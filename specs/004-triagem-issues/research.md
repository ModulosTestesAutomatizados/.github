# Research: triagem Codex

## Chamada e autenticação

- **Decision**: usar `workflow_call`; caller define eventos e passa secrets explicitamente, com `secrets: inherit` somente quando suportado na mesma organização/enterprise. Fora disso cada consumidor configura sua própria credencial.
- **Rationale**: reusable workflows não capturam os eventos do consumidor, nem centralizam automaticamente secrets entre organizações.
- **Alternatives considered**: workflow monolítico copiado por repo; secret único hospedado na organização fornecedora para outra organização.
- **Reference**: https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows

## Codex CLI headless

- **Decision**: `codex exec` não interativo, sandbox read-only por padrão, workspace-write somente em job opt-in e branch efêmera; modelos escolhidos por configuração real da instalação pinada.
- **Rationale**: mantém planejamento sem escrita e isola o contexto de PR.
- **Alternatives considered**: deixar prompts definirem privilégios ou usar identificadores de modelo inventados no exemplo da issue.
- **Reference**: https://github.com/openai/codex/blob/main/codex-rs/exec/src/cli.rs

## Eventos e idempotência

- **Decision**: permitir `issues` por padrão; filtros de autor para comentários e `workflow_run`, chave de idempotência e exclusão de eventos do bot; CI oferece diagnóstico antes de qualquer proposta de mudança.
- **Rationale**: `workflow_run` pode herdar segredos/escrita mesmo após workflow sem privilégios.
- **Alternatives considered**: acionar todos os eventos do exemplo sem filtro.
- **Reference**: https://docs.github.com/en/actions/reference/security/secure-use
