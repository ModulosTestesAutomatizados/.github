# Contrato proposto: `.github/workflows/issue-triage.yml`

## Caller (esquema ilustrativo, ref e opções ajustadas na adoção)

```yaml
on:
  issues:
    types: [opened]
jobs:
  triage:
    uses: ModulosTestesAutomatizados/.github/.github/workflows/issue-triage.yml@<sha-revisado>
    permissions:
      contents: read
      issues: write
      pull-requests: write
    with:
      model_planning: '<modelo-habilitado>'
      model_fix: '<modelo-habilitado>'
      model_diagnosis: '<modelo-habilitado>'
      allow_auto_fix: false
      target_branch: 'master'
    secrets:
      codex_auth: ${{ secrets.CODEX_AUTH_JSON }}
```

- `workflow_call` recebe modelos configurados (strings não vazias), `allow_auto_fix` default `false`, `target_branch` fornecida pelo consumidor e versão de prompts interna revisável. Evento de comentário/CI requer caller separado com filtro e contexto autorizado.
- `codex_auth`: credencial aceita pela versão pinada do Codex CLI (ou adaptação documentada para chave de API); fornecida no consumidor, nunca codificada no workflow. Token de GitHub para operações de PR usa permissions mínimas do caller e isolamento de jobs; não herdar secret entre organizações automaticamente.
- Saídas conceituais: `action`, `decision`, `plan_ref`, `pr_ref`, `result`; contrato de formatos exatos será validado na implementação com fixture.
- Erros: secret inválido/ausente, modelo desconhecido, evento sem permissão, timeout ou duplicação produzem diagnóstico sem auto-merge; idempotência preserva PR existente.
- Este documento é contrato de planejamento; código e caller executável serão entregues durante apply, com referências estáveis de produção substituindo `<sha-revisado>`.
