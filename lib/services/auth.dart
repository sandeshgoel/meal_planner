import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final _googleSignIn = GoogleSignIn(
      clientId:
          '1095305802843-ruana11ojarldglgm5vaqfanhso5d91d.apps.googleusercontent.com');

  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithPopup(authProvider);

        return userCredential.user;
      } catch (e) {
        print(e);
        return null;
      }
    } else {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      _user = googleUser;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      UserCredential uc =
          await FirebaseAuth.instance.signInWithCredential(credential);
      notifyListeners();

      return uc.user;
    }
  }

  Future googleSignOut() async {
    return await _googleSignIn.signOut();
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? currentUser() {
    return _auth.currentUser;
  }

  void userReload() {
    _auth.currentUser!.reload();
  }

  // auth change user stream
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  Future signInAnon() async {
    try {
      UserCredential res = await _auth.signInAnonymously();
      return res.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future register(String email, String password) async {
    try {
      UserCredential res = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return res.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signIn(String email, String password) async {
    try {
      UserCredential res = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return res.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future checkEmail(String email) async {
    List<String> res = await _auth.fetchSignInMethodsForEmail(email);
    return res;
  }

  Future sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
