// Database initialization
void initDatabase(db, version) async {
  await db.execute('''
      CREATE TABLE setting (
        `key` TEXT NOT NULL PRIMARY KEY,
        `value` TEXT NOT NULL
      );
  ''');

  await db.execute('''
        CREATE TABLE cache (
          `key` TEXT NOT NULL PRIMARY KEY,
          `value` TEXT NOT NULL,
          `group` TEXT NULL,
          `created_at` INTEGER,
          `valid_before` INTEGER
        )
      ''');

  await db.execute('''
        CREATE TABLE chat_message (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NULL,
          room_id INTEGER NOT NULL,
          chat_history_id INTEGER NULL,
          type TEXT NOT NULL,
          role TEXT NOT NULL,
          user TEXT,
          text TEXT,
          extra TEXT,
          ref_id INTEGER NULL,
          server_id INTEGER NULL,
          status INTEGER DEFAULT 1,
          token_consumed INTEGER NULL,
          quota_consumed INTEGER NULL,
          model TEXT,
          images TEXT NULL,
          ts INTEGER NOT NULL
        )
      ''');

  await db.execute('''
        CREATE TABLE chat_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NULL,
          room_id INTEGER NOT NULL,
          title TEXT,
          last_message TEXT,
          model TEXT,
          created_at INTEGER,
          updated_at INTEGER
        )
      ''');

  await db.execute('''
        CREATE TABLE chat_room (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NULL,
          name TEXT NOT NULL,
          category TEXT NOT NULL,
          priority INTEGER DEFAULT 0,
          model TEXT NOT NULL,
          icon_data TEXT NOT NULL,
          color TEXT,
          description TEXT,
          system_prompt TEXT,
          init_message TEXT,
          max_context INTEGER DEFAULT 10,
          created_at INTEGER,
          last_active_time INTEGER 
        )
      ''');
}