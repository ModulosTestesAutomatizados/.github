# Feature Specification: Versionamento por sprint

**Feature Branch**: `feature/issue-2` (planejamento; branch de entrega ainda não criada)

**Created**: 2026-09-23

**Status**: Backlog (Project [GitHub Features](https://github.com/orgs/ModulosTestesAutomatizados/projects/6), issue #2)

**Input**: [Issue #2 — Versionamento por sprint](https://github.com/ModulosTestesAutomatizados/.github/issues/2), sub-issue da épica #1 (`v1.0.0`).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Prévia semântica no PR (Priority: P1)

Como responsável por um projeto consumidor, quero ver no PR para a release qual seria o
impacto semântico da entrega para que a revisão e a homologação sejam informadas sem publicar
uma versão prematuramente.

**Why this priority**: Uma prévia confiável é utilizável isoladamente e não altera tags.

**Independent Test**: Abrir ou atualizar um PR de uma issue para a release e conferir uma
prévia rastreável; nenhum artefato publicado deve surgir nessa fase.

**Acceptance Scenarios**:

1. **Given** um PR de feature para `release/v1.0.0` com commits válidos, **When** sua análise
   termina, **Then** o PR recebe prévia do tipo de mudança e referência à sprint `v1.0.0`,
   sem criar tag ou release.
2. **Given** PR sem metadados mínimos ou com commits não interpretáveis, **When** é analisado,
   **Then** a falha é explicada e nenhuma versão é publicada.

---

### User Story 2 - Publicação após aprovação (Priority: P2)

Como mantenedor, quero publicar uma versão, tag e release somente após homologação e aprovação
do PR para a branch principal, mantendo a versão no formato exigido pelo projeto consumidor.

**Why this priority**: Completa o fluxo de entrega sem antecipar publicações durante a sprint.

**Independent Test**: Após aprovação de uma release homologada, executar a publicação em um
repositório de teste e conferir versão, tag, release e changelog quando suportado.

**Acceptance Scenarios**:

1. **Given** sprint concluída e PR aprovado para a branch principal, **When** a publicação é
   autorizada, **Then** a ferramenta escolhida pelo consumidor gera versão e changelog
   aplicáveis, e a tag/release refletem o commit integrado.
2. **Given** revisão humana pendente ou homologação incompleta, **When** a publicação é
   solicitada, **Then** ela é bloqueada com motivo explícito.

---

### User Story 3 - Concorrência e recuperação (Priority: P3)

Como mantenedor, quero que duas entregas simultâneas não sobrescrevam versões já publicadas
e que falhas possam ser tratadas sem corromper o histórico.

**Why this priority**: Protege projetos com PRs paralelos e reexecuções.

**Independent Test**: Simular execuções concorrentes e reexecução após publicação parcial;
conferir ausência de tags movidas ou releases duplicadas.

**Acceptance Scenarios**:

1. **Given** duas tentativas para a mesma versão, **When** ambas concorrem, **Then** no máximo
   uma publica, e a outra detecta o conflito e solicita recálculo ou revisão sem sobrescrever.
2. **Given** tag e release já associadas ao mesmo commit, **When** o fluxo é repetido, **Then**
   termina de forma idempotente e informa os artefatos existentes.

### Edge Cases

- PR empilhado ou destinado a `develop`: apenas prévia, nunca publicação.
- Merge que altera o histórico desde a prévia: recálculo antes da publicação.
- Tag existente em commit diferente: interromper, preservar histórico e orientar resolução.
- Ferramenta de versionamento não instalada/configurada: erro acionável no consumidor.
- Repositório sem issue vinculada: solicitar os metadados mínimos antes de publicar.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A solução DEVE oferecer um fluxo reutilizável invocado por repositórios
  consumidores com configuração específica da ferramenta de versionamento do projeto.
- **FR-002**: O fluxo DEVE identificar tipo de PR, sprint/release associada, dados da entrega
  e validade dos commits necessários ao cálculo semântico.
- **FR-003**: PRs de entregas individuais e PRs empilhados DEVEM produzir somente prévia;
  nenhuma tag, release ou versão definitiva deve ser publicada nessa etapa.
- **FR-004**: A publicação DEVE exigir conclusão da sprint, homologação e revisão humana
  aprovadas e executar-se apenas após integração no destino de publicação configurado.
- **FR-005**: A integração DEVE permitir adaptar as ferramentas já usadas em projetos Node,
  monorepos de pacotes, Maven/Java e Go sem pressupor uma única ferramenta universal.
- **FR-006**: O resultado publicado DEVE associar uma versão única ao commit integrado,
  emitir tag e release correspondentes e incluir changelog quando o consumidor o produzir.
- **FR-007**: Execuções concorrentes e repetidas DEVEM detectar colisões sem mover tags
  publicadas; reexecução do mesmo commit DEVE ser idempotente.
- **FR-008**: Falhas DEVEM deixar rastros verificáveis e indicar como retomar ou resolver
  inconsistências entre tag, release e versão da aplicação.
- **FR-009**: A interface de consumo DEVE documentar entradas, saídas, permissões e exemplo
  mínimo por família de ferramentas suportadas.

### Key Entities

- **Sprint de release**: marco que relaciona milestone, épica e branch de release.
- **Candidato de versão**: cálculo não publicado vinculado ao PR e seus commits.
- **Publicação**: versão, commit, tag, release e changelog de uma entrega concluída.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Nos quatro perfis de projeto declarados, 100% dos PRs de amostra válidos
  exibem prévia sem criar uma tag.
- **SC-002**: Em 100% dos cenários de publicação aprovada, a tag e a release representam
  o commit integrado; em 100% dos cenários não aprovados, não há publicação.
- **SC-003**: Em dez reexecuções e em duas publicações concorrentes simuladas, nenhuma tag
  publicada é movida e não surgem releases duplicadas para a mesma versão.
- **SC-004**: Um mantenedor consegue identificar em até cinco minutos, a partir do resultado
  do fluxo, o motivo de qualquer bloqueio e a ação de recuperação.

## Assumptions

- A épica #1 e a milestone `v1.0.0` são a referência da sprint; a issue não define por si só
  a versão real de cada consumidor.
- A prévia ocorre em PRs; criação de tag/release ocorre somente após integração aprovada na
  branch de publicação, nunca em abertura de PR.
- Tags publicadas são imutáveis. A sugestão da issue de realocar uma tag é substituída por
  bloqueio e reconciliação explícita para preservar rastreabilidade.
- A aprovação humana e as políticas de proteção de branch são configuradas no consumidor;
  o fluxo reutilizável não as substitui.
