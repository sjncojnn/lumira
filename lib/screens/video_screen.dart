import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  // --- THAY API KEY CỦA BẠN VÀO ĐÂY ---
  static const String API_KEY = 'AIzaSyDuP1wIcmES-YSrHSqUiheh38kN5HjKNC0';

  // Chuyển controller thành nullable (có thể null)
  YoutubePlayerController? _controller;

  // Biến kiểm tra xem đã bắt đầu xem video chưa
  bool _hasStarted = false;

  // Biến lưu thông tin video đang phát
  String _currentVideoTitle = '';
  String _currentChannelName = '';
  String _currentViews = '';
  String _currentTimeAgo = '';

  List<Map<String, dynamic>> _suggestedVideos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // LƯU Ý: Không khởi tạo _controller ở đây nữa.
    // Chỉ tải danh sách video gợi ý ban đầu.
    _fetchSuggestedVideos("Flutter tutorial for beginners");
  }

  Future<void> _fetchSuggestedVideos(String query) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=10&q=$query&key=$API_KEY',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;

        if (mounted) {
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
        }
        _fetchViewCounts();
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchViewCounts() async {
    try {
      if (_suggestedVideos.isEmpty) return;
      final videoIds = _suggestedVideos.map((v) => v['videoId']).join(',');
      final response = await http.get(
        Uri.parse(
            'https://www.googleapis.com/youtube/v3/videos?part=statistics&id=$videoIds&key=$API_KEY'),
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
      print(e);
    }
  }

  String _formatViews(String? viewCount) {
    if (viewCount == null) return '';
    final views = int.tryParse(viewCount) ?? 0;
    if (views >= 1000000)
      return '${(views / 1000000).toStringAsFixed(1)}M views';
    if (views >= 1000) return '${(views / 1000).toStringAsFixed(0)}K views';
    return '$views views';
  }

  String _getTimeAgo(String publishedAt) {
    // (Logic giữ nguyên để rút gọn code hiển thị)
    return publishedAt.substring(0, 10);
  }

  // --- HÀM QUAN TRỌNG NHẤT: XỬ LÝ KHI BẤM VIDEO ---
  void _playVideo(Map<String, dynamic> video) {
    final videoId = video['videoId'];

    // 1. Cập nhật UI Info
    setState(() {
      _currentVideoTitle = video['title'];
      _currentChannelName = video['channelName'];
      _currentViews = video['views'] ?? '';
      _currentTimeAgo = _getTimeAgo(video['publishedAt']);
      _hasStarted = true; // Đánh dấu là đã bắt đầu xem
    });

    // 2. Xử lý Controller
    if (_controller == null) {
      // Nếu chưa có controller (lần đầu bấm), thì tạo mới
      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: true, // Web cần mute, Android thì false
        ),
      );
    } else {
      // Nếu đã có controller rồi, thì chỉ cần load video mới
      _controller!.loadVideoById(videoId: videoId);
    }

    // 3. Load danh sách gợi ý mới theo bài hát vừa bấm
    _fetchSuggestedVideos(video['title']);

    // 4. Scroll lên đầu
    if (mounted) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller?.close(); // Dùng dấu ? vì controller có thể null
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // --- LOGIC HIỂN THỊ PLAYER ---
            // Nếu _hasStarted là true và controller đã có -> Hiện Player
            // Nếu chưa -> Ẩn đi (Size = 0)
            if (_hasStarted && _controller != null) ...[
              YoutubePlayer(
                controller: _controller!,
                aspectRatio: 16 / 9,
              ),

              // Chỉ hiện Info Card khi đã chọn video
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(), // Hàm tách riêng cho gọn
                      _buildActionButtons(),
                      _buildListHeader(),
                      _buildVideoList(),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // --- MÀN HÌNH CHỜ (LÚC MỚI VÀO) ---
              // Hiển thị Header to hơn hoặc thanh tìm kiếm ở đây nếu muốn
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                width: double.infinity,
                child: const Text(
                  "Discover Videos",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildVideoList(), // Chỉ hiện mỗi list
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- CÁC WIDGET CON (Tách ra cho code ngắn gọn) ---

  Widget _buildVideoList() {
    if (_isLoading) {
      return const SizedBox(
          height: 300,
          child: Center(
              child: CircularProgressIndicator(color: Color(0xFFEC4899))));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _suggestedVideos.length,
      itemBuilder: (context, index) {
        return _buildVideoCard(_suggestedVideos[index]);
      },
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withOpacity(0.3),
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
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Text(
            '$_currentChannelName • $_currentViews • $_currentTimeAgo',
            style:
                TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Like Button (Blue)
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFF1877F2), // Blue
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1877F2).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                // Handle Like Action
                print('Like button pressed');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.thumb_up_alt_outlined,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '125K',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Share Button (Green)
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFF00B14F), // Green
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00B14F).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                // Handle Share Action
                print('Share button pressed');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.share_outlined,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Share',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // More Button (Gradient Purple)
          Container(
            height: 45,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFA855F7), Color(0xFFEC4899)], // Purple to Pink
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFA855F7).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                // Handle More Action
                print('More button pressed');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Icon(Icons.video_library, size: 20),
          SizedBox(width: 8),
          Text('Suggested Videos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
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
                color: Colors.black12, blurRadius: 12, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16)),
              child: Image.network(
                video['thumbnail'],
                width: 140,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) =>
                    Container(width: 140, height: 100, color: Colors.grey),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(video['title'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(video['channelName'],
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}