import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../screens/home_screen.dart';
import '../screens/productos/productos_screen.dart';
import '../screens/clientes/clientes_screen.dart';
import '../screens/servicios/servicios_screen.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({
    super.key,
    required this.currentRoute,
  });

  Future<void> _confirmarInsertarDatosPrueba(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Insertar datos de prueba'),
        content: const Text(
          '¿Desea registrar los datos de ejemplo iniciales (un producto, un cliente y una orden de servicio)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D253F),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Insertar'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      try {
        await DatabaseService().insertarDatosDePrueba();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Datos de prueba insertados correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al insertar datos de prueba: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header empresarial
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D253F), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.devices,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TecnoMarket S.A.C.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tecnología y Soporte',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Elementos de Navegación
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFF1E3A8A)),
            title: const Text(
              'Inicio',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            selected: currentRoute == 'home',
            selectedTileColor: Colors.blue.withValues(alpha: 0.1),
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'home') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.inventory_2, color: Color(0xFF1E3A8A)),
            title: const Text(
              'Productos',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            selected: currentRoute == 'productos',
            selectedTileColor: Colors.blue.withValues(alpha: 0.1),
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'productos') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductosScreen()),
                );
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.people, color: Color(0xFF1E3A8A)),
            title: const Text(
              'Clientes',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            selected: currentRoute == 'clientes',
            selectedTileColor: Colors.blue.withValues(alpha: 0.1),
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'clientes') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ClientesScreen()),
                );
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.build, color: Color(0xFF1E3A8A)),
            title: const Text(
              'Servicios técnicos',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            selected: currentRoute == 'servicios',
            selectedTileColor: Colors.blue.withValues(alpha: 0.1),
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'servicios') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ServiciosScreen()),
                );
              }
            },
          ),

          const Divider(),

          // Opción para insertar datos de prueba
          ListTile(
            leading: const Icon(Icons.playlist_add, color: Colors.teal),
            title: const Text('Insertar datos de prueba'),
            subtitle: const Text('Cargar ejemplos iniciales en Firebase'),
            onTap: () {
              Navigator.pop(context);
              _confirmarInsertarDatosPrueba(context);
            },
          ),

          const Spacer(),
          const Divider(),

          // Pie del Drawer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'TecnoMarket v1.0 • Cloud Firestore',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
