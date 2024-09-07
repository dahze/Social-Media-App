// ignore_for_file: avoid_print, library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/profile_service.dart';
import '../services/friend_service.dart';
import '../widgets/retro_button.dart';
import 'feed_screen.dart';
import 'friends_screen.dart';
import 'search_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  ProfileScreen({super.key, required this.userId}) {
    print('ProfileScreen initialized with userId: $userId');
  }

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 2;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadUserProfile(widget.userId);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const FeedScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const FriendsScreen()));
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SearchScreen()));
        break;
    }
  }

  void _resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: context.read<ProfileProvider>().profile!.email);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send password reset email')));
    }
  }

  void _showConfirmDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xffbff0ce),
          content: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: Colors.black,
                width: 1.0,
              ),
            ),
            child: Text(
              content,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirm();
                  },
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'PressStart2P',
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'PressStart2P',
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount() async {
    _showConfirmDialog(
      title: 'Delete Account',
      content: 'Are you sure you want to delete your account?',
      onConfirm: () async {
        try {
          final profileProvider = context.read<ProfileProvider>();
          final userId = profileProvider.profile?.userId;

          if (userId != null) {
            await FriendService().cleanupUserRequests(userId);

            await _profileService.deleteUserProfile(userId);

            await FirebaseAuth.instance.currentUser!.delete();

            profileProvider.clearProfile();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account deleted successfully!')),
            );

            Navigator.of(context).pushNamedAndRemoveUntil(
              '/signin',
              (route) => false,
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete account')),
          );
        }
      },
    );
  }

  void _signOut() async {
    _showConfirmDialog(
      title: 'Sign Out',
      content: 'Are you sure you want to sign out?',
      onConfirm: () async {
        try {
          await FirebaseAuth.instance.signOut();
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/signin',
            (route) => false,
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to sign out')));
        }
      },
    );
  }

  void _updateUsername(String newUsername) async {
    try {
      if (newUsername.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username cannot be empty')),
        );
        return;
      }

      if (newUsername.length > 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Username cannot be more than 10 characters')),
        );
        return;
      }

      final profileProvider = context.read<ProfileProvider>();
      final updatedProfile = UserProfile(
        userId: profileProvider.profile!.userId,
        username: newUsername,
        email: profileProvider.profile!.email,
      );

      await _profileService.updateUserProfile(updatedProfile);

      profileProvider.loadUserProfile(profileProvider.profile!.userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update username')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xfffef9ef),
        appBar: AppBar(
          title: const Text(
            '2001',
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          backgroundColor: const Color(0xfffef9ef),
          elevation: 0,
          titleSpacing: -28,
          leading: const SizedBox(width: 0),
        ),
        body: Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
            if (profileProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final profile = profileProvider.profile;

            if (profile == null) {
              return const Center(child: Text('No profile data available'));
            }

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        profile.username,
                        style:
                            const TextStyle(fontSize: 24, color: Colors.black),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              final newUsernameController =
                                  TextEditingController();
                              return AlertDialog(
                                backgroundColor: const Color(0xffbff0ce),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: newUsernameController,
                                      decoration: InputDecoration(
                                        hintText: 'New Username',
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                          fontFamily: 'PressStart2P',
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          borderSide: const BorderSide(
                                            color: Colors.black,
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          borderSide: const BorderSide(
                                            color: Colors.black,
                                            width: 1.0,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          borderSide: const BorderSide(
                                            color: Colors.black,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      style:
                                          const TextStyle(color: Colors.black),
                                      maxLength: 10,
                                      buildCounter: (context,
                                          {required currentLength,
                                          required isFocused,
                                          maxLength}) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            '$currentLength/$maxLength',
                                            style: const TextStyle(
                                              fontFamily: 'PressStart2P',
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                actions: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          _updateUsername(
                                              newUsernameController.text);
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          'Update',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'PressStart2P',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'PressStart2P',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        profile.email.length > 21
                            ? '${profile.email.substring(0, 18)}...'
                            : profile.email,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  RetroButton(
                    text: 'Reset Password',
                    onPressed: _resetPassword,
                  ),
                  const SizedBox(height: 10),
                  RetroButton(
                    text: 'Sign Out',
                    onPressed: _signOut,
                  ),
                  const SizedBox(height: 10),
                  RetroButton(
                    text: 'Delete Account',
                    onPressed: _deleteAccount,
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Color(0xffc7a3ef),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: BottomAppBar(
            color: Colors.transparent,
            elevation: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(Icons.home, 0),
                _buildBottomNavItem(Icons.search, 3),
                _buildBottomNavItem(Icons.people, 1),
                _buildBottomNavItem(Icons.person, 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    SystemNavigator.pop();
    return Future.value(false);
  }

  Widget _buildBottomNavItem(IconData icon, int index) {
    final bool isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? Colors.black : Colors.white,
        size: 30,
      ),
      onPressed: () => _onItemTapped(index),
    );
  }
}
