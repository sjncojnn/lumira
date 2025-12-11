import 'package:flutter/foundation.dart'; // Để kiểm tra kIsWeb
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

// ==========================================
// 1. MODEL (Cấu trúc dữ liệu bài báo)
// ==========================================
class Article {
  final String title;
  final String description; // Tóm tắt
  final String link;
  final String pubDate;
  final String? imageUrl;
  final String source;

  Article({
    required this.title,
    required this.description,
    required this.link,
    required this.pubDate,
    this.imageUrl,
    this.source = 'VnExpress',
  });
}

// ==========================================
// 2. SERVICE (Xử lý RSS và Cào dữ liệu)
// ==========================================
class NewsService {
  static const String _rssUrl = 'https://vnexpress.net/rss/tin-moi-nhat.rss';
  
  // 🔴 QUAN TRỌNG: Thay link này bằng link Cloudflare Worker của bạn
  // Ví dụ: https://my-news-proxy.username.workers.dev
  static const String _workerUrl = 'https://sparkling-boat-1bf6.levanducanh0911.workers.dev'; 

  // --- Hàm tiện ích: Xử lý URL dựa trên nền tảng ---
  String _getFinalUrl(String targetUrl) {
    if (kIsWeb) {
      // Nếu là Web: Gọi qua Proxy Cloudflare
      // Cấu trúc: https://worker-url/?url=https://vnexpress...
      return '$_workerUrl?url=$targetUrl';
    } else {
      // Nếu là Mobile (Android/iOS): Gọi trực tiếp (Nhanh hơn, không cần Proxy)
      return targetUrl;
    }
  }

