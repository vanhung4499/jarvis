import 'dart:async';
import 'dart:io';

import 'package:jarvis/helper/haptic_feedback.dart';
import 'package:jarvis/helper/helper.dart';
import 'package:jarvis/helper/path.dart';
import 'package:jarvis/helper/platform.dart';
import 'package:jarvis/lang/lang.dart';
import 'package:jarvis/page/component/chat/markdown.dart';
import 'package:jarvis/page/component/loading.dart';
import 'package:jarvis/page/component/dialog.dart';
import 'package:jarvis/page/component/theme/custom_theme.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quickalert/quickalert.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher_string.dart';

class VoiceRecord extends StatefulWidget {
  final Function(String text) onFinished;
  final Function() onStart;
  const VoiceRecord(
      {super.key, required this.onFinished, required this.onStart});

  @override
  State<VoiceRecord> createState() => _VoiceRecordState();
}

class _VoiceRecordState extends State<VoiceRecord> {
  var _voiceRecording = false;
  final record = AudioRecorder();
  DateTime? _voiceStartTime;
  Timer? _timer;
  var _millSeconds = 0;

  @override
  void initState() {
    super.initState();
    record.hasPermission().then((hasPermission) {
      if (!hasPermission) {
        showErrorMessage('Please grant recording permission');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    record.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 90,
          child: _voiceRecording
              ? Column(
                  children: [
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: const Color.fromARGB(255, 74, 74, 254),
                      size: 60,
                    ),
                    const SizedBox(height: 10),
                    Text('${(_millSeconds / 1000.0).toStringAsFixed(3)} s'),
                  ],
                )
              : const SizedBox(),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onLongPressStart: (details) async {
            if (PlatformTool.isWeb()) {
              showCustomBeautyDialog(
                context,
                type: QuickAlertType.warning,
                confirmBtnText: AppLocale.gotIt.getString(context),
                showCancelBtn: false,
                title: 'Tips',
                child: Markdown(
                  data:
                      'Web version does not support voice input yet, so stay tuned. \n\nTo experience the full functionality, please use mobile app.',
                  onUrlTap: (value) {
                    launchUrlString(
                      value,
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  textStyle: TextStyle(
                    fontSize: 14,
                    color: customColors.dialogDefaultTextColor,
                  ),
                ),
              );
              return;
            }

            widget.onStart();

            if (await record.hasPermission()) {
              // 震动反馈
              HapticFeedbackHelper.heavyImpact();

              setState(() {
                _voiceRecording = true;
                _voiceStartTime = DateTime.now();
              });
              // Start recording
              await record.start(
                RecordConfig(
                  encoder: PlatformTool.isWindows() || PlatformTool.isIOS()
                      ? AudioEncoder.aacLc
                      : AudioEncoder.wav,
                ),
                path: "${PathHelper().getCachePath}/${randomId()}.m4a",
              );

              setState(() {
                _millSeconds = 0;
              });
              if (_timer != null) {
                _timer!.cancel();
                _timer = null;
              }

              _timer = Timer.periodic(const Duration(milliseconds: 100),
                  (timer) async {
                if (_voiceStartTime == null) {
                  timer.cancel();
                  return;
                }

                if (DateTime.now().difference(_voiceStartTime!).inSeconds >=
                    60) {
                  await onRecordStop();
                  return;
                }

                setState(() {
                  _millSeconds = DateTime.now()
                      .difference(_voiceStartTime!)
                      .inMilliseconds;
                });
              });
            }
          },
          onLongPressEnd: (details) async {
            if (!_voiceRecording) {
              return;
            }

            setState(() {
              _voiceRecording = false;
            });

            await onRecordStop();
          },
          child: SizedBox(
            height: 80,
            width: 80,
            child: CircleAvatar(
              backgroundColor: _voiceRecording
                  ? customColors.linkColor
                  : customColors.linkColor?.withAlpha(200),
              child: const Icon(
                Icons.mic,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          AppLocale.longPressSpeak.getString(context),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  deleteTempFile(String path) {
    // Delete temp file
    if (!path.startsWith('blob:')) {
      try {
        File.fromUri(Uri.parse(path)).deleteSync();
      } catch (e) {
        try {
          File(path).deleteSync();
        } catch (e) {
          // ignore
        }
      }
    }
  }

  Future onRecordStop() async {
    _timer?.cancel();

    var resPath = await record.stop();
    if (resPath == null) {
      showErrorMessage('Record failed');
      return;
    }

    resPath = resPath.replaceAll('\\', '/');

    final voiceDuration = DateTime.now().difference(_voiceStartTime!).inSeconds;
    if (voiceDuration < 1) {
      showErrorMessage('Talking time is too short');
      _voiceStartTime = null;
      deleteTempFile(resPath);
      return;
    }

    if (voiceDuration > 60) {
      showErrorMessage('Talking time is too long');
      _voiceStartTime = null;
      deleteTempFile(resPath);
      return;
    }

    _voiceStartTime = null;

    final cancel = BotToast.showCustomLoading(
      toastBuilder: (cancel) {
        return LoadingIndicator(
          message: AppLocale.processingWait.getString(context),
        );
      },
      allowClick: false,
      duration: const Duration(seconds: 120),
    );

    try {
      File audioFile;
      try {
        audioFile = File.fromUri(Uri.parse(resPath));
      } catch (e) {
        audioFile = File(resPath);
      }

      // TODO: Implement handling of audio file
      // widget.onFinished();
    } catch (e) {
      // ignore: use_build_context_synchronously
      showErrorMessageEnhanced(context, e);
    } finally {
      cancel();
      deleteTempFile(resPath);
    }
  }
}
