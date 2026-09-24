# Guia de validação: Versionamento por sprint

Pré-requisitos: repositório de ensaio com `develop`, `release/v1.0.0` e branch principal
protegida; ferramentas instaladas no respectivo perfil; credenciais de publicação restritas.
Ver [contrato](contracts/versioning.md) e [modelo](data-model.md).

1. Em cada perfil (`standard-version`, Changesets, `jgitver`, `go-gitsemver`), configurar um
   caller de prévia conforme o contrato e abrir PR de `feature/...` para `release/v1.0.0`.
   **Esperado**: saída com `bump`/candidato e nenhuma tag/release criada.
2. Criar PR empilhado e PR sem metadados válidos. **Esperado**: apenas prévia ou erro claro,
   jamais publicação.
3. Após review e homologação, integrar via PR para branch principal e executar caller de
   publicação. **Esperado**: tag/release no commit integrado, changelog quando aplicável.
4. Reexecutar a publicação dez vezes; simular dois PRs publicados simultaneamente.
   **Esperado**: uma única publicação por versão/commit, nenhuma tag movida.
5. Preparar tag igual em commit distinto e repetir. **Esperado**: conflito explícito,
   tag/release existentes preservados e indicação de reconciliação manual.
