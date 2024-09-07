// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/friend_service.dart';
import '../widgets/retro_button.dart';
import 'feed_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final FriendService _friendRequestService = FriendService();
  int _selectedIndex = 1;

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
              const Text(
                'Friend Requests',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: _buildFriendRequestsSection(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Friends',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: _buildFriendsSection(),
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

  Widget _buildFriendRequestsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('friend_requests')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final friendRequests = snapshot.data!.docs;

        if (friendRequests.isEmpty) {
          return const Center(
            child: Text(
              'No friend requests',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          );
        }

        return FutureBuilder<List<Widget>>(
          future: Future.wait(friendRequests.map((request) async {
            final requesterId = request['senderId'];
            final requesterUsername =
                await _friendRequestService.getUsernameById(requesterId);
            final requestId = request.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.5),
              child: Container(
                margin: const EdgeInsets.only(top: 16.0),
                child: ListTile(
                  title: Text(
                    requesterUsername,
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  trailing: SizedBox(
                    width: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        RetroButton(
                          text: '✓',
                          onPressed: () =>
                              _acceptFriendRequest(requesterId, requestId),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          textStyle: const TextStyle(
                              fontFamily: 'PressStart2P',
                              fontSize: 20,
                              color: Colors.black),
                        ),
                        const SizedBox(width: 8),
                        RetroButton(
                          text: '✗',
                          onPressed: () => _declineFriendRequest(requestId),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          textStyle: const TextStyle(
                              fontFamily: 'PressStart2P',
                              fontSize: 20,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              children: snapshot.data!,
            );
          },
        );
      },
    );
  }

  Widget _buildFriendsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('friends')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final friends = snapshot.data!.docs;

        if (friends.isEmpty) {
          return const Center(
            child: Text(
              'No friends',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          );
        }

        return FutureBuilder<List<Widget>>(
          future: Future.wait(friends.map((friend) async {
            final friendId = friend['friendId'];
            final friendUsername =
                await _friendRequestService.getUsernameById(friendId);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.5),
              child: Container(
                margin: const EdgeInsets.only(top: 16.0),
                child: ListTile(
                  title: Text(
                    friendUsername,
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  trailing: SizedBox(
                    width: 130,
                    child: RetroButton(
                      text: 'Remove Friend',
                      onPressed: () => _removeFriend(friendId),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      textStyle: const TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              children: snapshot.data!,
            );
          },
        );
      },
    );
  }

  void _acceptFriendRequest(String requesterId, String requestId) async {
    await _friendRequestService.acceptFriendRequest(currentUserId, requestId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friend request accepted.')),
    );
  }

  void _declineFriendRequest(String requestId) async {
    await _friendRequestService.rejectFriendRequest(currentUserId, requestId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friend request declined.')),
    );
  }

  void _removeFriend(String friendId) async {
    await _friendRequestService.removeFriend(currentUserId, friendId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friend removed.')),
    );
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
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ProfileScreen(userId: currentUserId)));
        break;
      case 3:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SearchScreen()));
        break;
    }
  }
}
