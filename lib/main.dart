// ARCHIVO: LIB/MAIN.DART

import 'package:flutter/material.dart';
import 'datos/base_datos_sqlite.dart';
import 'modelos/perfil_usuario.dart';
import 'pantallas/pantalla_bienvenida.dart';
import 'pantallas/pantalla_escaner.dart';
import 'pantallas/pantalla_historial.dart';
import 'pantallas/pantalla_perfil.dart';

// PUNTO DE INICIO ASINCRONO CON INICIALIZACION DE WIDGETS Y SQLITE
void main() async {
  // ASEGURA LA CORRECTA VINCULACION CON EL MOTOR DE FLUTTER
  WidgetsFlutterBinding.ensureInitialized();

  // INICIALIZA LA BASE DE DATOS LOCAL SQLITE ANTES DE LEVANTAR LA VISTA
  await BaseDatosSqlite.instancia.baseDatos;

  runApp(const AplicacionNutriScan());
}

/// APLICACION PRINCIPAL CON CONFIGURACION DE TEMA Y PANTALLA INICIAL
class AplicacionNutriScan extends StatelessWidget {
  const AplicacionNutriScan({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriScan Express',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00796B),
          primary: const Color(0xFF004D40),
          secondary: const Color(0xFF00897B),
        ),
        useMaterial3: true,
      ),
      // PANTALLA INICIAL DEFINIDA COMO LA PANTALLA DE BIENVENIDA
      home: const PantallaBienvenida(),
    );
  }
}

/// PANTALLA PRINCIPAL TIPO DASHBOARD CON ACCESOS DIRECTOS Y RESUMEN
class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _EstadoPantallaPrincipal();
}

class _EstadoPantallaPrincipal extends State<PantallaPrincipal> {
  // PERFIL ACTIVO CARGADO DE LA BASE DE DATOS LOCAL
  PerfilUsuario _perfilActivo = PerfilUsuario();
  bool _cargandoPerfil = true;

  @override
  void initState() {
    super.initState();
    _cargarPerfilActual();
  }

  // RECUPERA EL PERFIL MEDICO DESDE SQLITE PARA MOSTRAR SU ESTADO
  Future<void> _cargarPerfilActual() async {
    final perfil = await BaseDatosSqlite.instancia.obtenerPerfil();
    if (mounted) {
      setState(() {
        _perfilActivo = perfil;
        _cargandoPerfil = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('NutriScan Express'),
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _cargarPerfilActual,
          color: const Color(0xFF00796B),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ENCABEZADO SUPERIOR CON SALUDO E IDENTIDAD DE LA APLICACION
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00796B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.health_and_safety_rounded,
                        color: Color(0xFF00796B),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Asistente Nutricional IA',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Evaluación y prevención alimentaria en tiempo real',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // TARJETA DE RESUMEN DEL PERFIL DE SALUD ACTIVO
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF80CBC4).withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'MI PERFIL MÉDICO ACTIVO',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF004D40),
                              letterSpacing: 0.8,
                            ),
                          ),
                          if (_cargandoPerfil)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          _chipCondicion(
                            'Diabetes',
                            _perfilActivo.tieneDiabetes,
                            Icons.water_drop_rounded,
                            Colors.blue,
                          ),
                          _chipCondicion(
                            'Hipertensión',
                            _perfilActivo.tieneHipertension,
                            Icons.favorite_rounded,
                            Colors.redAccent,
                          ),
                          _chipCondicion(
                            'Celiaquía',
                            _perfilActivo.tieneCeliaquia,
                            Icons.grass_rounded,
                            Colors.orange,
                          ),
                          _chipCondicion(
                            'Lactosa',
                            _perfilActivo.alergiaLactosa,
                            Icons.coffee_rounded,
                            Colors.purple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // TITULO DE ACCESOS PRINCIPALES
                const Text(
                  'ACCIONES PRINCIPALES',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF455A64),
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 12),

                // 1. ACCESO: ESCANEAR CON CAMARA (IA)
                _tarjetaBoton(
                  titulo: 'ESCANEAR CON CÁMARA (IA)',
                  descripcion:
                      'Reconocimiento en vivo por visión artificial y ML Kit',
                  icono: Icons.qr_code_scanner_rounded,
                  colorFondo: const Color(0xFF004D40),
                  colorTexto: Colors.white,
                  colorIcono: Colors.tealAccent,
                  esDestacado: true,
                  alPresionar: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PantallaEscaner(),
                      ),
                    );
                    _cargarPerfilActual();
                  },
                ),
                const SizedBox(height: 14),

                // 2. ACCESO: HISTORIAL DE ESCANEOS
                _tarjetaBoton(
                  titulo: 'HISTORIAL DE ESCANEOS',
                  descripcion:
                      'Consulta el registro dinámico de alimentos evaluados',
                  icono: Icons.history_rounded,
                  colorFondo: Colors.white,
                  colorTexto: const Color(0xFF263238),
                  colorIcono: const Color(0xFF00796B),
                  esDestacado: false,
                  alPresionar: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PantallaHistorial(),
                      ),
                    );
                    _cargarPerfilActual();
                  },
                ),
                const SizedBox(height: 14),

                // 3. ACCESO: CONFIGURAR MI PERFIL DE SALUD
                _tarjetaBoton(
                  titulo: 'CONFIGURAR MI PERFIL DE SALUD',
                  descripcion:
                      'Ajusta tus condiciones médicas y restricciones',
                  icono: Icons.person_search_rounded,
                  colorFondo: Colors.white,
                  colorTexto: const Color(0xFF263238),
                  colorIcono: const Color(0xFF00796B),
                  esDestacado: false,
                  alPresionar: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PantallaPerfil(),
                      ),
                    );
                    _cargarPerfilActual();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET AUXILIAR PARA GENERAR CADA BOTON PRINCIPAL DEL DASHBOARD
  Widget _tarjetaBoton({
    required String titulo,
    required String descripcion,
    required IconData icono,
    required Color colorFondo,
    required Color colorTexto,
    required Color colorIcono,
    required bool esDestacado,
    required VoidCallback alPresionar,
  }) {
    return Material(
      color: colorFondo,
      borderRadius: BorderRadius.circular(18),
      elevation: esDestacado ? 4 : 2,
      child: InkWell(
        onTap: alPresionar,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: esDestacado
                  ? Colors.tealAccent.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: esDestacado
                      ? Colors.white.withValues(alpha: 0.12)
                      : colorIcono.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icono, color: colorIcono, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorTexto,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descripcion,
                      style: TextStyle(
                        fontSize: 12,
                        color: esDestacado
                            ? Colors.white.withValues(alpha: 0.8)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: esDestacado ? Colors.tealAccent : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET AUXILIAR PARA LAS ETIQUETAS DE ESTADO DEL PERFIL MEDICO
  Widget _chipCondicion(
    String condicion,
    bool activo,
    IconData icono,
    Color colorTema,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: activo
            ? colorTema.withValues(alpha: 0.14)
            : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activo ? colorTema.withValues(alpha: 0.6) : Colors.black12,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: 14,
            color: activo ? colorTema : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            '$condicion: ${activo ? "SÍ" : "NO"}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: activo
                  ? colorTema.withValues(alpha: 0.9)
                  : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
