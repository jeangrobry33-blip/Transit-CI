import 'package:flutter/material.dart';

/// Forme signature de Transit CI : un billet à encoche, comme un vrai
/// ticket de bus/car (deux demi-cercles creusés au milieu des bords gauche
/// et droit). Réservée à ce qui représente un trajet réellement achetable
/// (compagnie interurbaine, billet QR) — jamais une estimation VTC/taxi/
/// moto, qui garde un rectangle arrondi classique. Voir docs/DESIGN.md §4.
///
/// Usage : `Material(shape: const TicketShapeBorder(), clipBehavior:
/// Clip.antiAlias, child: ...)` pour que le ripple d'un InkWell respecte
/// aussi l'encoche.
class TicketShapeBorder extends ShapeBorder {
  const TicketShapeBorder({
    this.radius = 20,
    this.notchRadius = 9,
    this.side = BorderSide.none,
  });

  final double radius;
  final double notchRadius;
  final BorderSide side;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final base = Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final midY = rect.top + rect.height / 2;
    final notches = Path()
      ..addOval(Rect.fromCircle(center: Offset(rect.left, midY), radius: notchRadius))
      ..addOval(Rect.fromCircle(center: Offset(rect.right, midY), radius: notchRadius));
    return Path.combine(PathOperation.difference, base, notches);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    canvas.drawPath(getOuterPath(rect, textDirection: textDirection), side.toPaint());
  }

  @override
  ShapeBorder scale(double t) => TicketShapeBorder(
        radius: radius * t,
        notchRadius: notchRadius * t,
        side: side.scale(t),
      );
}

/// Ligne de perforation pointillée verticale, à placer au centre d'une
/// [TicketShapeBorder] pour marquer la séparation "souche" / "trajet" d'un
/// vrai billet. Purement décoratif : ne porte aucune information seule.
class TicketPerforation extends StatelessWidget {
  const TicketPerforation({super.key, this.color, this.height = double.infinity});

  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1,
      height: height,
      child: CustomPaint(
        painter: _DashedLinePainter(color ?? Theme.of(context).dividerColor),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashHeight = 4.0;
    const gap = 3.0;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dashHeight), paint);
      y += dashHeight + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) => oldDelegate.color != color;
}
