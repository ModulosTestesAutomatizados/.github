# Versionamento compartilhado por sprint

Os workflows reutilizáveis de `.github/workflows/` são chamados explicitamente pelo
consumidor; o checkout de `.shared-versioning` usa a **mesma revisão** da chamada
(`job.workflow_sha`). Os scripts em `scripts/versioning/` são executados a partir
dessa revisão compartilhada: o consumidor não precisa copiá-los.

## Fluxo e gates

| Transição | Check de leitura (`version-preview.yml`) | Escrita |
| --- | --- | --- |
| `feature/* → release/vX.Y.Z` | Sub-issue da épica e milestone da sprint | Nenhuma |
| `release/vX.Y.Z → develop` | Épica encerrada e milestone concluída após homologação breve; inicia homologação completa em develop | Nenhuma; guia provisório opcional |
| `develop → main/master` | Épica/milestone concluídas, PR de release já integrado a `develop`, review vigente e `Homologação: aprovada` no PR final | Nenhuma no PR |
| `versioning/* → main/master` | Verifica proveniência do merge homologado e limita o diff a arquivos de versão | Nenhuma antes de checks/review |
| `push` após merge funcional na principal | Reconfere milestone, épica, review, homologação e SHA | Node abre PR de versão; Go/Java podem publicar direto |
| `push` após merge do PR de versão | Reconfere vínculo à entrega e diff integrado | Publica tag/release no SHA **versionado** |

`vX.Y.Z` da milestone nomeia a sprint e **não determina** a versão da aplicação.
Prévia de SemVer, versão em arquivo e changelog não são exigidos nos PRs funcionais.
O guia provisório usa títulos dos commits desde `develop`, não publica artefatos e
pode falhar sem bloquear o check obrigatório. O arquivo indicado por
`changelog_path` só é lido no commit publicável; se não existir, a release usa
um resumo da sprint.

O consumidor precisa de branch protection com status de PR, CI e revisão
humana, além de environment `homologation` com aprovação para publicar. O
registro `Homologação: aprovada` no PR final deve ser feito após a validação
humana e não substitui aprovação da environment. `develop → main/master` é
aceito apenas se o PR de `release/vX.Y.Z → develop` pertence ao histórico e foi
aprovado; PR de versão exige review independente.

## Contrato `workflow_call`

| Workflow | Entradas | Saídas | Permissões do caller |
| --- | --- | --- | --- |
| `version-preview.yml` | `adapter`, `release_branch`, `target_branch`; `project_path` opcional | `phase`, `summary` | `contents: read`, `pull-requests: read`, `issues: read` |
| `version-publish.yml` | `adapter`, `release_branch`, `target_branch`, `homologation_environment`; `project_path`, `changelog_path` opcionais | `version`, `tag`, `release_url`, `version_pr_url`, `outcome` | `contents: write`, `pull-requests: read`, `issues: read` |

`version-publish.yml` aceita o secret opcional `versioning_token`. Para Node,
ele é **obrigatório na prática**: use token de GitHub App (ou credencial de
automação com `contents: write` e `pull-requests: write`) capaz de abrir PR e
disparar os checks sob as proteções do consumidor. O `GITHUB_TOKEN` do job
continua disponível para `gh api`, tag e GitHub Release. O antigo `unset` em
`prepare-release.sh` rodava em um subprocesso e **não** removia o token de
`publish.sh`; portanto comentá-lo não corrigia uma falha real de autenticação.
Não transmitir token de escrita a PR de feature ou fork.

`outcome` pode ser `pending-version-pr`, `published`, `already-published` ou
`conflict`. Na primeira fase Node, `version_pr_url` identifica a aprovação
pendente; após merge, `tag` e `release_url` são preenchidos. Nenhuma tag é
sobrescrita. Reexecução do mesmo SHA completa somente release ausente ou retorna
`already-published`; tag noutro commit retorna conflito. Em caso de avanço da
branch antes do PR de versão, a execução interrompe e pede novo cálculo/review.

## Perfis e arquivos

| Adaptador | Projeto selecionado | Preparação pós-merge |
| --- | --- | --- |
| `standard-version` | Diretório com `package.json` e lockfile | Atualiza `package.json`/lockfile/changelog em PR, sem tag ou commit direto na principal. Usa commits desde último marco publicado, incluindo vários PRs da mesma release. |
| `changesets` | Pacote `@scope/name` em monorepo com `.changeset/config.json` | `changeset version` atualiza pacote selecionado, changelog e lockfile; tag `@scope/name@versão` após merge do PR de versão. Um caller por pacote. |
| `jgitver` | Módulo Maven com `pom.xml` e `.mvn/extensions.xml` | Lê versão estável derivada do Git no commit integrado; prerelease é recusada. |
| `go-gitsemver` | Projeto Go | Lê versão estável derivada do Git no commit integrado; prerelease é recusada. |

