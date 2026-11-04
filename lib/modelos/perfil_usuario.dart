// ARCHIVO: LIB/MODELOS/PERFIL_USUARIO.DART

/// MODELO DE DATOS QUE REPRESENTA EL PERFIL DE SALUD Y RESTRICCIONES MEDICAS DEL USUARIO
class PerfilUsuario {
  // IDENTIFICADOR UNICO DEL REGISTRO EN LA BASE DE DATOS LOCAL
  final int id;

  // CONDICION MEDICA: DIABETES (REQUIERE CONTROL ESTRICTO DE AZUCARES)
  bool tieneDiabetes;

  // CONDICION MEDICA: HIPERTENSION (REQUIERE CONTROL ESTRICTO DE SODIO Y SALES)
  bool tieneHipertension;

  // CONDICION MEDICA: CELIAQUIA (INTOLERANCIA AL GLUTEN Y DERIVADOS DE TRIGO)
  bool tieneCeliaquia;

  // CONDICION MEDICA: ALERGIA O INTOLERANCIA A LA LACTOSA
  bool alergiaLactosa;

  // CONSTRUCTOR CON VALORES POR DEFECTO
  PerfilUsuario({
    this.id = 1,
    this.tieneDiabetes = false,
    this.tieneHipertension = false,
    this.tieneCeliaquia = false,
    this.alergiaLactosa = false,
  });

  // CONVIERTE EL OBJETO EN UN MAPA COMPATIBLE CON SQLITE
  Map<String, dynamic> aMapa() {
    return {
      'id': id,
      'tieneDiabetes': tieneDiabetes ? 1 : 0,
      'tieneHipertension': tieneHipertension ? 1 : 0,
      'tieneCeliaquia': tieneCeliaquia ? 1 : 0,
      'alergiaLactosa': alergiaLactosa ? 1 : 0,
    };
  }

  // CONSTRUYE UNA INSTANCIA DE PERFIL A PARTIR DE UN REGISTRO DE SQLITE
  factory PerfilUsuario.desdeMapa(Map<String, dynamic> mapa) {
    return PerfilUsuario(
      id: mapa['id'] as int? ?? 1,
      tieneDiabetes: (mapa['tieneDiabetes'] is bool)
          ? mapa['tieneDiabetes'] as bool
          : (mapa['tieneDiabetes'] == 1),
      tieneHipertension: (mapa['tieneHipertension'] is bool)
          ? mapa['tieneHipertension'] as bool
          : (mapa['tieneHipertension'] == 1),
      tieneCeliaquia: (mapa['tieneCeliaquia'] is bool)
          ? mapa['tieneCeliaquia'] as bool
          : (mapa['tieneCeliaquia'] == 1),
      alergiaLactosa: (mapa['alergiaLactosa'] is bool)
          ? mapa['alergiaLactosa'] as bool
          : (mapa['alergiaLactosa'] == 1),
    );
  }

  // COPIA DEL OBJETO PERMITIENDO MODIFICAR CAMPOS ESPECIFICOS
  PerfilUsuario copiarCon({
    int? id,
    bool? tieneDiabetes,
    bool? tieneHipertension,
    bool? tieneCeliaquia,
    bool? alergiaLactosa,
  }) {
    return PerfilUsuario(
      id: id ?? this.id,
      tieneDiabetes: tieneDiabetes ?? this.tieneDiabetes,
      tieneHipertension: tieneHipertension ?? this.tieneHipertension,
      tieneCeliaquia: tieneCeliaquia ?? this.tieneCeliaquia,
      alergiaLactosa: alergiaLactosa ?? this.alergiaLactosa,
    );
  }
}