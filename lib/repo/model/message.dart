import 'dart:convert';

import 'package:jarvis/helper/helper.dart';

/// Chat messages
class Message {
  /// Chat room ID
  int? roomId;

  /// User ID
  int? userId;

  /// Chat history ID
  int? chatHistoryId;

  /// Message ID
  int? id;

  /// Message role
  Role role;

  /// Message text
  String text;

  /// Message additional information, used to provide model-related information
  String? extra;

  /// AI model
  String? model;

  /// Message type
  MessageType type;

  /// Sender
  String? user;

  /// Message timestamp
  DateTime? ts;

  /// Associated message ID (issue ID)
  int? refId;

  /// Server ID
  int? serverId;

  /// Message status: 1-success 0-waiting for response 2-failure
  int status;

  /// Quota for message consumption
  int? quotaConsumed;

  /// Message consumed token
  int? tokenConsumed;

  /// Whether the current message is ready and does not require persistence
  bool isReady = true;

  /// The avatar of the message sender, does not need to be persisted
  String? avatarUrl;

  /// The name of the message sender, no persistence required
  String? senderName;

  /// Message image list
  List<String>? images;

  Message(
    this.role,
    this.text, {
    required this.type,
    this.userId,
    this.chatHistoryId,
    this.id,
    this.user,
    this.ts,
    this.model,
    this.roomId,
    this.extra,
    this.refId,
    this.serverId,
    this.status = 1,
    this.quotaConsumed,
    this.tokenConsumed,
    this.avatarUrl,
    this.senderName,
    this.images,
  });

  /// 获取消息附加信息
  void setExtra(dynamic data) {
    extra = jsonEncode(data);
  }

  /// Decode extra information
  decodeExtra() {
    if (extra == null) {
      return null;
    }

    return jsonDecode(extra!);
  }

  /// Check if the message is a system message, timeline, or context break
  bool isSystem() {
    return type == MessageType.system ||
        type == MessageType.timeline ||
        type == MessageType.contextBreak;
  }

  /// Is it an initial message?
  bool isInitMessage() {
    return type == MessageType.initMessage;
  }

  /// Is it a timeline message?
  bool isTimeline() {
    return type == MessageType.timeline;
  }

  /// Format the message time
  String friendlyTime() {
    return humanTime(ts);
  }

  /// Is it a failed message
  bool statusIsFailed() {
    return status == 2;
  }

  /// Is it successful
  bool statusIsSucceed() {
    return status == 1;
  }

  /// Is it pending
  bool statusPending() {
    return status == 0;
  }

  String get markdownWithImages {
    var t = text;
    if (images != null && images!.isNotEmpty) {
      t = images!.map((e) => '![img]($e)\n\n').join('') + t;
    }

    return t;
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'chat_history_id': chatHistoryId,
      'role': role.getRoleText(),
      'text': text,
      'type': type.getTypeText(),
      'extra': extra,
      'model': model,
      'user': user,
      'ts': ts?.millisecondsSinceEpoch,
      'room_id': roomId,
      'ref_id': refId,
      'server_id': serverId,
      'status': status,
      'token_consumed': tokenConsumed,
      'quota_consumed': quotaConsumed,
      'images': images != null ? jsonEncode(images) : null,
    };
  }

  Message.fromMap(Map<String, Object?> map)
      : id = map['id'] as int,
        userId = map['user_id'] as int?,
        chatHistoryId = map['chat_history_id'] as int?,
        role = Role.getRoleFromText(map['role'] as String),
        text = map['text'] as String,
        extra = map['extra'] as String?,
        model = map['model'] as String?,
        type = MessageType.getTypeFromText(map['type'] as String),
        user = map['user'] as String?,
        refId = map['ref_id'] as int?,
        serverId = map['server_id'] as int?,
        status = (map['status'] ?? 1) as int,
        tokenConsumed = map['token_consumed'] as int?,
        quotaConsumed = map['quota_consumed'] as int?,
        ts = map['ts'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(map['ts'] as int),
        roomId = map['room_id'] as int?,
        images = map['images'] == null
            ? null
            : (jsonDecode(map['images'] as String) as List<dynamic>)
                .cast<String>();
}

enum Role {
  receiver,
  sender;

  static Role getRoleFromText(String value) {
    switch (value) {
      case 'receiver':
        return Role.receiver;
      case 'assistant':
        return Role.receiver;
      case 'sender':
        return Role.sender;
      case 'user':
        return Role.sender;
      default:
        return Role.receiver;
    }
  }

  String getRoleText() {
    switch (this) {
      case Role.receiver:
        return 'receiver';
      case Role.sender:
        return 'sender';
      default:
        return 'receiver';
    }
  }
}

enum MessageType {
  text,
  image,
  file,
  audio,
  video,
  location,
  command,
  system,
  timeline,
  contextBreak,
  hide,
  initMessage;

  String getTypeText() {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.file:
        return 'file';
      case MessageType.audio:
        return 'audio';
      case MessageType.video:
        return 'video';
      case MessageType.location:
        return 'location';
      case MessageType.command:
        return 'command';
      case MessageType.system:
        return 'system';
      case MessageType.timeline:
        return 'timeline';
      case MessageType.contextBreak:
        return 'contextBreak';
      case MessageType.hide:
        return 'hide';
      case MessageType.initMessage:
        return 'initMessage';
      default:
        return 'text';
    }
  }

  static MessageType getTypeFromText(String value) {
    switch (value) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'audio':
        return MessageType.audio;
      case 'video':
        return MessageType.video;
      case 'location':
        return MessageType.location;
      case 'command':
        return MessageType.command;
      case 'system':
        return MessageType.system;
      case 'timeline':
        return MessageType.timeline;
      case 'contextBreak':
        return MessageType.contextBreak;
      case 'hide':
        return MessageType.hide;
      case 'initMessage':
        return MessageType.initMessage;
      default:
        return MessageType.text;
    }
  }
}
