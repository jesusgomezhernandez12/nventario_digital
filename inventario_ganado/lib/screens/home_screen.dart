import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/producto.dart';
import 'registro_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Esta función se encarga de refrescar la pantalla cada vez que volvemos de registrar algo
  void _actualizarLista() {
    setState(() {}); // Recarga el FutureBuilder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario Ganadero'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      // FutureBuilder es el "puente" entre SQLite y tu pantalla
      body: FutureBuilder<List<Producto>>(
        future: DbHelper().obtenerProductos(), // Va a la base de datos
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Cargando...
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos. Pica el + para agregar.'));
          }

          final productos = snapshot.data!;

          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final prod = productos[index];
              
              // Lógica de alerta: si la cantidad es menor al stock mínimo, se pone rojo
              bool stockBajo = prod.cantidad <= prod.stockMinimo;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: prod.tipo == 'Vacuna' ? Colors.blue : Colors.orange,
                    child: Icon(
                      prod.tipo == 'Vacuna' ? Icons.vaccines : Icons.medication,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(prod.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${prod.presentacion}\nCaduca: ${prod.fechaCaducidad}'),
                  isThreeLine: true,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${prod.cantidad}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: stockBajo ? Colors.red : Colors.green[800],
                        ),
                      ),
                      const Text('Exist.', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Esperamos a que el usuario termine de registrar
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegistroScreen()),
          );
          // Cuando regresa, actualizamos la lista automáticamente
          _actualizarLista();
        },
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}