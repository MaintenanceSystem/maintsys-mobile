# 🔧 MaintenanceSystem - Mobile (Flutter)

Aplicação mobile nativa para **gerenciamento e acompanhamento de manutenção de máquinas industriais** em tempo real. Desenvolvida com **Flutter**, permite que operadores, técnicos, gerentes e administradores monitorem máquinas, criem requisições de manutenção, agendem serviços e gerem relatórios de performance.

---

## 📋 Visão Geral

O **MaintenanceSystem Mobile** é a camada mobile da plataforma MaintenanceSystem, uma solução completa para gestão de manutenção preventiva e corretiva.

### Principais Funcionalidades

| Feature | Descrição | Acesso |
|---------|-----------|--------|
| **Login** | Autenticação segura via token Bearer | Público |
| **Dashboard** | Visão geral com alertas ativos e resumo de máquinas | Todos os usuários |
| **Detalhes da Máquina** | Informações técnicas, status e localização visual (floor plan) | Operador+ |
| **Requisições** | Criar, visualizar e atualizar requisições de manutenção com logs | Técnico+ |
| **Agendamento** | Visualizar calendário de manutenções programadas | Gerente+ |
| **Relatórios** | Gráficos de performance, downtime e análise de dados | Gerente+ |
| **Gerenciamento de Usuários** | Listagem e edição de usuários com atribuição de roles | Admin |

### Tecnologia Stack

- **Framework:** Flutter 3.11.3+
- **Linguagem:** Dart 3.11.3+
- **Navegação:** GoRouter (Navigator 2.0)
- **Autenticação:** Token Bearer + Secure Storage
- **HTTP Client:** Dio / http package
- **State Management:** Provider / GetX (a definir)
- **Backend API:** Laravel (maintsys-api)

---

## ⚙️ Pré-requisitos

Antes de começar, certifique-se de ter instalado em sua máquina:

### Sistema Operacional
- **Windows 10+**, **macOS 10.15+** ou **Linux** (Ubuntu 16.04+)

### Ferramentas Obrigatórias

