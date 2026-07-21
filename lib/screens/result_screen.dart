import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/assessment_data.dart';
import '../services/scoring_service.dart';
import '../services/fuzzy_logic_service.dart';
import '../services/pdf_service.dart';
import '../services/supabase_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/widgets.dart';
import '../widgets/ai_widgets.dart';
import 'main_screen.dart';

class ResultScreen extends StatefulWidget {
  final Assessment assessment;
  final bool isHistory;

  const ResultScreen({
    super.key,
    required this.assessment,
    this.isHistory = false,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  bool _isSaving = false;
  bool _isExporting = false;
  bool _isSaved = false;

  late AnimationController _entryController;
  late List<AnimationController> _itemControllers;

  @override
  void initState() {
    super.initState();

    if (!widget.isHistory) _saveToCloud();

    _entryController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();

    // Need 5 item controllers for: score(0), AI(1), recs(2), factory(3), categories(4)
    _itemControllers = List.generate(
      5,
      (i) => AnimationController(
          vsync: this, duration: const Duration(milliseconds: 500)),
    );
    for (int i = 0; i < _itemControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 300 + i * 150), () {
        if (mounted) _itemControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    for (final c in _itemControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveToCloud() async {
    setState(() => _isSaving = true);
    final success =
        await SupabaseService.saveAssessment(widget.assessment);
    if (success) {
      await LocalStorageService.deleteDraft(widget.assessment.id);
    }
    if (mounted) {
      setState(() {
        _isSaving = false;
        _isSaved = success;
      });
    }
  }

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);
    try {
      await PdfService.shareReport(widget.assessment);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('PDF generated successfully!'),
              ],
            ),
            backgroundColor: AppTheme.riskLow,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.riskHigh,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    if (mounted) setState(() => _isExporting = false);
  }

  Widget _staggered(int index, Widget child) {
    final anim = CurvedAnimation(
        parent: _itemControllers[index], curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
            .animate(anim),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = AssessmentData.getCategories(industryType: widget.assessment.factoryInfo.industryType);
    final recommendation = ScoringService.getRecommendation(
      widget.assessment.totalScore,
      widget.assessment.categoryScores,
    );
    final riskColors =
        AppTheme.getRiskGradient(widget.assessment.riskLevel);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Assessment Results'),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: !widget.isHistory,
        actions: [
          if (!widget.isHistory)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _isSaving
                  ? const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.goldPrimary,
                        ),
                      ),
                    )
                  : Icon(
                      _isSaved ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                      color: _isSaved ? AppTheme.riskLow : AppTheme.textSecondary,
                    ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Score Hero Card ──────────────────────────────────────────
            _staggered(
              0,
              GlassCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.analytics_rounded,
                            color: AppTheme.goldPrimary, size: 18),
                        const SizedBox(width: 8),
                        const Text('Overall Fire Risk Assessment',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.goldPrimary.withValues(alpha: 0.2),
                            AppTheme.goldPrimary.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.goldPrimary.withValues(alpha: 0.4),
                          width: 0.5,
                        ),
                      ),
                      child: const Text(
                        '✦ Powered by Fuzzy AHP Algorithm',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.goldPrimary),
                      ),
                    ),
                    const SizedBox(height: 28),
                    ScoreCircle(
                        score: widget.assessment.totalScore, size: 170),
                    const SizedBox(height: 24),
                    RiskBadge(riskLevel: widget.assessment.riskLevel),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── AI Computation Report Card ───────────────────────────
            Builder(builder: (context) {
              final scores = ScoringService.getCategoryScores(widget.assessment.answers, industryType: widget.assessment.factoryInfo.industryType);
              final fuzzy = FuzzyLogicService.evaluate(
                scores['A'] ?? 0,
                scores['B'] ?? 0,
                scores['C'] ?? 0,
                scores['D'] ?? 0,
              );
              return _staggered(
                1,
                AIAnalysisCard(
                  danger: fuzzy.vectorB[FuzzyLinguistic.DANGER] ?? 0,
                  warning: fuzzy.vectorB[FuzzyLinguistic.WARNING] ?? 0,
                  safe: fuzzy.vectorB[FuzzyLinguistic.SAFE] ?? 0,
                  confidence: fuzzy.confidence,
                  categoryScores: scores,
                ),
              );
            }),
            const SizedBox(height: 16),

