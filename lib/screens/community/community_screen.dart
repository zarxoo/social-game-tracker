import 'package:flutter/material.dart';
import 'package:social_game_tracker/core/theme/app_theme.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock user data
    final List<Map<String, dynamic>> users = [
      {'name': 'Lutfi Bagas W', 'initials': 'LW', 'level': 15, 'games': 32, 'color': Colors.pink},
      {'name': 'Mike Chen', 'initials': 'MC', 'level': 12, 'games': 28, 'color': Colors.blue},
      {'name': 'Emma Davis', 'initials': 'ED', 'level': 18, 'games': 45, 'color': Colors.green},
      {'name': 'Alex Storm', 'initials': 'AS', 'level': 20, 'games': 56, 'color': Colors.orange},
      {'name': 'Luna Knight', 'initials': 'LK', 'level': 16, 'games': 38, 'color': Colors.purpleAccent},
      {'name': 'Max Thunder', 'initials': 'MT', 'level': 14, 'games': 30, 'color': Colors.amber},
    ];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top App Bar equivalent area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.people, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Community',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Komunitas\nGamer',
                    style: AppTheme.heading1,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connect with fellow gamers',
                    style: AppTheme.subtitleText,
                  ),
                  const SizedBox(height: 24),
                  
                  // Search Bar (simplified for community)
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const TextField(
                      style: AppTheme.bodyText,
                      decoration: InputDecoration(
                        hintText: 'Search gamers...',
                        hintStyle: AppTheme.subtitleText,
                        prefixIcon: Icon(Icons.search, color: AppTheme.textSecondaryColor),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Users List Header
                  Row(
                    children: [
                      const Text(
                        'All Users',
                        style: AppTheme.heading2,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.textSecondaryColor,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text('Filter'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Users List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: user['color'],
                                child: Text(user['initials'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppTheme.successColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppTheme.cardColor, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          subtitle: Text('Level ${user['level']} • ${user['games']} games', style: AppTheme.subtitleText.copyWith(fontSize: 12)),
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.remove_red_eye, color: Colors.white, size: 20),
                              onPressed: () {},
                            ),
                          ),
                        ),
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
