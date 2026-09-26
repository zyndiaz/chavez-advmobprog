import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

class UserService {
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
    await saveUserData(user);
    return user;
  }

  // Activity 4 Enhancement 3: persist typed API user data for profile/cart use.
  Future<void> saveUserData(User user) async {
    final preferences = await SharedPreferences.getInstance();
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
    return {
      'id': preferences.getInt('id') ?? 0,
      'username': preferences.getString('username') ?? '',
      'email': preferences.getString('email') ?? '',
      'firstName': preferences.getString('firstName') ?? '',
      'lastName': preferences.getString('lastName') ?? '',
      'gender': preferences.getString('gender') ?? '',
      'image': preferences.getString('image') ?? '',
      'accessToken': preferences.getString('accessToken') ?? '',
      'refreshToken': preferences.getString('refreshToken') ?? '',
    };
  }

  Future<User?> getUser() async {
    final userData = await getUserData();
    if ((userData['id'] as int) <= 0) return null;
    return User.fromJson(userData);
  }

  Future<bool> isLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    final accessToken = preferences.getString('accessToken') ?? '';
    return accessToken.isNotEmpty && (preferences.getInt('id') ?? 0) > 0;
  }

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    for (final key in [
      'id',
      'username',
      'email',
      'firstName',
      'lastName',
      'gender',
      'image',
      'accessToken',
      'refreshToken',
    ]) {
      await preferences.remove(key);
    }
  }
}
