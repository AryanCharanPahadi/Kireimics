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
    // For Web
    // print('🌐 Attempting Google Sign-In on Web...');
    GoogleAuthProvider authProvider = GoogleAuthProvider();
    authProvider.setCustomParameters({'prompt': 'select_account'});

    try {
      final UserCredential userCredential =
      await _auth.signInWithPopup(authProvider);
      user = userCredential.user;
      // print('✅ Web Google sign-in successful: ${user?.email}');
    } catch (e) {
      // print('❌ Web Google sign-in error: $e');
    }
  } else {
    // For Mobile
    // print('📱 Attempting Google Sign-In on Mobile...');
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email'],
      signInOption: SignInOption.standard,
    );

    await googleSignIn.signOut(); // Optional: clear any existing session
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      // print('🔑 Retrieved Google account: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        final UserCredential userCredential =
        await _auth.signInWithCredential(credential);
        user = userCredential.user;
        // print('✅ Mobile Google sign-in successful: ${user?.email}');
      } catch (e) {
        // print('❌ Mobile Google sign-in error: $e');
      }
    } else {
      // print('⚠️ User canceled Google sign-in on mobile');
    }
  }

  if (user != null) {
    uid = user.uid;
    name = user.displayName;
    userEmail = user.email;
    imageUrl = user.photoURL;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auth', true);

    // print('🎉 User info saved:\n- UID: $uid\n- Name: $name\n- Email: $userEmail');
  }

  return user;
}
Future<void> signOutGoogle() async {
  try {
    // print('🚪 Signing out user...');
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().disconnect();
    await GoogleSignIn().signOut();

    uid = null;
    name = null;
    userEmail = null;
    imageUrl = null;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // print('✅ User completely signed out from Google, Firebase, and SharedPreferences');
  } catch (e) {
    // print('❌ Error during sign-out: $e');
  }
}
