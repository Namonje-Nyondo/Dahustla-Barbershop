import 'dart:async';
import 'package:customers/screens/dashboard.dart';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import 'dashboard.dart';
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  Timer? _carouselTimer;

  final List<String> _haircuts = [
    'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?q=80&w=600',
    'https://images.unsplash.com/photo-1621605815971-fbc98d665033?q=80&w=600',
    // 'https://images.unsplash.com/photo-1605497746444-ac9da5848ba7?q=80&w=600',
  ];

  @override
  void initState() {
    super.initState();
    _carouselTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (_pageController.hasClients) {
        if (_currentPage < _haircuts.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),

            const Text(
              'DAHUSTLA',
              style: TextStyle(
                color: AppTheme.primaryGold,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'THE ART OF GROOMING',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                letterSpacing: 2.0,
              ),
            ),

            const Spacer(flex: 2),

            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _haircuts.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: index == _currentPage ? 1.0 : 0.92,
                        child: child,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.cardBorder, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            // FIX 3: Replaced .withOpacity with .withValues
                            color: AppTheme.primaryGold.withValues(alpha: 0.05),
                            blurRadius: 15,
                            spreadRadius: 2,
                          )
                        ],
                        image: DecorationImage(
                          image: NetworkImage(_haircuts[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_haircuts.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                  width: _currentPage == index ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppTheme.primaryGold : AppTheme.cardBorder,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
              );
            },
            backgroundColor: AppTheme.primaryGold,
            foregroundColor: Colors.black,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            // FIX 4: Removed 'fontWeight' from Icon (Icon does not have a fontWeight property)
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: const Text(
              'BOOK NOW',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}