1. **Flutter SDK**
   - Versão mínima: **3.11.3**
   - [Download Flutter](https://flutter.dev/docs/get-started/install)
   - Verificar instalação:
     ```bash
     flutter --version
     flutter doctor
     ```

2. **Dart SDK**
   - Incluído automaticamente no Flutter SDK
   - Verificar: `dart --version`

3. **Git**
   - [Download Git](https://git-scm.com/downloads)
   - Verificar: `git --version`

### Dependências por Plataforma

#### 📱 Para Android
- **Android Studio** (recomendado) ou **Visual Studio Code** com extensão Flutter
- **Android SDK API 21+** (mínimo)
- **Java Development Kit (JDK) 11+**
- **Emulador Android** OU dispositivo Android conectado

Verificar setup Android:
```bash
flutter config --android-studio-path="/path/to/android/studio"
flutter doctor -v
```

#### 🍎 Para iOS (apenas em macOS)
- **Xcode 13+**
- **CocoaPods**
- **iOS 12.0+** como alvo mínimo
- **Dispositivo iOS ou Simulador**

Verificar setup iOS:
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
flutter doctor -v
```

#### 🌐 Para Web (opcional)
- Chrome, Firefox ou Edge instalado
- Suporte automático no Flutter

---

## 🚀 Instalação e Configuração

### Passo 1: Clonar o Repositório

```bash
# Clonar o repositório do projeto mobile
git clone https://github.com/MaintenanceSystem/maintsys-mobile.git

# Entrar no diretório
cd maintsys-mobile
```

### Passo 2: Instalar Dependências do Flutter

```bash
# Buscar as dependências definidas no pubspec.yaml
flutter pub get

# (Opcional) Gerar arquivos necessários
flutter pub get --offline
```

### Passo 3: Verificar Ambiente

```bash
# Diagnóstico completo do ambiente Flutter
flutter doctor

# Verificar dependências do projeto
flutter pub outdated
```

**Saída esperada do `flutter doctor`:**
```
[✓] Flutter (Channel stable, 3.11.3+, on Linux)
[✓] Android toolchain
[✓] iOS toolchain (ou [!] se não estiver em macOS)
[✓] Web development build files
[✓] Chrome - develop for the web
[✓] Android Studio
[✓] VS Code with Flutter extension
```

### Passo 4: Configurar Variáveis de Ambiente (Opcional)

Se o Flutter não estiver no PATH do sistema:

**Windows (Command Prompt):**
```cmd
setx FLUTTER_HOME C:\caminho\para\flutter
setx PATH %PATH%;%FLUTTER_HOME%\bin
```

**macOS/Linux (bash):**
```bash
export FLUTTER_HOME=~/path/to/flutter
export PATH="$FLUTTER_HOME/bin:$PATH"
```

### Passo 5: Configurar Arquivo `.env` (se aplicável)

Crie um arquivo `.env` na raiz do projeto com as variáveis necessárias:

```env
# URLs da API
API_BASE_URL=http://192.168.1.100:8000/api
API_TIMEOUT=30

# Configurações de Log
LOG_LEVEL=debug

# Recursos do Figma (para design)
FIGMA_API_KEY=seu_figma_key_aqui
```

---

## 📱 Executar o Aplicativo

### Modo Debug (Desenvolvimento)

#### No Emulador/Simulador Android
```bash
# Iniciar emulador Android (a partir do Android Studio)
# Ou conectar dispositivo USB e executar:
flutter run

# Com mais detalhes
flutter run -v

# Selecionar emulador específico
flutter run -d <device_id>
```

#### No Simulador iOS (macOS)
```bash
# Abrir simulador
open -a Simulator

# Executar app
flutter run
```

#### Na Web
```bash
flutter run -d chrome
```

#### Em Dispositivo Android Físico
1. Ativar **Modo de Desenvolvedor** no dispositivo
2. Ativar **Depuração USB**
3. Conectar via cabo USB
4. Executar:
   ```bash
   flutter devices  # Listar dispositivos conectados
   flutter run
   ```

### Modo Release (Produção)

#### APK para Android
```bash
# Build release APK
flutter build apk --release

# Arquivo gerado em: build/app/outputs/flutter-app.apk
```

#### AAB para Google Play
```bash
flutter build appbundle --release

# Arquivo gerado em: build/app/outputs/bundle/release/app-release.aab
```

#### IPA para iOS
```bash
flutter build ios --release

# Será necessário assinar com certificado Apple
```

### Hot Reload (Durante Desenvolvimento)

```bash
flutter run

# No terminal, pressione:
# r - Hot reload (recarrega código sem perder estado)
# R - Hot restart (reinicia completamente)
# q - Sair
```

---

## 📁 Estrutura do Projeto

```
maintsys-mobile/
├── lib/                              # Código-fonte principal (Dart)
│   ├── main.dart                    # Entry point da aplicação
│   ├── app/
│   │   ├── routes/                  # Configuração de rotas (GoRouter)
│   │   │   └── app_routes.dart
│   │   ├── theme/                   # Tema visual e estilos
│   │   │   └── app_theme.dart
│   │   └── app.dart                 # Widget raiz da aplicação
│   ├── features/                    # Funcionalidades organizadas por feature
│   │   ├── auth/
│   │   │   ├── presentation/        # UI (screens, widgets)
│   │   │   ├── data/                # API calls, repositories
│   │   │   └── domain/              # Models, use cases
│   │   ├── dashboard/
│   │   ├── machines/
│   │   ├── requests/
│   │   ├── schedule/
│   │   ├── reports/
│   │   └── users/
│   ├── shared/                      # Código compartilhado
│   │   ├── models/                  # Models genéricos
│   │   ├── services/                # Services (HTTP, storage)
│   │   ├── widgets/                 # Widgets reutilizáveis
│   │   └── constants/               # Constantes da app
│   └── config/                      # Configurações globais
│
├── android/                         # Código nativo Android (Kotlin/Java)
├── ios/                             # Código nativo iOS (Swift/Objective-C)
├── web/                             # Código para build web
├── test/                            # Testes unitários
├── pubspec.yaml                     # Dependências e metadados do projeto
├── pubspec.lock                     # Lock file das dependências
├── analysis_options.yaml            # Regras de lint do Dart
└── README.md                        # Este arquivo

```

### Padrão de Organização por Feature

Cada feature segue a arquitetura **Clean Architecture**:

```
features/auth/
├── presentation/                # UI Layer
│   ├── pages/
│   │   └── login_page.dart
│   ├── widgets/
│   └── controllers/
├── data/                        # Data Layer
│   ├── datasources/
│   ├── repositories/
│   └── models/
└── domain/                      # Domain Layer
    ├── entities/
    ├── repositories/
    └── usecases/
```

---

## 🔐 Autenticação e Configuração da API

### Fluxo de Autenticação

1. **Login:** Usuário fornece credenciais
2. **Resposta API:** Recebe `token` de acesso
3. **Armazenamento Seguro:** Token salvo em secure storage
4. **Requisições Subsequentes:** Token incluído no header `Authorization`


### Arquitetura de Navegação

- **Navigator:** GoRouter com guards baseado em role
- **Bottom Navigation:** Dashboard, Requests, Schedule
- **Drawer/Menu:** Reports, Users (apenas para roles elevados)
- **Deep Linking:** URLs profundas suportadas

---

## 📦 Dependências Principais

O projeto utiliza as seguintes dependências (confira `pubspec.yaml`):

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Será adicionado conforme necessário:
  # - dio ou http (requisições HTTP)
  # - go_router (navegação)
  # - provider ou getx (state management)
  # - flutter_secure_storage (armazenamento seguro)
  # - fl_chart (gráficos)
  # - intl (internacionalização)
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

### Adicionar Nova Dependência

```bash
# Adicionar package
flutter pub add nome_do_package

# Ou editar pubspec.yaml manualmente e executar
flutter pub get
```

---

## 🧪 Testes

### Executar Testes Unitários

```bash
# Todos os testes
flutter test

# Teste específico
flutter test test/features/auth/auth_test.dart

# Com cobertura
flutter test --coverage

# Gerar relatório de cobertura
genhtml coverage/lcov.info -o coverage/report
```

### Estrutura de Testes

```
test/
├── features/
│   ├── auth/
│   │   ├── auth_test.dart
│   │   └── login_test.dart
│   └── dashboard/
└── shared/
```

---

## 🐛 Troubleshooting

### Problema: "Dependências desatualizadas"
```bash
# Atualizar todas as dependências
flutter pub upgrade

# Limpar cache e reinstalar
flutter clean
flutter pub get
```

### Problema: "Emulador não inicia"
```bash
# Listar emuladores disponíveis
flutter emulators

# Iniciar emulador específico
flutter emulators --launch <emulator_id>
```

### Problema: "Erro ao conectar com API"
- Verificar se a URL da API está correta em `.env`
- Confirmar que a API está rodando: `curl http://sua-api.com/api/health`
- Em localhost: usar IP da máquina, não `localhost` (emulador não acessa)
- Verificar firewall e permissões de rede

### Problema: "Build falha no iOS"
```bash
# Limpar Xcode cache
rm -rf ios/Pods ios/Podfile.lock
flutter clean

# Reinstalar
flutter pub get
flutter run
```

### Problema: "Erro de assinatura no Android"
```bash
# Verificar certificados
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey

# Regenerar chave de debug
keytool -genkey -v -keystore ~/.android/debug.keystore \
  -storepass android -alias androiddebugkey -keypass android \
  -keyalg RSA -keysize 2048 -validity 10000
```

---

## 📱 Requisitos Mínimos do Dispositivo

| Requisito | Mínimo | Recomendado |
|-----------|--------|-------------|
| **Android** | 5.0 (API 21) | 8.0+ (API 26+) |
| **iOS** | 12.0 | 14.0+ |
| **RAM** | 2GB | 4GB+ |
| **Armazenamento** | 100MB | 200MB+ |
| **Tela** | 4.5" | 5.5"+ |

---

## 🔄 CI/CD e Deploy

### Build Automático

```bash
# Build APK release
flutter build apk --release --split-per-abi

# Build AppBundle (Google Play Store)
flutter build appbundle --release

# Build iOS
flutter build ios --release
```

### Assinatura de APK

```bash
# Criar chave
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Assinar APK
jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 \
  -keystore ~/upload-keystore.jks \
  build/app/outputs/apk/release/app-release.apk upload
```

---

## 📚 Documentação Adicional

### Referências do Projeto
- **Design:** [Figma - MaintenanceSystem](https://figma.com/design/CwA5oerq1iySYBkDdsWGLk)
- **API Docs:** Consulte o repositório `maintsys-api`
- **Banco de Dados:** Consulte o repositório `maintsys-obsidian`

### Documentação Oficial
- [Flutter Docs](https://flutter.dev/docs)
- [Dart Docs](https://dart.dev/guides)
- [GoRouter](https://pub.dev/packages/go_router)
- [Material Design 3](https://m3.material.io/)

### Arquivos de Configuração Lokais
- `analysis_options.yaml` - Regras de lint
- `pubspec.yaml` - Dependências e metadados
- `.env` - Variáveis de ambiente (se aplicável)

---

## 🤝 Contribuição

### Setup para Desenvolvimento

```bash
# 1. Fork e clonar
git clone https://github.com/seu-usuario/maintsys-mobile.git
cd maintsys-mobile

# 2. Criar branch
git checkout -b feature/sua-feature

# 3. Instalar dependências
flutter pub get

# 4. Fazer alterações e testar
flutter test
flutter run

# 5. Commit e push
git add .
git commit -m "feat: descrição da mudança"
git push origin feature/sua-feature

# 6. Abrir Pull Request
```

### Padrões de Código

- Usar **Flutter lints** (configured em `analysis_options.yaml`)
- Seguir **clean architecture**
- Nomes descritivos para variáveis e funções
- Comentar código complexo
- Testes para novas funcionalidades

---

## 📝 Licença

Este projeto é parte da **MaintenanceSystem** e segue a licença definida pela organização.

---

## 👨‍💻 Suporte e Contato

Para dúvidas, problemas ou sugestões:

1. **Issues:** Abra uma issue no GitHub
2. **Discussions:** Use discussions da organização
3. **Email:** Entre em contato com o time de desenvolvimento

---

## 🎯 Próximas Etapas

Após configurar o projeto com sucesso:

1. ✅ Verificar que `flutter doctor` retorna todos os [✓]
2. ✅ Executar `flutter run` em um emulador/dispositivo
3. ✅ Fazer login com credenciais de teste
4. ✅ Explorar as telas principais
5. ✅ Revisar a estrutura do código em `/lib`
6. ✅ Ler documentação da API em `maintsys-api`

---

**Última atualização:** Maio 2026  
**Versão Flutter:** 3.11.3+  
**Mantido por:** MaintenanceSystem Team