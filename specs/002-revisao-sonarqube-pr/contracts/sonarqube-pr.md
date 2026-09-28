# Contrato proposto: `.github/workflows/sonarqube-pr.yml`

## Interface

- `workflow_call` com `project_key`, `sonar_host_url` e `project_base_dir` (default `.`).
- Secret obrigatório `sonar_token` de análise; credencial separada `project_token` somente se
  `sync_project_status=true` e `project_number` for fornecido.
- Saídas: `gate` (`passed|failed|unavailable`), `report_url`, `analyzed_sha`.
- Caller invoca em `pull_request` para `opened`, `synchronize`, `reopened`; usa `contents: read`
  no job de scanner. Nunca executar código de fork com token de Project ou escrita.
- SonarQube Server exige binding GitHub e configuração de PR analysis compatível no
  consumidor; o caller protege a branch exigindo o check de análise.

## Reprovação e Project

- Gate `failed`/`unavailable` ou erro de scanner produz check não aprovado no HEAD atual.
- Se `sync_project_status` habilitado, localizar Project/itens explicitamente ligados e
  opção real `Request changes`; marcar PR e issue vinculada se ambos existirem.
- Sem vínculo ou permissão, registrar aviso de sincronização, nunca aprovar check vermelho.
- Retorno a verde não remove status mudado posteriormente por pessoa ou outro workflow.
- `Request changes` no Project não equivale à submissão de review REQUEST_CHANGES no PR.

## Referência de consumo

O caller deve fixar uma ref estável e fornecer credenciais pelo mecanismo de secrets, nunca
por arquivo ou logs. URL do relatório e resumo do check servem para diagnóstico. O contrato
acima é planejado: o workflow e os scripts ainda não existem.
