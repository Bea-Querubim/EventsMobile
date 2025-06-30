import 'package:flutter/material.dart';
import '../../core/theme/color_style.dart';
import '../../core/theme/font_style.dart';
import 'news_datails_page.dart';

class NewsFeedPage extends StatelessWidget {
  const NewsFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final today = DateTime.now();
    final formattedDate =
        "${today.weekday == 1 ? 'Monday' : ''}, ${today.day}/${today.month}/${today.year}";
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning',
                        style: AppTextStyles.heading.copyWith(
                          color: isDark ? AppColors.grey20 : AppColors.grey80,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: isDark ? AppColors.grey20 : AppColors.grey80,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.wb_sunny, color: Colors.orange, size: 28),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [_buildCategoryChip('World', selected: true)],
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  children: [
                    _buildMainNewsCard(context),
                    const SizedBox(height: 24),
                    _buildMiniNewsItem(
                      image:
                          'assets/images/news/port-authority-bus-terminal.png',
                      title:
                          'A Plan to Rebuild the Bus Terminal Everyone Loves to Hate',
                      author: 'Troy Corlson',
                      time: '2h ago',
                      context: context,
                    ),
                    const SizedBox(height: 16),
                    _buildMiniNewsItem(
                      image:
                          'assets/images/news/port-authority-bus-terminal.png',
                      title:
                          'A Plan to Rebuild the Bus Terminal Everyone Loves to Hate',
                      author: 'Troy Corlson',
                      time: '2h ago',
                      context: context,
                    ),
                    const SizedBox(height: 16),
                    _buildMiniNewsItem(
                      image: 'assets/images/news/montclair-schools-covid.png',
                      title: 'California Ends Virus Restrictions',
                      author: 'Isabella Kwai',
                      time: '3h ago',
                      context: context,
                    ),
                    const SizedBox(height: 16),
                    _buildMiniNewsItem(
                      image: 'assets/images/news/montclair-schools-covid.png',
                      title: 'California Ends Virus Restrictions',
                      author: 'Isabella Kwai',
                      time: '3h ago',
                      context: context,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, {bool selected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Chip(
        backgroundColor: selected ? AppColors.brand60 : AppColors.grey20,
        side: const BorderSide(style: BorderStyle.none),
        label: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: selected ? Colors.white : Colors.black,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildMainNewsCard(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const NewsDetailPage(
            title: 'A Plan to Rebuild the Bus Terminal Everyone Loves to Hate',
            author: 'Troy Carlson',
            imagePath: 'assets/images/news/port-authority-bus-terminal.png',
          ),
        ),
      );
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/news/port-authority-bus-terminal.png',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'A Plan to Rebuild the Bus Terminal Everyone Loves to Hate',
          style: AppTextStyles.subtitle.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.grey10 : AppColors.grey90,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '1h ago • by Troy Carlson',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.grey60 : AppColors.grey70,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildMiniNewsItem({
    required String image,
    required String title,
    required String author,
    required String time,
    required context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(image, width: 80, height: 80, fit: BoxFit.cover),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600,color: isDark ? AppColors.grey30 : AppColors.grey70 ),
              ),
              const SizedBox(height: 4),
              Text(
                '$time • by $author',
                style: AppTextStyles.caption.copyWith(
                  color: isDark ? AppColors.grey70 : AppColors.grey60,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
