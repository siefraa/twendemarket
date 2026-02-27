import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _loading = false;

  AppUser? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<void> loadUser() async {
    final fb = FirebaseService.currentUser;
    if (fb != null) {
      _user = await FirebaseService.getUser(fb.uid);
      notifyListeners();
    }
  }

  Future<String?> signIn(String email, String password) async {
    _loading = true; notifyListeners();
    try {
      await FirebaseService.signIn(email, password);
      await loadUser();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    _loading = true; notifyListeners();
    try {
      final cred = await FirebaseService.signUp(email, password);
      final user = AppUser(id: cred.user!.uid, name: name, email: email, phone: phone);
      await FirebaseService.createUser(user);
      _user = user;
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> signOut() async {
    await FirebaseService.signOut();
    _user = null;
    notifyListeners();
  }
}
