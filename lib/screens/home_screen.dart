import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final Function(int)? onTabSwitch;

  const HomeScreen({super.key, this.onTabSwitch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient background
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4A3FFF),
                      Color(0xFF9D4EDD),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'v1.0',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Welcome to Lumira',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your all-in-one multimedia experience',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Read news, watch videos, explore 3D models,\nand experience augmented reality',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Features header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '4 Available',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // Feature Cards with gradient borders
              _buildFeatureCard(
                context: context,
                icon: Icons.article,
                iconColor: Colors.white,
                iconBackgroundColor: Color(0xFFFF5722),
                title: '📰 News Reader',
                badge: '3+ Sources',
                badgeColor: Color(0xFFFF5722),
                description: 'Stay informed with live news from top sources worldwide',
                subtitle: 'Access articles from BBC, CNN, Reuters, and more. Read full stories with images and detailed content.',
                buttonText: 'Launch News',
                gradientColors: [Color(0xFFFF6B35), Color(0xFFFF5722)],
                onTap: () {
                  if (onTabSwitch != null) {
                    onTabSwitch!(1);
                  }
                },
              ),
              
              SizedBox(height: 16),
              
              _buildFeatureCard(
                context: context,
                icon: Icons.play_circle_filled,
                iconColor: Colors.white,
                iconBackgroundColor: Color(0xFFE91E63),
                title: '🎬 Video Player',
                badge: 'Live Streaming',
                badgeColor: Color(0xFFE91E63),
                description: 'Watch and stream YouTube videos directly in the app',
                subtitle: 'Embedded YouTube player with full playback controls. Stream trending content instantly.',
                buttonText: 'Launch Video',
                gradientColors: [Color(0xFFEC407A), Color(0xFFE91E63)],
                onTap: () {
                  if (onTabSwitch != null) {
                    onTabSwitch!(2);
                  }
                },
              ),
              
              SizedBox(height: 16),
              
              _buildFeatureCard(
                context: context,
                icon: Icons.view_in_ar,
                iconColor: Colors.white,
                iconBackgroundColor: Color(0xFF9C27B0),
                title: '📦 3D Viewer',
                badge: '4+ Shapes',
                badgeColor: Color(0xFF9C27B0),
                description: 'Explore interactive 3D models with full control',
                subtitle: 'Rotate, zoom, and interact with various 3D shapes including cubes, spheres, pyramids, and more.',
                buttonText: 'Launch 3D',
                gradientColors: [Color(0xFFAB47BC), Color(0xFF9C27B0)],
                onTap: () {
                  if (onTabSwitch != null) {
                    onTabSwitch!(3);
                  }
                },
              ),
              
              SizedBox(height: 16),
              
              _buildFeatureCard(
                context: context,
                icon: Icons.camera_alt,
                iconColor: Colors.white,
                iconBackgroundColor: Color(0xFF00BCD4),
                title: '🔵 AR Scanner',
                badge: 'Interactive AR',
                badgeColor: Color(0xFF00BCD4),
                description: 'Scan QR codes to reveal augmented reality objects',
                subtitle: 'Point your camera at QR codes to place interactive 3D objects in your space. Drag, rotate, and scale them!',
                buttonText: 'Launch AR',
                gradientColors: [Color(0xFF26C6DA), Color(0xFF00BCD4)],
                onTap: () {
                  if (onTabSwitch != null) {
                    onTabSwitch!(4);
                  }
                },
              ),
              
              SizedBox(height: 24),
              
              // About Lumira
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: Color(0xFF6C5CE7)),
                        SizedBox(width: 8),
                        Text(
                          'About Lumira',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Lumira combines the best of news reading, video streaming, 3D visualization, and augmented reality into one seamless mobile experience. Explore each feature by tapping on the cards above or using the navigation bar below.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Quick Tips
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, size: 16, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Quick Tips',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    _buildTip('📰 Tap any article in News to read the full story with images'),
                    _buildTip('🎬 Videos play instantly - no need to leave the app'),
                    _buildTip('📦 Use sliders to rotate and zoom 3D objects in real-time'),
                    _buildTip('🔵 Scan QR codes to place objects, then drag to move them'),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Term of Services
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 16, color: Colors.black87),
                        SizedBox(width: 8),
                        Text(
                          'Term of Services',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'This application is a university course project created solely for educational and demonstration purposes. It is not intended for commercial use or real-world deployment. The application is provided as-is and will be permanently removed in January 2028. Please do not use solely for reference, template, or basis for other applications.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'The development team does not accept any responsibility for copyright issues, misuse, or unintended consequences arising from the use of this project.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required String title,
    required String badge,
    required Color badgeColor,
    required String description,
    required String subtitle,
    required String buttonText,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Container(
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  badge,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              buttonText,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}