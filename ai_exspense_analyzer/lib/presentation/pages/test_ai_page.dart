import 'package:flutter/material.dart';
import '../../core/ai/expense_classifier.dart';

class TestAiPage extends StatefulWidget {
  const TestAiPage({super.key});

  @override
  State<TestAiPage> createState() => _TestAiPageState();
}

class _TestAiPageState extends State<TestAiPage> {
  final controller = TextEditingController();
  String result = '';
  bool loading = false;

  final classifier = ExpenseClassifier();

  Future<void> testAI() async {
    setState(() {
      loading = true;
      result = '';
    });

    try {
      final category = await classifier.classify(controller.text);
      setState(() {
        result = category;
      });
    } catch (e) {
      setState(() {
        result = 'ERROR: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test HuggingFace AI')),
      body: SingleChildScrollView( // ✅ FIX UTAMA
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Input pengeluaran',
                hintText: 'Contoh: Beli kopi di Starbucks',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : testAI,
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('TEST AI'),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              result.isEmpty
                  ? 'Hasil kategori akan muncul di sini'
                  : result,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
