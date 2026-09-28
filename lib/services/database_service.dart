import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/producto.dart';
import '../models/cliente.dart';
import '../models/servicio.dart';

class DatabaseService {
  // Patrón Singleton para uso en toda la aplicación
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Comprueba si Firebase ha sido inicializado correctamente
  bool get isFirebaseAvailable => Firebase.apps.isNotEmpty;

  // Referencias a las colecciones de Cloud Firestore
  CollectionReference get _productosRef =>
      FirebaseFirestore.instance.collection('productos');

  CollectionReference get _clientesRef =>
      FirebaseFirestore.instance.collection('clientes');

  CollectionReference get _serviciosRef =>
      FirebaseFirestore.instance.collection('servicios');

  // Marca de tiempo de la última acción local para no duplicar SnackBars de cambios externos
  DateTime? _lastLocalActionTime;

  void markLocalAction() {
    _lastLocalActionTime = DateTime.now();
  }

  bool get isRecentLocalAction {
    if (_lastLocalActionTime == null) return false;
    return DateTime.now().difference(_lastLocalActionTime!).inMilliseconds < 2500;
  }

  // ==========================================================
  // PRODUCTOS CRUD
  // ==========================================================

  /// Registrar un nuevo producto tecnológico
  Future<void> agregarProducto(Producto producto) async {
    try {
      markLocalAction();
      await _productosRef.add(producto.toMap());
    } catch (e) {
      debugPrint('Error en agregarProducto: $e');
      rethrow;
    }
  }

  /// Actualizar un producto existente
  Future<void> actualizarProducto(Producto producto) async {
    try {
      if (producto.id == null || producto.id!.isEmpty) {
        throw Exception('El ID del producto no es válido para actualizar.');
      }
      markLocalAction();
      await _productosRef.doc(producto.id!).update(producto.toMap());
    } catch (e) {
      debugPrint('Error en actualizarProducto: $e');
      rethrow;
    }
  }

  /// Eliminar un producto por su ID
  Future<void> eliminarProducto(String id) async {
    try {
      markLocalAction();
      await _productosRef.doc(id).delete();
    } catch (e) {
      debugPrint('Error en eliminarProducto: $e');
      rethrow;
    }
  }

