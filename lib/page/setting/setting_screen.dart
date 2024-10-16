import 'dart:io';

import 'package:jarvis/lang/lang.dart';
import 'package:jarvis/page/component/background_container.dart';
import 'package:jarvis/page/component/sliver_component.dart';
import 'package:jarvis/page/component/theme/custom_size.dart';
import 'package:jarvis/page/component/theme/custom_theme.dart';
import 'package:jarvis/page/component/theme/theme.dart';
import 'package:jarvis/helper/constant.dart';
import 'package:jarvis/page/component/dialog.dart';
import 'package:jarvis/page/setting/account_security.dart';
import 'package:jarvis/repo/setting_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingScreen extends StatefulWidget {
  final SettingRepository settings;

  const SettingScreen({super.key, required this.settings});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return BackgroundContainer(
      setting: widget.settings,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SliverComponent(
          title: Text(
            AppLocale.me.getString(context),
            style: TextStyle(
              fontSize: CustomSize.appBarTitleSize,
              color: customColors.backgroundInvertedColor,
            ),
          ),
          child: buildSettingsList([
            // Account information
            SettingsSection(
              title: Text(AppLocale.accountInfo.getString(context)),
              tiles: _buildAccountSetting(customColors),
            ),

            // Custom settings
            SettingsSection(
              title: Text(AppLocale.custom.getString(context)),
              tiles: [
                // Theme Mode
                _buildCommonThemeSetting(customColors),
                // Language
                _buildCommonLanguageSetting(),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  SettingsTile _buildCommonLanguageSetting() {
    return SettingsTile(
      title: Text(AppLocale.language.getString(context)),
      trailing: const Icon(
        CupertinoIcons.chevron_forward,
        size: 18,
        color: Colors.grey,
      ),
      onPressed: (_) {
        final current = widget.settings.stringDefault(settingLanguage, 'en');
        openModalBottomSheet(
          context,
              (context) {
            return ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocale.followSystem.getString(context)),
                      current == ''
                          ? const Icon(Icons.check, color: Colors.green)
                          : const SizedBox(),
                    ],
                  ),
                  onTap: () async {
                    await widget.settings.set(settingLanguage, '');
                    FlutterLocalization.instance
                        .translate(resolveSystemLanguage(Platform.localeName));
                    if (context.mounted) {
                      context.pop();
                    }
                  },
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tiếng Việt'),
                      current == 'vi'
                          ? const Icon(Icons.check, color: Colors.green)
                          : const SizedBox(),
                    ],
                  ),
                  onTap: () async {
                    await widget.settings.set(settingLanguage, 'vi');
                    FlutterLocalization.instance.translate('vi');
                    if (context.mounted) {
                      context.pop();
                    }
                  },
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('English'),
                      current == 'en'
                          ? const Icon(Icons.check, color: Colors.green)
                          : const SizedBox(),
                    ],
                  ),
                  onTap: () async {
                    await widget.settings.set(settingLanguage, 'en');
                    FlutterLocalization.instance.translate('en');
                    if (context.mounted) {
                      context.pop();
                    }
                  },
                ),
              ],
            );
          },
          heightFactor: 0.3,
        );
      },
    );
  }

  List<SettingsTile> _buildAccountSetting(CustomColors customColors) {
    return [
      SettingsTile(
        title: const Text(
          'Username',
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(children: [
          Text(
            AppLocale.accountSettings.getString(context),
            style: TextStyle(
              color: customColors.weakTextColor?.withAlpha(200),
              fontSize: 13,
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_forward,
            size: 18,
            color: Colors.grey,
          ),
        ]),
        onPressed: (context) {
          context.push('/setting/account-security');
        },
      ),
      SettingsTile(
        title: const Text('Free Statistics'),
        trailing: const Icon(
          CupertinoIcons.chevron_forward,
          size: 18,
          color: Colors.grey,
        ),
        onPressed: (context) {
          context.push('/free-statistics');
        },
      ),
    ];
  }

  SettingsTile _buildCommonThemeSetting(CustomColors customColors) {
    return SettingsTile.navigation(
      title: Text(AppLocale.themeMode.getString(context)),
      onPressed: (context) {
        final current =
        widget.settings.stringDefault(settingThemeMode, 'system');

        openModalBottomSheet(
          context,
              (context) {
            return ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocale.followSystem.getString(context)),
                      current == 'system'
                          ? const Icon(Icons.check, color: Colors.green)
                          : const SizedBox(),
                    ],
                  ),
                  onTap: () async {
                    await widget.settings.set(settingThemeMode, 'system');
                    AppTheme.instance.mode =
                        AppTheme.themeModeFormString('system');
                    if (context.mounted) {
                      context.pop();
                    }
                  },
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocale.lightThemeMode.getString(context)),
                      current == 'light'
                          ? const Icon(Icons.check, color: Colors.green)
                          : const SizedBox(),
                    ],
                  ),
                  onTap: () async {
                    await widget.settings.set(settingThemeMode, 'light');
                    AppTheme.instance.mode =
                        AppTheme.themeModeFormString('light');
                    if (context.mounted) {
                      context.pop();
                    }
                  },
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocale.darkThemeMode.getString(context)),
                      current == 'dark'
                          ? const Icon(Icons.check, color: Colors.green)
                          : const SizedBox(),
                    ],
                  ),
                  onTap: () async {
                    await widget.settings.set(settingThemeMode, 'dark');
                    AppTheme.instance.mode =
                        AppTheme.themeModeFormString('dark');
                    if (context.mounted) {
                      context.pop();
                    }
                  },
                ),
              ],
            );
          },
          heightFactor: 0.3,
        );
      },
    );
  }
}
