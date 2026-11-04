// ARCHIVO: LIB/MODELOS/PRODUCTO.DART

/// MODELO DE DATOS QUE REPRESENTA UN ALIMENTO REGISTRADO EN EL CATALOGO LOCAL
class Producto {
  // CODIGO DE BARRAS UNICO (IDENTIFICADOR PRINCIPAL DEL PRODUCTO)
  final String codigoBarras;

  // NOMBRE COMERCIAL COMPLETO DEL ALIMENTO
  final String nombre;

  // CATEGORIA DEL ALIMENTO (SNACKS, GALLETAS, BEBIDAS, ETC.)
  final String categoria;

  // VALOR ENERGETICO EN KILOCALORIAS (KCAL)
  final double calorias;

  // CANTIDAD DE AZUCARES TOTALES EN GRAMOS (G)
  final double azucares;

  // CONTENIDO TOTAL DE SODIO EN MILIGRAMOS (MG)
  final double sodio;

  // LISTADO DE SELLOS FRONTALES DE ADVERTENCIA NUTRICIONAL
  final List<String> sellos;

  // FORMATO DE SILUETA GUIA RECOMENDADA PARA EL ESCANEO ('barra' O 'galleta')
  final String formatoGuia;

  // CONSTRUCTOR DEL MODELO PRODUCTO
  Producto({
    required this.codigoBarras,
    required this.nombre,
    required this.categoria,
    required this.calorias,
    required this.azucares,
    required this.sodio,
    required this.sellos,
    this.formatoGuia = 'barra',
  });

  // CONVIERTE EL OBJETO PRODUCTO A UN MAPA PARA ALMACENAR EN SQLITE
  Map<String, dynamic> aMapa() {
    return {
      'codigoBarras': codigoBarras,
      'nombre': nombre,
      'categoria': categoria,
      'calorias': calorias,
      'azucares': azucares,
      'sodio': sodio,
      'sellos': sellos.join(', '),
      'formatoGuia': formatoGuia,
    };
  }

  // RECONSTRUYE UNA INSTANCIA DE PRODUCTO A PARTIR DE UN REGISTRO DE SQLITE
  factory Producto.desdeMapa(Map<String, dynamic> mapa) {
    List<String> sellosLista = [];
    if (mapa['sellos'] != null) {
      final cadenaSellos = mapa['sellos'].toString();
      if (cadenaSellos.trim().isNotEmpty) {
        sellosLista = cadenaSellos
            .split(',')
            .map((sello) => sello.trim())
            .where((sello) => sello.isNotEmpty)
            .toList();
      }
    }

    return Producto(
      codigoBarras: mapa['codigoBarras']?.toString() ?? '',
      nombre: mapa['nombre']?.toString() ?? '',
      categoria: mapa['categoria']?.toString() ?? '',
      calorias: (mapa['calorias'] as num?)?.toDouble() ?? 0.0,
      azucares: (mapa['azucares'] as num?)?.toDouble() ?? 0.0,
      sodio: (mapa['sodio'] as num?)?.toDouble() ?? 0.0,
      sellos: sellosLista,
      formatoGuia: mapa['formatoGuia']?.toString() ?? 'barra',
    );
  }
}