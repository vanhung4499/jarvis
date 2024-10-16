import 'dart:io';

import 'package:jarvis/helper/haptic_feedback.dart';
import 'package:jarvis/helper/platform.dart';
import 'package:jarvis/lang/lang.dart';
import 'package:jarvis/page/component/chat/file_upload.dart';
import 'package:jarvis/page/component/dialog.dart';
import 'package:jarvis/page/component/theme/custom_size.dart';
import 'package:jarvis/repo/setting_repo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:jarvis/page/component/theme/custom_theme.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChatInput extends StatefulWidget {
  final Function(String value) onSubmit;
  final ValueNotifier<bool> enableNotifier;
  final Widget? toolbar;
  final bool enableImageUpload;
  final Function(List<FileUpload> files)? onImageSelected;
  final List<FileUpload>? selectedImageFiles;
  final Function()? onNewChat;
  final String hintText;
  final Function()? onVoiceRecordTappedEvent;
  final List<Widget> Function()? leftSideToolsBuilder;
  final Function()? onStopGenerate;
  final Function(bool hasFocus)? onFocusChange;

  const ChatInput({
    super.key,
    required this.onSubmit,
    required this.enableNotifier,
    this.enableImageUpload = true,
    this.toolbar,
    this.onNewChat,
    this.hintText = '',
    this.onVoiceRecordTappedEvent,
    this.leftSideToolsBuilder,
    this.onImageSelected,
    this.selectedImageFiles,
    this.onStopGenerate,
    this.onFocusChange,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();

  /// Used to monitor keyboard events, implement Enter to send messages, and Shift Enter to change lines.
  late final FocusNode _focusNode = FocusNode(
    onKeyEvent: (node, event) {
      if (!HardwareKeyboard.instance.isShiftPressed &&
          event.logicalKey.keyLabel == 'Enter') {
        if (event is KeyDownEvent && widget.enableNotifier.value) {
          _handleSubmit(_textController.text.trim());
        }

        return KeyEventResult.handled;
      } else {
        return KeyEventResult.ignored;
      }
    },
  );

  final maxLength = 150000;

  /// Maximum height of the chat input box
  var maxLines = 5;

  @override
  void initState() {
    super.initState();

    _textController.addListener(() {
      setState(() {});
    });

    // After the robot completes the reply, the automatic input box automatically gains focus.
    if (!PlatformTool.isAndroid() && !PlatformTool.isIOS()) {
      widget.enableNotifier.addListener(() {
        if (widget.enableNotifier.value) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: customColors.backgroundColor,
      ),
      child: Builder(builder: (context) {
        final setting = context.read<SettingRepository>();
        return SafeArea(
          child: Column(
            children: [
              if (widget.selectedImageFiles != null &&
                  widget.selectedImageFiles!.isNotEmpty)
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: widget.selectedImageFiles!
                        .map(
                          (e) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(5),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: e.file.bytes != null
                                      ? Image.memory(
                                          e.file.bytes!,
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        )
                                      : Image.file(
                                          File(e.file.path!),
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        ),
                                ),
                                if (widget.enableNotifier.value)
                                  Positioned(
                                    right: 5,
                                    top: 5,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          widget.selectedImageFiles!.remove(e);
                                          widget.onImageSelected?.call(
                                              widget.selectedImageFiles!);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color:
                                              customColors.chatRoomBackground,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 10,
                                          color: customColors.weakTextColor,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              // Toolbar
              if (widget.toolbar != null) widget.toolbar!,
              // if (widget.toolbar != null)
              const SizedBox(height: 8),
              // Chat input area
              SingleChildScrollView(
                child: Slidable(
                  startActionPane: widget.onNewChat != null
                      ? ActionPane(
                          extentRatio: 0.3,
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              autoClose: true,
                              label: AppLocale.newChat.getString(context),
                              backgroundColor: Colors.blue,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                              onPressed: (_) {
                                widget.onNewChat!();
                              },
                            ),
                            const SizedBox(width: 10),
                          ],
                        )
                      : null,
                  child: Row(
                    children: [
                      // Chat button
                      Row(
                        children: [
                          if (widget.leftSideToolsBuilder != null)
                            ...widget.leftSideToolsBuilder!(),
                          if (widget.enableNotifier.value &&
                              widget.enableImageUpload)
                            _buildImageUploadButton(
                                context, setting, customColors),
                        ],
                      ),
                      // Chat input area
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: customColors.chatInputAreaBackground,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Focus(
                                  onFocusChange: (hasFocus) {
                                    setState(() {
                                      if (hasFocus) {
                                        maxLines = 10;
                                      } else {
                                        maxLines = 5;
                                      }
                                    });

                                    widget.onFocusChange?.call(hasFocus);
                                  },
                                  child: TextFormField(
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline,
                                    maxLines: maxLines,
                                    minLines: 1,
                                    maxLength: maxLength,
                                    focusNode: _focusNode,
                                    controller: _textController,
                                    decoration: InputDecoration(
                                      hintText: widget.hintText,
                                      hintStyle: const TextStyle(
                                        fontSize:
                                            CustomSize.defaultHintTextSize,
                                      ),
                                      border: InputBorder.none,
                                      counterText: '',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Build an image upload button
  Widget _buildImageUploadButton(
    BuildContext context,
    SettingRepository setting,
    CustomColors customColors,
  ) {
    return IconButton(
      onPressed: () async {
        HapticFeedbackHelper.mediumImpact();
        if (widget.selectedImageFiles != null &&
            widget.selectedImageFiles!.length >= 4) {
          showSuccessMessage('最多只能上传 4 张图片');
          return;
        }

        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: true,
        );
        if (result != null && result.files.isNotEmpty) {
          final files = widget.selectedImageFiles ?? [];
          files.addAll(result.files.map((e) => FileUpload(file: e)).toList());
          widget.onImageSelected
              ?.call(files.sublist(0, files.length > 4 ? 4 : files.length));
        }
      },
      icon: const Icon(Icons.camera_alt),
      color: customColors.chatInputPanelText,
      splashRadius: 20,
      tooltip: AppLocale.uploadImage.getString(context),
    );
  }

  /// Handle the send button
  void _handleSubmit(String text, {bool notSend = false}) {
    if (notSend) {
      var cursorPos = _textController.selection.base.offset;
      if (cursorPos < 0) {
        _textController.text = text;
      } else {
        String suffixText = _textController.text.substring(cursorPos);
        String prefixText = _textController.text.substring(0, cursorPos);
        _textController.text = prefixText + text + suffixText;
        _textController.selection = TextSelection(
          baseOffset: cursorPos + text.length,
          extentOffset: cursorPos + text.length,
        );
      }

      _focusNode.requestFocus();

      return;
    }

    if (text != '') {
      widget.onSubmit(text);
      _textController.clear();
    }
  }
}