  // --- Hàm 1: Lấy danh sách bài mới từ RSS ---
  Future<List<Article>> fetchNews() async {
    try {
      final String url = _getFinalUrl(_rssUrl);
      
      // Thêm User-Agent để trông giống trình duyệt thật, tránh bị chặn
      final response = await http.get(Uri.parse(url), headers: {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
        "Accept": "application/xml, text/xml, */*; q=0.01",
      });

      if (response.statusCode == 200) {
        // Lưu ý: Đôi khi Worker trả về UTF-8 nhưng header thiếu, 
        // dòng này giúp ép kiểu decode đúng tiếng Việt nếu bị lỗi font.
        // Tuy nhiên http package bản mới thường tự xử lý tốt.
        // var decodedBody = utf8.decode(response.bodyBytes); 

        final document = XmlDocument.parse(response.body);
        final items = document.findAllElements('item');

        return items.map((element) {
          final title = element.findElements('title').firstOrNull?.innerText ?? "";
          final link = element.findElements('link').firstOrNull?.innerText ?? "";
          final pubDate = element.findElements('pubDate').firstOrNull?.innerText ?? "";
          
          String descriptionRaw = element.findElements('description').firstOrNull?.innerText ?? "";

          // Trích xuất ảnh
          String? imgUrl;
          final imgRegExp = RegExp(r'src="([^"]+)"');
          final match = imgRegExp.firstMatch(descriptionRaw);
          if (match != null) {
            imgUrl = match.group(1);
          }

          // Làm sạch tóm tắt
          final cleanDescription = descriptionRaw
              .replaceAll(RegExp(r'<[^>]*>'), '')
              .replaceAll('&nbsp;', ' ')
              .trim();

          return Article(
            title: title,
            description: cleanDescription,
            link: link,
            pubDate: pubDate,
            imageUrl: imgUrl,
          );
        }).toList();
      } else {
        throw Exception('Failed to load RSS: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }

  // --- Hàm 2: Cào nội dung chi tiết (CRAWL FULL TEXT) ---
  Future<String> fetchArticleContent(String targetLink) async {
    try {
      final String url = _getFinalUrl(targetLink);

      final response = await http.get(Uri.parse(url), headers: {
         "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
      });

      if (response.statusCode == 200) {
        var document = parser.parse(response.body);

        // Các class chứa nội dung của VnExpress
        dom.Element? contentElement = document.getElementsByClassName('fck_detail').firstOrNull;
        contentElement ??= document.getElementsByClassName('sidebar-1').firstOrNull; 
        contentElement ??= document.getElementsByTagName('article').firstOrNull;

      if (contentElement != null) {
        // --- XỬ LÝ LÀM SẠCH HTML ---
        
        // 1. Xóa rác
        contentElement.getElementsByClassName('box-category-related').forEach((e) => e.remove());
        contentElement.getElementsByClassName('header-content').forEach((e) => e.remove());
        contentElement.getElementsByClassName('footer-content').forEach((e) => e.remove());
        
        // 2. [QUAN TRỌNG] Fix lỗi ảnh không hiện (Lazy loading)
        // Tìm tất cả thẻ img, nếu có data-src thì gán nó vào src
        for (var img in contentElement.getElementsByTagName('img')) {
          if (img.attributes.containsKey('data-src')) {
            img.attributes['src'] = img.attributes['data-src']!;
          }
        }
        
        // 3. Fix lỗi video (VnExpress dùng iframe/video tag phức tạp, tạm thời ẩn đi hoặc thay bằng text)
        contentElement.getElementsByTagName('video').forEach((e) {
           e.replaceWith(dom.Element.html('<p><i>[Video content - Vui lòng xem trên web]</i></p>'));
        });

        return contentElement.innerHtml;
      } else {
          return "<p>Không thể lấy nội dung chi tiết. <br>Vui lòng nhấn nút bên dưới để mở gốc.</p>";
        }
      } else {
        return "<p>Lỗi tải trang: ${response.statusCode}</p>";
      }
    } catch (e) {
      return "<p>Lỗi kết nối: $e</p>";
    }
  }
}

// ==========================================
// 3. MAIN SCREEN (Danh sách tin tức)
// ==========================================
class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsService _newsService = NewsService();
  late Future<List<Article>> _futureArticles;

  @override
  void initState() {
    super.initState();
    _futureArticles = _newsService.fetchNews();
  }

  String _formatDate(String dateStr) {
    if (dateStr.length > 16) return dateStr.substring(0, 16);
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      // --- AppBar Gradient Cam ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF4E00), Color(0xFFEC9F05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.public, color: Colors.blueAccent, size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        "VnExpress News",
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text("Vietnam", style: TextStyle(color: Colors.white, fontSize: 12)),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Latest Articles",
              style: TextStyle(fontSize: 18, color: Colors.blueGrey, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Article>>(
              future: _futureArticles,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFF4E00)));
                } else if (snapshot.hasError) {
                  return Center(child: Text("Lỗi: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Không có tin tức nào"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return _buildArticleCard(context, snapshot.data![index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, Article article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ArticleDetailScreen(article: article)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Tag Trending giả lập
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B00),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.trending_up, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text("Trending", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (article.imageUrl != null)
                  Container(
                    margin: const EdgeInsets.only(left: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: article.imageUrl!,
                        width: 80, height: 80, fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 12),
            Text(
              article.description,
              style: const TextStyle(fontSize: 13, color: Colors.blueGrey, height: 1.4),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(article.source, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(width: 8),
                const Text("•", style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 8),
                Text(_formatDate(article.pubDate), style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. DETAIL SCREEN (Hiển thị Full HTML Cào được)
// ==========================================
class ArticleDetailScreen extends StatefulWidget {
  final Article article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final NewsService _newsService = NewsService();
  late Future<String> _futureContent;

  @override
  void initState() {
    super.initState();
    // Gọi hàm cào nội dung chi tiết
    _futureContent = _newsService.fetchArticleContent(widget.article.link);
  }

  Future<void> _launchURL() async {
    final Uri url = Uri.parse(widget.article.link);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF4E00), Color(0xFFEC9F05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text("Back to News", style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4E00),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text("Vietnam", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),

            // Tiêu đề
            Text(
              widget.article.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.3),
            ),
            const SizedBox(height: 16),

            // Metadata
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 12,
                  child: Icon(Icons.person, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Text(widget.article.source, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                const SizedBox(width: 12),
                const Icon(Icons.circle, size: 4, color: Colors.grey),
                const SizedBox(width: 12),
                Text(
                  widget.article.pubDate.length > 16 ? widget.article.pubDate.substring(0, 16) : widget.article.pubDate,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            // NỘI DUNG CHÍNH (FULL CONTENT)
            FutureBuilder<String>(
              future: _futureContent,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Đang tải... hiện tạm tóm tắt
                  return Column(
                    children: [
                      const Center(child: CircularProgressIndicator(color: Color(0xFFFF4E00))),
                      const SizedBox(height: 20),
                      Text(widget.article.description, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  );
                } else if (snapshot.hasError) {
                   return Text("Lỗi tải nội dung: ${snapshot.error}");
                }

                // Render HTML đã cào được
                return HtmlWidget(
                  snapshot.data ?? "",
                  textStyle: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                  
                  // Dùng customWidgetBuilder để can thiệp sâu vào cấu trúc
                  customWidgetBuilder: (element) {
                    // 1. Bắt các thẻ chứa ảnh và chú thích của VnExpress (thường là figure hoặc table class="tplCaption")
                    if (element.localName == 'figure' || (element.localName == 'table' && element.classes.contains('tplCaption'))) {
                      String? imgSrc = element.getElementsByTagName('img').firstOrNull?.attributes['src'];
                      // Lấy text chú thích (bỏ qua text của bản thân cái ảnh)
                      String caption = element.text.replaceFirst(imgSrc ?? "", "").trim();
                      
                      // Nếu tìm thấy ảnh, trả về Widget tự dựng
                      if (imgSrc != null) {
                        return _buildCustomImageBlock(imgSrc, caption);
                      }
                    }

                    // 2. Ẩn video/iframe để tránh lỗi
                    if (element.localName == 'video' || element.localName == 'iframe') {
                      return Container();
                    }
                    
                    return null; // Các thẻ khác để mặc định
                  },
                );
              },
            ),

            const SizedBox(height: 20),
            // Nút mở link gốc phòng hờ
            Center(
              child: TextButton.icon(
                onPressed: _launchURL,
                icon: const Icon(Icons.open_in_new),
                label: const Text("Mở trên web VnExpress"),
                style: TextButton.styleFrom(foregroundColor: Colors.blue[700]),
              ),
            ),
            const SizedBox(height: 30),

            // Action Buttons
            _buildActionButtons(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.thumb_up_outlined, color: Colors.white), SizedBox(width: 8),
                Text('125K', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              ]),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.share, color: Colors.white), SizedBox(width: 8),
                Text('Share', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              ]),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 48, width: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: Colors.white)),
        ),
      ],
    );
  }
  Widget _buildCustomImageBlock(String src, String caption) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Ảnh
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: src,
              width: double.infinity, // Full chiều ngang
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200, 
                color: Colors.grey[200], 
                child: const Center(child: CircularProgressIndicator())
              ),
              errorWidget: (context, url, error) => const SizedBox(), // Ẩn nếu lỗi
            ),
          ),
          // Chú thích (chỉ hiện nếu có nội dung)
          if (caption.isNotEmpty) 
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
              child: Text(
                caption,
                textAlign: TextAlign.center, // Căn giữa chú thích
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}