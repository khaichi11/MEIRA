package id.meira.meira

import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileNotFoundException

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Lokasi library native: llama-server dikemas sebagai libllama_server.so dan dijalankan dari sini.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "meira/native").setMethodCallHandler { call, result ->
            when (call.method) {
                "nativeLibraryDir" -> result.success(applicationInfo.nativeLibraryDir)
                // APK lengkap membawa model bahasa dan Whisper sebagai aset. Model itu disalin bertahap ke folder
                // model karena llama-server dan sherpa-onnx membaca berkas biasa; memuatnya utuh ke memori Dart
                // terlalu besar. APK ringan tidak membawa model, sehingga hasilnya false.
                "copyAsset" -> {
                    val asset = call.argument<String>("asset")!!
                    val target = File(call.argument<String>("target")!!)
                    Thread {
                        try {
                            val key = FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(asset)
                            val part = File(target.path + ".part")
                            assets.open(key).use { input -> part.outputStream().use { input.copyTo(it, 1 shl 20) } }
                            part.renameTo(target)
                            runOnUiThread { result.success(true) }
                        } catch (e: FileNotFoundException) {
                            runOnUiThread { result.success(false) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("copyAsset", e.message, null) }
                        }
                    }.start()
                }
                else -> result.notImplemented()
            }
        }
    }
}
