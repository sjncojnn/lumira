import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const LumiraApp());
}

class LumiraApp extends StatelessWidget {
  const LumiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumira',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9810FA),
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      builder: (context, child) {
        // Hàm builder này bao bọc lấy toàn bộ widget con của MaterialApp
        return GlobalWatermark(child: child);
      },
      home: const SplashScreen(),
    );
  }
}

// Widget dùng để bọc watermark logo BK
class GlobalWatermark extends StatelessWidget {
  final Widget? child;
  const GlobalWatermark({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (child == null) return const SizedBox.shrink();

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Đưa nội dung App lên đầu (Vẽ trước, nằm dưới)
        child!, 

        // 2. Đưa Watermark xuống cuối (Vẽ sau, nằm ĐÈ LÊN TRÊN)
        IgnorePointer(
          child: Center(
            child: Opacity(
              opacity: 0.15, // Giữ nguyên độ mờ
              child: Image.asset(
                'assets/images/hcmut.png',
                width: 350,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}