// ARCHIVO: LIB/PANTALLAS/PANTALLA_RECURSOS_PRUEBA.DART

import 'package:flutter/material.dart';
import '../datos/base_datos_sqlite.dart';
import '../datos/servicio_alimentos.dart';
import '../datos/servicio_pdf.dart';
import '../modelos/producto.dart';
import 'pantalla_resultado.dart';

/// PANTALLA QUE DESPLIEGA LOS MARCADORES OFICIALES Y PERMITE DESCARGAR Y GUARDAR LOS DOCUMENTOS PDF EN EL CELULAR
class PantallaRecursosPrueba extends StatefulWidget {
  const PantallaRecursosPrueba({super.key});

  @override
  State<PantallaRecursosPrueba> createState() => _EstadoPantallaRecursosPrueba();
}

class _EstadoPantallaRecursosPrueba extends State<PantallaRecursosPrueba> {
  // ESTADO DE CARGA DURANTE LA GENERACION DE DOCUMENTOS PDF
  bool _procesandoPdf = false;

  // DESCARGA Y GUARDA EL DOCUMENTO PDF COMPLETO CON TODOS LOS MARCADORES
  Future<void> _descargarPdfCompleto() async {
    setState(() => _procesandoPdf = true);
    try {
      final bytes = await ServicioPdf.generarPdfCompleto();
      if (mounted) {
        await ServicioPdf.descargarYCompartirPdf(
          context: context,
          bytesPdf: bytes,
          nombreArchivo: 'nutriscan_reporte_marcadores.pdf',
          tituloNotificacion: 'Documento PDF Completo guardado',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _procesandoPdf = false);
      }
    }
  }

  // DESCARGA Y GUARDA EL DOCUMENTO PDF INDIVIDUAL DE UN ALIMENTO ESPECIFICO
  Future<void> _descargarPdfIndividual({
    required Producto producto,
    required String porcion,
    required String casoPrueba,
    required String nombreArchivo,
  }) async {
    setState(() => _procesandoPdf = true);
    try {
      final bytes = await ServicioPdf.generarPdfIndividual(
        producto: producto,
        porcion: porcion,
        casoPrueba: casoPrueba,
      );
      if (mounted) {
        await ServicioPdf.descargarYCompartirPdf(
          context: context,
          bytesPdf: bytes,
          nombreArchivo: nombreArchivo,
          tituloNotificacion: 'Marcador PDF guardado',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _procesandoPdf = false);
      }
    }
  }

