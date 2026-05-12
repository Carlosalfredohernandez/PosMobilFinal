# POSMOBIL - Resumen de Avances y Estabilidad

Fecha: 11-05-2026

## 1. Qué hace esta aplicación
- Aplicación POS móvil en Flutter para ventas en caja.
- Permite buscar/agregar productos, calcular total y registrar pago.
- Emite boletas electrónicas (DTE) integradas con SII vía API.
- Recupera el XML autorizado de la boleta emitida.
- Genera y muestra PDF de boleta en formato POS para visualización e impresión.

## 2. Flujo principal operativo
1. Caja: se arma el detalle de venta con productos seleccionados.
2. Emisión SII: se envía la boleta a API y se obtiene ID/folio DTE.
3. XML DTE: se solicita XML autorizado asociado a la boleta.
4. Parseo XML: se transforma XML a mapa de datos para PDF.
5. PDF POS: se genera boleta con encabezado, detalle, totales y timbre TED/PDF417.

## 3. Ajustes clave realizados para estabilidad

### Integración de parser centralizado XML
- Se unificó el parseo en un utilitario dedicado para evitar diferencias entre flujos.
- Extracción robusta de Folio, RUT Emisor, Razón Social, Giro, Dirección, Total, Detalle y TED.

### Compatibilidad con XML real SII
- Se ajustó la lectura para estructuras reales recibidas por API.
- Se soportan campos opcionales en Detalle (por ejemplo, QtyItem puede no venir).
- Cuando no existe QtyItem, la cantidad se asigna en 1 por defecto para no romper el render.

### Robustez en generación de PDF
- Manejo defensivo de datos nulos/vacíos en razón social y detalle.
- Render de tabla de productos tolerante a campos faltantes.
- Integración de TED DD para generar código PDF417.
- Fallback visual cuando no hay TED (mensaje de código sin TED).

### Integración en flujo real de emisión
- El flujo principal de caja pasa xml_string al visor de PDF.
- En la página PDF se parsea xml_string antes de generar documento, asegurando datos reales del DTE.

### Trazabilidad y diagnóstico
- Se agregaron prints de debug en flujo principal antes de abrir PDF (folio + XML).
- Se agregaron prints de debug del mapa final usado por el generador PDF.
- Esto permite validar en tiempo real que los datos de empresa y detalle llegan correctamente.

### Correcciones puntuales aplicadas
- Import faltante del parser corregido en páginas que lo usan.
- Ajustes de rutas/navegación para abrir pantalla PDF correcta.

## 4. Datos críticos cubiertos en el PDF
- RUT empresa (RUTEmisor).
- Razón social (RznSocEmisor).
- Dirección (DirOrigen).
- Giro (GiroEmisor).
- Folio DTE.
- Detalle de productos (nombre, cantidad, precio/monto).
- Total boleta.
- TED DD para código PDF417.

## 5. Estado actual
- Flujo de emisión y visualización PDF integrado de extremo a extremo.
- La aplicación está en mejor estado de estabilidad para pruebas reales con XML de SII.
- Si un XML llega con variaciones nuevas, el parser centralizado permite ajustar una sola vez y propagar a todo el flujo.

## 6. Recomendaciones de operación
1. Mantener parser XML como única fuente de datos para PDF.
2. Conservar logs de debug durante QA y retirarlos/reducirlos en producción.
3. Agregar pruebas sobre muestras XML reales (con y sin campos opcionales).
4. Versionar cualquier ajuste de estructura XML en este mismo documento.
