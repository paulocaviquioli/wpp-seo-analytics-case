# WPP SEO Analytics Case

Projeto de Analytics Engineering desenvolvido para estruturar uma solução analítica de performance de SEO, integrando dados do Google Analytics 4 (GA4) e Google Search Console (GSC).

O objetivo do projeto é transformar dados brutos de diferentes fontes em uma camada analítica confiável e pronta para consumo, utilizando uma arquitetura em camadas **Bronze → Silver → Gold**, com transformações e testes implementados em **dbt**.

---

## 🎯 Objetivo

Construir uma solução de dados capaz de analisar a performance orgânica de páginas e consultas de busca, permitindo responder perguntas como:

- Quais páginas possuem maior volume de sessões orgânicas?
- Quais páginas geram mais receita e conversões?
- Quais consultas geram mais impressões e cliques?
- Qual é o CTR das páginas e consultas?
- Qual é a posição média nos resultados de busca?
- Como o desempenho varia entre dispositivos?
- Quais páginas possuem boa visibilidade no Google, mas baixo CTR?
- Quais páginas possuem tráfego relevante, mas baixa conversão?

A solução foi estruturada para separar claramente **ingestão, tratamento e consumo analítico dos dados**.

---

## 🏗️ Arquitetura

```text
Google Analytics 4        Google Search Console
        │                           │
        └──────────┬────────────────┘
                   │
                Airbyte
                   │
                   ▼
             Bronze Layer
          Dados brutos ingeridos
                   │
                   ▼
                 dbt
                   │
                   ▼
             Silver Layer
      Limpeza + tipagem + padronização
                   │
                   ▼
              Gold Layer
       Modelos analíticos de negócio
                   │
                   ▼
               Power BI
        Visualização e análise
```

---

## 🧰 Stack utilizada

| Tecnologia | Utilização |
|---|---|
| Google Analytics 4 | Dados de sessões, conversões, receita e engajamento |
| Google Search Console | Dados de queries, cliques, impressões, CTR e posição |
| Airbyte | Ingestão dos dados |
| Supabase / PostgreSQL | Data Warehouse |
| dbt Core | Transformação, modelagem e testes |
| SQL | Desenvolvimento das transformações |
| Git | Versionamento |
| GitHub | Repositório do projeto |
| Power BI | Camada de visualização |

---

# 🥉 Bronze Layer

A camada Bronze representa os dados ingeridos das fontes sem aplicação das regras analíticas do projeto.

As principais fontes utilizadas são:

### GA4 — Sessões orgânicas

Contém informações como:

- data
- página
- dispositivo
- canal
- sessões
- conversões
- receita
- sessões engajadas
- taxa de engajamento
- tempo médio de engajamento

### Google Search Console

Contém informações como:

- data
- página
- query
- dispositivo
- cliques
- impressões
- CTR
- posição média

Os dados ingeridos originalmente possuem diversos campos armazenados como texto, incluindo números, percentuais e datas.

Essa característica é tratada na camada Silver.

---

# 🥈 Silver Layer

A camada Silver é responsável pela limpeza, padronização e tipagem dos dados provenientes da Bronze.

## `ga4__sessoes_organicas`

Modelo responsável pelo tratamento dos dados provenientes do GA4.

Principais transformações:

- conversão de datas para `date`
- conversão de sessões para valores inteiros
- conversão de conversões para valores inteiros
- conversão de receita para valores numéricos
- tratamento de números utilizando vírgula decimal
- transformação da taxa de engajamento de percentual para decimal
- padronização do tempo médio de engajamento
- padronização dos nomes das colunas
- preservação do timestamp de ingestão

Exemplo:

```text
54,92% → 0.549200
144,96 → 144.96
82,2 → 82.20
```

---

## `gsc__search_console`

Modelo responsável pelo tratamento dos dados provenientes do Google Search Console.

Principais transformações:

- conversão da data para `date`
- conversão de cliques para inteiro
- conversão de impressões para inteiro
- transformação do CTR de percentual para decimal
- conversão da posição média para valor numérico
- padronização dos nomes das colunas
- preservação do timestamp de ingestão

Exemplo:

```text
4,14% → 0.041400
6,62 → 6.6200
```

---

# 🥇 Gold Layer

A camada Gold contém modelos preparados para consumo analítico e utilização no Power BI.

Foram desenvolvidos dois grãos diferentes para evitar duplicidade de métricas durante análises.

---

## `seo__page_device_daily`

**Grão:**

```text
data + página + dispositivo
```

Este modelo combina métricas de GA4 e Google Search Console no nível de página e dispositivo.

### Métricas de GA4

- sessões
- conversões
- sessões engajadas
- receita
- taxa de conversão
- receita por sessão
- taxa de engajamento
- tempo médio de engajamento

### Métricas de Search Console

- cliques
- impressões
- CTR
- posição média

### Métricas derivadas

#### Conversion Rate

```text
conversions / sessions
```

#### Revenue per Session

```text
revenue / sessions
```

#### CTR

```text
clicks / impressions
```

