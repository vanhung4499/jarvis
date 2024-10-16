import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis/lang/lang.dart';
import 'package:jarvis/page/component/background_container.dart';
import 'package:jarvis/page/component/password_field.dart';
import 'package:jarvis/page/component/theme/custom_size.dart';
import 'package:jarvis/page/component/theme/custom_theme.dart';
import 'package:jarvis/repo/setting_repo.dart';

class ResetPasswordScreen extends StatefulWidget {
  final SettingRepository setting;

  const ResetPasswordScreen({super.key, required this.setting});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _verifyPasswordController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _verifyPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: CustomSize.toolbarHeight,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
      ),
      backgroundColor: customColors.backgroundColor,
      body: BackgroundContainer(
        setting: widget.setting,
        enabled: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Image.asset('assets/app.png'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedTextKit(
                    animatedTexts: [
                      ColorizeAnimatedText(
                        'Jarvis',
                        textStyle: const TextStyle(fontSize: 30.0),
                        colors: [
                          Colors.purple,
                          Colors.blue,
                          Colors.yellow,
                          Colors.red,
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Password
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 15, bottom: 0),
                    child: PasswordField(
                      controller: _passwordController,
                      labelText: AppLocale.password.getString(context),
                      hintText: AppLocale.passwordInputTips.getString(context),
                    ),
                  ),
                  // Verify password
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 15, bottom: 0),
                    child: PasswordField(
                      controller: _verifyPasswordController,
                      labelText: AppLocale.passwordConfirm.getString(context),
                      hintText: AppLocale.passwordInputTips.getString(context),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Signup button
                  Container(
                    height: 45,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: customColors.linkColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      child: Text(
                        AppLocale.resetPassword.getString(context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
