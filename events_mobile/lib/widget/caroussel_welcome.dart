import 'package:flutter/material.dart';
import 'package:events_mobile/core/theme/color_style.dart';

class CarousselWelcome extends StatefulWidget {
  const CarousselWelcome({super.key});

  @override
  State<CarousselWelcome> createState() => _CarousselState();
}

class _CarousselState extends State<CarousselWelcome> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<String> _images = [
    'assets/images/welcome/welcome_img1.png',
    'assets/images/welcome/welcome_img2.png',
    'assets/images/welcome/welcome_img3.png'
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _images.length,
            itemBuilder: (_, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(_images[index]),
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
                'Create brilliant learning\npathways',
                textAlign: TextAlign.center,
                style: TextStyle(
                   color: isDark ? AppColors.backgroundLight : AppColors.backgroundDark,
                  //color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _images.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: _currentPage == index ? 12 : 8,
              height: _currentPage == index ? 12 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? AppColors.brand60 : AppColors.grey40,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}



