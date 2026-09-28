# Research: revisão de PR com LLM e SonarQube

## Revisão de PR e refresh de HEAD

- **Decision**: caller em `pull_request` sem filtro de branch; análise inicial read-only, correção automática no máximo uma vez por PR confiável; verificar `reviewed_sha`/`analyzed_sha` antes de aprovar.
- **Rationale**: check antigo não atesta o novo commit, nem uma aprovação de revisão substitui gate.
- **Alternatives considered**: reutilizar resultado do run original depois de bot fazer push; confiar em review formal do bot.

## Disparo de segundo run

- **Decision**: preferir identidade autorizada que dispare evento após commit em PR interno; caso contrário apenas sugerir mudanças e manter check antigo não aprovado.
- **Rationale**: GitHub evita disparos recursivos de workflows por atividades com `GITHUB_TOKEN`.
- **Alternatives considered**: permitir que o run original aprove o novo HEAD sem check associado.
- **Reference**: https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-when-your-workflow-runs/triggering-a-workflow

## Segurança e análise profunda

- **Decision**: conteúdo de PR/fork é não confiável; sem `pull_request_target` com checkout privilegiado. A análise SonarQube é o job/fase posterior à revisão, com check e relatório atrelados ao HEAD.
- **Rationale**: isolar segredos evita prompt injection e resultado defasado.
- **Alternatives considered**: execução privilegiada do PR de fork, status de Project como único gate.
- **References**: https://docs.github.com/en/actions/reference/security/secure-use ; https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/ci-integration/github-actions.md
