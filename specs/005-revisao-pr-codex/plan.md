# Implementation Plan: Revisão Codex seguida de SonarQube

**Branch**: `feature/issue-7` | **Date**: 2026-09-25 | **Spec**: [spec.md](spec.md)

**Input**: `specs/005-revisao-pr-codex/spec.md`, delta OpenSpec `openspec/changes/codex-pr-review-orchestration/specs/pipelines/codex-pr-review/spec.md`.

## Summary

Orquestrar revisão Codex por PR e gate SonarQube por HEAD. Se revisão gerar commit confiável, abandonar aprovação do run antigo e iniciar novo run no HEAD atualizado; o gate da #3 permanece a fonte do bloqueio de qualidade.

## Technical Context

**Language/Version**: GitHub Actions YAML, scripts shell/Node dos padrões do repositório, Codex CLI pinado conforme #6.  
**Primary Dependencies**: contrato `issue-triage` da #6 para modelos/prompts e workflow `sonarqube-pr` da #3 para `gate/report_url/analyzed_sha`.  
**Storage**: relatórios/checks GitHub e SonarQube persistente; sem armazenamento adicional.  
**Testing**: fixtures com PR sem mudança, novo HEAD, fork, atualização concorrente, gate vermelho e indisponível.  
**Target Platform**: callers de PR em repositórios GitHub.  
**Project Type**: workflow compartilhado com composição de jobs.  
**Performance Goals**: check vinculável ao HEAD, no máximo uma iteração automática por PR.  
**Constraints**: segredo não alcança checkout de fork; `GITHUB_TOKEN` não pode ser pressuposto como gatilho de novo evento; review humana mantida.  
**Scale/Scope**: PRs de qualquer base/head e organizações autorizadas pelo caller.

## Constitution Check

- I/II: caller pequeno e ref estável; entradas/saídas documentadas; reaproveitar contratos da #3/#6 sem copiar lógica.
- IV: separar revisão read-only de eventual escrita e do token SonarQube; forks só sugestões.
- V: testar caso sem mudança, novo HEAD, falha crítica, revisão concorrente e consumos em repo de teste.
- Pós-design: o gate real depende de ruleset do consumidor; sem violação da constituição.

## Project Structure

### Documentation (this feature)

```text
specs/005-revisao-pr-codex/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── contracts/codex-review.md
├── quickstart.md
└── tasks.md
```

### Source Code (repository root; future apply)

```text
.github/workflows/codex-pr-review.yml
scripts/review/
tests/review/fixtures/caller.yml
docs/codex-pr-review.md
.opencode/skills/quality-workflows/SKILL.md
```

**Structure Decision**: integração nova isolada da triagem da #6, reuso do scanner da #3 e skill alterada apenas na PR da #7.

## Complexity Tracking

Nenhuma violação constitucional identificada.
