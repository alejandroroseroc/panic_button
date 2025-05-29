# panic_button

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.






# Panic Button App

App móvil desarrollada en Flutter para disparar alertas (SMS, WhatsApp, llamadas) por distintos métodos (tap, voz, shake), gestionar contactos, plantillas, ver estadísticas y perfil de usuario con foto.



## Contenido

1. [Requisitos](#-requisitos)  
2. [Instalación](#-instalación)  
3. [Configuración de Appwrite](#-configuración-de-appwrite)  
4. [Permisos Android](#-permisos-android)  
5. [Estructura principal](#-estructura-principal)  
6. [Ejecución](#%EF%B8%8F-ejecución)  

---

## 🎯 Requisitos

- Flutter SDK **>= 3.8.0 < 4.0.0**  
- Android Studio / VSCode  
- Un proyecto en Appwrite (v15+) con:
  - Database configurado  
  - Colecciones:
    - `panicButtons`
    - `contacts`
    - `alertLogs`
    - `messageTemplates`
    - (opcional) `profileImages` en Storage  
- Credenciales de Appwrite (endpoint, projectId, databaseId, collectionIds)

---

##  Instalación

1. Clona este repositorio:  
   git clone https://github.com/alejandroroseroc/panic_button.git
   cd panic_button
Instala dependencias:
flutter pub get
Genera los adaptadores Hive (para modelos):
flutter pub run build_runner build --delete-conflicting-outputs


Configuración de Appwrite

Edita en lib/core/constants/appwrite_constants.dart los valores:
class AppwriteConstants {
  static const String endpoint       = 'https://fra.cloud.appwrite.io/v1';
  static const String projectId      = '681038a5000c747072f0';
  static const String databaseId     = '6810393e0000c1471a5d';
  static const String collectionIdPB = '682a969100150e9947eb';  // <- tu colección panicButtons
  static const String collectionIdContacts = '682a97d4000cbae82e11';
  static const String collectionIdAlertLogs = '682a9863002cf9beff76';
  static const String collectionIdmessageTemplates = '6832204b00387e0e2e71';

  
}

Credenciales necesarias
endpoint: URL de tu Appwrite server
projectId: ID de tu proyecto
databaseId: ID de la base de datos
collectionIds: IDs de cada colección

perfil creado:
correo: diegoa@gmail.com 
password: 987654321

Permisos Android

En android/app/src/main/AndroidManifest.xml añade:
<uses-permission android:name="android.permission.SEND_SMS"/>
<uses-permission android:name="android.permission.CALL_PHONE"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>

<queries>
  <intent>
    <action android:name="android.intent.action.SENDTO"/>
    <data android:scheme="sms"/>
  </intent>
  <intent>
    <action android:name="android.intent.action.DIAL"/>
    <data android:scheme="tel"/>
  </intent>
</queries>

Y en android/app/build.gradle, comprueba que tienes:
android {
    compileSdkVersion flutter.compileSdkVersion
    defaultConfig {
        applicationId "com.example.panic_button"
        minSdkVersion flutter.minSdkVersion
        targetSdkVersion flutter.targetSdkVersion
        // ...
    }
    // ...
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
        coreLibraryDesugaringEnabled true
    }
}

dependencies {
    coreLibraryDesugaring "com.android.tools:desugar_jdk_libs:2.0.3"
}




En un emulador o dispositivo Android/iOS:
flutter run
Si necesita limpiar builds previos:
flutter clean
flutter pub get
flutter run

app: iniciar sesión, registrar usuarios, crear botones de pánico, contactos, plantillas, ver tu perfil (con foto), y revisar estadísticas y alertas en el mapa.