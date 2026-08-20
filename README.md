# EduPlay 🚀

![Deploy to Firebase Hosting](https://github.com/GrullonDev/EduPlay/actions/workflows/firebase_hosting.yml/badge.svg)

**EduPlay** es una plataforma educativa gamificada diseñada para transformar el aprendizaje de niños y adolescentes en una aventura interactiva. Combinando diseño moderno y pedagogía lúdica, EduPlay ofrece un entorno seguro donde aprender matemáticas, idiomas, arte y más es pura diversión.

## 🌟 Características Principales

### 🎮 Universo de Juegos Educativos
Nuestra colección de juegos se adapta automáticamente a la edad del niño (7-17 años):

*   **🧮 Aventura Matemática:** Domina sumas, restas y multiplicaciones en un entorno de reto progresivo.
*   **✨ Palabras Mágicas:** Mejora la ortografía y vocabulario con anagramas y desafios de palabras.
*   **🗣️ Inglés Divertido:** Aprende vocabulario básico (Colores, Animales, Números) con ayudas visuales y auditivas.
*   **🌿 Exploradores de la Naturaleza:** Descubre el mundo natural identificando elementos y aprendiendo sobre el medio ambiente.
*   **🎨 Artistas en Acción:** Desata la creatividad con herramientas de dibujo y pintura libre.
*   **🎹 Concierto de Colores:** Experimenta con la música y los colores en un juego sensorial.
*   **⚽ Reto Deportivo:** Aprende sobre deportes y mantente activo (conceptualmente) con trivias y juegos rápidos.
*   **⏳ Viajeros del Tiempo:** Explora la historia y eventos importantes de una manera interactiva.
*   **🗺️ Mapa del Tesoro:** Resuelve acertijos de lógica para encontrar recompensas.
*   **📒 Álbum de Estampas:** ¡Colecciona logros! Cada victoria desbloquea estampas únicas para tu álbum personal.

### 🛡️ Experiencia de Usuario Premium
*   **Pasaporte EduPlay:** Nuevo flujo de registro inmersivo donde los niños crean su "Pasaporte de Agente", seleccionando su propio **Avatar** y edad con un selector visual e interactivo.
*   **Modo Invitado:** ¿Prisa por jugar? El botón "¡JUGAR YA!" permite acceso inmediato a juegos seleccionados sin registro previo.
*   **Zona de Padres:** Dashboard protegido donde los padres pueden monitorear el progreso, ver las puntuaciones altas y gestionar perfiles.
*   **Auto-Login Inteligente:** El sistema recuerda a tus hijos. Si ya hay perfiles registrados, la app inicia directamente en el menú principal para una experiencia sin fricción.

### 🎨 Diseño y Tecnología
*   **Interfaz Vibrante:** Estética moderna con colores vivos, animaciones fluidas y elementos visuales grandes ("Kid-First Design").
*   **Multiplataforma:** Optimizado para funcionar en Web, con diseños responsivos para tablets y escritorio.

### 🚧 En desarrollo (próximamente)
*   **🛍️ Tienda:** Los estudiantes podrán canjear los puntos ganados jugando por avatares, íconos y estampas exclusivas para su Álbum.
*   **🤝 Amigos:** Sistema social multi-rol (estudiante, padre, profesor) para conectar y ver el progreso de compañeros de clase.

## 🛠 Stack Tecnológico

*   **Framework:** Flutter 3.x
*   **Lenguaje:** Dart
*   **Gestión de Estado:** Provider
*   **Base de Datos (Nube):** Firebase Cloud Firestore
*   **Autenticación:** Firebase Auth
*   **Hosting:** Firebase Hosting
*   **CI/CD:** GitHub Actions (Deploy automático)
*   **Fuentes:** Google Fonts (Nunito, Fredoka, Courier Prime)

## 📦 Instalación y Despliegue

### Requisitos Previos
*   [Flutter SDK](https://flutter.dev/docs/get-started/install)
*   [Firebase CLI](https://firebase.google.com/docs/cli)

### Instalación Local
1.  **Clonar el repositorio:**
    ```bash
    git clone https://github.com/GrullonDev/EduPlay.git
    cd EduPlay
    ```

2.  **Instalar dependencias:**
    ```bash
    flutter pub get
    ```

3.  **Ejecutar:**
    ```bash
    flutter run
    ```

### 🚀 Despliegue en Firebase Hosting

#### Opción 1: Despliegue Manual
Para asegurar que los iconos dinámicos se visualicen correctamente, utiliza el siguiente comando de compilación:

```bash
fvm flutter build web --no-tree-shake-icons
firebase deploy
```

#### Opción 2: Despliegue Automático (CI/CD)
Este repositorio cuenta con un flujo de trabajo de GitHub Actions (`.github/workflows/firebase_hosting.yml`) que despliega automáticamente a Firebase cuando se hacen cambios en la rama `main` o `master`.

**Configuración Requerida:**
Para que esto funcione en tu propio fork o repositorio, debes agregar el secreto `FIREBASE_SERVICE_ACCOUNT_EDUPLAY_8792F` en **Settings > Secrets and variables > Actions**.

## 🤝 Contribuciones

Este proyecto es mantenido por **GrullonDev**. Las contribuciones son bienvenidas mediante Pull Requests.

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.

## 📞 Contacto y Comunidad

¡Únete a nuestra creciente comunidad para recibir noticias, actualizaciones y soporte!

*   **📢 Canal de Novedades:** [Suscríbete en WhatsApp](https://whatsapp.com/channel/0029Vb7iH085K3zPbsXjht3v)
*   **💬 Grupo de Comunidad:** [Únete al Chat](https://chat.whatsapp.com/G63n7QTzAXo2To8StWI3eb)
*   **💻 GitHub:** [GrullonDev](https://github.com/GrullonDev)
*   **🔗 LinkedIn:** [Jorge Luis Grullón Marroquín](https://www.linkedin.com/in/jorge-luis-grull%C3%B3n-marroquin)
