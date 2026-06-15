import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/game_model.dart';
import '../../services/auth_service.dart';

import '../main_screen.dart';
import '../detail/game_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('User belum login'),
        ),
      );
    }

    final uid = currentUser.uid;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          backgroundColor: AppTheme.primaryColor.withOpacity(0.92),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              tooltip: 'Logout',
              onPressed: () async {
                await AuthService().logout();

                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return _buildEmptyState(
                icon: Icons.person_off_rounded,
                title: 'User tidak ditemukan',
                subtitle: 'Data profile belum tersedia di database.',
                color: AppTheme.primaryColor,
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final wishlist = _asList(data['wishlist']);
            final played = _asList(data['played']);
            final favorites = _asList(data['favorites']);
            final username = _readUsername(data);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileHeader(
                  username: username,
                  wishlistCount: wishlist.length,
                  playedCount: played.length,
                  favoriteCount: favorites.length,
                ),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildStatsTab(played),
                      _buildGameGrid(wishlist, context, 'wishlist'),
                      _buildGameGrid(played, context, 'played'),
                      _buildGameGrid(favorites, context, 'favorites'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader({
    required String username,
    required int wishlistCount,
    required int playedCount,
    required int favoriteCount,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.92),
            const Color(0xFF1C1933),
            AppTheme.backgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white.withOpacity(0.12),
                child: CircleAvatar(
                  radius: 38,
                  backgroundColor: AppTheme.cardColor,
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : 'P',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${_slugify(username)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.68),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sports_esports_rounded,
                            color: Colors.white.withOpacity(0.9),
                            size: 14,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'My Game Library',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withOpacity(0.09),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildProfileStat(
                    value: wishlistCount.toString(),
                    label: 'Wishlist',
                    icon: Icons.bookmark_rounded,
                    color: Colors.amber,
                  ),
                ),
                Expanded(
                  child: _buildProfileStat(
                    value: playedCount.toString(),
                    label: 'Played',
                    icon: Icons.sports_esports_rounded,
                    color: Colors.tealAccent,
                  ),
                ),
                Expanded(
                  child: _buildProfileStat(
                    value: favoriteCount.toString(),
                    label: 'Favorite',
                    icon: Icons.star_rounded,
                    color: Colors.pinkAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 46,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
        child: TabBar(
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(999),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Stats'),
            Tab(text: 'Wishlist'),
            Tab(text: 'Played'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTab(List<dynamic> played) {
    if (played.isEmpty) {
      return _buildEmptyState(
        icon: Icons.analytics_outlined,
        title: 'Belum ada statistik',
        subtitle: 'Statistik akan muncul setelah kamu punya game yang sudah dimainkan.',
        color: AppTheme.primaryColor,
      );
    }

    final totalGames = played.length;
    final Map<String, int> yearCounts = {};
    final Map<String, int> genreCounts = {};

    for (final item in played) {
      final game = _asMap(item);

      final releaseDate = _readString(
        game,
        ['releasedDate', 'released'],
        fallback: '',
      );

      if (releaseDate.length >= 4) {
        final year = releaseDate.substring(0, 4);
        yearCounts[year] = (yearCounts[year] ?? 0) + 1;
      }

      var genres = _readStringList(game['genres']);

      for (final genre in genres) {
        genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
      }
    }

    final sortedYears = yearCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sortedGenres = genreCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final favoriteYear = sortedYears.isNotEmpty ? sortedYears.first.key : '-';
    final favoriteGenre =
        sortedGenres.isNotEmpty ? sortedGenres.first.key : '-';

    final topGenres = sortedGenres.take(3).toList();
    final topGenresTotal = topGenres.fold<int>(
      0,
      (sum, item) => sum + item.value,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        _buildStatCard(
          title: 'Total Games Played',
          value: totalGames.toString(),
          icon: Icons.sports_esports_rounded,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          title: 'Most Played Year',
          value: favoriteYear,
          icon: Icons.calendar_month_rounded,
          color: Colors.amber,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          title: 'Favorite Genre',
          value: favoriteGenre,
          icon: Icons.category_rounded,
          color: Colors.tealAccent,
        ),
        const SizedBox(height: 24),
        const Text(
          'Top Genres',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        _buildGenreChart(
          topGenres: topGenres,
          total: topGenresTotal,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    final iconColor = color ?? AppTheme.primaryColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChart({
    required List<MapEntry<String, int>> topGenres,
    required int total,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: topGenres.isEmpty || total == 0
          ? const Text(
              'Belum cukup data untuk chart.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            )
          : Column(
              children: topGenres.map((entry) {
                final percentage = entry.value / total;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${(percentage * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: percentage.clamp(0.0, 1.0).toDouble(),
                          minHeight: 8,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildGameGrid(
    List<dynamic> games,
    BuildContext context,
    String listType,
  ) {
    if (games.isEmpty) {
      final config = _listConfig(listType);

      return _buildEmptyState(
        icon: config.icon,
        title: config.emptyTitle,
        subtitle: config.emptySubtitle,
        color: config.color,
      );
    }

    final config = _listConfig(listType);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = _asMap(games[index]);

        return _buildGameCard(
          context: context,
          game: game,
          config: config,
        );
      },
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required Map<String, dynamic> game,
    required _ListUiConfig config,
  }) {
    final name = _readString(
      game,
      ['name'],
      fallback: 'Unknown Game',
    );

    final image = _readString(
      game,
      ['image', 'backgroundImage', 'background_image'],
      fallback: '',
    );

    final releasedDate = _readString(
      game,
      ['releasedDate', 'released'],
      fallback: '-',
    );

    final rating = _readDouble(game['rating']);
    final tags = _readStringList(game['genres']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _navigateToDetail(context, game),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: _cardDecoration(),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 96,
                    height: 112,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (image.isNotEmpty)
                          Image.network(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder();
                            },
                          )
                        else
                          _buildImagePlaceholder(),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.62),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        if (rating > 0)
                          Positioned(
                            left: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.70),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    height: 112,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusBadge(config),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: Colors.grey,
                              size: 13,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                releasedDate,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (tags.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: tags
                                .take(2)
                                .map((tag) => _buildSmallChip(tag))
                                .toList(),
                          )
                        else
                          _buildSmallChip('No tag'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.35),
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(_ListUiConfig config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            color: config.color,
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppTheme.backgroundColor,
      child: Icon(
        Icons.videogame_asset_rounded,
        color: Colors.grey[700],
        size: 36,
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: _cardDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppTheme.cardColor,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: Colors.white.withOpacity(0.06),
      ),
    );
  }

  _ListUiConfig _listConfig(String listType) {
    if (listType == 'wishlist') {
      return const _ListUiConfig(
        label: 'Wishlist',
        icon: Icons.bookmark_rounded,
        color: Colors.amber,
        emptyTitle: 'Wishlist masih kosong',
        emptySubtitle: 'Game yang ingin kamu mainkan akan muncul di sini.',
      );
    }

    if (listType == 'played') {
      return const _ListUiConfig(
        label: 'Played',
        icon: Icons.sports_esports_rounded,
        color: Colors.tealAccent,
        emptyTitle: 'Belum ada game dimainkan',
        emptySubtitle: 'Game yang sudah kamu mainkan akan tampil di sini.',
      );
    }

    return const _ListUiConfig(
      label: 'Favorite',
      icon: Icons.star_rounded,
      color: Colors.pinkAccent,
      emptyTitle: 'Belum ada favorit',
      emptySubtitle: 'Game favorit kamu akan muncul di bagian ini.',
    );
  }

  void _navigateToDetail(BuildContext context, Map<String, dynamic> gameData) {
    final dummyGame = GameModel(
      id: _readInt(gameData['id']),
      name: _readString(gameData, ['name'], fallback: 'Unknown Game'),
      backgroundImage: _readString(
        gameData,
        ['image', 'backgroundImage', 'background_image'],
        fallback: '',
      ),
      rating: _readDouble(gameData['rating']),
      releasedDate: _readString(
        gameData,
        ['releasedDate', 'released'],
        fallback: '-',
      ),
      platforms: _readStringList(gameData['platforms']),
      genres: _readStringList(gameData['genres']),
      description: _readString(
        gameData,
        ['description'],
        fallback: '',
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameDetailScreen(game: dummyGame),
      ),
    );
  }

  static String _readUsername(Map<String, dynamic> data) {
    final username = data['username']?.toString().trim();

    if (username != null && username.isNotEmpty) {
      return username;
    }

    return 'Player';
  }

  static List<dynamic> _asList(dynamic value) {
    if (value is List) return value;
    return <dynamic>[];
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static String _readString(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallback;
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _readDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static List<String> _readStringList(dynamic value) {
    if (value is! List) return <String>[];

    return value
        .map((item) {
          if (item is Map) {
            final directName = item['name'];

            if (directName != null) {
              return directName.toString();
            }

            final platform = item['platform'];

            if (platform is Map && platform['name'] != null) {
              return platform['name'].toString();
            }
          }

          return item.toString();
        })
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }

  static String _slugify(String value) {
    final cleaned = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    return cleaned.isNotEmpty ? cleaned : 'player';
  }
}

class _ListUiConfig {
  final String label;
  final IconData icon;
  final Color color;
  final String emptyTitle;
  final String emptySubtitle;

  const _ListUiConfig({
    required this.label,
    required this.icon,
    required this.color,
    required this.emptyTitle,
    required this.emptySubtitle,
  });
}