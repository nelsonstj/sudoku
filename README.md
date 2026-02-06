# Sudoku - Aplicativo Flutter

Uma aplicação de Sudoku moderna e completa desenvolvida em **Flutter**, com suporte multilíngue, detecção de erros em tempo real e estatísticas detalhadas.

## 📱 Sobre o Projeto

O **Sudoku** é um jogo clássico de puzzle implementado como um aplicativo multiplataforma. O projeto demonstra boas práticas de desenvolvimento Flutter, incluindo gerenciamento de estado avançado, persistência de dados e experiência do usuário otimizada.

### Características Principais

✅ **Grade 9x9 Interativa** - Interface responsiva e intuitiva para jogar Sudoku  
✅ **4 Níveis de Dificuldade** - Fácil, Médio, Difícil e Especial  
✅ **20 Pacotes de Jogos** - 200 puzzles diferentes (10 jogos por pacote)  
✅ **Detecção de Erros em Tempo Real** - Identifique conflitos automaticamente  
✅ **Sistema de Dicas** - Obtenha sugestões para o próximo número  
✅ **Resolução Automática** - Resolver próxima célula ou jogo completo  
✅ **Destaque de Linha/Coluna** - Opção configurável para facilitar o jogo  
✅ **Tema Claro/Escuro** - Suporte completo a modo escuro do sistema  
✅ **Multilíngue** - Suporte para Português (BR) e Inglês  
✅ **Estatísticas Detalhadas** - Acompanhe seu progresso por nível de dificuldade  
✅ **Persistência de Dados** - Seus jogos são salvos automaticamente  
✅ **Undo/Redo** - Desfaça suas ações com limite configurável  

## 🛠️ Requisitos

- **Flutter**: 3.0.0 ou superior
- **Dart**: 2.18.0 ou superior
- **Android**: API 21+
- **iOS**: 11.0+
- **Windows/macOS/Linux**: Via Flutter desktop

## 📦 Dependências Principais

```yaml
flutter_riverpod: ^2.2.0      # Gerenciamento de estado
shared_preferences: ^2.1.0    # Persistência de dados local
flutter_localizations: sdk    # Suporte a múltiplos idiomas
intl: ^0.20.2                 # Internacionalização
flutter_svg: ^2.0.0           # Exibição de ícones SVG
package_info_plus: ^4.0.0     # Informações do aplicativo
share_plus: ^12.0.0           # Compartilhamento de conteúdo
```

## 🚀 Como Executar

### 1. Instalação das Dependências
```bash
cd sudoku
flutter pub get
```

### 2. Gerar Arquivos de Localização
```bash
flutter gen-l10n
```

### 3. Executar o Aplicativo

**Na Web (Chrome):**
```bash
flutter run -d chrome
```

**Em Dispositivo Android:**
```bash
flutter run -d android
```

**Em Simulador iOS:**
```bash
flutter run -d ios
```

**Desktop (Windows/macOS/Linux):**
```bash
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

## 🏗️ Estrutura do Projeto

```
lib/
├── main.dart                  # Ponto de entrada da aplicação
├── app.dart                   # Configuração da aplicação
├── core/                      # Funcionalidades principais
├── models/                    # Modelos de dados
│   ├── sudoku_puzzle.dart
│   ├── game_progress.dart
│   └── ...
├── providers/                 # Gerenciamento de estado (Riverpod)
│   ├── sudoku_provider.dart
│   ├── settings_provider.dart
│   └── ...
├── services/                  # Serviços e lógica de negócio
│   ├── persistence_service.dart
│   ├── statistics_service.dart
│   └── ...
├── ui/
│   ├── pages/                # Páginas da aplicação
│   │   ├── sudoku_home_page.dart
│   │   ├── sudoku_main_menu_page.dart
│   │   ├── settings_page.dart
│   │   ├── sudoku_statistics_page.dart
│   │   └── ...
│   └── widgets/              # Componentes reutilizáveis
│       ├── sudoku_grid.dart
│       ├── number_pad.dart
│       └── ...
└── l10n/                      # Arquivos de localização
    ├── app_pt.arb
    ├── app_en.arb
    └── ...
```

## 📝 Funcionalidades Detalhadas

### 🎮 Gameplay
- **Seleção de Células**: Toque para selecionar e preencher números
- **Pad Numérico**: Interface intuitiva para entrada de números
- **Validação em Tempo Real**: Detecte conflitos enquanto joga
- **Histórico de Movimentos**: Desfaça e refaça ações (até 200 operações)

### 🎯 Recursos Avançados
- **Sistema de Dicas**: Sugestões inteligentes para próximas células
- **Resolução Automática**: Resova a próxima célula ou o jogo completo
- **Detecção de Erros**: Identifique números duplicados em linhas/colunas
- **Correção Automática**: Corrija automaticamente inconsistências

### 📊 Estatísticas
- Progresso agregado por nível de dificuldade
- Contagem de pacotes e jogos completos
- Tempo total jogado por nível
- Última data de jogada

### ⚙️ Configurações
- **Idioma**: Português (BR) ou Inglês
- **Tema**: Claro, Escuro ou Automático (Sistema)
- **Tamanho de Números**: Aumentar ou manter tamanho padrão
- **Destaque de Linha/Coluna**: Ativar/desativar destaque
- **Verificação de Erros em Tempo Real**: Automática ou manual
- **Limite de Desfazer**: 5 a 200 operações

## 🔨 Build e Distribuição

### Build APK para Android
```bash
flutter build apk --release --obfuscate --split-debug-info=./symbols
```

### Build App Bundle para Android
```bash
flutter build appbundle --release --obfuscate --split-debug-info=./symbols
```

### Build Web
```bash
flutter build web --release
```

## 🌍 Suporte a Idiomas

- **Português (Brasil)** - Idioma padrão
- **Inglês** - Inglês americano

Novos idiomas podem ser adicionados facilmente através dos arquivos `.arb` na pasta `lib/l10n/`.

## 📈 Versão

**Versão Atual**: 1.0.1  
**Status**: Estável e pronto para produção

## 👨‍💻 Arquitetura

### Padrões de Design

- **MVVM** - Model-View-ViewModel com Riverpod
- **Riverpod** - Gerenciamento de estado reativo
- **Repository Pattern** - Isolamento de acesso a dados
- **Separation of Concerns** - Separação de responsabilidades

### Segurança
- Ofuscação de código em builds release
- Símbolos de debug separados
- Dados persistidos localmente (sem conexão com servidor)

## 🧪 Testes

Para executar análise de linting:
```bash
flutter analyze
```

## 📄 Licença

Este projeto é fornecido como está. Sinta-se livre para usar e modificar conforme necessário.

## 👤 Desenvolvedor

Desenvolvido por **KN - Nelson Sturaro Junior (nelsonstj)** - Fevereiro de 2026

## 🐛 Relato de Bugs

Para reportar bugs ou sugerir melhorias, entre em contato com o desenvolvedor.

---

**Divirta-se jogando Sudoku!** 🎮✨
