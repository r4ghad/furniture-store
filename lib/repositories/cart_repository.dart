import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CartRepository {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'shopping_cart.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cart_items (
            id TEXT,
            user_id TEXT,
            title TEXT,
            price REAL,
            image TEXT,
            quantity INTEGER,
            PRIMARY KEY (user_id, id)
          )
        ''');
      },
    );
  }

  // Read: Fetch saved cart items for a specific user
  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    final db = await database;
    return await db.query(
      'cart_items',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Create/Update: Add item to the database or increment quantity if it exists
  Future<void> addOrUpdateItem({
    required String userId,
    required String id,
    required String title,
    required double price,
    required String image,
    required int quantity,
  }) async {
    final db = await database;
    
    // Check if the item already exists for this user
    final existing = await db.query(
      'cart_items',
      where: 'user_id = ? AND id = ?',
      whereArgs: [userId, id],
    );

    if (existing.isNotEmpty) {
      final currentQty = existing.first['quantity'] as int;
      await db.update(
        'cart_items',
        {'quantity': currentQty + quantity},
        where: 'user_id = ? AND id = ?',
        whereArgs: [userId, id],
      );
    } else {
      await db.insert(
        'cart_items',
        {
          'id': id,
          'user_id': userId,
          'title': title,
          'price': price,
          'image': image,
          'quantity': quantity,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Update: Modify the quantity of a specific item
  Future<void> updateItemQuantity(String userId, String id, int quantity) async {
    final db = await database;
    await db.update(
      'cart_items',
      {'quantity': quantity},
      where: 'user_id = ? AND id = ?',
      whereArgs: [userId, id],
    );
  }

  // Delete: Remove a specific item
  Future<void> deleteItem(String userId, String id) async {
    final db = await database;
    await db.delete(
      'cart_items',
      where: 'user_id = ? AND id = ?',
      whereArgs: [userId, id],
    );
  }

  // Clear: Remove all items for a specific user (e.g. after checkout)
  Future<void> clearCart(String userId) async {
    final db = await database;
    await db.delete(
      'cart_items',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
