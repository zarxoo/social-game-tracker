import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:social_game_tracker/core/theme/app_theme.dart';

class GameCard
    extends StatelessWidget {

  final String title;
  final String releaseDate;
  final double rating;
  final String platforms;
  final String imageUrl;
  final VoidCallback?
      onDetailPressed;

  const GameCard({
    super.key,
    required this.title,
    required this.releaseDate,
    required this.rating,
    required this.platforms,
    required this.imageUrl,
    this.onDetailPressed,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return Container(

      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),

      decoration: BoxDecoration(
        color:
            AppTheme.cardColor,

        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // IMAGE
              ClipRRect(

                borderRadius:
                    const BorderRadius.only(
                  topLeft:
                      Radius.circular(
                    12,
                  ),

                  bottomRight:
                      Radius.circular(
                    12,
                  ),
                ),

                child: SizedBox(

                  width: 100,
                  height: 100,

                  child:
                      imageUrl.isNotEmpty

                          ? CachedNetworkImage(

                              imageUrl:
                                  imageUrl,

                              fit:
                                  BoxFit.cover,

                              memCacheWidth:
                                  300,

                              memCacheHeight:
                                  300,

                              fadeInDuration:
                                  const Duration(
                                milliseconds:
                                    200,
                              ),

                              placeholder:
                                  (
                                    context,
                                    url,
                                  ) =>
                                      Container(
                                color:
                                    Colors.grey[
                                        800],

                                child:
                                    const Center(
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                  ),
                                ),
                              ),

                              errorWidget:
                                  (
                                    context,
                                    url,
                                    error,
                                  ) {
                                return Container(
                                  color:
                                      Colors.grey[
                                          800],

                                  child:
                                      const Icon(
                                    Icons
                                        .image_not_supported,

                                    color:
                                        Colors.grey,
                                  ),
                                );
                              },
                            )

                          : Container(

                              color:
                                  Colors.grey[
                                      800],

                              child:
                                  const Icon(
                                Icons
                                    .videogame_asset,

                                color:
                                    Colors.grey,

                                size: 40,
                              ),
                            ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              // DETAIL
              Expanded(

                child: Padding(

                  padding:
                      const EdgeInsets.only(
                    top: 12,
                    right: 12,
                  ),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      Text(

                        title,

                        style: AppTheme
                            .heading2
                            .copyWith(
                          fontSize: 14,
                        ),

                        maxLines: 2,

                        overflow:
                            TextOverflow
                                .ellipsis,
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(

                        'Released: $releaseDate',

                        style: AppTheme
                            .subtitleText
                            .copyWith(
                          fontSize: 10,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Row(
                        children: [

                          const Icon(
                            Icons.star,

                            color:
                                AppTheme
                                    .warningColor,

                            size: 14,
                          ),

                          const SizedBox(
                            width: 4,
                          ),

                          Text(

                            'Rating: $rating/10',

                            style: AppTheme
                                .subtitleText
                                .copyWith(
                              color:
                                  Colors
                                      .white,

                              fontSize:
                                  11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // BOTTOM
          Padding(

            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),

            child: Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                Expanded(
                  child: Text(

                    platforms,

                    style: AppTheme
                        .subtitleText
                        .copyWith(
                      fontSize: 10,
                    ),

                    maxLines: 1,

                    overflow:
                        TextOverflow
                            .ellipsis,
                  ),
                ),

                ElevatedButton(

                  onPressed:
                      onDetailPressed,

                  style:
                      ElevatedButton
                          .styleFrom(

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),

                    minimumSize:
                        Size.zero,

                    tapTargetSize:
                        MaterialTapTargetSize
                            .shrinkWrap,

                    textStyle:
                        const TextStyle(
                      fontSize: 10,
                    ),
                  ),

                  child:
                      const Text(
                    'Detail',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}