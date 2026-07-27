import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../services/ai_service.dart';

enum _AiAction { explain, fix, improve, quiz }

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _service = AiService();
  final _inputController = TextEditingController();
  _AiAction _action = _AiAction.explain;
  bool _loading = false;
  String? _result;
  String? _error;

  Future<void> _submit() async {
    if (_inputController.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final hasKey = await _service.hasApiKey();
      if (!hasKey) {
        setState(() {
          _error = 'Барои истифодаи AI, лутфан калиди API-ро дар танзимот ворид кунед.';
          _loading = false;
        });
        return;
      }

      final text = _inputController.text;
      final String response;
      switch (_action) {
        case _AiAction.explain:
          response = await _service.explainCode(text);
          break;
        case _AiAction.fix:
          response = await _service.fixCode(text);
          break;
        case _AiAction.improve:
          response = await _service.suggestImprovement(text);
          break;
        case _AiAction.quiz:
          response = await _service.generateQuiz(text);
          break;
      }
      setState(() {
        _result = response;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e is AiServiceException ? e.message : 'Хатогӣ рӯй дод: $e';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ёвари AI')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                _ActionChip(label: 'Шарҳи код', selected: _action == _AiAction.explain, onTap: () => setState(() => _action = _AiAction.explain)),
                _ActionChip(label: 'Ислоҳи код', selected: _action == _AiAction.fix, onTap: () => setState(() => _action = _AiAction.fix)),
                _ActionChip(label: 'Беҳтарсозӣ', selected: _action == _AiAction.improve, onTap: () => setState(() => _action = _AiAction.improve)),
                _ActionChip(label: 'Тавлиди санҷиш', selected: _action == _AiAction.quiz, onTap: () => setState(() => _action = _AiAction.quiz)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _inputController,
                maxLines: 6,
                style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 13.5),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: _action == _AiAction.quiz
                      ? 'Мавзӯъ нависед (масалан: for loops)'
                      : 'Коди Python-ро дар ин ҷо гузоред...',
                  hintStyle: const TextStyle(color: Colors.white38),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(_loading ? 'AI фикр карда истодааст...' : 'Фиристодан'),
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_error!, style: const TextStyle(color: AppColors.error)),
              ),
            if (_result != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightBorder),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(_result!, style: const TextStyle(fontSize: 14, height: 1.5)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ActionChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap());
  }
}
