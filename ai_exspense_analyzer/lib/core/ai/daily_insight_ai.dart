import 'package:dio/dio.dart';
import '../config/api_config.dart';

class DailyInsightAI {
  late final Dio dio;

  DailyInsightAI(this.dio) {
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);
  }

  Future<String> generateInsight(String summary) async {
    // Validate input data
    if (summary.trim().isEmpty) {
      return 'No data available for insight generation.';
    }

    if (ApiConfig.groqApiKey.isEmpty) {
      return 'API key not configured. Please check your environment settings.';
    }

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
              "content": "You are a personal finance assistant."
            },
            {
              "role": "user",
              "content":
                  "Berikan SATU insight singkat (maks 2 kalimat) berdasarkan data ini:\n$summary"
            }
          ],
          "temperature": 0.6,
          "max_tokens": 100
        },
      );

      if (response.statusCode != 200) {
        return 'Failed to get response from AI service. Status code: ${response.statusCode}';
      }

      if (response.data == null || 
          response.data['choices'] == null || 
          response.data['choices'].isEmpty ||
          response.data['choices'][0]['message'] == null ||
          response.data['choices'][0]['message']['content'] == null) {
        return 'Invalid response format from AI service.';
      }

      return response.data['choices'][0]['message']['content'].toString();
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
      
      return 'Failed to connect to AI service: $errorMessage';
    } catch (e) {
      return 'Unexpected error occurred: ${e.toString()}';
    }
  }
}
