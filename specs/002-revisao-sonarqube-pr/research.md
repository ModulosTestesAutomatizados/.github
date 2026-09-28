# Research: Revisão SonarQube em PRs

## Decisão: gate e bloqueio de merge

- **Decision**: análise por PR/HEAD via scanner, qualidade calculada no SonarQube e check
  obrigatório na proteção da branch do consumidor. Check falha se não houver aprovação válida.
- **Rationale**: SonarQube documenta decoração de PR e reporte de quality gate no GitHub;
  branch ruleset/branch protection faz o bloqueio real.
- **Alternatives considered**: somente mudar campo de Project não bloqueia merge.
- **Referência**: https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/ci-integration/github-actions.md

## Decisão: política de qualidade

- **Decision**: 100% dos critérios do quality gate para código novo devem passar; falha crítica
  reprova. Cobertura 100% de todo o legado não é requisito inferido.
- **Rationale**: separa aprovação integral da política do percentual de cobertura.
- **Alternatives considered**: afirmar qualidade absoluta de 100% sem métrica verificável.

## Decisão: sincronização Project e review humano

- **Decision**: `Request changes` é um estado do Project; atualizar itens vinculados por ID
  apenas com permissão explícita e registrar autoria/status anterior para reconciliação.
- **Rationale**: check é a barreira técnica; workflow não pode falsificar review humana.
- **Alternatives considered**: emitir review automática de REQUEST_CHANGES foi descartada.

## Decisão: execução efêmera

- **Decision**: scanner em job/container descartável, SonarQube Server gerenciado e persistente.
- **Rationale**: encerrar o servidor apagaria histórico e afetaria PRs simultâneos.
- **Alternatives considered**: criar uma instância SonarQube por PR não é escalável.
- **Referência**: https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/setting-up-the-pull-request-analysis.md
