// ARCHIVO: LIB/DATOS/BASE_DATOS_SQLITE.DART

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../modelos/perfil_usuario.dart';
import '../modelos/producto.dart';
import '../modelos/registro_historial.dart';

/// CLASE SINGLETON PARA GESTIONAR LA BASE DE DATOS LOCAL SQLITE
class BaseDatosSqlite {
  // CONSTRUCTOR PRIVADO PARA EL PATRON SINGLETON
  BaseDatosSqlite._privado();

  // INSTANCIA UNICA ACCESIBLE GLOBALMENTE
  static final BaseDatosSqlite instancia = BaseDatosSqlite._privado();

  // REFERENCIA A LA BASE DE DATOS ABIERTA
  static Database? _baseDatos;

  // GETTER ASINCRONO QUE OBTIENE O INICIALIZA LA BASE DE DATOS
  Future<Database> get baseDatos async {
    if (_baseDatos != null) return _baseDatos!;
    _baseDatos = await _inicializarBaseDatos();
    return _baseDatos!;
  }

  // APERTURA Y CONFIGURACION DE LA BASE DE DATOS SQLITE LOCAL
  Future<Database> _inicializarBaseDatos() async {
    // RUTA DEL DIRECTORIO DEL SISTEMA PARA BASES DE DATOS
    final rutaDirectorio = await getDatabasesPath();
    final rutaArchivo = join(rutaDirectorio, 'nutriscan.db');

    // APERTURA O CREACION DEL ARCHIVO DE BASE DE DATOS 
    final db = await openDatabase(
      rutaArchivo,
      version: 3,
      onCreate: _crearTablasIniciales,
      onUpgrade: _actualizarBaseDatos,
    );

    // ASEGURA LA INTEGRIDAD DE LAS TABLAS Y COLUMNAS EN CASO DE BASES PREVIAS
    try {
      final columnas =
          await db.rawQuery('PRAGMA table_info(catalogo_alimentos)');
      final nombresColumnas =
          columnas.map((c) => c['name']?.toString() ?? '').toSet();
      if (!nombresColumnas.contains('categoria') ||
          !nombresColumnas.contains('sellos')) {
        await db.execute('DROP TABLE IF EXISTS catalogo_alimentos');
        await db.execute('''
          CREATE TABLE catalogo_alimentos (
            codigoBarras TEXT PRIMARY KEY,
            nombre TEXT,
            categoria TEXT,
            calorias REAL,
            azucares REAL,
            sodio REAL,
            sellos TEXT,
            formatoGuia TEXT
          )
        ''');
      }
    } catch (_) {
      // SI OCURRE ERROR EN LA VERIFICACION PRAGMA CONTINUA CON LA PRECARGA
    }

    // ASEGURA LA DISPONIBILIDAD DE LOS PRODUCTOS OFFLINE EN CADA INICIO
    try {
      await _precargarAlimentosReales(db);
    } catch (_) {
      // MANEJO SEGURO DE ERRORES DURANTE LA PRECARGA
    }

    return db;
  }

  // MIGRACION DINAMICA EN CASO DE ACTUALIZACION DE VERSION DE BASE DE DATOS
  Future<void> _actualizarBaseDatos(
      Database db, int versionAnterior, int versionNueva) async {
    // RECONSTRUYE LAS TABLAS LOCALES PARA ASEGURAR COLUMNAS Y TIPOS CORRECTOS
    await db.execute('DROP TABLE IF EXISTS catalogo_alimentos');
    await db.execute('''
      CREATE TABLE catalogo_alimentos (
        codigoBarras TEXT PRIMARY KEY,
        nombre TEXT,
        categoria TEXT,
        calorias REAL,
        azucares REAL,
        sodio REAL,
        sellos TEXT,
        formatoGuia TEXT
      )
    ''');
    await _precargarAlimentosReales(db);
  }

