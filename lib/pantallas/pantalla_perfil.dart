// ARCHIVO: LIB/PANTALLAS/PANTALLA_PERFIL.DART

import 'package:flutter/material.dart';
import '../datos/base_datos_sqlite.dart';
import '../modelos/perfil_usuario.dart';

/// PANTALLA REACTIVA PARA CONFIGURACION Y PERSISTENCIA DEL PERFIL DE SALUD
class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _EstadoPantallaPerfil();
}

class _EstadoPantallaPerfil extends State<PantallaPerfil> {
  // VARIABLES DE ESTADO REACTIVO PARA CADA CONDICION MEDICA
  bool _diabetes = false;
  bool _hipertension = false;
  bool _celiaquia = false;
  bool _alergiaLactosa = false;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPerfilDesdeSqlite();
  }

  // RECUPERA EL PERFIL ALMACENADO EN SQLITE LOCAL
  Future<void> _cargarPerfilDesdeSqlite() async {
    final perfil = await BaseDatosSqlite.instancia.obtenerPerfil();
    if (mounted) {
      setState(() {
        _diabetes = perfil.tieneDiabetes;
        _hipertension = perfil.tieneHipertension;
        _celiaquia = perfil.tieneCeliaquia;
        _alergiaLactosa = perfil.alergiaLactosa;
        _cargando = false;
      });
    }
  }

  // GUARDA DE INMEDIATO EN LA TABLA 'perfil_usuario' DE SQLITE
  Future<void> _persistirCambios({bool mostrarMensaje = false}) async {
    final perfilActualizado = PerfilUsuario(
      id: 1,
      tieneDiabetes: _diabetes,
      tieneHipertension: _hipertension,
      tieneCeliaquia: _celiaquia,
      alergiaLactosa: _alergiaLactosa,
    );

    await BaseDatosSqlite.instancia.guardarPerfil(perfilActualizado);

    if (mostrarMensaje && mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Perfil de salud actualizado correctamente',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF00796B),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Mi Perfil de Salud'),
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00796B)),
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              children: [
                // BANNER EXPLICATIVO SUPERIOR
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF80CBC4),
                      width: 1.2,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.health_and_safety_rounded,
                          color: Color(0xFF00695C), size: 36),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Selecciona tus condiciones o alergias médicas. El motor de reglas evaluará cada alimento escaneado según esta configuración.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF004D40),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // TARJETA CONTENEDORA DE INTERRUPTORES REACTIVOS
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        // 1. CONDICION: DIABETES
                        SwitchListTile(
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.water_drop_rounded,
                                color: Colors.blue),
                          ),
                          title: const Text(
                            'Diabetes Mellitus',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: const Text(
                            'Control riguroso de azúcares y carbohidratos.',
                            style: TextStyle(fontSize: 13),
                          ),
                          value: _diabetes,
                          activeThumbColor: const Color(0xFF00796B),
                          onChanged: (valor) {
                            setState(() {
                              _diabetes = valor;
                            });
                            _persistirCambios();
                          },
                        ),
                        const Divider(height: 1),

                        // 2. CONDICION: HIPERTENSION
                        SwitchListTile(
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.favorite_rounded,
                                color: Colors.redAccent),
                          ),
                          title: const Text(
                            'Hipertensión Arterial',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: const Text(
                            'Restricción estricta de sodio y contenido de sal.',
                            style: TextStyle(fontSize: 13),
                          ),
                          value: _hipertension,
                          activeThumbColor: const Color(0xFF00796B),
                          onChanged: (valor) {
                            setState(() {
                              _hipertension = valor;
                            });
                            _persistirCambios();
                          },
                        ),
                        const Divider(height: 1),

                        // 3. CONDICION: CELIAQUIA
                        SwitchListTile(
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.grass_rounded,
                                color: Colors.orange),
                          ),
                          title: const Text(
                            'Celiaquía / Sin Gluten',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: const Text(
                            'Exclusión de alimentos con trigo, cebada y centeno.',
                            style: TextStyle(fontSize: 13),
                          ),
                          value: _celiaquia,
                          activeThumbColor: const Color(0xFF00796B),
                          onChanged: (valor) {
                            setState(() {
                              _celiaquia = valor;
                            });
                            _persistirCambios();
                          },
                        ),
                        const Divider(height: 1),

                        // 4. CONDICION: ALERGIA A LA LACTOSA
                        SwitchListTile(
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.coffee_rounded,
                                color: Colors.purple),
                          ),
                          title: const Text(
                            'Alergia / Intolerancia a la Lactosa',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: const Text(
                            'Alerta sobre lácteos y derivados de leche.',
                            style: TextStyle(fontSize: 13),
                          ),
                          value: _alergiaLactosa,
                          activeThumbColor: const Color(0xFF00796B),
                          onChanged: (valor) {
                            setState(() {
                              _alergiaLactosa = valor;
                            });
                            _persistirCambios();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // BOTON EXPLICITO PARA GUARDAR EL PERFIL
                ElevatedButton.icon(
                  onPressed: () => _persistirCambios(mostrarMensaje: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004D40),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                  icon: const Icon(Icons.save_rounded),
                  label: const Text(
                    'GUARDAR MI PERFIL DE SALUD',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
    );
  }
}