            // ── Recommendations ─────────────────────────────────────────
            _staggered(
              2,
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                        Icons.lightbulb_outline_rounded, 'Recommendations',
                        color: AppTheme.riskMedium),
                    const SizedBox(height: 12),
                    Text(recommendation,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            height: 1.6)),
                    const SizedBox(height: 20),
                    _SectionTitle(
                        Icons.calendar_today_rounded, 'Follow-up Schedule',
                        color: AppTheme.accentBlue),
                    const SizedBox(height: 12),
                    _timelineBullet(context),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Factory Info ─────────────────────────────────────────────
            _staggered(
              3,
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(Icons.factory_rounded, 'Factory Information',
                        color: AppTheme.accentPurple),
                    const SizedBox(height: 16),
                    _ModernInfoRow('Date',
                        DateFormat('dd/MM/yyyy').format(widget.assessment.factoryInfo.assessmentDate),
                        Icons.calendar_today_outlined),
                    _ModernInfoRow('Factory Name',
                        widget.assessment.factoryInfo.factoryName,
                        Icons.business_rounded),
                    _ModernInfoRow('Factory Type',
                        widget.assessment.factoryInfo.factoryType,
                        Icons.category_outlined),
                    _ModernInfoRow('Worker Count',
                        widget.assessment.factoryInfo.workerCount,
                        Icons.people_outline_rounded),
                    _ModernInfoRow('Assessor',
                        widget.assessment.factoryInfo.assessorName,
                        Icons.person_outline_rounded),
                    _ModernInfoRow('GM/Director',
                        widget.assessment.factoryInfo.gmDirector,
                        Icons.manage_accounts_outlined),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Categories ───────────────────────────────────────────────
            _staggered(
              4,
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(Icons.bar_chart_rounded, 'Category Breakdown',
                        color: AppTheme.riskLow),
                    Text(
                      '${AssessmentData.getTotalQuestions(industryType: widget.assessment.factoryInfo.industryType)}/${AssessmentData.getTotalQuestions(industryType: widget.assessment.factoryInfo.industryType)} Questions Answered',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ...categories.map((category) {
                      final score =
                          widget.assessment.categoryScores[category.id] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CategoryHeader(
                              code: category.code,
                              name: category.name,
                              weight: category.weight,
                              answeredCount: ScoringService
                                  .getCategoryAnsweredCount(
                                      category, widget.assessment.answers),
                              totalCount: category.totalQuestions,
                              score: score,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                children: category.subCategories
                                    .map((sub) {
                                  final subScore =
                                      ScoringService.calculateSubCategoryScore(
                                          sub, widget.assessment.answers);
                                  final answered = sub.questions
                                      .where((q) => widget
                                          .assessment.answers
                                          .containsKey(q.id))
                                      .length;
                                  return ProgressBarWidget(
                                    label: sub.name,
                                    score: subScore,
                                    trailing:
                                        '$answered/${sub.questions.length}',
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: _GradientButton(
                  onPressed: _isExporting ? null : _exportPdf,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A3A6B), Color(0xFF0F2C59)],
                  ),
                  icon: _isExporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.picture_as_pdf_rounded,
                          color: Colors.white, size: 18),
                  label: _isExporting ? 'Exporting...' : 'Export PDF',
                ),
              ),
              if (!widget.isHistory) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _GradientButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const MainScreen(),
                          transitionsBuilder: (_, anim, __, child) =>
                              FadeTransition(opacity: anim, child: child),
                        ),
                        (route) => false,
                      );
                    },
                    gradient: const LinearGradient(
                      colors: [Color(0xFF006A3E), Color(0xFF004D2E)],
                    ),
                    icon: const Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 18),
                    label: 'Save & New',
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _timelineBullet(BuildContext context) {
    final level = widget.assessment.riskLevel;
    final items = <String>[
      if (level == 'HIGH') ...[
        'Immediate action required on all critical items.',
        'Re-audit within 2 months mandatory.',
        'Brief senior management immediately.',
      ] else if (level == 'MEDIUM') ...[
        'Address identified issues within 30 days.',
        'Schedule next assessment in 6 months.',
        'Monitor progress weekly.',
      ] else ...[
        'Maintain current safety standards.',
        'Next regular assessment in 12 months.',
        'Document compliance evidence.',
      ]
    ];

    return Column(
      children: items.asMap().entries.map((e) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.getRiskColor(level),
                    shape: BoxShape.circle,
                  ),
                ),
                if (e.key < items.length - 1)
                  Container(
                    width: 2,
                    height: 28,
                    color: AppTheme.getRiskColor(level)
                        .withValues(alpha: 0.3),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  e.value,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      height: 1.4),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// ─── Helpers ───────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionTitle(this.icon, this.title, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}

class _ModernInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ModernInfoRow(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Text('$label: ',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final LinearGradient gradient;
  final Widget icon;
  final String label;

  const _GradientButton({
    required this.onPressed,
    required this.gradient,
    required this.icon,
    required this.label,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => _ctrl.forward() : null,
      onTapUp: enabled
          ? (_) {
              _ctrl.reverse();
              widget.onPressed!();
            }
          : null,
      onTapCancel: enabled ? () => _ctrl.reverse() : null,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: widget.gradient.colors.first
                            .withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.icon,
                const SizedBox(width: 8),
                Text(widget.label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
