# Research: Versionamento por sprint

## Decisão: momento de publicar

- **Decision**: PR faz apenas prévia; publicação acontece após merge na branch principal do
  consumidor, com evidência de aprovação/homologação nas regras do consumidor.
- **Rationale**: PR simultâneo não é commit final; prévia não pode criar tag definitiva.
- **Alternatives considered**: criar tags por PR foi descartado por gerar versões prematuras.

## Decisão: interoperabilidade

- **Decision**: contratos de `workflow_call` separados para prévia e publicação; perfil de
  ferramenta em enumeração fechada, com comandos explícitos por adaptador e exemplos por perfil.
- **Rationale**: o repositório centraliza a lógica de coordenação, enquanto projetos preservam
  ferramentas de versionamento próprias. Não executar comandos arbitrários vindos do título/PR.
- **Alternatives considered**: impor `standard-version` a todos quebraria Maven/Go/Changesets.

## Decisão: colisões e tag já existente

- **Decision**: serialização por destino, conferência imediata antes da escrita e reconciliação
  idempotente quando a tag existente aponta para o mesmo commit. Divergência exige intervenção
  explícita sem force-push.
- **Rationale**: tags são referências auditáveis; mover uma tag publicada pode comprometer
  consumidores e proveniência.
- **Alternatives considered**: realocação automática sugerida na issue foi rejeitada por risco
  de inconsistência entre consumidores e release publicada.

## Decisão: changelog e proteção

- **Decision**: changelog é consumido quando a ferramenta do consumidor o produz; permissões
  de escrita são restritas ao fluxo pós-merge, e gates humanos residem na branch protection.
- **Rationale**: nem todos os perfis geram o mesmo arquivo, e um workflow não substitui review.
- **Alternatives considered**: sintetizar changelog genérico para todos perderia semântica.
