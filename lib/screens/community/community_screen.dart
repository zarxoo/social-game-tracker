import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_game_tracker/core/theme/app_theme.dart';

import '../../services/firestore_service.dart';
import 'user_profile_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() =>
      _CommunityScreenState();
}

class _CommunityScreenState
    extends State<CommunityScreen> {

  String searchText = '';

  @override
  Widget build(BuildContext context) {

    final currentUser =
        FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // Top App Bar equivalent area
          Padding(
            padding:
                const EdgeInsets.all(16.0),

            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.all(8),

                  decoration: BoxDecoration(
                    color:
                        AppTheme.primaryColor,

                    borderRadius:
                        BorderRadius.circular(
                            8),
                  ),

                  child: const Icon(
                    Icons.people,
                    color: Colors.white,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                const Text(
                  'Community',

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16.0,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(
                    'Komunitas\nGamer',
                    style:
                        AppTheme.heading1,
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Connect with fellow gamers',
                    style:
                        AppTheme.subtitleText,
                  ),

                  const SizedBox(height: 24),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color:
                          AppTheme.cardColor,

                      borderRadius:
                          BorderRadius.circular(
                              12),
                    ),

                    child: TextField(
                      style:
                          AppTheme.bodyText,

                      onChanged: (value) {

                        setState(() {
                          searchText =
                              value.toLowerCase();
                        });
                      },

                      decoration:
                          const InputDecoration(
                        hintText:
                            'Search gamers...',

                        hintStyle:
                            AppTheme
                                .subtitleText,

                        prefixIcon: Icon(
                          Icons.search,
                          color: AppTheme
                              .textSecondaryColor,
                        ),

                        border:
                            InputBorder.none,

                        enabledBorder:
                            InputBorder.none,

                        focusedBorder:
                            InputBorder.none,

                        contentPadding:
                            EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Users List Header
                  Row(
                    children: [
                      const Text(
                        'All Users',
                        style:
                            AppTheme.heading2,
                      ),

                      const Spacer(),

                      TextButton(
                        onPressed: () {},

                        style:
                            TextButton.styleFrom(
                          foregroundColor:
                              AppTheme
                                  .textSecondaryColor,

                          textStyle:
                              const TextStyle(
                            fontSize: 12,
                          ),
                        ),

                        child:
                            const Text('Filter'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  /// FIREBASE USERS
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirestoreService()
                            .getAllUsers(),

                    builder:
                        (context, snapshot) {

                      if (snapshot
                              .connectionState ==
                          ConnectionState
                              .waiting) {

                        return const Center(
                          child:
                              CircularProgressIndicator(),
                        );
                      }

                      if (!snapshot.hasData ||
                          snapshot.data!.docs
                              .isEmpty) {

                        return const Center(
                          child: Text(
                            'Belum ada user',

                            style: TextStyle(
                              color:
                                  Colors.white,
                            ),
                          ),
                        );
                      }

                      final allUsers =
                          snapshot.data!.docs;

                      /// SEARCH FILTER + HIDE CURRENT USER
                      final users =
                          allUsers.where((user) {

                        final data =
                            user.data()
                                as Map<String,
                                    dynamic>;

                        final username =
                            data['username']
                                .toString()
                                .toLowerCase();

                        final uid =
                            data['uid'];

                        /// hide akun sendiri
                        final isNotCurrentUser =
                            uid !=
                                currentUser?.uid;

                        /// search username
                        final matchesSearch =
                            username.contains(
                                searchText);

                        return isNotCurrentUser &&
                            matchesSearch;

                      }).toList();

                      if (users.isEmpty) {

                        return const Center(
                          child: Padding(
                            padding:
                                EdgeInsets.all(
                                    20),

                            child: Text(
                              'User tidak ditemukan',

                              style: TextStyle(
                                color:
                                    Colors.white,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,

                        physics:
                            const NeverScrollableScrollPhysics(),

                        itemCount:
                            users.length,

                        itemBuilder:
                            (context, index) {

                          final user =
                              users[index];

                          final data =
                              user.data()
                                  as Map<String,
                                      dynamic>;

                          final username =
                              data['username'] ??
                                  '';

                          final email =
                              data['email'] ??
                                  '';

                          return Container(
                            margin:
                                const EdgeInsets
                                    .only(
                              bottom: 12,
                            ),

                            decoration:
                                BoxDecoration(
                              color: AppTheme
                                  .cardColor,

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          12),
                            ),

                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),

                              leading: Stack(
                                children: [

                                  CircleAvatar(
                                    backgroundColor:
                                        AppTheme
                                            .primaryColor,

                                    child: Text(
                                      username
                                              .isNotEmpty
                                          ? username[0]
                                              .toUpperCase()
                                          : '?',

                                      style:
                                          const TextStyle(
                                        color: Colors
                                            .white,

                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    right: 0,
                                    bottom: 0,

                                    child:
                                        Container(
                                      width: 12,
                                      height: 12,

                                      decoration:
                                          BoxDecoration(
                                        color: AppTheme
                                            .successColor,

                                        shape: BoxShape
                                            .circle,

                                        border:
                                            Border.all(
                                          color: AppTheme
                                              .cardColor,

                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              title: Text(
                                username,

                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,

                                  color:
                                      Colors.white,
                                ),
                              ),

                              subtitle: Text(
                                email,

                                style: AppTheme
                                    .subtitleText
                                    .copyWith(
                                  fontSize: 12,
                                ),
                              ),

                              trailing: Container(
                                decoration:
                                    BoxDecoration(
                                  color: AppTheme
                                      .primaryColor,

                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              8),
                                ),

                                child: IconButton(
                                  icon: const Icon(
                                    Icons
                                        .remove_red_eye,

                                    color:
                                        Colors.white,

                                    size: 20,
                                  ),

                                  onPressed: () {

                                    Navigator.push(
                                      context,

                                      MaterialPageRoute(
                                        builder: (_) =>
                                            UserProfileScreen(
                                          userData:
                                              data,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}