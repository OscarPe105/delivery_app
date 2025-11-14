#!/usr/bin/env python3
"""
Script para configurar Firebase en el proyecto
"""
import os
import subprocess
import sys

def print_step(step, description):
    print(f"\n{'='*50}")
    print(f"PASO {step}: {description}")
    print('='*50)

def run_command(command, description):
    print(f"\n🔧 {description}")
    print(f"Comando: {command}")
    try:
        result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        print(f"✅ {description} - Exitoso")
        if result.stdout:
            print(f"Salida: {result.stdout}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ {description} - Error")
        print(f"Error: {e.stderr}")
        return False

def check_file_exists(file_path, description):
    if os.path.exists(file_path):
        print(f"✅ {description} - Encontrado")
        return True
    else:
        print(f"❌ {description} - No encontrado")
        return False

def main():
    print("🔥 CONFIGURACIÓN DE FIREBASE PARA DELIVERY APP")
    print("="*60)
    
    # Paso 1: Verificar archivos de configuración
    print_step(1, "Verificando archivos de configuración Firebase")
    
    android_config = check_file_exists("android/app/google-services.json", "google-services.json (Android)")
    ios_config = check_file_exists("ios/Runner/GoogleService-Info.plist", "GoogleService-Info.plist (iOS)")
    firebase_options = check_file_exists("lib/firebase_options.dart", "firebase_options.dart (Flutter)")
    
    if not android_config:
        print("❌ Archivo google-services.json no encontrado")
        print("   Descárgalo desde Firebase Console y colócalo en android/app/")
        return False
    
    if not ios_config:
        print("⚠️  Archivo GoogleService-Info.plist no encontrado")
        print("   Descárgalo desde Firebase Console y colócalo en ios/Runner/")
    
    if not firebase_options:
        print("❌ Archivo firebase_options.dart no encontrado")
        print("   Ejecuta: flutterfire configure")
        return False
    
    # Paso 2: Instalar dependencias Flutter
    print_step(2, "Instalando dependencias Flutter")
    if not run_command("flutter pub get", "Instalando dependencias Flutter"):
        return False
    
    # Paso 3: Verificar configuración Android
    print_step(3, "Verificando configuración Android")
    
    # Verificar que el plugin de Google Services esté en build.gradle
    android_build_gradle = "android/app/build.gradle.kts"
    if os.path.exists(android_build_gradle):
        with open(android_build_gradle, 'r') as f:
            content = f.read()
            if "com.google.gms.google-services" in content:
                print("✅ Plugin Google Services configurado en Android")
            else:
                print("❌ Plugin Google Services no encontrado en Android")
                return False
    
    # Paso 4: Verificar configuración iOS
    print_step(4, "Verificando configuración iOS")
    
    if ios_config:
        print("✅ Configuración iOS encontrada")
    else:
        print("⚠️  Configuración iOS no encontrada - Solo Android funcionará")
    
    # Paso 5: Verificación final
    print_step(5, "Verificación final")
    
    print("\n📋 RESUMEN DE CONFIGURACIÓN:")
    print("✅ Android: google-services.json configurado")
    print("✅ Flutter: firebase_options.dart configurado")
    print("✅ Dependencias: Instaladas")
    
    print("\n🚀 PRÓXIMOS PASOS:")
    print("1. Configura Firebase Console:")
    print("   - Habilita Authentication (Email/Password)")
    print("   - Habilita Firestore Database")
    print("   - Habilita Firebase Storage")
    print("   - Habilita Cloud Messaging")
    
    print("\n2. Ejecuta la aplicación con `flutter run` en el dispositivo deseado.")
    print("3. Para web, recuerda ejecutar `flutter run -d chrome --web-port 5000` si aplicaste reglas CORS específicas.")
    
    print("\n🔥 ¡Firebase configurado exitosamente!")
    return True

if __name__ == "__main__":
    success = main()
    if not success:
        sys.exit(1)
