# Research: Templates de issues e PRs

## Decisão: formulários versus metadados externos

- **Decision**: usar title, descrição, campos `required` e labels somente onde suportados;
  Issue Type, parent, milestone, Issue Fields e Project Fields requerem validação e etapa
  separada, ou guia manual quando API/permissão não disponível.
- **Rationale**: `release: "MAJOR"` no piloto `issuePai.yml` não é evidência de atribuição
  automática de Issue Field; não prometer sem verificar comportamento real.
- **Alternatives considered**: YAML com campos arbitrários mascararia falhas silenciosas.

## Decisão: migração dos pilotos

- **Decision**: manter `issueCLI.yml` (bug da CLI) e migrar `issuePai.yml` para o único
  template de épica, com conteúdo válido e escala explicitada.
- **Rationale**: preserva fluxo existente e evita duplicar opção de épica.
- **Alternatives considered**: excluir pilotos perderia dados que já solicitam.

## Decisão: escala e relações

- **Decision**: Size reflete valor, não dificuldade. Estimate 0 homologação; 1–5 conforme
  valor de features; 6 somente hotfix; 7 PATCH, 8 MINOR, 9 MAJOR e 10 só para épica.
- **Rationale**: mapeamento vem da issue #4; release não épica não herda 10.
- **Alternatives considered**: um único default de Estimate para todos gera Project incorreto.

## Decisão: escopo organizacional

- **Decision**: documentar adoção automática onde GitHub suportar defaults da organização,
  e instalação/cópia quando consumidor já tem arquivos locais ou precisar customização.
- **Rationale**: arquivos existentes no consumidor podem prevalecer; workflow genérico exige
  chamada explícita.
- **Alternatives considered**: afirmar herança universal seria enganoso.
