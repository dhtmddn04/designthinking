import 'package:flutter/material.dart';

class LanguageIconButton extends StatelessWidget {
  final String languageCode;
  final Future<void> Function(String code) onSelected;

  const LanguageIconButton({
    super.key,
    required this.languageCode,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: languageCode == 'en' ? 'Language' : '언어 선택',
      onOpened: () {
        FocusScope.of(context).unfocus();
      },
      onSelected: (value) {
        onSelected(value);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'ko',
          child: Row(
            children: [
              if (languageCode == 'ko')
                const Icon(Icons.check, size: 18)
              else
                const SizedBox(width: 18),
              const SizedBox(width: 8),
              const Text('한국어'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'en',
          child: Row(
            children: [
              if (languageCode == 'en')
                const Icon(Icons.check, size: 18)
              else
                const SizedBox(width: 18),
              const SizedBox(width: 8),
              const Text('English'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language, size: 20, color: Color(0xFF374151)),
            SizedBox(width: 1),
            Icon(Icons.arrow_drop_down, size: 20, color: Color(0xFF374151)),
          ],
        ),
      ),
    );
  }
}
