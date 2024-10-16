import 'dart:async';

import 'package:jarvis/helper/logger.dart';
import 'package:jarvis/lang/lang.dart';
import 'package:jarvis/page/component/background_container.dart';
import 'package:jarvis/page/component/enhanced_popup_menu.dart';
import 'package:jarvis/page/component/dialog.dart';
import 'package:jarvis/page/component/theme/custom_size.dart';
import 'package:jarvis/page/component/theme/custom_theme.dart';
import 'package:jarvis/repo/api_server.dart';
import 'package:jarvis/repo/setting_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:settings_ui/settings_ui.dart';

class AccountSecurityScreen extends StatefulWidget {
  final SettingRepository setting;

  const AccountSecurityScreen({super.key, required this.setting});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  var wechatInstalled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return BackgroundContainer(
      setting: widget.setting,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: CustomSize.toolbarHeight,
          title: const Text(
            'Account Settings',
            style: TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
          centerTitle: true,
          actions: [
            EnhancedPopupMenu(
              items: [
                EnhancedPopupMenuItem(
                  title: 'Delete Account',
                  icon: Icons.delete_forever,
                  iconColor: Colors.red,
                  onTap: (ctx) {
                    context.push('/user/destroy');
                  },
                ),
              ],
            )
          ],
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: buildSettingsList([
            SettingsSection(
              title: const Text('Basic information'),
              tiles: [
                SettingsTile(
                  title: const Text('Username'),
                  trailing: Row(
                    children: [
                      Text(
                        "Username",
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
                    ],
                  ),
                  onPressed: (context) {
                    openTextFieldDialog(
                      context,
                      title: 'Set your username',
                      hint: 'Please enter your username',
                      maxLine: 1,
                      maxLength: 30,
                      defaultValue: 'Username',
                      onSubmit: (value) {
                        return true;
                      },
                    );
                  },
                ),
                SettingsTile(
                  title: Text(AppLocale.resetPassword.getString(context)),
                  trailing: const Icon(
                    CupertinoIcons.chevron_forward,
                    size: 18,
                    color: Colors.grey,
                  ),
                  onPressed: (context) {
                    context.push('/user/reset-password');
                  },
                ),
              ],
            ),
            SettingsSection(
              tiles: [
                SettingsTile(
                  title: Text(AppLocale.signOut.getString(context)),
                  trailing: const Icon(
                    Icons.logout,
                    size: 18,
                    color: Colors.grey,
                  ),
                  onPressed: (_) {
                    openConfirmDialog(
                      context,
                      AppLocale.confirmSignOut.getString(context),
                      () {
                        // context.go('/login');
                      },
                      danger: true,
                    );
                  },
                ),
              ],
            ),
          ]),

          // return const Center(child: CircularProgressIndicator());
        ),
      ),
    );
  }
}

SettingsList buildSettingsList(List<AbstractSettingsSection> sections) {
  return SettingsList(
    platform: DevicePlatform.iOS,
    lightTheme: const SettingsThemeData(
      settingsListBackground: Colors.transparent,
      settingsSectionBackground: Color.fromARGB(255, 255, 255, 255),
    ),
    darkTheme: const SettingsThemeData(
      settingsListBackground: Colors.transparent,
      settingsSectionBackground: Color.fromARGB(255, 27, 27, 27),
      titleTextColor: Color.fromARGB(255, 239, 239, 239),
    ),
    sections: sections,
    contentPadding: const EdgeInsets.all(0),
  );
}
