import 'dart:convert';
import 'package:amenities_kenya/constants.dart';
import 'package:amenities_kenya/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amenities_kenya/services/mock_auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null) {
    checkLoginStatus();
  }

  final MockAuthService _authService = MockAuthService(ApiClient());

  Future<String> sendOtp(String phoneNumber) async {
    try {
      return await _authService.sendOtp(phoneNumber);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> verifyOtp(String phoneNumber, String otp) async {
    try {
      final user = await _authService.verifyOtp(phoneNumber, otp);
      state = user;
      await _saveToken(user.token!);
      return user.token!;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp({
    required String userId,
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    try {
      final user = await _authService.signUp(
        phoneNumber: phoneNumber,
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
      state = user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
  }) async {
    if (state == null) throw 'No user logged in';
    try {
      await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      );
      state = User(
        userId: state!.userId,
        phoneNumber: phoneNumber,
        firstName: firstName,
        lastName: lastName,
        email: email,
        emailVerified: state!.emailVerified,
        createdAt: state!.createdAt,
        token: state!.token,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Future<void> verifyEmail(String verificationToken) async {
  //   if (state == null) throw 'No user logged in';
  //   try {
  //     await _authService.verifyEmail(state!.userId, verificationToken);
  //     state = User(
  //       userId: state!.userId,
  //       phoneNumber: state!.phoneNumber,
  //       firstName: state!.firstName,
  //       lastName: state!.lastName,
  //       email: state!.email,
  //       username: state!.username,
  //       emailVerified: true,
  //       createdAt: state!.createdAt,
  //       token: state!.token,
  //     );
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<void> logout() async {
    await _clearToken();
    state = null;
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

 Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      state = User(token: token); // Set user as logged in
      return true;
    }
    return false;
  }
}