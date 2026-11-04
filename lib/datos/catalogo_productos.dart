// ARCHIVO: LIB/DATOS/CATALOGO_PRODUCTOS.DART

import '../modelos/producto.dart';

/// CATALOGO DE REFERENCIA CON LOS ALIMENTOS MINIMOS Y REALES DEL PROYECTO
class CatalogoProductos {
  // LISTA ESTATICA DE PRODUCTOS DE PRUEBA OFFLINE
  static final List<Producto> lista = [
    // =========================================================================
    // CATEGORIA 1: PAPAS FRITAS Y SNACKS CRUJIENTES (ALTO SODIO / GRASAS)
    // =========================================================================
    Producto(
      codigoBarras: '7702189000019',
      nombre: 'Papas Margarita Natural 25g',
      categoria: 'Snacks',
      calorias: 135.0,
      azucares: 0.0,
      sodio: 125.0,
      sellos: ['EXCESO EN SODIO', 'EXCESO EN GRASAS SATURADAS'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '7702189000064',
      nombre: 'Papas Margarita Natural 300g',
      categoria: 'Snacks',
      calorias: 540.0,
      azucares: 1.0,
      sodio: 490.0,
      sellos: ['EXCESO EN SODIO', 'EXCESO EN GRASAS SATURADAS'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '7702189010018',
      nombre: 'Papas Margarita Natural 36g',
      categoria: 'Snacks',
      calorias: 195.0,
      azucares: 0.5,
      sodio: 175.0,
      sellos: ['EXCESO EN SODIO', 'EXCESO EN GRASAS SATURADAS'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '7702189000026',
      nombre: 'Papas Margarita Sabor a Pollo 25g',
      categoria: 'Snacks',
      calorias: 135.0,
      azucares: 0.5,
      sodio: 130.0,
      sellos: ['EXCESO EN SODIO', 'EXCESO EN GRASAS SATURADAS'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '7702189010025',
      nombre: 'Papas Margarita Sabor a Pollo 36g',
      categoria: 'Snacks',
      calorias: 195.0,
      azucares: 0.8,
      sodio: 180.0,
      sellos: ['EXCESO EN SODIO', 'EXCESO EN GRASAS SATURADAS'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '7702189000033',
      nombre: 'Papas Margarita Sabor a Limón 25g',
      categoria: 'Snacks',
      calorias: 130.0,
      azucares: 0.0,
      sodio: 135.0,
      sellos: ['EXCESO EN SODIO', 'EXCESO EN GRASAS SATURADAS'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '7702189010032',
      nombre: 'Papas Margarita Sabor a Limón 36g',
      categoria: 'Snacks',
      calorias: 190.0,
      azucares: 0.5,
      sodio: 190.0,
      sellos: ['EXCESO EN SODIO', 'EXCESO EN GRASAS SATURADAS'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '7702189000040',
      nombre: 'Papas Margarita Onduladas Natural 36g',
      categoria: 'Snacks',
      calorias: 195.0,
      azucares: 0.5,
      sodio: 175.0,
      sellos: ['EXCESO EN SODIO', 'EXCESO EN GRASAS SATURADAS'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '7702001012345',
      nombre: 'Papas Fritas Clásicas 105g',
      categoria: 'Snacks',
      calorias: 540.0,
      azucares: 1.5,
      sodio: 480.0,
      sellos: ['EXCESO EN SODIO', 'EXCESO EN GRASAS SATURADAS'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '7702189015013',
      nombre: 'Doritos Mega Queso 42g',
      categoria: 'Snacks',
      calorias: 215.0,
      azucares: 1.2,
      sodio: 240.0,
      sellos: ['EXCESO EN SODIO', 'EXCESO EN GRASAS SATURADAS'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '7702189017017',
      nombre: 'De Todito Snack Mixto Natural 45g',
      categoria: 'Snacks',
      calorias: 238.0,
      azucares: 1.0,
      sodio: 235.0,
      sellos: ['EXCESO EN SODIO', 'EXCESO EN GRASAS SATURADAS'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '7702189016010',
      nombre: 'Cheetos Snacks de Queso 32g',
      categoria: 'Snacks',
      calorias: 165.0,
      azucares: 1.0,
      sodio: 200.0,
      sellos: ['EXCESO EN SODIO', 'EXCESO EN GRASAS SATURADAS'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '7702189014016',
      nombre: 'Choclitos Sabor a Limón 30g',
      categoria: 'Snacks',
      calorias: 150.0,
      azucares: 1.0,
      sodio: 145.0,
      sellos: ['EXCESO EN SODIO', 'EXCESO EN GRASAS SATURADAS'],
      formatoGuia: 'barra',
    ),

    // =========================================================================
    // CATEGORIA 2: BEBIDAS GASEOSAS Y AZUCARADAS (ALTO AZUCAR)
    // =========================================================================
    Producto(
      codigoBarras: '5449000000996',
      nombre: 'Gaseosa Coca-Cola Original 400ml',
      categoria: 'Bebidas azucaradas',
      calorias: 170.0,
      azucares: 42.0,
      sodio: 40.0,
      sellos: ['EXCESO EN AZÚCARES', 'CONTIENE EDULCORANTES'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '7702010023456',
      nombre: 'Gaseosa Cola 400ml',
      categoria: 'Bebidas azucaradas',
      calorias: 170.0,
      azucares: 42.0,
      sodio: 40.0,
      sellos: ['EXCESO EN AZÚCARES', 'CONTIENE EDULCORANTES'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '7501055300075',
      nombre: 'Gaseosa Coca-Cola Original 600ml',
      categoria: 'Bebidas azucaradas',
      calorias: 252.0,
      azucares: 63.0,
      sodio: 60.0,
      sellos: ['EXCESO EN AZÚCARES', 'EXCESO EN CALORÍAS'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '7702010000013',
      nombre: 'Gaseosa Coca-Cola Original 250ml',
      categoria: 'Bebidas azucaradas',
      calorias: 105.0,
      azucares: 26.0,
      sodio: 25.0,
      sellos: ['EXCESO EN AZÚCARES'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '7702010000020',
      nombre: 'Gaseosa Coca-Cola Original 350ml',
      categoria: 'Bebidas azucaradas',
      calorias: 147.0,
      azucares: 37.0,
      sodio: 32.0,
      sellos: ['EXCESO EN AZÚCARES'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '5449000131805',
      nombre: 'Gaseosa Coca-Cola Original 500ml',
      categoria: 'Bebidas azucaradas',
      calorias: 210.0,
      azucares: 53.0,
      sodio: 45.0,
      sellos: ['EXCESO EN AZÚCARES', 'EXCESO EN CALORÍAS'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '7702090000010',
      nombre: 'Gaseosa Colombiana Postobón 400ml',
      categoria: 'Bebidas azucaradas',
      calorias: 180.0,
      azucares: 44.0,
      sodio: 36.0,
      sellos: ['EXCESO EN AZÚCARES', 'CONTIENE EDULCORANTES'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '7702090000119',
      nombre: 'Gaseosa Manzana Postobón 400ml',
      categoria: 'Bebidas azucaradas',
      calorias: 180.0,
      azucares: 44.0,
      sodio: 36.0,
      sellos: ['EXCESO EN AZÚCARES', 'CONTIENE EDULCORANTES'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '7702004000310',
      nombre: 'Bebida de Malta Pony Malta 330ml',
      categoria: 'Bebidas azucaradas',
      calorias: 140.0,
      azucares: 33.0,
      sodio: 30.0,
      sellos: ['EXCESO EN AZÚCARES'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '7702090001017',
      nombre: 'Jugo Hit Mora 500ml',
      categoria: 'Bebidas azucaradas',
      calorias: 130.0,
      azucares: 31.0,
      sodio: 40.0,
      sellos: ['EXCESO EN AZÚCARES'],
      formatoGuia: 'barra',
    ),
    Producto(
      codigoBarras: '7702090001024',
      nombre: 'Jugo Hit Naranja Piña 500ml',
      categoria: 'Bebidas azucaradas',
      calorias: 130.0,
      azucares: 31.0,
      sodio: 40.0,
      sellos: ['EXCESO EN AZÚCARES'],
      formatoGuia: 'barra',
    ),

    // =========================================================================
    // CATEGORIA 3: GALLETAS COMERCIALES Y DULCES (GLUTEN / LACTOSA / AZUCARES)
    // =========================================================================
    Producto(
      codigoBarras: '7702025102032',
      nombre: 'Galletas Festival Chocolate 403g',
      categoria: 'Galletas y Dulces',
      calorias: 260.0,
      azucares: 22.0,
      sodio: 110.0,
      sellos: ['EXCESO EN AZÚCARES', 'EXCESO EN GRASAS SATURADAS'],
      formatoGuia: 'galleta',
    ),
    Producto(
      codigoBarras: '7702025102018',
      nombre: 'Galletas Festival Fresa 403g',
      categoria: 'Galletas y Dulces',
      calorias: 260.0,
      azucares: 22.0,
      sodio: 105.0,
      sellos: ['EXCESO EN AZÚCARES', 'EXCESO EN GRASAS SATURADAS'],
      formatoGuia: 'galleta',
    ),
    Producto(
      codigoBarras: '7702025102025',
      nombre: 'Galletas Festival Vainilla 403g',
      categoria: 'Galletas y Dulces',
      calorias: 260.0,
      azucares: 22.0,
      sodio: 105.0,
      sellos: ['EXCESO EN AZÚCARES', 'EXCESO EN GRASAS SATURADAS'],
      formatoGuia: 'galleta',
    ),
    Producto(
      codigoBarras: '7622210986708',
      nombre: 'Galletas Oreo Clásicas 108g',
      categoria: 'Galletas y Dulces',
      calorias: 210.0,
      azucares: 16.0,
      sodio: 180.0,
      sellos: ['EXCESO EN AZÚCARES', 'EXCESO EN GRASAS SATURADAS'],
      formatoGuia: 'galleta',
    ),
    Producto(
      codigoBarras: '7622300744652',
      nombre: 'Galletas Oreo Original 432g',
      categoria: 'Galletas y Dulces',
      calorias: 210.0,
      azucares: 16.0,
      sodio: 180.0,
      sellos: ['EXCESO EN AZÚCARES', 'EXCESO EN GRASAS SATURADAS'],
      formatoGuia: 'galleta',
    ),
    Producto(
      codigoBarras: '7702020034567',
      nombre: 'Galletas Rellenas de Chocolate 120g',
      categoria: 'Galletas y Dulces',
      calorias: 260.0,
      azucares: 22.0,
      sodio: 110.0,
      sellos: ['EXCESO EN AZÚCARES', 'EXCESO EN GRASAS SATURADAS'],
      formatoGuia: 'galleta',
    ),
    Producto(
      codigoBarras: '7702025101011',
      nombre: 'Galletas Noel Ducales 300g',
      categoria: 'Galletas y Dulces',
      calorias: 130.0,
      azucares: 4.0,
      sodio: 95.0,
      sellos: ['EXCESO EN GRASAS SATURADAS', 'EXCESO EN SODIO'],
      formatoGuia: 'galleta',
    ),
    Producto(
      codigoBarras: '7702025000017',
      nombre: 'Galletas Saltín Noel Tradicional 300g',
      categoria: 'Galletas y Dulces',
      calorias: 110.0,
      azucares: 1.0,
      sodio: 170.0,
      sellos: ['EXCESO EN SODIO'],
      formatoGuia: 'galleta',
    ),
    Producto(
      codigoBarras: '7702004000129',
      nombre: 'Ponqué Ramo Chocoramo 65g',
      categoria: 'Galletas y Dulces',
      calorias: 250.0,
      azucares: 21.0,
      sodio: 140.0,
      sellos: ['EXCESO EN AZÚCARES', 'EXCESO EN GRASAS SATURADAS'],
      formatoGuia: 'galleta',
    ),
  ];

  // METODO PARA BUSCAR UN ALIMENTO POR SU CODIGO DE BARRAS EN MEMORIA
  static Producto? buscarPorCodigo(String codigo) {
    final String codigoLimpio =
        codigo.replaceAll(RegExp(r'[^0-9]'), '').trim();
    final String codigoOriginal = codigo.trim();

    try {
      return lista.firstWhere((item) {
        if (item.codigoBarras == codigoOriginal ||
            item.codigoBarras == codigoLimpio) {
          return true;
        }
        // COMPARACION SIN CEROS A LA IZQUIERDA
        final itemSinCeros = item.codigoBarras.replaceFirst(RegExp(r'^0+'), '');
        final busqSinCeros = codigoLimpio.replaceFirst(RegExp(r'^0+'), '');
        if (itemSinCeros == busqSinCeros && busqSinCeros.isNotEmpty) {
          return true;
        }
        return false;
      });
    } catch (e) {
      // SI NO ESTA EN LA LISTA ESTATICA RETORNA NULO
      return null;
    }
  }
}