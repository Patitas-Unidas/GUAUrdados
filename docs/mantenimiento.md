# Mantenimiento remoto

Antes de desplegar las reglas y publicar la app, crea el documento
`configuracion/servicio` en Cloud Firestore, en la base de datos predeterminada
del proyecto `guaurdados`. Agrega el campo **booleano** `habilitada` con valor
`true`. La app y las reglas requieren este campo para habilitar el servicio.

Despliega las reglas con `firebase deploy --only firestore:rules,storage --project guaurdados`.
En el primer despliegue, Firebase puede pedir permiso para que las reglas de
Storage consulten Firestore. Publica después la versión de la app que incluye
la pantalla de mantenimiento.

Para activar el mantenimiento, cambia `habilitada` a `false` desde la consola
de Firebase. Las versiones que incorporan el interruptor muestran la pantalla
de mantenimiento al recibir el cambio, incluso con la app abierta. Para
restaurar el servicio, cambia el mismo campo a `true`.

Las reglas bloquean el acceso de clientes a Firestore y Storage durante el
mantenimiento, incluso desde versiones antiguas. Esas versiones conservan su
interfaz y pueden mostrar datos guardados en el dispositivo. Los SDK de
administración y las URL de descarga ya emitidas por Storage tienen sus
propios permisos.

La app requiere confirmación de Firestore para entrar. Si no tiene conexión
al iniciar o el documento falta, muestra la pantalla de verificación.
El documento es de lectura pública y solo debe contener datos públicos.
