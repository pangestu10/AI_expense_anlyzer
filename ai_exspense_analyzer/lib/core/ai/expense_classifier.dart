// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ExpenseClassifier {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 40),
      receiveTimeout: const Duration(seconds: 40),
    ),
  );

  Future<String> classify(String text) async {
    try {
      final response = await _dio.post(
        'https://router.huggingface.co/hf-inference/models/facebook/bart-large-mnli',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConfig.hfApiKey}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "inputs":
              "This is an expense category classification. "
              "Classify the following expense description into one category only: "
              "$text",
          "parameters": {
            "candidate_labels": [
              "Food and Drink",
              "Transportation",
              "Housing and Rent",
              "Entertainment and Leisure",
              "Shopping and Personal",
              "Health and Medical",
              "Education",
              "Other",
            ],
          },
          "options": {"wait_for_model": true},
        },
      );

      final data = response.data;

      // ✅ CASE 1: List<Map> dengan label & score (INI YANG KAMU DAPAT)
      if (data is List && data.isNotEmpty) {
        final first = data.first;
        if (first is Map && first['label'] is String) {
          return first['label'];
        }
      }

      // ✅ CASE 2: List<Map> dengan labels array
      if (data is List && data.isNotEmpty) {
        final first = data.first;
        if (first is Map && first['labels'] is List) {
          return first['labels'][0];
        }
      }

      // ✅ CASE 3: Map dengan labels
      if (data is Map && data['labels'] is List) {
        return data['labels'][0];
      }

      // ✅ CASE 4: Map dengan label
      if (data is Map && data['label'] is String) {
        return data['label'];
      }

      // ✅ CASE 5: String langsung
      if (data is String) {
        return data;
      }

      print('UNKNOWN RESPONSE FORMAT: $data');
      return "Other";
    } on DioException catch (e) {
      print("STATUS: ${e.response?.statusCode}");
      print("DATA: ${e.response?.data}");
      rethrow;
    }
  }
}
