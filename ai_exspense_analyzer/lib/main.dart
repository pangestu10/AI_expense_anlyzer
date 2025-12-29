import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

// CORE
import 'core/ai/expense_classifier.dart';

// DATA
import 'data/datasources/expense_local_ds.dart';
import 'data/repositories/expense_repository.dart';

// PRESENTATION
import 'presentation/providers/expense_provider.dart';
import 'presentation/pages/home_page.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Load ENV (Hugging Face API Key)
  await dotenv.load(fileName: ".env");

  // ✅ Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID');

  // ✅ Dependency Injection Manual (Clean & Simple)
  final expenseRepository = ExpenseRepository(
    ai: ExpenseClassifier(),
    local: ExpenseLocalDatasource(),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(expenseRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Expense Analyzer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.aiTheme,
      darkTheme: AppTheme.aiDarkTheme,
      themeMode: ThemeMode.dark, // Set to dark theme
      home: const HomePage(),
    );
  }
}
