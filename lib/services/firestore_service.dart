import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> createUser({
    required String uid,
    required String username,
    required String email,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set({
      'uid': uid,
      'username': username,
      'email': email,
      'wishlist': [],
    });
  }

  Future<DocumentSnapshot> getUser(
    String uid,
  ) async {
    return await _firestore
        .collection('users')
        .doc(uid)
        .get();
  }

  Future<void> addWishlist({
    required String uid,
    required int gameId,
    required String gameName,
    required String gameImage,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({
      'wishlist':
          FieldValue.arrayUnion([
        {
          'id': gameId,
          'name': gameName,
          'image': gameImage,
        }
      ]),
    });
  }

  Future<void> removeWishlist({
    required String uid,
    required int gameId,
    required String gameName,
    required String gameImage,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({
      'wishlist':
          FieldValue.arrayRemove([
        {
          'id': gameId,
          'name': gameName,
          'image': gameImage,
        }
      ]),
    });
  }
}