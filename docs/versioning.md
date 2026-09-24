# Versionamento compartilhado por sprint

Os workflows `.github/workflows/version-preview.yml` e `version-publish.yml` são
**chamados** por repositórios consumidores. Eles não se propagam automaticamente
por esta organização. O `project_path` seleciona um projeto ou, para Changesets,
um pacote de um monorepo; não é um comando executável vindo de PR.

## Contratos e acesso

| Contrato | Gatilho no consumidor | Permissões mínimas | Resultado |
| --- | --- | --- | --- |
| `version-preview.yml` | `pull_request` aberto/atualizado/reaberto | `contents: read`, `pull-requests: read`, `issues: read` | `bump`, `candidate_version`, `summary` no check e nas saídas, sem publicar |
| `version-publish.yml` | `push` na branch principal após PR integrado | `contents: write`, `pull-requests: read`, `issues: read` | `version`, `tag`, `release_url`, `outcome` (`published`, `already-published`, `conflict`) |

Os dois callers devem fixar um SHA do repositório compartilhado ou uma tag de
contrato estável, por exemplo `@v1`, **depois que essa referência existir**.
O workflow usa `job.workflow_repository` e `job.workflow_sha` para buscar os scripts
da mesma revisão do workflow chamada; o primeiro checkout é do consumidor.
O exemplo executável em [LocalLabs](https://github.com/GersonTekSystem/LocalLabs)
fica em `tests/versioning/fixtures/caller.yml` até que a referência estável, a
milestone e as proteções do consumidor estejam configuradas.

Nenhum secret é necessário na prévia; ela usa somente o token de leitura. O job
de publicação exige uma environment de homologação protegida por revisores no
consumidor (`homologation_environment`), aprovação efetiva do PR e o registro
`Homologação: aprovada` no corpo revisado do PR. Também exige a milestone
`vMAJOR.MINOR.PATCH` **fechada, sem issues abertas**, a épica de mesmo título
fechada e o merge de `develop` (ou `release/v...`) na branch padrão. Exigir
status checks e revisão humana nas regras de proteção do consumidor; a
automação não substitui essas regras. Somente `push` no destino publica.

Na prévia, o PR deve mencionar `Refs #N` (ou `Fixes/Closes/Resolves #N`) no corpo;
a issue N deve pertencer à milestone da branch `release/vMAJOR.MINOR.PATCH`.
PRs empilhados para `feature/*` e PRs para `develop` apenas produzem prévia.
Uma falha de configuração impede publicação, nunca move uma tag existente.

## Adaptadores

| `adapter` | `project_path` | Prévia | Publicação |
| --- | --- | --- | --- |
| `standard-version` | pasta com `package.json`, selecionada por `project_path` | `standard-version --dry-run` mais validação de Conventional Commits; quando a versão já foi registrada no PR, usa a versão do commit, sem segundo bump | versão **já registrada** no `package.json` do commit integrado; crie/valide changelog na release branch antes do merge, sem publicar tag antes |
| `changesets` | pasta de um pacote `@scope/name` com `package.json`; raiz com `.changeset/config.json` | `changeset status --output` em diretório temporário, buscando o pacote selecionado | `changeset version` deve ter sido integrado antes; cria tag/release `@scope/name@versão` para esse pacote. Use um caller por pacote para múltiplos pacotes |
| `jgitver` | módulo Maven com `pom.xml` e `.mvn/extensions.xml` | lê `project.version` da extensão instalada | requer `project.version` estável (sem `-SNAPSHOT`) no commit integrado |
| `go-gitsemver` | repositório Go (`project_path` usualmente `.`) | lê `SemVer` do binário instalado e commits interpretáveis | requer SemVer estável no commit integrado; alinhe configuração de branch principal e tags |

Adaptadores rejeitam ferramenta ausente, perfil desconhecido, projeto fora do
checkout e commits sem Conventional Commit. Para Node, o workflow instala as
dependências do consumidor pelo lockfile com scripts de instalação desativados;
para Java e Go, prepara runtime e binário de Go fixado em revisão. O cálculo
de `go-gitsemver`/`jgitver` pode produzir prerelease em branches intermediárias:
a publicação exige versão estável. O suporte a monorepos Changesets é **por
pacote selecionado**, não há uma única versão global para todos os pacotes.

## Exemplo de caller por perfil

O job abaixo usa a mesma estrutura para os quatro perfis; configure **um par
de jobs por pacote/projeto** quando houver várias unidades versionadas. `@v1`
é uma referência ilustrativa que precisa ser publicada antes de ativar o caller.

```yaml
name: Versão da sprint
on:
  pull_request:
    types: [opened, synchronize, reopened]
  push:
    branches: [main]
jobs:
  preview:
    if: github.event_name == 'pull_request'
    permissions: {contents: read, pull-requests: read, issues: read}
    uses: ModulosTestesAutomatizados/.github/.github/workflows/version-preview.yml@v1
    with:
      adapter: standard-version
      project_path: examples/standard-version
      release_branch: release/v1.0.0
  publish:
    if: github.event_name == 'push' && github.ref_name == 'main'
    permissions: {contents: write, pull-requests: read, issues: read}
    uses: ModulosTestesAutomatizados/.github/.github/workflows/version-publish.yml@v1
    with:
      adapter: standard-version
      project_path: examples/standard-version
      release_branch: release/v1.0.0
      target_branch: main
      homologation_environment: homologation
      changelog_path: examples/standard-version/CHANGELOG.md
    concurrency:
      group: version-publish-${{ github.repository }}-main
      cancel-in-progress: false
```

Para os demais perfis, substitua apenas `adapter` e `project_path`:

| Perfil | `adapter` | `project_path` do exemplo LocalLabs |
| --- | --- | --- |
| Pacote Node | `standard-version` | `examples/standard-version` |
| Monorepo | `changesets` | `examples/changesets` |
| Java | `jgitver` | `examples/jgitver` |
| Go | `go-gitsemver` | `examples/go-gitsemver` |

O `changelog_path` é opcional e só deve ser fornecido quando o arquivo já
estiver no commit integrado. Se ausente, a release inclui resumo da sprint.
Não execute `standard-version` com tagging na branch de release: registre
versão/changelog antes da homologação e deixe tag/release para o fluxo pós-merge.

## Colisão, recuperação e versionamento do contrato

O grupo de concorrência por repositório/destino evita duas execuções de
publicação simultâneas no mesmo caller; o `POST git/refs` é create-only e a
implementação consulta novamente a referência em caso de corrida. Reexecutar
no mesmo SHA preserva a tag e reutiliza a release; tag em outro SHA falha com
`conflict`, sem force-push. Se a tag foi criada mas a release falhou, repetir
após corrigir o erro conclui a release existente. Não refazer uma tag publicada.

Antes de publicar nova versão incompatível destes workflows, manter a ref
anterior e documentar a migração dos callers. A versão deste contrato é
independente da versão da constituição. Resultados de PR são checks/jobs e
resumos no GitHub; não simulam aprovação humana.

## Validação local

No clone LocalLabs, após `npm ci`, execute (ajustando o caminho):

```bash
SHARED_REPO="C:/caminho/para/.github" npm test
SHARED_REPO="C:/caminho/para/.github" bash tests/versioning/validate-contract.sh
```

Os testes criam repositórios temporários, verificam prévia para quatro perfis,
rejeição de PR inválido, idempotência em dez reexecuções e corrida entre duas
publicações. São testes locais com adaptadores/GitHub simulados; não substituem
execuções hospedadas nos consumidores com as ferramentas reais e regras de
proteção configuradas.
