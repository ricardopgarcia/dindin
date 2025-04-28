# 💸 Dindin – App de Gestão Financeira Pessoal

![Xcode](https://img.shields.io/badge/Xcode-15%2B-blue)
![iOS](https://img.shields.io/badge/iOS-15%2B-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

**Dindin** é um aplicativo iOS para controle financeiro pessoal com foco em segurança, simplicidade e funcionalidade offline.  
Desenvolvido em **SwiftUI**, com **persistência segura no Realm** e suporte a **Face ID/Touch ID** via Keychain.

---

## ✨ Funcionalidades

### 🔐 Acesso e Segurança
- Splash screen animada
- Login com e-mail e senha
- Autenticação biométrica: Face ID ou Touch ID
- Sessão persistente (`@AppStorage`)
- Logout com redirecionamento automático
- Criptografia de dados locais com AES-256
- Chave criptográfica gerenciada de forma segura com o Keychain

### 📦 Persistência de Dados
- Banco de dados local usando **Realm**
- Estruturas de dados mockadas para:
  - Contas (corrente, poupança, PJ, etc.)
  - Cartões de crédito
  - Investimentos (CDB, LCI, FII, ações, criptomoedas)
- Sincronização futura planejada com backend (Firebase, AWS ou Supabase)

### 💰 Gestão Financeira
- Tela de **Saldo** (com agrupamento por categoria)
- Visualização de detalhes de contas e investimentos
- Tela "Hoje" mostrando lançamentos diários
- **Relatórios financeiros** com gráficos comparativos (em desenvolvimento)
- Controle de **orçamento** mensal planejado
- Cadastro e edição de contas e investimentos
- Mock de lançamentos financeiros

### 📈 Gráficos e Análises
- Gráficos de investimentos com **Swift Charts**
- Comparações de rentabilidade (em evolução)

### 🧭 Navegação
- Barra inferior (TabBar) com 5 seções:
  - Hoje
  - Saldo
  - Orçamento
  - Relatórios
  - Mais (Configurações e Logout)

---

## 📂 Estrutura de Arquivos

| Arquivo | Função |
|:--------|:------|
| `DindinApp.swift` | Inicialização do app e gestão de sessão |
| `LoginView.swift`, `SignUpView.swift` | Fluxo de autenticação |
| `MainTabView.swift` | Controle da navegação por abas |
| `SaldoView.swift` | Exibição dinâmica de contas e investimentos |
| `HojeView.swift` | Lançamentos financeiros diários |
| `InvestimentoDetailView.swift` | Detalhamento de investimentos individuais |
| `InvestmentChartView.swift`, `InvestmentComparisonChartView.swift`, `InvestmentBarChartView.swift` | Gráficos de investimentos |
| `AddEditAccountView.swift` | Formulário de adição/edição de contas |
| `AccountStore.swift` | Gerenciamento local de contas e investimentos |
| `RemoteAccount.swift`, `RemoteLancamento.swift` | Modelos para dados de APIs futuras |
| `KeychainHelper.swift` | Gerenciamento seguro de chaves no Keychain |
| `AuthManager.swift` | Controle de sessão de usuário |
| `NetworkMonitor.swift` | Verificação de conectividade de rede |

---

## 🔄 Próximas Evoluções

- [ ] Integração completa com API externa para sincronização de dados
- [ ] Relatórios e dashboards detalhados
- [ ] Controle de orçamento com metas
- [ ] Notificações de vencimentos e alertas financeiros
- [ ] Suporte completo a login multi-dispositivo
- [ ] Backup em nuvem (iCloud ou serviço externo)

---

## 📸 Screenshots

| Splash Screen | Tela de Login | Tela "Hoje" | Tela de Saldo |
|:-------------:|:-------------:|:-----------:|:-------------:|
| ![](./screenshots/screenshot_00.jpg) | ![](./screenshots/screenshot_03.jpg) | ![](./screenshots/screenshot_06.jpg) | ![](./screenshots/screenshot_10.jpg) |

| Tela de Orçamento | Tela de Relatórios | Tela de Mais (Configurações) |
|:-----------------:|:------------------:|:---------------------------:|
| ![](./screenshots/screenshot_14.jpg) | ![](./screenshots/screenshot_18.jpg) | ![](./screenshots/screenshot_22.jpg) |


---

## 📥 Instalação

> Requer **Xcode 15** ou superior e iOS **15** ou superior.  
> Em breve: distribuição via TestFlight e App Store.

### Para rodar localmente:
1. Clone este repositório
2. Abra o arquivo `dindin.xcodeproj` no Xcode
3. Compile e execute em um dispositivo físico ou simulador

---

## 🛠 Tecnologias

- **SwiftUI**
- **Realm Database (criptografado)**
- **Keychain Services (segurança de credenciais)**
- **LocalAuthentication Framework**
- **Swift Charts (para relatórios gráficos)**

---

## 📣 Contribuições

Ideias, feedbacks ou sugestões de melhorias são bem-vindos! 🚀  
Abra uma issue ou envie um pull request.

---

## 📄 Licença

Distribuído sob a licença MIT.
