import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme.dart';
import 'widgets.dart';

/// Sekali saja di awal: nama panggilan untuk menyapa pengguna. Tanpa akun daring; nama hanya disimpan di ponsel.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save(AppState s, String name) => s.setPref('user_name', name);

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 48, 28, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const LogoMark(size: 64),
            const SizedBox(height: 32),
            Text('Halo, selamat datang', style: poppins(28, height: 1.2)),
            const SizedBox(height: 8),
            Text('Boleh tahu nama panggilan Anda?', style: inter(16, color: C.secondary)),
            const SizedBox(height: 28),
            TextField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              style: inter(18),
              decoration: const InputDecoration(hintText: 'Nama panggilan', contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16)),
              onChanged: (_) => setState(() {}),
              onSubmitted: (v) => v.trim().isEmpty ? null : _save(s, v),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _name.text.trim().isEmpty ? null : () => _save(s, _name.text), child: const Text('Lanjut')),
            ),
            Center(child: TextButton(onPressed: () => _save(s, ''), child: const Text('Nanti saja'))),
          ]),
        ),
      ),
    );
  }
}
