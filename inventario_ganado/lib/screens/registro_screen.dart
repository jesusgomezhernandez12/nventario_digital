import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/producto.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para capturar lo que el usuario escribe
  final _nombreController = TextEditingController();
  final _presentacionController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _stockMinimoController = TextEditingController();
  final _fechaController = TextEditingController();
  
  String _tipo = 'Medicamento'; // Valor por defecto

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del Producto'),
                validator: (value) => value!.isEmpty ? 'Ingresa el nombre' : null,
              ),
              DropdownButtonFormField<String>(
                value: _tipo,
                items: ['Medicamento', 'Vacuna'].map((String value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                onChanged: (val) => setState(() => _tipo = val!),
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              TextFormField(
                controller: _presentacionController,
                decoration: const InputDecoration(labelText: 'Presentación (ej. Frasco 500ml)'),
                validator: (value) => value!.isEmpty ? 'Ingresa la presentación' : null,
              ),
              TextFormField(
                controller: _cantidadController,
                decoration: const InputDecoration(labelText: 'Cantidad Inicial'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Ingresa la cantidad' : null,
              ),
              TextFormField(
                controller: _stockMinimoController,
                decoration: const InputDecoration(labelText: 'Stock Mínimo (Alerta)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Ingresa el stock mínimo' : null,
              ),
              TextFormField(
                controller: _fechaController,
                decoration: const InputDecoration(labelText: 'Fecha de Caducidad (AAAA-MM-DD)'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _fechaController.text = pickedDate.toString().split(' ')[0];
                    });
                  }
                },
                readOnly: true, // Para que el usuario use el calendario
                validator: (value) => value!.isEmpty ? 'Selecciona una fecha' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: _guardar,
                child: const Text('Guardar Producto'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      // Creamos el objeto producto
      final nuevoProducto = Producto(
        nombre: _nombreController.text,
        tipo: _tipo,
        presentacion: _presentacionController.text,
        cantidad: int.parse(_cantidadController.text),
        fechaCaducidad: _fechaController.text,
        stockMinimo: int.parse(_stockMinimoController.text),
      );

      // Guardamos en la base de datos (OFFLINE)
      await DbHelper().insertarProducto(nuevoProducto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Producto guardado con éxito!')),
        );
        Navigator.pop(context); // Regresar al inicio
      }
    }
  }
}