
# 📋 Nova Feature: Comparação de Rentabilidades

## 🎯 Objetivo:
Permitir ao usuário comparar diferentes investimentos com base em:
- Rentabilidade acumulada
- Rentabilidade anualizada
- Custo efetivo
- Escolher o **melhor investimento** considerando prazos e retornos

---

## 🧠 Funcionalidades principais:

| Item | Descrição |
|:---|:---|
| Entrada de investimentos | Selecionar 2 ou mais investimentos já cadastrados no app |
| Dados usados | Valor investido, Data de início, Valor atual, Data de hoje |
| Cálculo | Rentabilidade bruta, Rentabilidade anualizada |
| Comparativo visual | Mostrar de forma clara quem está performando melhor |
| Escolha rápida | Sugestão de "Melhor escolha" baseada no melhor retorno proporcional |

---

## 🛠️ Cálculos necessários:

**Rentabilidade Bruta (%):**

\[
\text{Rentabilidade Bruta} = \left( \frac{\text{Valor Atual} - \text{Valor Investido}}{\text{Valor Investido}} \right) \times 100
\]

**Rentabilidade Anualizada (%):**

\[
\text{Rentabilidade Anualizada} = \left( (1 + \text{Rentabilidade Bruta})^{\frac{1}{\text{número de anos}}} - 1 \right) \times 100
\]

**Número de anos:**

\[
\text{Anos} = \frac{\text{Dias corridos}}{365}
\]

---

## ✨ Interface sugerida:

| Tela | Ações |
|:---|:---|
| Escolha dos investimentos | Usuário seleciona 2 ou mais investimentos da lista |
| Tela de Comparação | Exibe tabela comparativa: Nome | Rentabilidade (%) | Rentabilidade Anualizada (%) |
| Destaque | Melhor investimento destacado com uma medalha 🥇 |

---

## 📦 Componentes necessários:

- Nova View: `ComparacaoRentabilidadeView.swift`
- Serviço de cálculo: `InvestmentComparisonService.swift` (ou método no `InvestmentStore`)
- Ajuste no banco (opcional): salvar comparações

---

## 📈 Possibilidades Futuras:

- Incluir taxas (IR, IOF) para rentabilidade líquida
- Comparação com benchmark (CDI, IPCA)
- Gráfico de evolução simulada

---

## 🚀 Resumo de plano imediato:

1. Implementar o comparador básico de rentabilidade
2. Interface clean para seleção e comparação
3. Destaque automático do melhor investimento

---

## 📋 Checklist:

- [x] Definir entrada (seleção de investimentos)
- [x] Definir cálculo (bruta e anualizada)
- [ ] Criar nova View
- [ ] Criar serviço de comparação
- [ ] Integrar com navegação do app
