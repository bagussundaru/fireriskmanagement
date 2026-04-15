import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../services/supabase_service.dart';
import '../models/models.dart';
import '../data/assessment_data.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _assessments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssessments();
  }

  Future<void> _loadAssessments() async {
    setState(() => _isLoading = true);
    
    // Try to load from Supabase
    final cloudData = await SupabaseService.getAssessments();
    
    if (cloudData.isNotEmpty) {
      setState(() {
        _assessments = cloudData;
        _isLoading = false;
      });
    } else {
      // Fallback to mock data for demo
      setState(() {
        _assessments = [
          {
            'id': '1',
            'factory_name': 'PT Tempo Scan Pacific, Tbk',
            'created_at': '2026-01-23T10:00:00Z',
            'total_score': 63.5,
            'risk_level': 'HIGH',
          },
          {
            'id': '2',
            'factory_name': 'PT Indofood Sukses Makmur',
            'created_at': '2026-01-20T14:30:00Z',
            'total_score': 78.2,
            'risk_level': 'MEDIUM',
          },
          {
            'id': '3',
            'factory_name': 'PT Astra International',
            'created_at': '2026-01-15T09:15:00Z',
            'total_score': 85.7,
            'risk_level': 'LOW',
          },
        ];
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAssessment(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Delete Assessment', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('Are you sure you want to delete this assessment?', 
          style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.riskHigh)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SupabaseService.deleteAssessment(id);
      _loadAssessments();
    }
  }

  Assessment _mapToAssessment(Map<String, dynamic> data) {
    // Helper to generate mock answers if missing
    Map<String, Answer> generateMockAnswers(double score) {
      final answers = <String, Answer>{};
      final categories = AssessmentData.getCategories(industryType: IndustryType.manufacturing);
      
      for (var cat in categories) {
        for (var sub in cat.subCategories) {
          for (var q in sub.questions) {
            // Randomize compliance based on score roughly
            final isCompliant = (score > 70) ? true : (DateTime.now().millisecond % 10 < 7);
            answers[q.id] = Answer(questionId: q.id, isCompliant: isCompliant);
          }
        }
      }
      return answers;
    }

    return Assessment(
      id: data['id'].toString(),
      factoryInfo: FactoryInfo(
        factoryName: data['factory_name'] ?? 'Unknown Factory',
        factoryType: data['factory_type'] ?? 'General Manufacturing',
        industryType: IndustryType.manufacturing,
        workerCount: data['worker_count'] ?? '100-500 workers',
        assessorName: data['assessor_name'] ?? 'Assessor',
        gmDirector: data['gm_director'] ?? 'Director',
        assessmentDate: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      ),
      answers: data['answers'] != null 
          ? (data['answers'] as Map).map((k, v) => MapEntry(k.toString(), Answer.fromJson(v)))
          : generateMockAnswers((data['total_score'] ?? 0).toDouble()),
      totalScore: (data['total_score'] ?? 0).toDouble(),
      riskLevel: data['risk_level'] ?? 'MEDIUM',
      categoryScores: data['category_scores'] != null
          ? Map<String, double>.from(data['category_scores'])
          : {
              'A': (data['total_score'] ?? 0).toDouble(),
              'B': (data['total_score'] ?? 0).toDouble(),
              'C': (data['total_score'] ?? 0).toDouble(),
              'D': (data['total_score'] ?? 0).toDouble(),
            }, // Mock scores if missing
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Assessment History'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.goldPrimary),
            onPressed: _loadAssessments,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.goldPrimary),
            )
          : _assessments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 80,
                        color: AppTheme.goldPrimary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No assessments yet',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Start your first assessment to see history here',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAssessments,
                  color: AppTheme.goldPrimary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _assessments.length,
                    itemBuilder: (context, index) {
                      final item = _assessments[index];
                      final riskLevel = item['risk_level'] ?? 'MEDIUM';
                      final riskColor = AppTheme.getRiskColor(riskLevel);
                      final score = (item['total_score'] ?? 0).toDouble();
                      final createdAt = DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now();

                      return Dismissible(
                        key: Key(item['id'].toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: AppTheme.riskHigh,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _deleteAssessment(item['id'].toString()),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            onTap: () {
                              final assessment = _mapToAssessment(item);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResultScreen(
                                    assessment: assessment,
                                    isHistory: true, // Need to add this flag to ResultScreen
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                // Score circle
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Stack(
                                    children: [
                                      CircularProgressIndicator(
                                        value: score / 100,
                                        strokeWidth: 6,
                                        color: riskColor,
                                        backgroundColor: AppTheme.surfaceLight,
                                      ),
                                      Center(
                                        child: Text(
                                          '${score.toStringAsFixed(0)}%',
                                          style: TextStyle(
                                            color: riskColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['factory_name'] ?? 'Unknown Factory',
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('dd/MM/yyyy HH:mm').format(createdAt),
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Risk badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: riskColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    riskLevel,
                                    style: TextStyle(
                                      color: riskColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppTheme.goldPrimary,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
