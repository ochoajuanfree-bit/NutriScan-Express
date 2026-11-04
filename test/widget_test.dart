// ARCHIVO: TEST/WIDGET_TEST.DART

import 'package:flutter_test/flutter_test.dart';
import 'package:nutriscan_express/modelos/perfil_usuario.dart';
import 'package:nutriscan_express/modelos/producto.dart';
import 'package:nutriscan_express/logica/motor_reglas.dart';

// PRUEBAS UNITARIAS DE LAS REGLAS DE SALUD Y SEMAFORO NUTRICIONAL
void main() {
  group('Pruebas del Motor de Reglas Nutricionales', () {
    // CASO 1: EVALUACION PARA PERSONAS CON DIABETES FRENTE A PRODUCTO AZUCARADO
    test('Deteccion de riesgo de azucar en gaseosa para paciente con diabetes', () {
      final perfil = PerfilUsuario(tieneDiabetes: true);
      final gaseosa = Producto(
        codigoBarras: '7702010023456',
        nombre: 'Gaseosa Cola 400ml',
        categoria: 'Bebidas azucaradas',
        calorias: 180.0,
        azucares: 45.0,
        sodio: 35.0,
        sellos: ['EXCESO EN AZÚCARES', 'CONTIENE EDULCORANTES'],
        formatoGuia: 'barra',
      );

      final evaluacion = MotorReglas.evaluar(gaseosa, perfil);

      // VERIFICA QUE EMITA EL VEREDICTO ROJO NO RECOMENDADO
      expect(evaluacion.veredicto, VeredictoSemaforo.rojoNoRecomendado);
      expect(evaluacion.titulo.contains('NO RECOMENDADO'), isTrue);
    });

    // CASO 2: EVALUACION PARA PERSONAS CON HIPERTENSION FRENTE A PRODUCTO CON ALTO SODIO
    test('Deteccion de exceso de sodio en papas fritas para paciente hipertenso', () {
      final perfil = PerfilUsuario(tieneHipertension: true);
      final papas = Producto(
        codigoBarras: '7702001012345',
        nombre: 'Papas Fritas Clásicas 105g',
        categoria: 'Snacks',
        calorias: 540.0,
        azucares: 1.5,
        sodio: 480.0,
        sellos: ['EXCESO EN SODIO', 'EXCESO EN GRASAS SATURADAS'],
        formatoGuia: 'barra',
      );

      final evaluacion = MotorReglas.evaluar(papas, perfil);

      // VERIFICA QUE SE RESTRINJA POR RIESGO DE SODIO CRITICO
      expect(evaluacion.veredicto, VeredictoSemaforo.rojoNoRecomendado);
    });

    // CASO 3: EVALUACION PARA PERSONAS CON CELIAQUIA FRENTE A GALLETAS
    test('Deteccion de gluten en galletas de chocolate para paciente con celiaquia', () {
      final perfil = PerfilUsuario(tieneCeliaquia: true);
      final galletas = Producto(
        codigoBarras: '7702020034567',
        nombre: 'Galletas Rellenas de Chocolate 120g',
        categoria: 'Galletas y Dulces',
        calorias: 490.0,
        azucares: 38.0,
        sodio: 220.0,
        sellos: ['EXCESO EN AZÚCARES', 'EXCESO EN GRASAS SATURADAS'],
        formatoGuia: 'galleta',
      );

      final evaluacion = MotorReglas.evaluar(galletas, perfil);

      // VERIFICA QUE RECONOZCA EL RIESGO DE HARINAS Y GLUTEN
      expect(evaluacion.veredicto, VeredictoSemaforo.rojoNoRecomendado);
    });

    // CASO 4: EVALUACION PARA PERSONA SANA
    test('Evaluacion general para usuario sin condiciones medicas preexistentes', () {
      final perfil = PerfilUsuario();
      final aguaOAlimentoSaludable = Producto(
        codigoBarras: '7700000000001',
        nombre: 'Agua Mineral Natural 500ml',
        categoria: 'Bebidas',
        calorias: 0.0,
        azucares: 0.0,
        sodio: 5.0,
        sellos: [],
        formatoGuia: 'barra',
      );

      final evaluacion = MotorReglas.evaluar(aguaOAlimentoSaludable, perfil);

      // VERIFICA EL VEREDICTO VERDE RECOMENDADO
      expect(evaluacion.veredicto, VeredictoSemaforo.verdeRecomendado);
      expect(evaluacion.titulo.contains('RECOMENDADO'), isTrue);
    });
  });
}
