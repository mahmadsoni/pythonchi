import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';

class _OnboardPage {
  final IconData icon;
  final String title;
  final String body;
  const _OnboardPage(this.icon, this.title, this.body);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _index = 0;

  final _pages = const [
    _OnboardPage(
      Icons.auto_stories_rounded,
      'Омӯзиши Python аз сифр',
      'Зиёда аз 100 дарси интерактивӣ, ки шуморо қадам ба қадам ба сатҳи касбӣ мебарад.',
    ),
    _OnboardPage(
      Icons.smart_toy_rounded,
      'Ёвари AI дар паҳлуи шумо',
      'Хатогиҳои коди худро фаҳмед, ислоҳ кунед ва беҳтар созед бо кӯмаки сунъии зеҳн.',
    ),
    _OnboardPage(
      Icons.offline_bolt_rounded,
      'Оффлайн омӯзед, дар ҳама ҷо',
      'Бе интернет ҳам дарсҳоро идома диҳед — пешрафти шумо ҳамеша нигоҳ дошта мешавад.',
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Гузаштан'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: AppColors.brandGradient),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(page.icon, size: 64, color: Colors.white),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _index == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == i ? AppColors.indigoLight : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_index == _pages.length - 1) {
                      _finish();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(_index == _pages.length - 1 ? 'Оғоз кунем' : 'Баъдӣ'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
