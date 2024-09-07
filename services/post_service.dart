import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createPost(Post post) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(post.userId).get();
      String username =
          userDoc.exists ? userDoc.get('username') : 'Unknown User';

      post.username = username;

      await _firestore
          .collection('users')
          .doc(post.userId)
          .collection('posts')
          .doc(post.postId)
          .set(post.toMap());
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  Future<List<Post>> getUserPosts(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Post.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  Future<List<Post>> loadAllPosts(String userId) async {
    try {
      QuerySnapshot userPostsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();

      List<Post> userPosts = userPostsSnapshot.docs
          .map((doc) => Post.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      QuerySnapshot friendsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .get();

      List<Future<QuerySnapshot>> friendsPostsFutures =
          friendsSnapshot.docs.map((friendDoc) {
        String friendId = friendDoc.id;
        return _firestore
            .collection('users')
            .doc(friendId)
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .get();
      }).toList();

      List<QuerySnapshot> friendsPostsSnapshots =
          await Future.wait(friendsPostsFutures);

      List<Post> friendsPosts = friendsPostsSnapshots.expand((snapshot) {
        return snapshot.docs
            .map((doc) => Post.fromMap(doc.data() as Map<String, dynamic>));
      }).toList();

      List<Post> allPosts = [...userPosts, ...friendsPosts];

      allPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return allPosts;
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }

  Future<void> updatePost(Post post) async {
    try {
      await _firestore
          .collection('users')
          .doc(post.userId)
          .collection('posts')
          .doc(post.postId)
          .update(post.toMap());
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  Future<void> deletePost(String userId, String postId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('posts')
          .doc(postId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  Future<String> fetchUsernameById(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.get('username') ?? 'Unknown User';
      } else {
        return 'User Not Found';
      }
    } catch (e) {
      throw Exception('Failed to fetch username: $e');
    }
  }
}
