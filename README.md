# Pizarra Interactiva - Whiteboard App

Una aplicación de pizarra digital inteligente desarrollada con Flutter que permite dibujar, detectar formas geométricas y reconocer texto manuscrito usando tecnologías de visión por computadora y OCR.

## ✨ Características Principales

### 🎨 Dibujo Libre
- **Dibujo con sensibilidad a la presión**: El grosor del trazo se ajusta automáticamente según la presión aplicada (2.0 - 8.0 píxeles)
- **Paleta de colores optimizada para OCR**: 5 colores de alta legibilidad (negro, azul oscuro, rojo oscuro, verde oscuro, índigo)
- **Interfaz modular**: Componentes organizados en widgets reutilizables

### � Reconocimiento de Texto (OCR) con Textarea
- **Captura de pantalla**: Convierte el contenido de la pizarra en imagen PNG
- **Textarea integrado**: Área dedicada en la parte inferior para mostrar el texto reconocido
- **Gestión de texto**: Botón para limpiar el contenido del textarea
- **Feedback visual**: Mensajes de estado para indicar el progreso del OCR
- **Compatibilidad multiplataforma**: 
  - **Web**: Envío directo de bytes via multipart
  - **Desktop/Móvil**: Guardado temporal de archivos

### 🛠️ Herramientas de Control

#### Botones Flotantes Organizados:
1. **Limpiar Pizarra** (🗑️): Borra todos los trazos dibujados
2. **Monitor de Presión** (👁️): Activa/desactiva indicador de presión en tiempo real
3. **Reconocimiento de Texto** (📝): Ejecuta OCR y muestra resultado en textarea

### 💻 Interfaz Mejorada
- **Área de dibujo expandida**: Ocupa la mayor parte de la pantalla
- **Textarea responsivo**: 120px de altura fija con scroll interno
- **Paleta de colores**: Selector visual mejorado con efectos de selección
- **Organización modular**: Código separado en widgets especializados

## 🏗️ Arquitectura del Proyecto

### Estructura de Archivos
```
lib/
├── main.dart                    # Punto de entrada de la aplicación
├── whiteboard_screen.dart       # Pantalla principal (refactorizada y optimizada)
├── whiteboard_painter.dart      # CustomPainter para renderizado de trazos
├── draw_point.dart              # Modelo para puntos de dibujo
└── widgets/                     # Widgets modulares reutilizables
    ├── ocr_text_display.dart    # Textarea para mostrar texto OCR
    ├── color_palette.dart       # Selector de colores optimizado
    └── whiteboard_action_buttons.dart # Botones flotantes organizados
```

### Clases Principales

#### `WhiteboardScreen` (Refactorizada)
- **Arquitectura modular**: Dividida en métodos especializados
- **Estado optimizado**: Variables específicas para texto OCR
- **Handlers especializados**: Métodos dedicados para eventos de puntero
- **UI organizada**: Widgets separados por responsabilidad

#### `OcrTextDisplay`
- **Textarea dedicado**: Área específica para mostrar texto reconocido
- **Interfaz limpia**: Header con título y botón de limpieza
- **Scroll automático**: Manejo de texto largo
- **Estados visuales**: Diferentes estilos para texto vacío y con contenido

#### `ColorPalette`
- **Selector optimizado**: Paleta de colores específica para OCR
- **Efectos visuales**: Indicación clara de color seleccionado
- **Responsive**: Se adapta al contenido disponible

#### `WhiteboardActionButtons`
- **Botones organizados**: Conjunto de acciones principales
- **Tooltips informativos**: Ayuda contextual para cada acción
- **Temas consistentes**: Colores apropiados para cada función

#### `WhiteboardPainter` (Simplificado)
- **Renderizado puro**: Solo maneja dibujo de trazos
- **Optimizado**: Código limpio sin funcionalidades no utilizadas

## 🔧 Dependencias

### Principales
- `flutter`: Framework de desarrollo
- `http: ^1.5.0`: Cliente HTTP para comunicación con servidor OCR

### Desarrollo
- `flutter_test`: Testing framework
- `flutter_lints: ^6.0.0`: Análisis estático de código

### Adicionales (configuradas pero no utilizadas actualmente)
- `google_ml_kit: ^0.20.0`: Kit de ML de Google
- `tesseract_ocr: ^0.5.0`: Motor OCR Tesseract

## 🚀 Instalación y Configuración

### Prerrequisitos
1. **Flutter SDK** (versión 3.9.2 o superior)
2. **Servidor OCR local** ejecutándose en `localhost:1688/upload`

### Pasos de instalación
```bash
# Clonar el repositorio
git clone <repository-url>
cd whiteboard_app

# Instalar dependencias
flutter pub get

# Ejecutar en el dispositivo deseado
flutter run
```

### Configuración del Servidor OCR
La aplicación espera un servidor HTTP en `localhost:1688` que:
- Acepte POST requests en `/upload`
- Reciba archivos multipart con campo `the_file`
- Retorne JSON con formato: `{"result": "texto_reconocido"}`

## 🎯 Casos de Uso

1. **Educación**: Pizarra digital para clases remotas o presenciales
2. **Diseño**: Bocetos rápidos con detección automática de formas
3. **Notas**: Escritura a mano con conversión a texto digital
4. **Presentaciones**: Herramienta interactiva para explicaciones visuales

## 🔄 Flujo de Trabajo

1. **Dibujo**: El usuario dibuja con el dedo/stylus
2. **Captura**: Sistema captura posición, presión y color
3. **Renderizado**: WhiteboardPainter dibuja trazos en tiempo real
4. **Detección**: Algoritmo analiza trazos para identificar formas
5. **OCR**: Botón de texto convierte dibujos en texto reconocible
6. **Gestión**: Herramientas de limpieza y configuración

## 🌐 Compatibilidad

- ✅ **Android**: Soporte completo con sensibilidad a presión
- ✅ **iOS**: Soporte completo con sensibilidad a presión  
- ✅ **Web**: Funcional, limitaciones en detección de presión
- ✅ **Windows**: Soporte completo
- ✅ **macOS**: Soporte completo
- ✅ **Linux**: Soporte completo

## 🤝 Contribuciones

Este proyecto está abierto a contribuciones. Areas de mejora:
- Detección de más formas geométricas (círculos, triángulos)
- OCR offline integrado
- Guardado/carga de sesiones
- Herramientas de edición avanzadas
- Mejora de precisión en detección de formas

## 📄 Licencia

Ver archivo `LICENSE` para detalles de licencia.

---

*Desarrollado con Flutter - Framework multiplataforma de Google*
