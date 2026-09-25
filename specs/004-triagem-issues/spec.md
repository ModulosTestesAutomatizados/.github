# Feature Specification: Triagem reutilizável de issues com Codex

**Feature Branch**: `feature/issue-6` (PR para `feature/issue-3`)  
**Created**: 2026-09-25  
**Status**: planejamento — status de execução no [Project da issue #6](https://github.com/ModulosTestesAutomatizados/.github/issues/6)  
**Input**: issue #6, dependente da #3; a #7 consome este contrato.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Triagem explicável de uma issue complexa (Priority: P1)

Como mantenedor, quero receber um plano contextualizado após a abertura da issue, sem alterar código, para decidir o trabalho seguinte.

**Why this priority**: entrega valor com permissão de leitura antes de habilitar qualquer escrita.

**Independent Test**: Abrir issue complexa em consumidor de teste; conferir ação, modelo, prompt, plano e vínculo com a issue, sem commit na base.

**Acceptance Scenarios**:

1. **Given** caller configurado e credencial válida, **When** chega issue complexa, **Then** um plano revisável é publicado com decisão registrada sem alterar código.
2. **Given** modelo/secret ausente, **When** a triagem inicia, **Then** falha com diagnóstico e sem declarar conclusão.

### User Story 2 - Correção simples supervisionada (Priority: P2)

Como mantenedor, quero que uma issue simples explicitamente autorizada resulte em branch/PR próprios, preservando revisão humana.

**Why this priority**: escrita automática deve depender de classificação e opt-in.

**Independent Test**: Simular issue simples permitida e reenviar o evento; verificar um único PR sem merge nem edição direta na base.

**Acceptance Scenarios**:

1. **Given** auto-correção habilitada, **When** issue simples satisfaz o roteamento, **Then** mudanças são propostas em PR com base correta e revisão humana.
2. **Given** evento repetido ou issue de bot, **When** o roteador executa, **Then** não produz PRs duplicados nem loops.

### User Story 3 - Eventos adicionais e reuso entre organizações (Priority: P3)

Como consumidor, quero configurar modelos/prompts por ação, comentários autorizados e diagnóstico de CI sem precisar duplicar automação.

**Why this priority**: amplia o reuso depois de demonstrar o fluxo principal.

**Independent Test**: Executar caller intraorganizacional e interorganizacional com eventos opcionais; verificar roteamento e política de credenciais.

**Acceptance Scenarios**:

1. **Given** consumidor em outra organização, **When** faz a chamada, **Then** usa secret próprio ou falha explicitamente, sem presumir herança.
2. **Given** falha de CI ou comentário autorizado, **When** evento opcional é habilitado, **Then** prompt específico gera diagnóstico sem execução privilegiada de código não confiável.

### Edge Cases

- Autor não autorizado solicita escrita, issue tenta injetar prompt, PR de fork chega sem secrets, CI se autoaciona, timeout e rate limit do provedor, autenticação inválida, base de PR empilhado e comentário já existente.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Caller MUST expor eventos, inputs/defaults, secrets, outputs, permissões e ref estável sem replicar corpo da automação.
- **FR-002**: Roteador MUST determinar ação, modelo e prompt versionado por evento e complexidade e registrar sua decisão; não pode perguntar ao operador durante execução.
- **FR-003**: Issue complexa MUST gerar planejamento revisável sem código; se o planejamento gerar arquivos, estes MUST seguir branch e PR da própria issue.
- **FR-004**: Auto-correção simples MUST exigir opt-in e entregar alterações em branch/PR individuais com revisão humana, nunca merge direto.
- **FR-005**: Comentários e falhas de CI MUST ser opcionais, validados quanto a autor/origem e idempotentes.
- **FR-006**: Credenciais e dados de issue/PR MUST ser segregados, com falha explícita quando secret for inacessível; compartilhamento entre organizações não é pressuposto.
- **FR-007**: Documentação e skill versionada MUST manter o modelo de caller, parâmetros e cenários de adoção sincronizados.

### Key Entities

- **Decisão de triagem**: evento, origem, ação, complexidade, modelo, versão de prompt, vínculo com issue/PR e status.
- **Execução Codex**: autenticação temporária, modo de execução e resultado sem conteúdo de credenciais.
- **Proposta de correção**: branch, PR e base de entrega vinculados à issue original.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Em 100% dos testes de issue complexa, não há commit direto na base e o plano aponta para a issue correta.
- **SC-002**: Em 100% dos casos simples permitidos, o resultado é no máximo um PR revisável por evento idempotente e nenhum auto-merge.
- **SC-003**: Segredos ausentes, PRs não confiáveis e comentários de bot não geram escrita privilegiada em 100% dos cenários simulados.
- **SC-004**: Chamadas de duas organizações distintas podem ser configuradas somente com secrets do contexto autorizado de cada caller.

## Assumptions

- O workflow reutilizável é chamado por um caller em cada repositório; `secrets: inherit` só se aplica quando suportado para a mesma organização/enterprise.
- Modelos reais são definidos e validados na versão do Codex CLI adotada; strings ilustrativas da issue não são identificadores válidos presumidos.
- Este planejamento descreve comportamento futuro da pipeline; nenhuma execução automática foi habilitada neste PR.
