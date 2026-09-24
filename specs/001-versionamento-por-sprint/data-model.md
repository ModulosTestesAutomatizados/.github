# Modelo de dados: Versionamento por sprint

Não há banco de dados. Os objetos abaixo representam entradas e estados observáveis.

## Sprint

Campos: `milestone` (obrigatório, formato `vMAJOR.MINOR.PATCH`), `epicIssue` (referência),
`releaseBranch` (`release/<milestone>`), `homologated` (verdadeiro antes de publicar).
Uma sprint agrega várias issues/PRs; seu identificador não substitui a versão do consumidor.

## Candidato de versão

Campos: `repository`, `prNumber`, `baseRef`, `headSha`, `adapter` (um dos quatro perfis),
`bump` (`major|minor|patch|none`), `candidateVersion`, `diagnostics`. Somente leitura;
recalculado para commits novos e inválido se a base mudou.

## Publicação

Campos: `repository`, `targetRef`, `commitSha`, `version`, `tag`, `releaseUrl`, `changelogPath`
(opcional), `state` (`pending|published|conflict|failed`). Uma tag identifica no máximo um
commit; `published` só ocorre se tag/release e commit coincidirem. Reexecutar no mesmo commit
devolve a mesma publicação; divergência leva a `conflict` sem escrita forçada.

## Transições

`PR aberto/atualizado → candidato calculado → PR aprovado/homologado → merge → publicação
pendente → publicado`. Erros de metadados bloqueiam o candidato; conflito preserva a última
publicação íntegra para correção manual.
