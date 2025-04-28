# 🚀 Roteiro de Evolução - Projeto Dindin

## 📌 Contexto Atual

- App Dindin funciona 100% offline-first com banco local Realm criptografado.
- Sincronização com APIs da DinDin ocorre manualmente (pull-to-refresh).
- Sessão de usuário persistente via Keychain e AppStorage.
- App já estruturado para evoluir em sincronização e consumo dinâmico de dados.

---

## 🎯 Próximas Evoluções Estruturadas

### 1. 📋 Melhorar Tela de Saldo (Lista de Contas)
**Objetivo:** Tornar a tela de Saldo mais rica, funcional e sincronizada.

- [ ] Ajustar o `SaldoView` para:
  - [ ] Exibir saldos das contas reais vindas da API `/accounts` + `/transactions`.
  - [ ] Atualizar os dados locais do Realm sempre que sincronizar com API.
  - [ ] Melhorar visual de agrupamento de contas e investimentos.
  - [ ] Exibir saldo consolidado (somatório de contas) atualizado.
- [ ] Implementar `pull-to-refresh` real para buscar as contas no servidor.

### 2. 🔄 Sincronização Automática (Background Refresh)
**Objetivo:** Minimizar esforço manual do usuário.

- [ ] Detectar reconexão de internet (`NetworkMonitor`).
- [ ] Quando a internet voltar, oferecer sincronização automática leve.
- [ ] Atualizar apenas se houver novos dados no servidor.

### 3. 📊 Melhorar Tela de Relatórios
**Objetivo:** Oferecer análises financeiras mais visuais e completas.

- [ ] Usar `/transactions` para consolidar dados de categorias (Rendimentos, Gastos, Investimentos).
- [ ] Implementar gráficos de pizza e linha com **Swift Charts**.

### 4. 🛡️ Melhorias de Segurança
**Objetivo:** Garantir proteção máxima aos dados.

- [ ] Refatorar armazenamento de chave criptográfica no Keychain.
- [ ] Revisar se as instâncias de Realm são sempre abertas com chave válida.

### 5. 🖥️ Tela de Orçamento
**Objetivo:** Permitir planejamento financeiro mensal.

- [ ] Criar tela de orçamento mensal baseado nas categorias de despesas.
- [ ] Permitir definir metas de gasto por categoria.
- [ ] Acompanhar execução em tempo real baseado nos lançamentos do mês.

### 6. ☁️ Backup e Login Multi-Device (Futuro)
**Objetivo:** Evoluir a experiência para multiplataforma.

- [ ] Definir backend de autenticação (Firebase Auth, Cognito, Supabase Auth).
- [ ] Implementar sincronização de contas e dados do Realm para nuvem.

---

## 🛠️ Tecnologias e Práticas Sugeridas

- **Swift Concurrency** (async/await) para consumo das APIs.
- **Swift Charts** para novos gráficos financeiros.
- **Keychain Services** para segurança aprimorada.
- **Combine** (opcional) para atualização reativa de dados.

---

## 📍 Prioridade Inicial Confirmada
**Iniciar pela melhoria da Tela de Saldo e Lista de Contas.**

