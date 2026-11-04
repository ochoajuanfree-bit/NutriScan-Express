// ARCHIVO: LIB/PANTALLAS/PANTALLA_RESULTADO.DART

import 'package:flutter/material.dart';
import '../datos/servicio_pdf.dart';
import '../modelos/producto.dart';
import '../modelos/perfil_usuario.dart';
import '../logica/motor_reglas.dart';
import 'pantalla_historial.dart';

/// PANTALLA QUE PRESENTA EL INFORME NUTRICIONAL, VEREDICTO MEDICO Y DESCARGA DE REPORTE PDF
class PantallaResultado extends StatefulWidget {
  final Producto producto;
  final PerfilUsuario perfil;
  final ResultadoEvaluacion? evaluacion;

  const PantallaResultado({
    super.key,
    required this.producto,
    required this.perfil,
    this.evaluacion,
  });

  @override
  State<PantallaResultado> createState() => _EstadoPantallaResultado();
}

class _EstadoPantallaResultado extends State<PantallaResultado> {
  // ESTADO DE CARGA DURANTE LA GENERACION DEL REPORTE PDF
  bool _descargandoPdf = false;

  // ASIGNA EL COLOR PRINCIPAL DEL SEMAFORO NUTRICIONAL
  Color _obtenerColorSemaforo(VeredictoSemaforo veredicto) {
    switch (veredicto) {
      case VeredictoSemaforo.verdeRecomendado:
        return const Color(0xFF2E7D32); // VERDE ESMERALDA
      case VeredictoSemaforo.amarilloModeracion:
        return const Color(0xFFE65100); // AMBAR INTENSO
      case VeredictoSemaforo.rojoNoRecomendado:
        return const Color(0xFFC62828); // ROJO ALERTA
    }
  }

  // ASIGNA EL ICONO ASOCIADO AL VEREDICTO MEDICO
  IconData _obtenerIconoSemaforo(VeredictoSemaforo veredicto) {
    switch (veredicto) {
      case VeredictoSemaforo.verdeRecomendado:
        return Icons.check_circle_rounded;
      case VeredictoSemaforo.amarilloModeracion:
        return Icons.warning_amber_rounded;
      case VeredictoSemaforo.rojoNoRecomendado:
        return Icons.dangerous_rounded;
    }
  }

