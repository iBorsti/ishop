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

📁 Regla base

Nada global que no sea realmente global.

lib/
│
├── core/                # Cosas reutilizables y globales
│   ├── theme/
│   ├── widgets/
│   ├── utils/
│
├── features/            # Todo vive por feature/rol
│   ├── auth/
│   ├── buyer/
│   ├── seller/
│   ├── delivery/
│   ├── fleet/
│   └── admin/
│
└── main.dart


Esto ya lo estás haciendo bien.

🧩 2. Estructura interna de cada feature

Cada feature sigue la misma regla, aunque no use todo aún.

Ejemplo: features/seller/

seller/
├── screens/         # Pantallas (UI)
├── widgets/         # Widgets solo de seller
├── models/          # Modelos de datos
├── services/        # Lógica (fake ahora, real después)
└── seller_routes.dart (opcional más adelante)


👉 Regla de oro
Un feature NO puede importar widgets de otro feature.
Si algo se comparte → va a core/widgets.

🎨 3. Reglas de UI / Diseño (MUY importantes)

Estas reglas evitan que la app se vea inconsistente.

✅ Sí se permite

Gradientes

Cards grandes

Iconos grandes

Animaciones sutiles

Dashboards visuales

❌ No se permite

Botones sin estilo

Colores hardcodeados en pantallas

Textos sin jerarquía (todo mismo tamaño)

Listas “feas” tipo ListTile por defecto

🎨 Colores (regla estricta)

❌ MAL:

color: Colors.blue


✅ BIEN:

color: AppColors.primaryBlue


Todos los colores:

viven en core/theme/app_colors.dart

gradientes también

📊 4. Dashboards y estadísticas (reglas)

Cada dashboard:

NO calcula datos

Solo consume datos preparados

Por ahora:

Fake data en services/

UI limpia y clara

Ejemplo:

SellerStats stats = SellerStats.fake();

🧠 5. Lógica: qué va dónde
Tipo de lógica	Dónde va
UI	screens/
Widgets reutilizables	core/widgets/
Widgets específicos	feature/widgets/
Datos fake	services/
Modelos	models/
Constantes	core/utils/

❌ Nunca:

Lógica compleja en build()

Calcular totales dentro de widgets

🧪 6. Regla MVP (esto es CLAVE)

Antes de backend, el MVP debe sentirse completo.

MVP incluye:

Flujos completos por rol

Dashboards funcionales (fake)

Navegación sólida

UI casi final

MVP NO incluye:

Autenticación real

Pagos

Google Maps real

Notificaciones push

👉 Esto evita abandonar el proyecto a mitad.

🧭 7. Navegación (regla clara)

Por ahora:

Navigator.push

Rutas directas

Más adelante:

go_router (cuando haya auth real)

No mezclar ambos.

📝 8. Convenciones de código
Archivos

snake_case

claros y largos si hace falta

seller_dashboard_screen.dart
buyer_feed_item_card.dart

Clases

PascalCase

SellerDashboardScreen

Widgets

Un widget = un archivo (si crece)

🔒 9. Control de crecimiento (muy importante)

Si una pantalla:

pasa de 300 líneas → dividir

tiene más de 5 widgets internos → extraer