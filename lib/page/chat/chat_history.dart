import 'package:jarvis/lang/lang.dart';
import 'package:jarvis/page/chat/home.dart';
import 'package:jarvis/page/component/background_container.dart';
import 'package:jarvis/page/component/loading.dart';
import 'package:jarvis/page/data/chat_history_datasource.dart';
import 'package:jarvis/page/component/theme/custom_size.dart';
import 'package:jarvis/page/component/theme/custom_theme.dart';
import 'package:jarvis/repo/chat_message_repo.dart';
import 'package:jarvis/repo/model/chat_history.dart';
import 'package:jarvis/repo/setting_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_more_list/loading_more_list.dart';

class ChatHistoryPage extends StatefulWidget {
  final SettingRepository setting;
  final ChatMessageRepository chatMessageRepo;

  const ChatHistoryPage(
      {super.key, required this.setting, required this.chatMessageRepo});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  late final ChatHistoryDatasource datasource;

  @override
  void initState() {
    datasource = ChatHistoryDatasource(widget.chatMessageRepo);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocale.histories.getString(context),
          style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
        ),
        toolbarHeight: CustomSize.toolbarHeight,
        centerTitle: true,
      ),
      backgroundColor: customColors.backgroundContainerColor,
      body: BackgroundContainer(
        setting: widget.setting,
        enabled: false,
        child: SafeArea(
          top: false,
          left: false,
          right: false,
          child: RefreshIndicator(
            color: customColors.linkColor,
            onRefresh: () async {
              await datasource.refresh();
            },
            child: RefreshIndicator(
              color: customColors.linkColor,
              displacement: 20,
              onRefresh: () {
                return datasource.refresh();
              },
              child: LoadingMoreList(
                ListConfig<ChatHistory>(
                  itemBuilder: (context, item, index) {
                    return ChatHistoryItem(
                      history: item,
                      customColors: customColors,
                      onTap: () {
                        context.push(
                            '/chat-anywhere?chat_id=${item.id}&model=${item.model}&title=${item.title}');
                      },
                    );
                  },
                  sourceList: datasource,
                  indicatorBuilder: (context, status) {
                    String msg = '';
                    switch (status) {
                      case IndicatorStatus.noMoreLoad:
                        msg = '~ No more ~';
                        break;
                      case IndicatorStatus.loadingMoreBusying:
                        msg = 'Loading...';
                        break;
                      case IndicatorStatus.error:
                        msg = 'Loading failed, please try again later';
                        break;
                      case IndicatorStatus.empty:
                        msg = 'No data yet';
                        break;
                      default:
                        return const Center(child: LoadingIndicator());
                    }
                    return Container(
                      padding: const EdgeInsets.all(15),
                      alignment: Alignment.center,
                      child: Text(
                        msg,
                        style: TextStyle(
                          color: customColors.weakTextColor,
                          fontSize: 14,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
