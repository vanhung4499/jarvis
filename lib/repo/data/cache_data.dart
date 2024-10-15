import 'package:sqflite/sqflite.dart';

class CacheDataProvider {
  Database conn;
  CacheDataProvider(this.conn);

  /// Setup cache
  Future<void> set(
      String key,
      String value,
      Duration ttl, {
        String? group,
      }) async {
    await conn.delete('cache', where: 'key = ?', whereArgs: [key]);
    await conn.insert('cache', <String, Object?>{
      'key': key,
      'value': value,
      'group': group,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'valid_before': DateTime.now().add(ttl).millisecondsSinceEpoch,
    });
  }

  Future<Map<String, String>> getAllInGroup(String group) async {
    List<Map<String, Object?>> cacheValue = await conn.query(
      'cache',
      where: '`group` = ? AND valid_before >= ?',
      whereArgs: [group, DateTime.now().millisecondsSinceEpoch],
    );

    if (cacheValue.isEmpty) {
      return {};
    }

    Map<String, String> ret = {};
    for (var item in cacheValue) {
      ret[item['key'] as String] = item['value'] as String;
    }

    return ret;
  }

  // Query cache value
  Future<String?> get(String key) async {
    List<Map<String, Object?>> cacheValue = await conn.query(
      'cache',
      where: 'key = ? AND valid_before >= ?',
      whereArgs: [key, DateTime.now().millisecondsSinceEpoch],
      limit: 1,
    );

    if (cacheValue.isEmpty) {
      return null;
    }

    return cacheValue.first['value'] as String;
  }

  /// Remove cache
  Future<void> remove(String key) async {
    await conn.delete('cache', where: 'key = ?', whereArgs: [key]);
  }

  /// Clean expired cache keys
  Future<void> gc() async {
    await conn.delete(
      'cache',
      where: 'valid_before < ?',
      whereArgs: [DateTime.now().millisecondsSinceEpoch],
    );
  }

  /// Clear all cache
  Future<void> clearAll() async {
    await conn.delete('cache');
  }
}
