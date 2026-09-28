import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/cliente.dart';
import '../../services/database_service.dart';
import '../../widgets/app_drawer.dart';
import 'cliente_form_screen.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final DatabaseService _dbService = DatabaseService();
  StreamSubscription<List<Cliente>>? _subscription;
  Map<String, Cliente>? _previousItems;
  bool _isFirstEvent = true;

  @override
  void initState() {
    super.initState();
    _listenToClientChanges();
  }

  void _listenToClientChanges() {
    _subscription = _dbService.obtenerClientes().listen((currentList) {
      if (_isFirstEvent) {
        _isFirstEvent = false;
        _previousItems = {for (var c in currentList) if (c.id != null) c.id!: c};
        return;
      }

      if (!_dbService.isRecentLocalAction && mounted) {
        final currentMap = {for (var c in currentList) if (c.id != null) c.id!: c};
        if (_previousItems != null) {
          final added = currentMap.keys.where((k) => !_previousItems!.containsKey(k)).length;
          final removed = _previousItems!.keys.where((k) => !currentMap.containsKey(k)).length;

          if (added > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Se agregó un nuevo cliente'),
                duration: Duration(seconds: 2),
                backgroundColor: Color(0xFF059669),
              ),
            );
          } else if (removed > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Se eliminó un cliente'),
                duration: Duration(seconds: 2),
                backgroundColor: Color(0xFF64748B),
              ),
            );
          } else {
            bool updated = false;
            for (final key in currentMap.keys) {
              final oldC = _previousItems![key];
              final newC = currentMap[key]!;
              if (oldC != null &&
                  (oldC.nombreRazonSocial != newC.nombreRazonSocial ||
                   oldC.dniRuc != newC.dniRuc ||
                   oldC.tipoCliente != newC.tipoCliente ||
                   oldC.telefono != newC.telefono ||
                   oldC.correo != newC.correo ||
                   oldC.direccion != newC.direccion ||
                   oldC.estado != newC.estado)) {
                updated = true;
                break;
              }
            }
            if (updated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Se actualizó un cliente'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Color(0xFF2563EB),
                ),
              );
            }
          }
        }
        _previousItems = currentMap;
      } else {
        _previousItems = {for (var c in currentList) if (c.id != null) c.id!: c};
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _eliminarCliente(Cliente cliente) async {
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
        await _dbService.eliminarCliente(cliente.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar el cliente'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clientes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D253F),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      drawer: const AppDrawer(currentRoute: 'clientes'),
      body: StreamBuilder<List<Cliente>>(
        stream: _dbService.obtenerClientes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF059669),
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
                      'Error al cargar clientes: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            );
          }

          final clientes = snapshot.data ?? [];

          if (clientes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay clientes registrados.',
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
            itemCount: clientes.length,
            itemBuilder: (context, index) {
              final cli = clientes[index];
              return _buildClienteCard(cli);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D253F),
        foregroundColor: Colors.white,
        tooltip: 'Registrar cliente',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ClienteFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildClienteCard(Cliente cli) {
    final bool esActivo = cli.estado == 'Activo';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior: Nombre / Razón Social y Estado
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF059669).withValues(alpha: 0.12),
                  child: Icon(
                    cli.tipoCliente == 'Empresa' ? Icons.business : Icons.person,
                    color: const Color(0xFF059669),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cli.nombreRazonSocial,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D253F),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Código: ${cli.codigoCliente}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: esActivo ? Colors.green.shade50 : Colors.grey.shade200,
                    border: Border.all(
                      color: esActivo ? Colors.green.shade300 : Colors.grey.shade400,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    cli.estado,
                    style: TextStyle(
                      color: esActivo ? Colors.green.shade800 : Colors.grey.shade800,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // DNI / RUC y Tipo de cliente
            Row(
              children: [
                _buildInfoTag(Icons.badge_outlined, 'DNI/RUC: ${cli.dniRuc}'),
                const SizedBox(width: 14),
                _buildInfoTag(Icons.category_outlined, cli.tipoCliente),
              ],
            ),
            const SizedBox(height: 6),

            // Teléfono y Correo
            Row(
              children: [
                _buildInfoTag(Icons.phone_outlined, cli.telefono),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildInfoTag(Icons.email_outlined, cli.correo),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Dirección
            _buildInfoTag(Icons.location_on_outlined, 'Dir: ${cli.direccion}'),

            const Divider(height: 20),

            // Botones de acción: Editar y Eliminar
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
                        builder: (_) => ClienteFormScreen(cliente: cli),
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
                  onPressed: () => _eliminarCliente(cli),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}
