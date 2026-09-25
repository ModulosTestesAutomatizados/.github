# Spec Delta

## Purpose

Padronizar a triagem automatizada de issues em repositórios consumidores, com decisões rastreáveis, execução não interativa e entregas sempre revisáveis por pull request.

## ADDED Requirements

### Requirement: Chamada reutilizável e configurável
O sistema MUST oferecer contrato de chamada com gatilhos definidos pelo consumidor, entradas, valores padrão, saídas, secrets e permissões documentadas, incluindo exemplo funcional com referência estável.

#### Scenario: Consumidor instala a triagem
- **WHEN** um repositório configura o caller para abrir uma issue
- **THEN** a chamada recebe o contexto daquele repositório e expõe decisão, resultado e referência à execução sem copiar a lógica central.

#### Scenario: Credencial ausente
- **WHEN** a credencial exigida não está disponível ao consumidor
- **THEN** a execução informa configuração faltante sem vazar tokens ou declarar triagem concluída.

### Requirement: Roteamento explicável e não interativo
O sistema MUST selecionar ação, modelo e template de prompt configuráveis de acordo com evento e complexidade; MUST produzir resultado limitado e auditável sem perguntas interativas.

#### Scenario: Issue complexa
- **WHEN** a issue exige planejamento complexo
- **THEN** o sistema produz plano e critérios revisáveis, sem implementar código nem declarar a issue encerrada.

#### Scenario: Correção simples permitida
- **WHEN** uma issue simples atende às regras configuradas para auto-correção
- **THEN** qualquer alteração é proposta em branch exclusiva e PR individual com revisão humana, sem merge automático.

#### Scenario: Evento auxiliar
- **WHEN** um evento de comentário autorizado ou falha de CI habilitada aciona a triagem
- **THEN** o sistema escolhe seu prompt específico e associa o resultado ao evento de origem sem iniciar um ciclo de novos acionamentos.

### Requirement: Proteção de credenciais e conteúdo não confiável
O sistema MUST limitar permissões ao mínimo por etapa, tratar texto de issue e conteúdo de PR como entrada não confiável, limitar eventos disparados por autores e evitar disponibilizar credenciais a código ou instruções de origem não confiável.

#### Scenario: Entrada maliciosa
- **WHEN** texto da issue pede para revelar secrets ou executar comandos fora do fluxo permitido
- **THEN** a execução não expõe credenciais nem ganha permissão de escrita indevida.

#### Scenario: Revisão ou repetição
- **WHEN** o mesmo evento é repetido ou um PR gerado pelo próprio agente dispara eventos
- **THEN** a triagem evita PR/comentário duplicado e recursão.

### Requirement: Autenticação portátil e documentação de reuso
O sistema MUST documentar configuração da autenticação no consumidor ou herança quando suportada pela mesma organização/enterprise; MUST explicitar configuração por consumidor quando não houver compartilhamento entre organizações e MUST manter orientação atualizada na skill versionada.

#### Scenario: Consumidor em outra organização
- **WHEN** o consumidor não pode herdar secrets da organização que hospeda o workflow
- **THEN** a documentação exige credencial configurada de forma segura no contexto do consumidor e o caller falha claramente se ela faltar.
