import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Future loginWithEmail(
      {@required String email,
      @required String matricNo,
      @required String password}) async {
    try {
      var user = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return user != null;
    } catch (e) {
      return e.message;
    }
  }

  Future registerWithEmail(
      {@required String email,
      @required String matricNo,
      @required String password}) async {
    try {
      var authResult = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return authResult.user != null;
    } catch (e) {
      return e.message;
    }
  }

  Future recoverPasswordWithEmail({
    @required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: email,
      );
      return null;
    } catch (e) {
      return e.message;
    }
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future signInAnonymously() async {
    try {
      var user = await _firebaseAuth.signInAnonymously();
      return user != null;
    } catch (e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
}
