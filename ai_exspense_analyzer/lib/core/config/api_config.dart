import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get hfApiKey =>
      dotenv.env['HF_API_KEY'] ?? '';

  static String get groqApiKey =>
      dotenv.env['GROQ_API_KEY'] ?? '';
}
