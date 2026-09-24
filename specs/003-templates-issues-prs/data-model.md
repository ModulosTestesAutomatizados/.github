# Modelo de dados: Templates de issues e PRs

## Tipo de entrega

`epic`, `release`, `feature`, `task`, `hotfix` têm título, campos e regras distintos.
Somente `epic` corresponde 1:1 a milestone `vMAJOR.MINOR.PATCH` e recebe Release MAJOR,
Size XL, Estimate 10 e Effort Team. `release` não épica escolhe 7/8/9 por PATCH/MINOR/MAJOR;
`hotfix` recebe 6; `feature` usa 1–5 associado a XS/S/M/L/XL; `task` requer escolha de
classe de valor, sem default inventado. Estimate 0 marca homologação, não hotfix.

## Formulário de issue

Campos: `kind`, `titlePrefix` (sub-issues `[TIPO]`, épica igual a milestone),
`context` obrigatório, `deliverable` obrigatório, `premises` obrigatório, `epicReference`
e `milestoneReference` quando aplicáveis. O bug específico da CLI mantém comando, ecossistema
e logs obrigatórios como no piloto.

## Template de PR

Campos: `linkedIssue`, `realizacao`, `fontesModificados`, `paraTeste`, `oQueHaDeNovo`,
`reviewer`, `labels`, `milestone`. Não fecha automaticamente issue em PR para release/develop;
em PR para principal seguir o vínculo de fechamento definido pelo consumidor.

## Conciliação de metadados

Campos: `repository`, `issueOrPrId`, `projectId` opcional, `fieldNames`, `resolvedFieldIds`,
`desiredValues`, `unresolved`. Atualizar apenas após validação de tipo/opção e relação com
Project; `unresolved` comunica pendência ao usuário sem inventar ID.
