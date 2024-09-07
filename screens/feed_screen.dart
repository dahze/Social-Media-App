// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import 'package:flutter/services.dart';
import '../widgets/post_card.dart';
import '../screens/profile_screen.dart';
import '../screens/friends_screen.dart';
import '../screens/search_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';
import '../widgets/retro_button.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _showAllPosts = true;
  bool _hasPosted = false;
  final TextEditingController _postController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPosts();
    });
  }

  void _loadPosts() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      if (_showAllPosts) {
        await Provider.of<PostProvider>(context, listen: false)
            .loadAllPosts(userId);
      } else {
        await Provider.of<PostProvider>(context, listen: false)
            .loadUserPosts(userId);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FriendsScreen(),
          ),
        );
        break;
      case 2:
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(userId: userId),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in')),
          );
        }
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SearchScreen(),
          ),
        );
        break;
    }
  }

  void _togglePostView(bool showAll) {
    setState(() {
      _isLoading = true;
      _showAllPosts = showAll;
    });
    _loadPosts();
  }

  void _createPost() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final content = _postController.text.trim();

    if (userId != null && content.isNotEmpty) {
      final newPost = Post(
        postId: DateTime.now().toString(),
        userId: userId,
        content: content,
        timestamp: DateTime.now(),
      );

      try {
        await Provider.of<PostProvider>(context, listen: false)
            .createPost(newPost);
        _postController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Posted!')),
        );
        setState(() {
          _hasPosted = false;
        });
      } catch (e) {
        print('Error creating post: $e');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error creating post')),
        );
      }
    }
  }

  void _editPost(String postId) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final postToEdit =
        postProvider.posts.firstWhere((post) => post.postId == postId);
    final TextEditingController editController =
        TextEditingController(text: postToEdit.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xffffd888),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    final updatedContent = editController.text.trim();
                    if (updatedContent.isNotEmpty) {
                      postToEdit.content = updatedContent;
                      postProvider.updatePost(postToEdit);
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Post cannot be empty!',
                            style: TextStyle(fontFamily: 'PressStart2P'),
                          ),
                        ),
                      );
                    }
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
                  onPressed: () => Navigator.of(context).pop(),
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

  void _showConfirmDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xffffd888),
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

  void _deletePost(String postId) {
    _showConfirmDialog(
      title: 'Delete Post',
      content: 'Are you sure you want to delete this post?',
      onConfirm: () async {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          try {
            await Provider.of<PostProvider>(context, listen: false)
                .deletePost(userId, postId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post deleted')),
            );
          } catch (e) {
            print('Error deleting post: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error deleting post')),
            );
          }
        }
      },
    );
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
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => _togglePostView(true),
                    child: Text(
                      'All Posts',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        color: _showAllPosts ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _togglePostView(false),
                    child: Text(
                      'My Posts',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        color: !_showAllPosts ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _postController,
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: 'PressStart2P',
                        fontSize: 14.0,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Share your thoughts...',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontFamily: 'PressStart2P',
                          fontSize: 14.0,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      maxLines: 3,
                      textAlignVertical: TextAlignVertical.center,
                      onChanged: (text) {
                        setState(() {
                          _hasPosted = false;
                        });
                      },
                      onTap: () {
                        setState(() {});
                      },
                      onEditingComplete: () {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 8.0),
                    if (!_hasPosted && _postController.text.isNotEmpty)
                      RetroButton(
                        text: 'Post',
                        onPressed: _createPost,
                        textStyle: const TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Consumer<PostProvider>(
                        builder: (context, postProvider, child) {
                          if (postProvider.posts.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    _showAllPosts
                                        ? 'No posts available.'
                                        : 'You have not created any posts yet.',
                                    style: const TextStyle(
                                      fontFamily: 'PressStart2P',
                                      fontSize: 14.0,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: postProvider.posts.length,
                            itemBuilder: (context, index) {
                              final post = postProvider.posts[index];
                              return PostCard(
                                post: post,
                                currentUserId:
                                    FirebaseAuth.instance.currentUser?.uid ??
                                        '',
                                onEdit: _editPost,
                                onDelete: _deletePost,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
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
        ));
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
