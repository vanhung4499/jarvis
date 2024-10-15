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
}