// ARCHIVO: LIB/PANTALLAS/PANTALLA_HISTORIAL.DART

import 'package:flutter/material.dart';
import '../datos/base_datos_sqlite.dart';
import '../datos/servicio_alimentos.dart';
import '../modelos/registro_historial.dart';
import 'pantalla_resultado.dart';

/// PANTALLA QUE PRESENTA EL HISTORIAL DINAMICO DE ALIMENTOS ESCANEADOS
class PantallaHistorial extends StatefulWidget {
  const PantallaHistorial({super.key});

  @override
  State<PantallaHistorial> createState() => _EstadoPantallaHistorial();
}

class _EstadoPantallaHistorial extends State<PantallaHistorial> {
  // LISTA LOCAL DE REGISTROS DE HISTORIAL
  List<RegistroHistorial> _listaHistorial = [];
  bool _estaCargando = true;

  @override
  void initState() {
    super.initState();
    _cargarRegistrosHistorial();
  }

  // RECUPERA LOS REGISTROS DESDE LA TABLA 'historial_escaneos' DE SQLITE
  Future<void> _cargarRegistrosHistorial() async {
    setState(() {
      _estaCargando = true;
    });

    final registros = await BaseDatosSqlite.instancia.obtenerHistorial();

    if (mounted) {
      setState(() {
        _listaHistorial = registros;
        _estaCargando = false;
      });
    }
  }

  // DIALOGO DE CONFIRMACION Y VACIADO DEL HISTORIAL EN SQLITE
  Future<void> _confirmarVaciarHistorial() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaciar Historial'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar todos los escaneos registrados?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('VACIAR'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await BaseDatosSqlite.instancia.limpiarHistorial();
      await _cargarRegistrosHistorial();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Historial de escaneos vaciado con éxito.'),
            backgroundColor: Color(0xFF00796B),
          ),
        );
      }
    }
  }

  // IDENTIFICA EL COLOR DE SEMAFORO ADECUADO SEGUN EL TEXTO DEL VEREDICTO
  Color _obtenerColorPorVeredicto(String veredicto) {
    final texto = veredicto.toUpperCase();
    if (texto.contains('NO RECOMENDADO')) {
      return const Color(0xFFC62828); // ROJO
    } else if (texto.contains('MODERAC')) {
      return const Color(0xFFF57F17); // AMBAR
    } else {
      return const Color(0xFF2E7D32); // VERDE
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Historial de Escaneos'),
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          // BOTON PARA LIMPIAR HISTORIAL SI EXISTEN ELEMENTOS
          if (_listaHistorial.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'Vaciar Historial',
              onPressed: _confirmarVaciarHistorial,
            ),
        ],
      ),
      body: _estaCargando
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00796B)),
              ),
            )
          : _listaHistorial.isEmpty
              // VISTA LIMPIA DE ESTADO INICIAL VACIO
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE0F2F1),
                            border: Border.all(
                              color: const Color(0xFF80CBC4),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.history_toggle_off_rounded,
                            size: 72,
                            color: Color(0xFF00796B),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Historial Vacío',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF263238),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Historial vacío. Escanea tu primer alimento físico o desde pantalla con la cámara para registrarlo aquí.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF546E7A),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              // LISTA DINAMICA DE TARJETAS DE ESCANEOS REGISTRADOS
              : RefreshIndicator(
                  onRefresh: _cargarRegistrosHistorial,
                  color: const Color(0xFF00796B),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    itemCount: _listaHistorial.length,
                    itemBuilder: (context, indice) {
                      final registro = _listaHistorial[indice];
                      final colorSemaforo =
                          _obtenerColorPorVeredicto(registro.veredicto);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            // ABRE EL DETALLE NUTRICIONAL Y VEREDICTO COMPLETO DEL PRODUCTO
                            try {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF00796B)),
                                  ),
                                ),
                              );

                              final producto = await ServicioAlimentos
                                  .obtenerAlimentoUniversal(
                                      registro.codigoBarras);
                              final perfil = await BaseDatosSqlite.instancia
                                  .obtenerPerfil();

                              if (context.mounted) {
                                Navigator.pop(context); // CIERRA EL CARGADOR
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
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ICONO DEL ALIMENTO
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: colorSemaforo
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.fastfood_rounded,
                                        color: colorSemaforo,
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // NOMBRE Y CODIGO DE BARRAS
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            registro.nombre,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF212121),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.qr_code_2_rounded,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                registro.codigoBarras,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: Color(0xFFB0BEC5),
                                    ),
                                  ],
                                ),
                                const Divider(height: 22),

                                // PIE DE LA TARJETA: VEREDICTO Y FECHA
                                Row(
                                  children: [
                                    // CHIP VISUAL DEL VEREDICTO EXPANDIDO PARA PREVENIR DESBORDAMIENTOS
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: colorSemaforo
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: colorSemaforo
                                                .withValues(alpha: 0.5),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          registro.veredicto,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: colorSemaforo,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // FECHA Y HORA DEL ESCANEO CON TAMANO MINIMO
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.access_time_rounded,
                                          size: 13,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          registro.fecha,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
