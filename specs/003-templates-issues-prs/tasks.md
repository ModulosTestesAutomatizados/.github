---
description: "Tarefas para templates de issues e pull requests"
---

# Tasks: Templates de issues e PRs

**Input**: `specs/003-templates-issues-prs/` (spec, plan, research, data-model, contrato e quickstart)

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/templates.md`

**Tests**: Verificação de formulários e uso manual descrita em `quickstart.md`.

**Organization**: Histórias independentes: issues, PR e conciliação.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: pode ser feita em paralelo em arquivo distinto sem dependência pendente.
- **[Story]**: rótulo da história correspondente em `spec.md`.

## Path Conventions

- Forms em `.github/ISSUE_TEMPLATE/`, PR em `.github/PULL_REQUEST_TEMPLATE.md`, automação
  em `.github/workflows/` e `scripts/templates/`; documentação em `docs/templates.md`.

## Phase 1: Setup

**Purpose**: Mapear a compatibilidade dos dois pilotos antes de alterá-los.

- [ ] T001 Registrar em `tests/templates/pilots.md` campos de `.github/ISSUE_TEMPLATE/issueCLI.yml` (comando, ecossistema, logs) e `.github/ISSUE_TEMPLATE/issuePai.yml` (título/label) que deverão continuar disponíveis.
- [ ] T002 [P] Criar verificação de sintaxe e campos suportados de issue forms em `tests/templates/validate-forms.sh`.

## Phase 2: Foundational

**Purpose**: Evitar defaults incompatíveis para tipos distintos.

- [ ] T003 Definir em `docs/templates.md` matriz de valor Size XS/S/M/L/XL, Estimate 0 homologação, 1–5 feature, 6 hotfix, 7/8/9 release PATCH/MINOR/MAJOR e 10 exclusivo épica.
- [ ] T004 [P] Definir em `tests/templates/scenarios.md` exemplos de título, corpo, parent/milestone e metadados esperados para cinco tipos, incluindo caso sem Project.

## Phase 3: User Story 1 - Registrar entrega com contexto mínimo (Priority: P1) 🎯 MVP

**Goal**: Cinco escolhas claras de issue, preservando bug da CLI.

**Independent Test**: formulário vazio exige contexto; épica e hotfix não trocam defaults.

- [ ] T005 [US1] Migrar `.github/ISSUE_TEMPLATE/issuePai.yml` para formulário válido de épica, mantendo a única opção de épica e orientando milestone com título igual, Release MAJOR, Size XL, Estimate 10, Effort Team e datas equivalentes.
- [ ] T006 [P] [US1] Criar `.github/ISSUE_TEMPLATE/release.yml` para release não épica com opção PATCH/MINOR/MAJOR, Estimate 7/8/9, contexto, entrega e premissas obrigatórios.
- [ ] T007 [P] [US1] Criar `.github/ISSUE_TEMPLATE/feature.yml` com título `[FEATURE]`, vínculo de épica/milestone, contexto/entrega/premissas obrigatórios e Scale Size XS–XL/Estimate 1–5 por valor agregado.
- [ ] T008 [P] [US1] Criar `.github/ISSUE_TEMPLATE/task.yml` com título `[TASK]`, contexto/entrega/premissas obrigatórios e orientação de valor sem Estimate fixo.
- [ ] T009 [P] [US1] Criar `.github/ISSUE_TEMPLATE/hotfix.yml` com título `[HOTFIX]`, motivo emergencial, impacto, validação, contexto/premissas obrigatórios e Estimate 6 com Size variável.
- [ ] T010 [US1] Corrigir somente incompatibilidades comprovadas no piloto `.github/ISSUE_TEMPLATE/issueCLI.yml`, preservando comando, ecossistema e logs obrigatórios conforme T001.

**Checkpoint**: cinco tipos + bug da CLI sem duplicar formulário de épica.

## Phase 4: User Story 2 - Revisar PR com evidências padronizadas (Priority: P2)

**Goal**: PR traz evidência de entrega e revisão.

**Independent Test**: abrir PR de exemplo e encontrar issue, quatro seções e checklist.

- [ ] T011 [US2] Criar `.github/PULL_REQUEST_TEMPLATE.md` com vínculo à issue, `Realização`, `Fontes modificados`, `p/ teste`, `O que há de novo` e checklist de review/labels/milestone/Project.
- [ ] T012 [US2] Incluir em `.github/PULL_REQUEST_TEMPLATE.md` instrução de referência sem fechamento para `release/*`/`develop` e fechamento apenas para principal, além de conferência de metadados com a issue.

**Checkpoint**: revisor consegue conferir o PR sem a automação de Project.

## Phase 5: User Story 3 - Completar metadados com segurança (Priority: P3)

**Goal**: Conciliar quando autorizado e sinalizar o restante.

**Independent Test**: com Project aplica apenas valores corretos; sem Project lista pendências.

- [ ] T013 [US3] Implementar em `scripts/templates/resolve-fields.sh` consulta ao repositório/Project alvo para IDs reais de campos, opções, tipo, milestone e vínculo, rejeitando IDs de outra organização.
- [ ] T014 [US3] Implementar em `scripts/templates/reconcile.sh` aplicação apenas de valores válidos, com Estimate 10/Size XL/Release MAJOR/Effort Team exclusivos de épica, e retorno explícito de pendências.
- [ ] T015 [US3] Criar `.github/workflows/issue-metadata.yml` com `workflow_call` para uso opt-in por consumidores, separando token de Project, recusando vínculo incerto e jamais executando texto de issue como código.
- [ ] T016 [US3] Adicionar a `tests/templates/scenarios.md` casos com/sem permissão/Project/field e PR vinculado para comprovar ausência de atualização em item errado.

**Checkpoint**: conciliação não impede criação básica por formulário.

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Instruções de adoção e validação em consumidor real.

- [ ] T017 Documentar em `docs/templates.md` adoção por defaults da organização versus arquivos locais, metadados manuais, migração do piloto e instruções de referência fixa para a automação opt-in.
- [ ] T018 Executar `specs/003-templates-issues-prs/quickstart.md` e registrar evidências de cinco issues, bug da CLI, PR e fallback em `tests/templates/validation-results.md`.

## Dependencies & Execution Order

- T001–T004 precedem a migração; T005 precede T010 para comparar piloto e épica nova.
- US2 pode ser implementada após T001–T004 em paralelo a US1; US3 requer matriz T003,
  não depende da existência do template de PR para aplicar metadados da issue.
- T015 requer T013–T014; T017–T018 seguem as histórias escolhidas para validação.

## Parallel Example: User Story 1

- Após T001–T004, T006–T009 podem ser feitos em paralelo: arquivos separados e sem
  dependência entre formulários. T005 e T010 seguem a comparação com o piloto.
- Em US2, documentação preliminar T017 pode começar após T011, mas T012 altera o mesmo
  arquivo e deve ser sequencial.

## Implementation Strategy

- MVP: T001–T010; experimentar os cinco tipos e manter o bug da CLI.
- Incrementos: T011–T012 para PR, T013–T016 para campos externos, T017–T018 para adoção.

## Notes

- Um form não cria parent/milestone/Issue Fields/Project Fields por si só; indicar pendência
  ou aplicar etapa de API com permissão, sem inserir chaves não suportadas no YAML.
