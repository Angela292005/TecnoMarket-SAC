class Servicio {
  final String? id;
  final String codigoServicio;
  final String cliente;
  final String equipoRecibido;
  final String marca;
  final String modelo;
  final String tipoFalla;
  final String tecnicoAsignado;
  final String fechaRecepcion;
  final String fechaEstimadaEntrega;
  final double costoEstimado;
  final String estadoServicio;

  Servicio({
    this.id,
    required this.codigoServicio,
    required this.cliente,
    required this.equipoRecibido,
    required this.marca,
    required this.modelo,
    required this.tipoFalla,
    required this.tecnicoAsignado,
    required this.fechaRecepcion,
    required this.fechaEstimadaEntrega,
    required this.costoEstimado,
    required this.estadoServicio,
  });

  static const List<String> estadosPermitidos = [
    'Recibido',
    'En diagnóstico',
    'En reparación',
    'Listo',
    'Entregado',
  ];

  factory Servicio.fromMap(String id, Map<dynamic, dynamic> map) {
    return Servicio(
      id: id,
      codigoServicio: map['codigoServicio']?.toString() ?? '',
      cliente: map['cliente']?.toString() ?? '',
      equipoRecibido: map['equipoRecibido']?.toString() ?? '',
      marca: map['marca']?.toString() ?? '',
      modelo: map['modelo']?.toString() ?? '',
      tipoFalla: map['tipoFalla']?.toString() ?? '',
      tecnicoAsignado: map['tecnicoAsignado']?.toString() ?? '',
      fechaRecepcion: map['fechaRecepcion']?.toString() ?? '',
      fechaEstimadaEntrega: map['fechaEstimadaEntrega']?.toString() ?? '',
      costoEstimado: (map['costoEstimado'] is num)
          ? (map['costoEstimado'] as num).toDouble()
          : double.tryParse(map['costoEstimado']?.toString() ?? '0') ?? 0.0,
      estadoServicio: map['estadoServicio']?.toString() ?? 'Recibido',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'codigoServicio': codigoServicio,
      'cliente': cliente,
      'equipoRecibido': equipoRecibido,
      'marca': marca,
      'modelo': modelo,
      'tipoFalla': tipoFalla,
      'tecnicoAsignado': tecnicoAsignado,
      'fechaRecepcion': fechaRecepcion,
      'fechaEstimadaEntrega': fechaEstimadaEntrega,
      'costoEstimado': costoEstimado,
      'estadoServicio': estadoServicio,
    };
  }

  Servicio copyWith({
    String? id,
    String? codigoServicio,
    String? cliente,
    String? equipoRecibido,
    String? marca,
    String? modelo,
    String? tipoFalla,
    String? tecnicoAsignado,
    String? fechaRecepcion,
    String? fechaEstimadaEntrega,
    double? costoEstimado,
    String? estadoServicio,
  }) {
    return Servicio(
      id: id ?? this.id,
      codigoServicio: codigoServicio ?? this.codigoServicio,
      cliente: cliente ?? this.cliente,
      equipoRecibido: equipoRecibido ?? this.equipoRecibido,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      tipoFalla: tipoFalla ?? this.tipoFalla,
      tecnicoAsignado: tecnicoAsignado ?? this.tecnicoAsignado,
      fechaRecepcion: fechaRecepcion ?? this.fechaRecepcion,
      fechaEstimadaEntrega: fechaEstimadaEntrega ?? this.fechaEstimadaEntrega,
      costoEstimado: costoEstimado ?? this.costoEstimado,
      estadoServicio: estadoServicio ?? this.estadoServicio,
    );
  }
}
