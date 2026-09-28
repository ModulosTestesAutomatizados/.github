# Spec Delta

## Purpose

Oferecer aos repositórios consumidores uma revisão automatizada rastreável a cada PR, seguida de análise profunda SonarQube do HEAD correto antes de qualquer decisão de merge.

## ADDED Requirements

### Requirement: Revisão reutilizável em qualquer branch de PR
O sistema MUST permitir que o consumidor invoque revisão automática na abertura, atualização ou reabertura do PR, independentemente das branches envolvidas, com modelo e prompt configuráveis e resultado atribuível ao HEAD.

#### Scenario: PR aberto
- **WHEN** um caller habilitado recebe um PR entre quaisquer branches
- **THEN** inicia revisão vinculada ao PR e HEAD, com relatório e decisão consultáveis.

#### Scenario: Modelo ou credencial falha
- **WHEN** não há modelo/credencial de revisão utilizável
- **THEN** o check não apresenta aprovação artificial e informa a causa.

### Requirement: Edição controlada e iteração finita
O sistema MUST permitir somente alterações autorizadas na própria branch do PR, com evidência de commits e no máximo uma iteração de autocorreção automática por PR antes de intervenção humana; PRs não confiáveis MUST receber apenas sugestões sem secrets de escrita.

#### Scenario: Correção aceita em branch própria
- **WHEN** a revisão encontra correção permitida em PR do mesmo repositório
- **THEN** o novo commit é identificado e uma nova revisão do HEAD resultante é iniciada sem recursão ilimitada.

#### Scenario: PR de fork
- **WHEN** o código vem de fork ou não existe permissão para atualizar a branch
- **THEN** o resultado publica sugestão revisável, sem push nem acesso a credencial privilegiada.

### Requirement: Análise SonarQube da revisão final
O sistema MUST encaminhar ao contrato de análise da #3 o HEAD confirmado após a primeira iteração ou a revisão sem mudança; resultado obsoleto ou faltante MUST NOT aprovar o merge.

#### Scenario: Nenhum commit novo
- **WHEN** a revisão termina sem alteração
- **THEN** a análise SonarQube avalia o HEAD revisado e vincula o resultado ao mesmo commit.

#### Scenario: Commit novo ou evento concorrente
- **WHEN** a revisão produz novo commit ou outro ator atualiza o PR antes do gate
- **THEN** o gate é reexecutado para o novo HEAD antes da aprovação e um resultado do SHA anterior não a substitui.

### Requirement: Bloqueio e intervenção humana
O sistema MUST comunicar achados e falhas no PR; revisão crítica ou gate `failed|unavailable` MUST bloquear a aprovação automática, encaminhar à revisão humana e, quando os vínculos e permissões existirem, refletir `Request changes` conforme o contrato da #3, sem forjar review humana.

#### Scenario: Falha crítica
- **WHEN** o SonarQube informa falha crítica após a revisão
- **THEN** o PR apresenta relatório e check reprovado, o Project acompanha a reprovação quando aplicável e o fluxo automático se encerra para decisão humana.

#### Scenario: Gate verde e revisão concluída
- **WHEN** revisão e gate aprovam o mesmo HEAD
- **THEN** o check técnico passa, mas não dispensa review humana exigida pelo consumidor.

### Requirement: Adoção documentada
O sistema MUST documentar caller com ref estável, parâmetros/defaults, secrets, permissões, prompts/modelos, estados e composição com SonarQube; a skill versionada MUST manter esses contratos atualizados.

#### Scenario: Novo consumidor
- **WHEN** outro repositório adota o caller
- **THEN** consegue configurar revisão e gate com exemplos verificáveis e política explícita para forks e branches protegidas.
