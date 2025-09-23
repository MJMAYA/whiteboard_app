# Pizarra Interactiva - Whiteboard App

Una aplicación de pizarra digital inteligente desarrollada con Flutter que permite dibujar, detectar formas geométricas y reconocer texto manuscrito usando tecnologías de visión por computadora y OCR.

## ✨ Características Principales

### 🎨 Dibujo Libre
- **Dibujo con sensibilidad a la presión**: El grosor del trazo se ajusta automáticamente según la presión aplicada (2.0 - 8.0 píxeles)
- **Paleta de colores**: 10 colores predefinidos disponibles (negro, rojo, verde, azul, naranja, púrpura, marrón, rosa, amarillo, cian)
- **Interfaz intuitiva**: Selector de color circular en la parte inferior de la pantalla

### 🔲 Detección Inteligente de Formas
- **Reconocimiento automático de cuadrados**: El sistema detecta cuadrados dibujados a mano libre
- **Algoritmo de detección**: 
  - Analiza trazos de al menos 20 puntos
  - Verifica proporción cuadrada (diferencia de ancho/alto < 15px)
  - Confirma que el 70% de los puntos estén en el perímetro
  - Tamaño mínimo de 30x30 píxeles
- **Feedback visual**: Notificación "¡Cuadrado detectado!" cuando se identifica una forma
- **Renderizado perfecto**: Los cuadrados detectados se muestran como rectángulos perfectos

### 📝 Reconocimiento de Texto (OCR)
- **Captura de pantalla**: Convierte el contenido de la pizarra en imagen PNG
- **Integración con servicio OCR**: Envía la imagen a un servidor local (localhost:1688)
- **Compatibilidad multiplataforma**: 
  - **Web**: Envío directo de bytes via multipart
  - **Desktop/Móvil**: Guardado temporal de archivos
- **Procesamiento de resultados**: Muestra el texto reconocido en pantalla

### 🛠️ Herramientas de Control

#### Botones Flotantes:
1. **Limpiar Pizarra** (🗑️): Borra todos los trazos y formas detectadas
2. **Monitor de Presión** (👁️): Activa/desactiva indicador de presión en tiempo real
3. **Reconocimiento de Texto** (📝): Ejecuta OCR sobre el contenido actual

### 💻 Indicadores en Pantalla
- **Monitor de presión**: Muestra valor actual de presión (0.00-1.00) en esquina superior derecha
- **Mensajes de estado**: Notificaciones temporales para detección de formas y resultados de OCR
- **Interfaz responsiva**: Se adapta a diferentes tamaños de pantalla

## 🏗️ Arquitectura del Proyecto

### Estructura de Archivos
```
lib/
├── main.dart              # Punto de entrada de la aplicación
├── whiteboard_screen.dart # Pantalla principal con toda la lógica
├── whiteboard_painter.dart# CustomPainter para renderizado de trazos
├── draw_point.dart        # Modelo para puntos de dibujo
└── detected_square.dart   # Modelo para cuadrados detectados
```

### Clases Principales

#### `WhiteboardScreen`
- **Estado**: Maneja puntos de dibujo, cuadrados detectados, color seleccionado
- **Eventos de puntero**: Captura PointerDown, PointerMove, PointerUp
- **Detección de formas**: Algoritmo de análisis geométrico
- **Integración OCR**: Cliente HTTP para servicio de reconocimiento

#### `WhiteboardPainter`
- **Renderizado personalizado**: Dibuja líneas conectadas entre puntos
- **Estilos dinámicos**: Aplica color y grosor específico a cada trazo
- **Formas detectadas**: Renderiza cuadrados perfectos superpuestos

#### `DrawPoint`
- **Propiedades**: Offset (posición), Color, strokeWidth (grosor)
- **Sensibilidad**: Grosor basado en presión del dispositivo de entrada

#### `DetectedSquare`
- **Geometría**: Rect (rectángulo) y Color
- **Renderizado**: Se dibuja como contorno perfecto sobre trazos originales

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
