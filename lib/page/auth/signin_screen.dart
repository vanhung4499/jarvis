import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis/lang/lang.dart';
import 'package:jarvis/page/component/background_container.dart';
import 'package:jarvis/page/component/password_field.dart';
import 'package:jarvis/page/component/theme/custom_size.dart';
import 'package:jarvis/page/component/theme/custom_theme.dart';
import 'package:jarvis/repo/setting_repo.dart';
import 'package:sign_in_button/sign_in_button.dart';

class SignInScreen extends StatefulWidget {
  final SettingRepository setting;
  final String? email;

  const SignInScreen({super.key, required this.setting, this.email});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      _emailController.text = widget.email!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: customColors.weakLinkColor,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
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
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15, bottom: 0),
                  child: TextFormField(
                    controller: _emailController,
                    inputFormatters: [
                      FilteringTextInputFormatter.singleLineFormatter
                    ],
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(200, 192, 192, 192)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: customColors.linkColor ?? Colors.green),
                      ),
                      floatingLabelStyle: TextStyle(
                        color: customColors.linkColor ?? Colors.green,
                      ),
                      isDense: true,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: AppLocale.email.getString(context),
                      labelStyle: const TextStyle(fontSize: 17),
                      hintText: AppLocale.accountInputTips.getString(context),
                      hintStyle: TextStyle(
                        color: customColors.textfieldHintColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15, bottom: 0),
                  child: PasswordField(
                    controller: _passwordController,
                    labelText: AppLocale.password.getString(context),
                    hintText: AppLocale.passwordInputTips.getString(context),
                  ),
                ),
                const SizedBox(height: 15),
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
                      context.go('/');
                    },
                    child: Text(
                      AppLocale.signIn.getString(context),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Forgot password
                          TextButton(
                            onPressed: () {
                              context.push(
                                  '/forgot-password?email=${_emailController.text.trim()}');
                            },
                            child: Text(
                              AppLocale.forgotPassword.getString(context),
                              style: TextStyle(
                                color: customColors.weakLinkColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          // Signup
                          TextButton(
                              onPressed: () {
                                context
                                    .push(
                                        '/signup?email=${_emailController.text.trim()}')
                                    .then((value) {
                                  if (value != null) {
                                    _emailController.text = value as String;
                                  }
                                });
                              },
                              child: Text(
                                AppLocale.createAccount.getString(context),
                                style: TextStyle(
                                  color: customColors.linkColor,
                                  fontSize: 14,
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                _buildThirdPartySignInButtons(context, customColors),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThirdPartySignInButtons(
      BuildContext context, CustomColors customColors) {
    return Column(
      children: [
        Text(
          'Or sign in with',
          style: TextStyle(
            fontSize: 13,
            color: customColors.weakTextColor?.withAlpha(80),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: SignInButton(
                Buttons.googleDark,
                // mini: true,
                // shape: const CircleBorder(),
                onPressed: () {},
              ),
            ),
            // Padding(
            //     padding: const EdgeInsets.all(10),
            //     child: SignInButton(
            //       Buttons.appleDark,
            //       mini: true,
            //       shape: const CircleBorder(),
            //       onPressed: () {},
            //     ),
            // ),
          ],
        ),
      ],
    );
  }
}
