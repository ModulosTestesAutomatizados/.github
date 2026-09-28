# Feature Specification: Revisão SonarQube em PRs

**Feature Branch**: `feature/issue-3` (PR para `master`; base da stack #3 → #6 → #7)

**Created**: 2026-09-23

**Status**: Backlog (Project [GitHub Features](https://github.com/orgs/ModulosTestesAutomatizados/projects/6), issue #3)

**Input**: [Issue #3 — Revisões com SonarQube](https://github.com/ModulosTestesAutomatizados/.github/issues/3), sub-issue da épica #1.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Verificar qualidade no PR (Priority: P1)

Como revisor, quero ver um resultado de análise por PR, incluindo falhas e diagnóstico, para
evitar merge de código que não cumpre os critérios de qualidade estabelecidos.

**Why this priority**: O gate verificável é o valor principal e não depende de Projects.

**Independent Test**: Abrir PR com achado que viole o gate; conferir falha do check e link
para relatório; corrigir e conferir aprovação após nova análise.

**Acceptance Scenarios**:

1. **Given** PR novo com critérios aprovados, **When** termina a análise, **Then** o check
   exigido passa e apresenta relatório e evidência acessíveis.
2. **Given** PR com falha crítica ou gate reprovado, **When** termina a análise, **Then** o
   check falha, explica a causa e impede merge enquanto for obrigatório no consumidor.
3. **Given** análise indisponível ou inconclusiva, **When** a execução termina, **Then**
   não é apresentada como aprovação.

---

### User Story 2 - Refletir status no Project (Priority: P2)

Como mantenedor de um Project, quero que PR e issue vinculada sejam sinalizados como
`Request changes` na reprovação, sem sobrescrever decisões humanas quando o gate se recuperar.

**Why this priority**: Aumenta visibilidade da triagem sem substituir o check de merge.

**Independent Test**: Testar com PR e issue no mesmo Project e verificar atualização e
recuperação apenas dos status criados pela automação.

**Acceptance Scenarios**:

1. **Given** PR e issue vinculada presentes no Project, **When** o gate falha, **Then** ambos
   recebem `Request changes` e referência ao relatório.
2. **Given** PR sem issue vinculada ou sem Project aplicável, **When** o gate falha, **Then**
   o check continua reprovado e a ausência de atualização é registrada sem inventar vínculo.
3. **Given** correção aprovada, **When** o gate volta a passar, **Then** apenas status que a
   automação marcou são reconciliados, preservando mudanças manuais posteriores.

---

### User Story 3 - Execução isolada por PR (Priority: P3)

Como operador, quero que os recursos de execução da análise tenham vida curta e não deixem
containers ou credenciais ativos após a conclusão do PR.

**Why this priority**: Mantém a infraestrutura previsível e evita acúmulo de recursos.

**Independent Test**: Encerrar PR com sucesso ou falha e verificar limpeza de recursos
temporários; histórico de resultados permanece disponível.

**Acceptance Scenarios**:

1. **Given** análise em execução temporária, **When** termina ou é cancelada, **Then** os
   recursos transitórios são liberados, mantendo relatório e histórico de check.

### Edge Cases

- PR vindo de fork sem acesso a secrets: falha/aviso claro sem executar código não confiável
  em contexto privilegiado.
- Projeto sem integração SonarQube, token ausente ou plataforma indisponível: sem aprovação
  artificial e com diagnóstico acionável.
- Novo commit durante análise: resultados antigos não podem aprovar o novo HEAD.
- Project sem opção `Request changes` ou sem permissão de escrita: check mantém resultado;
  sincronização informa impeditivo.
- PR de release para `develop` ou `master`: aplica a mesma regra de gate, sem substituir review.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Repositórios consumidores DEVEM poder invocar análise reutilizável para PR aberto,
  atualizado ou reaberto, com parâmetros de projeto e autenticação necessários.
- **FR-002**: A solução DEVE emitir resultado de análise e gate para o commit atual do PR,
  com relatório consultável e identificação dos achados que motivaram reprovação.
- **FR-003**: Gate reprovado, análise inconclusiva ou indisponível NÃO DEVEM ser tratados
  como aprovação; check obrigatório do consumidor DEVE bloquear merge independentemente de
  review humana aprovada.
- **FR-004**: A política de aceitação DEVE exigir aprovação de todos os critérios de qualidade
  configurados para código novo, inclusive falhas críticas, sem afirmar que cobertura de todo
  o legado precisa ser literalmente 100%.
- **FR-005**: Quando houver permissão e vínculos válidos, a reprovação DEVE refletir
  `Request changes` nos itens do PR e da issue relacionada no Project; recuperação não pode
  sobrescrever status posteriores de outra origem.
- **FR-006**: O scanner e seus recursos transitórios DEVEM ser liberados ao final ou no
  cancelamento da execução; relatório e histórico DEVEM permanecer acessíveis.
- **FR-007**: O repositório DEVE documentar integração, secrets e permissões mínimas,
  configuração do gate e ativação do check obrigatório no consumidor.
- **FR-008**: Uma skill versionada no repositório DEVE descrever o contrato de caller,
  o gate SonarQube e opções locais de análise coerentes com a documentação de consumo.

### Key Entities

- **Análise de PR**: execução vinculada ao repositório, PR e HEAD analisado.
- **Resultado de gate**: aprovado, reprovado ou indisponível, com URL do relatório.
- **Vínculo de Project**: itens de PR/issue, status anterior e status aplicado pela automação.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Em 100% dos PRs simulados com gate reprovado ou indisponível, o merge fica
  bloqueado quando o check obrigatório está configurado.
- **SC-002**: Em 100% dos PRs válidos de teste, resultado e relatório correspondem ao HEAD
  atual, não a um commit anterior.
- **SC-003**: Em dez cenários com issue/PR vinculados, a reprovação sincroniza ambos os
  status; sem vínculo, não há alteração em item não relacionado.
- **SC-004**: Em 100% das execuções concluídas ou canceladas, não persistem recursos de
  execução temporários, e o relatório do PR continua consultável.

## Assumptions

- Existe uma instância SonarQube mantida fora deste repositório; somente scanner/runner da
  análise é efêmero. O ciclo de vida do servidor não termina ao fechar um PR.
- `Request changes` é opção de status do Project, não um review formal de GitHub; o
  bloqueio de merge depende de check obrigatório configurado no consumidor.
- A sincronização de Projects requer credenciais com acesso ao Project e confirmação de
  vínculo PR–issue; quando indisponíveis, o check continua sendo a fonte de verdade.
