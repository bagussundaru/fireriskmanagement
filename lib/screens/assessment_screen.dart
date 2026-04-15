import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/assessment_data.dart';
import '../services/scoring_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/widgets.dart';
import 'result_screen.dart';

class AssessmentScreen extends StatefulWidget {
  final FactoryInfo factoryInfo;
  final String? draftId;

  const AssessmentScreen({
    super.key, 
    required this.factoryInfo,
    this.draftId,
  });

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final Map<String, Answer> _answers = {};
  late List<Category> _categories;
  int _currentCategoryIndex = 0;
  late String _assessmentId;

  @override
  void initState() {
    super.initState();
    _categories = AssessmentData.getCategories(widget.factoryInfo.factoryType);
    _assessmentId = widget.draftId ?? DateTime.now().millisecondsSinceEpoch.toString();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    if (widget.draftId != null) {
      final drafts = await LocalStorageService.getDrafts();
      final currentDraft = drafts.where((d) => d.id == widget.draftId).firstOrNull;
      if (currentDraft != null && mounted) {
        setState(() {
          _answers.addAll(currentDraft.answers);
        });
      }
    }
  }

  Future<void> _saveDraft() async {
    final draft = Assessment(
      id: _assessmentId,
      factoryInfo: widget.factoryInfo,
      answers: _answers,
      totalScore: 0, // calculated later
      riskLevel: 'HIGH',
      categoryScores: {},
      isCompleted: false,
    );
    await LocalStorageService.saveDraft(draft);
  }

  int get _totalQuestions => AssessmentData.getTotalQuestions(widget.factoryInfo.factoryType);
  int get _answeredQuestions => _answers.length;
  double get _progress => _answeredQuestions / _totalQuestions;

  Category get _currentCategory => _categories[_currentCategoryIndex];

  void _setAnswer(String questionId, bool isCompliant, [int? likertValue]) {
    setState(() {
      _answers[questionId] = Answer(
        questionId: questionId,
        isCompliant: isCompliant,
        likertValue: likertValue,
      );
    });
    _saveDraft();
  }

  void _nextCategory() {
    if (_currentCategoryIndex < _categories.length - 1) {
      setState(() {
        _currentCategoryIndex++;
      });
    }
  }

  void _previousCategory() {
    if (_currentCategoryIndex > 0) {
      setState(() {
        _currentCategoryIndex--;
      });
    }
  }

