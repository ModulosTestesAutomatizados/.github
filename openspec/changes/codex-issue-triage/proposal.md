# Proposal

## Why

A issue [#6](https://github.com/ModulosTestesAutomatizados/.github/issues/6) pede triagem automática e reutilizável para novas issues, sem copiar lógica de decisão em cada aplicação. A solução estabelece o contrato de execução de Codex CLI que a #7 reutilizará depois do gate da #3.

## What Changes

- Disponibilizar workflow de triagem chamado por consumidores, com caller versionado e documentado, entradas, secrets, permissões e saídas explícitas.
- Escolher modelo e template de prompt por evento e complexidade, produzir planejamento OpenSpec/SpecKit para questões complexas e, somente quando permitido, abrir PR individual para correções simples sem merge automático.
- Permitir diagnóstico de falhas de CI e comentários de review autorizados com roteamento limitado, idempotência e proteção contra loops.
- Documentar autenticação Codex CLI, opções de centralização dentro da mesma organização/enterprise, configuração por consumidor entre organizações e fallback claro quando não houver credencial.
- Ampliar a skill versionada em `.opencode/skills/quality-workflows/SKILL.md` com padrão obrigatório de caller e configurações aceitáveis.

## Capabilities

### New Capabilities

- `pipelines/issue-triage`: roteamento de issues e eventos, execução Codex e entrega rastreável por PR.

### Modified Capabilities

- Nenhuma.

## Impact

- Implementação futura: `.github/workflows/issue-triage.yml`, `scripts/triage/`, `docs/issue-triage.md`, `tests/triage/`, `.opencode/skills/quality-workflows/SKILL.md`.
- SpecKit exclusivo da #6: `specs/004-triagem-issues/` (reserva o prefixo `003` já usado pela issue #4 em `master`).
- Branch `feature/issue-6` parte de `feature/issue-3`, PR para ela; não modifica artefatos planejados da #3 no diff desta issue.
