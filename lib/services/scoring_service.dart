import '../models/models.dart';
import '../data/assessment_data.dart';
import 'fuzzy_logic_service.dart';

class ScoringService {
  static double calculateCategoryScore(
    Category category,
    Map<String, Answer> answers,
  ) {
    double totalWeight = 0;
    double weightedScore = 0;

    for (var sub in category.subCategories) {
      for (var question in sub.questions) {
        totalWeight += question.weight;
        final answer = answers[question.id];
        if (answer != null) {
          weightedScore += answer.scoreFor(question) * question.weight;
        }
      }
    }

    if (totalWeight == 0) return 0;
    return (weightedScore / totalWeight) * 100;
  }

  static double calculateSubCategoryScore(
    SubCategory subCategory,
    Map<String, Answer> answers,
  ) {
    double totalWeight = 0;
    double weightedScore = 0;

    for (var question in subCategory.questions) {
      totalWeight += question.weight;
      final answer = answers[question.id];
      if (answer != null) {
        weightedScore += answer.scoreFor(question) * question.weight;
      }
    }

    if (totalWeight == 0) return 0;
    return (weightedScore / totalWeight) * 100;
  }

  static double calculateTotalScore(
    Map<String, Answer> answers, {
    IndustryType industryType = IndustryType.manufacturing,
  }) {
    final scores = getCategoryScores(answers, industryType: industryType);
    final fuzzyResult = FuzzyLogicService.evaluate(
      scores['A'] ?? 0,
      scores['B'] ?? 0,
      scores['C'] ?? 0,
      scores['D'] ?? 0,
    );
    return fuzzyResult.fuzzyScore;
  }

  static String getRiskLevel(
    Map<String, Answer> answers, {
    IndustryType industryType = IndustryType.manufacturing,
  }) {
    final scores = getCategoryScores(answers, industryType: industryType);
    final fuzzyResult = FuzzyLogicService.evaluate(
      scores['A'] ?? 0,
      scores['B'] ?? 0,
      scores['C'] ?? 0,
      scores['D'] ?? 0,
    );
    return fuzzyResult.riskLevel;
  }

  static Map<String, double> getCategoryScores(
    Map<String, Answer> answers, {
    IndustryType industryType = IndustryType.manufacturing,
  }) {
    final categories = AssessmentData.getCategories(industryType: industryType);
    Map<String, double> scores = {};
    for (var category in categories) {
      scores[category.id] = calculateCategoryScore(category, answers);
    }
    return scores;
  }

  static int getAnsweredCount(Map<String, Answer> answers) => answers.length;

  static int getCategoryAnsweredCount(
    Category category,
    Map<String, Answer> answers,
  ) {
    int count = 0;
    for (var sub in category.subCategories) {
      for (var question in sub.questions) {
        if (answers.containsKey(question.id)) count++;
      }
    }
    return count;
  }

  static String getRecommendation(
      double score, Map<String, double> categoryScores) {
    if (score >= 80) {
      return 'Hasil asesmen menunjukkan kepatuhan keselamatan kebakaran yang baik. '
          'Pertahankan standar yang ada dan lakukan inspeksi rutin secara berkala.';
    } else if (score >= 60) {
      String lowestCategory = '';
      double lowestScore = 100;
      categoryScores.forEach((key, value) {
        if (value < lowestScore) {
          lowestScore = value;
          lowestCategory = key;
        }
      });
      return 'Asesmen menunjukkan adanya kekurangan pada tingkat sedang. '
          'Fokuskan perbaikan pada Kategori $lowestCategory yang mendapat skor terendah '
          '(${lowestScore.toStringAsFixed(1)}%). Jadwalkan re-assessment dalam 3 bulan.';
    } else {
      return 'Asesmen menunjukkan permasalahan kritis yang memerlukan tindakan segera. '
          'Lakukan koreksi darurat pada area dengan skor terendah dan jadwalkan re-assessment dalam 2 bulan.';
    }
  }
}
