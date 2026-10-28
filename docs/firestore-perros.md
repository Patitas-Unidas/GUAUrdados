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

## Primer documento

En Firebase Console: **Firestore Database → Create database → Start in production mode**.
Luego crea `perros/scooby` y agrega los campos de arriba. Para `actualizadoEn`,
selecciona el tipo **timestamp** y usa la hora actual. Repite para cada perro.

La consulta principal ordena por `actualizadoEn`, por lo que ese campo es obligatorio.
Las reglas del repositorio se publican con:

```powershell
firebase deploy --only firestore:rules
```

El archivo `firestore.rules` permite lectura únicamente a usuarios autenticados y
reserva las escrituras para cuentas con el custom claim `admin: true`.

## Fotos y carnets en Firebase Storage

Las imágenes están en `guaurdados.firebasestorage.app`, dentro de `images/` y
`carnets/`. Guarda la URL completa de descarga de la foto en `fotoUrl` y las del
carnet en el arreglo `carnetUrls`. También se admiten los campos antiguos
`imagen_asset` y `carnet_asset`, ya migrados a URLs de Storage.

Consulta [imagenes-storage.md](imagenes-storage.md) para subir nuevas imágenes y
publicar las reglas de acceso. La app prioriza `fotoUrl`; `imagenAsset` queda como
respaldo local opcional.
