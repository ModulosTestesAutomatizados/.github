# Validação prevista: triagem de issues

1. Configurar consumidor na mesma organização com caller do [contrato](contracts/issue-triage.md) e secrets. Abrir issue complexa. Esperado: decisão/planejamento vinculados, sem commit direto.
2. Repetir sem secret, com modelo inválido e com issue tentando pedir acesso a tokens. Esperado: erro diagnosticado, sem exposição ou escrita privilegiada.
3. Ativar `allow_auto_fix` para issue simples permitida e repetir evento. Esperado: apenas um PR para a base configurada, nenhum auto-merge.
4. Habilitar comentário autorizado e diagnóstico de CI, e simular evento de bot/fork. Esperado: prompt selecionado para ação correta, sem loops e sem checkout privilegiado de código não confiável.
5. Repetir em consumidor de outra organização. Esperado: configuração própria do secret no caller; ausência dele não gera sucesso falso.
6. Conferir que documentação e `.opencode/skills/quality-workflows/SKILL.md` descrevem os mesmos parâmetros/valores do caller efetivo.
