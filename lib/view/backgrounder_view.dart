import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BackgroundHider extends StatefulWidget {
  final Widget child;

  const BackgroundHider({super.key, required this.child});

  @override
  State<BackgroundHider> createState() => _BackgroundHiderState();
}

class _BackgroundHiderState extends State<BackgroundHider>
    with WidgetsBindingObserver {
  
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isBackground = false; // Controls the overlay visibility
  bool _isLocked = false; // Tracks if the user needs to authenticate

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start in a locked state if the app requires high security from the start
    // _isLocked = true; 
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // --- Biometric Authentication Logic ---

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      // Check if biometrics are available before attempting to authenticate
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) {
        // Fallback: If biometrics aren't available, just unlock the app.
        // In a real app, you might fall back to a PIN or password screen.
        print("Biometrics not available. Skipping authentication.");
        _unlockApp();
        return;
      }
      
      authenticated = await _auth.authenticate(
        localizedReason: 'Please verify your identity to unlock the secure app.',
        biometricOnly: true
      );
    } on PlatformException catch (e) {
      print("Authentication error: $e");
      // Handle fatal errors (e.g., no sensors, too many attempts)
    }

    if (!mounted) return;

    if (authenticated) {
      _unlockApp();
    } else {
      // If authentication failed (user cancelled or failed), keep the app locked
      // In a high-security app, you might terminate the app here: SystemNavigator.pop();
      print("Authentication failed. App remains locked.");
    }
  }
  
  void _lockApp() {
    setState(() {
      _isBackground = true;
      _isLocked = true;
    });
  }

  void _unlockApp() {
    setState(() {
      _isBackground = false;
      _isLocked = false;
    });
  }

  // --- WidgetsBindingObserver Method ---

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    if (state == AppLifecycleState.paused) {
      // The app goes to the background (set the visual barrier)
      _lockApp();
    } else if (state == AppLifecycleState.resumed) {
      // The app returns to the foreground (prompt for biometrics)
      if (_isLocked) {
        _authenticate();
      }
    }
  }

  // --- Widget Build Method ---

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. The main app content
        widget.child,

        // 2. The secure overlay barrier
        if (_isBackground)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  // Show a clear prompt if it's locked and waiting for auth
                  child: _isLocked
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock, color: Colors.white70, size: 80),
                            const SizedBox(height: 20),
                            const Text(
                              'App Locked. Authenticate to Proceed.',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton.icon(
                              onPressed: _authenticate,
                              icon: const Icon(Icons.fingerprint),
                              label: const Text('Re-authenticate'),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(), // Hides the lock content if only the blur is showing
                ),
              ),
            ),
          ),
      ],
    );
  }
}