import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/producto.dart';
import '../../services/database_service.dart';
import '../../widgets/app_drawer.dart';
import 'producto_form_screen.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final DatabaseService _dbService = DatabaseService();
  StreamSubscription<List<Producto>>? _subscription;
  Map<String, Producto>? _previousItems;
  bool _isFirstEvent = true;

  @override
  void initState() {
    super.initState();
    _listenToProductChanges();
  }

  void _listenToProductChanges() {
    _subscription = _dbService.obtenerProductos().listen((currentList) {
      if (_isFirstEvent) {
        _isFirstEvent = false;
        _previousItems = {for (var p in currentList) if (p.id != null) p.id!: p};
        return;
      }

      if (!_dbService.isRecentLocalAction && mounted) {
        final currentMap = {for (var p in currentList) if (p.id != null) p.id!: p};
        if (_previousItems != null) {
          final added = currentMap.keys.where((k) => !_previousItems!.containsKey(k)).length;
          final removed = _previousItems!.keys.where((k) => !currentMap.containsKey(k)).length;

          if (added > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Se agregó un nuevo producto'),
                duration: Duration(seconds: 2),
                backgroundColor: Color(0xFF1E3A8A),
              ),
            );
          } else if (removed > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Se eliminó un producto'),
                duration: Duration(seconds: 2),
                backgroundColor: Color(0xFF64748B),
              ),
            );
          } else {
            bool updated = false;
            for (final key in currentMap.keys) {
              final oldP = _previousItems![key];
              final newP = currentMap[key]!;
              if (oldP != null &&
                  (oldP.nombre != newP.nombre ||
                   oldP.precioVenta != newP.precioVenta ||
                   oldP.stockDisponible != newP.stockDisponible ||
                   oldP.categoria != newP.categoria ||
                   oldP.marca != newP.marca ||
                   oldP.modelo != newP.modelo)) {
                updated = true;
                break;
              }
            }
            if (updated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Se actualizó un producto'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Color(0xFF2563EB),
                ),
              );
            }
          }
        }
        _previousItems = currentMap;
      } else {
        _previousItems = {for (var p in currentList) if (p.id != null) p.id!: p};
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _eliminarProducto(Producto producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar este producto?'),
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
        await _dbService.eliminarProducto(producto.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar el producto'),
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
          'Productos tecnológicos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D253F),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      drawer: const AppDrawer(currentRoute: 'productos'),
      body: StreamBuilder<List<Producto>>(
        stream: _dbService.obtenerProductos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1E3A8A),
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
                      'Error al cargar productos: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            );
          }

          final productos = snapshot.data ?? [];

          if (productos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay productos registrados.',
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
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final prod = productos[index];
              return _buildProductCard(prod);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D253F),
        foregroundColor: Colors.white,
        tooltip: 'Registrar producto',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProductoFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductCard(Producto prod) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior: Nombre y Chip de Categoría
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    prod.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D253F),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    prod.categoria,
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Detalles del Producto
            Row(
              children: [
                _buildInfoTag(Icons.tag, 'Código: ${prod.codigoProducto}'),
                const SizedBox(width: 12),
                _buildInfoTag(Icons.branding_watermark, '${prod.marca} ${prod.modelo}'),
              ],
            ),
            const SizedBox(height: 8),

            // Precios y Stock
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Precio: S/ ${prod.precioVenta.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF059669),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: prod.stockDisponible > 5
                        ? Colors.green.shade50
                        : (prod.stockDisponible > 0 ? Colors.orange.shade50 : Colors.red.shade50),
                    border: Border.all(
                      color: prod.stockDisponible > 5
                          ? Colors.green.shade300
                          : (prod.stockDisponible > 0 ? Colors.orange.shade300 : Colors.red.shade300),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Stock: ${prod.stockDisponible}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: prod.stockDisponible > 5
                          ? Colors.green.shade800
                          : (prod.stockDisponible > 0 ? Colors.orange.shade800 : Colors.red.shade800),
                    ),
                  ),
                ),
              ],
            ),

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
                        builder: (_) => ProductoFormScreen(producto: prod),
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
                  onPressed: () => _eliminarProducto(prod),
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
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}
