// ARCHIVO: LIB/MODELOS/REGISTRO_HISTORIAL.DART

/// MODELO DE DATOS QUE REPRESENTA UN ESCANEO GUARDADO EN EL HISTORIAL
class RegistroHistorial {
  // IDENTIFICADOR AUTOINCREMENTAL DEL REGISTRO
  final int? id;

  // CODIGO DE BARRAS DEL PRODUCTO ESCANEADO
  final String codigoBarras;

  // NOMBRE DEL PRODUCTO ALIMENTICIO
  final String nombre;

  // VEREDICTO FINAL GENERADO POR EL SEMAFORO NUTRICIONAL
  final String veredicto;

  // FECHA Y HORA EN QUE SE REALIZO EL ESCANEO
  final String fecha;

  // CONSTRUCTOR DEL REGISTRO
  RegistroHistorial({
    this.id,
    required this.codigoBarras,
    required this.nombre,
    required this.veredicto,
    required this.fecha,
  });

  // CONVIERTE EL REGISTRO A UN FORMATO DE MAPA PARA SQLITE
  Map<String, dynamic> aMapa() {
    return {
      if (id != null) 'id': id,
      'codigoBarras': codigoBarras,
      'nombre': nombre,
      'veredicto': veredicto,
      'fecha': fecha,
    };
  }

  // RECONSTRUYE UN REGISTRO DE HISTORIAL DESDE LA BASE DE DATOS
  factory RegistroHistorial.desdeMapa(Map<String, dynamic> mapa) {
    return RegistroHistorial(
      id: mapa['id'] as int?,
      codigoBarras: mapa['codigoBarras']?.toString() ?? '',
      nombre: mapa['nombre']?.toString() ?? '',
      veredicto: mapa['veredicto']?.toString() ?? '',
      fecha: mapa['fecha']?.toString() ?? '',
    );
  }
}
