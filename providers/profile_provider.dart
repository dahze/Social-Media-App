// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileProvider with ChangeNotifier {
  UserProfile? _profile;
  bool _isLoading = false;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> loadUserProfile(String? userId) async {
    _isLoading = true;
    notifyListeners();

    if (userId == null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _profile = null;
        _isLoading = false;
        notifyListeners();
        return;
      }
      userId = user.uid;
    }

    try {
      print('Loading profile for userId: $userId');
      final profileService = ProfileService();
      final profileData = await profileService.getUserProfile(userId);

      if (profileData == null) {
        print('No profile found for userId: $userId');
        _profile = null;
      } else {
        _profile = profileData;
      }
    } catch (e) {
      print('Error loading profile: $e');
      _profile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    final profileService = ProfileService();
    await profileService.updateUserProfile(profile);
    _profile = profile;
    notifyListeners();
  }

  void clearProfile() {
    _profile = null;
    notifyListeners();
  }
}
