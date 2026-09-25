# Data Model: triagem de issues

## Triagem

- `source`: repositório, issue/evento, autor, tipo de evento e identificador para idempotência.
- `decision`: complexidade, ação (`plan|fix|diagnose`), modelo configurado, versão de prompt e motivo de decisão.
- `result`: plano, diagnóstico, PR proposto ou falha de autenticação/execução; sem material secreto.
- Estado: recebido → validado → roteado → concluído|falho|ignorado; repetição retorna resultado já vinculado.

## Proposta

- `issueRef`, `headBranch`, `baseBranch`, `pullRequestRef`, `analyzedHead` (se aplicável).
- Cada issue elegível tem no máximo um PR ativo por ação/base; revisão e merge cabem a pessoas.

## Credencial

- Secret é propriedade do contexto autorizado do caller; restauração temporária não é persistida em commits, comentários ou relatórios.
