# Modelo de dados: Revisão SonarQube em PRs

Sem banco local; referências são mantidas pelas plataformas integradas.

## Análise

Campos: `repository`, `prNumber`, `headSha`, `projectKey`, `scanRunId`, `reportUrl`,
`state` (`queued|running|passed|failed|unavailable`). Novo HEAD invalida check anterior.

## Quality gate

Campos: `analysisId`, `conditions` (lista de critério/valor/status), `result`
(`passed|failed|unavailable`), `checkedAt`. Somente `passed` habilita check verde; falhas
críticas e ausência de resposta são estados diferentes com resultado bloqueador.

## Vínculo de Project

Campos: `projectId`, `prItemId`, `issueItemId` (opcional), `previousStatus`, `lastAppliedStatus`,
`updatedHeadSha`. Atualização só se item correto e opção `Request changes` existirem;
restauração só se valor ainda for o colocado pela automação.

## Ciclo de vida

`queued → running → passed|failed|unavailable`; `failed` pode projetar status nos itens;
`passed` posterior reconcilia apenas estados automáticos; em todo encerramento/cancelamento
o runner temporário é liberado, mantendo `reportUrl` quando disponível.