  Future<void> _submitAssessment() async {
    final type = widget.factoryInfo.factoryType;
    final totalScore = ScoringService.calculateTotalScore(type, _answers);
    final riskLevel = ScoringService.getRiskLevel(type, _answers);
    final categoryScores = ScoringService.getCategoryScores(type, _answers);

    final assessment = Assessment(
      id: _assessmentId,
      factoryInfo: widget.factoryInfo,
      answers: _answers,
      totalScore: totalScore,
      riskLevel: riskLevel,
      categoryScores: categoryScores,
      isCompleted: true,
    );

    // Save final state as completed
    await LocalStorageService.saveDraft(assessment);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(assessment: assessment),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryScore = ScoringService.calculateCategoryScore(
      _currentCategory, 
      _answers,
    );
    final categoryAnswered = ScoringService.getCategoryAnsweredCount(
      _currentCategory, 
      _answers,
    );

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text('${_currentCategory.code}. ${_currentCategory.name}'),
        backgroundColor: Colors.transparent,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '$_answeredQuestions/$_totalQuestions',
                style: const TextStyle(
                  color: AppTheme.goldPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: AppTheme.surfaceLight,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.goldPrimary),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category ${_currentCategoryIndex + 1}/${_categories.length}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    Text(
                      '${(_progress * 100).toStringAsFixed(0)}% Complete',
                      style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Category header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CategoryHeader(
              code: _currentCategory.code,
              name: _currentCategory.name,
              weight: _currentCategory.weight,
              answeredCount: categoryAnswered,
              totalCount: _currentCategory.totalQuestions,
              score: categoryScore,
            ),
          ),
          const SizedBox(height: 8),

          // Questions list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _currentCategory.subCategories.length,
              itemBuilder: (context, subIndex) {
                final subCategory = _currentCategory.subCategories[subIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      subCategory.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.goldLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...subCategory.questions.map((question) {
                      final answer = _answers[question.id];
                      return _QuestionCard(
                        question: question,
                        answer: answer,
                        onAnswer: (isCompliant, likertValue) => _setAnswer(question.id, isCompliant, likertValue),
                      );
                    }),
                  ],
                );
              },
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              border: Border(
                top: BorderSide(color: AppTheme.goldPrimary.withValues(alpha: 0.3)),
              ),
            ),
            child: Row(
              children: [
                if (_currentCategoryIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousCategory,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                  ),
                if (_currentCategoryIndex > 0) const SizedBox(width: 16),
                Expanded(
                  child: _currentCategoryIndex < _categories.length - 1
                      ? ElevatedButton.icon(
                          onPressed: _nextCategory,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Next'),
                        )
                      : ElevatedButton.icon(
                          onPressed: _answeredQuestions > 0 ? _submitAssessment : null,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Submit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.riskLow,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final Question question;
  final Answer? answer;
  final Function(bool, int?) onAnswer;

  const _QuestionCard({
    required this.question,
    this.answer,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    bool isAnswered = answer != null;
    Color borderColor = AppTheme.surfaceLight;
    if (isAnswered) {
      if (question.type == QuestionType.likert) {
         borderColor = AppTheme.goldPrimary.withValues(alpha: 0.5);
      } else {
         borderColor = (answer!.isCompliant ? AppTheme.riskLow : AppTheme.riskHigh).withValues(alpha: 0.5);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (question.type == QuestionType.likert)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.goldPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('LIKERT', style: TextStyle(fontSize: 10, color: AppTheme.goldPrimary, fontWeight: FontWeight.bold)),
                ),
              Expanded(
                child: Text(
                  question.text,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (question.type == QuestionType.boolean)
            Row(
              children: [
                Expanded(
                  child: _AnswerButton(
                    label: 'Comply',
                    isSelected: answer?.isCompliant == true,
                    isPositive: true,
                    onTap: () => onAnswer(true, null),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AnswerButton(
                    label: 'Not Comply',
                    isSelected: answer?.isCompliant == false,
                    isPositive: false,
                    onTap: () => onAnswer(false, null),
                  ),
                ),
              ],
            )
          else
            _LikertScale(
               currentValue: answer?.likertValue,
               onChanged: (val) => onAnswer(val >= 3, val),
            ),
        ],
      ),
    );
  }
}

class _LikertScale extends StatelessWidget {
  final int? currentValue;
  final Function(int) onChanged;

  const _LikertScale({this.currentValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: List.generate(5, (index) {
             int val = index + 1;
             bool isSelected = currentValue == val;
             return GestureDetector(
               onTap: () => onChanged(val),
               child: Container(
                 width: 45,
                 height: 45,
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   color: isSelected ? AppTheme.goldPrimary : AppTheme.surfaceLight,
                   border: Border.all(
                      color: isSelected ? AppTheme.goldPrimary : AppTheme.surfaceLight,
                      width: 2,
                   ),
                 ),
                 alignment: Alignment.center,
                 child: Text(
                   val.toString(),
                   style: TextStyle(
                     color: isSelected ? Colors.white : AppTheme.textSecondary,
                     fontWeight: FontWeight.bold,
                     fontSize: 16,
                   ),
                 ),
               ),
             );
           }),
         ),
         const SizedBox(height: 8),
         const Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Text('Buruk', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
             Text('Sangat Baik', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
           ],
         ),
      ],
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isPositive;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.isSelected,
    required this.isPositive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppTheme.riskLow : AppTheme.riskHigh;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppTheme.surfaceLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPositive ? Icons.check_circle : Icons.cancel,
              color: isSelected ? color : AppTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
