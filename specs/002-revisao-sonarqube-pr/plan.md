# Implementation Plan: Revisão SonarQube em PRs

**Branch**: `feature/issue-3` (base `master`) | **Date**: 2026-09-25 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/002-revisao-sonarqube-pr/spec.md`

## Summary

Workflow reutilizável analisa PR com scanner temporário, entrega check e relatório SonarQube,
falhando fechado quando gate não é aprovado. Com credenciais separadas e vínculo confirmado,
um passo adicional sincroniza os itens PR/issue no Project. A instância SonarQube é persistente.

## Technical Context

**Language/Version**: YAML de GitHub Actions; script de integração a definir no próprio projeto

**Primary Dependencies**: SonarQube Server, scanner oficial, integração GitHub/SonarQube,
GitHub Actions, GitHub Projects API para sincronização opcional

**Storage**: relatório/histórico no SonarQube; status/check no GitHub; sem armazenamento local

**Testing**: análise de PR permitido/reprovado, indisponibilidade, HEAD atualizado, Project
com e sem vínculo, limpeza após cancelamento

**Target Platform**: workflows chamados por repositórios GitHub com acesso ao SonarQube

**Project Type**: automação compartilhada com integração externa

**Performance Goals**: resultado do check em até 15 min para amostra de projeto pequeno

**Constraints**: PR de fork não recebe secret privilegiado; branch ruleset exige check;
`Request changes` no Project depende de permissão externa; SonarQube Server não é efêmero

**Scale/Scope**: N PRs de consumidores independentes; um resultado válido por HEAD analisado

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- I/II: workflow genérico `workflow_call` com entradas e secrets documentados, sem copiar
  scanner em cada projeto; versão pinável.
- IV: leitura para PR; acesso a Project separado e restrito; fork não herda secrets.
- V: `quickstart.md` inclui cenário verde, vermelho, indisponível e cleanup.

**Rechecagem pós-design**: interface e modelo documentados; status do Project não substitui
check obrigatório, preservando segurança e compatibilidade. Gates satisfeitos.

## Project Structure

### Documentation (this feature)

```text
specs/002-revisao-sonarqube-pr/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── contracts/sonarqube-pr.md
├── quickstart.md
├── checklists/requirements.md
└── tasks.md
```

### Source Code (repository root)

```text
.github/workflows/sonarqube-pr.yml      # proposto: check e scanner
scripts/sonarqube/sync-project-status.* # proposto: adaptação ao Project com privilégios separados
docs/sonarqube-pr.md                    # proposto: chamada e ruleset
tests/sonarqube/                       # proposto: cenários de consumo
.opencode/skills/quality-workflows/SKILL.md # proposto: prática versionada de reuso e análise local
```

**Structure Decision**: nenhum workflow de análise existe hoje; cliente configura o check
obrigatório e a instância SonarQube fora deste repositório.

## Complexity Tracking

Sem violações constitucionais identificadas.
