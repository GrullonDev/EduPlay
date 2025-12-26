# EduPlay

EduPlay es una plataforma educativa gamificada dirigida a niños y adolescentes. El objetivo es proporcionar una herramienta interactiva que fomente el aprendizaje en diversas áreas de una manera divertida y atractiva.

## 🚀 Características

### 🎮 Juegos Educativos (Adaptables a la Edad)
*   **Aventura Matemática (Math Adventure):** Resuelve problemas matemáticos adaptados a la edad del niño (Suma, Resta, Multiplicación).
*   **Palabras Mágicas (Magic Words):** Juego de ortografía y asociación de palabras con niveles de dificultad (Ver y Elegir, Completar Espacios, Anagramas).
*   **Inglés Divertido (Fun English):** Juego de construcción de vocabulario (Colores, Animales, Números) con modos visuales y de traducción.

### 🌟 Experiencia Central
*   **Modo Invitado (Guest Mode):** Permite a los niños jugar inmediatamente sin un registro completo. Entrada tipo "Mago" amigable para niños.
*   **Zona de Padres (Parent Dashboard):** Área administrativa para que los padres vean a los niños registrados y sus puntuaciones más altas en los juegos.
*   **Tema Global:** Diseño vibrante, lúdico y responsivo "tipo Web" utilizando estética personalizada de Glassmorphism y Neumorphism.

### 🛠 Destacados Técnicos
*   **Base de Datos Local:** Utiliza `sqflite` (SQLite) para almacenar perfiles de niños y el progreso del juego localmente en el dispositivo.
*   **Gestión de Estado:** Impulsado por `Provider` para un manejo eficiente del estado global (Sesión de Usuario, Lógica del Juego).
*   **UI Responsiva:** Diseños dinámicos (GridViews, LayoutBuilders) que se adaptan a pantallas Web, Tablet y Escritorio.

## 💻 Stack Tecnológico

- **Flutter:** 3.x
- **Lenguaje:** Dart
- **Gestión de Estado:** Provider
- **Almacenamiento Local:** sqflite, path
- **Estilos:** Google Fonts (Nunito), Esquemas de Color Personalizados

## 📦 Instalación

### Requisitos Previos

- [SDK de Flutter](https://flutter.dev/docs/get-started/install)
- [FVM (Opcional pero Recomendado)](https://fvm.app/docs/getting_started/installation)

### Clonar el Repositorio

```sh
git clone https://github.com/GrullonDev/EduPlay.git
cd EduPlay
```

### Configuración y Ejecución

1.  **Instalar Dependencias:**
    ```sh
    fvm flutter pub get
    # o simplemente 'flutter pub get' si no usas FVM
    ```

2.  **Ejecutar la App:**
    ```sh
    # Para Chrome (Web)
    fvm flutter run -d chrome

    # Para Windows
    fvm flutter run -d windows
    ```

> **Nota para Web:** Si encuentras errores de `AssetManifest`, ejecuta `flutter clean` seguido de `flutter build web --profile` antes de ejecutar.

## 🤝 Contribuciones

Firmado por **GrullonDev**. Si deseas contribuir:

1.  Haz un Fork del repositorio.
2.  Crea una rama: `git checkout -b feature/funcionalidad-increible`
3.  Haz commit de los cambios: `git commit -m "Agregar funcionalidad increíble"`
4.  Push a la rama: `git push origin feature/funcionalidad-increible`
5.  Abre un Pull Request.

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.

## 📞 Contacto

- **GitHub:** [GrullonDev](https://github.com/GrullonDev)
- **LinkedIn:** [Jorge Luis Grullón Marroquín](https://www.linkedin.com/in/jorge-luis-grull%C3%B3n-marroquin)
- **WhatsApp:** [GrullonDev](https://wa.me/50242909548)
