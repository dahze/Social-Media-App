import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friend_request.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendFriendRequest(FriendRequest request) async {
    await _firestore
        .collection('users')
        .doc(request.receiverId)
        .collection('friend_requests')
        .add(request.toMap());

    await _firestore
        .collection('users')
        .doc(request.senderId)
        .collection('sent_friend_requests')
        .add(request.toMap());
  }

  Future<void> acceptFriendRequest(String receiverId, String requestId) async {
    DocumentSnapshot requestDoc = await _firestore
        .collection('users')
        .doc(receiverId)
        .collection('friend_requests')
        .doc(requestId)
        .get();
    FriendRequest request =
        FriendRequest.fromMap(requestDoc.data() as Map<String, dynamic>);

    await _firestore
        .collection('users')
        .doc(receiverId)
        .collection('friend_requests')
        .doc(requestId)
        .delete();

    QuerySnapshot sentRequestSnapshot = await _firestore
        .collection('users')
        .doc(request.senderId)
        .collection('sent_friend_requests')
        .where('receiverId', isEqualTo: receiverId)
        .get();
    for (DocumentSnapshot doc in sentRequestSnapshot.docs) {
      await doc.reference.delete();
    }

    await _firestore
        .collection('users')
        .doc(receiverId)
        .collection('friends')
        .doc(request.senderId)
        .set({
      'friendId': request.senderId,
      'since': FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection('users')
        .doc(request.senderId)
        .collection('friends')
        .doc(receiverId)
        .set({
      'friendId': receiverId,
      'since': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejectFriendRequest(String receiverId, String requestId) async {
    DocumentSnapshot requestDoc = await _firestore
        .collection('users')
        .doc(receiverId)
        .collection('friend_requests')
        .doc(requestId)
        .get();
    FriendRequest request =
        FriendRequest.fromMap(requestDoc.data() as Map<String, dynamic>);

    await _firestore
        .collection('users')
        .doc(receiverId)
        .collection('friend_requests')
        .doc(requestId)
        .delete();

    QuerySnapshot sentRequestSnapshot = await _firestore
        .collection('users')
        .doc(request.senderId)
        .collection('sent_friend_requests')
        .where('receiverId', isEqualTo: receiverId)
        .get();
    for (DocumentSnapshot doc in sentRequestSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> cancelFriendRequest(String senderId, String receiverId) async {
    QuerySnapshot receiverRequestSnapshot = await _firestore
        .collection('users')
        .doc(receiverId)
        .collection('friend_requests')
        .where('senderId', isEqualTo: senderId)
        .get();
    for (DocumentSnapshot doc in receiverRequestSnapshot.docs) {
      await doc.reference.delete();
    }

    QuerySnapshot sentRequestSnapshot = await _firestore
        .collection('users')
        .doc(senderId)
        .collection('sent_friend_requests')
        .where('receiverId', isEqualTo: receiverId)
        .get();
    for (DocumentSnapshot doc in sentRequestSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> removeFriend(String currentUserId, String friendId) async {
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(friendId)
        .delete();

    await _firestore
        .collection('users')
        .doc(friendId)
        .collection('friends')
        .doc(currentUserId)
        .delete();
  }

  Future<List<FriendRequest>> getFriendRequests(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('friend_requests')
        .get();
    return snapshot.docs
        .map((doc) => FriendRequest.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<String> getUsernameById(String userId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    return userDoc['username'] ?? 'Unknown';
  }

  Future<void> cleanupUserRequests(String userId) async {
    QuerySnapshot sentRequestsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('sent_friend_requests')
        .get();
    for (DocumentSnapshot doc in sentRequestsSnapshot.docs) {
      FriendRequest request =
          FriendRequest.fromMap(doc.data() as Map<String, dynamic>);

      await _firestore
          .collection('users')
          .doc(request.receiverId)
          .collection('friend_requests')
          .where('senderId', isEqualTo: userId)
          .get()
          .then((snapshot) =>
              Future.wait(snapshot.docs.map((doc) => doc.reference.delete())));

      await doc.reference.delete();
    }

    QuerySnapshot receivedRequestsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('friend_requests')
        .get();
    for (DocumentSnapshot doc in receivedRequestsSnapshot.docs) {
      FriendRequest request =
          FriendRequest.fromMap(doc.data() as Map<String, dynamic>);

      await doc.reference.delete();

      await _firestore
          .collection('users')
          .doc(request.senderId)
          .collection('sent_friend_requests')
          .where('receiverId', isEqualTo: userId)
          .get()
          .then((snapshot) =>
              Future.wait(snapshot.docs.map((doc) => doc.reference.delete())));
    }

    QuerySnapshot friendsSnapshot = await _firestore
        .collection('users')
        .where('friends.$userId', isNotEqualTo: null)
        .get();
    for (DocumentSnapshot userDoc in friendsSnapshot.docs) {
      String currentUserId = userDoc.id;
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('friends')
          .doc(userId)
          .delete();
    }

    QuerySnapshot deletedUserFriendsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .get();
    for (DocumentSnapshot friendDoc in deletedUserFriendsSnapshot.docs) {
      String friendId = friendDoc.id;
      await _firestore
          .collection('users')
          .doc(friendId)
          .collection('friends')
          .doc(userId)
          .delete();
    }
  }
}
