# iShop 📦🛵

**iShop** es una aplicación móvil de **marketplace y gestión de delivery local**, pensada inicialmente para **Puerto Cabezas (Bilwi), Nicaragua**, con posibilidad de escalar a nivel nacional.

El proyecto nace para resolver un problema real:  
hoy en día, la venta de productos y la gestión de deliveries se hace de forma fragmentada usando **Facebook y WhatsApp**, lo que genera desorden, pérdida de tiempo y poca trazabilidad.

iShop busca unificar todo en una sola plataforma.

---

## 🚀 Objetivo del proyecto

Crear una plataforma que permita:

- 🛒 Comprar y vender productos de forma local
- 🛵 Gestionar deliveries individuales y por flota
- 📊 Visualizar estadísticas claras para cada tipo de usuario
- 📍 Facilitar la logística y el control de motos en tiempo real (futuro)
- 📱 Ofrecer una experiencia visual moderna, intuitiva y familiar (estilo redes sociales)

---

## 🧩 Perfiles de usuario

La aplicación está diseñada para múltiples roles:

### 👤 Comprador
- Feed tipo red social (scroll infinito)
- Búsqueda por categorías y nombre
- Historial básico de compras
- Solicitud de pedidos y seguimiento

### 🏪 Vendedor
- Publicación de productos
- Dashboard con:
  - Ventas diarias / semanales / mensuales
  - Gráficas visuales
  - Generación de reportes (PDF – futuro)
- Historial de ventas

### 🛵 Delivery individual
- Visualización de pedidos disponibles
- Métricas:
  - Carreras realizadas
  - Ingresos estimados
  - Distancia recorrida

### 🛵🛵 Flota de delivery
- Gestión de múltiples motos
- Asignación de motos a repartidores
- Seguimiento y reportes de desempeño
- Control de cuotas diarias (moto prestada)

### 🛠️ Administrador
- Control general del sistema
- Reportes globales por:
  - Perfil
  - Fecha
  - Categoría
- Supervisión de usuarios y actividad

---

## 🎨 Diseño y experiencia de usuario

- Inspirado en **Facebook / Instagram**
- Scroll infinito en el feed del comprador
- Cards visuales, gradientes y jerarquía clara
- Paleta de colores:
  - Blanco
  - Azul (principal)
  - Verde para acciones (comprar / aceptar)

El enfoque es **visual, intuitivo y no minimalista**, pero sin saturar la vista.

---

## 🛠️ Tecnologías

### Frontend
- **Flutter**
- **Dart**
- Arquitectura por features

### Estado actual
- Proyecto en fase inicial (UI + estructura)
- Datos simulados (fake data)
- Sin backend integrado aún

---

## 📁 Estructura del proyecto

lib/
│
├── core/
│ ├── theme/
│ ├── widgets/
│ └── utils/
│
├── features/
│ ├── auth/
│ ├── buyer/
│ ├── seller/
│ ├── delivery/
│ ├── fleet/
│ └── admin/
│
└── main.dart


---

## 📍 Alcance inicial (MVP)

- Zona piloto: **Puerto Cabezas (Bilwi)**
- Enfoque inicial:
  - UI sólida
  - Experiencia clara por rol
  - Simulación completa de flujos
- Evolución posterior:
  - Backend
  - Autenticación real
  - Pagos
  - Geolocalización en tiempo real

---

## 📌 Estado del proyecto

🚧 **En desarrollo activo**

Este proyecto está siendo desarrollado por una sola persona, con apoyo de planificación y diseño asistido.

---

## 📄 Licencia

Por definir.

---

## 🤝 Contribuciones

Por ahora el proyecto es privado a nivel de desarrollo.  
Más adelante se definirá si será open-source o de uso comercial.

