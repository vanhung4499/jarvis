import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis/lang/lang.dart';
import 'package:jarvis/page/component/background_container.dart';
import 'package:jarvis/page/component/theme/custom_size.dart';
import 'package:jarvis/page/component/theme/custom_theme.dart';
import 'package:jarvis/repo/setting_repo.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final SettingRepository setting;
  final String? email;

  const ForgotPasswordScreen({super.key, required this.setting, this.email});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();

}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

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
          icon: Icon(
            Icons.arrow_back_ios,
            color: customColors.weakLinkColor,
          ),
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
                  // Username
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
                              color: Color.fromARGB(255, 192, 192, 192)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: customColors.linkColor!),
                        ),
                        floatingLabelStyle:
                        TextStyle(color: customColors.linkColor!),
                        isDense: true,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: AppLocale.email.getString(context),
                        hintText: AppLocale.accountInputTips.getString(context),
                        hintStyle: TextStyle(
                          color: customColors.textfieldHintColor,
                          fontSize: 15,
                        ),
                      ),
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
                        context.go('/verify-code');
                      },
                      child: Text(
                        AppLocale.forgotPassword.getString(context),
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
