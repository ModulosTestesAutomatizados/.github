# Guia de validação: Revisão SonarQube em PRs

Pré-requisitos: instância SonarQube com projeto integrado ao GitHub, token de análise,
repositório de teste e branch protegida exigindo o check. Para Project opcional, credencial
com permissão e opção `Request changes` existente. Ver [contrato](contracts/sonarqube-pr.md).

1. Configurar caller em PR e abrir PR válido. **Esperado**: check verde no HEAD atual e link
   para relatório.
2. Abrir PR com violação do quality gate, inclusive crítica. **Esperado**: check vermelho,
   motivo visível, bloqueio de merge apesar de review aprovada.
3. Com issue/PR vinculados no Project, repetir falha. **Esperado**: ambos recebem
   `Request changes`; sem vínculo, nenhum item aleatório é alterado.
4. Atualizar PR com correção e mover manualmente o status antes da conclusão. **Esperado**:
   novo check corresponde ao HEAD; mudança manual é preservada.
5. Simular serviço indisponível, PR de fork sem secret e cancelamento. **Esperado**: sem
   aprovação artificial ou segredo exposto; runner/container encerrado, histórico preservado.
