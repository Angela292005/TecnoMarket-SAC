import 'package:flutter/material.dart';
import '../../models/cliente.dart';
import '../../services/database_service.dart';
import '../../utils/date_utils.dart';

class ClienteFormScreen extends StatefulWidget {
  final Cliente? cliente;

  const ClienteFormScreen({super.key, this.cliente});

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _databaseService = DatabaseService();

  late TextEditingController _codigoController;
  late TextEditingController _nombreController;
  late TextEditingController _dniRucController;
  late TextEditingController _telefonoController;
  late TextEditingController _correoController;
  late TextEditingController _direccionController;
  late TextEditingController _fechaRegistroController;

  String? _tipoSeleccionado;
  String? _estadoSeleccionado;
  bool _isLoading = false;

  bool get _isEditing => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;
    _codigoController = TextEditingController(text: c?.codigoCliente ?? '');
    _nombreController = TextEditingController(text: c?.nombreRazonSocial ?? '');
    _dniRucController = TextEditingController(text: c?.dniRuc ?? '');
    _telefonoController = TextEditingController(text: c?.telefono ?? '');
    _correoController = TextEditingController(text: c?.correo ?? '');
    _direccionController = TextEditingController(text: c?.direccion ?? '');
    _fechaRegistroController = TextEditingController(
      text: c?.fechaRegistro.isNotEmpty == true
          ? c!.fechaRegistro
          : AppDateUtils.today(),
    );

    _tipoSeleccionado = c != null && Cliente.tiposPermitidos.contains(c.tipoCliente)
        ? c.tipoCliente
        : Cliente.tiposPermitidos.first;

    _estadoSeleccionado = c != null && Cliente.estadosPermitidos.contains(c.estado)
        ? c.estado
        : Cliente.estadosPermitidos.first;
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _dniRucController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    _fechaRegistroController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final DateTime fechaInicial =
        AppDateUtils.parse(_fechaRegistroController.text) ?? DateTime.now();

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
        _fechaRegistroController.text = AppDateUtils.format(fechaSeleccionada);
      });
    }
  }

  Future<void> _guardarCliente() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final codigo = _codigoController.text.trim();
      final nombre = _nombreController.text.trim();
      final dniRuc = _dniRucController.text.trim();
      final telefono = _telefonoController.text.trim();
      final correo = _correoController.text.trim();
      final direccion = _direccionController.text.trim();
      final fecha = _fechaRegistroController.text.trim();

      final clienteAGuardar = Cliente(
        id: widget.cliente?.id,
        codigoCliente: codigo,
        nombreRazonSocial: nombre,
        dniRuc: dniRuc,
        tipoCliente: _tipoSeleccionado ?? 'Persona natural',
        telefono: telefono,
        correo: correo,
        direccion: direccion,
        fechaRegistro: fecha,
        estado: _estadoSeleccionado ?? 'Activo',
      );

      if (_isEditing) {
        await _databaseService.actualizarCliente(clienteAGuardar);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        await _databaseService.agregarCliente(clienteAGuardar);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente registrado correctamente'),
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
                  ? 'Error al actualizar el cliente'
                  : 'Error al registrar el cliente',
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
          _isEditing ? 'Editar cliente' : 'Registrar cliente',
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
                          'Datos del Cliente',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D253F),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Código del Cliente
                        TextFormField(
                          controller: _codigoController,
                          decoration: const InputDecoration(
                            labelText: 'Código del cliente *',
                            hintText: 'Ej. C001',
                            prefixIcon: Icon(Icons.tag),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El código del cliente es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Nombre / Razón Social
                        TextFormField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre completo / Razón social *',
                            hintText: 'Ej. Juan Pérez o Tech Soluciones S.A.C.',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El nombre o razón social es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // DNI / RUC
                        TextFormField(
                          controller: _dniRucController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'DNI / RUC *',
                            hintText: 'Ej. 70456789 o 20601234567',
                            prefixIcon: Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El DNI o RUC es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Tipo de Cliente (Dropdown)
                        DropdownButtonFormField<String>(
                          initialValue: _tipoSeleccionado,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de cliente *',
                            prefixIcon: Icon(Icons.business_center_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: Cliente.tiposPermitidos.map((tipo) {
                            return DropdownMenuItem<String>(
                              value: tipo,
                              child: Text(tipo),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _tipoSeleccionado = val;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Seleccione el tipo de cliente';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Teléfono
                        TextFormField(
                          controller: _telefonoController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono *',
                            hintText: 'Ej. 987654321',
                            prefixIcon: Icon(Icons.phone_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El teléfono es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Correo electrónico
                        TextFormField(
                          controller: _correoController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico *',
                            hintText: 'Ej. juan@gmail.com',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El correo es obligatorio';
                            }
                            final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!regex.hasMatch(value.trim())) {
                              return 'Ingrese un formato de correo válido (ej. usuario@dominio.com)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Dirección
                        TextFormField(
                          controller: _direccionController,
                          decoration: const InputDecoration(
                            labelText: 'Dirección *',
                            hintText: 'Ej. Huancayo, Jr. Real 450',
                            prefixIcon: Icon(Icons.location_on_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La dirección es obligatoria';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Fecha de Registro con DatePicker
                        TextFormField(
                          controller: _fechaRegistroController,
                          readOnly: true,
                          onTap: _seleccionarFecha,
                          decoration: const InputDecoration(
                            labelText: 'Fecha de registro *',
                            hintText: 'dd/MM/yyyy',
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                            suffixIcon: Icon(Icons.arrow_drop_down),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La fecha es obligatoria';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Estado (Dropdown)
                        DropdownButtonFormField<String>(
                          initialValue: _estadoSeleccionado,
                          decoration: const InputDecoration(
                            labelText: 'Estado *',
                            prefixIcon: Icon(Icons.toggle_on_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: Cliente.estadosPermitidos.map((est) {
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
                              return 'Seleccione el estado';
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
                  onPressed: _isLoading ? null : _guardarCliente,
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
                    _isEditing ? 'Actualizar Cliente' : 'Guardar Cliente',
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
