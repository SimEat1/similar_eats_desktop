import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnonSignInScreen extends StatefulWidget {
  const AnonSignInScreen({super.key});

  @override
  State<AnonSignInScreen> createState() => _AnonSignInScreenState();
}

class _AnonSignInScreenState extends State<AnonSignInScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _signInAnon() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final cred = await FirebaseAuth.instance.signInAnonymously();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in as ${cred.user?.uid ?? "unknown"}')),
      );
      setState(() {/* nothing else */});
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out')),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Anon Sign-In')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Status: ${user == null ? "Signed out" : "Signed in"}'),
            if (user != null) ...[
              const SizedBox(height: 8),
              SelectableText('UID: ${user.uid}'),
            ],
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const Spacer(),
            FilledButton(
              onPressed: _busy ? null : (user == null ? _signInAnon : _signOut),
              child: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(user == null ? 'Sign in anonymously' : 'Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
