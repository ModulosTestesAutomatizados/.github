# Data Model: revisão e gate por PR

## Revisão

- `repo`, `prNumber`, `headSha`, `baseRef`, `sourceTrust`, `model`, `promptVersion`, `reviewStatus`, `reportRef`.
- Estados: recebida → revisão → sem mudanças | correção única | sugestões → gate → aprovada | bloqueada | indisponível.

## Correção

- `originalSha`, `newSha`, `committerIdentity`, `attemptConsumed`, `newRunRef`; `attemptConsumed` é associado ao PR, não reiniciado por cada novo HEAD.
- Sem commit em fork/branch sem permissão; o run do SHA antigo jamais aprova novo SHA.

## Gate

- `analyzedSha`, `gate` (`passed|failed|unavailable`), `reportUrl`, `projectLink` opcional e `reviewStatus`.
- A aprovação técnica requer ambos os resultados válidos para o mesmo HEAD; análise inconclusiva preserva necessidade de decisão humana.
