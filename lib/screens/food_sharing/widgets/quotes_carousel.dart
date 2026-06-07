import 'dart:async';
import 'package:flutter/material.dart';

class QuoteItem {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  const QuoteItem({
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
  });
}

class QuotesCarousel extends StatefulWidget {
  const QuotesCarousel({super.key});

  @override
  State<QuotesCarousel> createState() => _QuotesCarouselState();
}

class _QuotesCarouselState extends State<QuotesCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // Modern pastel colors as requested: Mint Green, Light Blue, Lavender, Soft Peach, Light Teal
  final List<QuoteItem> _quotes = const [
    QuoteItem(
      text: "Share food, spread happiness.",
      icon: Icons.restaurant_menu_rounded,
      backgroundColor: Color(0xFFE2F3E8), // Mint Green
      textColor: Color(0xFF2C5E3B),
    ),
    QuoteItem(
      text: "Every meal shared is a smile multiplied.",
      icon: Icons.favorite_rounded,
      backgroundColor: Color(0xFFE3F2FD), // Light Blue
      textColor: Color(0xFF0D47A1),
    ),
    QuoteItem(
      text: "Food is precious. Don't waste it.",
      icon: Icons.no_food_rounded,
      backgroundColor: Color(0xFFF3E5F5), // Lavender
      textColor: Color(0xFF4A148C),
    ),
    QuoteItem(
      text: "Take what you need, share what you can.",
      icon: Icons.volunteer_activism_rounded,
      backgroundColor: Color(0xFFFFE0B2), // Soft Peach
      textColor: Color(0xFFE65100),
    ),
    QuoteItem(
      text: "A plate saved is a future preserved.",
      icon: Icons.savings_rounded,
      backgroundColor: Color(0xFFE0F2F1), // Light Teal
      textColor: Color(0xFF004D40),
    ),
    QuoteItem(
      text: "Sharing food nourishes both body and soul.",
      icon: Icons.emoji_food_beverage_rounded,
      backgroundColor: Color(0xFFE2F3E8), // Mint Green
      textColor: Color(0xFF2C5E3B),
    ),
    QuoteItem(
      text: "Together we can stop food waste.",
      icon: Icons.people_alt_rounded,
      backgroundColor: Color(0xFFE3F2FD), // Light Blue
      textColor: Color(0xFF0D47A1),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _quotes.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _quotes.length,
            itemBuilder: (context, index) {
              final quote = _quotes[index];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: quote.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        quote.icon,
                        color: quote.textColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quote.text,
                            style: TextStyle(
                              color: quote.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _quotes.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  width: _currentPage == index ? 16 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: _currentPage == index
                        ? _quotes[_currentPage].textColor
                        : _quotes[_currentPage].textColor.withValues(alpha: 0.3),
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
