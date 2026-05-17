# POSMOBIL - Resumen de Avances y Estabilidad


Fecha: 13-05-2026 (actualizado)

## 1. Qué hace esta aplicación
- Aplicación POS móvil en Flutter para ventas en caja.
- Permite buscar/agregar productos, calcular total y registrar pago.
- Emite boletas electrónicas (DTE) integradas con SII vía API (ahora usando endpoint público Railway: https://backendposmobil-production.up.railway.app).
- Recupera el XML autorizado de la boleta emitida.
- Genera y muestra PDF de boleta en formato POS para visualización e impresión.
- Permite imprimir la boleta como imagen PDF en impresora Bluetooth compatible.

## 2. Flujo principal operativo
1. Caja: se arma el detalle de venta con productos seleccionados.
2. Emisión SII: se envía la boleta a API y se obtiene ID/folio DTE.
3. XML DTE: se solicita XML autorizado asociado a la boleta.
4. Parseo XML: se transforma XML a mapa de datos para PDF.
5. PDF POS: se genera boleta con encabezado, detalle, totales y timbre TED/PDF417.


## 3. Ajustes clave y nuevas funcionalidades
### Integración con backend público Railway
- Todos los endpoints de consumo de API fueron actualizados a https://backendposmobil-production.up.railway.app para acceso desde cualquier red.

### Pantalla de configuración de impresora Bluetooth
- Nueva opción en el menú general para seleccionar y conectar impresora Bluetooth.
- Al seleccionar una impresora, la app intenta conectar y muestra mensaje de éxito o error.

### Impresión directa de boleta PDF
- Desde la pantalla de visualización PDF POS, se puede imprimir la boleta como imagen en la impresora Bluetooth conectada.
- El botón flotante (FAB) “Imprimir boleta” renderiza la primera página del PDF y la envía a la impresora.
- Se valida conexión antes de imprimir y se notifica al usuario.

### Validaciones y feedback
- Mensajes claros de éxito/error al conectar impresora y al imprimir.
- Recomendaciones de troubleshooting para errores comunes de Bluetooth.

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
- Flujo de emisión, visualización PDF y prueba de impresión Bluetooth integrado de extremo a extremo.
- La aplicación está en mejor estado de estabilidad para pruebas reales con XML de SII y backend público.
- Si un XML llega con variaciones nuevas, el parser centralizado permite ajustar una sola vez y propagar a todo el flujo.
- Se puede operar y probar desde cualquier red, sin depender de IPs locales.

## 6. Recomendaciones de operación
1. Mantener parser XML como única fuente de datos para PDF.
2. Conservar logs de debug durante QA y retirarlos/reducirlos en producción.
3. Agregar pruebas sobre muestras XML reales (con y sin campos opcionales).
4. Versionar cualquier ajuste de estructura XML en este mismo documento.
5. Para impresión Bluetooth:
	- Asegurarse de conectar la impresora desde la pantalla de configuración antes de imprimir.
	- Si ocurre error de conexión, cerrar otras apps que usen la impresora y volver a intentar.
	- Verificar compatibilidad de la impresora con impresión de imágenes.
6. Usar siempre el endpoint Railway para pruebas remotas o en producción.
## 7. Avances recientes (14-05-2026)

- Integración completa del flujo de cobro en ventas_page.dart:
	- Al presionar "Cobrar y finalizar venta", la boleta se guarda primero en backendposmobil (API propia) y luego en la API SII (Railway).
	- Solo si ambos guardados son exitosos, se ofrece al usuario la opción de ver el PDF o imprimir la boleta.
	- El carrito se limpia únicamente tras éxito en ambos sistemas.
	- Feedback robusto de errores en cada paso (snackbar).
	- El usuario puede elegir entre visualizar PDF o imprimir tras la venta.
- Corrección de errores de compilación y estructura en ventas_page.dart:
	- Función _finalizarVenta ahora está fuera de la clase y correctamente enlazada.
	- Se corrigieron cierres de clase/función duplicados y errores de sintaxis.
	- Se maneja defensivamente el null en precios y detalles.
- El flujo de ventas ahora es robusto, seguro y preparado para pruebas integrales.
## 8. Avances recientes (15-17-05-2026)

- Ahora la pantalla cliente_caja_create_antiguo graba la boleta en backendposmobil después de emitir la boleta en SII, usando el folio del DTE como campo 'numero', igual que el flujo de ventas_page.
- Se corrigió la navegación para usuarios con rol 3, apuntando a la ruta correcta '/inicio/cliente/caja/create_antiguo'.
- Se realizó commit de respaldo antes de modificar la lógica de grabado en backend.
- El flujo de emisión en cliente_caja_create_antiguo ahora garantiza que la venta queda registrada tanto en SII como en el backend propio, permitiendo trazabilidad y reportabilidad completa.
- Se mantiene la limpieza del carrito y feedback al usuario tras la operación.
