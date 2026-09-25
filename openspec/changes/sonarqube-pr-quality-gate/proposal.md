# Proposal

## Why

A issue [#3](https://github.com/ModulosTestesAutomatizados/.github/issues/3) precisa impedir merges com falhas de qualidade, mesmo quando a revisão humana já foi aprovada. Seu resultado também será consumido pela revisão automatizada da #7; por isso o contrato de check e relatório precisa existir antes das demais camadas da stack.

## What Changes

- Oferecer análise SonarQube reutilizável para cada HEAD de PR, com quality gate, relatório, check de falha fechada e exemplo de caller com referência estável.
- Refletir `Request changes` nos itens PR/issue de Project quando houver vínculo e autorização, sem simular uma review humana nem substituir o check obrigatório.
- Isolar o scanner em execução efêmera, manter o servidor e o histórico persistentes e orientar o uso local de SonarQube for IDE/Scanner.
- Registrar, na skill versionada deste repositório para workflows de qualidade, os contratos de chamada e adoção exigidos pela issue.

## Capabilities

### New Capabilities

- `pipelines/sonarqube-pr`: análise, gate e estado de revisão em PRs consumidores.

### Modified Capabilities

- Nenhuma.

## Impact

- Planejamento SpecKit já existente em `specs/002-revisao-sonarqube-pr/` será atualizado sem substituí-lo por uma cópia do OpenSpec.
- Implementação futura: `.github/workflows/sonarqube-pr.yml`, `scripts/sonarqube/`, `tests/sonarqube/`, `docs/sonarqube-pr.md` e `.opencode/skills/quality-workflows/SKILL.md`.
- Instância SonarQube e ruleset/check obrigatório precisam ser disponibilizados pelo consumidor; a branch de entrega da #3 é `feature/issue-3` com PR para `master`, seguida por #6 e #7 em bases encadeadas.
