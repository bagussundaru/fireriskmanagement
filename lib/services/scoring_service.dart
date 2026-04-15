import '../models/models.dart';
import '../data/assessment_data.dart';
import 'fuzzy_logic_service.dart';

class ScoringService {
  static double calculateCategoryScore(
    Category category, 
    Map<String, Answer> answers,
  ) {
    int totalQuestions = 0;
    double accumulatedPoints = 0;
    
    for (var subCategory in category.subCategories) {
      for (var question in subCategory.questions) {
        totalQuestions++;
        final answer = answers[question.id];
        if (answer != null) {
          if (question.type == QuestionType.likert) {
            final lValue = answer.likertValue ?? 1;
            accumulatedPoints += (lValue / 5.0);
          } else {
            if (answer.isCompliant) {
              accumulatedPoints += 1.0;
            }
          }
        }
      }
    }
    
    if (totalQuestions == 0) return 0;
    return (accumulatedPoints / totalQuestions) * 100;
  }

  static double calculateSubCategoryScore(
    SubCategory subCategory,
    Map<String, Answer> answers,
  ) {
    int totalQuestions = subCategory.questions.length;
    double accumulatedPoints = 0;
    
    for (var question in subCategory.questions) {
      final answer = answers[question.id];
      if (answer != null) {
        if (question.type == QuestionType.likert) {
          final lValue = answer.likertValue ?? 1;
          accumulatedPoints += (lValue / 5.0);
        } else {
          if (answer.isCompliant) {
            accumulatedPoints += 1.0;
          }
        }
      }
    }
    
    if (totalQuestions == 0) return 0;
    return (accumulatedPoints / totalQuestions) * 100;
  }

  static double calculateTotalScore(String factoryType, Map<String, Answer> answers) {
    final scores = getCategoryScores(factoryType, answers);
    
    // Fuzzy AHP Process
    final fuzzyResult = FuzzyLogicService.evaluate(
      scores['A'] ?? 0,
      scores['B'] ?? 0,
      scores['C'] ?? 0,
      scores['D'] ?? 0,
    );
    
    return fuzzyResult.fuzzyScore;
  }

  static String getRiskLevel(String factoryType, Map<String, Answer> answers) {
    final scores = getCategoryScores(factoryType, answers);
    
    // Fuzzy AHP Process
    final fuzzyResult = FuzzyLogicService.evaluate(
      scores['A'] ?? 0,
      scores['B'] ?? 0,
      scores['C'] ?? 0,
      scores['D'] ?? 0,
    );
    
    return fuzzyResult.riskLevel;
  }

  static Map<String, double> getCategoryScores(String factoryType, Map<String, Answer> answers) {
    final categories = AssessmentData.getCategories(factoryType);
    Map<String, double> scores = {};
    
    for (var category in categories) {
      scores[category.id] = calculateCategoryScore(category, answers);
    }
    
    return scores;
  }

  static int getAnsweredCount(Map<String, Answer> answers) {
    return answers.length;
  }

  static int getCategoryAnsweredCount(
    Category category, 
    Map<String, Answer> answers,
  ) {
    int count = 0;
    for (var subCategory in category.subCategories) {
      for (var question in subCategory.questions) {
        if (answers.containsKey(question.id)) {
          count++;
        }
      }
    }
    return count;
  }

  static String getRecommendation(double score, Map<String, double> categoryScores) {
    if (score >= 80) {
      return 'The assessment indicates good fire safety compliance. Continue maintaining current standards and conduct regular inspections.';
    } else if (score >= 60) {
      // Find lowest category
      String lowestCategory = '';
      double lowestScore = 100;
      categoryScores.forEach((key, value) {
        if (value < lowestScore) {
          lowestScore = value;
          lowestCategory = key;
        }
      });
      
      return 'The assessment indicates moderate fire safety issues. Focus improvement efforts on Category $lowestCategory which scored lowest at ${lowestScore.toStringAsFixed(1)}%. Schedule follow-up assessment within 3 months.';
    } else {
      return 'The assessment indicates critical fire safety issues that require immediate attention. Focus improvement efforts on the areas which scored lowest in this assessment. Implement critical corrections immediately and schedule follow-up assessment within 2 months.';
    }
  }
}
