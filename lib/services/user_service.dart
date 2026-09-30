import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

ValueNotifier<UserService> userService = ValueNotifier(UserService());

enum LoginType { dummyJson, firebase }

class UserService {
  final firebase_auth.FirebaseAuth firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  firebase_auth.User? get currentUser => firebaseAuth.currentUser;

  Stream<firebase_auth.User?> get authStateChanges =>
      firebaseAuth.authStateChanges();

  Future<firebase_auth.UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user != null) {
      await _clearLocalSession();
      await _cacheFirebaseUser(user);
      try {
        await syncChatDirectory();
      } catch (_) {}
    }
    return credential;
  }

  Future<firebase_auth.UserCredential> createAccount({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int age,
    required String contactNo,
    required String username,
  }) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) throw StateError('Firebase did not return a user.');

    await user.updateDisplayName(username);
    final profile = <String, dynamic>{
      'uid': user.uid,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'contactNo': contactNo,
      'username': username,
      'email': email,
      'loginType': LoginType.firebase.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _clearLocalSession();
    await _cacheFirebaseUser(user, profile: profile);
    try {
      await firestore.collection('users').doc(user.uid).set(profile);
      try {
        await syncChatDirectory();
      } catch (_) {}
      await user.getIdToken(true);
    } catch (_) {
      try {
        await user.delete();
      } catch (_) {}
      await signOut();
      rethrow;
    }
    return credential;
  }

  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } finally {
      await _clearLocalSession();
    }
  }

  Future<void> updateUsername({required String username}) async {
    final preferences = await SharedPreferences.getInstance();
    final loginType = preferences.getString('loginType');
    if (loginType == LoginType.firebase.name) {
      final user = currentUser;
      if (user == null) throw StateError('No Firebase user is signed in.');
      await user.updateDisplayName(username);
      await firestore.collection('users').doc(user.uid).set({
        'username': username,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      try {
        await syncChatDirectory();
      } catch (_) {}
      await preferences.setString('username', username);
      return;
    }

    final userData = await getUserData();
    final id = userData['id'] as int? ?? 0;
    if (id > 0 && id != 9999) {
      final response = await http.put(
        Uri.parse('$host/users/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Could not update username');
      }
    }
    await preferences.setString('username', username);
  }

  Future<void> updateUserName({required String username}) =>
      updateUsername(username: username);

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    final user = currentUser;
    if (user == null) throw StateError('No Firebase user is signed in.');
    final credential = firebase_auth.EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
    await user.getIdToken(true);
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString('loginType') != LoginType.firebase.name) {
      final userData = await getUserData();
      final id = userData['id'] as int? ?? 0;
      if (id > 0 && id != 9999) {
        final response = await http.delete(Uri.parse('$host/users/$id'));
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception('Could not delete account');
        }
      }
      await signOut();
      return;
    }

    final user = currentUser;
    if (user == null) throw StateError('No Firebase user is signed in.');
    final credential = firebase_auth.EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
    await firestore.collection('chat_directory').doc(user.uid).delete();
    await firestore.collection('users').doc(user.uid).delete();
    await user.delete();
    await signOut();
  }

  Future<String?> getAccessToken({bool forceRefresh = false}) async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString('loginType') == LoginType.firebase.name) {
      final user = currentUser;
      if (user == null) return null;
      final token = await user.getIdToken(forceRefresh);
      if (token != null) await preferences.setString('accessToken', token);
      return token;
    }

    final accessToken = preferences.getString('accessToken') ?? '';
    final refreshToken = preferences.getString('refreshToken') ?? '';
    if (!forceRefresh && accessToken.isNotEmpty) return accessToken;
    if (refreshToken.isEmpty) return accessToken.isEmpty ? null : accessToken;

    final response = await http.post(
      Uri.parse('$host/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken, 'expiresInMins': 60}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Could not refresh login session');
    }
    final refreshed = jsonDecode(response.body) as Map<String, dynamic>;
    final token = refreshed['accessToken']?.toString();
    if (token != null) await preferences.setString('accessToken', token);
    final newRefreshToken = refreshed['refreshToken']?.toString();
    if (newRefreshToken != null) {
      await preferences.setString('refreshToken', newRefreshToken);
    }
    return token;
  }

  Future<User> loginUser(String username, String password) async {
    if (username.trim().toLowerCase() == 'zyn' && password == 'zynpass') {
      const demoUser = User(
        id: 9999,
        username: 'zyn',
        email: 'zyndiaz@dummy.com',
        firstName: 'Zyn',
        lastName: 'Diaz',
        gender: 'female',
        image: '',
        accessToken: 'local-zyn-session',
        refreshToken: '',
      );
      await firebaseAuth.signOut();
      await saveUserData(demoUser);
      return demoUser;
    }

    final response = await http.post(
      Uri.parse('$host/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 60,
      }),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['message'] ?? 'Login failed');
    }

    final user = User.fromJson(jsonDecode(response.body));
    await firebaseAuth.signOut();
    await saveUserData(user);
    return user;
  }

  // Activity 4 Enhancement 3: persist typed API user data for profile/cart use.
  Future<void> saveUserData(User user) async {
    await _clearLocalSession();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('loginType', LoginType.dummyJson.name);
    await preferences.setInt('id', user.id);
    await preferences.setString('username', user.username);
    await preferences.setString('email', user.email);
    await preferences.setString('firstName', user.firstName);
    await preferences.setString('lastName', user.lastName);
    await preferences.setString('gender', user.gender);
    await preferences.setString('image', user.image);
    await preferences.setString('accessToken', user.accessToken);
    await preferences.setString('refreshToken', user.refreshToken);
  }

  Future<Map<String, dynamic>> getUserData() async {
    final preferences = await SharedPreferences.getInstance();
    final firebaseUser = currentUser;
    final isFirebaseUser =
        preferences.getString('loginType') == LoginType.firebase.name &&
        firebaseUser != null;
    var profile = <String, dynamic>{};
    if (isFirebaseUser) {
      try {
        final snapshot = await firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        profile = snapshot.data() ?? {};
      } catch (_) {}
    }

    return {
      'id': isFirebaseUser ? firebaseUser.uid : preferences.getInt('id') ?? 0,
      'uid': isFirebaseUser ? firebaseUser.uid : '',
      'loginType': isFirebaseUser
          ? LoginType.firebase.name
          : preferences.getString('loginType') ?? LoginType.dummyJson.name,
      'email':
          profile['email'] ??
          firebaseUser?.email ??
          preferences.getString('email') ??
          '',
      'firstName':
          profile['firstName'] ?? preferences.getString('firstName') ?? '',
      'lastName':
          profile['lastName'] ?? preferences.getString('lastName') ?? '',
      'age': profile['age'] ?? preferences.getInt('age'),
      'contactNo':
          profile['contactNo'] ?? preferences.getString('contactNo') ?? '',
      'username':
          profile['username'] ??
          firebaseUser?.displayName ??
          preferences.getString('username') ??
          '',
      'gender': preferences.getString('gender') ?? '',
      'image': preferences.getString('image') ?? '',
      'accessToken': isFirebaseUser
          ? await firebaseUser.getIdToken() ?? ''
          : preferences.getString('accessToken') ?? '',
      'refreshToken': preferences.getString('refreshToken') ?? '',
    };
  }

  Future<void> syncChatDirectory() async {
    final user = currentUser;
    if (user == null) return;

    final snapshot = await firestore.collection('users').doc(user.uid).get();
    final profile = snapshot.data() ?? <String, dynamic>{};
    await firestore.collection('chat_directory').doc(user.uid).set({
      'uid': user.uid,
      'firstName': (profile['firstName'] ?? '').toString(),
      'lastName': (profile['lastName'] ?? '').toString(),
      'username': (profile['username'] ?? user.displayName ?? '').toString(),
      'email': (profile['email'] ?? user.email ?? '').toString(),
    }, SetOptions(merge: true));
  }

  Future<User?> getUser() async {
    final userData = await getUserData();
    if (userData['loginType'] != LoginType.dummyJson.name ||
        (userData['id'] as int) <= 0) {
      return null;
    }
    return User.fromJson(userData);
  }

  Future<bool> isLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString('loginType') == LoginType.firebase.name) {
      return currentUser != null;
    }
    final accessToken = preferences.getString('accessToken') ?? '';
    return accessToken.isNotEmpty && (preferences.getInt('id') ?? 0) > 0;
  }

  Future<void> logout() => signOut();

  Future<void> _cacheFirebaseUser(
    firebase_auth.User user, {
    Map<String, dynamic>? profile,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final token = await user.getIdToken();
    await preferences.setString('loginType', LoginType.firebase.name);
    await preferences.setString('uid', user.uid);
    await preferences.setString('accessToken', token ?? '');
    await preferences.setString('email', user.email ?? '');
    await preferences.setString(
      'username',
      profile?['username']?.toString() ?? user.displayName ?? '',
    );
    if (profile != null) {
      await preferences.setString(
        'firstName',
        profile['firstName']?.toString() ?? '',
      );
      await preferences.setString(
        'lastName',
        profile['lastName']?.toString() ?? '',
      );
      await preferences.setInt('age', profile['age'] as int? ?? 0);
      await preferences.setString(
        'contactNo',
        profile['contactNo']?.toString() ?? '',
      );
    }
  }

  Future<void> _clearLocalSession() async {
    final preferences = await SharedPreferences.getInstance();
    for (final key in [
      'id',
      'uid',
      'username',
      'email',
      'firstName',
      'lastName',
      'age',
      'contactNo',
      'gender',
      'image',
      'accessToken',
      'refreshToken',
      'loginType',
    ]) {
      await preferences.remove(key);
    }
  }
}
