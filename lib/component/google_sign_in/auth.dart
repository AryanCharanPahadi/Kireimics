import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

String? userEmail;
String? uid;
String? name;
String? imageUrl;

Future<User?> signInWithGoogle() async {
  await Firebase.initializeApp();
  User? user;

  if (kIsWeb) {
    // For web
    GoogleAuthProvider authProvider = GoogleAuthProvider();
    authProvider.setCustomParameters({'prompt': 'select_account'});

    try {
      final UserCredential userCredential = await _auth.signInWithPopup(
        authProvider,
      );
      user = userCredential.user;
    } catch (e) {
      print('Web Google sign-in error: $e');
    }
  } else {
    // For mobile
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email'],
      // This prompts user to select an account every time
      // (essential on Android/iOS)
      signInOption: SignInOption.standard,
      // Optional: pass hostedDomain or clientId if using G Suite or custom OAuth
    );

    await googleSignIn.signOut(); // Ensure previous session is ended

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        final UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );
        user = userCredential.user;
      } catch (e) {
        print('Mobile Google sign-in error: $e');
      }
    }
  }

  if (user != null) {
    uid = user.uid;
    name = user.displayName;
    userEmail = user.email;
    imageUrl = user.photoURL;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auth', true);
  }

  return user;
}

Future<void> signOutGoogle() async {
  try {
    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();

    // Sign out from Google
    await GoogleSignIn().disconnect(); // Required to fully revoke token
    await GoogleSignIn().signOut(); // Clear local session
    await FirebaseAuth.instance.signOut();

    // Clear local variables
    uid = null;
    name = null;
    userEmail = null;
    imageUrl = null;

    // Clear auth state in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // clears all saved user data

    print(
      '✅ User completely signed out from Google, Firebase, and SharedPreferences',
    );
  } catch (e) {
    print('❌ Error during sign-out: $e');
  }
}
