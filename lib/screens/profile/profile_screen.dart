import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

import '../main_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final uid =
        FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
        ),

        actions: [
          IconButton(
            onPressed: () async {
              // LOGOUT
              await AuthService().logout();

              // KEMBALI KE MAIN SCREEN
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const MainScreen(),
                  ),
                  (route) => false,
                );
              }
            },

            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),

        builder: (context, snapshot) {
          // LOADING
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          // USER TIDAK DITEMUKAN
          if (!snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'User tidak ditemukan',
              ),
            );
          }

          final data = snapshot.data!.data()
              as Map<String, dynamic>;

          final wishlist =
              data['wishlist'] ?? [];

          return Padding(
            padding:
                const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // FOTO PROFILE
                Center(
                  child: CircleAvatar(
                    radius: 40,

                    child: Text(
                      data['username'][0]
                          .toUpperCase(),

                      style:
                          const TextStyle(
                        fontSize: 32,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // USERNAME
                Center(
                  child: Text(
                    data['username'],

                    style:
                        const TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // EMAIL
                Center(
                  child: Text(
                    data['email'],
                  ),
                ),

                const SizedBox(height: 32),

                // JUDUL WISHLIST
                const Text(
                  'Wishlist',

                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // LIST WISHLIST
                Expanded(
                  child: wishlist.isEmpty
                      ? const Center(
                          child: Text(
                            'Wishlist masih kosong',
                          ),
                        )
                      : ListView.builder(
                          itemCount:
                              wishlist.length,

                          itemBuilder:
                              (context, index) {
                            final game =
                                wishlist[index];

                            return Card(
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.all(
                                  12,
                                ),

                                leading:
                                    ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(
                                    8,
                                  ),

                                  child:
                                      Image.network(
                                    game['image'],

                                    width: 80,

                                    height: 80,

                                    fit:
                                        BoxFit.cover,
                                  ),
                                ),

                                title: Text(
                                  game['name'],
                                ),

                                trailing:
                                    IconButton(
                                  onPressed:
                                      () async {
                                    await FirestoreService()
                                        .removeWishlist(
                                      uid: uid,

                                      gameId:
                                          game['id'],

                                      gameName:
                                          game['name'],

                                      gameImage:
                                          game['image'],
                                    );
                                  },

                                  icon:
                                      const Icon(
                                    Icons.delete,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}