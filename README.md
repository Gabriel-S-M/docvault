# DocVault

## Descrição do Projeto

O **DocVault** é uma aplicação web e mobile desenvolvida em Flutter para **visualização e gerenciamento centralizado de documentação pública de empresas**. O sistema permite que empresas cadastradas disponibilizem seus documentos (PDFs) de forma organizada, com controle de acesso por perfil de usuário. Visitantes podem navegar pelo catálogo de empresas e consultar documentos publicamente, enquanto usuários autenticados com papéis específicos podem gerenciar o conteúdo.

---

## Problema

Empresas e organizações frequentemente mantêm sua documentação interna e pública dispersa em diferentes ferramentas (e-mails, drives pessoais, pastas físicas), dificultando o acesso rápido por parte de colaboradores, clientes e partes interessadas. Não existe um ponto centralizado e acessível onde todos possam consultar documentos públicos de forma organizada e confiável.

A necessidade identificada é: **como disponibilizar documentação pública de múltiplas empresas de forma centralizada, segura e acessível, sem exigir login para leitura, mas garantindo controle sobre quem pode publicar ou editar conteúdo?**

---

## Justificativa

A implementação do DocVault se justifica pela crescente demanda por **transparência e acessibilidade à informação institucional**. Com o avanço da digitalização, empresas precisam de soluções modernas para organizar e publicar seus documentos de maneira eficiente.

Os principais benefícios esperados com o sistema são:

- **Acesso democrático:** qualquer pessoa pode consultar a documentação pública sem necessidade de cadastro ou login.
- **Controle granular de permissões:** somente usuários autorizados (gerentes e administradores) podem criar, editar ou excluir documentos.
- **Escalabilidade:** o sistema suporta múltiplas empresas na mesma plataforma, com documentos isolados por organização.
- **Disponibilidade multiplataforma:** funciona como aplicativo web hospedado e como APK Android, garantindo acesso de qualquer dispositivo.
- **Infraestrutura moderna e de baixo custo:** uso de serviços serverless (Firebase e Cloudflare Workers) elimina a necessidade de servidores dedicados.

---

## Tecnologias Utilizadas

| Camada | Tecnologia | Versão |
|---|---|---|
| **Frontend / Mobile** | Flutter (Dart) | SDK ≥ 3.13.2 |
| **Autenticação** | Firebase Authentication | 5.5.1 |
| **Banco de dados** | Cloud Firestore | 5.6.5 |
| **Armazenamento de arquivos** | Cloudflare R2 (via Worker) | — |
| **Backend (API de upload)** | Cloudflare Workers (JavaScript) | — |
| **Hospedagem Web** | Firebase Hosting | — |
| **Fontes** | Google Fonts (Inter, JetBrains Mono) | 8.2.1 |
| **HTTP Client** | package:http | 1.3.0 |
| **Internacionalização** | package:intl (pt_BR) | 0.20.3 |
| **Seleção de arquivo** | package:file_picker | 8.3.7 |
| **Abertura de URLs** | package:url_launcher | 6.3.2 |

---

## Regras de Negócio

### RN01 — Leitura pública sem autenticação
Qualquer usuário (autenticado ou não) pode visualizar a lista de empresas, acessar os documentos de cada empresa e abrir os PDFs associados.

### RN02 — Escrita exige autenticação
Apenas usuários autenticados via Firebase Authentication podem criar, editar ou excluir empresas, documentos e usuários.

### RN03 — Hierarquia de papéis
O sistema possui três papéis de usuário:

| Papel | Descrição | Permissões |
|---|---|---|
| **Super Admin DocVault** | Administrador global da plataforma | Gerencia todas as empresas e todos os usuários |
| **Super Gerente** | Administrador de uma empresa específica | Gerencia documentos e usuários da própria empresa |
| **Gerente** | Usuário operacional de uma empresa | Gerencia apenas os documentos da própria empresa |

### RN04 — Super Admin acessa painel oculto
O login de Super Admin é realizado por meio de um botão discreto na tela inicial, que abre um modal de autenticação separado do login de empresa.

### RN05 — Documentos pertencem a uma empresa
Cada documento está vinculado a exatamente uma empresa. A exclusão de uma empresa implica a exclusão em cascata de todos os seus documentos no Firestore.

### RN06 — Upload de arquivos via Worker autenticado
O envio de PDFs e imagens de thumbnail é realizado exclusivamente pelo Cloudflare Worker (`PUT /upload/{companyId}/{documentId}/{tipo}`), que valida o Firebase ID Token antes de gravar no bucket R2. O app Flutter nunca expõe credenciais do R2.

### RN07 — URLs de arquivo são públicas e cacheadas
Após o upload, o arquivo fica acessível via `GET /files/{companyId}/{documentId}/{tipo}` sem autenticação, com cache de 24 horas (`Cache-Control: public, max-age=86400`).

### RN08 — Limite de tamanho de upload
O Worker rejeita uploads com `Content-Length` superior a **100 MB**.

### RN09 — Tipos de arquivo permitidos
O Worker aceita apenas: `application/pdf`, `image/jpeg`, `image/png`, `image/webp`, `image/gif`, `image/bmp`.

### RN10 — Categorias de documentos predefinidas
Os documentos são classificados nas seguintes categorias: Relatórios, Manuais, Propostas, Contratos, Atas, Políticas.

### RN11 — Visualização de PDF embutida apenas na web
Na versão web, o PDF é renderizado diretamente na interface via `<iframe>`. Na versão Android/desktop, é exibida uma mensagem e o botão "Abrir em nova aba" redireciona ao arquivo.

---

## Casos de Uso

### UC01 — Navegar pelo catálogo de empresas
**Ator:** Visitante (qualquer usuário)  
**Fluxo principal:**
1. O usuário acessa o sistema.
2. O sistema exibe a lista de empresas cadastradas, com nome, segmento e ícone.
3. O usuário pode pesquisar empresas por nome, segmento ou descrição.
4. O usuário seleciona uma empresa para ver seus documentos.

---

### UC02 — Visualizar documentos de uma empresa
**Ator:** Visitante  
**Fluxo principal:**
1. O usuário seleciona uma empresa no catálogo.
2. O sistema exibe os documentos da empresa em grade ou lista.
3. O usuário pode filtrar por categoria e ordenar por data, título, tamanho ou número de páginas.
4. O usuário clica em um documento para abrir o modal de visualização.
5. Na versão web, o PDF é exibido embutido; nas demais plataformas, o botão abre o PDF em nova aba.

---

### UC03 — Login de Gerente/Super Gerente em uma empresa
**Ator:** Gerente, Super Gerente  
**Fluxo principal:**
1. O usuário acessa a página de documentos de uma empresa.
2. O usuário clica no ícone de configurações no cabeçalho.
3. O sistema exibe o modal de login.
4. O usuário informa e-mail e senha.
5. O sistema autentica via Firebase Auth e valida o papel e a empresa do usuário.
6. Se autenticado com sucesso, o painel administrativo da empresa é habilitado.

---

### UC04 — Gerenciar documentos (Gerente / Super Gerente)
**Ator:** Gerente, Super Gerente  
**Pré-condição:** Usuário autenticado em modo administrador da empresa.  
**Fluxo principal:**
1. O usuário acessa o painel de administração da empresa.
2. O sistema lista todos os documentos com ações de editar e excluir.
3. Para **adicionar** um documento: usuário preenche título, categoria, data, autor, número de páginas, faz upload do PDF e da thumbnail; o sistema envia os arquivos ao Cloudflare R2 e salva os metadados no Firestore.
4. Para **editar**: usuário altera os campos desejados e confirma; o sistema atualiza o Firestore.
5. Para **excluir**: o sistema solicita confirmação e remove o documento do Firestore.

---

### UC05 — Gerenciar usuários da empresa (Super Gerente)
**Ator:** Super Gerente  
**Pré-condição:** Usuário autenticado como Super Gerente.  
**Fluxo principal:**
1. O usuário acessa "Gerenciar Usuários" no painel da empresa.
2. O sistema exibe apenas os usuários vinculados à empresa do Super Gerente.
3. O Super Gerente pode criar Gerentes para a empresa, editar dados ou remover usuários.

