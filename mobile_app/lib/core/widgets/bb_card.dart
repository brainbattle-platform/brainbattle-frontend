import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/theme/palette.dart';
import '../../core/theme/tokens.dart';

class BBCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final VoidCallback? onTap;

  const BBCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(BBSpacing.lg),
    this.margin = const EdgeInsets.symmetric(vertical: BBSpacing.sm),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BBRadii.xl),
        boxShadow: BBShadows.neon,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x1AFFFFFF),
            Color(0x0DFFFFFF),
          ],
        ),
        border: GradientBoxBorder(
          gradient: const LinearGradient(colors: [BBPalette.pink, BBPalette.purple]),
          width: BBTokens.hairline,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(BBRadii.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BBRadii.xl),
        child: card,
      );
    }
    return card;
  }
}

// Gradient border helper (no external package)
class GradientBoxBorder extends BoxBorder {
  const GradientBoxBorder({required this.gradient, this.width = 1.0});

  final Gradient gradient;
  final double width;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  // BoxBorder abstract members
  @override
  bool get isUniform => true;

  // We return transparent sides; actual drawing is in paint()
  @override
  BorderSide get top    => BorderSide(width: width, color: Colors.transparent);
  @override
  // ignore: override_on_non_overriding_member
  BorderSide get right  => BorderSide(width: width, color: Colors.transparent);
  @override
  BorderSide get bottom => BorderSide(width: width, color: Colors.transparent);
  @override
  // ignore: override_on_non_overriding_member
  BorderSide get left   => BorderSide(width: width, color: Colors.transparent);

  // ShapeBorder abstract member
  @override
  BoxBorder scale(double t) =>
      GradientBoxBorder(gradient: gradient, width: width * t);

  Paint _paint(Rect rect, TextDirection? textDirection) {
    final Shader shader = gradient.createShader(rect);
    return Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final paint = _paint(rect, textDirection);
    if (shape == BoxShape.circle) {
      canvas.drawOval(rect.deflate(width / 2), paint);
    } else {
      final rrect =
          (borderRadius ?? BorderRadius.zero).toRRect(rect).deflate(width / 2);
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) => this;

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) => this;
}
