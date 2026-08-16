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

    // IMPRIME EL CONTENIDO AUTOMÁTICAMENTE AL ABRIR LA BASE DE DATOS
    try {
      final productos = await db.query('productos');
      final carrito = await db.query('carrito');
      debugPrint('==============================================');
      debugPrint('🚀 TABLA PRODUCTOS EN DB: $productos');
      debugPrint('🛒 TABLA CARRITO EN DB: $carrito');
      debugPrint('==============================================');
    } catch (e) {
      debugPrint('⚠️ Error al leer tablas al iniciar: $e');
    }

    return db;
  }

  // --- MÉTODOS DE CONSULTA ---

  // 1. Insertar un producto al carrito
  Future<int> agregarAlCarrito(Map<String, dynamic> item) async {
    final db = await instance.database;
    final id = await db.insert('carrito', item);

    final carritoActual = await obtenerCarrito();
    debugPrint('==============================================');
    debugPrint('➕ CARRITO ACTUALIZADO (NUEVO ITEM): $carritoActual');
    debugPrint('==============================================');

    return id;
  }

  // 2. Obtener todos los productos guardados en el carrito
  Future<List<Map<String, dynamic>>> obtenerCarrito() async {
    final db = await instance.database;
    return await db.query('carrito');
  }

  // 3. Vaciar el carrito
  Future<int> limpiarCarrito() async {
    final db = await instance.database;
    final res = await db.delete('carrito');

    debugPrint('==============================================');
    debugPrint('🗑️ CARRITO VACIADO');
    debugPrint('==============================================');

    return res;
  }
}