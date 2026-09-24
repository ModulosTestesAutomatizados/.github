# Implementation Plan: Templates de issues e PRs

**Branch**: `feature/sdd` (planejamento) | **Date**: 2026-09-23 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/003-templates-issues-prs/spec.md`

## Summary

Formulários de issue por tipo e um template de PR com conteúdo padronizado; respeitar o que
o formulário GitHub preenche nativamente e conciliar metadados externos em automação opcional,
com descoberta de campos, permissões e fallback manual. Migrar pilotos sem perder bug da CLI.

## Technical Context

**Language/Version**: Markdown e YAML de issue forms/GitHub Actions; integração de metadados
por API GitHub se necessária

**Primary Dependencies**: GitHub Issue Forms, PR templates, Issues API e Projects API

**Storage**: arquivos versionados de templates; metadados de issues/PRs/Projects no GitHub

**Testing**: validação YAML e formulário na UI, criação de cinco issues e PR de exemplo,
verificação de Project com e sem campos e comparação com templates piloto

**Target Platform**: repositório organizacional `.github` e consumidores GitHub compatíveis

**Project Type**: catálogo de templates de colaboração com integração GitHub opcional

**Performance Goals**: preencher novo card de tipo conhecido em até 5 min

**Constraints**: forms não criam automaticamente parent/milestone/Project Fields; nunca
fixar ID de campo entre organizações; não presumir labels/assignees existentes

**Scale/Scope**: cinco categorias de issue e um PR; migração de dois templates piloto

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- I/III: formatos reutilizáveis, distinguíveis e com apenas campos úteis; piloto específico
  da CLI fica identificado como exceção existente, sem forçar consumidores.
- II: formato, limitação e migração documentados, sem alteração silenciosa.
- IV: conciliação usa permissão mínima e não executa código vindo de formulário.
- V: exemplo de consumo, cenários de UI e ausência de Projects no quickstart.

**Rechecagem pós-design**: separação entre forms e automação de metadados explícita no
contrato; preservação de `issueCLI.yml` e migração de `issuePai.yml` previstas. Gates satisfeitos.

## Project Structure

### Documentation (this feature)

```text
specs/003-templates-issues-prs/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── contracts/templates.md
├── quickstart.md
├── checklists/requirements.md
└── tasks.md
```

### Source Code (repository root)

```text
.github/ISSUE_TEMPLATE/issueCLI.yml    # existente; manter compatibilidade
.github/ISSUE_TEMPLATE/issuePai.yml    # existente; migrar épica
.github/ISSUE_TEMPLATE/release.yml     # proposto
.github/ISSUE_TEMPLATE/feature.yml     # proposto
.github/ISSUE_TEMPLATE/task.yml        # proposto
.github/ISSUE_TEMPLATE/hotfix.yml      # proposto
.github/PULL_REQUEST_TEMPLATE.md       # proposto
.github/workflows/issue-metadata.yml   # proposto; opcional e com guardas
scripts/templates/                     # proposto; conciliação por IDs resolvidos
docs/templates.md                      # proposto; consumo e limitações
tests/templates/                       # proposto; validação e cenários
```

**Structure Decision**: reusar `issuePai.yml` para épica corrigindo-o, não criar formulário
duplicado; manter `issueCLI.yml` como especialização de bug da CLI.

## Complexity Tracking

Sem violações constitucionais identificadas.
