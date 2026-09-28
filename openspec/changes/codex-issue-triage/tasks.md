# Tasks

## 1. Contrato e roteamento

- [ ] 1.1 Formalizar entradas, defaults, saídas, secrets, eventos e caller em `specs/004-triagem-issues/contracts/issue-triage.md`; verificar exemplo de chamada para issue aberta com ref fixa.
- [ ] 1.2 Implementar roteador determinístico e prompts versionados em `scripts/triage/` com modelo configurável por ação; verificar decisões de issue complexa/simples, comentário autorizado e falha de CI em testes de fixtures.

## 2. Execução Codex com privilégio mínimo

- [ ] 2.1 Implementar `.github/workflows/issue-triage.yml` para triagem/planejamento não interativo read-only; verificar comentário ou PR de planejamento da issue complexa sem alteração direta da branch base.
- [ ] 2.2 Implementar restauração efêmera da credencial Codex por secret do caller e limpeza em todas as saídas; verificar falta de secret, ausência de dados em logs e fluxo entre organizações sem herança indevida.
- [ ] 2.3 Implementar correção simples opt-in em branch única por issue e PR para a base configurada com revisão humana; verificar ausência de auto-merge e de escrita no job de triagem.
- [ ] 2.4 Tratar eventos opcionais `issue_comment`, `pull_request_review_comment` e `workflow_run` sem confiar em conteúdo do PR, com idempotência/filtro de bot; verificar reexecução e prevenção de loop.

## 3. Documentação, skill e consumo

- [ ] 3.1 Entregar `docs/issue-triage.md` e fixture `tests/triage/fixtures/caller.yml` para configurações na mesma organização e entre organizações, modelos, prompts, falhas e permissões; verificar execução controlada com consumidor de teste.
- [ ] 3.2 Atualizar `.opencode/skills/quality-workflows/SKILL.md` com obrigação de caller versionado, interface e decisões de triagem; verificar paridade entre skill, contrato e fixture e diff exclusivo da issue #6 em PR para `feature/issue-3`.
