import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AI Brain / Neural Network Visualizer  (Home Screen hero)
// ─────────────────────────────────────────────────────────────────────────────
class AIBrainWidget extends StatefulWidget {
  final double size;
  const AIBrainWidget({super.key, this.size = 220});

  @override
  State<AIBrainWidget> createState() => _AIBrainWidgetState();
}

class _AIBrainWidgetState extends State<AIBrainWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _orbCtrl;
  late AnimationController _nodeCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _orbCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    _nodeCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _orbCtrl.dispose();
    _nodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseCtrl, _orbCtrl, _nodeCtrl]),
      builder: (_, __) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _NeuralNetworkPainter(
            pulse: _pulseCtrl.value,
            orbit: _orbCtrl.value,
            node: _nodeCtrl.value,
          ),
          child: SizedBox(width: widget.size, height: widget.size),
        );
      },
    );
  }
}

class _NeuralNetworkPainter extends CustomPainter {
  final double pulse;
  final double orbit;
  final double node;

  _NeuralNetworkPainter({
    required this.pulse,
    required this.orbit,
    required this.node,
  });

  static const List<List<Offset>> _relativeNodes = [
    // Input layer (left)
    [Offset(0.15, 0.25), Offset(0.15, 0.50), Offset(0.15, 0.75)],
    // Hidden layer 1
    [Offset(0.38, 0.18), Offset(0.38, 0.40), Offset(0.38, 0.62), Offset(0.38, 0.82)],
    // Hidden layer 2
    [Offset(0.62, 0.25), Offset(0.62, 0.50), Offset(0.62, 0.75)],
    // Output (right)
    [Offset(0.85, 0.38), Offset(0.85, 0.62)],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final layers = _relativeNodes.map((layer) =>
      layer.map((o) => Offset(o.dx * size.width, o.dy * size.height)).toList(),
    ).toList();

    // ── Draw connections ──────────────────────────────────────────────────
    for (int l = 0; l < layers.length - 1; l++) {
      for (final src in layers[l]) {
        for (final dst in layers[l + 1]) {
          final t = (math.sin((orbit * math.pi * 2) + src.dy * 0.02) + 1) / 2;
          final alpha = 0.08 + t * 0.25;
          final linePaint = Paint()
            ..color = AppTheme.goldPrimary.withValues(alpha: alpha)
            ..strokeWidth = 0.8
            ..style = PaintingStyle.stroke;
          canvas.drawLine(src, dst, linePaint);

          // Traveling signal dot
          if (t > 0.6) {
            final signalT = (t - 0.6) / 0.4;
            final signalPos = Offset.lerp(src, dst, signalT)!;
            final signalPaint = Paint()
              ..color = AppTheme.goldLight.withValues(alpha: 0.9 * (1 - signalT))
              ..style = PaintingStyle.fill;
            canvas.drawCircle(signalPos, 2.5, signalPaint);
          }
        }
      }
    }

    // ── Draw nodes ────────────────────────────────────────────────────────
    const layerColors = [
      Color(0xFF4FC3F7),   // input  - blue
      AppTheme.goldPrimary, // hidden1 - orange
      Color(0xFF9C6FDE),   // hidden2 - purple
      Color(0xFF00C897),   // output  - green
    ];

    int layerIdx = 0;
    for (final layer in layers) {
      final baseColor = layerColors[layerIdx];
      int nodeIdx = 0;
      for (final pos in layer) {
        final activation = (math.sin(node * math.pi * 2 + layerIdx * 1.3 + nodeIdx * 0.9) + 1) / 2;

        // Glow ring
        final glowPaint = Paint()
          ..color = baseColor.withValues(alpha: 0.15 + activation * 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(pos, 14, glowPaint);

        // Node fill
        final fillPaint = Paint()
          ..color = baseColor.withValues(alpha: 0.3 + activation * 0.5)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 8, fillPaint);

        // Node border
        final borderPaint = Paint()
          ..color = baseColor.withValues(alpha: 0.8)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(pos, 8, borderPaint);

        nodeIdx++;
      }
      layerIdx++;
    }

    // ── Central glow overlay ──────────────────────────────────────────────
    final center = Offset(size.width / 2, size.height / 2);
    final glowRadius = size.width * (0.3 + pulse * 0.05);
    final overlayPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.goldPrimary.withValues(alpha: 0.07 + pulse * 0.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: glowRadius));
    canvas.drawCircle(center, glowRadius, overlayPaint);
  }

  @override
  bool shouldRepaint(_NeuralNetworkPainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Fuzzy Live Meter  (used in Assessment screen — real-time AI status)
// ─────────────────────────────────────────────────────────────────────────────
class FuzzyLiveMeter extends StatefulWidget {
  final double danger;
  final double warning;
  final double safe;
  final double confidence;

  const FuzzyLiveMeter({
    super.key,
    required this.danger,
    required this.warning,
    required this.safe,
    required this.confidence,
  });

  @override
  State<FuzzyLiveMeter> createState() => _FuzzyLiveMeterState();
}

class _FuzzyLiveMeterState extends State<FuzzyLiveMeter>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF101428), Color(0xFF0D0F1A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.goldPrimary.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, child) => Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.goldPrimary,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.goldPrimary
                            .withValues(alpha: _pulseAnim.value),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'AI FUZZY ENGINE  •  LIVE',
                style: TextStyle(
                  color: AppTheme.goldPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              _ConfidenceBadge(confidence: widget.confidence),
            ],
          ),
          const SizedBox(height: 12),

          // Membership bars
          _MembershipBar(
            label: 'DANGER',
            value: widget.danger,
            color: AppTheme.riskHigh,
            icon: Icons.warning_rounded,
          ),
          const SizedBox(height: 6),
          _MembershipBar(
            label: 'WARNING',
            value: widget.warning,
            color: AppTheme.riskMedium,
            icon: Icons.error_outline_rounded,
          ),
          const SizedBox(height: 6),
          _MembershipBar(
            label: 'SAFE',
            value: widget.safe,
            color: AppTheme.riskLow,
            icon: Icons.verified_rounded,
          ),
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final double confidence;
  const _ConfidenceBadge({required this.confidence});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.3)),
      ),
      child: Text(
        'conf. ${confidence.toStringAsFixed(0)}%',
        style: const TextStyle(
            color: AppTheme.accentBlue,
            fontSize: 10,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _MembershipBar extends StatelessWidget {
  final String label;
  final double value; // 0.0 to 1.0
  final Color color;
  final IconData icon;

  const _MembershipBar({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).clamp(0.0, 100.0);
    return Row(
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 6),
        SizedBox(
          width: 56,
          child: Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      color.withValues(alpha: 0.6),
                      color,
                    ]),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                          color: color.withValues(alpha: 0.5), blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            '${pct.toStringAsFixed(0)}%',
            textAlign: TextAlign.right,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Analysis Card  (Result screen — full decomposition)
// ─────────────────────────────────────────────────────────────────────────────
class AIAnalysisCard extends StatefulWidget {
  /// Fuzzy membership vector B
  final double danger;
  final double warning;
  final double safe;
  final double confidence;

  /// Category raw scores (A,B,C,D)
  final Map<String, double> categoryScores;

  const AIAnalysisCard({
    super.key,
    required this.danger,
    required this.warning,
    required this.safe,
    required this.confidence,
    required this.categoryScores,
  });

  @override
  State<AIAnalysisCard> createState() => _AIAnalysisCardState();
}

class _AIAnalysisCardState extends State<AIAnalysisCard>
    with TickerProviderStateMixin {
  late AnimationController _scanCtrl;
  late AnimationController _entryCtrl;
  bool _expanded = false;

  static const _weights = {'A': 0.150, 'B': 0.380, 'C': 0.270, 'D': 0.200};
  static const _categoryLabels = {
    'A': 'Legal / Compliance',
    'B': 'Prevention System',
    'C': 'Protection System',
    'D': 'Evacuation System',
  };

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0E1525), Color(0xFF0A0E1A)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.goldPrimary.withValues(alpha: 0.35),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.goldPrimary.withValues(alpha: 0.08),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ───────────────────────────────────────────────────
            _buildHeader(),

            // ── Fuzzy Membership visualization ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SubLabel('Fuzzy Membership Vector  B = W · R'),
                  const SizedBox(height: 10),
                  _BigMembershipBar(
                      label: 'DANGER', value: widget.danger,
                      color: AppTheme.riskHigh),
                  const SizedBox(height: 8),
                  _BigMembershipBar(
                      label: 'WARNING', value: widget.warning,
                      color: AppTheme.riskMedium),
                  const SizedBox(height: 8),
                  _BigMembershipBar(
                      label: 'SAFE', value: widget.safe,
                      color: AppTheme.riskLow),
                  const SizedBox(height: 16),

                  // Confidence
                  Row(
                    children: [
                      const Icon(Icons.psychology_rounded,
                          color: AppTheme.accentBlue, size: 16),
                      const SizedBox(width: 6),
                      const Text('AI Confidence',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12)),
                      const Spacer(),
                      Text(
                        '${widget.confidence.toStringAsFixed(1)}%',
                        style: const TextStyle(
                            color: AppTheme.accentBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: widget.confidence / 100,
                      minHeight: 4,
                      backgroundColor:
                          AppTheme.accentBlue.withValues(alpha: 0.15),
                      valueColor:
                          const AlwaysStoppedAnimation(AppTheme.accentBlue),
                    ),
                  ),
                ],
              ),
            ),

            // ── Expand/collapse: AHP weights ──────────────────────────────
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_tree_rounded,
                        color: AppTheme.goldPrimary, size: 16),
                    const SizedBox(width: 8),
                    const Text('AHP Eigenvalue Weights  →  W vector',
                        style: TextStyle(
                            color: AppTheme.goldPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.expand_more,
                          color: AppTheme.goldPrimary, size: 18),
                    ),
                  ],
                ),
              ),
            ),

            // Expandable AHP section
            AnimatedSize(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              child: _expanded
                  ? _buildAHPSection()
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      child: Row(
        children: [
          // Scan animation icon
          AnimatedBuilder(
            animation: _scanCtrl,
            builder: (_, __) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.goldPrimary.withValues(alpha: 0.12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.goldPrimary.withValues(
                              alpha: 0.15 +
                                  0.15 *
                                      math.sin(
                                          _scanCtrl.value * math.pi * 2)),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.memory_rounded,
                        color: AppTheme.goldPrimary, size: 22),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI COMPUTATION REPORT',
                style: TextStyle(
                  color: AppTheme.goldPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Hybrid AHP-Fuzzy Logic · Sugeno Defuzz.',
                style: TextStyle(
                    color: AppTheme.textSecondary.withValues(alpha: 0.8),
                    fontSize: 10),
              ),
            ],
          ),
          const Spacer(),
          // Animated scan line
          AnimatedBuilder(
            animation: _scanCtrl,
            builder: (_, __) => _MiniRadarPainter(t: _scanCtrl.value),
          ),
        ],
      ),
    );
  }

  Widget _buildAHPSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SubLabel('AHP Pairwise Eigenvector Weights (CR < 0.1)'),
          const SizedBox(height: 12),
          ..._weights.entries.map((e) {
            final score = widget.categoryScores[e.key] ?? 0;
            final weightedContrib = (e.value * score / 100) * 100;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppTheme.goldPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color:
                                  AppTheme.goldPrimary.withValues(alpha: 0.4)),
                        ),
                        child: Center(
                          child: Text(e.key,
                              style: const TextStyle(
                                  color: AppTheme.goldPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _categoryLabels[e.key]!,
                          style: const TextStyle(
                              color: AppTheme.textPrimary, fontSize: 12),
                        ),
                      ),
                      Text(
                        'w=${(e.value * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                            color: AppTheme.goldPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const SizedBox(width: 30),
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            // Weight bar
                            FractionallySizedBox(
                              widthFactor: e.value,
                              child: Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  color: AppTheme.goldPrimary
                                      .withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            // Score contribution
                            AnimatedFractionallySizedBox(
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              widthFactor:
                                  (weightedContrib / 100).clamp(0.0, 1.0),
                              child: Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.goldPrimary
                                          .withValues(alpha: 0.7),
                                      AppTheme.goldPrimary,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.goldPrimary
                                          .withValues(alpha: 0.5),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${score.toStringAsFixed(0)}%',
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const Divider(color: AppTheme.surfaceLight, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 12, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Consistency Ratio (CR) < 0.1 → weights validated',
                style: TextStyle(
                    color: AppTheme.textSecondary.withValues(alpha: 0.7),
                    fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubLabel extends StatelessWidget {
  final String text;
  const _SubLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          color: AppTheme.textSecondary.withValues(alpha: 0.8),
          fontSize: 10,
          letterSpacing: 0.5,
          fontFamily: 'monospace'),
    );
  }
}

class _BigMembershipBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _BigMembershipBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5)),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 14,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [color.withValues(alpha: 0.7), color]),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                          color: color.withValues(alpha: 0.5), blurRadius: 6),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${(value * 100).toStringAsFixed(1)}%',
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Mini animated radar indicator for the AI card header
class _MiniRadarPainter extends StatelessWidget {
  final double t;
  const _MiniRadarPainter({required this.t});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(36, 36),
      painter: _RadarPainterImpl(t: t),
    );
  }
}

class _RadarPainterImpl extends CustomPainter {
  final double t;
  const _RadarPainterImpl({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Background circle
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = AppTheme.goldPrimary.withValues(alpha: 0.08),
    );

    // Ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppTheme.goldPrimary.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Inner ring
    canvas.drawCircle(
      center,
      radius * 0.6,
      Paint()
        ..color = AppTheme.goldPrimary.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Sweep
    final sweepAngle = t * 2 * math.pi;
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          AppTheme.goldPrimary.withValues(alpha: 0.5),
        ],
        startAngle: sweepAngle - 0.8,
        endAngle: sweepAngle,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, sweepPaint);

    // Dot on sweep tip
    final tipX = center.dx + radius * math.cos(sweepAngle);
    final tipY = center.dy + radius * math.sin(sweepAngle);
    canvas.drawCircle(
      Offset(tipX, tipY),
      2.5,
      Paint()..color = AppTheme.goldPrimary,
    );
  }

  @override
  bool shouldRepaint(_RadarPainterImpl old) => old.t != t;
}
