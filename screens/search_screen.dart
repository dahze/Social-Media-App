// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/retro_button.dart';
import 'feed_screen.dart';
import 'profile_screen.dart';
import 'friends_screen.dart';
import '../models/friend_request.dart';
import '../services/friend_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final FriendService _friendRequestService = FriendService();
  int _selectedIndex = 3;

  String _searchQuery = '';

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
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search users',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
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
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                ),
                style: const TextStyle(
                  color: Colors.black,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _buildSearchResults(),
              ),
            ],
          ),
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

  Widget _buildSearchResults() {
    Query query = FirebaseFirestore.instance.collection('users');

    if (_searchQuery.isNotEmpty) {
      query = query
          .where('username', isGreaterThanOrEqualTo: _searchQuery)
          .where('username', isLessThan: '${_searchQuery}z');
    }

    query = query.where(FieldPath.documentId, isNotEqualTo: currentUserId);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final searchResults = snapshot.data!.docs;

        if (_searchQuery.isEmpty || searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _searchQuery.isEmpty
                      ? 'Enter a username to search'
                      : 'No users found',
                  style: const TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            final user = searchResults[index];
            final username = user['username'];
            final userId = user.id;

            return FutureBuilder(
              future: _getUserStatus(userId),
              builder: (context,
                  AsyncSnapshot<Map<String, dynamic>> statusSnapshot) {
                if (!statusSnapshot.hasData) {
                  return ListTile(
                    title: Text(username,
                        style: const TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 14,
                            color: Colors.black)),
                    trailing: const CircularProgressIndicator(),
                  );
                }

                final status = statusSnapshot.data!;
                // ignore: unused_local_variable, prefer_const_declarations
                final requestId = '';
                return ListTile(
                  title: Text(username,
                      style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 14,
                          color: Colors.black)),
                  trailing: SizedBox(
                    width: status['requestReceived'] ? 108 : 150,
                    child: status['requestReceived']
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 50,
                                    child: RetroButton(
                                      text: '✓',
                                      onPressed: () {
                                        _acceptFriendRequest(
                                            userId, status['requestId']!);
                                      },
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      textStyle: const TextStyle(
                                          fontFamily: 'PressStart2P',
                                          fontSize: 20,
                                          color: Colors.black),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 50,
                                    child: RetroButton(
                                      text: '✗',
                                      onPressed: () {
                                        _rejectFriendRequest(
                                            status['requestId']!);
                                      },
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      textStyle: const TextStyle(
                                          fontFamily: 'PressStart2P',
                                          fontSize: 20,
                                          color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (status['requestSent'])
                                RetroButton(
                                  text: 'Cancel\nRequest',
                                  onPressed: () {
                                    _cancelFriendRequest(userId);
                                  },
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  textStyle: const TextStyle(
                                      fontFamily: 'PressStart2P',
                                      fontSize: 13,
                                      color: Colors.black),
                                ),
                              if (status['friend'])
                                RetroButton(
                                  text: 'Remove\nFriend',
                                  onPressed: () {
                                    _removeFriend(userId);
                                  },
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  textStyle: const TextStyle(
                                      fontFamily: 'PressStart2P',
                                      fontSize: 13,
                                      color: Colors.black),
                                ),
                              if (!status['requestReceived'] &&
                                  !status['requestSent'] &&
                                  !status['friend'])
                                RetroButton(
                                  text: 'Add Friend',
                                  onPressed: () {
                                    _sendFriendRequest(userId, username);
                                  },
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  textStyle: const TextStyle(
                                      fontFamily: 'PressStart2P',
                                      fontSize: 13,
                                      color: Colors.black),
                                ),
                            ],
                          ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getUserStatus(String userId) async {
    final receivedRequestSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('friend_requests')
        .where('senderId', isEqualTo: userId)
        .get();

    final sentRequestSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('friend_requests')
        .where('senderId', isEqualTo: currentUserId)
        .get();

    final friendsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(userId)
        .get();

    String? requestId;
    if (receivedRequestSnapshot.docs.isNotEmpty) {
      requestId = receivedRequestSnapshot.docs.first.id;
    }

    return {
      'requestReceived': receivedRequestSnapshot.docs.isNotEmpty,
      'requestSent': sentRequestSnapshot.docs.isNotEmpty,
      'friend': friendsSnapshot.exists,
      'requestId': requestId,
    };
  }

  void _sendFriendRequest(String userId, String receiverUsername) async {
    final FriendRequest request = FriendRequest(
      senderId: currentUserId,
      receiverId: userId,
      timestamp: DateTime.now(),
    );

    await _friendRequestService.sendFriendRequest(request);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Friend request sent to $receiverUsername')),
    );

    setState(() {});
  }

  void _cancelFriendRequest(String userId) async {
    await _friendRequestService.cancelFriendRequest(currentUserId, userId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friend request cancelled')),
    );

    setState(() {});
  }

  void _removeFriend(String userId) async {
    await _friendRequestService.removeFriend(currentUserId, userId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friend removed')),
    );

    setState(() {});
  }

  void _acceptFriendRequest(String requesterId, String requestId) async {
    await _friendRequestService.acceptFriendRequest(currentUserId, requestId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friend request accepted')),
    );

    setState(() {});
  }

  void _rejectFriendRequest(String requestId) async {
    await _friendRequestService.rejectFriendRequest(currentUserId, requestId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friend request rejected')),
    );

    setState(() {});
  }

  Widget _buildBottomNavItem(IconData icon, int index) {
    return IconButton(
      icon: Icon(icon),
      color: _selectedIndex == index ? Colors.black : Colors.white,
      onPressed: () => _onNavItemTapped(index),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FeedScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FriendsScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileScreen(userId: currentUserId)),
        );
        break;
      case 3:
        break;
    }
  }
}
