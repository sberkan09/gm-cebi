/// "Giriş yap": the online scene's sign-in with an emailed 6-digit code
/// (neuracraft-cloud #48). Asked when the online feature is first used, and
/// from Settings. Wherever it starts, the consent comes first
/// ([ensureOnlineConsent]): no address leaves the device before it.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/neuracraft/errors.dart';
import '../../features/online_scene/account.dart';
import '../../features/online_scene/messages.dart';
import '../../features/online_scene/online_settings.dart';

/// The online feature's first-use consent: true when it was given before or
/// is given now. False when the user declines, and (without asking) while the
/// feature is switched off in Settings or this build is no longer accepted:
/// nothing is sent then, so there is nothing to consent to or sign in for.
Future<bool> ensureOnlineConsent(BuildContext context) async {
  // The app's container, not a widget's ref: the answer is saved even if the
  // screen that asked is gone by then.
  final container = ProviderScope.containerOf(context, listen: false);
  final settings = container.read(onlineSettingsProvider).value;
  if (settings == null || !settings.enabled || settings.authInvalid) return false;
  if (settings.consented) return true;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(consentTitle),
      content: const SingleChildScrollView(child: Text(consentText)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
        FilledButton(key: const Key('consent-accept'), onPressed: () => Navigator.pop(context, true), child: const Text('Kabul et')),
      ],
    ),
  );
  if (ok != true) return false;
  await container.read(onlineSettingsProvider.notifier).setConsented(true);
  return true;
}

/// Shows the sign-in sheet, after the consent if it is still missing; true
/// once signed in.
Future<bool> showSignInSheet(BuildContext context) async {
  if (!await ensureOnlineConsent(context) || !context.mounted) return false;
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    // The form draws its own handle: while a request is on its way the sheet
    // must not be dragged away, which the built-in handle cannot be told.
    showDragHandle: false,
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

  /// When another code may be asked for; the countdown shows what is left.
  DateTime? _resendAt;
  Timer? _countdown;

  DateTime _now() => ref.read(ncClockProvider)();

  /// Seconds before another code may be asked for.
  int get _resendIn {
    final at = _resendAt;
    if (at == null) return 0;
    final left = at.difference(_now()).inMilliseconds;
    return left <= 0 ? 0 : (left / 1000).ceil();
  }

  @override
  void initState() {
    super.initState();
    // A code sent earlier in this run of the app (the sheet was closed, or
    // closed itself, meanwhile): go on at the code step. Asking for another
    // one now would only be refused (`auth.code_rate_limited`).
    final sent = ref.read(ncCodeRequestProvider.notifier).current(_now());
    if (sent != null) {
      _sentTo = sent.email;
      _resendAt = sent.resendAt;
      _runCountdown();
    }
  }

  @override
  void dispose() {
    _countdown?.cancel();
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  void _startCountdown(DateTime resendAt) {
    setState(() => _resendAt = resendAt);
    _runCountdown();
  }

  /// Redraws once a second until the resend time has passed.
  void _runCountdown() {
    _countdown?.cancel();
    if (_resendIn <= 0) return;
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {});
      if (_resendIn <= 0) t.cancel();
    });
  }

  Future<void> _send() async {
    final email = _sentTo ?? _email.text.trim();
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _error = messageForReaction(NcReaction.invalidEmail));
      return;
    }
    final account = ref.read(ncAccountProvider.notifier);
    final requests = ref.read(ncCodeRequestProvider.notifier);
    final now = _now();
    final sent = requests.current(now);
    if (_sentTo == null && sent != null && sent.email.toLowerCase() == email.toLowerCase() && now.isBefore(sent.resendAt)) {
      // The same address again within the resend time: its code is on its way.
      _code.clear();
      setState(() {
        _sentTo = sent.email;
        _error = null;
      });
      _startCountdown(sent.resendAt);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final answer = await account.startEmail(email);
      if (!mounted) return;
      setState(() => _sentTo = email);
      _code.clear();
      _startCountdown(_now().add(Duration(seconds: answer.resendAfter)));
    } on NcException catch (e) {
      if (!mounted) return;
      setState(() => _error = messageFor(e));
      final wait = e is NcApiException ? e.retryAfter : null;
      if (wait != null && _sentTo != null) {
        final at = _now().add(Duration(seconds: wait));
        requests.resendBlockedUntil(at);
        _startCountdown(at);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    final email = _sentTo;
    if (email == null || _code.text.length != 6) return;
    final account = ref.read(ncAccountProvider.notifier);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await account.verifyEmail(email, _code.text);
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
    final resendIn = _resendIn;
    Widget progress() => const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2));
    // While a request is on its way the sheet stays: not by the back button
    // or a tap outside (PopScope), not by dragging it down (the drag is taken
    // here, before the sheet's own recognizer gets it). Otherwise the answer,
    // an error included, would arrive with nobody to show it to.
    return PopScope(
      canPop: !_busy,
      child: GestureDetector(
        key: const Key('signin-sheet'),
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: _busy ? (_) {} : null,
        onVerticalDragUpdate: _busy ? (_) {} : null,
        onVerticalDragEnd: _busy ? (_) {} : null,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // The sheet's handle (as the Material one: 32 × 4 in a 48 dp band).
            SizedBox(
              height: kMinInteractiveDimension,
              child: Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(color: scheme.onSurfaceVariant.withValues(alpha: _busy ? 0.2 : 1), borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ),
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
                  onPressed: _busy || resendIn > 0 ? null : _send,
                  child: Text(resendIn > 0 ? 'Yeniden gönder ($resendIn sn)' : 'Kodu yeniden gönder'),
                ),
                TextButton(
                  key: const Key('signin-change-email'),
                  onPressed: _busy
                      ? null
                      : () {
                          // The request stays remembered: the same address
                          // typed again goes back to the code step.
                          _countdown?.cancel();
                          setState(() {
                            _sentTo = null;
                            _error = null;
                            _resendAt = null;
                          });
                        },
                  child: const Text('E-postayı değiştir'),
                ),
              ]),
            ],
          ]),
        ),
      ),
    );
  }
}
