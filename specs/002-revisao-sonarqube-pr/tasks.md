---
description: "Tarefas da análise SonarQube por PR"
---

# Tasks: Revisão SonarQube em PRs

**Input**: `specs/002-revisao-sonarqube-pr/` (spec, plan, research, data-model, contrato e quickstart)

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/sonarqube-pr.md`

**Tests**: Cenários de gate, HEAD, sincronização e cleanup requeridos por SC-001–SC-004.

**Organization**: Tarefas em fases por história; integração com Project não bloqueia MVP.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: arquivos independentes e nenhuma tarefa não concluída como dependência.
- **[Story]**: US1, US2 ou US3 conforme `spec.md`.

## Path Conventions

- Workflow em `.github/workflows/`; integração em `scripts/sonarqube/`;
  testes de consumo em `tests/sonarqube/` e instruções em `docs/sonarqube-pr.md`.

## Phase 1: Setup

**Purpose**: Cenários de consumo e validação de interface.

- [ ] T001 Criar caller de demonstração com ref fixa, inputs `project_key`/`sonar_host_url`/`project_base_dir` e `sonar_token` fictício em `tests/sonarqube/fixtures/caller.yml`.
- [ ] T002 [P] Registrar verificação de sintaxe, inputs/secrets e permissões do workflow em `tests/sonarqube/validate-contract.sh`.

## Phase 2: Foundational

**Purpose**: Preparar resultados atrelados ao HEAD e falha segura.

- [ ] T003 Criar em `scripts/sonarqube/parse-gate.sh` normalização `passed|failed|unavailable` por `headSha`, `reportUrl` e critérios, negando aprovação se HEAD divergir.
- [ ] T004 [P] Criar em `tests/sonarqube/fixtures/gates.json` resultados verde, vermelho, indisponível e stale HEAD para validar T003.

## Phase 3: User Story 1 - Verificar qualidade no PR (Priority: P1) 🎯 MVP

**Goal**: Check e relatório do SonarQube bloqueiam merge quando gate não aprova.

**Independent Test**: PR verde, vermelho, indisponível e HEAD novo produzem check coerente.

- [ ] T005 [US1] Implementar `.github/workflows/sonarqube-pr.yml` com `workflow_call`, `contents: read`, checkout do PR, scanner oficial com action pinada e entradas do contrato.
- [ ] T006 [US1] Conectar `.github/workflows/sonarqube-pr.yml` ao resultado do gate e expor `gate`, `report_url` e `analyzed_sha`, falhando check em `failed|unavailable` sem tratar erro de scanner como sucesso.
- [ ] T007 [US1] Registrar em `tests/sonarqube/gate-scenarios.md` execução de PR verde, crítico, indisponível e novo HEAD com check obrigatório no consumidor.

**Checkpoint**: gate técnico de PR independente do Project.

## Phase 4: User Story 2 - Refletir status no Project (Priority: P2)

**Goal**: Marcar itens relacionados sem criar review humana falsa.

**Independent Test**: PR/issue no mesmo Project recebem `Request changes` na falha;
ausência de vínculo/credencial não modifica outros itens.

- [ ] T008 [US2] Implementar `scripts/sonarqube/sync-project-status.sh` com resolução de `projectId`, IDs dos itens vinculados e ID da opção real `Request changes`, sem inferir IDs fixos.
- [ ] T009 [US2] Persistir marcador de alteração automática e status anterior em comentário identificado do PR, com reconciliação conservadora em `scripts/sonarqube/sync-project-status.sh`; jamais reverter status modificado por outra origem.
- [ ] T010 [US2] Integrar `.github/workflows/sonarqube-pr.yml` ao passo de sincronização com `project_token` separado e opção `sync_project_status`, sem conceder esse secret ao job que executa código de fork.
- [ ] T011 [US2] Registrar casos vinculados, sem vínculo, opção ausente e sem permissão em `tests/sonarqube/project-scenarios.md`.

**Checkpoint**: Project acompanha o check, mas não determina sozinho o bloqueio de merge.

## Phase 5: User Story 3 - Execução isolada por PR (Priority: P3)

**Goal**: Nenhum recurso temporário remanescente após encerramento/cancelamento.

**Independent Test**: executar PR verde e cancelado, inspecionar runner/container e relatório.

- [ ] T012 [US3] Isolar scanner em job temporário e adicionar limpeza em condição de término/cancelamento em `.github/workflows/sonarqube-pr.yml`, sem encerrar servidor compartilhado.
- [ ] T013 [US3] Registrar cenário de cancelamento, PR de fork e persistência do relatório em `tests/sonarqube/lifecycle-scenarios.md`.

**Checkpoint**: execução temporária sem perda de histórico no SonarQube.

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Adoção segura e validação final.

- [ ] T014 Documentar binding SonarQube/GitHub, check obrigatório, Project opcional, privilégios e referência fixa em `docs/sonarqube-pr.md`.
- [ ] T015 Executar cenários de `specs/002-revisao-sonarqube-pr/quickstart.md` e guardar evidências em `tests/sonarqube/validation-results.md`.

## Dependencies & Execution Order

- T001–T002 precedem a integração; T003–T004 precedem US1.
- US2 pode começar após T003–T004, mas T010 requer o workflow T005–T006; US3 usa o mesmo
  workflow e deve ser integrado depois de T006.
- T014–T015 fecham as histórias; nenhuma tarefa altera a configuração da instância SonarQube.

## Parallel Example: User Story 1

- T005 (workflow) e T007 (cenários em arquivo separado) podem avançar após o fundamento;
  T006 conecta e valida as saídas.
- Em US2, T008 e a preparação de T011 podem ocorrer em paralelo; T009 depende de T008.

## Implementation Strategy

- MVP: T001–T007 para gate verificável e bloqueio real.
- Incrementos: T008–T011 para Project, T012–T013 para isolamento, T014–T015 para adoção.

## Notes

- O token de Project só pode ser usado em job que não executa código não confiável do PR.
