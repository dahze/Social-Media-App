import 'package:flutter/material.dart';
import '../models/friend_request.dart';
import '../services/friend_service.dart';

class FriendRequestProvider with ChangeNotifier {
  final FriendService _friendRequestService = FriendService();
  List<FriendRequest> _friendRequests = [];

  List<FriendRequest> get friendRequests => _friendRequests;

  Future<void> loadFriendRequests(String userId) async {
    _friendRequests = await _friendRequestService.getFriendRequests(userId);
    notifyListeners();
  }

  Future<void> sendFriendRequest(FriendRequest request) async {
    await _friendRequestService.sendFriendRequest(request);
    _friendRequests.add(request);
    notifyListeners();
  }

  Future<void> acceptFriendRequest(String receiverId, String requestId) async {
    await _friendRequestService.acceptFriendRequest(receiverId, requestId);
    _friendRequests.removeWhere(
        (req) => req.receiverId == receiverId && req.senderId == requestId);
    notifyListeners();
  }

  Future<void> rejectFriendRequest(String receiverId, String requestId) async {
    await _friendRequestService.rejectFriendRequest(receiverId, requestId);
    _friendRequests.removeWhere(
        (req) => req.receiverId == receiverId && req.senderId == requestId);
    notifyListeners();
  }
}
