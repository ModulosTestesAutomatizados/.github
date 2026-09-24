# Feature Specification: Templates de issues e PRs

**Feature Branch**: `feature/sdd` (planejamento; branch de entrega ainda não criada)

**Created**: 2026-09-23

**Status**: Backlog (Project [GitHub Features](https://github.com/orgs/ModulosTestesAutomatizados/projects/6), issue #4)

**Input**: [Issue #4 — Templates de issues e PRs](https://github.com/ModulosTestesAutomatizados/.github/issues/4), sub-issue da épica #1.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Registrar entrega com contexto mínimo (Priority: P1)

Como pessoa que abre um card, quero escolher um template para épica, release, feature,
task ou hotfix que já indique título e campos necessários para triagem e planejamento.

**Why this priority**: Evita cards incompletos e funciona mesmo sem automação de metadados.

**Independent Test**: Criar um card de cada tipo e verificar campos obrigatórios, título,
descrição e indicação dos metadados que ainda exigem preenchimento.

**Acceptance Scenarios**:

1. **Given** épica de sprint, **When** o formulário é preenchido, **Then** título coincide
   com milestone e há orientação para release MAJOR, Estimate 10, Size XL, Effort Team e datas.
2. **Given** sub-issue de feature, task ou hotfix, **When** é criada, **Then** título inicia
   com categoria em maiúsculas entre colchetes e corpo contém contexto, entrega e premissas.
3. **Given** campo obrigatório vazio, **When** se tenta criar, **Then** o formulário exige
   correção dos dados suportados; metadados externos são explicitados como pendências.

---

### User Story 2 - Revisar PR com evidências padronizadas (Priority: P2)

Como revisor, quero um template de PR com realização, fontes, instruções de teste e novidade
para conferir a entrega e comparar metadados com a issue relacionada.

**Why this priority**: Facilita review e homologação mesmo sem automação de issue fields.

**Independent Test**: Abrir PR vinculado a issue e verificar as seções presentes e
instruções claras para fornecer evidência e metadados correspondentes.

**Acceptance Scenarios**:

1. **Given** PR para sub-issue, **When** é aberto, **Then** o corpo pede vínculo, realização,
   fontes modificados, procedimento de teste e novidades.
2. **Given** PR com metadados diferentes dos da issue, **When** o autor preenche o template,
   **Then** uma verificação visível solicita alinhamento antes da revisão.

---

### User Story 3 - Completar metadados com segurança (Priority: P3)

Como mantenedor, quero que os campos possíveis sejam preenchidos automaticamente e os
demais sejam sinalizados para que Projects tenha dados comparáveis sem inventar defaults.

**Why this priority**: Expande o benefício para a organização sem afirmar suporte inexistente.

**Independent Test**: Criar issues/PRs em repositório com e sem configuração de Project e
verificar metadados disponíveis ou checklist de preenchimento manual.

**Acceptance Scenarios**:

1. **Given** épica criada com Project e permissão, **When** metadados são conciliados, **Then**
   valores fixos da épica são aplicados somente aos campos corretos e há diagnóstico de falha.
2. **Given** repositório sem campos, Project ou autorização necessária, **When** formulário é
   usado, **Then** criação continua possível e pendências são explicitadas sem vincular
   itens incorretos.

### Edge Cases

- Templates existentes `issueCLI.yml` (bug específico da CLI) e `issuePai.yml` precisam ser
  preservados ou migrados com equivalência explícita, sem duplicar épicas.
- Issue Type `Release` existe tanto para épica quanto para release não épica; somente a
  épica recebe Estimate 10 e o nome exato do milestone.
- Labels/assignees inexistentes no consumidor não podem impedir uso do formulário genérico.
- Issue Fields e campos de Project diferem entre organizações: mapear por nome/ID real, nunca
  copiar IDs de outra organização.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: DEVEM existir entradas distintas e descobríveis para épica, release não épica,
  feature, task, hotfix e PR, sem dois formulários com a mesma finalidade.
- **FR-002**: Formulários de issue DEVEM apresentar título orientado por tipo e corpo com
  contexto, entrega e premissas, exigindo os campos disponíveis que são necessários à triagem.
- **FR-003**: Épica DEVE instruir coincidência com milestone, datas equivalentes, Release
  MAJOR, Size XL, Estimate 10 e Effort Team; PR/sub-issues não podem herdar esse padrão.
- **FR-004**: A escala DEVE tratar Size XS–XL como valor agregado; Estimate 0 é homologação,
  1–5 acompanha Size para features, 6 é Hotfix, 7/8/9 representam PATCH/MINOR/MAJOR e 10
  é exclusivo da épica; release não épica não pode receber 10 automaticamente.
- **FR-005**: Sub-issues DEVEM orientar título com marcador `[TIPO]` maiúsculo e vínculo à
  épica/milestone; hotfix deve pedir contexto de emergência e escopo de correção.
- **FR-006**: Template de PR DEVE incluir seções `Realização`, `Fontes modificados`,
  `p/ teste` e `O que há de novo`, além de issue vinculada, review e metadados equivalentes.
- **FR-007**: Metadados suportados pelo formulário DEVEM ser preenchidos nele; os que
  dependem de API/Project DEVEM ser conciliados separadamente somente com permissão e
  mapeamento válidos, ou apresentados como pendência manual.
- **FR-008**: A documentação DEVE explicar como consumir cada template no repositório
  organizacional e como migrar os dois templates piloto atuais sem perda de funcionalidade.

### Key Entities

- **Template de issue**: tipo, campos obrigatórios e regra de título/corpo.
- **Escala de valor**: correspondência entre classe de entrega, Size e Estimate.
- **Template de PR**: seções de revisão e relacionamento com a issue.
- **Conciliação**: conjunto de metadados aplicáveis e pendências por repositório/Project.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Em cinco cenários de issue (épica, release, feature, task, hotfix), 100% dos
  formulários expõem as instruções e campos obrigatórios do respectivo tipo.
- **SC-002**: Em dez cards/PRs amostrais, 100% exibem o vínculo correto e a escala aplicável
  ou apontam explicitamente o metadado pendente.
- **SC-003**: Em PR de teste, todos os quatro blocos de relatório aparecem por padrão e
  um revisor consegue localizar evidências em até três minutos.
- **SC-004**: A migração preserva 100% das informações exigidas nos templates piloto para
  as jornadas que permanecerem disponíveis.

## Assumptions

- Formulários GitHub não garantem preenchimento de Issue Fields, campos de Project, milestone
  e sub-issue; quando a plataforma não suportar, uma etapa separada ou instrução manual cobre
  a lacuna sem prometer automação inexistente.
- A regra de título `[TIPO]` é uma orientação e/ou verificação posterior caso o formulário
  não consiga impor o valor dinâmico de forma nativa.
- Labels e tipos organizacionais só são atribuídos automaticamente após validação de que
  existem no repositório consumidor.
