# Tasks

## 1. Integrações da stack

- [ ] 1.1 Confirmar que `.github/workflows/sonarqube-pr.yml` da #3 e o roteamento/modelos da #6 estão presentes na base `feature/issue-6`; verificar contratos de `gate`, `report_url`, `analyzed_sha` e autenticação antes de conectar a #7.
- [ ] 1.2 Definir caller de qualquer PR em `tests/review/fixtures/caller.yml` e contrato de `specs/005-revisao-pr-codex/contracts/codex-review.md`; verificar entradas, permissões e refs estáveis com lint de workflow.

## 2. Revisão e iteração finita

- [ ] 2.1 Implementar `.github/workflows/codex-pr-review.yml` e `scripts/review/` com modelo/prompt configuráveis, revisão não interativa e relatório por HEAD; verificar PR sem alterações e sem filtro de branch.
- [ ] 2.2 Limitar autocorreção a uma por PR, isolar credenciais e permitir commit somente em PR confiável com nova execução real; verificar teste para push via credencial autorizada, fork sem escrita e nenhuma aprovação pelo run antigo.
- [ ] 2.3 Criar marcador idempotente e checagens de SHA em `scripts/review/`; verificar concorrência, reexecução do bot e prevenção de loop sem perder review humana.

## 3. SonarQube e diagnóstico

- [ ] 3.1 Encadear análise da #3 após revisão do HEAD vigente, conferir `analyzed_sha` e exigir gate válido no check combinado; testar HEAD inalterado, novo commit e resultado obsoleto.
- [ ] 3.2 Publicar achados e link de relatório no PR, encaminhar falha crítica ou indisponibilidade para análise humana e integração `Request changes` da #3 quando aplicável; verificar check reprovado sem forjar review humana.
- [ ] 3.3 Documentar caller, modelos/prompts, secrets, permissões e falhas em `docs/codex-pr-review.md` e atualizar `.opencode/skills/quality-workflows/SKILL.md`; verificar paridade entre documentação, fixture, skill e diff exclusivo da #7 em PR para `feature/issue-6`.
