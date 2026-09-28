class Producto {
  final String? id;
  final String codigoProducto;
  final String nombre;
  final String categoria;
  final String marca;
  final String modelo;
  final double precioVenta;
  final int stockDisponible;

  Producto({
    this.id,
    required this.codigoProducto,
    required this.nombre,
    required this.categoria,
    required this.marca,
    required this.modelo,
    required this.precioVenta,
    required this.stockDisponible,
  });

  // Categorías permitidas según requerimientos
  static const List<String> categoriasPermitidas = [
    'Celulares',
    'Laptops',
    'Tablets',
    'Accesorios',
    'Periféricos',
  ];

  factory Producto.fromMap(String id, Map<dynamic, dynamic> map) {
    return Producto(
      id: id,
      codigoProducto: map['codigoProducto']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      categoria: map['categoria']?.toString() ?? '',
      marca: map['marca']?.toString() ?? '',
      modelo: map['modelo']?.toString() ?? '',
      precioVenta: (map['precioVenta'] is num)
          ? (map['precioVenta'] as num).toDouble()
          : double.tryParse(map['precioVenta']?.toString() ?? '0') ?? 0.0,
      stockDisponible: (map['stockDisponible'] is num)
          ? (map['stockDisponible'] as num).toInt()
          : int.tryParse(map['stockDisponible']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'codigoProducto': codigoProducto,
      'nombre': nombre,
      'categoria': categoria,
      'marca': marca,
      'modelo': modelo,
      'precioVenta': precioVenta,
      'stockDisponible': stockDisponible,
    };
  }

  Producto copyWith({
    String? id,
    String? codigoProducto,
    String? nombre,
    String? categoria,
    String? marca,
    String? modelo,
    double? precioVenta,
    int? stockDisponible,
  }) {
    return Producto(
      id: id ?? this.id,
      codigoProducto: codigoProducto ?? this.codigoProducto,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      precioVenta: precioVenta ?? this.precioVenta,
      stockDisponible: stockDisponible ?? this.stockDisponible,
    );
  }
}
