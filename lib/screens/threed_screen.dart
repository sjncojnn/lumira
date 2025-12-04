import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class ThreeDScreen extends StatefulWidget {
  const ThreeDScreen({super.key});

  @override
  State<ThreeDScreen> createState() => _ThreeDScreenState();
}

class _ThreeDScreenState extends State<ThreeDScreen>
    with SingleTickerProviderStateMixin {
  String _selectedShape = 'cube';
  double _rotation = 0.0;
  double _zoom = 1.0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(() {
        setState(() {});
      });
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _rotateShape() {
    setState(() {
      _rotation += 0.2;
      if (_rotation >= math.pi * 2) {
        _rotation = 0;
      }
    });
  }

  void _resetAll() {
    setState(() {
      _rotation = 0.0;
      _zoom = 1.0;
      _selectedShape = 'cube';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F5F5),
              Color(0xFFFFF0F5),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _build3DCanvas(),
                  const SizedBox(height: 16),
                  _buildShapeSelector(),
                  const SizedBox(height: 16),
                  _buildRotationControl(),
                  const SizedBox(height: 16),
                  _buildZoomControl(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7C3AED),
            Color(0xFF6366F1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF7C3AED).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎨 3D Viewer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Interactive 3D model visualization',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DCanvas() {
    return Container(
      width: double.infinity,
      height: 350,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4C1D95),
            Color(0xFF7C3AED),
            Color(0xFFEC4899),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4C1D95).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CustomPaint(
          painter: Shape3DPainter(
            shape: _selectedShape,
            rotation: _rotation,
            zoom: _zoom,
          ),
        ),
      ),
    );
  }

  Widget _buildShapeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEEF2FF),
            Color(0xFFFAF5FF),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFC7D2FE), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🎯 Select Shape',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4C1D95),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildShapeButton('cube', Icons.crop_square, Color(0xFF7C3AED), Color(0xFF6366F1))),
              const SizedBox(width: 8),
              Expanded(child: _buildShapeButton('sphere', Icons.circle_outlined, Color(0xFFEC4899), Color(0xFFF43F5E))),
              const SizedBox(width: 8),
              Expanded(child: _buildShapeButton('pyramid', Icons.change_history, Color(0xFFF97316), Color(0xFFF59E0B))),
              const SizedBox(width: 8),
              Expanded(child: _buildShapeButton('torus', Icons.hexagon_outlined, Color(0xFF06B6D4), Color(0xFF3B82F6))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShapeButton(String shape, IconData icon, Color color1, Color color2) {
    final isActive = _selectedShape == shape;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedShape = shape;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color1, color2],
                )
              : null,
          color: isActive ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.transparent : Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color1.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.black54,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildRotationControl() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFAF5FF),
            Color(0xFFFCE7F3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE9D5FF), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🔄 Rotation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7C3AED),
                ),
              ),
              Icon(Icons.rotate_right, size: 20, color: Color(0xFF7C3AED)),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Color(0xFF7C3AED),
              inactiveTrackColor: Color(0xFFE9D5FF),
              thumbColor: Colors.white,
              overlayColor: Color(0xFF7C3AED).withOpacity(0.2),
              trackHeight: 4,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _rotation,
              min: 0,
              max: math.pi * 2,
              onChanged: (value) {
                setState(() {
                  _rotation = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomControl() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEFF6FF),
            Color(0xFFDDEAFE),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFBFDBFE), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🔍 Zoom',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.zoom_out, size: 20, color: Color(0xFF3B82F6)),
                  const SizedBox(width: 8),
                  Icon(Icons.zoom_in, size: 20, color: Color(0xFF3B82F6)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Color(0xFF3B82F6),
              inactiveTrackColor: Color(0xFFBFDBFE),
              thumbColor: Colors.white,
              overlayColor: Color(0xFF3B82F6).withOpacity(0.2),
              trackHeight: 4,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _zoom,
              min: 0.5,
              max: 2.0,
              onChanged: (value) {
                setState(() {
                  _zoom = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF7C3AED).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _rotateShape,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Rotate',
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
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFEC4899).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _resetAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restart_alt, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Reset',
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
        ),
      ],
    );
  }
}

class Shape3DPainter extends CustomPainter {
  final String shape;
  final double rotation;
  final double zoom;

  Shape3DPainter({
    required this.shape,
    required this.rotation,
    required this.zoom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    switch (shape) {
      case 'cube':
        _drawCube(canvas, centerX, centerY);
        break;
      case 'sphere':
        _drawSphere(canvas, centerX, centerY);
        break;
      case 'pyramid':
        _drawPyramid(canvas, centerX, centerY);
        break;
      case 'torus':
        _drawTorus(canvas, centerX, centerY);
        break;
    }
  }

  void _drawCube(Canvas canvas, double centerX, double centerY) {
    final cubeSize = 80.0 * zoom;

    // Define cube vertices
    final vertices = [
      [-1.0, -1.0, -1.0], [1.0, -1.0, -1.0], [1.0, 1.0, -1.0], [-1.0, 1.0, -1.0],
      [-1.0, -1.0, 1.0], [1.0, -1.0, 1.0], [1.0, 1.0, 1.0], [-1.0, 1.0, 1.0],
    ];

    // Rotate vertices
    final rotated = vertices.map((v) {
      final x = v[0];
      final y = v[1];
      var z = v[2];

      final cosX = math.cos(rotation);
      final sinX = math.sin(rotation);
      final cosY = math.cos(rotation * 0.7);
      final sinY = math.sin(rotation * 0.7);

      // Rotate around Y axis
      var newX = x * cosY - z * sinY;
      var newZ = x * sinY + z * cosY;

      // Rotate around X axis
      var newY = y * cosX - newZ * sinX;
      newZ = y * sinX + newZ * cosX;

      return [newX, newY, newZ];
    }).toList();

    // Project to 2D
    final projected = rotated.map((v) {
      final perspective = 1 / (1 + v[2] * 0.2);
      return Offset(
        centerX + v[0] * cubeSize * perspective,
        centerY + v[1] * cubeSize * perspective,
      );
    }).toList();

    // Draw faces
    final faces = [
      [4, 5, 6, 7], // Front
      [0, 1, 2, 3], // Back
      [0, 1, 5, 4], // Bottom
      [2, 3, 7, 6], // Top
      [0, 3, 7, 4], // Left
      [1, 2, 6, 5], // Right
    ];

    final colors = [
      Color(0xFF8B5CF6).withOpacity(0.7),
      Color(0xFF3B82F6).withOpacity(0.5),
      Color(0xFFEC4899).withOpacity(0.6),
      Color(0xFF22C55E).withOpacity(0.6),
      Color(0xFFFB923C).withOpacity(0.6),
      Color(0xFFA855F7).withOpacity(0.6),
    ];

    for (var i = 0; i < faces.length; i++) {
      final face = faces[i];
      final path = Path();
      path.moveTo(projected[face[0]].dx, projected[face[0]].dy);
      for (var j = 1; j < face.length; j++) {
        path.lineTo(projected[face[j]].dx, projected[face[j]].dy);
      }
      path.close();

      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);

      final strokePaint = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(path, strokePaint);
    }
  }

