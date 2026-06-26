# Controle de Aluguel

Aplicativo Flutter para o proprietário gerenciar imóveis, inquilinos, contratos de aluguel e pagamentos.

## Funcionalidades

- Login do sistema.
- Cadastro e edição dos imóveis do proprietário.
- Cadastro, edição e exclusão de inquilinos com CPF e telefone mascarados.
- Geração, edição e exclusão de contratos de aluguel.
- Registro de pagamentos por contrato, data, parcela e forma de pagamento.
- Dashboard com indicadores de imóveis, contratos, recebimentos e pendências.
- Relatório rápido de contratos ativos, vencidos, pagamentos e parcelas pendentes.
- Geração de avisos de vencimento para aluguéis próximos.

## Arquitetura

Projeto organizado em camadas:

- `lib/core/config`: configuração visual e tema.
- `lib/core/constants`: constantes reutilizadas no app.
- `lib/core/utils`: utilitários de formatação e busca.
- `lib/data/models`: modelos, enums e regras ligadas aos dados.
- `lib/data/repositories`: contrato e implementação do repositório.
- `lib/mvvm/viewmodels`: estado global (`ChangeNotifier`).
- `lib/views`: telas do aplicativo.
- `lib/widgets`: componentes reutilizáveis.

## Persistência

- Supabase para autenticacao e CRUD principal.
- Tabelas principais:
  - `locadores`
  - `inquilinos`
  - `imoveis`
  - `contratos_aluguel`
  - `pagamentos_aluguel`
  - `notificacoes_aluguel`

Para uma base nova, execute `supabase/schema.sql`.
Para uma base que ainda usa nomes em ingles, execute `supabase/migracao_para_portugues.sql`.

## Como executar

```bash
flutter pub get
flutter run
```

## Validação

```bash
flutter analyze
flutter test
flutter build apk --release
```
