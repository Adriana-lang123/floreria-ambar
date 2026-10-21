<div align="center">

# Florería Ámbar

### Flores para momentos especiales

Aplicación móvil desarrollada en **Flutter + Firebase** para facilitar la compra de arreglos florales, la creación de pedidos personalizados y la gestión de entregas.

<br>

**Cliente** · **Administrador** · **Repartidor**

</div>

---

## Acerca del proyecto

**Florería Ámbar** es una aplicación móvil diseñada para mejorar la experiencia de compra y administración de una florería.

Desde la aplicación, los clientes pueden explorar productos, agregar arreglos al carrito, realizar pedidos y solicitar diseños personalizados para diferentes ocasiones.

Además, el sistema incorpora módulos especiales para **administradores** y **repartidores**, permitiendo controlar productos, pedidos y entregas desde una misma aplicación.

---

## Características principales

| Cliente | Administrador | Repartidor |
| :--- | :--- | :--- |
| Registro e inicio de sesión | Gestión de productos | Consulta de entregas |
| Catálogo de productos | Gestión de pedidos | Inicio de entrega |
| Categorías de flores | Control de estados | Confirmación de entrega |
| Carrito de compras | Arreglos personalizados | Pedidos no entregados |
| Realización de pedidos | Aceptar o rechazar solicitudes | Registro de incidencias |
| Fecha y hora de entrega | Reintentar entregas | Motivo de no entrega |
| Arreglos personalizados | Consulta de usuarios | Perfil del repartidor |
| Consulta de pedidos | Reportes y seguimiento | Seguimiento de pedidos |
| Perfil del usuario | Panel administrativo | |

---

## Arreglos personalizados

Una de las principales funciones de **Florería Ámbar** es permitir que cada cliente solicite un arreglo de acuerdo con sus preferencias.

El usuario puede indicar:

- Tipo de arreglo
- Colores predominantes
- Estilo del arreglo
- Tamaño
- Ocasión
- Presupuesto aproximado
- Flores deseadas
- Flores que no desea
- Mensaje para tarjeta
- Fecha de entrega
- Hora de entrega

La solicitud es enviada al administrador, quien puede **aceptarla o rechazarla**.

---

## Proceso de compra

El cliente puede realizar su pedido de una manera sencilla:

**Explorar productos**  
↓  
**Seleccionar un arreglo**  
↓  
**Agregar al carrito**  
↓  
**Confirmar el pedido**  
↓  
**Seleccionar fecha y hora de entrega**  
↓  
**Esperar la preparación y entrega**

---

## Seguimiento del pedido

Los pedidos pasan por diferentes estados para facilitar su seguimiento:

```text
┌─────────────┐
│  Pendiente  │
└──────┬──────┘
       ↓
┌─────────────┐
│ Preparando  │
└──────┬──────┘
       ↓
┌──────────────────────┐
│ Listo para entregar  │
└──────────┬───────────┘
           ↓
┌─────────────┐
│  En camino  │
└──────┬──────┘
       ↓
┌─────────────┐
│  Entregado  │
└─────────────┘
```

### ¿Qué ocurre si no se puede entregar?

Cuando el repartidor no puede completar una entrega, registra el motivo y el administrador puede programar un nuevo intento.

```text
En camino
    ↓
No entregado
    ↓
Motivo de no entrega
    ↓
Reintentar entrega
    ↓
Listo para entregar
```

---

## Roles de usuario

### Cliente

El cliente puede explorar el catálogo, realizar compras, solicitar arreglos personalizados y consultar sus pedidos.

### Administrador

El administrador controla los productos, pedidos, usuarios y solicitudes personalizadas de la florería.

### Repartidor

El repartidor recibe los pedidos preparados y actualiza el resultado de cada entrega.

---

## Tecnologías utilizadas

<p align="center">

**Flutter** • **Dart** • **Firebase Authentication** • **Cloud Firestore** • **Google Maps** • **Provider** • **Git** • **GitHub**

</p>

---

## Autenticación y seguridad

La aplicación utiliza **Firebase Authentication** para administrar el acceso de los usuarios.

Después del inicio de sesión, el sistema identifica el rol registrado en **Cloud Firestore** y dirige automáticamente al usuario al módulo correspondiente.

```text
Inicio de sesión
       │
       ▼
Identificación del rol
       │
 ┌─────┼───────────┐
 ▼     ▼           ▼
Cliente   Admin   Repartidor
```

---

## Versión para Android

Actualmente **Florería Ámbar** cuenta con una versión de prueba disponible para dispositivos Android.

La aplicación puede descargarse desde la sección:

### Releases

Archivo disponible:

```text
app-release.apk
```

> Esta versión está destinada a pruebas de funcionamiento y evaluación de la aplicación.

---

## Pruebas

Durante la etapa de pruebas se recomienda verificar principalmente:

- Inicio de sesión y registro
- Catálogo y categorías
- Carrito de compras
- Creación de pedidos
- Programación de entregas
- Arreglos personalizados
- Administración de pedidos
- Flujo de entrega
- Registro de entregas no realizadas
- Reintentos de entrega

---

## Estado del proyecto

> **Proyecto en desarrollo y etapa de pruebas**

Actualmente se realizan mejoras relacionadas con:

- Experiencia de usuario
- Validación de información
- Gestión de pedidos
- Personalización de arreglos
- Seguimiento de entregas
- Seguridad de la información

---

## Proyecto académico

**Florería Ámbar** fue desarrollada como un proyecto académico para aplicar conocimientos relacionados con:

- Desarrollo de aplicaciones móviles
- Flutter y Dart
- Bases de datos en la nube
- Firebase Authentication
- Cloud Firestore
- Gestión de roles
- Integración de mapas
- Control de versiones con Git y GitHub

---

<div align="center">

## Florería Ámbar

**Cada momento especial merece flores especiales.**

</div>