  void _drawSphere(Canvas canvas, double centerX, double centerY) {
    final radius = 80.0 * zoom;
    final latitudes = 16;
    final longitudes = 24;

    final paint = Paint()
      ..color = Color(0xFF8B5CF6).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw latitude lines
    for (var lat = 0; lat <= latitudes; lat++) {
      final path = Path();
      final theta = (lat * math.pi) / latitudes;
      final sinTheta = math.sin(theta);
      final cosTheta = math.cos(theta);

      bool first = true;
      for (var lon = 0; lon <= longitudes; lon++) {
        final phi = (lon * 2 * math.pi) / longitudes;
        final sinPhi = math.sin(phi);
        final cosPhi = math.cos(phi);

        var x = cosPhi * sinTheta;
        final y = cosTheta;
        var z = sinPhi * sinTheta;

        // Rotate
        final cosY = math.cos(rotation);
        final sinY = math.sin(rotation);
        final newX = x * cosY - z * sinY;
        final newZ = x * sinY + z * cosY;

        final perspective = 1 / (1 + newZ * 0.2);
        final screenX = centerX + newX * radius * perspective;
        final screenY = centerY + y * radius * perspective;

        if (first) {
          path.moveTo(screenX, screenY);
          first = false;
        } else {
          path.lineTo(screenX, screenY);
        }
      }
      canvas.drawPath(path, paint);
    }

    // Draw longitude lines
    for (var lon = 0; lon <= longitudes; lon++) {
      final path = Path();
      final phi = (lon * 2 * math.pi) / longitudes;

      bool first = true;
      for (var lat = 0; lat <= latitudes; lat++) {
        final theta = (lat * math.pi) / latitudes;
        final sinTheta = math.sin(theta);
        final cosTheta = math.cos(theta);
        final sinPhi = math.sin(phi);
        final cosPhi = math.cos(phi);

        var x = cosPhi * sinTheta;
        final y = cosTheta;
        var z = sinPhi * sinTheta;

        // Rotate
        final cosY = math.cos(rotation);
        final sinY = math.sin(rotation);
        final newX = x * cosY - z * sinY;
        final newZ = x * sinY + z * cosY;

        final perspective = 1 / (1 + newZ * 0.2);
        final screenX = centerX + newX * radius * perspective;
        final screenY = centerY + y * radius * perspective;

        if (first) {
          path.moveTo(screenX, screenY);
          first = false;
        } else {
          path.lineTo(screenX, screenY);
        }
      }
      canvas.drawPath(path, paint);
    }

    // Draw gradient fill
    final gradient = ui.Gradient.radial(
      Offset(centerX, centerY),
      radius,
      [
        Color(0xFFEC4899).withOpacity(0.6),
        Color(0xFF8B5CF6).withOpacity(0.4),
        Color(0xFF3B82F6).withOpacity(0.2),
      ],
      [0.0, 0.5, 1.0],
    );

    final fillPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, centerY), radius * 0.9, fillPaint);
  }

  void _drawPyramid(Canvas canvas, double centerX, double centerY) {
    final pyramidSize = 100.0 * zoom;

    // Pyramid vertices
    final vertices = [
      [0.0, -1.5, 0.0],
      [-1.0, 0.5, 1.0],
      [1.0, 0.5, 1.0],
      [1.0, 0.5, -1.0],
      [-1.0, 0.5, -1.0],
    ];

    // Rotate vertices
    final rotated = vertices.map((v) {
      var x = v[0];
      var y = v[1];
      var z = v[2];

      final cosX = math.cos(rotation * 0.5);
      final sinX = math.sin(rotation * 0.5);
      final cosY = math.cos(rotation);
      final sinY = math.sin(rotation);

      // Rotate around Y axis
      var newX = x * cosY - z * sinY;
      var newZ = x * sinY + z * cosY;

      // Rotate around X axis
      var newY = y * cosX - newZ * sinX;
      newZ = y * sinX + newZ * cosX;

      return [newX, newY, newZ];
    }).toList();

    // Project to 2D
    final projected = rotated.map((v) {
      final perspective = 1 / (1 + v[2] * 0.2);
      return Offset(
        centerX + v[0] * pyramidSize * perspective,
        centerY + v[1] * pyramidSize * perspective,
      );
    }).toList();

    // Draw faces
    final faces = [
      [0, 1, 2],
      [0, 2, 3],
      [0, 3, 4],
      [0, 4, 1],
      [1, 2, 3, 4],
    ];

    final colors = [
      Color(0xFFFB923C).withOpacity(0.7),
      Color(0xFFEC4899).withOpacity(0.7),
      Color(0xFF8B5CF6).withOpacity(0.7),
      Color(0xFF22C55E).withOpacity(0.7),
      Color(0xFF3B82F6).withOpacity(0.6),
    ];

    for (var i = 0; i < faces.length; i++) {
      final face = faces[i];
      final path = Path();
      path.moveTo(projected[face[0]].dx, projected[face[0]].dy);
      for (var j = 1; j < face.length; j++) {
        path.lineTo(projected[face[j]].dx, projected[face[j]].dy);
      }
      path.close();

      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);

      final strokePaint = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(path, strokePaint);
    }
  }

  void _drawTorus(Canvas canvas, double centerX, double centerY) {
    final majorRadius = 70.0 * zoom;
    final minorRadius = 30.0 * zoom;
    final segments = 32;
    final sides = 16;

    final paint = Paint()
      ..color = Color(0xFF8B5CF6).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final vertices = <List<double>>[];

    for (var i = 0; i < segments; i++) {
      final theta = (i * 2 * math.pi) / segments;
      for (var j = 0; j < sides; j++) {
        final phi = (j * 2 * math.pi) / sides;

        var x = (majorRadius + minorRadius * math.cos(phi)) * math.cos(theta);
        var y = minorRadius * math.sin(phi);
        var z = (majorRadius + minorRadius * math.cos(phi)) * math.sin(theta);

        // Rotate
        final cosY = math.cos(rotation);
        final sinY = math.sin(rotation);
        final cosX = math.cos(rotation * 0.5);
        final sinX = math.sin(rotation * 0.5);

        var newX = x * cosY - z * sinY;
        var newZ = x * sinY + z * cosY;
        var newY = y * cosX - newZ * sinX;
        newZ = y * sinX + newZ * cosX;

        vertices.add([newX, newY, newZ]);
      }
    }

    // Draw segments
    for (var i = 0; i < segments; i++) {
      final path = Path();
      bool first = true;
      for (var j = 0; j <= sides; j++) {
        final idx = i * sides + (j % sides);
        final v = vertices[idx];
        final perspective = 1 / (1 + v[2] * 0.003);
        final screenX = centerX + v[0] * perspective;
        final screenY = centerY + v[1] * perspective;

        if (first) {
          path.moveTo(screenX, screenY);
          first = false;
        } else {
          path.lineTo(screenX, screenY);
        }
      }
      canvas.drawPath(path, paint);
    }

    // Draw sides
    for (var j = 0; j < sides; j++) {
      final path = Path();
      bool first = true;
      for (var i = 0; i <= segments; i++) {
        final idx = ((i % segments) * sides) + j;
        final v = vertices[idx];
        final perspective = 1 / (1 + v[2] * 0.003);
        final screenX = centerX + v[0] * perspective;
        final screenY = centerY + v[1] * perspective;

        if (first) {
          path.moveTo(screenX, screenY);
          first = false;
        } else {
          path.lineTo(screenX, screenY);
        }
      }
      canvas.drawPath(path, paint);
    }

    // Draw gradient overlay
    final gradient = ui.Gradient.radial(
      Offset(centerX, centerY),
      majorRadius + minorRadius,
      [
        Color(0xFFEC4899).withOpacity(0.3),
        Color(0xFF8B5CF6).withOpacity(0.2),
        Color(0xFF3B82F6).withOpacity(0.1),
      ],
      [0.0, 0.5, 1.0],
    );

    final fillPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX, centerY),
      (majorRadius + minorRadius) * 0.8,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}