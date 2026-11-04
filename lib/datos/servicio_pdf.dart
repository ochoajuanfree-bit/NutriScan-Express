// ARCHIVO: LIB/DATOS/SERVICIO_PDF.DART

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../logica/motor_reglas.dart';
import '../modelos/perfil_usuario.dart';
import '../modelos/producto.dart';

/// SERVICIO ESPECIALIZADO PARA LA GENERACION Y DESCARGA NATIVA DE DOCUMENTOS PDF EN ANDROID 11, 12 Y 13 (API 33)
class ServicioPdf {
  // OBTIENE LA FECHA Y HORA ACTUAL FORMATEADA PARA EL ENCABEZADO DEL DOCUMENTO PDF
  static String _obtenerFechaActualFormateada() {
    final ahora = DateTime.now();
    final dia = ahora.day.toString().padLeft(2, '0');
    final mes = ahora.month.toString().padLeft(2, '0');
    final anio = ahora.year.toString();
    final hora = ahora.hour.toString().padLeft(2, '0');
    final minuto = ahora.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$anio $hora:$minuto';
  }

  // CONSTRUYE EL ENCABEZADO OFICIAL CON EL TITULO, EL AUTOR Y LA FECHA DE GENERACION
  static pw.Widget _construirEncabezadoOficial({
    required String subtituloDocumento,
  }) {
    final fechaActual = _obtenerFechaActualFormateada();

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.teal900,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'NutriScan Express - Reporte Nutricional',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Evaluador / Desarrollador: Juan David Ochoa',
            style: pw.TextStyle(
              color: PdfColors.teal100,
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Fecha de generación: $fechaActual',
                style: const pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 10,
                ),
              ),
              pw.Text(
                subtituloDocumento,
                style: pw.TextStyle(
                  color: PdfColors.teal100,
                  fontSize: 9.5,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // GENERA EL DOCUMENTO PDF COMPLETO CON TODOS LOS MARCADORES Y REPORTES DE LA RUBRICA
  static Future<List<int>> generarPdfCompleto() async {
    final documento = pw.Document();

    // DATOS OFICIALES DE LOS 3 PRODUCTOS EXIGIDOS POR LA RUBRICA
    final listaAlimentos = [
      {
        'producto': Producto(
          codigoBarras: '7702189000019',
          nombre: 'Papas Margarita Natural 25g',
          categoria: 'Snacks / Fritura Salada',
          calorias: 135.0,
          azucares: 0.0,
          sodio: 125.0,
          sellos: ['EXCESO EN SODIO', 'EXCESO EN GRASAS SATURADAS'],
        ),
        'porcion': 'Paquete comercial de 25 g',
        'prueba': 'Hipertensión Arterial -> Veredicto: NO RECOMENDADO',
      },
      {
        'producto': Producto(
          codigoBarras: '5449000000996',
          nombre: 'Gaseosa Coca-Cola Original 400ml',
          categoria: 'Bebida Azucarada Refrescante',
          calorias: 170.0,
          azucares: 42.0,
          sodio: 40.0,
          sellos: ['EXCESO EN AZÚCARES', 'CONTIENE EDULCORANTES'],
        ),
        'porcion': 'Envase personal de 400 ml',
        'prueba': 'Diabetes Mellitus -> Veredicto: NO RECOMENDADO',
      },
      {
        'producto': Producto(
          codigoBarras: '7702025102032',
          nombre: 'Galletas Festival Chocolate 403g',
          categoria: 'Galletas y Dulces Comerciales',
          calorias: 260.0,
          azucares: 22.0,
          sodio: 110.0,
          sellos: ['EXCESO EN AZÚCARES', 'EXCESO EN GRASAS SATURADAS'],
        ),
        'porcion': 'Porción declarada de 4 galletas (56 g)',
        'prueba': 'Celiaquía o Intolerancia a Lactosa -> NO RECOMENDADO',
      },
    ];

    documento.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return [
            // ENCABEZADO OFICIAL CON AUTOR Y FECHA ACTUAL
            _construirEncabezadoOficial(
              subtituloDocumento: 'CATÁLOGO OFICIAL DE MARCADORES',
            ),
            pw.SizedBox(height: 14),

            // DESCRIPCION GENERAL DE LA GUIA DE PRUEBA
            pw.Text(
              'Documento Oficial de Marcadores e Información Nutricional',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Apunta con la cámara de NutriScan Express a cada código de barras para verificar la detección en tiempo real y el análisis clínico según el perfil médico configurado.',
              style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 14),

            // ITERACION DE LOS 3 ALIMENTOS
            ...listaAlimentos.map((elemento) {
              final prod = elemento['producto'] as Producto;
              final porcion = elemento['porcion'] as String;
              final prueba = elemento['prueba'] as String;

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 1),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // COLUMNA DEL CODIGO DE BARRAS ESCANEABLE
                    pw.Container(
                      width: 165,
                      child: pw.Column(
                        children: [
                          pw.BarcodeWidget(
                            barcode: pw.Barcode.ean13(),
                            data: prod.codigoBarras,
                            width: 155,
                            height: 65,
                            drawText: true,
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'EAN-13: ${prod.codigoBarras}',
                            style: const pw.TextStyle(fontSize: 8.5),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 14),

                    // DETALLES DEL PRODUCTO Y REGLAS CLINICAS
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            prod.nombre,
                            style: pw.TextStyle(
                              fontSize: 12.5,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.teal900,
                            ),
                          ),
                          pw.Text(
                            'Categoría: ${prod.categoria}',
                            style: const pw.TextStyle(
                              fontSize: 9,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.Text(
                            'Porción Real: $porcion',
                            style: const pw.TextStyle(
                              fontSize: 9,
                              color: PdfColors.grey800,
                            ),
                          ),
                          pw.SizedBox(height: 5),

                          // TABLA DE VALORES NUTRICIONALES
                          pw.Container(
                            padding: const pw.EdgeInsets.all(5),
                            color: PdfColors.grey100,
                            child: pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceAround,
                              children: [
                                pw.Text(
                                  'Energía: ${prod.calorias} kcal',
                                  style: const pw.TextStyle(fontSize: 8.5),
                                ),
                                pw.Text(
                                  'Azúcares: ${prod.azucares} g',
                                  style: const pw.TextStyle(fontSize: 8.5),
                                ),
                                pw.Text(
                                  'Sodio: ${prod.sodio} mg',
                                  style: const pw.TextStyle(fontSize: 8.5),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 5),

                          // SELLOS OFICIALES DE ADVERTENCIA
                          pw.Text(
                            'Sellos Frontales: ${prod.sellos.join(" | ")}',
                            style: pw.TextStyle(
                              fontSize: 8.5,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red900,
                            ),
                          ),
                          pw.SizedBox(height: 4),

                          // CASO CLINICO EVALUADO
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.red50,
                              borderRadius: pw.BorderRadius.circular(4),
                              border: pw.Border.all(
                                color: PdfColors.red200,
                                width: 0.5,
                              ),
                            ),
                            child: pw.Text(
                              'Prueba Rúbrica: $prueba',
                              style: pw.TextStyle(
                                fontSize: 8.5,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.red800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );

    return await documento.save();
  }

  // GENERA EL DOCUMENTO PDF INDIVIDUAL PARA UN SOLO PRODUCTO ESPECIFICO
  static Future<List<int>> generarPdfIndividual({
    required Producto producto,
    required String porcion,
    required String casoPrueba,
  }) async {
    final documento = pw.Document();

    documento.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // ENCABEZADO OFICIAL CON AUTOR Y FECHA ACTUAL
              _construirEncabezadoOficial(
                subtituloDocumento: 'REPORTE Y MARCADOR INDIVIDUAL',
              ),
              pw.SizedBox(height: 22),

              // NOMBRE DEL PRODUCTO
              pw.Text(
                producto.nombre,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal900,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Categoría: ${producto.categoria} | Porción: $porcion',
                style: const pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 20),

              // MARCADOR DE CODIGO DE BARRAS DE GRAN TAMANO Y ALTA DEFINICION
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 1.5),
                  borderRadius: pw.BorderRadius.circular(12),
                  color: PdfColors.white,
                ),
                child: pw.Column(
                  children: [
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.ean13(),
                      data: producto.codigoBarras,
                      width: 250,
                      height: 110,
                      drawText: true,
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'CÓDIGO EAN-13: ${producto.codigoBarras}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // TABLA DE NUTRIENTES
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'INFORMACIÓN NUTRICIONAL DEL EMPAQUE',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal900,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Calorías por porción:',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                        pw.Text(
                          '${producto.calorias} kcal',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Divider(color: PdfColors.grey300),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Azúcares totales:',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                        pw.Text(
                          '${producto.azucares} g',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Divider(color: PdfColors.grey300),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Sodio:',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                        pw.Text(
                          '${producto.sodio} mg',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // SELLOS FRONTALES DE ADVERTENCIA
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.red50,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: PdfColors.red300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SELLOS FRONTALES DE ADVERTENCIA (LEY COLOMBIANA):',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      producto.sellos.isNotEmpty
                          ? producto.sellos.join('  •  ')
                          : 'SIN SELLOS DE ADVERTENCIA',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red800,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // PRUEBA CLINICA DE LA RUBRICA
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.teal50,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: PdfColors.teal300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'EVALUACIÓN Y CASO DE PRUEBA CLÍNICA EN NUTRISCAN EXPRESS:',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      casoPrueba,
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return await documento.save();
  }

  // GENERA UN REPORTE NUTRICIONAL COMPLETO EN PDF A PARTIR DEL DIAGNOSTICO DE UN PRODUCTO
  static Future<List<int>> generarPdfReporteEvaluacion({
    required Producto producto,
    required PerfilUsuario perfil,
    required ResultadoEvaluacion evaluacion,
  }) async {
    final documento = pw.Document();

    // SELECCIONA EL COLOR INSTITUCIONAL SEGUN EL SEMAFORO NUTRICIONAL
    PdfColor colorVeredicto = PdfColors.green800;
    PdfColor fondoVeredicto = PdfColors.green50;
    if (evaluacion.veredicto == VeredictoSemaforo.rojoNoRecomendado) {
      colorVeredicto = PdfColors.red800;
      fondoVeredicto = PdfColors.red50;
    } else if (evaluacion.veredicto == VeredictoSemaforo.amarilloModeracion) {
      colorVeredicto = PdfColors.orange800;
      fondoVeredicto = PdfColors.orange50;
    }

    // RESUMEN DE LAS CONDICIONES DEL PERFIL MEDICO EVALUADO
    final List<String> condicionesActivas = [];
    if (perfil.tieneDiabetes) condicionesActivas.add('Diabetes Mellitus');
    if (perfil.tieneHipertension) condicionesActivas.add('Hipertensión Arterial');
    if (perfil.tieneCeliaquia) condicionesActivas.add('Celiaquía (Sin Gluten)');
    if (perfil.alergiaLactosa) condicionesActivas.add('Intolerancia a la Lactosa');

    final String textoPerfil = condicionesActivas.isEmpty
        ? 'Sin patologías ni restricciones activas registradas'
        : condicionesActivas.join(' | ');

    documento.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ENCABEZADO OFICIAL EXIGIDO CON AUTOR Y FECHA ACTUAL
              _construirEncabezadoOficial(
                subtituloDocumento: 'DIAGNÓSTICO CLÍNICO PERSONALIZADO',
              ),
              pw.SizedBox(height: 18),

              // TARJETA DEL VEREDICTO DEL SEMAFORO NUTRICIONAL
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: fondoVeredicto,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: colorVeredicto, width: 1.5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'VEREDICTO NUTRICIONAL: ${evaluacion.titulo}',
                      style: pw.TextStyle(
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                        color: colorVeredicto,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      evaluacion.justificacion,
                      style: const pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.grey900,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // DATOS DEL ALIMENTO EVALUADO
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'DATOS DEL PRODUCTO ANALIZADO',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal900,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Producto: ${producto.nombre}',
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Categoría: ${producto.categoria}   |   Código de barras: ${producto.codigoBarras}',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey800,
                      ),
                    ),
                    pw.Divider(color: PdfColors.grey300),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        pw.Text(
                          'Calorías: ${producto.calorias} kcal',
                          style: pw.TextStyle(
                            fontSize: 10.5,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Azúcares: ${producto.azucares} g',
                          style: pw.TextStyle(
                            fontSize: 10.5,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Sodio: ${producto.sodio} mg',
                          style: pw.TextStyle(
                            fontSize: 10.5,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // PERFIL MEDICO Y ADVERTENCIAS ESPECIFICAS
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PERFIL MÉDICO EVALUADO:',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      textoPerfil,
                      style: const pw.TextStyle(fontSize: 10.5),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'HALLAZGOS CLÍNICOS Y ADVERTENCIAS:',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    if (evaluacion.advertencias.isNotEmpty)
                      ...evaluacion.advertencias.map(
                        (adv) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 4),
                          child: pw.Text(
                            '• $adv',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ),
                      )
                    else
                      pw.Text(
                        '• Alimento compatible sin restricciones detectadas para el perfil activo.',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.green900,
                        ),
                      ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // SELLOS DE ADVERTENCIA
              if (producto.sellos.isNotEmpty)
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.red50,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.red300),
                  ),
                  child: pw.Text(
                    'Sellos Frontales Detectados: ${producto.sellos.join("  •  ")}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red900,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );

    return await documento.save();
  }

  // GUARDA EL ARCHIVO PDF EN EL DIRECTORIO DE DOCUMENTOS DE LA APP Y ABRE EL SELECTOR NATIVO DE ANDROID 11/12/13 (API 33)
  static Future<void> descargarYCompartirPdf({
    required BuildContext context,
    required List<int> bytesPdf,
    required String nombreArchivo,
    required String tituloNotificacion,
  }) async {
    try {
      // 1. OBTIENE EL DIRECTORIO SEGURO DE DOCUMENTOS DE LA APLICACION MEDIANTE PATH_PROVIDER
      // ESTE DIRECTORIO NO REQUIERE PERMISOS DE ALMACENAMIENTO ANTIGUOS Y NUNCA FALLA EN ANDROID 11, 12 Y 13 (API 33)
      final Directory directorioDocumentosApp =
          await getApplicationDocumentsDirectory();
      final String rutaSeguraApp =
          '${directorioDocumentosApp.path}/$nombreArchivo';
      final File archivoSeguro = File(rutaSeguraApp);
      await archivoSeguro.writeAsBytes(bytesPdf, flush: true);

      // 2. INTENTA GUARDAR UNA COPIA ADICIONAL EN LA CARPETA PUBLICA DE DESCARGAS DE FORMA SILENCIOSA
      // SI ANDROID 11/12/13 BLOQUEA EL ACCESO DIRECTO POR SCOPED STORAGE, CONTINUA SIN LANZAR ERROR
      if (Platform.isAndroid) {
        try {
          final Directory dirDescargasPublico =
              Directory('/storage/emulated/0/Download');
          if (await dirDescargasPublico.exists()) {
            final File archivoDescargas =
                File('${dirDescargasPublico.path}/$nombreArchivo');
            await archivoDescargas.writeAsBytes(bytesPdf, flush: true);
          }
        } catch (_) {
          // IGNORA EL BLOQUEO DE PERMISOS DE ESCRITURA DIRECTA EN ANDROID 11+ (REDMI / MIUI)
          // YA QUE EL ARCHIVO ESTA GUARDADO EN DOCUMENTOS DE LA APP Y SE ABRIRA EL SELECTOR NATIVO
        }
      }

      // 3. MUESTRA NOTIFICACION FLOTANTE DE CONFIRMACION AL USUARIO
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.download_done_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$tituloNotificacion: $nombreArchivo',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // 4. ABRE AUTOMATICAMENTE EL SELECTOR NATIVO DE ANDROID MEDIANTE PRINTING.SHAREPDF
      // PERMITE "GUARDAR EN DESCARGAS", "ABRIR CON LECTOR PDF", O COMPARTIR POR WHATSAPP / GOOGLE DRIVE
      await Printing.sharePdf(
        bytes: Uint8List.fromList(bytesPdf),
        filename: nombreArchivo,
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Error al generar o guardar el PDF: $error'),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }
}
