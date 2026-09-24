# Implementation Plan: Versionamento por sprint

**Branch**: `feature/issue-2` (planejamento) | **Date**: 2026-09-23 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-versionamento-por-sprint/spec.md`

## Summary

Planejar dois contratos reutilizáveis: prévia de versão somente leitura em PR e publicação
após integração aprovada na branch principal. Adaptadores declarativos por família de
versionamento mantêm os comandos específicos fora da lógica de coordenação; publicação é
serializada, idempotente e preserva tags existentes.

## Technical Context

**Language/Version**: YAML de GitHub Actions; comandos das ferramentas instaladas no consumidor

**Primary Dependencies**: GitHub Actions, GitHub Releases, Git, adaptadores `standard-version`,
Changesets/Turbo, `jgitver` e `go-gitsemver` conforme perfil do consumidor

**Storage**: Git tags/releases e arquivos de versão/changelog no repositório consumidor

**Testing**: validação de YAML/contratos, execução em repositórios de exemplo para quatro perfis,
simulação de concorrência e reexecução. O repositório de testes fornecido é o
[LocalLabs](https://github.com/GersonTekSystem/LocalLabs).

**Target Platform**: GitHub Actions de repositórios autorizados a chamar workflows reutilizáveis

**Project Type**: automação compartilhada para repositórios GitHub

**Performance Goals**: prévia em até 2 min em projeto de exemplo; publicação em até 5 min

**Constraints**: nenhum push a partir de PR; aprovação humana e proteção configuradas no
consumidor; tags imutáveis; secrets e permissões mínimos; callers fixam referência estável

**Scale/Scope**: quatro perfis de consumidor; release por repositório e branch de destino

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- I: coordenação e contratos comuns ficam aqui; exemplos de CI do consumidor são curtos.
- II: prévia e publicação possuem entradas/saídas e versões de referência documentadas;
  nenhum breaking change silencioso.
- IV: PR é somente leitura; escrita em release exige token mínimo pós-merge; nada de secrets
  em código não confiável.
- V: quatro exemplos e cenários de falha/concorrência previstos para validação.

**Rechecagem pós-design**: contratos em `contracts/`, instruções em `quickstart.md` e
impossibilidade de mover tags mantêm os quatro gates satisfeitos; sem exceções.

## Project Structure

### Documentation (this feature)

```text
specs/001-versionamento-por-sprint/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── contracts/versioning.md
├── quickstart.md
├── checklists/requirements.md
└── tasks.md
```

### Source Code (repository root)

```text
.github/workflows/version-preview.yml       # proposto
.github/workflows/version-publish.yml       # proposto
scripts/versioning/                       # adaptadores, checagens e publicação
docs/versioning.md                        # chamadas curtas e matriz de perfis
```

**Structure Decision**: Nenhum workflow reutilizável de versionamento existe hoje.
O diretório `.github/ISSUE_TEMPLATE/` atual não é alterado por esta feature.
Os modelos e os testes de integração local ficam no repositório externo
`GersonTekSystem/LocalLabs`, em `examples/` e `tests/versioning/`, conforme a
orientação do usuário; nele, o caller permanece inativo até existir ref estável
e configuração de homologação no GitHub.

## Complexity Tracking

Sem violações constitucionais identificadas.
