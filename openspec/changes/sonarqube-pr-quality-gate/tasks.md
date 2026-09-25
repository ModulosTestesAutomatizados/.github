# Tasks

## 1. Contrato e ambiente de teste

- [ ] 1.1 Definir caller de PR com ref revisada, inputs e secrets em `tests/sonarqube/fixtures/caller.yml`; verificar contrato `workflow_call` contra `specs/002-revisao-sonarqube-pr/contracts/sonarqube-pr.md`.
- [ ] 1.2 Preparar cenários de gate verde/vermelho/indisponível/HEAD obsoleto em `tests/sonarqube/`; verificar que nenhum resultado anterior aprova o SHA atual.

## 2. Gate e isolamento

- [ ] 2.1 Implementar `.github/workflows/sonarqube-pr.yml` com scanner isolado, menor permissão possível e saída de gate/URL/SHA; verificar lint do YAML e execução de PR verde e vermelho.
- [ ] 2.2 Garantir check falha fechada para scanner/gate indisponível, execução concorrente, fork e cancelamento; verificar que o merge protegido não é liberado por resultado anterior ou por review humana.
- [ ] 2.3 Assegurar descarte dos recursos do runner ao término ou cancelamento mantendo relatório no servidor; verificar cenário de ciclo de vida do `quickstart.md`.

## 3. Project e adoção

- [ ] 3.1 Implementar `scripts/sonarqube/sync-project-status.*` com descoberta de IDs e vínculo real issue/PR, token separado e reconciliação conservadora; verificar status `Request changes` em ambos sem afetar item sem vínculo ou alteração humana posterior.
- [ ] 3.2 Documentar caller, instância/edição SonarQube, regras de check obrigatório, credenciais, falhas e ferramentas locais em `docs/sonarqube-pr.md`; verificar execução das instruções com consumidor de teste.
- [ ] 3.3 Criar `.opencode/skills/quality-workflows/SKILL.md` versionada com contrato de caller, gate SonarQube e diagnóstico local; verificar que o exemplo da skill coincide com o caller testado e que somente arquivos da #3 entram no PR contra `master`.
