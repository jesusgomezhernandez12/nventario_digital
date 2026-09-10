import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/producto.dart';

class DbHelper {
  // Patrón Singleton: Solo una instancia de la base de datos abierta a la vez
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  // Crea el archivo .db en el celular
  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'inventario_ganado.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Aquí creamos la tabla principal con los campos que definimos
        await db.execute('''
          CREATE TABLE productos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            tipo TEXT,
            presentacion TEXT,
            cantidad INTEGER,
            fecha_caducidad TEXT,
            stock_minimo INTEGER
          )
        ''');
      },
    );
  }

  // --- FUNCIONES CRUD (Altas, Bajas, Cambios) ---

  // 1. Registrar un producto nuevo
  Future<int> insertarProducto(Producto producto) async {
    final db = await database;
    return await db.insert('productos', producto.toMap());
  }

  // 2. Ver todos los productos
  Future<List<Producto>> obtenerProductos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('productos');
    return List.generate(maps.length, (i) => Producto.fromMap(maps[i]));
  }

  // 3. Actualizar (Entradas y Salidas)
  // Esta función sirve para editar todo o solo la cantidad
  Future<int> actualizarProducto(Producto producto) async {
    final db = await database;
    return await db.update(
      'productos',
      producto.toMap(),
      where: 'id = ?',
      whereArgs: [producto.id],
    );
  }

  // 4. Eliminar producto
  Future<int> eliminarProducto(int id) async {
    final db = await database;
    return await db.delete(
      'productos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 5. Actualizar solo el stock (cantidad)
  Future<int> actualizarStock(int id, int nuevaCantidad) async {
    final db = await database;
    return await db.update(
      'productos',
      {'cantidad': nuevaCantidad},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}