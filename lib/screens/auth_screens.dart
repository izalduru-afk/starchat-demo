import 'package:flutter/material.dart';

import '../data.dart';
import '../widgets.dart';
import 'home_shell.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  /// Which sign-in button is loading: 'google', 'apple', or null.
  String? _loading;

  Future<void> _continue(String provider) async {
    setState(() => _loading = provider);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
    );
  }

  Widget _signInButton({
    required String provider,
    required String label,
    required Widget icon,
    required Color background,
    required Color foreground,
  }) {
    final loading = _loading == provider;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _loading != null ? null : () => _continue(provider),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: background,
          disabledForegroundColor: foreground,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: loading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: foreground),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 28),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B21B6),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFC4B5FD), width: 2),
                      ),
                      child: const Icon(Icons.forum_rounded, color: Colors.white, size: 50),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'StarChat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Private chats and communities\nin one app',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFE4DCFB), fontSize: 17, height: 1.5),
                    ),
                  ],
                ),
              ),
              _signInButton(
                provider: 'google',
                label: 'Sign in with Google',
                background: Colors.white,
                foreground: kText,
                icon: Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD6D3E0), width: 1.5),
                  ),
                  child: const Text('G',
                      style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF4C1D95))),
                ),
              ),
              const SizedBox(height: 12),
              _signInButton(
                provider: 'apple',
                label: 'Sign in with Apple',
                background: Colors.black,
                foreground: Colors.white,
                icon: const Icon(Icons.apple, size: 26, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFD9CFF7), fontSize: 12, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Used both after sign-in and from "Edit Profile".
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key, this.editMode = false});

  final bool editMode;

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _username;
  late final TextEditingController _bio;
  DateTime? _dob;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: app.myName);
    _username = TextEditingController(text: app.myUsername);
    _bio = TextEditingController(text: app.myBio);
    _dob = app.myDob;
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _bio.dispose();
    super.dispose();
  }

  String? get _usernameError {
    final u = _username.text.trim();
    if (u.isEmpty) return 'Username is required';
    if (!kUsernamePattern.hasMatch(u)) {
      return 'Use 3–30 lowercase letters, numbers, or _';
    }
    if (app.isUserUsernameTaken(u)) return 'This username is already taken';
    return null;
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 20, 1, 1),
      firstDate: DateTime(1940),
      lastDate: now,
      helpText: 'Date of Birth',
    );
    if (picked != null) setState(() => _dob = picked);
  }

  void _save() {
    setState(() => _submitted = true);
    if (_name.text.trim().isEmpty || _usernameError != null || _dob == null) {
      showSnack(context, 'Please complete the required fields');
      return;
    }
    app.updateProfile(
      name: _name.text.trim(),
      username: _username.text.trim(),
      bio: _bio.text.trim(),
      dob: _dob,
    );
    if (widget.editMode) {
      Navigator.of(context).pop();
      showSnack(context, 'Profile updated');
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usernameError = _usernameError;

    return Scaffold(
      appBar: widget.editMode ? AppBar(title: const Text('Edit Profile')) : null,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            if (!widget.editMode) ...[
              const SizedBox(height: 12),
              const Text(
                'Complete Your Profile',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: kText),
              ),
              const SizedBox(height: 6),
              const Text(
                'Set up your profile before you start chatting',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: kMuted),
              ),
              const SizedBox(height: 24),
            ],
            Center(
              child: SizedBox(
                width: 112,
                height: 112,
                child: Stack(
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: kPrimaryLight, shape: BoxShape.circle),
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _name,
                        builder: (_, value, __) => Text(
                          initialsOf(value.text),
                          style: const TextStyle(
                              fontSize: 38, fontWeight: FontWeight.w700, color: Color(0xFF5B21B6)),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Material(
                        color: kPrimary,
                        shape: const CircleBorder(side: BorderSide(color: Colors.white, width: 3)),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => showSnack(
                              context, 'Photo upload will be available in the full version'),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.photo_camera_outlined, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                errorText: _submitted && _name.text.trim().isEmpty ? 'Full name is required' : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _username,
              autocorrect: false,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: const Icon(Icons.alternate_email_rounded),
                suffixIcon: usernameError == null
                    ? const Icon(Icons.check_circle_rounded, color: kGreen)
                    : null,
                helperText: usernameError == null ? 'Username is available' : null,
                helperStyle: const TextStyle(color: kGreen),
                errorText: usernameError,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDob,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon: const Icon(Icons.cake_outlined),
                  suffixIcon: const Icon(Icons.calendar_month_outlined),
                  errorText: _submitted && _dob == null ? 'Date of birth is required' : null,
                ),
                child: Text(
                  _dob == null ? 'Select date' : fmtDate(_dob!),
                  style: TextStyle(fontSize: 16, color: _dob == null ? kMuted : kText),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bio,
              maxLines: 3,
              maxLength: 150,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Bio (optional)',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.notes_rounded),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: FilledButton(
            onPressed: _save,
            child: Text(widget.editMode ? 'Save Changes' : 'Save and Continue'),
          ),
        ),
      ),
    );
  }
}
