import 'package:jarvis/helper/constant.dart';

/// Chat Room
class Room {
  /// Chat room ID
  int? id;

  /// User ID
  int? userId;

  /// Avatar ID
  int? avatarId;

  /// Avatar URL
  String? avatarUrl;

  /// Chat room name
  String name;

  /// Chat room category
  String category;

  /// Display priority (sorting, the higher the value, the earlier it appears)
  int priority;

  /// Model used in the chat room
  String model;

  /// Model initialization message
  String? initMessage;

  /// Maximum context count for the model
  int maxContext;

  /// Maximum number of tokens returned by the model
  int? maxTokens;

  /// Room type: local or remote
  bool? localRoom;

  /// Chat room type
  int? roomType;

  bool get isLocalRoom => localRoom ?? false;

  /// Chat room avatar identifier
  int get avatar => (avatarId == null || avatarId == 0) ? 0 : avatarId!;

  /// Model category
  String modelCategory() {
    final segs = model.split(':');
    if (segs.length == 1) {
      return 'openai';
    }

    return segs[0];
  }

  /// Model name
  String modelName() {
    final segs = model.split(':');
    if (segs.length == 1) {
      return segs[0];
    }

    return segs[1];
  }

  /// Chat room icon
  String? iconData;

  /// Chat room icon color
  String? color;

  /// Chat room description
  String? description;

  /// System prompt
  String? systemPrompt;

  /// Chat room creation time
  DateTime? createdAt;

  /// Chat room last active time
  DateTime? lastActiveTime;

  /// List of member avatars in the chat room
  List<String> members;

  Room(
    this.name,
    this.category, {
    this.description,
    this.id,
    this.userId,
    this.avatarId,
    this.avatarUrl,
    this.createdAt,
    this.lastActiveTime,
    this.iconData,
    this.systemPrompt,
    this.priority = 0,
    this.color,
    this.roomType,
    this.initMessage,
    this.localRoom,
    this.maxContext = 10,
    this.maxTokens,
    this.model = defaultChatModel,
    this.members = const [],
  });

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'category': category,
      'model': model,
      'priority': priority,
      'icon_data': iconData,
      'color': color,
      'description': description,
      'system_prompt': systemPrompt,
      'init_message': initMessage,
      'max_context': maxContext,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'last_active_time': lastActiveTime?.millisecondsSinceEpoch,
    };
  }

  Room.fromMap(Map<String, Object?> map)
      : id = map['id'] as int,
        userId = map['user_id'] as int?,
        avatarId = map['avatar_id'] as int?,
        avatarUrl = map['avatar_url'] as String?,
        name = map['name'] as String,
        category = (map['category'] ?? '') as String,
        priority = (map['priority'] ?? 0) as int,
        model = (map['model'] ?? '') as String,
        iconData = map['icon_data'] as String?,
        color = map['color'] as String?,
        roomType = map['room_type'] as int?,
        systemPrompt = map['system_prompt'] as String?,
        description = map['description'] as String?,
        initMessage = map['init_message'] as String?,
        maxContext = map['max_context'] as int? ?? 10,
        maxTokens = map['max_tokens'] as int?,
        members = (map['members'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        createdAt =
            DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int? ?? 0),
        lastActiveTime = DateTime.fromMillisecondsSinceEpoch(
            map['last_active_time'] as int? ?? 0);
}
