
import 'package:jarvis/helper/haptic_feedback.dart';
import 'package:jarvis/helper/helper.dart';
import 'package:jarvis/lang/lang.dart';
import 'package:jarvis/page/component/background_container.dart';
import 'package:jarvis/page/component/chat/empty.dart';
import 'package:jarvis/page/component/chat/voice_record.dart';
import 'package:jarvis/page/component/column_block.dart';
import 'package:jarvis/page/component/enhanced_textfield.dart';
import 'package:jarvis/page/component/sliver_component.dart';
import 'package:jarvis/page/component/dialog.dart';
import 'package:jarvis/page/component/theme/custom_size.dart';
import 'package:jarvis/page/component/theme/custom_theme.dart';
import 'package:jarvis/repo/model/chat_history.dart';
import 'package:jarvis/repo/model/misc.dart';
import 'package:jarvis/repo/setting_repo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  final SettingRepository setting;
  final bool showInitialDialog;
  final int? reward;

  const HomePage({
    super.key,
    required this.setting,
    this.showInitialDialog = false,
    this.reward,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class ChatModel {
  String id;
  String name;
  Color backgroundColor;
  String backgroundImage;

  ChatModel({
    required this.id,
    required this.name,
    required this.backgroundColor,
    required this.backgroundImage,
  });
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatHistory> histories = [];
  final List<ChatExample>? examples = [];

  /// Maximum height of the chat input box
  int inputMaxLines = 6;

  /// Used to monitor keyboard events, implement Enter to send messages, and Shift Enter to change lines.
  late final FocusNode _focusNode = FocusNode(
    onKeyEvent: (node, event) {
      if (!HardwareKeyboard.instance.isShiftPressed &&
          event.logicalKey.keyLabel == 'Enter') {
        if (event is KeyDownEvent) {
          onSubmit(context, _textController.text.trim());
        }

        return KeyEventResult.handled;
      } else {
        return KeyEventResult.ignored;
      }
    },
  );

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _textController.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;
    return BackgroundContainer(
      setting: widget.setting,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SliverSingleComponent(
          title: Text(
            AppLocale.chatAnywhere.getString(context),
            style: TextStyle(
              fontSize: CustomSize.appBarTitleSize,
              color: customColors.backgroundInvertedColor,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                context.push('/chat/history');
              },
            ),
          ],
          backgroundImage: Image.asset(
            customColors.appBarBackgroundImage!,
            fit: BoxFit.cover,
          ),
          appBarExtraWidgets: () {
            return [
              SliverStickyHeader(
                header: SafeArea(
                  top: false,
                  child: buildChatComponents(customColors, context),
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) {
                        return SafeArea(
                          top: false,
                          bottom: false,
                          child: Container(
                            margin: const EdgeInsets.only(top: 10, left: 15),
                            child: Text(
                              AppLocale.histories.getString(context),
                              style: TextStyle(
                                color:
                                    customColors.weakTextColor?.withAlpha(100),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }

                      if (index == histories.length && index > 3) {
                        return SafeArea(
                          top: false,
                          bottom: false,
                          child: GestureDetector(
                            onTap: () {
                              context.push('/chat-chat/history');
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(top: 5, bottom: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.keyboard_double_arrow_left,
                                    size: 12,
                                    color: customColors.weakTextColor!
                                        .withAlpha(120),
                                  ),
                                  Text(
                                    "View more",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: customColors.weakTextColor!
                                          .withAlpha(120),
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_double_arrow_right,
                                    size: 12,
                                    color: customColors.weakTextColor!
                                        .withAlpha(120),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return SafeArea(
                        top: false,
                        bottom: false,
                        child: ChatHistoryItem(
                          history: histories[index - 1],
                          customColors: customColors,
                          onTap: () {
                            context.push('/chat-anywhere?chat_id=${1}');
                          },
                        ),
                      );
                    },
                    childCount: histories.isNotEmpty ? histories.length + 1 : 0,
                  ),
                ),
              ),
            ];
          },
        ),
      ),
    );
  }

  Container buildChatComponents(
    CustomColors customColors,
    BuildContext context,
  ) {
    return Container(
      color: customColors.backgroundContainerColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chat text area
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
            ),
            child: ColumnBlock(
              padding: const EdgeInsets.only(
                top: 5,
                bottom: 5,
                left: 15,
                right: 15,
              ),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chat question input box
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 12,
                              right: 4,
                            ),
                            child: Icon(
                              Icons.circle,
                              color: customColors.weakTextColor,
                              size: 10,
                            ),
                          ),
                        Expanded(
                          child: EnhancedTextField(
                            onFocusChange: (hasFocus) {
                              if (hasFocus) {
                                setState(() {
                                  inputMaxLines = 15;
                                });
                              } else {
                                setState(() {
                                  inputMaxLines = 6;
                                });
                              }
                            },
                            focusNode: _focusNode,
                            controller: _textController,
                            customColors: customColors,
                            maxLines: inputMaxLines,
                            minLines: 6,
                            hintText:
                                AppLocale.askMeAnyQuestion.getString(context),
                            maxLength: 150000,
                            showCounter: false,
                            hintColor: customColors.textfieldHintDeepColor,
                            hintTextSize: 15,
                          ),
                        ),
                      ],
                    ),
                    // Chat control toolbar
                    Container(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: _buildSendOrVoiceButton(
                        context,
                        customColors,
                      ),
                    ),
                    // SizedBox(
                    //   height: 110,
                    //   child: ListView(
                    //     scrollDirection: Axis.horizontal,
                    //     children: selectedImageFiles
                    //         .map(
                    //           (e) => Container(
                    //             margin: const EdgeInsets.only(right: 8),
                    //             padding: const EdgeInsets.all(5),
                    //             child: Stack(
                    //               children: [
                    //                 ClipRRect(
                    //                   borderRadius: BorderRadius.circular(5),
                    //                   child: e.file.bytes != null
                    //                       ? Image.memory(
                    //                           e.file.bytes!,
                    //                           fit: BoxFit.cover,
                    //                           width: 100,
                    //                           height: 100,
                    //                         )
                    //                       : Image.file(
                    //                           File(e.file.path!),
                    //                           fit: BoxFit.cover,
                    //                           width: 100,
                    //                           height: 100,
                    //                         ),
                    //                 ),
                    //                 Positioned(
                    //                   right: 5,
                    //                   top: 5,
                    //                   child: InkWell(
                    //                     onTap: () {
                    //                       setState(() {
                    //                         selectedImageFiles.remove(e);
                    //                       });
                    //                     },
                    //                     child: Container(
                    //                       padding: const EdgeInsets.all(3),
                    //                       decoration: BoxDecoration(
                    //                         borderRadius:
                    //                             BorderRadius.circular(10),
                    //                         color:
                    //                             customColors.chatRoomBackground,
                    //                       ),
                    //                       child: Icon(
                    //                         Icons.close,
                    //                         size: 10,
                    //                         color: customColors.weakTextColor,
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         )
                    //         .toList(),
                    //   ),
                    // )
                  ],
                )
              ],
            ),
          ),
          // Container(
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(10),
          //   ),
          //   padding:
          //       const EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 3),
          //   margin: const EdgeInsets.all(10),
          //   height: 260,
          //   child: Column(
          //     mainAxisSize: MainAxisSize.min,
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Row(
          //         children: [
          //           Image.asset(
          //             'assets/app-256-transparent.png',
          //             width: 20,
          //             height: 20,
          //           ),
          //           const SizedBox(width: 5),
          //           Text(
          //             AppLocale.askMeLikeThis.getString(context),
          //             style: TextStyle(
          //               fontSize: 16,
          //               fontWeight: FontWeight.bold,
          //               color: customColors.textfieldHintDeepColor,
          //             ),
          //           ),
          //         ],
          //       ),
          //       const SizedBox(height: 20),
          //       Expanded(
          //         child: ListView.separated(
          //           padding: const EdgeInsets.all(0),
          //           itemCount: examples!.length > 4 ? 4 : examples!.length,
          //           physics: const NeverScrollableScrollPhysics(),
          //           itemBuilder: (context, index) {
          //             return ListTextItem(
          //               title: examples![index].title,
          //               onTap: () {
          //                 onSubmit(
          //                   context,
          //                   examples![index].text,
          //                 );
          //               },
          //               customColors: customColors,
          //             );
          //           },
          //           separatorBuilder: (BuildContext context, int index) {
          //             return Divider(
          //               color: customColors.chatExampleItemText?.withAlpha(20),
          //             );
          //           },
          //         ),
          //       ),
          //       Align(
          //         alignment: Alignment.centerRight,
          //         child: TextButton(
          //           style: ButtonStyle(
          //             overlayColor: WidgetStateProperty.all(Colors.transparent),
          //           ),
          //           onPressed: () {
          //             setState(() {
          //               examples!.shuffle();
          //             });
          //           },
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.end,
          //             children: [
          //               Icon(
          //                 Icons.refresh,
          //                 color: customColors.weakTextColor,
          //                 size: 16,
          //               ),
          //               const SizedBox(width: 3),
          //               Text(
          //                 AppLocale.refresh.getString(context),
          //                 style: TextStyle(
          //                   color: customColors.weakTextColor,
          //                 ),
          //                 textScaler: const TextScaler.linear(0.9),
          //               ),
          //             ],
          //           ),
          //         ),
          //       )
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  /// Build a send or voice button
  Widget _buildSendOrVoiceButton(
    BuildContext context,
    CustomColors customColors,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () {
                HapticFeedbackHelper.mediumImpact();

                openModalBottomSheet(
                  context,
                  (context) {
                    return VoiceRecord(
                      onFinished: (text) {
                        _textController.text = _textController.text + text;
                        Navigator.pop(context);
                      },
                      onStart: () {},
                    );
                  },
                  isScrollControlled: false,
                  heightFactor: 0.8,
                );
              },
              child: Icon(
                Icons.mic,
                color: customColors.chatInputPanelText,
                size: 28,
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () async {
                // Upload images
                HapticFeedbackHelper.mediumImpact();

                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  allowMultiple: true,
                );
              },
              child: Icon(
                Icons.camera_alt,
                color: customColors.chatInputPanelText,
                size: 28,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: () {
            onSubmit(context, _textController.text.trim());
          },
          child: Icon(
            Icons.send,
            color: _textController.text.trim().isNotEmpty
                ? customColors.linkColor ??
                    const Color.fromARGB(255, 70, 165, 73)
                : customColors.chatInputPanelText,
            size: 26,
          ),
        )
      ],
    );
  }

  void onSubmit(BuildContext context, String text) {
    if (text.trim().isEmpty) {
      return;
    }

    context
        .push(Uri(path: '/chat-anywhere', queryParameters: {
      'init_message': text,
    }).toString())
        .whenComplete(() {
      _textController.clear();

      FocusScope.of(context).requestFocus(FocusNode());
    });
  }
}

