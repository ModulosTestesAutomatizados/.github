# Contrato proposto: templates e conciliação

## Issue forms em `.github/ISSUE_TEMPLATE/`

- `issuePai.yml`: única entrada de épica (migrada), título do milestone e campos obrigatórios
  de contexto/objetivos/premissas; metadados fixos da épica explicados no formulário.
- `release.yml`: release não épica, escolha PATCH/MINOR/MAJOR e orientação Estimate 7/8/9.
- `feature.yml`, `task.yml`, `hotfix.yml`: título `[FEATURE]`, `[TASK]`, `[HOTFIX]`;
  contexto/entrega/premissas e orientação de vínculo à épica e escala aplicável.
- `issueCLI.yml`: bug da CLI existente, preservando comando, ecossistema e logs obrigatórios.
- Labels só em YAML quando já existirem no repositório de uso; IDs de Projects não entram no form.

## PR em `.github/PULL_REQUEST_TEMPLATE.md`

Seções por padrão: issue vinculada, `Realização`, `Fontes modificados`, `p/ teste`,
`O que há de novo`, checklist de review/labels/milestone/Project. Distinguir palavra-chave
de fechamento em PR para principal de referência simples em PR para release/develop.

## Conciliação opcional

`.github/workflows/issue-metadata.yml` somente quando o consumidor autorizar API de escrita.
Caller/ação localiza campos reais por nome, valida permissões e tipo de issue, aplica defaults
da épica somente a ela; se vínculo/campo/opção não existir, informa metadado pendente.
Nenhum código do corpo da issue é executado; credencial de Project não é exposta em PR de fork.

Esses arquivos são caminhos propostos para a implementação; no estado atual só existem
`issueCLI.yml` e `issuePai.yml`.
