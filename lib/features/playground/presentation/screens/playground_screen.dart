import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/providers/dashboard_providers.dart';
import '../../services/python_mock_interpreter.dart';

class PlaygroundScreen extends ConsumerStatefulWidget {
  const PlaygroundScreen({super.key});

  @override
  ConsumerState<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends ConsumerState<PlaygroundScreen> {
  final _controller = TextEditingController(text: 'name = "Pythonchi"\nprint("Салом,", name)\n\nfor i in range(1, 4):\n    print("Такрори", i)');
  String _output = '';
  bool _hasRun = false;
  int _runCount = 0;

  Future<void> _run() async {
    final result = PythonMockInterpreter.run(_controller.text);
    setState(() {
      _output = result.isEmpty ? '(баромад холӣ аст)' : result;
      _hasRun = true;
      _runCount++;
    });

    if (_runCount == 10) {
      await ref.read(progressRepositoryProvider).unlockAchievement('playground_10');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Python Playground'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Тоза кардан',
            onPressed: () => setState(() {
              _controller.clear();
              _output = '';
              _hasRun = false;
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF282C34),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _run,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Иҷро кардан'),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _hasRun ? _output : 'Натиҷаи баромад дар ин ҷо нишон дода мешавад...',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 13.5,
                    color: _hasRun ? AppColors.darkOnBackground : AppColors.darkOnSurfaceMuted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
