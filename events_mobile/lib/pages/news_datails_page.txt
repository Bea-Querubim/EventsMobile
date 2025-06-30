import 'package:flutter/material.dart';
import '../core/theme/color_style.dart';

class NewsDetailPage extends StatefulWidget {
  final String title;
  final String author;
  final String imagePath;

  const NewsDetailPage({
    super.key,
    required this.title,
    required this.author,
    required this.imagePath,
  });

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLandscape
            ? Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Image.asset(widget.imagePath, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _buildTextContent(context),
                  ),
                ],
              )
            : ListView(
                children: [
                  _buildTextContent(context),
                  const SizedBox(height: 12),
                  Image.asset(widget.imagePath, fit: BoxFit.cover),
                ],
              ),
      ),
    );
  }

  Widget _buildTextContent(context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('by ${widget.author}', style: TextStyle(
          color: isDark ? AppColors.grey40: AppColors.grey60)
          ),
        const SizedBox(height: 12),
        const Text(
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
          'Aliquam at porttitor sem. Aliquam erat volutpat. '
          'Donec placerat nisl magna, et faucibus arcu condimentum sed.',
        ),
      ],
    );
  }
}