---

### UC06 — Login de Super Admin DocVault
**Ator:** Super Admin DocVault  
**Fluxo principal:**
1. Na tela inicial, o Super Admin clica no botão discreto de acesso administrativo (ícone de escudo no rodapé).
2. O sistema exibe o modal de login do DocVault Admin.
3. O Super Admin informa e-mail e senha.
4. O sistema autentica e redireciona para o painel global de administração.

---

### UC07 — Gerenciar empresas (Super Admin DocVault)
**Ator:** Super Admin DocVault  
**Pré-condição:** Usuário autenticado como Super Admin.  
**Fluxo principal:**
1. O Super Admin acessa o painel DocVault Admin.
2. O sistema exibe todas as empresas cadastradas.
3. Para **criar**: o Super Admin preenche nome, segmento, descrição, ícone, cor de destaque e dados do administrador da empresa.
4. Para **editar**: o Super Admin altera os campos e confirma.
5. Para **excluir**: o sistema solicita confirmação e remove a empresa e todos os seus documentos do Firestore.

---

### UC08 — Gerenciar todos os usuários (Super Admin DocVault)
**Ator:** Super Admin DocVault  
**Fluxo principal:**
1. O Super Admin acessa "Gerenciar Usuários" no painel global.
2. O sistema exibe todos os usuários do sistema.
3. O Super Admin pode criar, editar ou remover qualquer usuário, de qualquer empresa.

---

## Diagramas

### Diagrama de Arquitetura do Sistema

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENTE (Flutter)                         │
│          Web (Firebase Hosting) / Android (APK)                  │
└──────────────┬──────────────────────────┬───────────────────────┘
               │                          │
               ▼                          ▼
┌──────────────────────┐    ┌─────────────────────────────────────┐
│  Firebase Auth        │    │        Cloudflare Worker            │
│  (Autenticação)       │    │  PUT /upload/{cId}/{dId}/{tipo}     │
│                       │    │  GET /files/{cId}/{dId}/{tipo}      │
└──────────────┬────────┘    └─────────────────┬───────────────────┘
               │                               │
               ▼                               ▼
┌──────────────────────┐    ┌─────────────────────────────────────┐
│   Cloud Firestore    │    │         Cloudflare R2 Bucket        │
│  /companies          │    │      (Armazenamento de PDFs e       │
│    /documents        │    │          Thumbnails)                 │
│  /users              │    └─────────────────────────────────────┘
└──────────────────────┘
```

---

### Diagrama de Fluxo de Navegação

```
                        ┌─────────────────────────────────┐
                        │     CompanySelectionScreen       │
                        │  (Tela Inicial — sem login)      │
                        └──────────┬──────────┬────────────┘
                                   │          │
              Clica numa empresa   │          │  Botão Super Admin
                                   ▼          ▼
                    ┌──────────────────┐  ┌──────────────────────┐
                    │  DocVaultScreen  │  │  DocVaultAdminScreen  │
                    │  (Docs da empresa│  │  (Gestão de empresas) │
                    │   — sem login)   │  └──────────┬────────────┘
                    └───────┬──────────┘             │
                            │                        │  Gerenciar Usuários
                   Login    │                        ▼
                 Gerente /  │            ┌──────────────────────┐
                 Sup.Gerente│            │  UserManagementScreen │
                            ▼            │  (Todos os usuários)  │
                    ┌──────────────┐     └──────────────────────┘
                    │ AdminScreen  │
                    │(Gestão docs) │
                    └──────┬───────┘
                           │  Gerenciar Usuários (Super Gerente)
                           ▼
                  ┌──────────────────────┐
                  │  UserManagementScreen │
                  │  (Usuários da empresa)│
                  └──────────────────────┘
