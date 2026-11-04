// ARCHIVO: LIB/PANTALLAS/PANTALLA_ESCANER.DART

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../datos/base_datos_sqlite.dart';
import '../datos/servicio_alimentos.dart';
import '../modelos/producto.dart';
import '../modelos/perfil_usuario.dart';
import '../logica/motor_reglas.dart';
import 'pantalla_resultado.dart';

// ENUMERACION PARA SELECCIONAR LA FORMA DEL ENCUADRE DE VISION
enum TipoSiluetaGuia {
  codigoBarras,
  empaqueSnack,
}

/// PANTALLA DE ESCANEO CON CAMARA TOTALMENTE TRANSPARENTE, LASER ANIMADO Y CAPTURA MANUAL
class PantallaEscaner extends StatefulWidget {
  const PantallaEscaner({super.key});

  @override
  State<PantallaEscaner> createState() => _EstadoPantallaEscaner();
}

class _EstadoPantallaEscaner extends State<PantallaEscaner>
    with SingleTickerProviderStateMixin {
  // CONTROLADOR EXPLICITO DEL SENSOR DE CAMARA CONFIGURADO PARA ESTABILIDAD EN RELEASE
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
    returnImage: false,
  );

  // CONTROLADOR PARA LA ANIMACION CONTINUA DEL HAZ LASER
  late AnimationController _controladorLaser;
  late Animation<double> _animacionLaser;

  // CONTROL DEL ESTADO DE DETECCION Y ENCUADRE SELECCIONADO
  bool _detectorPausado = false;
  bool _cargandoDatos = false;
  TipoSiluetaGuia _siluetaActiva = TipoSiluetaGuia.codigoBarras;

  // ALMACENA EL ULTIMO VALOR CAPTURADO PARA SOPORTE DE DISPARO MANUAL
  String? _ultimoCodigoDetectado;

  @override
  void initState() {
    super.initState();

    // INICIALIZA EL CICLO DE SUBIDA Y BAJADA DEL RAYO LASER NEON
    _controladorLaser = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _animacionLaser = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controladorLaser,
        curve: Curves.easeInOut,
      ),
    );
  }

  // PROCESA EL CODIGO DETECTADO Y ABRE EL DIAGNOSTICO NUTRICIONAL
  Future<void> _procesarCodigoDetectado(String codigo) async {
    if (_detectorPausado) return;

    // PAUSA EL DETECTOR, DETIENE EL LASER Y ACTIVA EL INDICADOR DE CARGA
    setState(() {
      _detectorPausado = true;
      _cargandoDatos = true;
    });
    _controladorLaser.stop();

    try {
      final baseDatos = BaseDatosSqlite.instancia;

      // PASO 1: CONSULTAR EL SERVICIO UNIVERSAL DE ALIMENTOS (API OPEN FOOD FACTS / SQLITE / FALLBACK)
      final Producto alimento =
          await ServicioAlimentos.obtenerAlimentoUniversal(codigo);

      // PASO 2: RECUPERAR EL PERFIL MEDICO ACTUAL DEL USUARIO
      final PerfilUsuario perfil = await baseDatos.obtenerPerfil();

      if (!mounted) return;

      // PASO 3: EVALUAR LAS REGLAS MEDICAS DEL SEMAFORO NUTRICIONAL
      final evaluacion = MotorReglas.evaluar(alimento, perfil);

      // FORMATEO DE LA FECHA Y HORA LOCAL PARA EL HISTORIAL
      final ahora = DateTime.now();
      final String fechaTexto =
          '${ahora.day.toString().padLeft(2, '0')}/${ahora.month.toString().padLeft(2, '0')}/${ahora.year} '
          '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';

      // PASO 4: REGISTRO AUTOMATICO DEL ESCANEO EN LA BASE DE DATOS LOCAL
      await baseDatos.registrarEscaneo(
        codigoBarras: alimento.codigoBarras,
        nombre: alimento.nombre,
        veredicto: evaluacion.titulo,
        fecha: fechaTexto,
      );

      if (!mounted) return;

      setState(() {
        _cargandoDatos = false;
      });

      // PASO 5: NAVEGACION A LA PANTALLA DE RESULTADOS
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PantallaResultado(
            producto: alimento,
            perfil: perfil,
            evaluacion: evaluacion,
          ),
        ),
      );

      // AL VOLVER SE REANUDA EL VISOR Y LA ANIMACION
      _reanudarEscaneo();
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargandoDatos = false;
        });
      }
      _reanudarEscaneo();
    }
  }

  // ACCION MANUAL DEL BOTON DISPARADOR DE CAMARA
  void _capturarManualmente() {
    if (_detectorPausado) return;

    if (_ultimoCodigoDetectado != null && _ultimoCodigoDetectado!.isNotEmpty) {
      _procesarCodigoDetectado(_ultimoCodigoDetectado!);
    } else {
      // SI AUN NO HA ENFOCADO UN CODIGO, ABRE DIALOGO PARA INGRESO MANUAL DE CODIGO DE BARRAS
      _mostrarDialogoIngresoManual();
    }
  }

  // DIALOGO PARA INGRESAR UN CODIGO DE BARRAS MANUALMENTE O PEGARLO
  void _mostrarDialogoIngresoManual() {
    final TextEditingController controladorTexto = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Row(
          children: [
            Icon(Icons.pin_outlined, color: Color(0xFF00796B)),
            SizedBox(width: 8),
            Text(
              'Ingresar Código',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escribe o pega el código de barras numérico del empaque:',
              style: TextStyle(fontSize: 13, color: Color(0xFF455A64)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controladorTexto,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Código EAN-13',
                prefixIcon: const Icon(Icons.qr_code_2_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004D40),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final texto = controladorTexto.text.trim();
              Navigator.pop(context);
              if (texto.isNotEmpty) {
                _procesarCodigoDetectado(texto);
              }
            },
            child: const Text('ANALIZAR'),
          ),
        ],
      ),
    );
  }

  // REANUDA LA DETECCION Y EL EFECTO LUMINOSO DEL LASER
  void _reanudarEscaneo() {
    if (mounted) {
      setState(() {
        _detectorPausado = false;
        _cargandoDatos = false;
      });
      _controladorLaser.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    // LIBERA EL CONTROLADOR DE LA ANIMACION Y EL CONTROLADOR DE LA CAMARA
    _controladorLaser.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // DIMENSIONES SEGUN EL TIPO DE ENCUADRE SELECCIONADO
    // EMPAQUE/SNACK UTILIZA UN RECTANGULO MAS AMPLIO PARA BOLSAS Y PAQUETES
    final double anchoGuia =
        _siluetaActiva == TipoSiluetaGuia.codigoBarras ? 280.0 : 310.0;
    final double altoGuia =
        _siluetaActiva == TipoSiluetaGuia.codigoBarras ? 170.0 : 380.0;
    final double radioBorde =
        _siluetaActiva == TipoSiluetaGuia.codigoBarras ? 18.0 : 26.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Escáner Nutricional IA'),
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          // BOTON PARA DIGITAR EL CODIGO DE BARRAS MANUALMENTE
          IconButton(
            icon: const Icon(Icons.keyboard_alt_outlined),
            tooltip: 'Ingreso Manual',
            onPressed: _mostrarDialogoIngresoManual,
          ),

          // BOTON PARA ACTIVAR O DESACTIVAR LA LINTERNA
          IconButton(
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: controller,
              builder: (context, estado, child) {
                final bool linternaEncendida =
                    estado.torchState == TorchState.on;
                return Icon(
                  linternaEncendida ? Icons.flash_on : Icons.flash_off,
                  color: linternaEncendida ? Colors.amberAccent : Colors.white,
                );
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. VISOR DE LA CAMARA CON MANEJO LIMPIO DE EXCEPCIONES MEDIANTE ERRORBUILDER
          MobileScanner(
            controller: controller,
            errorBuilder: (context, error, child) {
              // MANEJA CUALQUIER EXCEPCION DE INICIO DE CAMARA DE FORMA LIMPIA Y AMIGABLE
              String mensajeError =
                  'No se pudo iniciar la cámara. Verifica los permisos de cámara de la aplicación.';
              if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
                mensajeError =
                    'Permiso de cámara denegado. Activa el permiso en los ajustes de tu celular.';
              } else if (error.errorCode ==
                  MobileScannerErrorCode.controllerUninitialized) {
                mensajeError = 'Inicializando el sensor de cámara...';
              }

              return ColoredBox(
                color: Colors.black,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.tealAccent,
                          size: 56,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          mensajeError,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: () => controller.start(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00796B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('REINTENTAR CÁMARA'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _mostrarDialogoIngresoManual,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.tealAccent,
                            side: const BorderSide(color: Colors.tealAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.keyboard_alt_outlined),
                          label: const Text('INGRESAR CÓDIGO MANUALMENTE'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            onDetect: (captura) {
              if (_detectorPausado) return;
              for (final barcode in captura.barcodes) {
                final String? valor = barcode.rawValue ?? barcode.displayValue;
                if (valor != null && valor.trim().isNotEmpty) {
                  _ultimoCodigoDetectado = valor.trim();
                  _procesarCodigoDetectado(valor.trim());
                  break;
                }
              }
            },
          ),

          // 2. RECUADRO DE ENCUADRE SIN NINGUN FONDO SOLIDO NI SOMBRA INTERNA PARA NO TAPAR LA CAMARA
          IgnorePointer(
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: anchoGuia,
                height: altoGuia,
                decoration: BoxDecoration(
                  // UNICAMENTE EL BORDE EXTERIOR SIN COLOR DE RELLENO NI BOXSHADOW INTERNO
                  borderRadius: BorderRadius.circular(radioBorde),
                  border: Border.all(
                    color: const Color(0xFF00E676),
                    width: 2.8,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radioBorde - 2),
                  child: Stack(
                    children: [
                      // LINEA HORIZONTAL DE LUZ LASER VERDE NEON QUE SUBE Y BAJA
                      AnimatedBuilder(
                        animation: _animacionLaser,
                        builder: (context, child) {
                          return Positioned(
                            top: _animacionLaser.value * (altoGuia - 6),
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 3.0,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Color(0xFF00E676),
                                    Color(0xFF18FFFF),
                                    Color(0xFF00E676),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. SELECTOR SUPERIOR PARA CAMBIAR ENTRE CODIGO Y EMPAQUE AMPLIO
          Positioned(
            top: 18,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white24,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // OPCION 1: CODIGO DE BARRAS ESTANDAR
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _siluetaActiva = TipoSiluetaGuia.codigoBarras;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: _siluetaActiva == TipoSiluetaGuia.codigoBarras
                              ? const Color(0xFF00796B)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.barcode_reader,
                              size: 18,
                              color: _siluetaActiva ==
                                      TipoSiluetaGuia.codigoBarras
                                  ? Colors.white
                                  : Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Código de Barras',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _siluetaActiva ==
                                        TipoSiluetaGuia.codigoBarras
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // OPCION 2: EMPAQUE / SNACK MAS AMPLIO
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _siluetaActiva = TipoSiluetaGuia.empaqueSnack;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: _siluetaActiva == TipoSiluetaGuia.empaqueSnack
                              ? const Color(0xFF00796B)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 18,
                              color: _siluetaActiva ==
                                      TipoSiluetaGuia.empaqueSnack
                                  ? Colors.white
                                  : Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Empaque / Snack',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _siluetaActiva ==
                                        TipoSiluetaGuia.empaqueSnack
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. BOTON FLOTANTE DE DISPARO MANUAL TIPO CAMARA FOTOGRAFICA
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TEXTO GUIA INFORMATIVO
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _siluetaActiva == TipoSiluetaGuia.codigoBarras
                        ? 'Enfoca el código de barras o pulsa el obturador'
                        : 'Encuadra el paquete de galletas o snack',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // DISPARADOR CIRCULAR TIPO CAMARA
                GestureDetector(
                  onTap: _capturarManualmente,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Color(0xFF004D40),
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 5. INDICADOR DE CARGA Y CONSULTA DE INFORMACION NUTRICIONAL IA
          if (_cargandoDatos)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00382F),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.tealAccent,
                      width: 1.5,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.tealAccent),
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Analizando producto con IA...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