  // EVALUA EL ALIMENTO Y ABRE EL RESULTADO CLINICO
  Future<void> _evaluarAlimento(BuildContext context, String codigo) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00796B)),
          ),
        ),
      );

      final producto =
          await ServicioAlimentos.obtenerAlimentoUniversal(codigo);
      final perfil = await BaseDatosSqlite.instancia.obtenerPerfil();

      if (context.mounted) {
        Navigator.pop(context); // CIERRA EL DIALOGO DE CARGA
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaResultado(
              producto: producto,
              perfil: perfil,
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Recursos de Prueba y PDF'),
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Descargar / Guardar PDF Completo',
            icon: const Icon(Icons.download_rounded),
            onPressed: _procesandoPdf ? null : _descargarPdfCompleto,
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
            children: [
              // 1. PANEL SUPERIOR PRINCIPAL PARA DESCARGAR Y GUARDAR EL PDF COMPLETO EN EL CELULAR
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF004D40), Color(0xFF00796B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF004D40).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Reporte y Marcadores en PDF',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Guarda y abre el documento PDF directamente en tu celular mediante el selector nativo de Android (Guardar en Descargas, Abrir con Lector PDF o Compartir).',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFE0F2F1),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // BOTON PRINCIPAL DESTACADO PARA DESCARGAR / GUARDAR TODO EL PDF
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _procesandoPdf ? null : _descargarPdfCompleto,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF004D40),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.file_download_rounded, size: 22),
                        label: const Text(
                          'DESCARGAR / GUARDAR PDF COMPLETO',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              const Text(
                'MARCADORES INDIVIDUALES DE LA RÚBRICA',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF455A64),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 12),

              // PRODUCTO 1: PAPAS MARGARITA NATURAL 25G
              _tarjetaMarcador(
                context: context,
                producto: Producto(
                  codigoBarras: '7702189000019',
                  nombre: 'Papas Margarita Natural 25g',
                  categoria: 'Snack / Fritura Salada',
                  calorias: 135.0,
                  azucares: 0.0,
                  sodio: 125.0,
                  sellos: ['EXCESO EN SODIO', 'EXCESO EN GRASAS SATURADAS'],
                ),
                porcion: 'Paquete comercial de 25g',
                caloriasTexto: '135.0 kcal (paquete 25g)',
                nutrienteCritico: 'Sodio: 125.0 mg (Porción del empaque)',
                sellosTexto: 'EXCESO EN SODIO, EXCESO EN GRASAS',
                pruebaSalud: 'Hipertensión -> Veredicto: NO RECOMENDADO',
                nombreArchivoPdf: 'marcador_papas_margarita_25g.pdf',
                colorFondoIcono: Colors.amber.shade100,
                colorIcono: Colors.amber.shade900,
                icono: Icons.lunch_dining_rounded,
                onProbar: () => _evaluarAlimento(context, '7702189000019'),
              ),
              const SizedBox(height: 16),

              // PRODUCTO 2: GASEOSA COCA-COLA ORIGINAL 400ML
              _tarjetaMarcador(
                context: context,
                producto: Producto(
                  codigoBarras: '5449000000996',
                  nombre: 'Gaseosa Coca-Cola Original 400ml',
                  categoria: 'Bebida Azucarada Refrescante',
                  calorias: 170.0,
                  azucares: 42.0,
                  sodio: 40.0,
                  sellos: ['EXCESO EN AZÚCARES', 'CONTIENE EDULCORANTES'],
                ),
                porcion: 'Envase personal de 400ml',
                caloriasTexto: '170.0 kcal (envase 400ml)',
                nutrienteCritico: 'Azúcares: 42.0 g (Porción del envase)',
                sellosTexto: 'EXCESO EN AZÚCARES, CONTIENE EDULCORANTES',
                pruebaSalud: 'Diabetes -> Veredicto: NO RECOMENDADO',
                nombreArchivoPdf: 'marcador_coca_cola_400ml.pdf',
                colorFondoIcono: Colors.red.shade100,
                colorIcono: Colors.red.shade900,
                icono: Icons.local_drink_rounded,
                onProbar: () => _evaluarAlimento(context, '5449000000996'),
              ),
              const SizedBox(height: 16),

              // PRODUCTO 3: GALLETAS FESTIVAL CHOCOLATE
              _tarjetaMarcador(
                context: context,
                producto: Producto(
                  codigoBarras: '7702025102032',
                  nombre: 'Galletas Festival Chocolate 403g',
                  categoria: 'Galletas y Dulces Comerciales',
                  calorias: 260.0,
                  azucares: 22.0,
                  sodio: 110.0,
                  sellos: ['EXCESO EN AZÚCARES', 'EXCESO EN GRASAS SATURADAS'],
                ),
                porcion: 'Porción de 4 galletas (56g)',
                caloriasTexto: '260.0 kcal (porción 4 galletas / 56g)',
                nutrienteCritico: 'Azúcares: 22.0 g | Gluten y Lactosa',
                sellosTexto: 'EXCESO EN AZÚCARES, EXCESO EN GRASAS',
                pruebaSalud: 'Celiaquía o Lactosa -> NO RECOMENDADO',
                nombreArchivoPdf: 'marcador_galletas_festival.pdf',
                colorFondoIcono: Colors.brown.shade100,
                colorIcono: Colors.brown.shade800,
                icono: Icons.cookie_rounded,
                onProbar: () => _evaluarAlimento(context, '7702025102032'),
              ),
              const SizedBox(height: 24),
            ],
          ),

          // INDICADOR DE CARGA TRANSPARENTE DURANTE LA GENERACION DE PDF
          if (_procesandoPdf)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF00796B)),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Preparando PDF...',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // TARJETA DE CADA PRODUCTO CON SUS BOTONES DE ACCION
  Widget _tarjetaMarcador({
    required BuildContext context,
    required Producto producto,
    required String porcion,
    required String caloriasTexto,
    required String nutrienteCritico,
    required String sellosTexto,
    required String pruebaSalud,
    required String nombreArchivoPdf,
    required Color colorFondoIcono,
    required Color colorIcono,
    required IconData icono,
    required VoidCallback onProbar,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorFondoIcono,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icono, color: colorIcono, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombre,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${producto.categoria} • $porcion',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // CODIGO DE BARRAS
            Row(
              children: [
                const Icon(
                  Icons.qr_code_2_rounded,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Text(
                  'Código EAN-13: ${producto.codigoBarras}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // VALORES REALES DE LA PORCION DECLARADA
            Text(
              '• Energía: $caloriasTexto',
              style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 3),
            Text(
              '• $nutrienteCritico',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB71C1C),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '• Sellos: $sellosTexto',
              style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 8),

            // CASO CLINICO DE PRUEBA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECDD3)),
              ),
              child: Text(
                'Prueba: $pruebaSalud',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFBE123C),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // FILA DE BOTONES DE ACCION: DESCARGAR / GUARDAR PDF INDIVIDUAL Y PROBAR EVALUACION
            Row(
              children: [
                // BOTON 1: DESCARGAR / GUARDAR EL PDF DE ESTE PRODUCTO
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _procesandoPdf
                        ? null
                        : () => _descargarPdfIndividual(
                              producto: producto,
                              porcion: porcion,
                              casoPrueba: pruebaSalud,
                              nombreArchivo: nombreArchivoPdf,
                            ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF004D40),
                      side: const BorderSide(
                        color: Color(0xFF00796B),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.file_download_outlined, size: 18),
                    label: const Text(
                      'GUARDAR PDF',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // BOTON 2: EVALUACION CLINICA INMEDIATA
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onProbar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004D40),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 1.5,
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text(
                      'PROBAR AHORA',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
