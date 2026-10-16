# Carnets veterinarios en Firebase Hosting

Guarda cada imagen de carnet en `public/carnets/` con un nombre simple, sin
acentos ni espacios. Por ejemplo:

```text
public/carnets/scooby-carnet.jpg
public/carnets/bobby-carnet.jpg
```

Publícalas con:

```powershell
firebase deploy --only hosting --project guaurdados
```

Las URLs públicas resultantes son:

```text
https://guaurdados.web.app/carnets/scooby-carnet.jpg
https://guaurdados.web.app/carnets/bobby-carnet.jpg
```

En Firestore, usa un campo de tipo **array** llamado `carnetUrls` con las dos
URLs, una para cada lado del carnet:

```text
carnetUrls: [
  "https://guaurdados.web.app/carnets/scooby-carnet-frente.jpg",
  "https://guaurdados.web.app/carnets/scooby-carnet-reverso.jpg"
]
```

El botón **Carnet Veterinario** se muestra sólo cuando el arreglo contiene al
menos una imagen. En la pantalla de carnet se puede deslizar horizontalmente
entre las dos imágenes.
