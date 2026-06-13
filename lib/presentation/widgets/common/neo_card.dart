import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// A soft, raised "3D" card built from dual shadows on the light canvas.
/// This is the primary surface used across the redesigned app.
class NeoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;
  final Gradient? gradient;
  final List<BoxShadow>? shadows;
  final Border? border;
  final VoidCallback? onTap;

  const NeoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.paddingM),
    this.margin,
    this.radius = AppDimensions.radiusXL,
    this.color,
    this.gradient,
    this.shadows,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppColors.backgroundCard) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadows ?? AppShadows.soft,
        border: border,
      ),
      child: child,
    );

    if (onTap == null) return Container(margin: margin, child: card);

    return Container(
      margin: margin,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          splashColor: AppColors.primary.withValues(alpha: 0.06),
          highlightColor: AppColors.primary.withValues(alpha: 0.03),
          child: card,
        ),
      ),
    );
  }
}

/// A button/surface that visually presses down (3D tactile feedback).
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _down = true),
      onTapUp: widget.onTap == null ? null : (_) => setState(() => _down = false),
      onTapCancel: widget.onTap == null ? null : () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// A floating gradient CTA with a colored glow — the hero "3D" button.
class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final List<Color> gradient;
  final double height;
  final double? width;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.gradient = AppColors.primaryGradient,
    this.height = AppDimensions.buttonHeight,
    this.width,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          boxShadow: AppShadows.glow(gradient.first),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// A circular gradient avatar showing initials (or an icon fallback).
class GradientAvatar extends StatelessWidget {
  final String? name;
  final double size;
  final IconData fallbackIcon;
  final List<Color> gradient;

  const GradientAvatar({
    super.key,
    this.name,
    this.size = 44,
    this.fallbackIcon = Icons.person,
    this.gradient = AppColors.primaryGradient,
  });

  String get _initials {
    final n = (name ?? '').trim();
    if (n.isEmpty) return '';
    final parts = n.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: AppShadows.glow(gradient.first),
      ),
      child: _initials.isEmpty
          ? Icon(fallbackIcon, color: Colors.white, size: size * 0.5)
          : Text(
              _initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.36,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}

/// A pill chip with a tinted background (used for tags, salary, type, etc.).
class TintChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;

  const TintChip({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
