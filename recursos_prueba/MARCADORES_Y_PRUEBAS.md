# RECURSOS DE PRUEBA Y MARCADORES - NUTRISCAN EXPRESS

**Asignatura:** Profesional Complementaria II (Desarrollo Móvil con Flutter)  
**Proyecto:** NutriScan Express - Asistente de Evaluación Nutricional

---

## 1. Alimentos Oficiales Definidos para el MVP (3 Productos Obligatorios)

| Categoría                 | Producto Comercial                   | Código EAN-13 Exacto | Parámetros Críticos                      | Sellos Oficiales                              | Veredicto con Alerta                                             |
| ------------------------- | ------------------------------------ | -------------------- | ---------------------------------------- | --------------------------------------------- | ---------------------------------------------------------------- |
| **Papas Fritas / Snacks** | **Papas Margarita Natural 25g**      | `7702189000019`      | Sodio: 490mg <br> Calorías: 540 kcal     | EXCESO EN SODIO <br> EXCESO EN GRASAS         | 🔴 No recomendado si el perfil tiene **Hipertensión**            |
| **Bebidas Gaseosas**      | **Coca-Cola Original 400ml**         | `5449000000996`      | Azúcar: 45g <br> Calorías: 180 kcal      | EXCESO EN AZÚCARES <br> CONTIENE EDULCORANTES | 🔴 No recomendado si el perfil tiene **Diabetes**                |
| **Galletas Comerciales**  | **Galletas Festival Chocolate 403g** | `7702025102032`      | Azúcar: 38g <br> Gluten + Trazas Lácteas | EXCESO EN AZÚCARES <br> EXCESO EN GRASAS      | 🔴 No recomendado si el perfil tiene **Celiaquía** o **Lactosa** |

---

## 2. Catálogo Extendido Precargado en SQLite (Offline)

Además de los 3 productos obligatorios, el sistema tiene precargadas en SQLite las presentaciones más comunes del mercado colombiano:

- **Snacks:** Papas Margarita Pollo (`7702189000026`), Limón (`7702189000033`), Onduladas (`7702189000040`), Doritos Mega Queso (`7702189015013`), De Todito Natural (`7702189017017`), Cheetos (`7702189016010`), Choclitos (`7702189014016`).
- **Bebidas:** Coca-Cola 600ml (`7501055300075`), 250ml (`7702010000013`), Colombiana Postobón (`7702090000010`), Manzana Postobón (`7702090000119`), Pony Malta (`7702004000310`), Jugos Hit (`7702090001017`).
- **Galletas y Dulces:** Galletas Oreo Clásicas (`7622210986708`), Galletas Oreo Original 432g (`7622300744652`), Galletas Ducales (`7702025101011`), Saltín Noel (`7702025000017`), Ponqué Chocoramo (`7702004000129`).

---

## 3. Opciones de Prueba en la Aplicación

1. **Escaneo con Cámara en Tiempo Real:**
   - Abre la aplicación y pulsa **ESCANEAR PRODUCTO (CÁMARA IA)**.
   - Apunta el visor al código de barras en pantalla (abriendo `recursos_prueba/marcadores_de_prueba.html`) o a un producto físico real.
2. **Acceso Rápido a Marcadores Oficiales:**
   - En la barra superior del escáner, pulsa el ícono de **Marcadores** (cinta con check).
   - Se abrirá un menú desplegable con los 3 productos del examen; al tocar cualquiera de ellos, se procesa automáticamente.
3. **Ingreso Manual de Código:**
   - En la barra superior del escáner o tocando el disparador manual, pulsa el ícono de **Teclado**.
   - Digita cualquier código numérico para evaluarlo en SQLite o en Open Food Facts.

---

## 4. Generación del Documento PDF para la Entrega

Abre en tu navegador (Google Chrome, Edge o Firefox) el archivo:
`recursos_prueba/marcadores_de_prueba.html`

Presiona **Ctrl + P** (o Cmd + P en Mac), selecciona la opción **"Guardar como PDF"** y guárdalo como `Marcadores_NutriScan_Express.pdf` para incluirlo en la carpeta de recursos de prueba de la entrega final.
