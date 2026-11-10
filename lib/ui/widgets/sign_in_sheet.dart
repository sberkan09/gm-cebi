/// "Giriş yap": the online scene's sign-in with an emailed 6-digit code
/// (neuracraft-cloud #48). Asked when the online feature is first used, and
/// from Settings.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/neuracraft/errors.dart';
import '../../features/online_scene/account.dart';
import '../../features/online_scene/messages.dart';

/// Shows the sign-in sheet; true once signed in.
Future<bool> showSignInSheet(BuildContext context) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const SignInForm(),
  );
  return ok == true;
}

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class SignInForm extends ConsumerStatefulWidget {
  const SignInForm({super.key});

  @override
  ConsumerState<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<SignInForm> {
  final _email = TextEditingController();
  final _code = TextEditingController();

  /// The address the code went to; null on the email step.
  String? _sentTo;
  String? _error;
  bool _busy = false;

  /// Seconds before another code may be asked for.
  int _resendIn = 0;
  Timer? _countdown;

  @override
  void dispose() {
    _countdown?.cancel();
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  void _startCountdown(int seconds) {
    _countdown?.cancel();
    setState(() => _resendIn = seconds);
    if (seconds <= 0) return;
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _resendIn--);
      if (_resendIn <= 0) t.cancel();
    });
  }

  Future<void> _send() async {
    final email = _sentTo ?? _email.text.trim();
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _error = messageForReaction(NcReaction.invalidEmail));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final sent = await ref.read(ncAccountProvider.notifier).startEmail(email);
      if (!mounted) return;
      setState(() => _sentTo = email);
      _code.clear();
      _startCountdown(sent.resendAfter);
    } on NcException catch (e) {
      if (!mounted) return;
      setState(() => _error = messageFor(e));
      final wait = e is NcApiException ? e.retryAfter : null;
      if (wait != null && _sentTo != null) _startCountdown(wait);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    final email = _sentTo;
    if (email == null || _code.text.length != 6) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(ncAccountProvider.notifier).verifyEmail(email, _code.text);
      if (mounted) Navigator.pop(context, true);
    } on NcException catch (e) {
      if (!mounted) return;
      setState(() => _error = messageFor(e));
      if (e.reaction == NcReaction.codeExpired) _code.clear();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final sentTo = _sentTo;
    final error = _error;
    Widget progress() => const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2));
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Giriş yap', style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          sentTo == null ? signInInfo : 'Kodu $sentTo adresine gönderdik. Kod 10 dakika geçerli.',
          key: const Key('signin-info'),
          style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        if (sentTo == null)
          TextField(
            key: const Key('signin-email'),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _busy ? null : _send(),
            decoration: const InputDecoration(labelText: 'E-posta', border: OutlineInputBorder()),
          )
        else
          TextField(
            key: const Key('signin-code'),
            controller: _code,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.oneTimeCode],
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 6,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _busy ? null : _verify(),
            decoration: const InputDecoration(labelText: '6 haneli kod', border: OutlineInputBorder()),
          ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(error, key: const Key('signin-error'), style: t.bodyMedium?.copyWith(color: scheme.error)),
        ],
        const SizedBox(height: 12),
        if (sentTo == null)
          FilledButton(key: const Key('signin-send'), onPressed: _busy ? null : _send, child: _busy ? progress() : const Text('Kod gönder'))
        else ...[
          FilledButton(
            key: const Key('signin-verify'),
            onPressed: _busy || _code.text.length != 6 ? null : _verify,
            child: _busy ? progress() : const Text('Giriş yap'),
          ),
          const SizedBox(height: 4),
          Wrap(alignment: WrapAlignment.spaceBetween, children: [
            TextButton(
              key: const Key('signin-resend'),
              onPressed: _busy || _resendIn > 0 ? null : _send,
              child: Text(_resendIn > 0 ? 'Yeniden gönder ($_resendIn sn)' : 'Kodu yeniden gönder'),
            ),
            TextButton(
              key: const Key('signin-change-email'),
              onPressed: _busy
                  ? null
                  : () {
                      _countdown?.cancel();
                      setState(() {
                        _sentTo = null;
                        _error = null;
                        _resendIn = 0;
                      });
                    },
              child: const Text('E-postayı değiştir'),
            ),
          ]),
        ],
      ]),
    );
  }
}
