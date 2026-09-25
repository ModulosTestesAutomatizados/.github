# Design

## Context

Ver [proposal.md](proposal.md). O contrato SonarQube da #3 prevê `gate`, `report_url` e `analyzed_sha`; o de triagem da #6 define Codex CLI, modelos/prompts e política de secrets. Ambos ainda são planejamento na stack e serão implementados em seus PRs respectivos antes da #7.

## Goals / Non-Goals

**Goals:** revisão prévia e gate profundo no HEAD vigente, repetição finita após commit, isolamento de credenciais e caller simples em qualquer PR.

**Non-Goals:** alterar artefatos das #3/#6 no diff da #7, autoaprovar formalmente review, ignorar ruleset do consumidor ou executar código de fork junto a secrets.

## Decisions

1. O caller no repositório consumidor escuta `pull_request` (`opened`, `synchronize`, `reopened`) sem filtro de branch, invoca `.github/workflows/codex-pr-review.yml` com ref estável. Reutiliza estratégia de modelo/prompt da #6, mas o código de revisão vive em `scripts/review/` para não estender responsabilidade da triagem. Alternativa de acionar só PR para `master` não cumpre a issue.
2. Primeira etapa verifica origem, HEAD e elegibilidade; análise Codex isolada e não interativa usa permissões mínimas. Para PR confiável da mesma origem, proposta de edição limitada é testada e comitada uma vez na própria branch usando credencial de automação que dispare nova execução de PR; `GITHUB_TOKEN` em push normalmente NÃO dispara novo `pull_request`. Em forks ou falta de permissão, postar sugestões sem push. Idempotência por PR/HEAD e marcador de autoria evitam loop; se a política do consumidor proibir push, sugestões são o fallback documentado.
3. Revisão sem novo commit chama o workflow SonarQube da #3 depois do job de revisão e compara `analyzed_sha` ao HEAD vigente antes de aprovar. Revisão com novo commit encerra o run antigo como não aprovado; o evento `synchronize` no novo HEAD abre run novo que executa revisão em modo de verificação sem nova autocorreção e então chama SonarQube. Assim o check do gate corresponde ao SHA protegido; alternativa de usar status do run antigo para aprovar novo commit foi rejeitada.
4. Resultado normalizado `review_status`, `reviewed_sha`, `new_sha`, `gate`, `report_url`; check obrigatório considera ambos os estágios. SonarQube falha crítica atualiza Project pela capacidade da #3 (quando autorizada), posta evidência e requer intervenção humana; falha de review/timeout também não passa. Testar forks e credenciais de organizações diferentes como na #6.
5. Versionar novo caller, documentação e ampliação da skill `.opencode/skills/quality-workflows/SKILL.md` apenas na branch #7; contratos existentes são referenciados, sem alterações nas #3/#6. Caso sua implementação futura exija alterar contratos públicos anteriores, elaborar mudança e PR específicos antes de integrar a stack.

## Risks / Trade-offs

- Push do bot com `GITHUB_TOKEN` não reaciona a pipeline → usar identidade autorizada que desencadeie evento ou não efetuar autocorreção; nunca marcar o run antigo como verde.
- Atualização simultânea do PR → validar SHA antes/depois da revisão e do gate, cancelar runs obsoletos sem aprovar.
- Fork e conteúdo malicioso → sugestões somente e contexto sem secret de escrita; nunca `pull_request_target` com checkout de fork.
- Falha de serviço Codex/SonarQube → check não aprova, diagnóstico com link quando disponível e intervenção humana.

## Migration Plan

1. PR da #7 contra `feature/issue-6` com apenas planejamento; implementação futura requer contratos da #3 e #6 entregues antes de ativar consumidores.
2. Ativar caller em repo de teste e ruleset apenas após validar matriz sem edição, autocorreção, fork, concorrência e gate crítico; não exigir novo status check sem testá-lo.
3. Rollback: desabilitar caller/reverter ref estável do consumidor, preservar comentários e relatórios, manter controles de review humana e gate já existentes da #3.
