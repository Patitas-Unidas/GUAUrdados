# Colección de perros en Cloud Firestore

La aplicación obtiene los perros exclusivamente desde la colección `perros`.
Cada documento puede usar un ID automático o uno legible, por ejemplo `scooby`.

| Campo | Tipo | Ejemplo |
| --- | --- | --- |
| `nombre` | string | `Scooby` |
| `estado` | string | `Saludable` o `Necesita atención` |
| `raza`, `edad`, `peso`, `ultimaComida`, `tamano` | string | `Mestizo`, `3 años`, etc. |
| `vacunacion`, `descripcion`, `caracter` | string | Información visible en el perfil |
| `fotoUrl` | string | URL de descarga completa de Firebase Storage |
| `imagenAsset` | string | Respaldo local opcional, por ejemplo `Scooby.jpg` |
| `actualizadoEn` | timestamp | Timestamp actual de Firestore |
| `seguidores` | array de strings | UIDs de Firebase Auth que siguen al perro |

### Adopción

Solo los administradores pueden editar la colección `perros`. Al marcar un
perrito como adoptado, la app lo pasa al final de la lista con la etiqueta
"Adoptado", muestra su perfil desenfocado con un mensaje y deja de pedir
registros de cuidado, alertas y emergencias para él. Sus datos y su foro se
conservan como historial.

| Campo | Tipo | Ejemplo |
| --- | --- | --- |
| `adoptado` | boolean | `true` |
| `adoptadoEn` | timestamp (opcional) | Fecha en que encontró una familia |

### Avisos de perritos sin registrar

Si la cámara no reconoce a un perrito, cualquier usuario puede avisar a GUAU
desde ahí. El aviso se guarda en `foro/sin_registrar/publicaciones` con
`tipoPublicacion: "perrito_nuevo"`, sin `idPerro` ni `nombrePerro` (no está asociado a ningún perrito),
una descripción y, opcionalmente, `ubicacion` y `fotoUrl` (la foto se sube a
Storage en `avisos/{uid}/`). Aparece en el foro general.

Cuando GUAU revisa el aviso, un administrador lo cierra agregando estos campos
a la publicación (no se borra, así la comunidad ve cómo terminó):

| Campo | Tipo | Uso |
|---|---|---|
| `resultadoAviso` | string | `registrado` (se agregó el perrito) o `ya_registrado` (era uno conocido) |
| `idPerroAviso` | string (opcional) | ID del perrito en `perros`; la publicación muestra su nombre y foto y abre su perfil |
| `notaGuau` | string (opcional) | Comentario de GUAU, hasta 500 caracteres |
| `revisadoEn` | timestamp (opcional) | Cuándo se revisó |
| `revisadoPor` | string (opcional) | UID del administrador que lo revisó |

### Campos opcionales de cuidado

Si no existen, la app muestra "Sin registrar". Con las fechas calcula sola la
próxima alimentación sugerida, cuándo vencen vacunas y desparasitación, y los
avisos del perfil (reglas en `lib/services/cuidados.dart`).

| Campo | Tipo | Ejemplo |
| --- | --- | --- |
| `ultimaComidaEn` | timestamp | Hora en que se registró la última comida |
| `ultimaAguaEn` | timestamp | Hora en que se registró la última vez que tomó agua |
| `ultimaVacunaEn` | timestamp | Fecha de la última vacuna |
| `ultimaDesparasitacionEn` | timestamp | Fecha de la última desparasitación |
| `esterilizado` | boolean o string | `true`, `"Sí"`, `"No"` |
| `condiciones` | array de strings | Condiciones médicas: `["Displasia de cadera"]` (se ven en Estado médico) |
| `restricciones` | array de strings | Restricciones de alimentación: `["Sin pollo", "Sin gluten"]` (se ven en Registrar alimentación) |
| `fotoCentro` | string o map | Dónde está la cara del perro en la foto, de 0 a 1 (horizontal, vertical): `"0.5, 0.35"` o `{x: 0.5, y: 0.35}`. Las fotos se recortan para que la cara quede a la vista; sin este campo se usa un punto un poco arriba del centro |

## Primer documento

En Firebase Console: **Firestore Database → Create database → Start in production mode**.
Luego crea `perros/scooby` y agrega los campos de arriba. Para `actualizadoEn`,
selecciona el tipo **timestamp** y usa la hora actual. Repite para cada perro.

La consulta principal ordena por `actualizadoEn`, por lo que ese campo es obligatorio.
Las reglas del repositorio se publican con:

```powershell
firebase deploy --only firestore:rules
```

El archivo `firestore.rules` limita la lectura a usuarios autenticados. Las
cuentas administradoras administran los documentos de perros; cada usuario
autenticado puede seguir perros y crear publicaciones en sus foros.

## Foros y publicaciones

Cada perro tiene un foro en `foro/{idPerro}`. El ID del documento del foro es el
mismo ID del documento en `perros` para foros nuevos, y guarda el campo
`idperro`. Si ya existe un foro con ese campo y un ID antiguo, la app lo reutiliza.
Por eso no hace falta agregar un campo `id_foro` al perro. Las publicaciones se guardan en
`foro/{idPerro}/publicaciones/{idPublicacion}`; Firestore genera el ID de cada
publicación.

