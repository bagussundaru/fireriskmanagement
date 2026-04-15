import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

export 'fire_particles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Glass Card (with hover lift)
// ─────────────────────────────────────────────────────────────────────────────
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final List<Color>? gradientColors;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.gradientColors,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _ctrl.forward() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _ctrl.reverse();
              widget.onTap!();
            }
          : null,
      onTapCancel: widget.onTap != null ? () => _ctrl.reverse() : null,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          padding: widget.padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: widget.gradientColors != null
                ? LinearGradient(
                    colors: widget.gradientColors!,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.surfaceLight.withValues(alpha: 0.7),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Score Circle (count-up + spin-in)
// ─────────────────────────────────────────────────────────────────────────────
class ScoreCircle extends StatefulWidget {
  final double score;
  final double size;
  final double strokeWidth;

  const ScoreCircle({
    super.key,
    required this.score,
    this.size = 150,
    this.strokeWidth = 14,
  });

  @override
  State<ScoreCircle> createState() => _ScoreCircleState();
}

class _ScoreCircleState extends State<ScoreCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progressAnim;
  late Animation<double> _countAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _progressAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _countAnim = Tween<double>(begin: 0, end: widget.score)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getScoreColor(widget.score);
    final s = widget.size;
    final sw = widget.strokeWidth;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final current = _countAnim.value;
        return SizedBox(
          width: s,
          height: s,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow
              Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2 * _progressAnim.value),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
              // Track
              SizedBox(
                width: s,
                height: s,
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: sw,
                  color: AppTheme.surfaceLight,
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Progress
              SizedBox(
                width: s,
                height: s,
                child: CircularProgressIndicator(
                  value: (current / 100) * _progressAnim.value,
                  strokeWidth: sw,
                  color: color,
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Center content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${current.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: s * 0.19,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Score',
                    style: TextStyle(
                      fontSize: s * 0.1,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Risk Badge
// ─────────────────────────────────────────────────────────────────────────────
class RiskBadge extends StatefulWidget {
  final String riskLevel;

  const RiskBadge({super.key, required this.riskLevel});

  @override
  State<RiskBadge> createState() => _RiskBadgeState();
}

class _RiskBadgeState extends State<RiskBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.getRiskGradient(widget.riskLevel);

    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              '${widget.riskLevel} RISK',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Progress Bar
// ─────────────────────────────────────────────────────────────────────────────
class ProgressBarWidget extends StatefulWidget {
  final String label;
  final double score;
  final String? trailing;

  const ProgressBarWidget({
    super.key,
    required this.label,
    required this.score,
    this.trailing,
  });

  @override
  State<ProgressBarWidget> createState() => _ProgressBarWidgetState();
}

class _ProgressBarWidgetState extends State<ProgressBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _widthAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _widthAnim = Tween<double>(begin: 0, end: widget.score / 100)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getScoreColor(widget.score);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 13),
                ),
              ),
              if (widget.trailing != null)
                Text(
                  widget.trailing!,
                  style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 8,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: AnimatedBuilder(
                    animation: _widthAnim,
                    builder: (_, __) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _widthAnim.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color.withValues(alpha: 0.8), color],
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 46,
                child: Text(
                  '${widget.score.toStringAsFixed(1)}%',
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Header (with gradient bar)
// ─────────────────────────────────────────────────────────────────────────────
class CategoryHeader extends StatelessWidget {
  final String code;
  final String name;
  final double weight;
  final int answeredCount;
  final int totalCount;
  final double score;

  const CategoryHeader({
    super.key,
    required this.code,
    required this.name,
    required this.weight,
    required this.answeredCount,
    required this.totalCount,
    required this.score,
  });

  static const Map<String, Color> _codeColors = {
    'A': AppTheme.goldPrimary,
    'B': Color(0xFF4FC3F7),
    'C': Color(0xFF00C897),
    'D': Color(0xFF9C6FDE),
  };

  @override
  Widget build(BuildContext context) {
    final riskLevel = score >= 90 ? 'LOW' : score >= 70 ? 'MEDIUM' : 'HIGH';
    final riskColor = AppTheme.getRiskColor(riskLevel);
    final titleColor = _codeColors[code] ?? AppTheme.goldPrimary;

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: titleColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Code badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [titleColor.withValues(alpha: 0.3), titleColor.withValues(alpha: 0.1)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: titleColor.withValues(alpha: 0.4)),
                  ),
                  child: Center(
                    child: Text(code,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: titleColor)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: titleColor)),
                      const SizedBox(height: 4),
                      Text(
                        'Answered: $answeredCount/$totalCount • Weight: ${weight.toStringAsFixed(1)}%',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${score.toStringAsFixed(1)}%',
                      style: TextStyle(
                          color: riskColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(riskLevel,
                        style: TextStyle(color: riskColor, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          // Gradient progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: score / 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: AppTheme.getRiskGradient(riskLevel)),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
