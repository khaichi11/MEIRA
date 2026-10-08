/// Pembungkus ONNX Runtime yang ringkas untuk detektor bahan dan OCR. Memakai libonnxruntime.so yang sudah
/// dibawa paket sherpa_onnx, jadi tidak menambah pustaka native. Tensor masuk dan keluar berupa Float32List.
library;

import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../third_party/onnxruntime_bindings.dart';

typedef _Status = OrtStatusPtr;

class Tensor {
  Tensor(this.data, this.shape);
  final Float32List data;
  final List<int> shape;
}

class OrtModel {
  OrtModel._(this._session, this._names, this._outputs);

  static ffi.Pointer<OrtApi>? _apiPtr;
  static ffi.Pointer<OrtEnv>? _env;

  /// Lokasi pustaka: Android memakai milik sherpa_onnx; uji di laptop dapat menunjuk ke berkas lain lewat
  /// variabel lingkungan MEIRA_ORT_LIB (misalnya libonnxruntime.so dari paket Python onnxruntime).
  static ffi.DynamicLibrary _open() {
    final custom = Platform.environment['MEIRA_ORT_LIB'];
    if (custom != null && custom.isNotEmpty) return ffi.DynamicLibrary.open(custom);
    return ffi.DynamicLibrary.open('libonnxruntime.so');
  }

  static OrtApi get _api {
    if (_apiPtr == null) {
      final base = OnnxRuntimeBindings(_open()).OrtGetApiBase();
      // versi API 14 cukup untuk fungsi yang dipakai di sini dan didukung oleh ONNX Runtime yang lebih baru
      _apiPtr = base.ref.GetApi.asFunction<ffi.Pointer<OrtApi> Function(int)>()(14);
      final out = calloc<ffi.Pointer<OrtEnv>>();
      final id = 'meira'.toNativeUtf8().cast<ffi.Char>();
      _check(_apiPtr!.ref.CreateEnv.asFunction<_Status Function(int, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Pointer<OrtEnv>>)>()(3, id, out));
      _env = out.value;
      calloc.free(out);
      calloc.free(id);
    }
    return _apiPtr!.ref;
  }

  static void _check(_Status status) {
    if (status == ffi.nullptr) return;
    final api = _apiPtr!.ref;
    final msg = api.GetErrorMessage.asFunction<ffi.Pointer<ffi.Char> Function(_Status)>()(status).cast<Utf8>().toDartString();
    api.ReleaseStatus.asFunction<void Function(_Status)>()(status);
    throw StateError('ONNX Runtime: $msg');
  }

  final ffi.Pointer<OrtSession> _session;
  final List<String> _names; // nama masukan
  final List<String> _outputs;

  static OrtModel load(String path, {int threads = 2}) {
    final api = _api;
    final opts = calloc<ffi.Pointer<OrtSessionOptions>>();
    _check(api.CreateSessionOptions.asFunction<_Status Function(ffi.Pointer<ffi.Pointer<OrtSessionOptions>>)>()(opts));
    _check(api.SetIntraOpNumThreads.asFunction<_Status Function(ffi.Pointer<OrtSessionOptions>, int)>()(opts.value, threads));
    _check(api.SetSessionGraphOptimizationLevel.asFunction<_Status Function(ffi.Pointer<OrtSessionOptions>, int)>()(opts.value, 99));
    final out = calloc<ffi.Pointer<OrtSession>>();
    final p = path.toNativeUtf8().cast<ffi.Char>();
    try {
      _check(
        api.CreateSession.asFunction<
          _Status Function(ffi.Pointer<OrtEnv>, ffi.Pointer<ffi.Char>, ffi.Pointer<OrtSessionOptions>, ffi.Pointer<ffi.Pointer<OrtSession>>)
        >()(_env!, p, opts.value, out),
      );
      final session = out.value;
      return OrtModel._(session, _ioNames(session, input: true), _ioNames(session, input: false));
    } finally {
      api.ReleaseSessionOptions.asFunction<void Function(ffi.Pointer<OrtSessionOptions>)>()(opts.value);
      calloc.free(opts);
      calloc.free(out);
      calloc.free(p);
    }
  }

  static List<String> _ioNames(ffi.Pointer<OrtSession> s, {required bool input}) {
    final api = _api;
    final alloc = calloc<ffi.Pointer<OrtAllocator>>();
    final count = calloc<ffi.Size>();
    final name = calloc<ffi.Pointer<ffi.Char>>();
    try {
      _check(api.GetAllocatorWithDefaultOptions.asFunction<_Status Function(ffi.Pointer<ffi.Pointer<OrtAllocator>>)>()(alloc));
      final countFn = (input ? api.SessionGetInputCount : api.SessionGetOutputCount)
          .asFunction<_Status Function(ffi.Pointer<OrtSession>, ffi.Pointer<ffi.Size>)>();
      final nameFn = (input ? api.SessionGetInputName : api.SessionGetOutputName)
          .asFunction<_Status Function(ffi.Pointer<OrtSession>, int, ffi.Pointer<OrtAllocator>, ffi.Pointer<ffi.Pointer<ffi.Char>>)>();
      final free = api.AllocatorFree.asFunction<_Status Function(ffi.Pointer<OrtAllocator>, ffi.Pointer<ffi.Void>)>();
      _check(countFn(s, count));
      final names = <String>[];
      for (var i = 0; i < count.value; i++) {
        _check(nameFn(s, i, alloc.value, name));
        names.add(name.value.cast<Utf8>().toDartString());
        _check(free(alloc.value, name.value.cast()));
      }
      return names;
    } finally {
      calloc.free(alloc);
      calloc.free(count);
      calloc.free(name);
    }
  }

