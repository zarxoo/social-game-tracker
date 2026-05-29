import 'package:cached_network_image/cached_network_image.dart';
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

            /// PROFILE
            Center(
              child: CircleAvatar(

                radius: 45,

                child: Text(
                  userData['username'][0]
                      .toUpperCase(),

                  style:
                      const TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Center(
              child: Text(
                userData['username'],

                style:
                    const TextStyle(
                  fontSize: 24,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Center(
              child: Text(
                userData['email'],
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            /// TITLE
            const Text(
              'Wishlist Games',

              style: TextStyle(
                fontSize: 22,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            /// WISHLIST
            Expanded(

              child:
                  wishlist.isEmpty

                      ? const Center(
                          child: Text(
                            'Wishlist kosong',
                          ),
                        )

                      : ListView.builder(

                          /// PERFORMANCE
                          cacheExtent: 200,

                          addAutomaticKeepAlives:
                              false,

                          addRepaintBoundaries:
                              true,

                          itemCount:
                              wishlist.length,

                          itemBuilder:
                              (
                                context,
                                index,
                              ) {

                            final game =
                                wishlist[index];

                            return RepaintBoundary(

                              child: Card(

                                child: ListTile(

                                  leading:
                                      ClipRRect(

                                    borderRadius:
                                        BorderRadius.circular(
                                      8,
                                    ),

                                    child:
                                        CachedNetworkImage(

                                      imageUrl:
                                          game['image'],

                                      width: 50,

                                      height: 50,

                                      fit:
                                          BoxFit.cover,

                                      memCacheWidth:
                                          200,

                                      memCacheHeight:
                                          200,

                                      fadeInDuration:
                                          const Duration(
                                        milliseconds:
                                            150,
                                      ),

                                      placeholder:
                                          (
                                            context,
                                            url,
                                          ) =>
                                              Container(

                                        width: 50,
                                        height: 50,

                                        color:
                                            Colors.grey[
                                                800],

                                        child:
                                            const Center(
                                          child:
                                              SizedBox(

                                            width: 18,
                                            height: 18,

                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth:
                                                  2,
                                            ),
                                          ),
                                        ),
                                      ),

                                      errorWidget:
                                          (
                                            context,
                                            url,
                                            error,
                                          ) =>
                                              Container(

                                        width: 50,
                                        height: 50,

                                        color:
                                            Colors.grey[
                                                800],

                                        child:
                                            const Icon(
                                          Icons
                                              .broken_image,

                                          color:
                                              Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),

                                  title: Text(
                                    game['name'],
                                  ),
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