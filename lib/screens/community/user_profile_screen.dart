import 'package:flutter/material.dart';

class UserProfileScreen
    extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserProfileScreen({
    super.key,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    final wishlist =
        userData['wishlist'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Profile',
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Center(
              child: CircleAvatar(
                radius: 45,

                child: Text(
                  userData['username'][0]
                      .toUpperCase(),

                  style: const TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: Text(
                userData['username'],

                style: const TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                userData['email'],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Wishlist Games',

              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: wishlist.isEmpty
                  ? const Center(
                      child: Text(
                        'Wishlist kosong',
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
                            leading:
                                Image.network(
                              game['image'],
                              width: 50,
                              fit: BoxFit.cover,
                            ),

                            title: Text(
                              game['name'],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}