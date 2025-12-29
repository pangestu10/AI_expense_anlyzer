// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'lib/core/config/api_config.dart';

void main() async {
  final dio = Dio();
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);
  dio.options.sendTimeout = const Duration(seconds: 30);

  print('Testing Groq API...');
  print('API Key: ${ApiConfig.groqApiKey.isNotEmpty ? "Present" : "Missing"}');

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
            "role": "user",
            "content": "Hello, can you give me one simple financial tip?"
          }
        ],
        "temperature": 0.6,
        "max_tokens": 50
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response: ${response.data}');
    
    if (response.statusCode == 200 && response.data['choices'] != null) {
      final content = response.data['choices'][0]['message']['content'];
      print('Success! Response: $content');
    }
  } catch (e) {
    print('Error: $e');
    if (e is DioException) {
      print('Dio Error Type: ${e.type}');
      print('Response: ${e.response?.data}');
    }
  }
}
