# Validação prevista: revisão Codex e SonarQube

1. Instalar caller do [contrato](contracts/codex-review.md) num consumidor de teste e abrir PR entre branches que não sejam `master`. Esperado: review seguida de SonarQube do mesmo HEAD.
2. Habilitar autocorreção de PR interno com identidade capaz de emitir novo evento. Esperado: commit na própria branch, run antigo sem aprovação, novo run sem segunda edição e SonarQube do novo SHA.
3. Repetir com fork e sem permissão de escrita. Esperado: apenas sugestões; nenhum secret privilegiado acessível ao código do fork.
4. Forçar gate crítico, serviço indisponível e commit humano durante análise. Esperado: check reprovado/stale, relatório quando disponível, notificação humana e status de Project apenas com vínculo real.
5. Proteger branch do consumidor com check técnico e review humana; confirmar que check verde não dispensa aprovação humana.
6. Verificar que caller, docs e skill versionada declaram o mesmo contrato, modelos/prompts e política para branches, forks e falhas.