```

---

### Diagrama de Estrutura de Dados (Firestore)

```
Firestore
│
├── companies/                        ← Coleção pública de empresas
│   └── {companyId}/
│       ├── name: string
│       ├── segment: string
│       ├── description: string
│       ├── iconName: string
│       ├── accentColorHex: string
│       ├── adminEmail: string
│       ├── adminName: string
│       └── documents/               ← Subcoleção de documentos
│           └── {documentId}/
│               ├── title: string
│               ├── category: string
│               ├── date: timestamp
│               ├── pages: number
│               ├── size: string
│               ├── author: string
│               ├── thumbnail: string (URL)
│               └── url: string (URL do PDF no R2)
│
└── users/                           ← Coleção privada (auth required)
    └── {uid}/
        ├── name: string
        ├── email: string
        ├── role: string (superAdmin | superGerente | gerente)
        └── companyId: string?
```

---

### Diagrama de Papéis e Permissões

```
                    ┌─────────────────────────┐
                    │   Super Admin DocVault   │
                    │   (role: superAdmin)     │
                    │                          │
                    │  ✔ Criar/editar/excluir  │
                    │    qualquer empresa      │
                    │  ✔ Gerenciar todos os    │
                    │    usuários do sistema   │
                    └────────────┬─────────────┘
                                 │ pode criar
                    ┌────────────▼─────────────┐
                    │      Super Gerente        │
                    │   (role: superGerente)   │
                    │                          │
                    │  ✔ Gerenciar documentos  │
                    │    da própria empresa    │
                    │  ✔ Gerenciar usuários    │
                    │    da própria empresa    │
                    └────────────┬─────────────┘
                                 │ pode criar
                    ┌────────────▼─────────────┐
                    │         Gerente           │
                    │      (role: gerente)      │
                    │                          │
                    │  ✔ Gerenciar documentos  │
                    │    da própria empresa    │
                    │  ✗ Gerenciar usuários    │
                    └──────────────────────────┘
```

---

## Como Executar o Projeto

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.13.2
- [Dart SDK](https://dart.dev/get-dart) ≥ 3.13.2 (incluído no Flutter)
- [Git](https://git-scm.com/)
- Conta no [Firebase](https://firebase.google.com/) com projeto configurado
- Conta na [Cloudflare](https://cloudflare.com/) com R2 habilitado (para funcionalidade de upload)
- [Node.js](https://nodejs.org/) ≥ 18 e [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/) (apenas para deploy do Worker)

> Para executar localmente como **somente leitura**, apenas Flutter e o projeto Firebase já configurado são necessários.

---

### 1. Clonar o repositório

```bash
git clone https://github.com/Gabriel-S-M/docvault.git
cd docvault
```

### 2. Instalar dependências Flutter

```bash
flutter pub get
```

### 3. Configuração do Firebase

O arquivo `lib/firebase_options.dart` já está configurado para o projeto Firebase de produção (`docvault-1436f`). **Nenhuma configuração adicional é necessária para executar a versão de leitura pública.**

> Para criar um ambiente próprio: acesse o [Firebase Console](https://console.firebase.google.com/), crie um projeto, habilite **Authentication (Email/Senha)** e **Cloud Firestore**, depois substitua o arquivo `lib/firebase_options.dart` com as opções do seu projeto usando o FlutterFire CLI (`flutterfire configure`).

---

### 4. Executar na Web (modo debug)

```bash
# Com o Worker de upload configurado:
flutter run -d chrome --dart-define=R2_WORKER_URL=https://docvault-r2.docvault.workers.dev

# Sem upload (somente leitura):
flutter run -d chrome
```

Ou para expor em porta específica:

```bash
flutter run -d web-server --web-port=8080 --dart-define=R2_WORKER_URL=https://docvault-r2.docvault.workers.dev
```

---

### 5. Executar no Android (modo debug)

```bash
# Com dispositivo/emulador conectado:
flutter run -d android --dart-define=R2_WORKER_URL=https://docvault-r2.docvault.workers.dev
```

---

### 6. Instalar o APK Android (para avaliação)

O APK de release já compilado está disponível em:

```
build/app/outputs/flutter-apk/app-release.apk
```

Transfira o arquivo para o dispositivo Android e instale (habilite "Fontes desconhecidas" nas configurações de segurança do aparelho, se necessário).

---

### 7. Build de release (Web)

```bash
flutter build web --dart-define=R2_WORKER_URL=https://docvault-r2.docvault.workers.dev
firebase deploy --only hosting
```

---

### 8. Build de release (Android)

```bash
flutter build apk --release --dart-define=R2_WORKER_URL=https://docvault-r2.docvault.workers.dev
```

O APK gerado estará em `build/app/outputs/flutter-apk/app-release.apk`.

---

### 9. Deploy do Cloudflare Worker (opcional)

O Worker é responsável pelo upload seguro de arquivos para o Cloudflare R2.

```bash
cd cloudflare/worker
npx wrangler login
npx wrangler deploy
```

O Wrangler exibirá a URL do Worker (ex.: `https://docvault-r2.<seu-subdomínio>.workers.dev`). Use essa URL na variável `--dart-define=R2_WORKER_URL=...` ao compilar o Flutter.

