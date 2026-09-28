# Feature Specification: Code review automatizado com Codex e SonarQube

**Feature Branch**: `feature/issue-7` (PR para `feature/issue-6`)  
**Created**: 2026-09-25  
**Status**: planejamento — execução acompanhada na [issue #7](https://github.com/ModulosTestesAutomatizados/.github/issues/7)  
**Input**: issue #7; depende do gate da #3 e do roteamento Codex da #6.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Revisar PR antes da análise profunda (Priority: P1)

Como revisor, quero um relatório Codex para todo PR aberto, sem distinção da branch, seguido de análise SonarQube no mesmo HEAD.

**Why this priority**: fluxo sem alterações automáticas já traz sinalização e gate profundo.

**Independent Test**: Abrir PR entre branches arbitrárias, sem correção sugerida; conferir ordem de checks e SHA idêntico entre revisão e gate.

**Acceptance Scenarios**:

1. **Given** caller ativo, **When** PR é aberto/atualizado/reaberto, **Then** revisão ocorre e SonarQube avalia HEAD confirmado.
2. **Given** Codex ou SonarQube indisponível, **When** job termina, **Then** check não fica verde por engano e causa é visível.

### User Story 2 - Autocorreção supervisionada (Priority: P2)

Como autor, quero sugestões ou um commit limitado na minha branch quando permitido, com nova execução do gate, sem loop de correções.

**Why this priority**: iteração automática só pode ser habilitada após garantir SHA e credenciais.

**Independent Test**: PR interno com alteração sugerida e PR de fork; conferir uma correção por PR e nenhuma escrita no fork.

**Acceptance Scenarios**:

1. **Given** PR interno confiável e permissão de escrita, **When** Codex corrige um problema, **Then** commit aparece na própria branch e nova execução analisa o HEAD resultante.
2. **Given** PR de fork ou branch protegida, **When** há sugestão, **Then** comentário é publicado sem push nem exposição de secrets.

### User Story 3 - Bloquear falhas críticas com humano na decisão (Priority: P3)

Como mantenedor, quero ver falha crítica do SonarQube no PR e `Request changes` no Project quando aplicável, sem aprovação automática de review.

**Why this priority**: complementa os checks da #3 com evidência e sequência da #7.

**Independent Test**: Gate vermelho após revisão e PR/issue vinculados no Project; conferir check reprovado, relatório e tratamento humano.

**Acceptance Scenarios**:

1. **Given** gate reprovado, **When** a revisão termina, **Then** check bloqueia merge, relatório é anexado e status é sincronizado quando autorizado.
2. **Given** revisão e gate verdes, **When** verificações terminam, **Then** o check técnico passa sem substituir review humana obrigatória.

### Edge Cases

- Push via `GITHUB_TOKEN` sem evento subsequente, webhook atrasado, atualização concorrente, fork sem secrets, duplicação de comentários, edição em branch protegida, gatilho acionado por bot e nova falha após correção.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Caller MUST suportar qualquer combinação de branches do PR e invocar workflow com ref estável e permissões mínimas.
- **FR-002**: Revisão MUST utilizar modelo/prompt configuráveis e expor `review_status` e `reviewed_sha` sem falsificar review humana.
- **FR-003**: Autocorreção MUST ser limitada a uma iteração por PR, restrita à própria branch autorizada e produzir nova execução real para o novo HEAD; forks recebem apenas sugestões.
- **FR-004**: SonarQube da #3 MUST analisar o HEAD final e seu `analyzed_sha` MUST corresponder ao SHA do PR antes de aprovar check.
- **FR-005**: Falha crítica, resultado obsoleto ou indisponível MUST impedir aprovação automática e notificar para decisão humana, sincronizando Project via contrato da #3 quando possível.
- **FR-006**: Caller, inputs/defaults, secrets, permissões, prompts/modelos e falhas MUST constar na documentação e skill versionada da #7.

### Key Entities

- **Revisão**: PR, SHA inicial/final, ação, modelo, versão do prompt e estado.
- **Iteração**: commit da autocorreção ou sugestões, identificador único por PR e limite consumido.
- **Resultado de gate**: SHA analisado, status, URL de relatório e sinalização de falha.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Em 100% dos casos de PR sem mudança, SonarQube roda depois do review e só aprova se os SHAs coincidirem.
- **SC-002**: Em 100% dos casos de correção automática, a execução anterior não aprova novo HEAD e ocorre no máximo uma autocorreção por PR.
- **SC-003**: Em 100% dos casos de fork testados, não há commit nem exposição de credenciais.
- **SC-004**: Em 100% dos cenários de falha crítica, o check fica reprovado e o PR exige revisão humana; Project é atualizado apenas quando vínculo/permissão existem.

## Assumptions

- As #3 e #6 serão implementadas em seus próprios PRs antes de ativar o caller da #7; este PR contém apenas planejamento.
- O consumidor habilita os checks obrigatórios e mantém revisão humana; um campo Project `Request changes` não substitui review formal.
- Para nova execução depois do commit do bot, o consumidor dispõe de identidade que aciona eventos; sem ela, usar sugestões sem push.
