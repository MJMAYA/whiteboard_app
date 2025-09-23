# Pizarra I### � Exportación de Dataset para Machine Learning
- **Captura automática**: Guarda imagen de pizarra + texto de significado real
- **Formato CSV**: Dataset estructurado con timestamp, nombres de archivo y textos
- **Almacenamiento local**: Directorio `E:\temp\whiteboard_dataset`
- **Estructura organizada**: 
  - `whiteboard_dataset.csv` - Archivo principal con metadatos
  - `images/` - Carpeta con imágenes PNG numeradas por timestamp
- **Botón inteligente**: Solo se activa cuando hay dibujo y significado escrito
- **Auto-limpieza**: Limpia la pizarra automáticamente después de guardar exitosamente
- **Contador de muestras**: Muestra número actual de muestras en el dataset

### �📝 Reconocimiento de Texto (OCR) con Doble Textarea
- **Captura de pantalla**: Convierte el contenido de la pizarra en imagen PNG
- **Textarea OCR**: Área dedicada para mostrar el texto reconocido automáticamente
- **Textarea Significado**: Campo editable para escribir el significado real de lo dibujado
- **Gestión independiente**: Cada textarea tiene su propio botón de limpieza
- **Limpieza total**: El botón principal limpia pizarra y ambos textareas
- **Compatibilidad multiplataforma**: 
  - **Web**: Envío directo de bytes via multipart
  - **Desktop/Móvil**: Guardado temporal de archivosva - Whiteboard App

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
1. **Limpiar Pizarra** (🗑️): Borra todos los trazos dibujados y ambos textareas
2. **Monitor de Presión** (👁️): Activa/desactiva indicador de presión en tiempo real
3. **Reconocimiento de Texto** (📝): Ejecuta OCR y muestra resultado en textarea

#### Botón de Dataset:
4. **Guardar en Dataset** (💾): Exporta imagen + significado real al CSV de entrenamiento

### 💻 Interfaz Mejorada con Doble Textarea
- **Área de dibujo expandida**: Ocupa la mayor parte de la pantalla
- **Doble sistema de texto**: 
  - **Textarea OCR**: Solo lectura, muestra texto detectado automáticamente
  - **Textarea Significado**: Campo editable para escribir interpretación personal
- **Textareas responsivos**: 100px de altura cada uno con scroll interno
- **Paleta de colores**: Selector visual mejorado con efectos de selección
- **Organización modular**: Código separado en widgets especializados
- **Limpieza integral**: Un botón limpia todo (dibujo + ambos textos)

## 🏗️ Arquitectura del Proyecto

### Estructura de Archivos
```
lib/
├── main.dart                    # Punto de entrada de la aplicación
├── whiteboard_screen.dart       # Pantalla principal (refactorizada y optimizada)
├── whiteboard_painter.dart      # CustomPainter para renderizado de trazos
├── draw_point.dart              # Modelo para puntos de dibujo
├── widgets/                     # Widgets modulares reutilizables
    ├── ocr_text_display.dart    # Textarea solo lectura para texto OCR
    ├── meaning_text_input.dart  # Campo editable para significado real
    ├── color_palette.dart       # Selector de colores optimizado
    ├── whiteboard_action_buttons.dart # Botones flotantes organizados
    └── dataset_export_button.dart # Botón para exportar al dataset
├── services/                    # Servicios de la aplicación
    └── dataset_exporter.dart    # Manejo de exportación a CSV y archivos
```

### Clases Principales

#### `WhiteboardScreen` (Refactorizada)
- **Arquitectura modular**: Dividida en métodos especializados
- **Estado optimizado**: Variables específicas para texto OCR
- **Handlers especializados**: Métodos dedicados para eventos de puntero
- **UI organizada**: Widgets separados por responsabilidad

#### `DatasetExporter` (Nuevo)
- **Gestión de archivos**: Crea directorios y maneja almacenamiento local
- **Formato CSV**: Estructura de datos compatible con frameworks de ML
- **Nomenclatura única**: Timestamps para evitar colisiones de archivos
- **Escapado CSV**: Manejo correcto de comas y comillas en texto
- **Metadatos completos**: Timestamp, rutas, textos OCR y real

#### `DatasetExportButton` (Nuevo)
- **Interfaz intuitiva**: Botón que muestra estado del dataset
- **Validación inteligente**: Solo se activa con contenido válido
- **Feedback visual**: Animaciones y notificaciones de éxito/error
- **Contador dinámico**: Muestra número actual de muestras
- **Estado de carga**: Indicador visual durante el procesamiento

#### `MeaningTextInput` (Actualizado)
- **Campo de texto editable**: Permite escribir el significado real del dibujo
- **Interfaz interactiva**: Header distintivo con color azul
- **Autoguardado**: Actualiza el estado en tiempo real mientras escribes
- **Botón de limpieza**: Icono X para borrar el contenido individualmente
- **Placeholder inteligente**: Texto de guía cuando está vacío

#### `OcrTextDisplay` (Actualizado)
- **Solo lectura**: Área específica para mostrar texto OCR detectado
- **Interfaz diferenciada**: Header gris para distinguir del campo editable
- **Scroll automático**: Manejo de texto largo
- **Estados visuales**: Diferentes estilos para texto vacío y con contenido
- **Botón de limpieza**: Solo visible cuando hay contenido

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

## 🎯 **Casos de Uso Ampliados**

### 🔬 **Investigación y Desarrollo de IA**
- **Generación de datasets**: Crear conjuntos de datos para entrenar modelos OCR
- **Evaluación de precisión**: Comparar OCR automático vs interpretación humana
- **Análisis de patrones**: Estudiar diferencias entre texto detectado y significado real

### 📚 **Educación y Formación**
- **Práctica de escritura**: Mejorar caligrafía observando resultados de OCR
- **Aprendizaje de IA**: Entender cómo funcionan los sistemas de reconocimiento
- **Creación de contenido**: Generar material educativo con ejemplos reales

### 💼 **Aplicaciones Profesionales**
- **Prototipado de interfaces**: Bocetos con interpretación automática
- **Documentación visual**: Capturar ideas con contexto textual
- **Control de calidad**: Validar sistemas OCR con datos reales

## 🔄 Flujo de Trabajo Completo para Dataset

### 📋 **Proceso de Creación de Dataset:**
1. **Dibujar** → Crear contenido en la pizarra con colores optimizados
2. **OCR (Opcional)** → Ver qué detecta automáticamente el sistema
3. **Escribir significado** → Introducir interpretación real en textarea azul
4. **Exportar** → Botón naranja guarda imagen + texto en CSV
5. **Auto-limpieza** → Sistema limpia automáticamente para próxima muestra

### 📊 **Estructura del Dataset Generado:**
```
E:\temp\whiteboard_dataset\
├── whiteboard_dataset.csv        # Archivo principal
│   ├── timestamp                 # Marca de tiempo ISO8601
│   ├── image_filename            # nombre único del archivo
│   ├── meaning_text              # Texto real escrito por usuario
│   ├── ocr_text                  # Texto detectado por OCR (opcional)
│   └── image_path                # Ruta relativa a la imagen
└── images\
    ├── whiteboard_1695484800000.png
    ├── whiteboard_1695484801000.png
    └── ...
```

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
