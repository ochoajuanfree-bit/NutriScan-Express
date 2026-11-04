# ARCHIVO: RECURSOS_PRUEBA/GENERAR_PDF_MARCADORES.PY
# GENERA EL DOCUMENTO PDF OFICIAL EXIGIDO POR LA RUBRICA DEL EXAMEN

import os
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, KeepTogether
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.graphics.barcode import createBarcodeDrawing

def generar_pdf():
    carpeta_actual = os.path.dirname(os.path.abspath(__file__))
    ruta_pdf = os.path.join(carpeta_actual, "marcadores_de_prueba.pdf")

    doc = SimpleDocTemplate(
        ruta_pdf,
        pagesize=letter,
        rightMargin=36,
        leftMargin=36,
        topMargin=36,
        bottomMargin=36
    )

    estilos = getSampleStyleSheet()

    estilo_titulo = ParagraphStyle(
        'TituloPrincipal',
        parent=estilos['Heading1'],
        fontSize=20,
        leading=24,
        textColor=colors.HexColor('#004D40'),
        alignment=1, # Centrado
        fontName='Helvetica-Bold'
    )

    estilo_subtitulo = ParagraphStyle(
        'Subtitulo',
        parent=estilos['Normal'],
        fontSize=11,
        leading=15,
        textColor=colors.HexColor('#455A64'),
        alignment=1,
        fontName='Helvetica'
    )

    estilo_producto = ParagraphStyle(
        'NombreProducto',
        parent=estilos['Heading2'],
        fontSize=14,
        leading=17,
        textColor=colors.HexColor('#004D40'),
        fontName='Helvetica-Bold'
    )

    estilo_categoria = ParagraphStyle(
        'CategoriaBadge',
        parent=estilos['Normal'],
        fontSize=9,
        leading=11,
        textColor=colors.HexColor('#00796B'),
        fontName='Helvetica-Bold'
    )

    estilo_celda = ParagraphStyle(
        'CeldaTexto',
        parent=estilos['Normal'],
        fontSize=9,
        leading=12,
        textColor=colors.HexColor('#263238'),
        fontName='Helvetica'
    )

    estilo_celda_bold = ParagraphStyle(
        'CeldaTextoBold',
        parent=estilos['Normal'],
        fontSize=9,
        leading=12,
        textColor=colors.HexColor('#1B5E20'),
        fontName='Helvetica-Bold'
    )

    estilo_alerta = ParagraphStyle(
        'CeldaAlerta',
        parent=estilos['Normal'],
        fontSize=9,
        leading=12,
        textColor=colors.HexColor('#B71C1C'),
        fontName='Helvetica-Bold'
    )

    elementos = []

    # ENCABEZADO
    elementos.append(Paragraph("NutriScan Express - Marcadores de Prueba Oficiales", estilo_titulo))
    elementos.append(Spacer(1, 4))
    elementos.append(Paragraph("Carpeta de Recursos de Prueba (Imprimibles / Digitales) | Asignatura: Profesional Complementaria II", estilo_subtitulo))
    elementos.append(Spacer(1, 14))

    # LISTADO DE LOS 3 PRODUCTOS EXIGIDOS
    productos = [
        {
            "nombre": "1. Papas Margarita Natural 25g",
            "categoria": "CATEGORÍA: SNACKS / PAPAS FRITAS",
            "codigo": "7702189000019",
            "filas": [
                ("Calorías (Porción 25g / 100g):", "135 kcal (540 kcal / 100g)"),
                ("Sodio (Porción 25g / 100g):", "125 mg (490 mg / 100g) [ALTO SODIO]"),
                ("Azúcares:", "0.0 g"),
                ("Sellos Frontales:", "EXCESO EN SODIO, EXCESO EN GRASAS SATURADAS"),
                ("Condición Médica de Prueba:", "Hipertensión Arterial -> Veredicto: NO RECOMENDADO")
            ],
            "alerta_idx": 4
        },
        {
            "nombre": "2. Gaseosa Coca-Cola Original 400ml",
            "categoria": "CATEGORÍA: BEBIDAS AZUCARADAS",
            "codigo": "5449000000996",
            "filas": [
                ("Calorías (Envase 400ml):", "170 kcal (42.5 kcal / 100ml)"),
                ("Azúcares Totales:", "42.0 g [ALTO AZÚCAR CRÍTICO]"),
                ("Sodio:", "40 mg"),
                ("Sellos Frontales:", "EXCESO EN AZÚCARES, CONTIENE EDULCORANTES"),
                ("Condición Médica de Prueba:", "Diabetes Mellitus -> Veredicto: NO RECOMENDADO")
            ],
            "alerta_idx": 4
        },
        {
            "nombre": "3. Galletas Festival Chocolate 403g",
            "categoria": "CATEGORÍA: GALLETAS COMERCIALES Y DULCES",
            "codigo": "7702025102032",
            "filas": [
                ("Calorías (Porción 4 galletas / 56g):", "260 kcal (490 kcal / 100g)"),
                ("Azúcares Totales:", "22.0 g (38g / 100g) [ALTO AZÚCAR]"),
                ("Sodio:", "110 mg (220 mg / 100g)"),
                ("Sellos y Alérgenos:", "EXCESO EN AZÚCARES, GRASAS | Contiene Gluten y Lactosa"),
                ("Condición Médica de Prueba:", "Celiaquía o Intolerancia a Lactosa -> NO RECOMENDADO")
            ],
            "alerta_idx": 4
        }
    ]

    for p in productos:
        # DIBUJO DEL CODIGO DE BARRAS ESCANEABLE (EAN13)
        dibujo_codigo = createBarcodeDrawing(
            'EAN13',
            value=p["codigo"],
            width=170,
            height=65,
            barWidth=1.3,
            fontSize=9,
            humanReadable=True
        )

        # TABLA DE INFORMACION NUTRICIONAL Y CLINICA
        datos_tabla = []
        for i, (k, v) in enumerate(p["filas"]):
            estilo_val = estilo_alerta if i == p["alerta_idx"] else estilo_celda_bold
            datos_tabla.append([
                Paragraph(k, estilo_celda),
                Paragraph(v, estilo_val)
            ])

        tabla_info = Table(datos_tabla, colWidths=[150, 210])
        tabla_info.setStyle(TableStyle([
            ('BACKGROUND', (0,0), (-1,-1), colors.HexColor('#FAFAFA')),
            ('LINEBELOW', (0,0), (-1,-1), 0.5, colors.HexColor('#ECEFF1')),
            ('TOPPADDING', (0,0), (-1,-1), 3),
            ('BOTTOMPADDING', (0,0), (-1,-1), 3),
            ('LEFTPADDING', (0,0), (-1,-1), 6),
            ('RIGHTPADDING', (0,0), (-1,-1), 6),
        ]))

        # COMBINAR CODIGO DE BARRAS + TABLA EN UNA SOLA FILA
        fila_bloque = Table([
            [dibujo_codigo, tabla_info]
        ], colWidths=[180, 360])
        fila_bloque.setStyle(TableStyle([
            ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
            ('ALIGN', (0,0), (0,0), 'CENTER'),
            ('BOX', (0,0), (-1,-1), 1, colors.HexColor('#CFD8DC')),
            ('BACKGROUND', (0,0), (-1,-1), colors.white),
            ('TOPPADDING', (0,0), (-1,-1), 8),
            ('BOTTOMPADDING', (0,0), (-1,-1), 8),
            ('LEFTPADDING', (0,0), (-1,-1), 8),
            ('RIGHTPADDING', (0,0), (-1,-1), 8),
        ]))

        bloque = [
            Paragraph(p["nombre"], estilo_producto),
            Paragraph(p["categoria"], estilo_categoria),
            Spacer(1, 4),
            fila_bloque,
            Spacer(1, 10)
        ]
        elementos.append(KeepTogether(bloque))

    # NOTA AL PIE CON INSTRUCCIONES DE EVALUACION
    instrucciones = (
        "<b>Guía de Evaluación Rápida:</b> 1) Abre la app NutriScan Express en tu teléfono o emulador. "
        "2) En <i>Mi Perfil de Salud</i> activa Diabetes o Hipertensión. "
        "3) En <i>Escanear Producto</i> enfoca cualquiera de los códigos de barras de este documento con la cámara o pulsa el ícono de Marcadores en la barra superior. "
        "El motor evaluará las restricciones del usuario y emitirá el semáforo justificando la recomendación médica."
    )
    estilo_pie = ParagraphStyle(
        'PieTexto',
        parent=estilos['Normal'],
        fontSize=8.5,
        leading=11.5,
        textColor=colors.HexColor('#004D40'),
        fontName='Helvetica'
    )
    tabla_pie = Table([[Paragraph(instrucciones, estilo_pie)]], colWidths=[540])
    tabla_pie.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor('#E0F2F1')),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor('#80CBC4')),
        ('TOPPADDING', (0,0), (-1,-1), 6),
        ('BOTTOMPADDING', (0,0), (-1,-1), 6),
        ('LEFTPADDING', (0,0), (-1,-1), 10),
        ('RIGHTPADDING', (0,0), (-1,-1), 10),
    ]))
    elementos.append(tabla_pie)

    doc.build(elementos)
    print(f"PDF generado exitosamente en: {ruta_pdf}")

if __name__ == "__main__":
    generar_pdf()