O modelo permite analisar conjuntamente **aquisição orgânica, comportamento e resultado de negócio**.

---

## `seo__query_page_device_daily`

**Grão:**

```text
data + página + query + dispositivo
```

Este modelo preserva o nível de detalhe das consultas provenientes do Google Search Console.

Principais métricas:

- cliques
- impressões
- CTR
- posição média

Esse modelo é utilizado principalmente para análises relacionadas a:

- performance de palavras-chave
- oportunidades de CTR
- visibilidade orgânica
- posicionamento no Google
- comportamento das queries por página e dispositivo

A separação entre os dois modelos Gold evita replicar métricas do GA4 ao trabalhar no nível de query.

---

# 🔎 Data Grain

A definição explícita do grão foi uma decisão importante da modelagem.

### Performance de página

```text
dt_date
+ str_page
+ str_device
```

Modelo:

```text
seo__page_device_daily
```

### Performance de query

```text
dt_date
+ str_page
+ str_query
+ str_device
```

Modelo:

```text
seo__query_page_device_daily
```

Essa separação evita problemas de **fan-out** ao combinar dados com granularidades diferentes.

---

# 🧪 Qualidade dos dados

Foram implementados testes dbt para garantir integridade dos modelos Gold.

Entre as validações:

- `not_null` para dimensões essenciais
- unicidade do grão de página
- unicidade do grão de query

Testes executados:

```text
9 tests
9 passed
```

Também foram realizadas reconciliações entre Silver e Gold.

### Resultado da reconciliação

| Métrica | Silver | Gold |
|---|---:|---:|
| Sessions | 24,256 | 24,256 |
| Conversions | 452 | 452 |
| Revenue | 68,886.20 | 68,886.20 |
| Clicks | 20,802 | 20,802 |
| Impressions | 518,986 | 518,986 |

Para as métricas de Search Console:

```text
diff_clicks      = 0
diff_impressions = 0
```

Isso confirma que a transformação para a camada Gold preservou os totais das fontes tratadas.

---

# 📁 Estrutura do projeto

```text
wpp-seo-analytics-case/
│
├── macros/
│   └── generate_schema_name.sql
│
├── models/
│   ├── silver/
│   │   ├── sources.yml
│   │   ├── ga4__sessoes_organicas.sql
│   │   └── gsc__search_console.sql
│   │
│   └── gold/
│       ├── schema.yml
│       ├── seo__page_device_daily.sql
│       └── seo__query_page_device_daily.sql
│
├── tests/
│   ├── assert_unique_seo_page_device_daily.sql
│   └── assert_unique_seo_query_page_device_daily.sql
│
├── dbt_project.yml
├── .gitignore
└── README.md
```

---

# ▶️ Executando o projeto

Após configurar o profile do dbt e a conexão com o banco:

### Validar o projeto

```bash
dbt parse
```

### Executar os modelos

```bash
dbt run
```

### Executar os testes

```bash
dbt test
```

Também é possível executar as camadas individualmente.

### Silver

```bash
dbt run --select silver
```

### Gold

```bash
dbt run --select gold
```

---

# 📊 Dashboard

A camada Gold foi construída para servir como fonte de dados para um dashboard no Power BI.

A camada de visualização terá foco em:

- performance orgânica
- sessões
- conversões
- receita
- CTR
- impressões
- cliques
- posição média
- performance por página
- performance por query
- comparação entre dispositivos
- identificação de oportunidades de SEO

> Dashboard em desenvolvimento.

---

# 💡 Principais decisões de modelagem

Durante o desenvolvimento foram tomadas algumas decisões importantes:

**Separação Bronze / Silver / Gold**

Permite separar dados brutos, tratamento técnico e regras analíticas.

**Tipagem na Silver**

Os dados ingeridos continham métricas numéricas e percentuais armazenados como texto. A Silver centraliza essa conversão.

**Separação dos grãos de página e query**

GA4 e Search Console possuem granularidades diferentes. Manter modelos Gold separados evita duplicidade de sessões, receita e conversões.

**Recalcular métricas após agregação**

Métricas como CTR e taxas são calculadas a partir dos componentes agregados, evitando médias simples de percentuais.

**Testes de unicidade**

Cada modelo Gold possui uma chave lógica correspondente ao seu grão, protegida por testes dbt.

---

# 🚀 Próximas etapas

- [x] Ingestão das fontes
- [x] Estruturação da camada Bronze
- [x] Modelagem Silver
- [x] Modelagem Gold
- [x] Testes de qualidade
- [x] Reconciliação Silver × Gold
- [x] Versionamento com Git
- [x] Publicação no GitHub
- [ ] Construção do dashboard no Power BI
- [ ] Documentação das métricas do dashboard
- [ ] Inclusão de screenshots do dashboard

---

## Autor

**Paulo Henrique Caviquioli**

Data Analyst | Analytics Engineering | BI

Projeto desenvolvido como case de Analytics Engineering com foco em modelagem de dados, qualidade, SQL, dbt e visualização analítica.