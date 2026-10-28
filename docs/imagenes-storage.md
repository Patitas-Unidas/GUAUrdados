# Fotos y carnets en Firebase Storage

Proyecto: `guaurdados`. Bucket: `gs://guaurdados.firebasestorage.app`.
Ubicación: Santiago (`southamerica-west1`), igual que Firestore.

Las fotos están en `images/` y los carnets en `carnets/`. Los originales locales
se conservan en `media/images/` y `media/carnets/` como respaldo; no se publican
con Firebase Hosting.

Para agregar una imagen, abre Firebase Console → Storage → Archivos, entra a la
carpeta correspondiente y sube el archivo. Copia su URL de descarga completa al
documento del perro en Firestore:

- Foto: `fotoUrl` (también se admite el campo antiguo `imagen_asset`).
- Carnet: `carnetUrls`, un arreglo con las URLs de frente y reverso (también se
  admite `carnet_asset`). No guardes solamente el nombre del archivo.

El botón de carnet aparece cuando hay al menos una URL válida. La app ya muestra
las URLs de Storage con `ImagenRemota` y `CachedNetworkImageProvider`. Todas las
pantallas comparten `ImagenesCache`, que guarda archivos en disco entre sesiones
(hasta 200 objetos, limpieza de archivos no usados durante 30 días). El sistema
operativo puede liberar esa caché; no es almacenamiento permanente garantizado.
Las URLs con token permiten descargar la imagen a quien tenga el enlace.

La validez de cada archivo respeta `Cache-Control` de Storage; al caducar, la
caché usa `ETag` para comprobar cambios sin volver a transferir una imagen que
sigue igual. Un archivo cacheado puede mostrarse mientras se comprueba su nueva
versión. Para que una actualización se vea inmediatamente, sube la imagen con
un nombre nuevo y actualiza su URL en Firestore. Reemplazar el contenido con la
misma URL se detecta en una carga posterior a su caducidad, no instantáneamente
en una pantalla que ya tiene la imagen en memoria. No uses `actualizadoEn` del
perro para invalidar fotos: cambios de comida o perfil no deben descargarlas.

Las reglas permiten lectura autenticada por SDK y subida de imágenes menores a
10 MiB exclusivamente a usuarios con el custom claim `admin: true`. La consola
usa los permisos IAM de la cuenta de Google.

```powershell
firebase deploy --only storage --project guaurdados
```

La migración de Hosting a Storage se realizó el 27 de octubre de 2026: 19 archivos
y referencias actualizadas en 8 perros. Se conservaron los campos existentes
para mantener compatibilidad con la app. Los carnets de Cabezon y Perla están
subidos pero no se asignaron a otros perros porque no tenían documento en la
colección. Hosting quedó retirado después de verificar las descargas.
