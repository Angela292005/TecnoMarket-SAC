class Cliente {
  final String? id;
  final String codigoCliente;
  final String nombreRazonSocial;
  final String dniRuc;
  final String tipoCliente;
  final String telefono;
  final String correo;
  final String direccion;
  final String fechaRegistro;
  final String estado;

  Cliente({
    this.id,
    required this.codigoCliente,
    required this.nombreRazonSocial,
    required this.dniRuc,
    required this.tipoCliente,
    required this.telefono,
    required this.correo,
    required this.direccion,
    required this.fechaRegistro,
    required this.estado,
  });

  static const List<String> tiposPermitidos = [
    'Persona natural',
    'Empresa',
  ];

  static const List<String> estadosPermitidos = [
    'Activo',
    'Inactivo',
  ];

  factory Cliente.fromMap(String id, Map<dynamic, dynamic> map) {
    return Cliente(
      id: id,
      codigoCliente: map['codigoCliente']?.toString() ?? '',
      nombreRazonSocial: map['nombreRazonSocial']?.toString() ?? '',
      dniRuc: map['dniRuc']?.toString() ?? '',
      tipoCliente: map['tipoCliente']?.toString() ?? 'Persona natural',
      telefono: map['telefono']?.toString() ?? '',
      correo: map['correo']?.toString() ?? '',
      direccion: map['direccion']?.toString() ?? '',
      fechaRegistro: map['fechaRegistro']?.toString() ?? '',
      estado: map['estado']?.toString() ?? 'Activo',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'codigoCliente': codigoCliente,
      'nombreRazonSocial': nombreRazonSocial,
      'dniRuc': dniRuc,
      'tipoCliente': tipoCliente,
      'telefono': telefono,
      'correo': correo,
      'direccion': direccion,
      'fechaRegistro': fechaRegistro,
      'estado': estado,
    };
  }

  Cliente copyWith({
    String? id,
    String? codigoCliente,
    String? nombreRazonSocial,
    String? dniRuc,
    String? tipoCliente,
    String? telefono,
    String? correo,
    String? direccion,
    String? fechaRegistro,
    String? estado,
  }) {
    return Cliente(
      id: id ?? this.id,
      codigoCliente: codigoCliente ?? this.codigoCliente,
      nombreRazonSocial: nombreRazonSocial ?? this.nombreRazonSocial,
      dniRuc: dniRuc ?? this.dniRuc,
      tipoCliente: tipoCliente ?? this.tipoCliente,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
      direccion: direccion ?? this.direccion,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      estado: estado ?? this.estado,
    );
  }
}
