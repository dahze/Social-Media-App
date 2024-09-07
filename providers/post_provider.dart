// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/post_service.dart';

class PostProvider with ChangeNotifier {
  final PostService _postService = PostService();
  List<Post> _posts = [];
  bool _isLoading = false;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  // ignore: prefer_final_fields
  Map<String, String> _usernames = {};

  Future<void> loadAllPosts(String userId) async {
    _setLoading(true);
    try {
      _posts = await _postService.loadAllPosts(userId);
      await _fetchUsernamesForPosts();
      notifyListeners();
    } catch (e) {
      print('Error loading posts: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserPosts(String userId) async {
    _setLoading(true);
    try {
      _posts = await _postService.getUserPosts(userId);
      await _fetchUsernamesForPosts();
      notifyListeners();
    } catch (e) {
      print('Error loading user posts: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createPost(Post post) async {
    _setLoading(true);
    try {
      await _postService.createPost(post);
      _posts.insert(0, post);

      final username = await _postService.fetchUsernameById(post.userId);
      _usernames[post.userId] = username;
      notifyListeners();
    } catch (e) {
      print('Error creating post: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePost(Post post) async {
    _setLoading(true);
    try {
      await _postService.updatePost(post);
      int index = _posts.indexWhere((p) => p.postId == post.postId);
      if (index != -1) {
        _posts[index] = post;

        final username = await _postService.fetchUsernameById(post.userId);
        _usernames[post.userId] = username;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating post: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePost(String userId, String postId) async {
    _setLoading(true);
    try {
      await _postService.deletePost(userId, postId);
      _posts.removeWhere((p) => p.postId == postId);
      notifyListeners();
    } catch (e) {
      print('Error deleting post: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fetchUsernamesForPosts() async {
    final userIds = _posts.map((post) => post.userId).toSet();
    for (String userId in userIds) {
      if (!_usernames.containsKey(userId)) {
        final username = await _postService.fetchUsernameById(userId);
        _usernames[userId] = username;
      }
    }
    notifyListeners();
  }

  String getUsername(String userId) {
    return _usernames[userId] ?? 'Unknown';
  }

  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }
}
