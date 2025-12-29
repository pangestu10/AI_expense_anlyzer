import 'package:dio/dio.dart';
import '../config/api_config.dart';

class SmartRecommendationAI {
  late final Dio dio;

  SmartRecommendationAI(this.dio) {
    // Configure timeout to prevent hanging requests
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);
  }

  Future<List<String>> generateRecommendations({
    required String topCategory,
    required int totalExpense,
    required Map<String, int> breakdown,
  }) async {
    // Validate input data
    if (breakdown.isEmpty || totalExpense == 0) {
      return ['No expense data available for recommendations.'];
    }

    if (ApiConfig.groqApiKey.isEmpty) {
      return ['API key not configured. Please check your environment settings.'];
    }

    final breakdownText = breakdown.entries
        .map((e) => "- ${e.key}: ${e.value}")
        .join('\n');

    final prompt = """
Anda adalah asisten keuangan pribadi yang cerdas.

Ringkasan pengeluaran hari ini:
Kategori teratas: $topCategory
Total pengeluaran: $totalExpense
Rincian:
$breakdownText

Berikan 2 atau 3 rekomendasi singkat yang dapat ditindaklanjuti untuk meningkatkan kebiasaan pengeluaran.
Gunakan bullet points.
Jawab dalam bahasa Indonesia.
""";

    try {
      final response = await dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConfig.groqApiKey}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "model": "llama-3.1-8b-instant",
          "messages": [
            {
              "role": "system",
              "content": "Anda adalah advisor keuangan yang membantu. Jawab dalam bahasa Indonesia."
            },
            {
              "role": "user",
              "content": prompt
            }
          ],
          "temperature": 0.6,
          "max_tokens": 150
        },
      );

      if (response.statusCode != 200) {
        return ['Failed to get response from AI service. Status code: ${response.statusCode}'];
      }

      if (response.data == null || 
          response.data['choices'] == null || 
          response.data['choices'].isEmpty ||
          response.data['choices'][0]['message'] == null ||
          response.data['choices'][0]['message']['content'] == null) {
        return ['Invalid response format from AI service.'];
      }

      final text = response.data['choices'][0]['message']['content'].toString();

      final recommendations = text
          .split('\n')
          .where((e) => e.trim().isNotEmpty)
          .map((e) => e.replaceAll(RegExp(r'^[\s\-\*]+'), '').trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (recommendations.isEmpty) {
        return ['No recommendations generated. Please try again later.'];
      }

      return recommendations;
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred';
      
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = 'Connection timeout. Please check your internet connection.';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Response timeout. Please try again.';
          break;
        case DioExceptionType.badResponse:
          errorMessage = 'Server error: ${e.response?.statusCode}';
          if (e.response?.statusCode == 401) {
            errorMessage = 'Invalid API key. Please check your configuration.';
          }
          break;
        case DioExceptionType.unknown:
          errorMessage = 'Network error: ${e.message}';
          break;
        default:
          errorMessage = 'Network error: ${e.type.toString()}';
      }
      
      return ['Failed to connect to AI service: $errorMessage'];
    } catch (e) {
      return ['Unexpected error occurred: ${e.toString()}'];
    }
  }
}
