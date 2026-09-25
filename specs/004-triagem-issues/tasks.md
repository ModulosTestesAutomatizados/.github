---
description: "Tarefas por história para triagem de issues com Codex"
---

# Tasks: Triagem de issues

**Input**: `specs/004-triagem-issues/` e `openspec/changes/codex-issue-triage/tasks.md`.

**Prerequisites**: spec, plan, research, data-model, contract, quickstart.

**Tests**: cenários SC-001–SC-004 e isolamento de credenciais.

## Format: `[ID] [P?] [Story] Description`

- `[P]` significa independente; `[USn]` identifica história do `spec.md`.
- Paths futuros: `.github/workflows/`, `scripts/triage/`, `tests/triage/`, `docs/` e skill versionada.

## Phase 1: Setup

- [ ] T001 Preparar `tests/triage/fixtures/caller.yml` a partir de `contracts/issue-triage.md`, conferindo inputs, saídas, secrets e permissões do workflow.
- [ ] T002 [P] Criar fixtures de eventos e resultados em `tests/triage/fixtures/` para complexo/simples/comentário/falha de CI/bot/duplicação.

## Phase 2: Foundational

- [ ] T003 Implementar `scripts/triage/router.*` com ação/modelo/prompt versionado e validação de origem; testar seleção e fallback sem escrita.
- [ ] T004 Implementar chave de idempotência e exclusão de bot em `scripts/triage/`; testar duplicações de evento e concorrência por issue.
- [ ] T005 Criar prompts separados em `scripts/triage/prompts/` e testes que assegurem ausência de segredos em resultado.

## Phase 3: User Story 1 - Planejamento complexo (Priority: P1) 🎯 MVP

**Goal**: plano contextualizado read-only para issue complexa.

**Independent Test**: issue complexa produz plano revisável e nenhum commit direto.

- [ ] T006 [US1] Implementar `.github/workflows/issue-triage.yml` com `workflow_call` e execução Codex não interativa em job read-only; validar evento e resultado da issue.
- [ ] T007 [US1] Restaurar/limpar credencial temporária no runner em job isolado; testar secret ausente/inválido, logs e cleanup.
- [ ] T008 [US1] Publicar referência ao plano sem gerar código na base; testar SC-001 em `tests/triage/`.

## Phase 4: User Story 2 - PR simples (Priority: P2)

**Goal**: correção opt-in em branch exclusiva com PR humano.

**Independent Test**: issue simples cria até um PR na base indicada, sem merge automático.

- [ ] T009 [US2] Adicionar job de escrita opt-in e branch por issue em `.github/workflows/issue-triage.yml`; testar que job read-only não ganha permissão de escrita.
- [ ] T010 [US2] Criar PR rastreável e testar reexecução, fork, base configurada e revisão humana em `tests/triage/`.

## Phase 5: User Story 3 - Reuso e eventos (Priority: P3)

**Goal**: callers interorganizacionais e diagnósticos opcionais sem loops.

**Independent Test**: comentário autorizado e falha de CI usam prompts corretos; ausência de herança de secret falha claramente.

- [ ] T011 [US3] Acrescentar filtros de eventos opcionais e diagnóstico sem checkout privilegiado em `scripts/triage/`; testar bot/fork e `workflow_run`.
- [ ] T012 [US3] Documentar callers, autenticação, modelos/defaults e limitações em `docs/issue-triage.md` e atualizar `.opencode/skills/quality-workflows/SKILL.md`; validar paridade com fixture.

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T013 Rodar cenários de `quickstart.md` com consumidor de teste e registrar evidências em `tests/triage/validation-results.md` antes de solicitar review.

## Dependencies & Execution Order

T001–T005 antes das histórias; US1 antes de US2 (escrita); US3 reutiliza o roteador; T013 após todas.

## Parallel Example: User Story 1

T002 (fixtures) pode avançar junto de T001; T007 (isolamento) após T006, T008 após T007.

## Implementation Strategy

Entregar MVP read-only e contrato de caller; habilitar correção simples apenas depois de provar isolamento/idempotência; expandir eventos por opt-in do consumidor.
