import 'package:flutter/material.dart';
import '../../models/producto.dart';
import '../../services/database_service.dart';

class ProductoFormScreen extends StatefulWidget {
  final Producto? producto;

  const ProductoFormScreen({super.key, this.producto});

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _databaseService = DatabaseService();

  late TextEditingController _codigoController;
  late TextEditingController _nombreController;
  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _precioController;
  late TextEditingController _stockController;

  String? _categoriaSeleccionada;
  bool _isLoading = false;

  bool get _isEditing => widget.producto != null;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _codigoController = TextEditingController(text: p?.codigoProducto ?? '');
    _nombreController = TextEditingController(text: p?.nombre ?? '');
    _marcaController = TextEditingController(text: p?.marca ?? '');
    _modeloController = TextEditingController(text: p?.modelo ?? '');
    _precioController = TextEditingController(
      text: p != null ? p.precioVenta.toString() : '',
    );
    _stockController = TextEditingController(
      text: p != null ? p.stockDisponible.toString() : '',
    );

    if (p != null && Producto.categoriasPermitidas.contains(p.categoria)) {
      _categoriaSeleccionada = p.categoria;
    } else {
      _categoriaSeleccionada = Producto.categoriasPermitidas.first;
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final codigo = _codigoController.text.trim();
      final nombre = _nombreController.text.trim();
      final marca = _marcaController.text.trim();
      final modelo = _modeloController.text.trim();
      final precio = double.parse(_precioController.text.trim());
      final stock = int.parse(_stockController.text.trim());

      final productoAGuardar = Producto(
        id: widget.producto?.id,
        codigoProducto: codigo,
        nombre: nombre,
        categoria: _categoriaSeleccionada ?? 'Accesorios',
        marca: marca,
        modelo: modelo,
        precioVenta: precio,
        stockDisponible: stock,
      );

      if (_isEditing) {
        await _databaseService.actualizarProducto(productoAGuardar);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        await _databaseService.agregarProducto(productoAGuardar);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto registrado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Error al actualizar el producto'
                  : 'Error al registrar el producto',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar producto' : 'Registrar producto',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D253F),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Datos del Producto Tecnológico',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D253F),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Código del Producto
                        TextFormField(
                          controller: _codigoController,
                          decoration: const InputDecoration(
                            labelText: 'Código del producto *',
                            hintText: 'Ej. P001',
                            prefixIcon: Icon(Icons.tag),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El código del producto es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Nombre del Producto
                        TextFormField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre del producto *',
                            hintText: 'Ej. Samsung Galaxy A55',
                            prefixIcon: Icon(Icons.shopping_bag_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El nombre del producto es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Categoría (Dropdown)
                        DropdownButtonFormField<String>(
                          initialValue: _categoriaSeleccionada,
                          decoration: const InputDecoration(
                            labelText: 'Categoría *',
                            prefixIcon: Icon(Icons.category_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: Producto.categoriasPermitidas.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat,
                              child: Text(cat),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _categoriaSeleccionada = val;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Seleccione una categoría';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Marca
                        TextFormField(
                          controller: _marcaController,
                          decoration: const InputDecoration(
                            labelText: 'Marca *',
                            hintText: 'Ej. Samsung, Lenovo, Apple',
                            prefixIcon: Icon(Icons.branding_watermark_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La marca es obligatoria';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Modelo
                        TextFormField(
                          controller: _modeloController,
                          decoration: const InputDecoration(
                            labelText: 'Modelo *',
                            hintText: 'Ej. Galaxy A55, IdeaPad 3',
                            prefixIcon: Icon(Icons.memory_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El modelo es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Precio de Venta
                        TextFormField(
                          controller: _precioController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Precio de venta (S/) *',
                            hintText: 'Ej. 1299.90',
                            prefixIcon: Icon(Icons.monetization_on_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El precio de venta es obligatorio';
                            }
                            final parsed = double.tryParse(value.trim());
                            if (parsed == null) {
                              return 'Debe ingresar un valor numérico válido';
                            }
                            if (parsed < 0) {
                              return 'El precio debe ser mayor o igual a 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Stock Disponible
                        TextFormField(
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Stock disponible *',
                            hintText: 'Ej. 10',
                            prefixIcon: Icon(Icons.numbers_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El stock disponible es obligatorio';
                            }
                            final parsed = int.tryParse(value.trim());
                            if (parsed == null) {
                              return 'Debe ingresar un número entero';
                            }
                            if (parsed < 0) {
                              return 'El stock debe ser mayor o igual a 0';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Botón Guardar
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D253F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _guardarProducto,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isEditing ? 'Actualizar Producto' : 'Guardar Producto',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
