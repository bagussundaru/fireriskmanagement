import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/assessment_data.dart';
import '../services/scoring_service.dart';
import '../services/pdf_service.dart';
import '../services/supabase_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/widgets.dart';
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

class _ResultScreenState extends State<ResultScreen> {
  bool _isSaving = false;
  bool _isExporting = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isHistory) {
      _saveToCloud();
    }
  }

  Future<void> _saveToCloud() async {
    setState(() => _isSaving = true);
    final success = await SupabaseService.saveAssessment(widget.assessment);
    if (success) {
      // Clean up the draft once successfully saved to backend
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
          const SnackBar(
            content: Text('PDF generated successfully!'),
            backgroundColor: AppTheme.riskLow,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: AppTheme.riskHigh,
          ),
        );
      }
    }
    if (mounted) setState(() => _isExporting = false);
  }

  @override
  Widget build(BuildContext context) {
    final categories = AssessmentData.getCategories();
    final recommendation = ScoringService.getRecommendation(
      widget.assessment.totalScore,
      widget.assessment.categoryScores,
    );

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Assessment Results'),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: !widget.isHistory,
        actions: [
          if (!widget.isHistory)
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.goldPrimary,
                    ),
                  ),
                ),
              )
            else if (_isSaved)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.cloud_done, color: AppTheme.riskLow),
              )
            else
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.cloud_off, color: AppTheme.textSecondary),
              ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Overall Score Card
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  const Text(
                    'Overall Fire Risk Assessment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.goldPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Powered by Fuzzy AHP Algorithm',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.goldPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ScoreCircle(score: widget.assessment.totalScore, size: 160),
                  const SizedBox(height: 24),
                  RiskBadge(riskLevel: widget.assessment.riskLevel),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Recommendations
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recommendations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    recommendation,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Follow-up Schedule',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (widget.assessment.riskLevel == 'HIGH')
                    const _BulletText('Immediate action required to address critical fire safety issues. Schedule follow-up assessment within 2 months.')
                  else if (widget.assessment.riskLevel == 'MEDIUM')
                    const _BulletText('Review and address identified issues within 30 days. Schedule next assessment within 6 months.')
                  else
                    const _BulletText('Maintain current safety standards. Schedule next regular assessment in 12 months.'),
                  
                  if (widget.assessment.riskLevel == 'HIGH')
                    const _BulletText('Implement critical corrections immediately.')
                  else if (widget.assessment.riskLevel == 'MEDIUM')
                    const _BulletText('Plan improvements for medium urgency items.'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Factory Info Card
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Factory Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow('Date', DateFormat('dd/MM/yyyy').format(widget.assessment.factoryInfo.assessmentDate)),
                  _InfoRow('Factory Name', widget.assessment.factoryInfo.factoryName),
                  _InfoRow('Factory Type', widget.assessment.factoryInfo.factoryType),
                  _InfoRow('Worker Count', widget.assessment.factoryInfo.workerCount),
                  _InfoRow('Assessor Name', widget.assessment.factoryInfo.assessorName),
                  _InfoRow('GM/Director', widget.assessment.factoryInfo.gmDirector),
                  
                  const SizedBox(height: 24),
                  Text(
                    '(${AssessmentData.getTotalQuestions()}/${AssessmentData.getTotalQuestions()} Questions Answered)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Categories Breakdown inside the Factory Info block logically
                  ...categories.map((category) {
                    final score = widget.assessment.categoryScores[category.id] ?? 0;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CategoryHeader(
                          code: category.code,
                          name: category.name,
                          weight: category.weight,
                          answeredCount: ScoringService.getCategoryAnsweredCount(category, widget.assessment.answers),
                          totalCount: category.totalQuestions,
                          score: score,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            children: category.subCategories.map((sub) {
                              final subScore = ScoringService.calculateSubCategoryScore(sub, widget.assessment.answers);
                              final answered = sub.questions.where((q) => widget.assessment.answers.containsKey(q.id)).length;
                              return ProgressBarWidget(
                                label: sub.name,
                                score: subScore,
                                trailing: '$answered/${sub.questions.length}',
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),
                ],
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
                child: ElevatedButton.icon(
                  onPressed: _isExporting ? null : _exportPdf,
                  icon: _isExporting 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.picture_as_pdf),
                  label: Text(_isExporting ? 'Exporting...' : 'Export PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F2C59), // Dark Blue styling from mockup
                  ),
                ),
              ),
              if (!widget.isHistory) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MainScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save & New'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A4D2E), // Dark Green styling from mockup
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontFamily: 'Roboto',
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;

  const _BulletText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
