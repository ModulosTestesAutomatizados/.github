# Design

## Context

Ver [proposal.md](proposal.md). A #3 especifica gate SonarQube; a branch da #6 herda apenas seu planejamento. Neste repositório não há workflow de triagem Codex. A constituição exige contrato explícito, caller pequeno e separação de dados não confiáveis de secrets e escrita.

## Goals / Non-Goals

**Goals:** orquestrar triagem sem intervenção humana na execução, mas com PR humano para qualquer edição; expor o mesmo mecanismo de seleção de prompts/modelos à #7.

**Non-Goals:** aceitar os nomes de modelos fictícios no exemplo da issue, usar o `auth.json` pessoal como valor versionado, executar auto-merge, conceder `contents: write` a jobs de leitura ou acionar em todo commit.

## Decisions

1. Caller do consumidor escolhe `issues` como gatilho principal, podendo habilitar `issue_comment`, `pull_request_review_comment` e `workflow_run` explicitamente; chama `.github/workflows/issue-triage.yml@<ref-estavel>` via `workflow_call`. Workflow reutilizável NÃO declara gatilhos de evento do consumidor. Alternativa de concentrar todos os eventos no workflow chamado não funciona com `workflow_call`.
2. Roteador determinístico em `scripts/triage/` valida evento, autor, labels e idempotência por repositório/issue/HEAD/ação. Mapeia entradas `model_planning`, `model_fix`, `model_diagnosis` e versões de prompts separadas; valida modelos configurados na versão instalada em vez de usar placeholders da issue. Falha desconhecida vai para diagnóstico sem escrita. Alternativa de deixar a LLM escolher privilégios foi rejeitada.
3. Jobs distintos: triagem e planejamento read-only; correção simples opt-in em ambiente efêmero com escopo de escrita limitado, cria branch de origem e PR individual sem merge automático. Eventos de CI/review privilegiam diagnóstico; qualquer correção segue mesmo caminho de PR. Nunca rodar checkout de fork/código não confiável em contexto privilegiado. Descartar comentários do bot e reexecuções duplicadas.
4. Preferir credencial não pessoal dedicada quando disponível. Para exigência de Codex CLI, aceitar secret com estado de autenticação suportado ou chave de API em formato documentado, armazenado SOMENTE como secret; provisionar diretório temporário com permissões restritas e destruí-lo após uso. `secrets: inherit` só resolve compartilhamento dentro da mesma organização/enterprise: entre organizações cada consumidor configura seu próprio secret ou credencial aprovada. Se auth pessoal em CI não for permitida pelo provedor/organização, exigir credencial de serviço antes de ativar caller. Alternativa de centralização global de secret no repo chamado foi rejeitada: secrets do caller não são magicamente compartilhados entre organizações.
5. Publicar `specs/004-triagem-issues/` e contrato do caller; atualizar a skill versionada de qualidade apenas na #6, incluindo todos os inputs/defaults/outputs/secrets/permissões e falhas. A #7 complementará esse mesmo contrato em seu próprio PR.

## Risks / Trade-offs

- Tokens reutilizados expostos em logs/cache ou prompts → diretório temporário, máscara, sem persistência, permissões mínimas e inspeção de saída.
- Orquestração de eventos em loop → chave de idempotência, filtro de bot e allowlist de gatilhos configurados.
- Eventos `workflow_run` recebem privilégio ampliado → não fazer checkout de conteúdo do PR com escrita; entregar diagnóstico sem execução de código não confiável.
- Concorrência de PRs gerados → branch por issue/execução com reaproveitamento idempotente e revisão humana.

## Migration Plan

1. Entregar PR da #6 contra `feature/issue-3`; quando implementado, experimentar caller read-only e credencial no consumidor de teste.
2. Ativar escrita opt-in por repositório depois dos testes de isolamento, PR e revisão; reverter desabilitando o caller sem invalidar relatório anterior.
3. Basear #7 na #6 para reutilizar contrato e roteador sem misturar alterações de outras issues no diff da PR.
