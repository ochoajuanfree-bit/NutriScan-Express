// ARCHIVO: LIB/LOGICA/MOTOR_REGLAS.DART

import '../modelos/producto.dart';
import '../modelos/perfil_usuario.dart';

// ENUMERACION QUE DEFINE LOS TRES ESTADOS DEL SEMAFORO NUTRICIONAL
enum VeredictoSemaforo {
  verdeRecomendado,
  amarilloModeracion,
  rojoNoRecomendado,
}

// CLASE QUE ENCAPSULA EL RESULTADO DE LA EVALUACION NUTRICIONAL
class ResultadoEvaluacion {
  // CLASIFICACION DEL SEMAFORO
  final VeredictoSemaforo veredicto;

  // TITULO DESCRIPTIVO CON ICONO DE COLOR
  final String titulo;

  // EXPLICACION MEDICA Y JUSTIFICACION DEL VEREDICTO
  final String justificacion;

  // LISTA DE ADVERTENCIAS Y ALERTAS ESPECIFICAS DETECTADAS
  final List<String> advertencias;

  // CONSTRUCTOR DEL RESULTADO
  ResultadoEvaluacion({
    required this.veredicto,
    required this.titulo,
    required this.justificacion,
    required this.advertencias,
  });
}

// MOTOR DE INFERENCIA Y EVALUACION DE REGLAS DE SALUD
class MotorReglas {
  // CRUZA EL PERFIL DEL USUARIO CON LA TABLA NUTRICIONAL DEL PRODUCTO
  static ResultadoEvaluacion evaluar(Producto producto, PerfilUsuario perfil) {
    final List<String> alertas = [];
    bool esPeligroCritico = false;

    // REGLA 1: CONTROL DE AZUCARES EN DIABETES
    if (perfil.tieneDiabetes) {
      final bool tieneSelloAzucar = producto.sellos.any((s) =>
          s.toUpperCase().contains('AZÚCAR') ||
          s.toUpperCase().contains('AZUCAR'));

      if (producto.azucares >= 20.0 || (tieneSelloAzucar && producto.azucares >= 10.0)) {
        alertas.add(
          'Contiene ${producto.azucares}g de azúcar por porción, representando un riesgo crítico para diabetes mellitus.',
        );
        esPeligroCritico = true;
      } else if (producto.azucares > 5.0 || tieneSelloAzucar) {
        alertas.add(
          'Contiene ${producto.azucares}g de azúcar, superando el límite diario recomendado para pacientes diabéticos.',
        );
      }
    }

    // REGLA 2: CONTROL DE SODIO EN HIPERTENSION ARTERIAL
    if (perfil.tieneHipertension) {
      final bool tieneSelloSodio =
          producto.sellos.any((s) => s.toUpperCase().contains('SODIO'));

      if (producto.sodio >= 300.0 || (tieneSelloSodio && producto.sodio >= 100.0)) {
        alertas.add(
          'Contiene ${producto.sodio}mg de sodio con sello oficial de exceso, representando un riesgo crítico para hipertensión arterial.',
        );
        esPeligroCritico = true;
      } else if (producto.sodio > 100.0 || tieneSelloSodio) {
        alertas.add(
          'Contiene ${producto.sodio}mg de sodio, cantidad alta que requiere monitoreo y moderación en hipertensión.',
        );
      }
    }

    // REGLA 3: CONTROL DE GLUTEN EN CELIAQUIA
    if (perfil.tieneCeliaquia) {
      final nombreMin = producto.nombre.toLowerCase();
      final categoriaMin = producto.categoria.toLowerCase();
      if (nombreMin.contains('galleta') ||
          categoriaMin.contains('galleta') ||
          nombreMin.contains('trigo') ||
          categoriaMin.contains('panaderia')) {
        alertas.add(
          'Elaborado con harinas o cereales con gluten, no apto para personas con celiaquía.',
        );
        esPeligroCritico = true;
      }
    }

    // REGLA 4: CONTROL DE LACTOSA
    if (perfil.alergiaLactosa) {
      final nombreMin = producto.nombre.toLowerCase();
      final categoriaMin = producto.categoria.toLowerCase();
      if (nombreMin.contains('chocolate') ||
          nombreMin.contains('leche') ||
          categoriaMin.contains('lacteo') ||
          nombreMin.contains('rellena')) {
        alertas.add(
          'Contiene derivados de leche o trazas lácteas no toleradas en alergia o intolerancia a la lactosa.',
        );
        esPeligroCritico = true;
      }
    }

    // REGLA 5: EVALUACION DE SELLOS FRONTALES DE ADVERTENCIA
    if (producto.sellos.isNotEmpty) {
      alertas.add(
        'Sellos oficiales de advertencia: ${producto.sellos.join(", ")}.',
      );
    }

    // DETERMINACION DEL VEREDICTO FINAL BASADO EN RIESGOS
    if (esPeligroCritico || alertas.length >= 2) {
      return ResultadoEvaluacion(
        veredicto: VeredictoSemaforo.rojoNoRecomendado,
        titulo: '🔴 NO RECOMENDADO',
        justificacion:
            'Este alimento representa un riesgo significativo para tu condición de salud actual.',
        advertencias: alertas,
      );
    } else if (alertas.isNotEmpty) {
      return ResultadoEvaluacion(
        veredicto: VeredictoSemaforo.amarilloModeracion,
        titulo: '🟡 CONSUMIR CON MODERACIÓN',
        justificacion:
            'El producto presenta nutrientes o ingredientes que debes vigilar con atención.',
        advertencias: alertas,
      );
    } else {
      return ResultadoEvaluacion(
        veredicto: VeredictoSemaforo.verdeRecomendado,
        titulo: '🟢 RECOMENDADO',
        justificacion:
            'Alimento compatible y seguro respecto a tus condiciones de salud registradas.',
        advertencias: [
          'No se detectaron contraindicaciones críticas en su composición.',
        ],
      );
    }
  }
}