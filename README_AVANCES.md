# 9. Consulta certificación software de mercado

**¿Es necesario certificar el software ante el SII si desarrollo y comercializo sistemas de facturación electrónica?**

Sí, si tu empresa desarrolla software de mercado para emitir documentos tributarios electrónicos (como facturas o boletas electrónicas) y lo comercializa a terceros, debes certificarlo ante el Servicio de Impuestos Internos (SII) de Chile.
Esto implica:

- Registrar tu empresa y tu software como proveedor de software de mercado en el SII.
- Pasar por un proceso de certificación técnica y funcional, donde el SII valida que tu sistema cumple con los requisitos legales y técnicos.
- Realizar pruebas de emisión, recepción y validación de DTE en ambiente de certificación.
- Una vez aprobado, tu software aparecerá en la lista oficial de “Software de Mercado Certificado” del SII.

**Referencias útiles:**
- [Portal SII: Certificación de Software de Mercado](https://www.sii.cl/servicios_online/1041-1592.html)
- [Manual de Certificación de Software de Mercado SII (PDF)](https://www.sii.cl/factura_electronica/manuales/certificacion_software_mercado.pdf)
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

## 9. Implementar la app en Play Store

- **Preparación:**  
  - Configura el archivo `android/app/build.gradle` con el nombre de paquete, versión y firma digital (keystore).
  - Genera el archivo de firma (`keystore.jks`) y configura las variables en `key.properties`.
  - Asegúrate de que el ícono y los permisos estén correctamente definidos en `AndroidManifest.xml`.

- **Compilación:**  
  - Ejecuta `flutter build appbundle` para generar el archivo `.aab` requerido por Google Play.
  - Verifica que la app funcione correctamente en modo release.

- **Publicación:**  
  - Ingresa a Google Play Console, crea una aplicación y sube el archivo `.aab`.
  - Completa la ficha de Play Store, políticas de privacidad y pruebas internas.
  - Sube capturas de pantalla y define los testers.
  - Espera la revisión de Google y publica la app.


## 10. Integración con Transbank (POS físico)
- **Notas técnicas:**  
  - La integración requiere conocer el modelo de POS y su protocolo de comunicación Bluetooth.
  - Si existe SDK nativo (Android/iOS), se debe implementar un canal de plataforma Flutter para enviar el monto y recibir el resultado.
  - Si el POS solo opera con la app oficial de Transbank, la app debe esperar confirmación manual del cajero.
  - El flujo está preparado para mostrar feedback inmediato al usuario según el resultado de la transacción.

## 11. Avances y errores recientes (18-05-2026)

- Se detectó y corrigió un crash visual en el diálogo de cobro en efectivo (pantalla cliente_caja_create_antiguo):
  - El error era causado por la presencia de un código de color ANSI (`\u001b[32m`) en el widget de texto del total, lo que no es soportado por Flutter y puede provocar cierre inesperado de la app o errores de renderizado.
  - Se eliminó dicho código y se validó que el diálogo funciona correctamente, mostrando el total en azul sin caracteres extraños.
- Se revisó línea por línea la función _cashBack y el flujo de cobro para descartar otros errores de sintaxis o lógica.
- No se detectaron errores de compilación tras la corrección, pero se recomienda limpiar caché y reiniciar el workspace si persisten problemas visuales o de estado.
- Se documenta este ajuste para futuras referencias y para evitar el uso de códigos de color ANSI en widgets de Flutter.

- **Flujo de pago presencial:**  
  - Al cerrar la venta, el usuario elige el método de pago: efectivo, débito o crédito.
  - Si es débito/crédito, se muestra un diálogo: "Opere tarjeta en POS".
  - El cliente pasa la tarjeta en el POS físico (Bluetooth) y digita la clave.
  - La app espera la respuesta del POS (aprobada/rechazada).
  - Si la transacción es exitosa, se cierra la venta y se emite la boleta; si es rechazada, se permite reintentar o cambiar el método.

- **Notas técnicas:**  
  - La integración requiere conocer el modelo de POS y su protocolo de comunicación Bluetooth.
  - Si existe SDK nativo (Android/iOS), se debe implementar un canal de plataforma Flutter para enviar el monto y recibir el resultado.
  - Si el POS solo opera con la app oficial de Transbank, la app debe esperar confirmación manual del cajero.
  - El flujo está preparado para mostrar feedback inmediato al usuario según el resultado de la transacción.

## 12. Avances recientes (20-05-2026)

### Gestión de usuarios empresa: Eliminar usuario
- Se implementó la funcionalidad de eliminar usuario en la pantalla de gestión de usuarios empresa (`usuarios_empresa_page.dart`).
- Ahora cada usuario tiene un menú con la opción "Eliminar" junto a "Editar".
- Al seleccionar "Eliminar", se muestra un diálogo de confirmación antes de proceder.
- Si se confirma, se llama al método `eliminarUsuario` en el controlador, que a su vez utiliza el provider para eliminar el usuario en backend.
- Tras eliminar, la lista de usuarios se refresca automáticamente y se muestra feedback visual (snackbar de éxito o error).
- Se corrigieron y ordenaron los imports y declaraciones en el controlador para evitar errores de compilación.
- Se validó que no existan errores en los archivos clave tras los cambios.

### Notas técnicas
- El provider de usuarios empresa ya soportaba la operación delete, solo faltaba exponerla en la UI y controlador.
- Se revisó línea por línea el controlador para asegurar que todas las funciones y variables usadas estuvieran correctamente declaradas y accesibles.
- Se recomienda limpiar caché y reiniciar el IDE si persisten errores visuales tras los cambios.

## 13. Robustez en asignación de local_usuario al grabar boletas (20-05-2026)

- Se detectó que el campo `local_usuario` podía quedar vacío al grabar boletas desde el flujo de caja, lo que afectaba la trazabilidad y la correcta asociación de ventas a cada local.
- Se implementó una validación y asignación robusta en el controlador de caja para asegurar que siempre se asigne un valor válido a `local_usuario` antes de enviar la boleta al backend.
- Ahora, si el valor no está presente en el usuario o en la sesión, se muestra un error y no se permite grabar la boleta hasta corregir el dato.
- Se agregaron logs de debug para verificar que el campo se envía correctamente en cada emisión.
- Impacto: Todas las boletas quedan correctamente asociadas a un local, mejorando la trazabilidad, reportabilidad y evitando inconsistencias en el backend.

## 14. Incidencias y correcciones recientes (21-22-05-2026)

### Limpieza y compatibilidad de impresión TSC (cliente_caja_create_antiguo.dart)
- Se revisó y limpió completamente la función de impresión de prueba para máxima compatibilidad con la versión instalada de la librería image (4.x), eliminando errores de argumentos y de acceso a píxeles.
- Se eliminaron todos los rastros de la API antigua de image (argumentos posicionales, operadores bitwise, etc.) y se migró todo a la API moderna.
- Se corrigió el uso de drawString para que solo acepte los argumentos posicionales requeridos por la versión instalada.
- Se agregó y validó el constructor por defecto en la clase State para evitar errores de compilación.
- Se eliminaron funciones duplicadas y código muerto relacionado con impresión y PDF que no se utilizaba.
- Se revisó línea por línea el archivo para asegurar que no quedaran errores de compilación ni advertencias.
- Se documentó el flujo de impresión de prueba y la binarización moderna para futuras referencias.

### Manejo de errores y limpieza de imports
- Se corrigieron errores de ambigüedad y duplicidad en la importación de GetX, usando alias (getx) y actualizando todas las referencias en main_simple_fixed.dart.
- Se eliminaron referencias y el archivo main_simple_fixed.dart, ya que no se utiliza en el proyecto principal.
- Se validó que no existan referencias residuales ni errores tras la limpieza.

### Recomendaciones
- Si aparecen errores tras eliminar archivos, limpiar caché del IDE y ejecutar `flutter clean` seguido de `flutter pub get`.
- Mantener este README actualizado con cada incidencia relevante para no perder el historial de problemas y soluciones al cerrar el workspace.

## 12. Impresora utilizada y forma de impresión

### Modelo de impresora
- **Modelo:** Genérica China P1 (u otros modelos compatibles ESC/POS)
- **Tipo:** Térmica Bluetooth
- **Compatibilidad:** Funciona con el paquete `blue_thermal_printer` y comandos ESC/POS estándar.
- **Pruebas realizadas:** Impresión de texto, imágenes (bitmap) y PDF rasterizado como imagen.

### Forma de impresión habilitada en la app
- La app permite seleccionar y conectar la impresora desde la pantalla de configuración.
- El flujo de impresión utiliza la dirección MAC de la impresora guardada y se conecta automáticamente antes de imprimir.
- Se soportan dos métodos principales:
  1. **Impresión directa de texto:** Usando métodos como `printCustom` y `printNewLine` para imprimir líneas de texto y totales.
  2. **Impresión de imágenes:** Usando `printImageBytes` para enviar imágenes binarizadas (por ejemplo, logos, pruebas o boleta renderizada como imagen).
  3. **Impresión de PDF como imagen:** El PDF de la boleta se rasteriza a PNG y se imprime como bitmap usando `printImageBytes`.
- El flujo valida la conexión antes de imprimir y notifica al usuario en caso de éxito o error.
- La lógica es compatible con la mayoría de impresoras térmicas Bluetooth económicas del mercado (incluyendo la P1 y similares).

### Recomendaciones
- Verificar que la impresora esté encendida y emparejada antes de imprimir.
- Si ocurre error de conexión, cerrar otras apps que usen la impresora y volver a intentar.
- Para impresoras nuevas, probar primero la impresión de prueba desde la app.
- Si la impresión de imágenes sale distorsionada, ajustar el ancho de la imagen a 384px (o el ancho nativo de la impresora).

## 15. Avances recientes (29-05 al 01-06-2026)

### Impresión TSPL/POS: estabilidad de extremo a extremo
- Se consolidó la impresión de boleta rasterizada a TSPL con conversión robusta de imagen y manejo correcto de píxeles según la API de `image` 4.x.
- Se corrigió el problema de franjas verticales en la boleta: el comando `BITMAP` ahora se envía como bytes binarios reales (`writeBytes`) y no como string hexadecimal.
- Se corrigió la polaridad de bits (contraste invertido), evitando boletas con fondo oscuro y texto claro.
- Se ajustó el ancho imprimible para evitar corte en margen derecho y se dejó configurable por modelo de impresora.

### Configuración de impresora: calibración sin recompilar
- Se agregó control de `Ancho imprimible` en la pantalla de configuración de impresora (`impresora.dart`).
- El valor se guarda en `GetStorage` (`printable_width`) y se aplica automáticamente durante la impresión TSPL.
- Rango de calibración implementado: `320` a `384` px (valor recomendado inicial: `376`).

### Visor PDF: robustez ante bloqueos (estado "busy")
- Se reforzó la apertura del PDF POS para evitar bloqueos al reintentar impresión:
  - generación de archivo temporal con nombre único por intento,
  - liberación explícita de `PdfController` en `dispose`,
  - timeout al abrir el documento,
  - validaciones `mounted` antes de `setState` en rutas asíncronas.
- Se corrigió import faltante para `TimeoutException` en la pantalla de boleta PDF POS.

### Emisión SII: diagnóstico real y tolerancia a latencia
- Se robusteció `BoletaProvider`:
  - timeout en `generarBoleta`,
  - captura de error detallado (`status/body`) en `lastError`,
  - reintentos para obtener XML autorizado (`obtenerXmlBoleta`) con espera entre intentos,
  - detalle de error en `lastXmlError`.
- Se actualizó el controlador de caja para mostrar errores reales (no genéricos) al usuario.
- Se agregó log consolidado por intento de emisión (`[SII_FLOW]`) con etapa, resultado, id/folio, total, items y error final.

### Limpieza de producción
- Se retiró el guardado de PNGs de depuración y la lógica de permisos de almacenamiento usada solo para debugging de impresión.
- Se dejó el flujo final más limpio, con menor ruido en logs y enfocado en operación productiva.

### Commits relevantes de este bloque
- `5b62877` feat(tspl): impresión TSPL robusta a 384px, binarización y pruebas.
- `f68121d` fix: permisos Android y robustez de generación/visualización PDF.
- `c299dd5` fix: envío de BITMAP TSPL como bytes binarios (corrige franjas).
- `f878e87` fix: ajuste de polaridad de bits (corrige contraste invertido).
- `b98087f` chore: consolidación de configuración de ancho imprimible y mejoras TSPL.
- `ee074f2` chore: limpieza de debug TSPL para producción.

### Estado actual del módulo de boletas
- Emisión SII + recuperación XML + generación PDF + visualización + impresión Bluetooth operan de forma integrada.
- Persisten puntos de calibración fina dependientes de modelo de impresora (ancho/contraste), pero ya quedaron parametrizados para ajuste rápido en operación.
