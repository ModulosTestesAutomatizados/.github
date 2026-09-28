# Proposal

## Why

A issue [#7](https://github.com/ModulosTestesAutomatizados/.github/issues/7) pede revisão automatizada de qualquer PR antes da validação profunda da #3. Depende do roteamento/modelos/prompts da #6 e do quality gate SonarQube da #3 para produzir um fluxo verificável sem aprovar código inadequado.

## What Changes

- Criar workflow reutilizável de code review com Codex CLI acionado por caller em todo PR, independentemente da branch.
- Registrar revisão e eventuais sugestões ou mudanças limitadas no próprio PR; acionar a análise SonarQube após estabilizar o HEAD, evitando checks verdes de commit obsoleto e loops.
- Quando a revisão ou o gate encontrarem falha, emitir evidência no PR, manter o bloqueio de merge e encaminhar para revisão humana; preservar a sincronização `Request changes` prevista na #3.
- Entregar contrato de caller, modelos/prompts configuráveis e atualização da skill versionada de workflows de qualidade.

## Capabilities

### New Capabilities

- `pipelines/codex-pr-review`: revisão automatizada por PR, iteração controlada e orquestração do gate SonarQube.

### Modified Capabilities

- Nenhuma; os contratos planejados das #3 e #6 são consumidos, sem alteração em seus arquivos na PR da #7.

## Impact

- Implementação futura: `.github/workflows/codex-pr-review.yml`, `scripts/review/`, `tests/review/`, `docs/codex-pr-review.md` e atualização da `.opencode/skills/quality-workflows/SKILL.md`.
- SpecKit exclusivo da #7 em `specs/005-revisao-pr-codex/`; branch `feature/issue-7` baseada em `feature/issue-6`, PR para essa branch.
