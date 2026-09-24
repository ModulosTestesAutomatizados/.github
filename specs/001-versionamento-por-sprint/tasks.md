---
description: "Tarefas da feature de versionamento por sprint"
---

# Tasks: Versionamento por sprint

**Input**: `specs/001-versionamento-por-sprint/` (spec, plan, research, data-model, contracts e quickstart)

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/versioning.md`

**Tests**: Verificações de contrato e cenário de consumo exigidas por FR-007 e SC-001–SC-003.

**Organization**: Fases entregáveis por história; caminhos de implementação abaixo são propostos.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: pode ser executada em paralelo com outras tarefas marcadas que tocam arquivos distintos.
- **[Story]**: história que a tarefa realiza.

## Path Conventions

- Workflows em `.github/workflows/`; coordenação e adaptadores em `scripts/versioning/`.
- Cenários e exemplos de consumo em `LocalLabs/tests/versioning/` e
  `LocalLabs/examples/` (clone de testes fornecido pelo usuário);
  documentação compartilhada em `docs/versioning.md`.

## Phase 1: Setup

**Purpose**: Estabelecer a estrutura de validação sem alterar os templates de issue existentes.

- [X] T001 Criar cenário de consumidor de prévia e publicação em `LocalLabs/tests/versioning/fixtures/caller.yml`, com referência estável `@v1` para ativar após publicá-la e sem secrets reais.
- [X] T002 [P] Definir lint/validação YAML e checagem de `workflow_call` em `LocalLabs/tests/versioning/validate-contract.sh`.

## Phase 2: Foundational

**Purpose**: Impedir comandos e versões ambíguos nos adaptadores.

- [X] T003 Implementar seleção por enumeração fechada (`standard-version`, `changesets`, `jgitver`, `go-gitsemver`) e validação de `project_path` em `scripts/versioning/resolve-adapter.sh`.
- [X] T004 [P] Criar validador de milestone `vMAJOR.MINOR.PATCH`, branch `release/<milestone>`, metadados mínimos e conventional commits em `scripts/versioning/validate-sprint.sh` e `scripts/versioning/version.mjs`.

## Phase 3: User Story 1 - Prévia semântica no PR (Priority: P1) 🎯 MVP

**Goal**: Publicar prévia no PR sem efeitos de escrita.

**Independent Test**: PR válido e inválido para release produzem prévia/diagnóstico, sem tag.

- [X] T005 [US1] Implementar cálculo não destrutivo por perfil, retornando `bump` (`major|minor|patch|none`), `candidate_version` e `summary`, em `scripts/versioning/preview.sh`.
- [X] T006 [US1] Criar `.github/workflows/version-preview.yml` com `workflow_call`, entradas `adapter`/`release_branch`/`project_path`, saídas do contrato e `contents: read`, `pull-requests: read`, `issues: read` para verificar a sub-issue.
- [X] T007 [US1] Registrar em `LocalLabs/tests/versioning/preview-scenarios.md` passos de validação para PR válido, empilhado e malformado, exigindo ausência de tags e releases.

**Checkpoint**: prévia utilizável isoladamente nos quatro perfis.

## Phase 4: User Story 2 - Publicação após aprovação (Priority: P2)

**Goal**: Publicar após merge, mantendo versão gerada pelo perfil do consumidor.

**Independent Test**: merge aprovado gera uma tag/release, tentativa antes da homologação falha.

- [X] T008 [US2] Implementar preparação/checagem da versão do perfil em `scripts/versioning/prepare-release.sh` e changelog opcional em `scripts/versioning/publish.sh`, sem executar shell interpolado a partir de PR.
- [X] T009 [US2] Implementar criação de tag e GitHub Release no commit integrado, conferindo existência antes de criar, em `scripts/versioning/publish.sh`.
- [X] T010 [US2] Criar `.github/workflows/version-publish.yml` com `workflow_call`, inputs `adapter`/`release_branch`/`project_path`/`target_branch`/`homologation_environment`, `contents: write` apenas nesta operação e saídas `version`/`tag`/`release_url`/`outcome`.
- [X] T011 [US2] Incluir em `LocalLabs/tests/versioning/fixtures/caller.yml` exemplo de caller pós-merge que requer review/homologação e serializa pelo destino, sem permitir publicação no evento de PR.

**Checkpoint**: publicação funcional sem comprometer o MVP de prévia.

## Phase 5: User Story 3 - Concorrência e recuperação (Priority: P3)

**Goal**: Reexecutar sem duplicar e resolver colisões sem mover tags.

**Independent Test**: duas publicações concorrentes e dez reexecuções preservam a tag original.

- [X] T012 [US3] Incorporar em `scripts/versioning/publish.sh` comparação de commit/tag com criação exclusiva da ref e reconciliação `published|already-published|conflict`, sem force-push.
- [X] T013 [US3] Tratar em `.github/workflows/version-publish.yml` e `scripts/versioning/publish.sh` falha parcial e retorno acionável quando a release existe sem tag correspondente ou vice-versa.
- [X] T014 [US3] Registrar reexecuções, colisão entre commits diferentes e recuperação manual em `LocalLabs/tests/versioning/retry-scenarios.md`.

**Checkpoint**: conflitos não corrompem tags ou releases existentes.

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Documentação de contrato, consumo e evidências de validação.

- [X] T015 Documentar em `docs/versioning.md` os quatro perfis de callers, permissões, referência estável, limites e política de migração.
- [ ] T016 Executar integralmente e registrar os passos hospedados de `specs/001-versionamento-por-sprint/quickstart.md` em `LocalLabs/tests/versioning/validation-results.md` após publicar uma ref estável e configurar milestone, review e homologação no LocalLabs. Cenários locais já registrados; integração GitHub ainda pendente.

## Dependencies & Execution Order

- Setup T001–T002 antecede T003–T004; US1 requer ambos os validadores.
- US2 requer contrato de US1 apenas para reaproveitar adaptadores; seu caller é testável
  independentemente após T003–T004. US3 requer T009–T011.
- T015–T016 dependem das histórias que documentam/validam.

## Parallel Example: User Story 1

- Após T003–T004, T005 e a redação inicial de T007 podem avançar em paralelo em arquivos
  diferentes; T006 conecta as saídas resultantes.
- Em US2, T008 e o desenho do caller em T011 podem começar paralelamente; T009 precede T010.

## Implementation Strategy

- MVP: T001–T007; validar a prévia sem gerar publicações.
- Depois: T008–T011 para publicação, T012–T014 para robustez, T015–T016 para entrega.

## Notes

- Se o consumidor ainda não gera/commita versão no fluxo de release, T008 precisa garantir
  coerência entre arquivo de versão, commit integrado e tag antes de liberar T009.