Adaptador desconhecido, caminho fora do checkout e versão instável falham antes
de publicar. A CI de build/teste (TypeScript, Spring Boot, Go e Node) pertence
ao **consumidor**, não ao workflow de versionamento. Para configurações de
`standard-version` que atualizam outros arquivos além dos acima, estenda e
revise a lista de artefatos permitidos antes da adoção.

## Exemplo de caller para uma rodada

Publique primeiro uma revisão estável do compartilhado e substitua
`SEU_SHA_COMPARTILHADO` pelo SHA completo **existente**, ou use uma tag `v1`
somente depois de criá-la. Ajuste `target_branch` para `master` quando for a
principal. Um perfil de publicação por rodada no mesmo LocalLabs evita colisões
de tags entre os três perfis que usam `vX.Y.Z`.

```yaml
name: Versionamento do consumidor
on:
  pull_request:
    types: [opened, reopened, synchronize, edited, ready_for_review]
  pull_request_review:
    types: [submitted, dismissed]
  push:
    branches: [main]
jobs:
  validate-pr:
    if: github.event_name == 'pull_request' || github.event_name == 'pull_request_review'
    permissions: {contents: read, pull-requests: read, issues: read}
    uses: ModulosTestesAutomatizados/.github/.github/workflows/version-preview.yml@SEU_SHA_COMPARTILHADO
    with:
      adapter: standard-version
      project_path: examples/standard-version
      release_branch: release/v1.2.3
      target_branch: main
  publish:
    if: github.event_name == 'push' && github.ref_name == 'main'
    permissions: {contents: write, pull-requests: read, issues: read}
    uses: ModulosTestesAutomatizados/.github/.github/workflows/version-publish.yml@SEU_SHA_COMPARTILHADO
    with:
      adapter: standard-version
      project_path: examples/standard-version
      release_branch: release/v1.2.3
      target_branch: main
      homologation_environment: homologation
      changelog_path: examples/standard-version/CHANGELOG.md
    secrets:
      versioning_token: ${{ secrets.VERSIONING_TOKEN }}
    concurrency:
      group: version-publish-${{ github.repository }}-main
      cancel-in-progress: false
```

## Roteiro de homologação no LocalLabs

1. Com acesso de escrita, crie `develop` e uma `release/vX.Y.Z` **distinta por
   rodada**. Crie a milestone `vX.Y.Z`, épica de mesmo título e sub-issues de
   features. Configure regras de proteção da principal e `develop`: review
   humano, status do check `validate-pr / preview` (confira nome exato no GitHub)
   e CI própria. Crie environment `homologation` com revisores obrigatórios.
2. Instale ferramentas/build do perfil e habilite apenas o job de PR. Mova o
   caller de ensaio de `tests/versioning/fixtures/caller.yml` do consumidor para
   `.github/workflows/`; a ref do compartilhado deve existir. Abra feature →
   release, release → develop e develop → principal, conferindo sucesso, falha
   por vínculo ausente e ausência de tags. O guia de homologação é opcional.
3. Após aprovação, habilite **um** perfil de publicação. Para Node, confira
   merge funcional → PR de versão → CI/review → merge → tag/release no SHA do
   commit versionado. Para Go/Java derivados de Git, confira tag/release no SHA
   funcional e versão estável. Repita para `standard-version`, `changesets`,
   `jgitver` e `go-gitsemver`, com versões/commits diferentes. Em
   `standard-version` inclua vários PRs na mesma release sem tag intermediária.
4. Repita a publicação dez vezes, ensaie concorrência e uma tag divergente em
   rodada isolada; confira que tags jamais se movem e release não duplica. Para
   falha após criar tag, retome apenas a release com SHA idêntico.
5. Registre por rodada URLs de PRs/checks, aprovação de environment, SHA de
   integração/versão, tag, GitHub Release, idempotência e diagnóstico de conflito
   em `LocalLabs/tests/versioning/validation-results.md`.

### Verificações locais do compartilhado

```bash
node tests/versioning/pr-check.mjs
node tests/versioning/post-merge.mjs
bash -n scripts/versioning/*.sh
openspec validate corrigir-versionamento-pos-merge --strict
```

Os ensaios locais simulam a API GitHub e o adaptador; eles não substituem o
ensaio hospedado com ferramentas reais e proteções configuradas.
