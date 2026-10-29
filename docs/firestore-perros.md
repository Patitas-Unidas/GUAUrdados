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

### Campos opcionales de cuidado

Si no existen, la app muestra "Sin registrar". Con las fechas calcula sola la
próxima alimentación sugerida, cuándo vencen vacunas y desparasitación, y los
avisos del perfil (reglas en `lib/services/cuidados.dart`).

| Campo | Tipo | Ejemplo |
| --- | --- | --- |
| `ultimaComidaEn` | timestamp | Hora en que se registró la última comida |
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
