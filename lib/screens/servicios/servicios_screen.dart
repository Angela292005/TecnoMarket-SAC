import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/servicio.dart';
import '../../services/database_service.dart';
import '../../widgets/app_drawer.dart';
import 'servicio_form_screen.dart';

class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key});

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  final DatabaseService _dbService = DatabaseService();
  StreamSubscription<List<Servicio>>? _subscription;
  Map<String, Servicio>? _previousItems;
  bool _isFirstEvent = true;

  @override
  void initState() {
    super.initState();
    _listenToServiceChanges();
  }

  void _listenToServiceChanges() {
    _subscription = _dbService.obtenerServicios().listen((currentList) {
      if (_isFirstEvent) {
        _isFirstEvent = false;
        _previousItems = {for (var s in currentList) if (s.id != null) s.id!: s};
        return;
      }

      if (!_dbService.isRecentLocalAction && mounted) {
        final currentMap = {for (var s in currentList) if (s.id != null) s.id!: s};
        if (_previousItems != null) {
          final added = currentMap.keys.where((k) => !_previousItems!.containsKey(k)).length;
          final removed = _previousItems!.keys.where((k) => !currentMap.containsKey(k)).length;

          if (added > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Se agregó un nuevo servicio'),
                duration: Duration(seconds: 2),
                backgroundColor: Color(0xFFD97706),
              ),
            );
          } else if (removed > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Se eliminó un servicio'),
                duration: Duration(seconds: 2),
                backgroundColor: Color(0xFF64748B),
              ),
            );
          } else {
            bool updated = false;
            for (final key in currentMap.keys) {
              final oldS = _previousItems![key];
              final newS = currentMap[key]!;
              if (oldS != null &&
                  (oldS.cliente != newS.cliente ||
                   oldS.equipoRecibido != newS.equipoRecibido ||
                   oldS.marca != newS.marca ||
                   oldS.modelo != newS.modelo ||
                   oldS.tipoFalla != newS.tipoFalla ||
                   oldS.tecnicoAsignado != newS.tecnicoAsignado ||
                   oldS.costoEstimado != newS.costoEstimado ||
                   oldS.estadoServicio != newS.estadoServicio ||
                   oldS.fechaEstimadaEntrega != newS.fechaEstimadaEntrega)) {
                updated = true;
                break;
              }
            }
            if (updated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Se actualizó un servicio'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Color(0xFF2563EB),
                ),
              );
            }
          }
        }
        _previousItems = currentMap;
      } else {
        _previousItems = {for (var s in currentList) if (s.id != null) s.id!: s};
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _eliminarServicio(Servicio servicio) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar este registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      try {
        await _dbService.eliminarServicio(servicio.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Servicio eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar el servicio'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'Recibido':
        return Colors.blue;
      case 'En diagnóstico':
        return Colors.orange;
      case 'En reparación':
        return Colors.purple;
      case 'Listo':
        return Colors.teal;
      case 'Entregado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Servicios técnicos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D253F),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      drawer: const AppDrawer(currentRoute: 'servicios'),
      body: StreamBuilder<List<Servicio>>(
        stream: _dbService.obtenerServicios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD97706),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      'Error al cargar servicios: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            );
          }

          final servicios = snapshot.data ?? [];

          if (servicios.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.build_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay servicios registrados.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            itemCount: servicios.length,
            itemBuilder: (context, index) {
              final serv = servicios[index];
              return _buildServicioCard(serv);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D253F),
        foregroundColor: Colors.white,
        tooltip: 'Registrar servicio técnico',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ServicioFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildServicioCard(Servicio serv) {
    final estadoColor = _getEstadoColor(serv.estadoServicio);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior: Código de servicio y Estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D253F).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.build,
                        size: 18,
                        color: Color(0xFF0D253F),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Código: ${serv.codigoServicio}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF0D253F),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: estadoColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: estadoColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    serv.estadoServicio,
                    style: TextStyle(
                      color: estadoColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Cliente
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                const Text(
                  'Cliente: ',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Text(
                    serv.cliente,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Equipo, Marca y Modelo
            Row(
              children: [
                const Icon(Icons.devices_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${serv.equipoRecibido} - ${serv.marca} ${serv.modelo}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Falla y Técnico
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Falla: ${serv.tipoFalla}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.engineering_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Técnico: ${serv.tecnicoAsignado}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Costo y Fecha estimada de entrega
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Costo: S/ ${serv.costoEstimado.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF059669),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.event_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Entrega: ${serv.fechaEstimadaEntrega}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Divider(height: 20),

            // Botones: Editar y Eliminar
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E3A8A),
                    side: const BorderSide(color: Color(0xFF1E3A8A)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServicioFormScreen(servicio: serv),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Eliminar'),
                  onPressed: () => _eliminarServicio(serv),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
