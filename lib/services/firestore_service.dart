import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser({
    required String uid,
    required String username,
    required String email,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'username': username,
      'email': email,
      'wishlist': [],
      'played': [],
      'favorites': [],
    });
  }

  Future<DocumentSnapshot> getUser(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  Stream<QuerySnapshot> getAllUsers() {
    return _firestore.collection('users').snapshots();
  }

  Map<String, dynamic> _gameToMap(
    int id,
    String name,
    String image,
    double rating,
    String releasedDate,
    List<String> platforms,
  ) {
    return {
      'id': id,
      'name': name,
      'image': image,
      'rating': rating,
      'releasedDate': releasedDate,
      'platforms': platforms,
    };
  }

  // ─── HELPER: Tambah game ke suatu list jika belum ada (cek by id) ───
  Future<void> _addToList({
    required String uid,
    required String listName,
    required Map<String, dynamic> gameMap,
  }) async {
    final docRef = _firestore.collection('users').doc(uid);
    final snapshot = await docRef.get();
    final data = snapshot.data() as Map<String, dynamic>? ?? {};
    final currentList = List<Map<String, dynamic>>.from(
      (data[listName] ?? []).map((e) => Map<String, dynamic>.from(e)),
    );

    // Cegah duplikat berdasarkan ID
    final alreadyExists = currentList.any((g) => g['id'] == gameMap['id']);
    if (alreadyExists) return;

    currentList.add(gameMap);
    await docRef.update({listName: currentList});
  }

  // ─── HELPER: Hapus game dari suatu list (cek by id) ───
  Future<void> _removeFromList({
    required String uid,
    required String listName,
    required int gameId,
  }) async {
    final docRef = _firestore.collection('users').doc(uid);
    final snapshot = await docRef.get();
    final data = snapshot.data() as Map<String, dynamic>? ?? {};
    final currentList = List<Map<String, dynamic>>.from(
      (data[listName] ?? []).map((e) => Map<String, dynamic>.from(e)),
    );

    // Filter hapus berdasarkan id saja — tidak peduli field lain
    final updatedList = currentList.where((g) => g['id'] != gameId).toList();
    await docRef.update({listName: updatedList});
  }

  // ─── WISHLIST ───
  Future<void> addWishlist({
    required String uid,
    required int gameId,
    required String gameName,
    required String gameImage,
    required double gameRating,
    required String gameReleasedDate,
    required List<String> gamePlatforms,
  }) async {
    await _addToList(
      uid: uid,
      listName: 'wishlist',
      gameMap: _gameToMap(gameId, gameName, gameImage, gameRating, gameReleasedDate, gamePlatforms),
    );
  }

  Future<void> removeWishlist({
    required String uid,
    required int gameId,
    required String gameName,
    required String gameImage,
    required double gameRating,
    required String gameReleasedDate,
    required List<String> gamePlatforms,
  }) async {
    await _removeFromList(uid: uid, listName: 'wishlist', gameId: gameId);
  }

  // ─── PLAYED ───
  Future<void> addPlayed({
    required String uid,
    required int gameId,
    required String gameName,
    required String gameImage,
    required double gameRating,
    required String gameReleasedDate,
    required List<String> gamePlatforms,
  }) async {
    await _addToList(
      uid: uid,
      listName: 'played',
      gameMap: _gameToMap(gameId, gameName, gameImage, gameRating, gameReleasedDate, gamePlatforms),
    );
  }

  Future<void> removePlayed({
    required String uid,
    required int gameId,
    required String gameName,
    required String gameImage,
    required double gameRating,
    required String gameReleasedDate,
    required List<String> gamePlatforms,
  }) async {
    await _removeFromList(uid: uid, listName: 'played', gameId: gameId);
  }

  // ─── FAVORITES ───
  Future<void> addFavorite({
    required String uid,
    required int gameId,
    required String gameName,
    required String gameImage,
    required double gameRating,
    required String gameReleasedDate,
    required List<String> gamePlatforms,
  }) async {
    await _addToList(
      uid: uid,
      listName: 'favorites',
      gameMap: _gameToMap(gameId, gameName, gameImage, gameRating, gameReleasedDate, gamePlatforms),
    );
  }

  Future<void> removeFavorite({
    required String uid,
    required int gameId,
    required String gameName,
    required String gameImage,
    required double gameRating,
    required String gameReleasedDate,
    required List<String> gamePlatforms,
  }) async {
    await _removeFromList(uid: uid, listName: 'favorites', gameId: gameId);
  }
}