  /// Obtener lista de productos en tiempo real mediante snapshots()
  Stream<List<Producto>> obtenerProductos() {
    if (!isFirebaseAvailable) {
      return Stream.value(<Producto>[]);
    }

    return _productosRef.snapshots().map((QuerySnapshot snapshot) {
      final List<Producto> lista = snapshot.docs.map((doc) {
        return Producto.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();

      lista.sort((a, b) => a.codigoProducto.compareTo(b.codigoProducto));
      return lista;
    });
  }

  // ==========================================================
  // CLIENTES CRUD
  // ==========================================================

  /// Registrar un nuevo cliente
  Future<void> agregarCliente(Cliente cliente) async {
    try {
      markLocalAction();
      await _clientesRef.add(cliente.toMap());
    } catch (e) {
      debugPrint('Error en agregarCliente: $e');
      rethrow;
    }
  }

  /// Actualizar un cliente existente
  Future<void> actualizarCliente(Cliente cliente) async {
    try {
      if (cliente.id == null || cliente.id!.isEmpty) {
        throw Exception('El ID del cliente no es válido para actualizar.');
      }
      markLocalAction();
      await _clientesRef.doc(cliente.id!).update(cliente.toMap());
    } catch (e) {
      debugPrint('Error en actualizarCliente: $e');
      rethrow;
    }
  }

  /// Eliminar un cliente por su ID
  Future<void> eliminarCliente(String id) async {
    try {
      markLocalAction();
      await _clientesRef.doc(id).delete();
    } catch (e) {
      debugPrint('Error en eliminarCliente: $e');
      rethrow;
    }
  }

  /// Obtener lista de clientes en tiempo real mediante snapshots()
  Stream<List<Cliente>> obtenerClientes() {
    if (!isFirebaseAvailable) {
      return Stream.value(<Cliente>[]);
    }

    return _clientesRef.snapshots().map((QuerySnapshot snapshot) {
      final List<Cliente> lista = snapshot.docs.map((doc) {
        return Cliente.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();

      lista.sort((a, b) => a.nombreRazonSocial.compareTo(b.nombreRazonSocial));
      return lista;
    });
  }

  // ==========================================================
  // SERVICIOS TÉCNICOS CRUD
  // ==========================================================

  /// Registrar una nueva orden de servicio técnico
  Future<void> agregarServicio(Servicio servicio) async {
    try {
      markLocalAction();
      await _serviciosRef.add(servicio.toMap());
    } catch (e) {
      debugPrint('Error en agregarServicio: $e');
      rethrow;
    }
  }

  /// Actualizar una orden de servicio técnico
  Future<void> actualizarServicio(Servicio servicio) async {
    try {
      if (servicio.id == null || servicio.id!.isEmpty) {
        throw Exception('El ID del servicio no es válido para actualizar.');
      }
      markLocalAction();
      await _serviciosRef.doc(servicio.id!).update(servicio.toMap());
    } catch (e) {
      debugPrint('Error en actualizarServicio: $e');
      rethrow;
    }
  }

  /// Eliminar un servicio técnico por su ID
  Future<void> eliminarServicio(String id) async {
    try {
      markLocalAction();
      await _serviciosRef.doc(id).delete();
    } catch (e) {
      debugPrint('Error en eliminarServicio: $e');
      rethrow;
    }
  }

  /// Obtener lista de servicios técnicos en tiempo real mediante snapshots()
  Stream<List<Servicio>> obtenerServicios() {
    if (!isFirebaseAvailable) {
      return Stream.value(<Servicio>[]);
    }

    return _serviciosRef.snapshots().map((QuerySnapshot snapshot) {
      final List<Servicio> lista = snapshot.docs.map((doc) {
        return Servicio.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();

      lista.sort((a, b) => a.codigoServicio.compareTo(b.codigoServicio));
      return lista;
    });
  }

  // ==========================================================
  // DATOS DE PRUEBA
  // ==========================================================

  /// Inserta datos de prueba indicados en la guía académica
  Future<void> insertarDatosDePrueba() async {
    try {
      markLocalAction();

      // 1. Producto de prueba
      await _productosRef.add({
        'codigoProducto': 'P001',
        'nombre': 'Samsung Galaxy A55',
        'categoria': 'Celulares',
        'marca': 'Samsung',
        'modelo': 'Galaxy A55',
        'precioVenta': 1299.90,
        'stockDisponible': 10,
      });

      // 2. Cliente de prueba
      await _clientesRef.add({
        'codigoCliente': 'C001',
        'nombreRazonSocial': 'Juan Pérez',
        'dniRuc': '70456789',
        'tipoCliente': 'Persona natural',
        'telefono': '987654321',
        'correo': 'juan@gmail.com',
        'direccion': 'Huancayo',
        'fechaRegistro': '28/09/2026',
        'estado': 'Activo',
      });

      // 3. Servicio de prueba
      await _serviciosRef.add({
        'codigoServicio': 'ST001',
        'cliente': 'Juan Pérez',
        'equipoRecibido': 'Laptop',
        'marca': 'Lenovo',
        'modelo': 'IdeaPad 3',
        'tipoFalla': 'No enciende',
        'tecnicoAsignado': 'Carlos Mendoza',
        'fechaRecepcion': '28/09/2026',
        'fechaEstimadaEntrega': '02/10/2026',
        'costoEstimado': 150.0,
        'estadoServicio': 'Recibido',
      });
    } catch (e) {
      debugPrint('Error al insertar datos de prueba: $e');
      rethrow;
    }
  }
}
