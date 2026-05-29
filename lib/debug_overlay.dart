import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // ✅ FIX 1: Import necesario

class TouchDebugOverlay extends StatefulWidget {
  final Widget child;
  const TouchDebugOverlay({required this.child, super.key});

  @override
  State<TouchDebugOverlay> createState() => _TouchDebugOverlayState();
}

class _TouchDebugOverlayState extends State<TouchDebugOverlay> {
  final Map<int, Offset> _touches = {};

  void _log(PointerEvent e, String type) {
    if (e.kind == PointerDeviceKind.touch) {
      setState(() {
        type == 'UP' ? _touches.remove(e.pointer) : _touches[e.pointer] = e.position;
      });
      // ✅ FIX 2: Formatear Offset correctamente
      final pos = '(${e.position.dx.toStringAsFixed(1)}, ${e.position.dy.toStringAsFixed(1)})';
      debugPrint('[TOUCH $type] ID:${e.pointer} GLOBAL:$pos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (e) => _log(e, 'DOWN'),
            onPointerMove: (e) => _log(e, 'MOVE'),
            onPointerUp: (e) => _log(e, 'UP'),
            child: IgnorePointer(
              child: CustomPaint(painter: _TouchPainter(_touches)),
            ),
          ),
        ),
      ],
    );
  }
}

class _TouchPainter extends CustomPainter {
  final Map<int, Offset> touches;
  _TouchPainter(this.touches);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellowAccent.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    for (final offset in touches.values) {
      canvas.drawCircle(offset, 18, paint);
      canvas.drawCircle(offset, 18, Paint()..color = Colors.white..style = PaintingStyle.stroke);
    }
  }
  @override
  bool shouldRepaint(covariant _TouchPainter oldDelegate) => true;
}