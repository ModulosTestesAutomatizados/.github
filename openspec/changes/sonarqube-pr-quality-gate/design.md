# Design

## Context

Ver [proposal.md](proposal.md). A branch `feature/issue-3` já contém SpecKit em `specs/002-revisao-sonarqube-pr/`, mas não há workflow SonarQube nem delta OpenSpec. O repositório publica automações compartilhadas; cada consumidor escolhe quando chamá-las e quais regras de proteção aplicar.

## Goals / Non-Goals

**Goals:** manter o scanner isolado, o check atrelado ao SHA do PR e a atualização do Project separada da análise; produzir contrato reutilizável consumido também pela #7.

**Non-Goals:** hospedar servidor SonarQube efêmero, mudar status de review humana ou prometer bloqueio de merge em branch sem ruleset configurado.

## Decisions

1. `workflow_call` em `.github/workflows/sonarqube-pr.yml` com caller documentado em `docs/sonarqube-pr.md` e fixture em `tests/sonarqube/`; pinagem de dependências e ref estável no caller. Alternativa de duplicar scanner em cada consumidor foi rejeitada por divergência de contrato.
2. Scanner oficial em runner efêmero; servidor e relatórios persistem externamente. O resultado de quality gate para o SHA analisado produz `passed|failed|unavailable`, URL e SHA; falha do scanner ou HEAD divergente nunca dá check verde. Configurar decoração nativa e check obrigatório no consumidor, verificando capacidade da edição/licença da instância antes da adoção; se o status nativo não for utilizável, o job aguardará a decisão do gate e falhará fechado. Alternativa de desligar o servidor por PR perde histórico e afeta outros PRs.
3. Separar `scripts/sonarqube/sync-project-status.*` da etapa de scanner. O primeiro só roda em contexto controlado, recebe credencial específica do Project e consulta IDs e opção de status reais; registrar autoria e status anterior para reconciliação conservadora. Código não confiável de fork nunca é executado junto a token privilegiado. Alternativa de editar status pelo token do scanner foi rejeitada por ampliação de privilégio.
4. Preservar especificação SpecKit existente como descrição de histórias e testes; o delta OpenSpec define comportamento normativo. Incluir orientação SonarQube for IDE/Scanner e contrato de reuso em `.opencode/skills/quality-workflows/SKILL.md` no PR da #3; a #6 amplia a skill na própria branch e a #7 adiciona a revisão automatizada.

## Risks / Trade-offs

- Instância/edição não oferece decoração de PR → validar compatibilidade e usar check do job com gate aguardado; não tratar ausência de decoração como sucesso.
- Falta credencial com acesso a Projects entre organizações → manter check independente e registrar falha de sincronização, sem inferir IDs.
- Execuções concorrentes ou commit durante análise → usar chave de concorrência por PR e comparar SHA antes de publicar estado.
- Fork sem secret → encerrar com resultado explícito e sem checkout não confiável em contexto privilegiado.

## Migration Plan

1. Publicar PR da #3 contra `master`; manter caller em ref fixa, teste verde/vermelho/fork e habilitar check obrigatório somente após verificar o nome real do check no consumidor.
2. Desabilitar o caller ou reverter a ref no consumidor em rollback; preservar servidor/relatórios e não remover controles humanos.
3. Basear a #6 na #3 e a #7 na #6, sem incorporar artefatos exclusivos de outras issues ao diff de cada PR.
