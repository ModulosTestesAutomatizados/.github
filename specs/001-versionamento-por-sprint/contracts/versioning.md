# Contrato proposto: workflows de versionamento

## Prévia: `.github/workflows/version-preview.yml`

- `workflow_call` com `adapter` obrigatório (`standard-version|changesets|jgitver|go-gitsemver`),
  `release_branch` obrigatório e `project_path` opcional (default `.`).
- Caller executa em `pull_request` (`opened`, `synchronize`, `reopened`) com `contents: read`,
  `pull-requests: read`, `issues: read`; PR de fork não recebe credencial de publicação.
- Saídas: `bump`, `candidate_version`, `summary`; erro quando dados são inválidos.
- O contrato é somente leitura; não cria tag, release nem modifica arquivos do consumidor.

## Publicação: `.github/workflows/version-publish.yml`

- `workflow_call` com `adapter`, `release_branch`, `project_path` e `target_branch`
  obrigatórios; `changelog_path` opcional. Requer `contents: write` apenas na chamada de
  publicação; restrição por branch/ambiente cabe ao consumidor.
- Caller dispara após merge para `target_branch` (branch padrão), requer ambiente protegido
  `homologation_environment` e utiliza `concurrency` por repositório/destino (sem cancelamento
  da execução ativa). O workflow valida PR aprovado, milestone/épica fechadas e homologação.
- Saídas: `version`, `tag`, `release_url`, `outcome` (`published|already-published|conflict`).
- Tag existente no mesmo commit é reconciliada; tag noutro commit interrompe sem overwrite.
  Configuração ausente ou gate pendente falha sem efeitos irreversíveis.
- `project_path` escolhe um pacote em monorepos Changesets; nesse perfil tag/release são
  `@scope/name@versão` por pacote, não uma versão única do monorepo inteiro.

## Compatibilidade e integração

Caller fixa SHA ou referência estável revisada, nunca uma branch de desenvolvimento; a versão
do contrato é independente do SemVer da constituição. Exemplos dos quatro perfis são
documentados em `docs/versioning.md`. Os caminhos acima são interfaces propostas, não arquivos
existentes no repositório nesta etapa de planejamento.
