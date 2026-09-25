# Spec Delta

## Purpose

Permitir que repositórios consumidores validem cada revisão de PR com o SonarQube e identifiquem falhas de qualidade antes do merge, preservando rastreabilidade e segurança.

## ADDED Requirements

### Requirement: Análise reutilizável por revisão do PR
O sistema MUST disponibilizar chamada reutilizável que analise o HEAD do PR aberto, atualizado ou reaberto e exponha o resultado e a referência ao relatório para o consumidor.

#### Scenario: Nova revisão analisada
- **WHEN** o consumidor aciona a análise para o HEAD atual de um PR
- **THEN** o check e o relatório identificam esse HEAD e o resultado `passed`, `failed` ou `unavailable`.

#### Scenario: Resultado antigo
- **WHEN** um novo commit é enviado antes de terminar a análise anterior
- **THEN** um resultado do HEAD anterior não aprova o novo HEAD.

### Requirement: Gate integral e falha fechada
O sistema MUST reprovar achados críticos ou qualquer condição reprovada do quality gate configurado para código novo; análise indisponível ou inconclusiva MUST NOT ser reportada como aprovada. O consumidor MUST poder tornar o check obrigatório independentemente de revisão humana.

#### Scenario: Gate reprovado
- **WHEN** o quality gate reprova um PR, mesmo com review humana aprovada
- **THEN** o check exigido falha, informa a causa e impede o merge na branch protegida.

#### Scenario: SonarQube indisponível
- **WHEN** a análise falha, falta configuração ou o serviço não responde
- **THEN** o check não recebe aprovação artificial e informa o impedimento.

### Requirement: Sincronização conservadora do Project
O sistema MUST marcar `Request changes` nos itens do PR e da issue comprovadamente vinculada quando ambos existirem em Project acessível e o gate reprovar; MUST preservar alterações humanas subsequentes. A ausência de Project ou permissões não altera a validade do check.

#### Scenario: Itens vinculados e autorizados
- **WHEN** gate reprova e PR e issue vinculada constam no Project com opção `Request changes`
- **THEN** ambos os itens são atualizados com rastreio da origem e referência ao relatório.

#### Scenario: Ausência de vínculo ou revisão posterior
- **WHEN** não existe vínculo verificável, ou uma pessoa altera o status depois da automação
- **THEN** o sistema não atualiza um item não relacionado nem desfaz uma decisão humana posterior.

### Requirement: Execução efêmera e adoção documentada
O sistema MUST encerrar recursos temporários de análise após sucesso, erro ou cancelamento, preservar resultados consultáveis e documentar exemplo de caller, credenciais, permissões, check obrigatório e ferramentas locais de análise.

#### Scenario: Execução encerrada
- **WHEN** a análise termina ou é cancelada
- **THEN** o scanner temporário é liberado sem apagar o histórico do servidor e o consumidor mantém instruções reproduzíveis de adoção.

#### Scenario: PR não confiável
- **WHEN** o PR não pode receber secrets com segurança
- **THEN** o sistema não disponibiliza credenciais privilegiadas ao código desse PR e explicita a limitação no resultado.
