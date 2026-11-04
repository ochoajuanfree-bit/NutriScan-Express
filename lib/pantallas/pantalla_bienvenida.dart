// ARCHIVO: LIB/PANTALLAS/PANTALLA_BIENVENIDA.DART

import 'dart:async';
import 'package:flutter/material.dart';
import '../datos/base_datos_sqlite.dart';
import '../main.dart';

/// PANTALLA SPLASH DE BIENVENIDA CON LOGO OFICIAL, ANIMACION Y CREDITOS DEL AUTOR
class PantallaBienvenida extends StatefulWidget {
  const PantallaBienvenida({super.key});

  @override
  State<PantallaBienvenida> createState() => _EstadoPantallaBienvenida();
}

class _EstadoPantallaBienvenida extends State<PantallaBienvenida>
    with SingleTickerProviderStateMixin {
  // CONTROLADOR DE ANIMACION PARA ENTRADA SUAVE DEL SPLASH SCREEN
  late AnimationController _controladorAnimacion;
  late Animation<double> _animacionOpacidad;
  late Animation<double> _animacionEscala;

  @override
  void initState() {
    super.initState();

    // CONFIGURACION DE LAS ANIMACIONES VISUALES DE ENTRADA
    _controladorAnimacion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _animacionOpacidad = CurvedAnimation(
      parent: _controladorAnimacion,
      curve: Curves.easeIn,
    );

    _animacionEscala = CurvedAnimation(
      parent: _controladorAnimacion,
      curve: Curves.easeOutBack,
    );

    _controladorAnimacion.forward();

    // INICIALIZACION ASINCRONA Y TEMPORIZADOR DE BIENVENIDA (2.8 SEGUNDOS)
    _ejecutarCargaInicial();
  }

  // INICIA LA BASE DE DATOS Y REDIRIGE CON TRANSICION FLUIDA A LA PANTALLA PRINCIPAL
  Future<void> _ejecutarCargaInicial() async {
    // PRECALENTAMIENTO DE LA BASE DE DATOS SQLITE LOCAL
    await BaseDatosSqlite.instancia.baseDatos;

    // ESPERA DE 2.8 SEGUNDOS PARA MOSTRAR EL LOGO Y LOS CREDITOS DEL AUTOR
    await Future.delayed(const Duration(milliseconds: 2800));

    if (!mounted) return;

    // NAVEGACION FLUIDA HACIA LA PANTALLA PRINCIPAL CON TRANSICION FADE
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animacion, animacionSecundaria) =>
            const PantallaPrincipal(),
        transitionsBuilder: (context, animacion, animacionSecundaria, hijo) {
          return FadeTransition(
            opacity: animacion,
            child: hijo,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controladorAnimacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // DEGRADADO INSTITUCIONAL EN TONOS VERDE AZULADO Y ESMERALDA
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00382F),
              Color(0xFF004D40),
              Color(0xFF00796B),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
              child: FadeTransition(
                opacity: _animacionOpacidad,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // LOGO CENTRAL DE LA APLICACION CON BORDES REDONDEADOS Y SOMBRA SUAVE
                    ScaleTransition(
                      scale: _animacionEscala,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.tealAccent.withValues(alpha: 0.65),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 24,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.tealAccent.withValues(alpha: 0.22),
                              blurRadius: 28,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(29.5),
                          child: Image.asset(
                            'assets/icono/icono_app.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // ICONO DE RESPALDO EN CASO DE QUE EL RECURSO NO CARGUE
                              return Container(
                                color: const Color(0xFF004D40),
                                child: const Icon(
                                  Icons.health_and_safety_rounded,
                                  size: 80,
                                  color: Colors.tealAccent,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // TITULO PRINCIPAL DE LA APLICACION
                    const Text(
                      'NutriScan Express',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // SUBTITULO DESCRIPTIVO DEL SISTEMA
                    const Text(
                      'Evaluación Nutricional Inteligente en Tiempo Real',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFE0F2F1),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const Spacer(),

                    // INDICADOR DE CARGA CIRCULAR ESTILIZADO
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // TARJETA INFERIOR CON EL CREDITO DEL AUTOR Y SUBTITULO DEL PROYECTO FINAL
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                          width: 1,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'Desarrollado por: Juan David Ochoa',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Proyecto Final - Asistente Nutricional',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.tealAccent,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
