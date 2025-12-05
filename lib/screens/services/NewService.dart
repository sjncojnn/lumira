import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

// --- MODEL ---
class Article {
  final String title;
  final String description;
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

// --- SERVICE LẤY TIN TỪ VNEXPRESS (ĐÃ SỬA LỖI) ---
class NewsService {
  static const String rssUrl = 'https://vnexpress.net/rss/tin-moi-nhat.rss';

  Future<List<Article>> fetchNews() async {
    try {
      final response = await http.get(Uri.parse(rssUrl));
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final items = document.findAllElements('item');

        return items.map((element) {
          final descriptionRaw = element.findElements('description').isNotEmpty 
              ? element.findElements('description').first.innerText 
              : "";
          
          final title = element.findElements('title').isNotEmpty 
              ? element.findElements('title').first.innerText 
              : "No Title";
              
          final link = element.findElements('link').isNotEmpty 
              ? element.findElements('link').first.innerText 
              : "";
              
          final pubDate = element.findElements('pubDate').isNotEmpty 
              ? element.findElements('pubDate').first.innerText 
              : "";

          // Trích xuất ảnh từ thẻ HTML description
          String? imgUrl;
          final imgRegExp = RegExp(r'src="([^"]+)"');
          final match = imgRegExp.firstMatch(descriptionRaw);
          if (match != null) {
            imgUrl = match.group(1);
          }

          // Làm sạch text description (xóa các thẻ HTML <br>, </a>...)
          final cleanDescription = descriptionRaw
              .replaceAll(RegExp(r'<[^>]*>'), '') // Xóa thẻ HTML
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
        throw Exception('Failed to load RSS');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }
}