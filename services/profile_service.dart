// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      print('Fetching profile for userId: $userId');
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        print('Profile found for userId: $userId');
        return UserProfile.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      } else {
        print('Profile not found for userId: $userId');
        return null;
      }
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.userId)
          .set(profile.toMap());

      QuerySnapshot postsSnapshot = await _firestore
          .collection('users')
          .doc(profile.userId)
          .collection('posts')
          .get();

      for (var post in postsSnapshot.docs) {
        await post.reference.update({'username': profile.username});
      }

      print(
          'User profile and posts updated successfully for userId: ${profile.userId}');
    } catch (e) {
      print('Error updating profile or posts: $e');
    }
  }

  Future<void> deleteUserProfile(String userId) async {
    try {
      QuerySnapshot postsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('posts')
          .get();

      for (var doc in postsSnapshot.docs) {
        await doc.reference.delete();
      }

      await _firestore.collection('users').doc(userId).delete();

      print('User profile and posts deleted for userId: $userId');
    } catch (e) {
      print('Error deleting user profile: $e');
    }
  }
}
