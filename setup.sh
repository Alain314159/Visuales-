#!/bin/bash

# ============================================
# Script de Setup - Visuales UCLV
# ============================================
# Este script configura el entorno de desarrollo
# ============================================

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Start
print_header "🚀 Setup de Visuales UCLV"

# Step 1: Check Flutter
print_header "1️⃣ Verificando Flutter"
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version --short 2>&1 | head -n 1)
    print_success "Flutter encontrado: $FLUTTER_VERSION"
else
    print_error "Flutter no encontrado"
    print_warning "Instala Flutter desde: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Step 2: Install dependencies
print_header "2️⃣ Instalando dependencias"
flutter pub get
if [ $? -eq 0 ]; then
    print_success "Dependencias instaladas"
else
    print_error "Error al instalar dependencias"
    exit 1
fi

# Step 3: Setup .env
print_header "3️⃣ Configurando variables de entorno"
if [ -f ".env" ]; then
    print_warning ".env ya existe, saltando..."
else
    if [ -f ".env.example" ]; then
        cp .env.example .env
        print_success ".env creado desde .env.example"
        print_warning "Edita .env con tu configuración"
    else
        print_error ".env.example no encontrado"
        exit 1
    fi
fi

# Step 4: Setup Firebase
print_header "4️⃣ Configurando Firebase"
if [ -f "android/app/google-services.json" ]; then
    print_warning "google-services.json ya existe, saltando..."
else
    print_warning "google-services.json no encontrado"
    print_warning ""
    print_warning "Para configurar Firebase:"
    print_warning "1. Ve a https://console.firebase.google.com/"
    print_warning "2. Crea un proyecto o selecciona uno existente"
    print_warning "3. Agrega una app Android con package: com.visuales.uclv"
    print_warning "4. Descarga google-services.json"
    print_warning "5. Colócalo en: android/app/google-services.json"
    print_warning ""
    print_warning "O usa el placeholder: android/app/google-services.json.placeholder"
fi

# Step 5: Run build_runner (if needed)
print_header "5️⃣ Generando código (Hive adapters)"
# Nota: Hive no requiere build_runner en esta versión
print_success "No se requiere build_runner para esta configuración"

# Step 6: Verify setup
print_header "6️⃣ Verificando configuración"

# Check pubspec.yaml
if grep -q "hive:" pubspec.yaml; then
    print_success "Hive configurado"
else
    print_error "Hive no encontrado en pubspec.yaml"
fi

if grep -q "flutter_dotenv:" pubspec.yaml; then
    print_success "flutter_dotenv configurado"
else
    print_error "flutter_dotenv no encontrado en pubspec.yaml"
fi

if grep -q "firebase_crashlytics:" pubspec.yaml; then
    print_success "Firebase Crashlytics configurado"
else
    print_warning "Firebase Crashlytics no encontrado en pubspec.yaml"
fi

# Check .env
if [ -f ".env" ]; then
    print_success ".env existe"
else
    print_error ".env no existe"
fi

# Step 7: Final instructions
print_header "✅ Setup Completado"

echo -e "${GREEN}"
echo "┌─────────────────────────────────────────────────┐"
echo "│  🎉 Setup completado exitosamente              │"
echo "└─────────────────────────────────────────────────┘"
echo -e "${NC}"

echo ""
echo "📋 Próximos pasos:"
echo ""
echo "1. Configura Firebase (si aún no lo has hecho):"
echo "   - Revisa FIREBASE_SETUP.md"
echo ""
echo "2. Edita .env con tu configuración:"
echo "   - VISUALES_BASE_URL"
echo "   - Otras variables de entorno"
echo ""
echo "3. Ejecuta la app:"
echo "   flutter run"
echo ""
echo "4. Para builds de producción:"
echo "   flutter build apk --release"
echo ""
echo "📚 Documentación adicional:"
echo "   - IMPLEMENTATION_GUIDE.md"
echo "   - FIREBASE_SETUP.md"
echo "   - README.md"
echo ""

# Exit
exit 0