  // CREACION DE TABLAS E INSERCION DE REGISTROS INICIALES OBLIGATORIOS
  Future<void> _crearTablasIniciales(Database db, int version) async {
    // 1. TABLA PERFIL DE USUARIO
    await db.execute('''
      CREATE TABLE perfil_usuario (
        id INTEGER PRIMARY KEY,
        tieneDiabetes INTEGER,
        tieneHipertension INTEGER,
        tieneCeliaquia INTEGER,
        alergiaLactosa INTEGER
      )
    ''');

    // 2. TABLA CATALOGO DE ALIMENTOS LOCALES
    await db.execute('''
      CREATE TABLE catalogo_alimentos (
        codigoBarras TEXT PRIMARY KEY,
        nombre TEXT,
        categoria TEXT,
        calorias REAL,
        azucares REAL,
        sodio REAL,
        sellos TEXT,
        formatoGuia TEXT
      )
    ''');

    // 3. TABLA HISTORIAL DE ESCANEOS EN VIVO (SE INICIALIZA TOTALMENTE VACIA)
    await db.execute('''
      CREATE TABLE historial_escaneos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigoBarras TEXT,
        nombre TEXT,
        veredicto TEXT,
        fecha TEXT
      )
    ''');

    // 4. INSERCION DEL PERFIL INICIAL POR DEFECTO DEL USUARIO
    await db.insert('perfil_usuario', {
      'id': 1,
      'tieneDiabetes': 0,
      'tieneHipertension': 0,
      'tieneCeliaquia': 0,
      'alergiaLactosa': 0,
    });
  }

