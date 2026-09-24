# Guia de validação: Templates de issues e PRs

Pré-requisitos: repositório de ensaio na organização, milestone `v1.0.0`, Project com os
campos/valores necessários quando se quiser testar conciliação. Ver [contrato](contracts/templates.md).

1. Abrir cada formulário (épica, release, feature, task, hotfix); tentar enviar vazio.
   **Esperado**: campos necessários exigidos; títulos e escala condizentes com o tipo.
2. Criar épica com milestone `v1.0.0` e feature vinculada. **Esperado**: somente épica tem
   Estimate 10; feature orienta valor 1–5, vínculo, contexto e premissas.
3. Criar hotfix e release não épica. **Esperado**: 6 para hotfix e 7/8/9 por classe de
   release, quando campos existem; senão pendência clara.
4. Criar bug da CLI pelo piloto e preencher comando, ecossistema e logs. **Esperado**:
   exigências preservadas. Confirmar que só há uma opção de épica.
5. Abrir PR ligado à issue. **Esperado**: quatro seções de relatório e checklist de
   metadados/revisão; conteúdo do PR reflete o destino da branch.
6. Repetir em repo sem Project/labels/permissão. **Esperado**: criação disponível, nenhuma
   associação falsa e instrução de preenchimento manual.
