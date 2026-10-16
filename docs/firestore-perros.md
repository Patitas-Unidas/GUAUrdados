# Colección de perros en Cloud Firestore

La aplicación obtiene los perros exclusivamente desde la colección `perros`.
Cada documento puede usar un ID automático o uno legible, por ejemplo `scooby`.

| Campo | Tipo | Ejemplo |
| --- | --- | --- |
| `nombre` | string | `Scooby` |
| `estado` | string | `Saludable` o `Necesita atención` |
| `raza`, `edad`, `peso`, `ultimaComida`, `tamano` | string | `Mestizo`, `3 años`, etc. |
| `vacunacion`, `descripcion`, `caracter` | string | Información visible en el perfil |
| `fotoUrl` | string | `https://guaurdados.web.app/images/Scooby.jpg` |
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

## Fotos públicas con Firebase Hosting

Las imágenes de perros se publican desde `public/images/`, no desde Firestore
ni Firebase Storage. Para publicar las imágenes incluidas en el proyecto:

```powershell
npm install -g firebase-tools
firebase login
firebase deploy --only hosting --project guaurdados
```

Al terminar, guarda la URL pública de cada imagen en el campo `fotoUrl` del
documento correspondiente. La app prioriza `fotoUrl`; `imagenAsset` queda como
respaldo temporal mientras se completa la migración.
