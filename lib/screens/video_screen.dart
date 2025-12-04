import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  static const String API_KEY = 'AIzaSyDuP1wIcmES-YSrHSqUiheh38kN5HjKNC0';
  
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  List<Map<String, dynamic>> _suggestedVideos = [];
  bool _isLoading = true;
  
  // Default video - Introduction to 3D Modeling
  String _currentVideoId = 'pRaC9YldAKw';
  String _currentVideoTitle = 'Introduction to 3D Modeling - Complete Tutorial';
  String _currentChannelName = 'Blender Guru';
  String _currentViews = '1.2M views';
  String _currentTimeAgo = '2 days ago';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _fetchSuggestedVideos();
  }

  void _initializePlayer() {
    _controller = YoutubePlayerController(
      initialVideoId: _currentVideoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
      ),
    )..addListener(_listener);
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {});
    }
  }

  Future<void> _fetchSuggestedVideos() async {
    try {
      // Fetch trending videos related to 3D modeling, AR, and technology
      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=10&q=3D+modeling+AR+technology&key=$API_KEY',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;

        setState(() {
          _suggestedVideos = items.map((item) {
            return {
              'videoId': item['id']['videoId'],
              'title': item['snippet']['title'],
              'channelName': item['snippet']['channelTitle'],
              'thumbnail': item['snippet']['thumbnails']['medium']['url'],
              'publishedAt': item['snippet']['publishedAt'],
            };
          }).toList();
          _isLoading = false;
        });

        // Fetch view counts for each video
        _fetchViewCounts();
      }
    } catch (e) {
      print('Error fetching videos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchViewCounts() async {
    try {
      final videoIds = _suggestedVideos.map((v) => v['videoId']).join(',');
      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/youtube/v3/videos?part=statistics&id=$videoIds&key=$API_KEY',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;

        setState(() {
          for (int i = 0; i < items.length && i < _suggestedVideos.length; i++) {
            final viewCount = items[i]['statistics']['viewCount'];
            _suggestedVideos[i]['views'] = _formatViews(viewCount);
          }
        });
      }
    } catch (e) {
      print('Error fetching view counts: $e');
    }
  }

  String _formatViews(String viewCount) {
    final views = int.tryParse(viewCount) ?? 0;
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M views';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(0)}K views';
    }
    return '$views views';
  }

  String _getTimeAgo(String publishedAt) {
    final publishedDate = DateTime.parse(publishedAt);
    final now = DateTime.now();
    final difference = now.difference(publishedDate);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    }
  }

  void _playVideo(Map<String, dynamic> video) {
    setState(() {
      _currentVideoId = video['videoId'];
      _currentVideoTitle = video['title'];
      _currentChannelName = video['channelName'];
      _currentViews = video['views'] ?? '0 views';
      _currentTimeAgo = _getTimeAgo(video['publishedAt']);
    });

    _controller.load(_currentVideoId);
    
    // Scroll to top
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Video Player - Fixed at top
            YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Color(0xFFEC4899),
              progressColors: ProgressBarColors(
                playedColor: Color(0xFFEC4899),
                handleColor: Color(0xFFEC4899),
                backgroundColor: Colors.grey.shade300,
                bufferedColor: Colors.grey.shade400,
              ),
              onReady: () {
                _isPlayerReady = true;
              },
              bottomActions: [
                CurrentPosition(),
                const SizedBox(width: 10),
                ProgressBar(
                  isExpanded: true,
                  colors: ProgressBarColors(
                    playedColor: Color(0xFFEC4899),
                    handleColor: Color(0xFFEC4899),
                    backgroundColor: Colors.grey.shade400,
                    bufferedColor: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(width: 10),
                RemainingDuration(),
                const SizedBox(width: 10),
                FullScreenButton(),
              ],
            ),

            // Scrollable content below video player
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video Info Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFEC4899),
                            Color(0xFFF43F5E),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFEC4899).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentVideoTitle,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$_currentChannelName • $_currentViews • $_currentTimeAgo',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF3B82F6).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  // Like action
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.thumb_up, color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      '125K',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF10B981).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  // Share action
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.share, color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Share',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF8B5CF6).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {
                                // More options
                              },
                              icon: Icon(Icons.more_vert, color: Colors.white),
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Suggested Videos Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(Icons.video_library, size: 20, color: Colors.black87),
                          const SizedBox(width: 8),
                          Text(
                            'Suggested Videos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Suggested Videos List
                    _isLoading
                        ? Container(
                            height: 300,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFEC4899),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _suggestedVideos.length,
                            itemBuilder: (context, index) {
                              final video = _suggestedVideos[index];
                              return _buildVideoCard(video);
                            },
                          ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    return GestureDetector(
      onTap: () => _playVideo(video),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Image.network(
                    video['thumbnail'],
                    width: 160,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 160,
                        height: 120,
                        color: Colors.grey.shade300,
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 48,
                          color: Colors.grey.shade600,
                        ),
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFEC4899).withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFEC4899).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Video Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video['title'],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      video['channelName'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${video['views'] ?? 'N/A'} • ${_getTimeAgo(video['publishedAt'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}