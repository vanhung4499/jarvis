import 'package:jarvis/helper/constant.dart';
import 'package:jarvis/helper/logger.dart';
import 'package:jarvis/repo/api_server.dart';
import 'package:jarvis/repo/chat_message_repo.dart';
import 'package:jarvis/repo/model/chat_history.dart';
import 'package:loading_more_list/loading_more_list.dart';

class ChatHistoryDatasource extends LoadingMoreBase<ChatHistory> {
  int pageIndex = 1;
  bool _hasMore = true;
  bool forceRefresh = false;

  final ChatMessageRepository repo;
  ChatHistoryDatasource(this.repo);

  @override
  bool get hasMore => (_hasMore && length < 300) || forceRefresh;

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    try {
      final histories = await repo.recentChatHistories(
        chatAnywhereRoomId,
        30,
        offset: 30 * (pageIndex - 1),
        userId: APIServer().localUserID(),
      );

      if (pageIndex == 1) {
        clear();
      }

      for (var element in histories) {
        add(element);
      }

      if (histories.isEmpty) {
        _hasMore = false;
      }

      pageIndex = pageIndex + 1;
      return true;
    } catch (e) {
      Logger.instance.e(e);
      return false;
    }
  }

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _hasMore = true;
    pageIndex = 1;
    //force to refresh list when you don't want clear list before request
    //for the case, if your list already has 20 items.
    forceRefresh = !notifyStateChanged;
    var result = await super.refresh(notifyStateChanged);
    forceRefresh = false;
    return result;
  }
}
