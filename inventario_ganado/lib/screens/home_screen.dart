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
  String _busqueda = ""; // Para el buscador
  final _searchController = TextEditingController();

  void _actualizarLista() {
    setState(() {}); 
  }

  int _calcularDiasRestantes(String fechaCaducidad) {
    try {
      DateTime fecha = DateTime.parse(fechaCaducidad);
      DateTime hoy = DateTime.now();
      return fecha.difference(hoy).inDays;
    } catch (e) {
      return 0;
    }
  }

  // FUNCIÓN PARA ELIMINAR CON CONFIRMACIÓN
  void _confirmarEliminar(int id, String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar producto?'),
        content: Text('¿Estás seguro de borrar "$nombre"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () async {
              await DbHelper().eliminarProducto(id);
              Navigator.pop(context);
              _actualizarLista();
            }, 
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario Ganadero'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _busqueda = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Buscar medicina o vacuna...',
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Producto>>(
        future: DbHelper().obtenerProductos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos registrados.'));
          }

          // FILTRADO EN TIEMPO REAL
          final productos = snapshot.data!.where((p) {
            return p.nombre.toLowerCase().contains(_busqueda);
          }).toList();

          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final prod = productos[index];
              bool stockBajo = prod.cantidad <= prod.stockMinimo;
              int diasRestantes = _calcularDiasRestantes(prod.fechaCaducidad);

              Color colorCad = diasRestantes < 0 ? Colors.red : (diasRestantes <= 30 ? Colors.orange : Colors.green);

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  onLongPress: () => _confirmarEliminar(prod.id!, prod.nombre), // ELIMINAR
                  leading: CircleAvatar(
                    backgroundColor: prod.tipo == 'Vacuna' ? Colors.blue : Colors.orange,
                    child: Icon(prod.tipo == 'Vacuna' ? Icons.vaccines : Icons.medication, color: Colors.white),
                  ),
                  title: Text(prod.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(prod.presentacion, style: const TextStyle(fontSize: 12)),
                      Text("Vence en $diasRestantes días", style: TextStyle(color: colorCad, fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 110,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                          onPressed: () async {
                            if (prod.cantidad > 0) {
                              await DbHelper().actualizarStock(prod.id!, prod.cantidad - 1);
                              _actualizarLista();
                            }
                          },
                        ),
                        Expanded(child: Text('${prod.cantidad}', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: stockBajo ? Colors.red : Colors.blue[900]))),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () async {
                            await DbHelper().actualizarStock(prod.id!, prod.cantidad + 1);
                            _actualizarLista();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistroScreen()));
          _actualizarLista();
        },
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}