  // GENERA Y GUARDA EL REPORTE NUTRICIONAL EN PDF ABRIENDO EL SELECTOR NATIVO DE ANDROID
  Future<void> _descargarReportePdf(ResultadoEvaluacion evaluacionFinal) async {
    setState(() => _descargandoPdf = true);
    try {
      final bytesPdf = await ServicioPdf.generarPdfReporteEvaluacion(
        producto: widget.producto,
        perfil: widget.perfil,
        evaluacion: evaluacionFinal,
      );

      if (mounted) {
        final codigoLimpio = widget.producto.codigoBarras.replaceAll(
          RegExp(r'[^a-zA-Z0-9]'),
          '',
        );
        await ServicioPdf.descargarYCompartirPdf(
          context: context,
          bytesPdf: bytesPdf,
          nombreArchivo: 'reporte_nutricional_$codigoLimpio.pdf',
          tituloNotificacion: 'Reporte PDF listo para guardar',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _descargandoPdf = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // EVALUA EN TIEMPO REAL SI NO FUE PROVISTO PREVIAMENTE
    final evaluacionFinal =
        widget.evaluacion ?? MotorReglas.evaluar(widget.producto, widget.perfil);
    final colorPrincipal = _obtenerColorSemaforo(evaluacionFinal.veredicto);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Diagnóstico Nutricional'),
        backgroundColor: colorPrincipal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          // BOTON EN LA BARRA SUPERIOR PARA DESCARGAR / GUARDAR EL REPORTE PDF
          IconButton(
            tooltip: 'Descargar / Guardar PDF',
            icon: const Icon(Icons.picture_as_pdf_rounded),
            onPressed: _descargandoPdf
                ? null
                : () => _descargarReportePdf(evaluacionFinal),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. TARJETA ELEGANTE DEL VEREDICTO DEL SEMAFORO
            Container(
              decoration: BoxDecoration(
                color: colorPrincipal,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: colorPrincipal.withValues(alpha: 0.38),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
              child: Column(
                children: [
                  // ICONO CON RESPLANDOR CIRCULAR
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: Icon(
                      _obtenerIconoSemaforo(evaluacionFinal.veredicto),
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // TITULO DEL VEREDICTO
                  Text(
                    evaluacionFinal.titulo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // JUSTIFICACION MEDICA
                  Text(
                    evaluacionFinal.justificacion,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 2. SECCION DE ALERTAS MEDICAS SEGUN EL PERFIL ACTIVO
            const Padding(
              padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                'EVALUACIÓN DE PERFIL MÉDICO',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF455A64),
                  letterSpacing: 0.6,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // CONDICIONES ANALIZADAS
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 6.0,
                    children: [
                      _badgeCondicion('Diabetes', widget.perfil.tieneDiabetes),
                      _badgeCondicion(
                        'Hipertensión',
                        widget.perfil.tieneHipertension,
                      ),
                      _badgeCondicion('Celiaquía', widget.perfil.tieneCeliaquia),
                      _badgeCondicion('Lactosa', widget.perfil.alergiaLactosa),
                    ],
                  ),
                  const Divider(height: 22),

                  // DETALLE DE ADVERTENCIAS GENERADAS POR EL MOTOR
                  if (evaluacionFinal.advertencias.isNotEmpty) ...[
                    ...evaluacionFinal.advertencias.map(
                      (advertencia) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Color(0xFFC62828),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                advertencia,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF263238),
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    const Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF2E7D32),
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Alimento compatible sin restricciones detectadas para tu perfil.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 4. INFORMACION COMERCIAL DEL PRODUCTO
            const Padding(
              padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                'INFORMACIÓN DEL PRODUCTO',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF455A64),
                  letterSpacing: 0.6,
                ),
              ),
            ),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.producto.nombre,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B1B1B),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // BADGE DE CATEGORIA
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2F1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF80CBC4)),
                          ),
                          child: Text(
                            widget.producto.categoria,
                            style: const TextStyle(
                              color: Color(0xFF00796B),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        // BADGE DEL CODIGO DE BARRAS EXACTO
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.qr_code_2_rounded,
                                size: 16,
                                color: Color(0xFF475569),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Código: ${widget.producto.codigoBarras}',
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28),

                    // TABLA NUTRICIONAL CON CALORIAS TOTALES Y MACRONUTRIENTES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _columnaNutriente(
                          'Calorías',
                          '${widget.producto.calorias}',
                          'kcal',
                          Icons.local_fire_department_rounded,
                          Colors.deepOrange,
                        ),
                        _columnaNutriente(
                          'Azúcares',
                          '${widget.producto.azucares}',
                          'g',
                          Icons.water_drop_rounded,
                          Colors.blue,
                        ),
                        _columnaNutriente(
                          'Sodio',
                          '${widget.producto.sodio}',
                          'mg',
                          Icons.grain_rounded,
                          Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 5. INSIGNIAS NEGRAS Y ROJAS PARA SELLOS DE ADVERTENCIA
            if (widget.producto.sellos.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  'SELLOS FRONTALES DE ADVERTENCIA',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF455A64),
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: widget.producto.sellos.map((sello) {
                  final bool esCritico = sello.contains('EXCESO');
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: esCritico
                            ? const Color(0xFFD32F2F)
                            : Colors.white30,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: esCritico
                              ? const Color(0xFFFF5252)
                              : Colors.amberAccent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          sello.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // 6. BOTONES DE ACCION: DESCARGAR / GUARDAR PDF, CONTINUAR ESCANEANDO O VER HISTORIAL
            ElevatedButton.icon(
              onPressed: _descargandoPdf
                  ? null
                  : () => _descargarReportePdf(evaluacionFinal),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
              ),
              icon: _descargandoPdf
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf_rounded),
              label: Text(
                _descargandoPdf
                    ? 'GENERANDO REPORTE PDF...'
                    : 'DESCARGAR / GUARDAR PDF',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004D40),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
              ),
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text(
                'CONTINUAR ESCANEANDO',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaHistorial(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF004D40),
                side: const BorderSide(color: Color(0xFF00796B), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.history_rounded),
              label: const Text(
                'VER HISTORIAL DE ESCANEOS',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET AUXILIAR PARA REPRESENTAR CADA NUTRIENTE CLAVE
  Widget _columnaNutriente(
    String etiqueta,
    String valor,
    String unidad,
    IconData icono,
    Color colorIcono,
  ) {
    return Column(
      children: [
        Icon(icono, color: colorIcono, size: 26),
        const SizedBox(height: 6),
        Text(
          etiqueta,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: valor,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Color(0xFF212121),
                ),
              ),
              TextSpan(
                text: ' $unidad',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // WIDGET AUXILIAR PARA MOSTRAR EL ESTADO DE CADA CONDICION MEDICA
  Widget _badgeCondicion(String nombre, bool activa) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: activa
            ? const Color(0xFF004D40).withValues(alpha: 0.12)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: activa ? const Color(0xFF00796B) : Colors.black12,
        ),
      ),
      child: Text(
        '$nombre: ${activa ? "ACTIVO" : "INACTIVO"}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: activa ? const Color(0xFF004D40) : Colors.grey.shade600,
        ),
      ),
    );
  }
}