  // INSERTA O ACTUALIZA LOS ALIMENTOS OFFLINE CON SUS CODIGOS Y NOMBRES REALES
  Future<void> _precargarAlimentosReales(Database db) async {
    final List<Map<String, dynamic>> alimentosReales = [
      // =======================================================================
      // CATEGORIA 1: PAPAS FRITAS Y SNACKS CRUJIENTES (ALTO SODIO / GRASAS)
      // =======================================================================
      {
        'codigoBarras': '7702189000019',
        'nombre': 'Papas Margarita Natural 25g',
        'categoria': 'Snacks',
        'calorias': 135.0,
        'azucares': 0.0,
        'sodio': 125.0,
        'sellos': 'EXCESO EN SODIO, EXCESO EN GRASAS SATURADAS',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '7702189000064',
        'nombre': 'Papas Margarita Natural 300g',
        'categoria': 'Snacks',
        'calorias': 540.0,
        'azucares': 1.0,
        'sodio': 490.0,
        'sellos': 'EXCESO EN SODIO, EXCESO EN GRASAS SATURADAS',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '7702189010018',
        'nombre': 'Papas Margarita Natural 36g',
        'categoria': 'Snacks',
        'calorias': 195.0,
        'azucares': 0.5,
        'sodio': 175.0,
        'sellos': 'EXCESO EN SODIO, EXCESO EN GRASAS SATURADAS',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '7702189000026',
        'nombre': 'Papas Margarita Sabor a Pollo 25g',
        'categoria': 'Snacks',
        'calorias': 135.0,
        'azucares': 0.5,
        'sodio': 130.0,
        'sellos': 'EXCESO EN SODIO, EXCESO EN GRASAS SATURADAS',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '7702189010025',
        'nombre': 'Papas Margarita Sabor a Pollo 36g',
        'categoria': 'Snacks',
        'calorias': 195.0,
        'azucares': 0.8,
        'sodio': 180.0,
        'sellos': 'EXCESO EN SODIO, EXCESO EN GRASAS SATURADAS',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '7702189000033',
        'nombre': 'Papas Margarita Sabor a Limón 25g',
        'categoria': 'Snacks',
        'calorias': 130.0,
        'azucares': 0.0,
        'sodio': 135.0,
        'sellos': 'EXCESO EN SODIO, EXCESO EN GRASAS SATURADAS',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '7702189010032',
        'nombre': 'Papas Margarita Sabor a Limón 36g',
        'categoria': 'Snacks',
        'calorias': 190.0,
        'azucares': 0.5,
        'sodio': 190.0,
        'sellos': 'EXCESO EN SODIO, EXCESO EN GRASAS SATURADAS',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '7702189000040',
        'nombre': 'Papas Margarita Onduladas Natural 36g',
        'categoria': 'Snacks',
        'calorias': 195.0,
        'azucares': 0.5,
        'sodio': 175.0,
        'sellos': 'EXCESO EN SODIO, EXCESO EN GRASAS SATURADAS',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '7702001012345',
        'nombre': 'Papas Fritas Clásicas 105g',
        'categoria': 'Snacks',
        'calorias': 540.0,
        'azucares': 1.5,
        'sodio': 480.0,
        'sellos': 'EXCESO EN SODIO, EXCESO EN GRASAS SATURADAS',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '7702189015013',
        'nombre': 'Doritos Mega Queso 42g',
        'categoria': 'Snacks',
        'calorias': 215.0,
        'azucares': 1.2,
        'sodio': 240.0,
        'sellos': 'EXCESO EN SODIO, EXCESO EN GRASAS SATURADAS',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '7702189017017',
        'nombre': 'De Todito Snack Mixto Natural 45g',
        'categoria': 'Snacks',
        'calorias': 238.0,
        'azucares': 1.0,
        'sodio': 235.0,
        'sellos': 'EXCESO EN SODIO, EXCESO EN GRASAS SATURADAS',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '7702189016010',
        'nombre': 'Cheetos Snacks de Queso 32g',
        'categoria': 'Snacks',
        'calorias': 165.0,
        'azucares': 1.0,
        'sodio': 200.0,
        'sellos': 'EXCESO EN SODIO, EXCESO EN GRASAS SATURADAS',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '7702189014016',
        'nombre': 'Choclitos Sabor a Limón 30g',
        'categoria': 'Snacks',
        'calorias': 150.0,
        'azucares': 1.0,
        'sodio': 145.0,
        'sellos': 'EXCESO EN SODIO, EXCESO EN GRASAS SATURADAS',
        'formatoGuia': 'barra',
      },

      // =======================================================================
      // CATEGORIA 2: BEBIDAS GASEOSAS Y AZUCARADAS (ALTO AZUCAR)
      // =======================================================================
      {
        'codigoBarras': '5449000000996',
        'nombre': 'Gaseosa Coca-Cola Original 400ml',
        'categoria': 'Bebidas azucaradas',
        'calorias': 170.0,
        'azucares': 42.0,
        'sodio': 40.0,
        'sellos': 'EXCESO EN AZÚCARES, CONTIENE EDULCORANTES',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '7702010023456',
        'nombre': 'Gaseosa Cola 400ml',
        'categoria': 'Bebidas azucaradas',
        'calorias': 170.0,
        'azucares': 42.0,
        'sodio': 40.0,
        'sellos': 'EXCESO EN AZÚCARES, CONTIENE EDULCORANTES',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '7501055300075',
        'nombre': 'Gaseosa Coca-Cola Original 600ml',
        'categoria': 'Bebidas azucaradas',
        'calorias': 252.0,
        'azucares': 63.0,
        'sodio': 60.0,
        'sellos': 'EXCESO EN AZÚCARES, EXCESO EN CALORÍAS',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '7702010000013',
        'nombre': 'Gaseosa Coca-Cola Original 250ml',
        'categoria': 'Bebidas azucaradas',
        'calorias': 105.0,
        'azucares': 26.0,
        'sodio': 25.0,
        'sellos': 'EXCESO EN AZÚCARES',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '7702010000020',
        'nombre': 'Gaseosa Coca-Cola Original 350ml',
        'categoria': 'Bebidas azucaradas',
        'calorias': 147.0,
        'azucares': 37.0,
        'sodio': 32.0,
        'sellos': 'EXCESO EN AZÚCARES',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '5449000131805',
        'nombre': 'Gaseosa Coca-Cola Original 500ml',
        'categoria': 'Bebidas azucaradas',
        'calorias': 210.0,
        'azucares': 53.0,
        'sodio': 45.0,
        'sellos': 'EXCESO EN AZÚCARES, EXCESO EN CALORÍAS',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '7702090000010',
        'nombre': 'Gaseosa Colombiana Postobón 400ml',
        'categoria': 'Bebidas azucaradas',
        'calorias': 180.0,
        'azucares': 44.0,
        'sodio': 36.0,
        'sellos': 'EXCESO EN AZÚCARES, CONTIENE EDULCORANTES',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '7702090000119',
        'nombre': 'Gaseosa Manzana Postobón 400ml',
        'categoria': 'Bebidas azucaradas',
        'calorias': 180.0,
        'azucares': 44.0,
        'sodio': 36.0,
        'sellos': 'EXCESO EN AZÚCARES, CONTIENE EDULCORANTES',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '7702004000310',
        'nombre': 'Bebida de Malta Pony Malta 330ml',
        'categoria': 'Bebidas azucaradas',
        'calorias': 140.0,
        'azucares': 33.0,
        'sodio': 30.0,
        'sellos': 'EXCESO EN AZÚCARES',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '7702090001017',
        'nombre': 'Jugo Hit Mora 500ml',
        'categoria': 'Bebidas azucaradas',
        'calorias': 130.0,
        'azucares': 31.0,
        'sodio': 40.0,
        'sellos': 'EXCESO EN AZÚCARES',
        'formatoGuia': 'barra',
      },
      {
        'codigoBarras': '7702090001024',
        'nombre': 'Jugo Hit Naranja Piña 500ml',
        'categoria': 'Bebidas azucaradas',
        'calorias': 130.0,
        'azucares': 31.0,
        'sodio': 40.0,
        'sellos': 'EXCESO EN AZÚCARES',
        'formatoGuia': 'barra',
      },

      // =======================================================================
      // CATEGORIA 3: GALLETAS COMERCIALES Y DULCES (GLUTEN / LACTOSA / AZUCARES)
      // =======================================================================
      {
        'codigoBarras': '7702025102032',
        'nombre': 'Galletas Festival Chocolate 403g',
        'categoria': 'Galletas y Dulces',
        'calorias': 260.0,
        'azucares': 22.0,
        'sodio': 110.0,
        'sellos': 'EXCESO EN AZÚCARES, EXCESO EN GRASAS SATURADAS',
        'formatoGuia': 'galleta',
      },
      {
        'codigoBarras': '7702025102018',
        'nombre': 'Galletas Festival Fresa 403g',
        'categoria': 'Galletas y Dulces',
        'calorias': 260.0,
        'azucares': 22.0,
        'sodio': 105.0,
        'sellos': 'EXCESO EN AZÚCARES, EXCESO EN GRASAS SATURADAS',
        'formatoGuia': 'galleta',
      },
      {
        'codigoBarras': '7702025102025',
        'nombre': 'Galletas Festival Vainilla 403g',
        'categoria': 'Galletas y Dulces',
        'calorias': 260.0,
        'azucares': 22.0,
        'sodio': 105.0,
        'sellos': 'EXCESO EN AZÚCARES, EXCESO EN GRASAS SATURADAS',
        'formatoGuia': 'galleta',
      },
      {
        'codigoBarras': '7622210986708',
        'nombre': 'Galletas Oreo Clásicas 108g',
        'categoria': 'Galletas y Dulces',
        'calorias': 210.0,
        'azucares': 16.0,
        'sodio': 180.0,
        'sellos': 'EXCESO EN AZÚCARES, EXCESO EN GRASAS SATURADAS',
        'formatoGuia': 'galleta',
      },
      {
        'codigoBarras': '7622300744652',
        'nombre': 'Galletas Oreo Original 432g',
        'categoria': 'Galletas y Dulces',
        'calorias': 210.0,
        'azucares': 16.0,
        'sodio': 180.0,
        'sellos': 'EXCESO EN AZÚCARES, EXCESO EN GRASAS SATURADAS',
        'formatoGuia': 'galleta',
      },
      {
        'codigoBarras': '7702020034567',
        'nombre': 'Galletas Rellenas de Chocolate 120g',
        'categoria': 'Galletas y Dulces',
        'calorias': 260.0,
        'azucares': 22.0,
        'sodio': 110.0,
        'sellos': 'EXCESO EN AZÚCARES, EXCESO EN GRASAS SATURADAS',
        'formatoGuia': 'galleta',
      },
      {
        'codigoBarras': '7702025101011',
        'nombre': 'Galletas Noel Ducales 300g',
        'categoria': 'Galletas y Dulces',
        'calorias': 130.0,
        'azucares': 4.0,
        'sodio': 95.0,
        'sellos': 'EXCESO EN GRASAS SATURADAS, EXCESO EN SODIO',
        'formatoGuia': 'galleta',
      },
      {
        'codigoBarras': '7702025000017',
        'nombre': 'Galletas Saltín Noel Tradicional 300g',
        'categoria': 'Galletas y Dulces',
        'calorias': 110.0,
        'azucares': 1.0,
        'sodio': 170.0,
        'sellos': 'EXCESO EN SODIO',
        'formatoGuia': 'galleta',
      },
      {
        'codigoBarras': '7702004000129',
        'nombre': 'Ponqué Ramo Chocoramo 65g',
        'categoria': 'Galletas y Dulces',
        'calorias': 250.0,
        'azucares': 21.0,
        'sodio': 140.0,
        'sellos': 'EXCESO EN AZÚCARES, EXCESO EN GRASAS SATURADAS',
        'formatoGuia': 'galleta',
      },
    ];

    for (final item in alimentosReales) {
      await db.insert(
        'catalogo_alimentos',
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // RECUPERA EL PERFIL MEDICO GUARDADO DEL USUARIO
  Future<PerfilUsuario> obtenerPerfil() async {
    final db = await baseDatos;
    final resultados = await db.query(
      'perfil_usuario',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (resultados.isNotEmpty) {
      return PerfilUsuario.desdeMapa(resultados.first);
    }

    // SI NO EXISTIERA RETORNA UNO PREDETERMINADO
    return PerfilUsuario();
  }

  // PERSISTE O ACTUALIZA EL PERFIL DE SALUD DEL USUARIO
  Future<void> guardarPerfil(PerfilUsuario perfil) async {
    final db = await baseDatos;
    await db.insert(
      'perfil_usuario',
      perfil.aMapa(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // BUSCA UN ALIMENTO EN EL CATALOGO MEDIANTE SU CODIGO DE BARRAS EXACTO
  Future<Producto?> buscarAlimentoPorCodigo(String codigo) async {
    final db = await baseDatos;

    final String codigoOriginal = codigo.trim();
    // LIMPIEZA DE ESPACIOS Y CARACTERES NO NUMERICOS
    final String codigoLimpio =
        codigo.replaceAll(RegExp(r'[^0-9]'), '').trim();

    // INTENTO 1: BUSQUEDA DIRECTA POR CODIGO LIMPIO NUMERICO
    if (codigoLimpio.isNotEmpty) {
      final resultadosDirectos = await db.query(
        'catalogo_alimentos',
        where: 'codigoBarras = ?',
        whereArgs: [codigoLimpio],
        limit: 1,
      );

      if (resultadosDirectos.isNotEmpty) {
        return Producto.desdeMapa(resultadosDirectos.first);
      }

      // INTENTO 2: COINCIDENCIA REMOVIENDO CEROS A LA IZQUIERDA
      final codigoSinCeros = codigoLimpio.replaceFirst(RegExp(r'^0+'), '');
      if (codigoSinCeros.isNotEmpty && codigoSinCeros != codigoLimpio) {
        final resultadosSinCeros = await db.query(
          'catalogo_alimentos',
          where: 'codigoBarras = ? OR codigoBarras LIKE ?',
          whereArgs: [codigoSinCeros, '%$codigoSinCeros'],
          limit: 1,
        );

        if (resultadosSinCeros.isNotEmpty) {
          return Producto.desdeMapa(resultadosSinCeros.first);
        }
      }

      // INTENTO 3: COINCIDENCIA DE CODIGO CON CERO INICIAL (FORMATO UPC-A A EAN-13)
      if (codigoLimpio.length == 12) {
        final codigoEan13 = '0$codigoLimpio';
        final resultadosEan = await db.query(
          'catalogo_alimentos',
          where: 'codigoBarras = ?',
          whereArgs: [codigoEan13],
          limit: 1,
        );

        if (resultadosEan.isNotEmpty) {
          return Producto.desdeMapa(resultadosEan.first);
        }
      }

      // INTENTO 4: COINCIDENCIA POR CONTENIDO O SUBSTRING
      final resultadosSub = await db.query(
        'catalogo_alimentos',
        where: 'codigoBarras LIKE ?',
        whereArgs: ['%$codigoLimpio%'],
        limit: 1,
      );

      if (resultadosSub.isNotEmpty) {
        return Producto.desdeMapa(resultadosSub.first);
      }
    }

    // INTENTO 5: BUSQUEDA CON EL TEXTO EXACTO ORIGINAL RECIBIDO
    if (codigoOriginal.isNotEmpty) {
      final resultadosOriginal = await db.query(
        'catalogo_alimentos',
        where: 'codigoBarras = ?',
        whereArgs: [codigoOriginal],
        limit: 1,
      );

      if (resultadosOriginal.isNotEmpty) {
        return Producto.desdeMapa(resultadosOriginal.first);
      }
    }

    // SI NO SE ENCUENTRA EN LA BASE DE DATOS LOCAL RETORNA NULO
    return null;
  }

  // ALIAS COMPATIBLE PARA BUSQUEDA DE PRODUCTO
  Future<Producto?> buscarProductoPorCodigo(String codigo) async {
    return buscarAlimentoPorCodigo(codigo);
  }

  // REGISTRA UN NUEVO ESCANEO REALIZADO EN LA TABLA DE HISTORIAL
  Future<int> registrarEscaneo({
    required String codigoBarras,
    required String nombre,
    required String veredicto,
    required String fecha,
  }) async {
    final db = await baseDatos;
    return await db.insert('historial_escaneos', {
      'codigoBarras': codigoBarras,
      'nombre': nombre,
      'veredicto': veredicto,
      'fecha': fecha,
    });
  }

  // OBTIENE LA LISTA COMPLETA DEL HISTORIAL DE ESCANEOS ORDENADA CRONOLOGICAMENTE
  Future<List<RegistroHistorial>> obtenerHistorial() async {
    final db = await baseDatos;
    final registros = await db.query(
      'historial_escaneos',
      orderBy: 'id DESC',
    );

    return registros.map((mapa) => RegistroHistorial.desdeMapa(mapa)).toList();
  }

  // ELIMINA TODOS LOS REGISTROS DEL HISTORIAL DE ESCANEOS
  Future<void> limpiarHistorial() async {
    final db = await baseDatos;
    await db.delete('historial_escaneos');
  }
}