class ChatHistoryItem extends StatelessWidget {
  const ChatHistoryItem({
    super.key,
    required this.history,
    required this.customColors,
    required this.onTap,
  });

  final ChatHistory history;
  final CustomColors customColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            const SizedBox(width: 10),
            SlidableAction(
              label: AppLocale.delete.getString(context),
              borderRadius: BorderRadius.circular(10),
              backgroundColor: Colors.red,
              icon: Icons.delete,
              onPressed: (_) {
                openConfirmDialog(
                  context,
                  AppLocale.confirmDelete.getString(context),
                  () {},
                  danger: true,
                );
              },
            ),
          ],
        ),
        child: Material(
          color: customColors.backgroundColor?.withAlpha(200),
          borderRadius: BorderRadius.all(
            Radius.circular(customColors.borderRadius ?? 8),
          ),
          child: InkWell(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(customColors.borderRadius ?? 8),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      (history.title ?? 'Untitle').trim(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: customColors.weakTextColor,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  Text(
                    humanTime(history.updatedAt),
                    style: TextStyle(
                      color: customColors.weakTextColor?.withAlpha(65),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              dense: true,
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  (history.lastMessage ?? 'Not chat yet')
                      .trim()
                      .replaceAll("\n", " "),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: customColors.weakTextColor?.withAlpha(150),
                    fontSize: 12,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              onTap: () {
                HapticFeedbackHelper.lightImpact();
                onTap();
              },
            ),
          ),
        ),
      ),
    );
  }
}
