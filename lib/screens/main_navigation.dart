import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'news_screen.dart';
import 'video_screen.dart';
import 'threed_screen.dart';
import 'ar_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    HomeScreen(onTabSwitch: (index) {
      setState(() {
        _currentIndex = index;
      });
    }),
    const NewsScreen(),
    const VideoScreen(),
    const ThreeDScreen(),
    const ARScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          border: Border(
            top: BorderSide(
              color: Colors.black.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavButton(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                  isActive: _currentIndex == 0,
                ),
                _buildNavButton(
                  icon: Icons.article_outlined,
                  label: 'News',
                  index: 1,
                  isActive: _currentIndex == 1,
                ),
                _buildNavButton(
                  icon: Icons.play_circle_outline,
                  label: 'Video',
                  index: 2,
                  isActive: _currentIndex == 2,
                ),
                _buildNavButton(
                  icon: Icons.view_in_ar_outlined,
                  label: '3D',
                  index: 3,
                  isActive: _currentIndex == 3,
                ),
                _buildNavButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'AR',
                  index: 4,
                  isActive: _currentIndex == 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isActive
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF6900),
                    Color(0xFFFB2C36),
                  ],
                )
              : null,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: SizedBox(
          width: 58,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: isActive ? Colors.white : const Color(0xFF90A1B9),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.white : const Color(0xFF90A1B9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
