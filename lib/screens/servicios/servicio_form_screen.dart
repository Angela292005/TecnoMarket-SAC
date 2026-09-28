import 'package:flutter/material.dart';
import '../../models/servicio.dart';
import '../../services/database_service.dart';
import '../../utils/date_utils.dart';

class ServicioFormScreen extends StatefulWidget {
  final Servicio? servicio;

  const ServicioFormScreen({super.key, this.servicio});

  @override
  State<ServicioFormScreen> createState() => _ServicioFormScreenState();
}

class _ServicioFormScreenState extends State<ServicioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _databaseService = DatabaseService();

  late TextEditingController _codigoController;
  late TextEditingController _clienteController;
  late TextEditingController _equipoController;
  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _tipoFallaController;
  late TextEditingController _tecnicoController;
  late TextEditingController _fechaRecepcionController;
  late TextEditingController _fechaEntregaController;
  late TextEditingController _costoController;

  String? _estadoSeleccionado;
  bool _isLoading = false;

  bool get _isEditing => widget.servicio != null;

  @override
  void initState() {
    super.initState();
    final s = widget.servicio;
    _codigoController = TextEditingController(text: s?.codigoServicio ?? '');
    _clienteController = TextEditingController(text: s?.cliente ?? '');
    _equipoController = TextEditingController(text: s?.equipoRecibido ?? '');
    _marcaController = TextEditingController(text: s?.marca ?? '');
    _modeloController = TextEditingController(text: s?.modelo ?? '');
    _tipoFallaController = TextEditingController(text: s?.tipoFalla ?? '');
    _tecnicoController = TextEditingController(text: s?.tecnicoAsignado ?? '');
    _fechaRecepcionController = TextEditingController(
      text: s?.fechaRecepcion.isNotEmpty == true
          ? s!.fechaRecepcion
          : AppDateUtils.today(),
    );
    _fechaEntregaController = TextEditingController(
      text: s?.fechaEstimadaEntrega.isNotEmpty == true
          ? s!.fechaEstimadaEntrega
          : AppDateUtils.format(DateTime.now().add(const Duration(days: 3))),
    );
    _costoController = TextEditingController(
      text: s != null ? s.costoEstimado.toString() : '',
    );

    _estadoSeleccionado = s != null && Servicio.estadosPermitidos.contains(s.estadoServicio)
        ? s.estadoServicio
        : Servicio.estadosPermitidos.first;
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _clienteController.dispose();
    _equipoController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _tipoFallaController.dispose();
    _tecnicoController.dispose();
    _fechaRecepcionController.dispose();
    _fechaEntregaController.dispose();
    _costoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(
    TextEditingController controller,
    String titulo,
  ) async {
    final DateTime fechaInicial =
        AppDateUtils.parse(controller.text) ?? DateTime.now();

    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D253F),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0D253F),
            ),
          ),
          child: child!,
        );
      },
    );

    if (fechaSeleccionada != null) {
      setState(() {
        controller.text = AppDateUtils.format(fechaSeleccionada);
      });
    }
  }

  Future<void> _guardarServicio() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final codigo = _codigoController.text.trim();
      final cliente = _clienteController.text.trim();
      final equipo = _equipoController.text.trim();
      final marca = _marcaController.text.trim();
      final modelo = _modeloController.text.trim();
      final tipoFalla = _tipoFallaController.text.trim();
      final tecnico = _tecnicoController.text.trim();
      final fechaRecepcion = _fechaRecepcionController.text.trim();
      final fechaEntrega = _fechaEntregaController.text.trim();
      final costo = double.parse(_costoController.text.trim());

      final servicioAGuardar = Servicio(
        id: widget.servicio?.id,
        codigoServicio: codigo,
        cliente: cliente,
        equipoRecibido: equipo,
        marca: marca,
        modelo: modelo,
        tipoFalla: tipoFalla,
        tecnicoAsignado: tecnico,
        fechaRecepcion: fechaRecepcion,
        fechaEstimadaEntrega: fechaEntrega,
        costoEstimado: costo,
        estadoServicio: _estadoSeleccionado ?? 'Recibido',
      );

      if (_isEditing) {
        await _databaseService.actualizarServicio(servicioAGuardar);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Servicio actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        await _databaseService.agregarServicio(servicioAGuardar);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Servicio registrado correctamente'),
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
                  ? 'Error al actualizar el servicio'
                  : 'Error al registrar el servicio',
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
          _isEditing ? 'Editar servicio técnico' : 'Registrar servicio técnico',
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
                          'Datos de la Orden de Servicio',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D253F),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Código de Servicio
                        TextFormField(
                          controller: _codigoController,
                          decoration: const InputDecoration(
                            labelText: 'Código de servicio *',
                            hintText: 'Ej. ST001',
                            prefixIcon: Icon(Icons.tag),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El código de servicio es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Cliente
                        TextFormField(
                          controller: _clienteController,
                          decoration: const InputDecoration(
                            labelText: 'Cliente *',
                            hintText: 'Ej. Juan Pérez',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El cliente es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Equipo recibido
                        TextFormField(
                          controller: _equipoController,
                          decoration: const InputDecoration(
                            labelText: 'Equipo recibido *',
                            hintText: 'Ej. Laptop, Celular, Impresora',
                            prefixIcon: Icon(Icons.devices_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El equipo recibido es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Marca y Modelo en fila
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _marcaController,
                                decoration: const InputDecoration(
                                  labelText: 'Marca *',
                                  hintText: 'Ej. Lenovo',
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
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _modeloController,
                                decoration: const InputDecoration(
                                  labelText: 'Modelo *',
                                  hintText: 'Ej. IdeaPad 3',
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
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Tipo de falla
                        TextFormField(
                          controller: _tipoFallaController,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de falla *',
                            hintText: 'Ej. No enciende / Pantalla rota',
                            prefixIcon: Icon(Icons.warning_amber_rounded),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El tipo de falla es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Técnico Asignado
                        TextFormField(
                          controller: _tecnicoController,
                          decoration: const InputDecoration(
                            labelText: 'Técnico asignado *',
                            hintText: 'Ej. Carlos Mendoza',
                            prefixIcon: Icon(Icons.engineering_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El técnico asignado es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Fecha de recepción
                        TextFormField(
                          controller: _fechaRecepcionController,
                          readOnly: true,
                          onTap: () => _seleccionarFecha(
                            _fechaRecepcionController,
                            'Fecha de recepción',
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Fecha de recepción *',
                            hintText: 'dd/MM/yyyy',
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                            suffixIcon: Icon(Icons.arrow_drop_down),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La fecha de recepción es obligatoria';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Fecha estimada de entrega
                        TextFormField(
                          controller: _fechaEntregaController,
                          readOnly: true,
                          onTap: () => _seleccionarFecha(
                            _fechaEntregaController,
                            'Fecha estimada de entrega',
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Fecha estimada de entrega *',
                            hintText: 'dd/MM/yyyy',
                            prefixIcon: Icon(Icons.event_available_outlined),
                            suffixIcon: Icon(Icons.arrow_drop_down),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La fecha estimada de entrega es obligatoria';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Costo Estimado
                        TextFormField(
                          controller: _costoController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Costo estimado (S/) *',
                            hintText: 'Ej. 150.00',
                            prefixIcon: Icon(Icons.monetization_on_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El costo estimado es obligatorio';
                            }
                            final parsed = double.tryParse(value.trim());
                            if (parsed == null) {
                              return 'Debe ingresar un valor numérico válido';
                            }
                            if (parsed < 0) {
                              return 'El costo debe ser mayor o igual a 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Estado del Servicio (Dropdown)
                        DropdownButtonFormField<String>(
                          initialValue: _estadoSeleccionado,
                          decoration: const InputDecoration(
                            labelText: 'Estado del servicio *',
                            prefixIcon: Icon(Icons.info_outline),
                            border: OutlineInputBorder(),
                          ),
                          items: Servicio.estadosPermitidos.map((est) {
                            return DropdownMenuItem<String>(
                              value: est,
                              child: Text(est),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _estadoSeleccionado = val;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Seleccione el estado del servicio';
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
                  onPressed: _isLoading ? null : _guardarServicio,
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
                    _isEditing
                        ? 'Actualizar Servicio'
                        : 'Guardar Servicio Técnico',
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
