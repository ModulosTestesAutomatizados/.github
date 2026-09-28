# Contrato proposto: `.github/workflows/codex-pr-review.yml`

## Caller mínimo (esquema ilustrativo)

```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened]
jobs:
  review:
    uses: ModulosTestesAutomatizados/.github/.github/workflows/codex-pr-review.yml@<sha-revisado>
    permissions:
      contents: read
      pull-requests: write
    with:
      model_review: '<modelo-habilitado>'
      allow_auto_fix: false
      sonar_project_key: '<chave-do-projeto>'
      sonar_host_url: '<url-sem-credencial>'
    secrets:
      codex_auth: ${{ secrets.CODEX_AUTH_JSON }}
      sonar_token: ${{ secrets.SONAR_TOKEN }}
```

- Caller não filtra branches; `workflow_call` recebe modelo/prompt, política de autocorreção, opções do contrato SonarQube da #3 e credenciais do contexto autorizado do consumidor.
- Permissões de escrita em branch, quando habilitadas, devem pertencer a job/identidade isolados e explicitamente autorizados; o exemplo read-only produz sugestões. Em fork, nunca usar credencial de escrita nem checkout privilegiado.
- Saídas conceituais: `review_status`, `reviewed_sha`, `new_sha`, `gate`, `analyzed_sha`, `report_url`; exigência de check verde depende do ruleset do consumidor.
- Se houver commit novo, o run original não aprova: novo `pull_request.synchronize` valida HEAD com revisão sem segunda autocorreção e gate. Sem trigger seguro, apenas sugestão.
- Quality gate `failed|unavailable`, revisão indisponível ou SHA divergente: check não aprovado e notificação para intervenção humana; Project da #3 sincroniza `Request changes` quando possível.
- Workflow/caller ainda serão implementados no apply; `<sha-revisado>` representa ref estável publicada após review, não um literal executável.