  /// Satu masukan float32 bernama sesuai model; hasil: semua keluaran float32 sesuai urutan di model.
  List<Tensor> run(Tensor input) {
    final api = _api;
    final info = calloc<ffi.Pointer<OrtMemoryInfo>>();
    final data = calloc<ffi.Float>(input.data.length);
    final shape = calloc<ffi.Int64>(input.shape.length);
    final value = calloc<ffi.Pointer<OrtValue>>();
    final inNames = calloc<ffi.Pointer<ffi.Char>>(1);
    final outNames = calloc<ffi.Pointer<ffi.Char>>(_outputs.length);
    final outs = calloc<ffi.Pointer<OrtValue>>(_outputs.length);
    final shapeInfo = calloc<ffi.Pointer<OrtTensorTypeAndShapeInfo>>();
    final dims = calloc<ffi.Size>();
    final raw = calloc<ffi.Pointer<ffi.Void>>();
    try {
      data.asTypedList(input.data.length).setAll(0, input.data);
      for (var i = 0; i < input.shape.length; i++) {
        shape[i] = input.shape[i];
      }
      _check(api.CreateCpuMemoryInfo.asFunction<_Status Function(int, int, ffi.Pointer<ffi.Pointer<OrtMemoryInfo>>)>()(1, 0, info));
      _check(
        api.CreateTensorWithDataAsOrtValue.asFunction<
          _Status Function(
            ffi.Pointer<OrtMemoryInfo>,
            ffi.Pointer<ffi.Void>,
            int,
            ffi.Pointer<ffi.Int64>,
            int,
            int,
            ffi.Pointer<ffi.Pointer<OrtValue>>,
          )
        >()(info.value, data.cast(), input.data.length * 4, shape, input.shape.length, 1, value),
      );
      inNames[0] = _names.first.toNativeUtf8().cast();
      for (var i = 0; i < _outputs.length; i++) {
        outNames[i] = _outputs[i].toNativeUtf8().cast();
      }
      _check(
        api.Run.asFunction<
          _Status Function(
            ffi.Pointer<OrtSession>,
            ffi.Pointer<OrtRunOptions>,
            ffi.Pointer<ffi.Pointer<ffi.Char>>,
            ffi.Pointer<ffi.Pointer<OrtValue>>,
            int,
            ffi.Pointer<ffi.Pointer<ffi.Char>>,
            int,
            ffi.Pointer<ffi.Pointer<OrtValue>>,
          )
        >()(_session, ffi.nullptr, inNames, value, 1, outNames, _outputs.length, outs),
      );
      final result = <Tensor>[];
      for (var i = 0; i < _outputs.length; i++) {
        _check(
          api.GetTensorTypeAndShape.asFunction<_Status Function(ffi.Pointer<OrtValue>, ffi.Pointer<ffi.Pointer<OrtTensorTypeAndShapeInfo>>)>()(
            outs[i],
            shapeInfo,
          ),
        );
        _check(
          api.GetDimensionsCount.asFunction<_Status Function(ffi.Pointer<OrtTensorTypeAndShapeInfo>, ffi.Pointer<ffi.Size>)>()(shapeInfo.value, dims),
        );
        final d = calloc<ffi.Int64>(dims.value);
        _check(
          api.GetDimensions.asFunction<_Status Function(ffi.Pointer<OrtTensorTypeAndShapeInfo>, ffi.Pointer<ffi.Int64>, int)>()(
            shapeInfo.value,
            d,
            dims.value,
          ),
        );
        final outShape = [for (var k = 0; k < dims.value; k++) d[k]];
        calloc.free(d);
        api.ReleaseTensorTypeAndShapeInfo.asFunction<void Function(ffi.Pointer<OrtTensorTypeAndShapeInfo>)>()(shapeInfo.value);
        _check(api.GetTensorMutableData.asFunction<_Status Function(ffi.Pointer<OrtValue>, ffi.Pointer<ffi.Pointer<ffi.Void>>)>()(outs[i], raw));
        final n = outShape.fold<int>(1, (a, b) => a * b);
        result.add(Tensor(Float32List.fromList(raw.value.cast<ffi.Float>().asTypedList(n)), outShape));
        api.ReleaseValue.asFunction<void Function(ffi.Pointer<OrtValue>)>()(outs[i]);
      }
      return result;
    } finally {
      if (value.value != ffi.nullptr) api.ReleaseValue.asFunction<void Function(ffi.Pointer<OrtValue>)>()(value.value);
      if (info.value != ffi.nullptr) api.ReleaseMemoryInfo.asFunction<void Function(ffi.Pointer<OrtMemoryInfo>)>()(info.value);
      if (inNames[0] != ffi.nullptr) calloc.free(inNames[0]);
      for (var i = 0; i < _outputs.length; i++) {
        if (outNames[i] != ffi.nullptr) calloc.free(outNames[i]);
      }
      for (final p in [
        data.cast<ffi.Void>(),
        shape.cast<ffi.Void>(),
        value.cast<ffi.Void>(),
        inNames.cast<ffi.Void>(),
        outNames.cast<ffi.Void>(),
        outs.cast<ffi.Void>(),
        shapeInfo.cast<ffi.Void>(),
        dims.cast<ffi.Void>(),
        raw.cast<ffi.Void>(),
        info.cast<ffi.Void>(),
      ]) {
        calloc.free(p);
      }
    }
  }

  void close() => _api.ReleaseSession.asFunction<void Function(ffi.Pointer<OrtSession>)>()(_session);
}
