# Implementation Plan: Triagem de issues com Codex

**Branch**: `feature/issue-6` | **Date**: 2026-09-25 | **Spec**: [spec.md](spec.md)

**Input**: `specs/004-triagem-issues/spec.md`; delta normativo em `openspec/changes/codex-issue-triage/specs/pipelines/issue-triage/spec.md`.

## Summary

Workflow reutilizável chamado pelo consumidor faz roteamento determinístico e executa Codex CLI com modelo/prompt configuráveis. Triagem complexa fica read-only; escrita em issue simples é opt-in, sempre em branch/PR individual e sob review humana.

## Technical Context

**Language/Version**: GitHub Actions YAML; scripts shell/Node compatíveis com runner Linux, versão Codex CLI fixada e verificada antes do uso.  
**Primary Dependencies**: Codex CLI, GitHub Actions/CLI/API; contratos da issue #3 para futura integração.  
**Storage**: histórico na issue/PR e resultado dos jobs; secret exclusivamente no consumidor ou organização autorizada.  
**Testing**: fixtures de roteamento, idempotência, credencial ausente, caller entre organizações, PR e review.  
**Target Platform**: GitHub-hosted runners de repositórios consumidores.  
**Project Type**: workflow compartilhado com caller externo.  
**Performance Goals**: uma triagem por evento/issue, com timeout configurado pelo caller.  
**Constraints**: untrusted input não acessa credenciais de escrita; sem modelo fixo fictício; sem merge automático.  
**Scale/Scope**: vários consumidores/organizações, sem estado persistido fora de GitHub.

## Constitution Check

- Reuso/contrato (I/II): `workflow_call`, inputs/secrets/outputs e fixture de caller com ref estável.
- Segurança (IV): jobs read-only separados de PR opt-in, auth efêmera e sem checkout privilegiado de PR de fork.
- Validação (V): cenários de contrato em `quickstart.md` e tests/triage.
- Rechecagem pós-design: decisões acima atendem os princípios; exceção do Git Flow é própria deste repositório, stack `#3 → #6 → #7` com base final `master`.

## Project Structure

### Documentation (this feature)

```text
specs/004-triagem-issues/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── contracts/issue-triage.md
├── quickstart.md
└── tasks.md
```

### Source Code (repository root; future apply)

```text
.github/workflows/issue-triage.yml
scripts/triage/
tests/triage/fixtures/caller.yml
docs/issue-triage.md
.opencode/skills/quality-workflows/SKILL.md
```

**Structure Decision**: reutilizar padrão de `.github/workflows/` e `scripts/` já existente; conteúdo exclusivo da issue #6 entra em seu diff para a base `feature/issue-3`.

## Complexity Tracking

Nenhuma violação constitucional planejada.
