# Documentación Técnica del Proyecto

## 1. Descripción general
- **Objetivo:** Juego "Slide Puzzle" que permite mover fichas numéricas o de imágenes para ordenarlas.
- **Tecnologías:** Flutter (Dart) para la aplicación, Firebase Firestore para el *leaderboard*, librerías auxiliares para sonido, animaciones y manipulación de imágenes.
- **Arquitectura:** Patrón basado en *Provider* para gestión de estado; cada pantalla es un `Widget` independiente.

## 2. Estructura de archivos
- `lib/` código fuente principal de Flutter.
  - `main.dart` configura `MaterialApp` y rutas entre pantallas.
  - `models/` contiene modelos como `Tile`, `GameMode` y `Difficulty`.
  - `providers/puzzle_provider.dart` maneja el estado global del juego y la lógica del puzzle, incluyendo el auto-solver A*.
  - `screens/` vistas de la aplicación (ej. `DashboardScreen`, `GameScreen`, `VictoryScreen`).
  - `services/` funcionalidades extra como `AutoSolveService` y `FirebaseService`.
  - `widgets/` componentes reutilizables (`PuzzleBoard`, `TileWidget`, `ParallaxBackground`).
- `assets/` recursos (imágenes, audio, animaciones) declarados en `pubspec.yaml`.
- `analysis_options.yaml` define reglas de lint de Flutter.
- `pubspec.yaml` especifica las dependencias del proyecto.

## 3. Flujo de trabajo
1. La app inicia en `WelcomeScreen`. Tras una animación inicial, redirige al `DashboardScreen`.
2. En el tablero se eligen modo (numérico o imagen) y dificultad; se pueden cargar imágenes propias.
3. `PuzzleProvider.initialize()` crea las fichas y mezcla la posición inicial verificando solvencia.
4. El usuario mueve las fichas; el estado se actualiza mediante el provider. Se muestran tiempo transcurrido, número de movimientos y sugerencias calculadas con A*.
5. Es posible solicitar la resolución automática con `autoSolve()` salvo en dificultad "hard" (5x5) para evitar cierres inesperados.
6. Al completar el puzzle se navega a `VictoryScreen` donde se muestra un resumen y se puede guardar la puntuación en Firebase.

## 4. Dependencias principales
- `provider` para la gestión de estado.
- `just_audio` para la música de fondo controlada desde `ParallaxBackground`.
- `lottie` para animaciones.
- `confetti` para efectos de victoria.
- `cloud_firestore` para almacenar puntuaciones.
- `image_picker` e `image_cropper` para seleccionar y editar imágenes de usuario.

## 5. Instrucciones para contribuir
1. Instalar Flutter SDK 3.8.1 o superior.
2. Ejecutar `flutter pub get` para descargar dependencias.
3. Correr `flutter run` para lanzar la app.
4. El proyecto sigue las reglas de `flutter_lints` (ver `analysis_options.yaml`). Ejecutar `flutter analyze` antes de enviar un PR.
5. Las nuevas funciones o pantallas deben implementarse siguiendo el esquema de `Provider` para el estado global.
