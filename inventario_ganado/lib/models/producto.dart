class Producto {
  int? id;
  String nombre;
  String tipo; // Medicamento o Vacuna
  String presentacion;
  int cantidad;
  String fechaCaducidad;
  int stockMinimo;

  Producto({
    this.id,
    required this.nombre,
    required this.tipo,
    required this.presentacion,
    required this.cantidad,
    required this.fechaCaducidad,
    required this.stockMinimo,
  });

  // Esto sirve para convertir los datos de la base de datos a un objeto de Flutter
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'presentacion': presentacion,
      'cantidad': cantidad,
      'fecha_caducidad': fechaCaducidad,
      'stock_minimo': stockMinimo,
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'],
      nombre: map['nombre'],
      tipo: map['tipo'],
      presentacion: map['presentacion'],
      cantidad: map['cantidad'],
      fechaCaducidad: map['fecha_caducidad'],
      stockMinimo: map['stock_minimo'],
    );
  }
}