Todas las publicaciones comparten estos campos:

| Campo | Tipo | Descripción |
| --- | --- | --- |
| `idPerro` | string | ID del perro del foro |
| `nombrePerro` | string | Nombre visible del perro al publicar |
| `idUsuario` | string | UID de Firebase Authentication que publicó |
| `nombreUsuario` | string | Nombre de perfil guardado como referencia histórica |
| `fotoUsuario` | string, opcional | URL de perfil, si la cuenta tiene una |
| `tipoPublicacion` | string | `normal`, `alimentacion` o `estado_medico` |
| `descripcion` | string | Texto de la publicación o nota opcional |
| `creadoEn` | timestamp | Hora asignada por Firestore |

Las publicaciones de tipo `alimentacion` agregan `tipoComida` y
`cantidadComida`; `estado_medico` agrega `procedimiento`. Así los tipos
comparten una sola colección y pueden ordenarse juntos en la misma cronología.
El UID identifica al autor; el nombre y la foto son copias de presentación, no
se usan para autorizar escrituras.

La pantalla **Nueva publicación** crea publicaciones `normal` de texto. La
alimentación se registra desde el perfil del perro; al guardar, la app actualiza
`ultimaComida`, `ultimaComidaEn` y `actualizadoEn` del perro y agrega una
publicación `alimentacion` al foro dentro de la misma escritura atómica.

La fila de seguidores usa la colección `perfiles_publicos/{uid}`, que solo
contiene nombre, usuario y foto. La app la actualiza al iniciar sesión o al
cambiar el nombre. Los tokens de notificaciones permanecen en `usuarios/{uid}`
y no se exponen en la consulta de seguidores.

Para habilitar la creación de publicaciones en el proyecto Firebase, publica
las reglas actualizadas:

```powershell
firebase deploy --only firestore:rules
```

Las consultas de la cronología y de actividad de usuario usan el grupo de
colecciones `publicaciones`. Sus índices de grupo están definidos en
`firestore.indexes.json` y se publican con:

```powershell
firebase deploy --only firestore:indexes
```

### Reacciones y comentarios

Solo las publicaciones normales y los avisos de perrito nuevo tienen reacciones y
comentarios (las de alimentación, estado médico y las emergencias no).

| Campo en la publicación | Tipo | Uso |
|---|---|---|
| `reacciones` | map | `{uid: {e, n, f}}`: emoji (`❤️ 🥰 🐶 😂 😮 😢 💪`), nombre y foto de quien reaccionó. Una reacción por persona; cada uno solo cambia la suya |
| `numComentarios` | number | Cantidad de comentarios (sube y baja de a uno) |
| `ultimoComentario` | map | `{idUsuario, nombre, en}` del último comentario; con esto la campana del autor muestra "X comentó tu publicación" |

Los comentarios van en `foro/{idForo}/publicaciones/{idPublicacion}/comentarios/{id}`
con `idUsuario`, `nombreUsuario`, `fotoUsuario` (opcional), `texto` (hasta 500
caracteres) y `creadoEn`. No se editan; los borra su autor o un admin.

## Fotos y carnets en Firebase Storage

Las imágenes están en `guaurdados.firebasestorage.app`, dentro de `images/` y
`carnets/`. Guarda la URL completa de descarga de la foto en `fotoUrl` y las del
carnet en el arreglo `carnetUrls`. También se admiten los campos antiguos
`imagen_asset` y `carnet_asset`, ya migrados a URLs de Storage.

Consulta [imagenes-storage.md](imagenes-storage.md) para subir nuevas imágenes y
publicar las reglas de acceso. La app prioriza `fotoUrl`; `imagenAsset` queda como
respaldo local opcional.

## Emergencias

Cada reporte es un documento de `emergencias`:

| Campo | Tipo | Detalle |
| --- | --- | --- |
| `idsPerros`, `nombresPerros` | array de strings | Perros involucrados, en el mismo orden. Vacíos si no se conoce al perro |
| `tipo` | string | `Problema de salud`, `Pelea`, `Peligro` u `Otro` |
| `ubicacion` | string | Opcional, hasta 200 caracteres |
| `creadoPor`, `nombreUsuario` | string | Quien reportó |
| `estado` | string | `en_curso`, `resuelta`, `veterinario` o `falsa_alarma` |
| `nota` | string | Comentario opcional al cerrarla |
| `creadoEn`, `cerradaEn` | timestamp | Hora asignada por Firestore |

Solo quien la reportó (o un admin) puede cerrarla, una sola vez, desde **Mi
perfil**. Mientras está en curso aparece fijada arriba del foro general y del
foro de cada perro involucrado; al cerrarse se sigue viendo 24 horas con su
resultado. Las emergencias en curso dejan de mostrarse en los foros a los 3
días, pero siguen en el perfil de quien la reportó hasta que la cierre.

Las funciones de `functions/index.js` avisan por push a los seguidores al crear
y al cerrar una emergencia, y cada hora revisan `ultimaComidaEn` y
`ultimaAguaEn` para avisar si un perro lleva más de 24 horas sin registros
(una vez por registro; lo avisado queda en `avisos_cuidado/{idPerro}`).