---

### Resumo das variáveis de ambiente

| Variável | Onde configurar | Valor padrão |
|---|---|---|
| `R2_WORKER_URL` | `--dart-define` no build/run Flutter | *(vazio — desabilita upload)* |
| `FIREBASE_PROJECT_ID` | `cloudflare/worker/wrangler.jsonc` | `docvault-1436f` |

---

### Estrutura do Projeto

```
docvault/
├── lib/
│   ├── main.dart                    # Ponto de entrada da aplicação
│   ├── firebase_options.dart        # Configurações do Firebase
│   ├── models/
│   │   ├── company_item.dart        # Modelo de empresa
│   │   ├── document_item.dart       # Modelo de documento
│   │   └── user_item.dart           # Modelo de usuário e enum de papéis
│   ├── services/
│   │   ├── auth_service.dart        # Autenticação Firebase
│   │   ├── firestore_service.dart   # CRUD Firestore (empresas, docs, usuários)
│   │   └── document_storage_service.dart  # Upload via Cloudflare Worker
│   ├── screens/
│   │   ├── company_selection_screen.dart  # Tela inicial (catálogo de empresas)
│   │   ├── doc_vault_screen.dart          # Tela de documentos da empresa
│   │   ├── admin_screen.dart              # Painel admin da empresa
│   │   ├── doc_vault_admin_screen.dart    # Painel Super Admin (gestão de empresas)
│   │   └── user_management_screen.dart   # Gestão de usuários
│   ├── widgets/
│   │   ├── app_header.dart                # Cabeçalho com busca
│   │   ├── category_bar.dart              # Barra de filtro por categoria
│   │   ├── document_card.dart             # Card de documento (grade)
│   │   ├── document_list_tile.dart        # Item de documento (lista)
│   │   ├── pdf_modal.dart                 # Modal de visualização de PDF
│   │   ├── pdf_document_view.dart         # Seletor web/stub para PDF
│   │   ├── pdf_document_view_web.dart     # Visualizador PDF (iframe — web)
│   │   ├── pdf_document_view_stub.dart    # Fallback para plataformas não-web
│   │   ├── options_panel.dart             # Painel lateral de opções
│   │   ├── add_doc_modal.dart             # Modal de adição de documento
│   │   ├── edit_doc_modal.dart            # Modal de edição de documento
│   │   ├── admin_card.dart                # Card de administração
│   │   ├── company_form_modal.dart        # Formulário de empresa
│   │   ├── user_form_modal.dart           # Formulário de usuário
│   │   └── doc_vault_login_modal.dart     # Modal de login
│   └── theme/
│       └── app_theme.dart                 # Tema claro/escuro (Material 3)
├── cloudflare/
│   └── worker/
│       ├── src/index.js             # Cloudflare Worker (upload/download R2)
│       └── wrangler.jsonc           # Configuração do Worker
├── android/                         # Configuração Android (ícones, manifesto)
├── web/                             # Assets web (ícones, favicon, index.html)
├── test/                            # Testes de widget
├── firestore.rules                  # Regras de segurança do Firestore
├── firebase.json                    # Configuração de deploy Firebase
└── pubspec.yaml                     # Dependências Flutter/Dart
```

---

### Acesso à Aplicação Hospedada

A versão web do DocVault está disponível em:

**🔗 https://docvault-1436f.web.app**

**Repositório:**

**🔗 https://github.com/Gabriel-S-M/docvault**
