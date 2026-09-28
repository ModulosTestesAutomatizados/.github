---
description: "Tarefas por história para code review automatizado"
---

# Tasks: Revisão Codex e SonarQube

**Input**: `specs/005-revisao-pr-codex/` e `openspec/changes/codex-pr-review-orchestration/tasks.md`.

**Prerequisites**: contratos de #3 e #6 implementados nas respectivas branches; spec, plan, research, data-model e quickstart.

**Tests**: SC-001–SC-004 incluindo HEAD obsoleto, fork e gate crítico.

## Format: `[ID] [P?] [Story] Description`

- `[P]` significa arquivos independentes; `[USn]` identifica história do `spec.md`.
- Paths previstos: `.github/workflows/`, `scripts/review/`, `tests/review/`, `docs/` e skill versionada.

## Phase 1: Setup

- [ ] T001 Confirmar contratos `.github/workflows/sonarqube-pr.yml` e de modelos/prompts da #6 na branch base; validar saídas `gate`, `report_url`, `analyzed_sha` contra specs herdadas.
- [ ] T002 [P] Criar `tests/review/fixtures/caller.yml` e eventos para branches quaisquer, PR interno, fork, SHA concorrente e gate crítico conforme `contracts/codex-review.md`.

## Phase 2: Foundational

- [ ] T003 Implementar deduplicação por PR e limite de uma autocorreção em `scripts/review/`; testar reexecução e push do bot.
- [ ] T004 Criar templates de prompt de review separados em `scripts/review/prompts/` usando política de modelo da #6; verificar falta de secret e proteção contra instruções da entrada.

## Phase 3: User Story 1 - Review e gate por PR (Priority: P1) 🎯 MVP

**Goal**: revisão antes de SonarQube no HEAD correto de qualquer PR.

**Independent Test**: PR sem mudanças: revisão e gate têm o mesmo SHA e a ordem certa.

- [ ] T005 [US1] Criar `.github/workflows/codex-pr-review.yml` com caller `workflow_call`, revisão não interativa e relatórios vinculados ao SHA; testar bases arbitrárias.
- [ ] T006 [US1] Encadear chamada SonarQube da #3 e validar `analyzed_sha` contra HEAD vigente; testar gate verde, indisponível e resultado stale.

## Phase 4: User Story 2 - Correção limitada (Priority: P2)

**Goal**: uma correção permitida inicia nova execução sem loop, fork recebe só sugestão.

**Independent Test**: mudança segura em PR interno inicia novo check; fork não recebe push.

- [ ] T007 [US2] Limitar commit automático à branch confiável do PR com identidade que produza novo evento; testar que run antigo não aprova SHA novo.
- [ ] T008 [US2] Tratar fork, branch protegida e push concorrente com comentários de sugestão e sem secret de escrita; testar limite por PR.

## Phase 5: User Story 3 - Bloqueio e adoção (Priority: P3)

**Goal**: achados críticos vão para revisão humana e status Project da #3 quando autorizado.

**Independent Test**: gate crítico depois do review falha check e informa revisão humana.

- [ ] T009 [US3] Expor relatório/check consolidado e integrar status `Request changes` da #3 sem review formal falsa; testar vínculo válido/inexistente.
- [ ] T010 [US3] Documentar adoção em `docs/codex-pr-review.md` e atualizar `.opencode/skills/quality-workflows/SKILL.md` com caller, modelos, prompts, secrets e regras de SHA; validar exemplos contra fixture.

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T011 Executar `quickstart.md` no consumidor de teste e registrar evidências de proteção e review humana em `tests/review/validation-results.md`.

## Dependencies & Execution Order

#3 e #6 implementadas antes de T001; T003–T004 antes de US1; US2 depende de US1; US3 valida os dois fluxos; T011 final.

## Parallel Example: User Story 1

T002 (fixtures) e T001 (contratos) são independentes; T006 conecta gate após T005.

## Implementation Strategy

Validar MVP read-only e gate para qualquer PR; só depois habilitar autocorreção e reconferência do HEAD, mantendo review humana e caller estável.
