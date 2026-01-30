import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../gen/locale_keys.g.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppTheme.primaryTextColor),
        title: Text(
          LocaleKeys.settings_select_language.tr(),
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLanguageTile(
            context: context,
            languageCode: 'tr',
            languageName: LocaleKeys.settings_turkish.tr(),
            flag: '🇹🇷',
            isSelected: currentLocale.languageCode == 'tr',
            onTap: () async {
              final gameProvider = Provider.of<GameProvider>(
                context,
                listen: false,
              );
              await context.setLocale(const Locale('tr'));
              // Reload data from services with new language
              gameProvider.reloadDataForLanguage('tr');
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(height: 12),
          _buildLanguageTile(
            context: context,
            languageCode: 'en',
            languageName: LocaleKeys.settings_english.tr(),
            flag: '🇬🇧',
            isSelected: currentLocale.languageCode == 'en',
            onTap: () async {
              final gameProvider = Provider.of<GameProvider>(
                context,
                listen: false,
              );
              await context.setLocale(const Locale('en'));
              // Reload data from services with new language
              gameProvider.reloadDataForLanguage('en');
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required String languageCode,
    required String languageName,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            isSelected
                ? Border.all(color: AppTheme.accentColor, width: 2)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Text(flag, style: const TextStyle(fontSize: 40)),
        title: Text(
          languageName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.accentColor : Colors.black,
          ),
        ),
        trailing:
            isSelected
                ? Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.accentColor,
                  size: 28,
                )
                : null,
      ),
    );
  }
}
