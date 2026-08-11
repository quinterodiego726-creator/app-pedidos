import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Patrón Singleton para usar una única instancia de la base de datos
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_pedidos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Crear la tabla local para almacenar los productos del carrito
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE carrito (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        precio REAL NOT NULL,
        cantidad INTEGER NOT NULL
      )
    ''');
  }

  // Métodos CRUD básicos

  // 1. Insertar un producto al carrito local
  Future<int> agregarAlCarrito(Map<String, dynamic> item) async {
    final db = await instance.database;
    return await db.insert('carrito', item);
  }

  // 2. Obtener todos los productos guardados en el carrito
  Future<List<Map<String, dynamic>>> obtenerCarrito() async {
    final db = await instance.database;
    return await db.query('carrito');
  }

  // 3. Vaciar el carrito
  Future<int> limpiarCarrito() async {
    final db = await instance.database;
    return await db.delete('carrito');
  }
}
