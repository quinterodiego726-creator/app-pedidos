import 'dart:io';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('productos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    bool exists = await databaseExists(path);

    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load('assets/$filePath');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }

    final db = await openDatabase(path);

    // Crear la tabla de usuarios en caso de que no exista en la base de datos precompilada
    await db.execute('''
      CREATE TABLE IF NOT EXISTS usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        correo TEXT UNIQUE,
        password TEXT
      )
    ''');

    // IMPRIME EL CONTENIDO AUTOMÁTICAMENTE AL ABRIR LA BASE DE DATOS
    try {
      final productos = await db.query('productos');
      final carrito = await db.query('carrito');
      final usuarios = await db.query('usuarios');
      debugPrint('==============================================');
      debugPrint('🚀 TABLA PRODUCTOS EN DB: $productos');
      debugPrint('🛒 TABLA CARRITO EN DB: $carrito');
      debugPrint('👤 TABLA USUARIOS EN DB: $usuarios');
      debugPrint('==============================================');
    } catch (e) {
      debugPrint('⚠️ Error al leer tablas al iniciar: $e');
    }

    return db;
  }

  // --- MÉTODOS DE AUTENTICACIÓN Y USUARIOS ---

  // Registrar nuevo usuario
  Future<bool> registrarUsuario(String correo, String password) async {
    final db = await instance.database;
    try {
      await db.insert('usuarios', {
        'correo': correo.toLowerCase().trim(),
        'password': password,
      });
      return true;
    } catch (e) {
      debugPrint('Error al registrar usuario (posible correo duplicado): $e');
      return false;
    }
  }

  // Validar inicio de sesión
  Future<bool> loginUsuario(String correo, String password) async {
    final db = await instance.database;
    final res = await db.query(
      'usuarios',
      where: 'correo = ? AND password = ?',
      whereArgs: [correo.toLowerCase().trim(), password],
    );
    return res.isNotEmpty;
  }

  // --- MÉTODOS DE CONSULTA CARRITO ---

  Future<int> agregarAlCarrito(Map<String, dynamic> item) async {
    final db = await instance.database;
    final id = await db.insert('carrito', item);

    final carritoActual = await obtenerCarrito();
    debugPrint('==============================================');
    debugPrint('➕ CARRITO ACTUALIZADO: $carritoActual');
    debugPrint('==============================================');

    return id;
  }

  Future<List<Map<String, dynamic>>> obtenerCarrito() async {
    final db = await instance.database;
    return await db.query('carrito');
  }

  Future<int> limpiarCarrito() async {
    final db = await instance.database;
    final res = await db.delete('carrito');

    debugPrint('==============================================');
    debugPrint('🗑️ CARRITO VACIADO');
    debugPrint('==============================================');

    return res;
  }
}