# barberstyle

A new Flutter project.

#  Barber Style
Aplicación móvil para la **gestión digital de citas en barberías**, desarrollada en **Flutter** con backend en **Firebase**.

---

##  Tabla de Contenidos
1. [Descripción del proyecto](#descripción-del-proyecto)
2. [Características principales](#características-principales)
3. [Tecnologías utilizadas](#tecnologías-utilizadas)
4. [Arquitectura del proyecto](#arquitectura-del-proyecto)
5. [Estructura de la base de datos](#estructura-de-la-base-de-datos)
6. [Instalación y configuración](#instalación-y-configuración)
7. [Estructura del código](#estructura-del-código)
8. [Guía de uso](#guía-de-uso)
9. [Capturas de pantalla](#capturas-de-pantalla)
10. [Posibles mejoras](#posibles-mejoras)
11. [Autor](#autor)

---

##  **Descripción del proyecto**

**Barber Style** es una aplicación móvil creada para modernizar cómo las barberías gestionan sus citas.  
Permite que los usuarios puedan:

- Ver barberías registradas  
- Seleccionar barberos  
- Consultar horarios disponibles  
- Reservar una cita sin necesidad de llamadas  
- Cancelar sus citas  
- Dejar reseñas

Y que los administradores puedan:

- Gestionar barberos  
- Gestionar servicios  
- Administrar citas  
- Ver reseñas de los clientes  
-Editar la información de su barbería

El objetivo principal es eliminar gestiones manuales, evitar llamadas constantes, reducir errores y mejorar la experiencia de clientes y barberías.

---

##  **Características principales**

###  **Usuario**
- Registro e inicio de sesión
- Listado de barberías
- Visualización de barberos y servicios
- Selección de fecha y hora disponible
- Reserva de citas
- Cancelación de citas
- Gestión de perfil
- Reseñas a barberías

###  **Administrador**
- Creación y edición de barbería propia
- Gestión de barberos: añadir, editar y eliminar
- Gestión de servicios: añadir, editar y eliminar
- Gestión completa de citas: filtrar, completar o eliminar
- Visualización de reseñas y promedio de estrellas

---

##  **Tecnologías utilizadas**

###  Frontend
- **Flutter 3.x**
- **Dart**
- Provider (gestión de estado)

###  Backend
- **Firebase Authentication**
- **Cloud Firestore**
- **Firebase Storage** (si se guardan imágenes)
- **Firebase Hosting / Web (opcional)**

### ️ Herramientas adicionales
- Android Studio
- Git y GitHub
- Mermaid.js (diagramas UML)
- Intl (formatos de fecha)
- RxDart (CombineLatestStream)

---

##  **Arquitectura del proyecto**

El proyecto sigue el patrón **MVVM (Model - View - ViewModel)**:


