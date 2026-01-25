import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../gen/locale_keys.g.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppTheme.primaryTextColor),
        title: Text(
          LocaleKeys.settings_title.tr(),
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsTile(
            context: context,
            icon: Icons.language_rounded,
            title: LocaleKeys.settings_language.tr(),
            subtitle:
                context.locale.languageCode == 'tr'
                    ? LocaleKeys.settings_turkish.tr()
                    : LocaleKeys.settings_english.tr(),
            onTap: () {
              context.go('/settings/language');
            },
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context: context,
            icon: Icons.info_rounded,
            title: LocaleKeys.settings_about.tr(),
            onTap: () {
              context.go('/settings/about');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.accentColor, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle:
            subtitle != null
                ? Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                )
                : null,
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
      ),
    );
  }
}
