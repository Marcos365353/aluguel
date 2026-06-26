# Roteiro de Apresentacao - Controle de Aluguel

## 1. Abertura

Meu projeto e um aplicativo Flutter para controle de aluguel.

Ele serve para ajudar no gerenciamento de:

- imoveis;
- inquilinos;
- contratos;
- pagamentos;
- avisos de vencimento;
- resumo financeiro no dashboard.

Fala pronta:

> "Meu projeto e um aplicativo de controle de aluguel feito em Flutter. Ele permite cadastrar imoveis, inquilinos, contratos e pagamentos. Tambem mostra um dashboard com resumo financeiro e vencimentos proximos."

## 2. Tecnologias usadas

O projeto usa:

- Flutter: para criar o aplicativo;
- Dart: linguagem usada no codigo;
- Provider: para controlar os dados entre as telas;
- Supabase: backend do aplicativo;
- Supabase Auth: login com e-mail e senha;
- PostgreSQL do Supabase: banco onde ficam as tabelas;
- Google Fonts e Material Design: para interface.

Fala pronta:

> "Usei Flutter para criar o app, Provider para controlar o estado e Supabase como backend. O login e feito pelo Supabase Auth, e os dados ficam salvos nas tabelas do Supabase."

## 3. Estrutura do projeto

As pastas principais sao:

- `lib/main.dart`: inicia o app e conecta no Supabase;
- `lib/pages`: telas de entrada e navegacao principal;
- `lib/views`: telas principais do sistema;
- `lib/mvvm`: controles e ViewModels, como login, entidades e estado do app;
- `lib/mvvm/viewmodels`: estado central do app;
- `lib/data/models`: classes que representam os dados;
- `lib/data/repositories`: acesso ao Supabase;
- `lib/services`: helpers e DAOs usados como camada de servico;
- `lib/services/dao`: DAOs de locador, inquilino, imovel, contrato e pagamento;
- `lib/widgets`: componentes reaproveitados.

Fala pronta:

> "Eu separei o projeto em camadas. As telas ficam em pages e views. Os models representam os dados. O AppState controla o estado geral. O repositorio conversa com o Supabase. Assim cada parte tem uma responsabilidade."

## 4. Arquivo main.dart

O aplicativo comeca em:

`lib/main.dart`

Pontos importantes:

- guarda a URL do Supabase;
- guarda a chave anonima publica;
- chama `Supabase.initialize`;
- registra os ViewModels com `MultiProvider`;
- abre a tela de login.

Fala pronta:

> "No main.dart eu inicio o Flutter, conecto com o Supabase e registro os providers. Esses providers deixam os dados disponiveis para as telas."

Trecho para mostrar:

```dart
await Supabase.initialize(url: urlSupabase, publishableKey: chaveAnonimaSupabase);
```

Explicacao simples:

> "Essa linha abre a conexao com o Supabase antes do aplicativo aparecer."

## 5. Login

O login fica em:

- `lib/pages/login_tela.dart`
- `lib/mvvm/usuario_controle.dart`

O fluxo e:

1. O usuario digita e-mail e senha.
2. A tela chama o `UsuarioControle`.
3. O Controle envia os dados para o Supabase Auth.
4. Se o Supabase aceitar, o app carrega os dados.
5. Depois abre a tela principal.

Fala pronta:

> "O login nao e inventado no app. Ele usa o Supabase Auth. Se o e-mail e a senha estiverem cadastrados no Supabase, o usuario entra."

Trecho para mostrar:

```dart
Supabase.instance.client.auth.signInWithPassword(
  email: email,
  password: senha,
);
```

## 6. Banco de dados no Supabase

As tabelas principais sao:

- `locadores`;
- `inquilinos`;
- `imoveis`;
- `contratos_aluguel`;
- `pagamentos_aluguel`;
- `notificacoes_aluguel`.

Fala pronta:

> "Os dados ficam no Supabase. As tabelas estao em portugues: locadores, inquilinos, imoveis, contratos_aluguel, pagamentos_aluguel e notificacoes_aluguel. Isso deixa o banco mais facil de entender durante a apresentacao."

Tambem existem dois scripts SQL:

- `supabase/schema.sql`: cria uma base nova ja em portugues;
- `supabase/migracao_para_portugues.sql`: migra uma base antiga em ingles para portugues.

## 7. Repositorio do Supabase

O arquivo principal de conexao com as tabelas e:

`lib/data/repositories/repositorio_aluguel_supabase.dart`

Ele faz:

- `select`: buscar dados;
- `upsert`: criar ou atualizar;
- `insert`: inserir pagamento ou aviso;
- `delete`: excluir registros.

Fala pronta:

> "Esse arquivo e a ponte entre o aplicativo e o Supabase. As telas nao fazem select direto. Elas chamam o AppState, e o AppState chama o repositorio."

Trechos para mostrar:

```dart
_cliente.from('imoveis').select().order('endereco')
```

```dart
_cliente.from('imoveis').upsert(...)
```

```dart
_cliente.from('pagamentos_aluguel').insert(...)
```

## 8. Pasta services

A pasta `lib/services` ajuda a organizar pontos de servico do app.

Ela tem:

- `lib/services/auxiliar_supabase.dart`: helper para centralizar acesso ao cliente Supabase;
- `lib/services/dao/locador_servico.dart`: acesso aos locadores;
- `lib/services/dao/inquilino_servico.dart`: acesso aos inquilinos;
- `lib/services/dao/imovel_servico.dart`: acesso aos imoveis;
- `lib/services/dao/contrato_servico.dart`: acesso aos contratos;
- `lib/services/dao/pagamento_servico.dart`: acesso aos pagamentos.

Fala pronta:

> "A pasta services fica como uma camada de servico. Nela eu deixei helpers e DAOs. Os DAOs organizam as operacoes principais de cada entidade, como locador, inquilino, imovel, contrato e pagamento. Eles usam o repositorio do Supabase por baixo."

Importante:

> "Antes o projeto tinha helper de banco local, mas isso foi removido. Agora a camada de servicos aponta para o Supabase."

## 9. AppState

O estado principal fica em:

`lib/mvvm/viewmodels/app_state.dart`

Ele guarda:

- lista de locadores;
- lista de inquilinos;
- lista de imoveis;
- lista de contratos;
- lista de pagamentos;
- lista de avisos.

Ele tambem tem metodos como:

- `salvarInquilino`;
- `salvarImovel`;
- `salvarContrato`;
- `registrarPagamento`;
- `gerarAvisosVencimento`;
- `recarregar`.

Fala pronta:

> "O AppState e como o controle central do app. A tela pede para salvar, o AppState chama o repositorio, o repositorio salva no Supabase, e depois o AppState recarrega os dados para atualizar a tela."

## 10. Tela de dashboard

Arquivo:

`lib/views/dashboard_tela.dart`

O dashboard mostra:

- total de imoveis;
- imoveis alugados;
- recebido no mes;
- pendencias;
- vencimentos proximos;
- contratos ativos.

Fala pronta:

> "O dashboard e um resumo geral. Ele nao usa numeros fixos. Ele calcula tudo com base nos imoveis, contratos e pagamentos cadastrados."

Pontos para nao esquecer de mostrar:

- Cards de resumo: imoveis, alugados, recebido no mes e pendencias;
- Secao `Vencimentos proximos`: mostra alugueis que vencem nos proximos 7 dias;
- Secao `Contratos ativos`: mostra os contratos que ainda estao em andamento;
- Botao de atualizar no topo: recarrega os dados do Supabase.

Fala pronta:

> "Aqui no dashboard eu tenho os indicadores principais. Embaixo aparecem os vencimentos proximos, que ajudam a ver quais alugueis estao perto de vencer. Tambem mostro os contratos ativos, que sao os contratos em andamento."

## 11. Tela de imoveis

Arquivo:

`lib/views/imoveis_tela.dart`

Ela permite:

- listar imoveis;
- filtrar imoveis;
- cadastrar novo imovel;
- editar imovel;
- excluir imovel.

Fala pronta:

> "Na tela de imoveis eu cadastro endereco, tipo, valor do aluguel e status. Quando salvo, o AppState manda para o Supabase."

## 12. Tela de inquilinos

Arquivo:

`lib/views/inquilinos_tela.dart`

Ela permite:

- cadastrar inquilino;
- editar inquilino;
- excluir inquilino;
- buscar por nome, CPF, telefone ou e-mail.

Fala pronta:

> "Na tela de inquilinos eu salvo os dados da pessoa que vai alugar o imovel. Tambem coloquei mascara para CPF e telefone."

## 13. Tela de contratos

Arquivo:

`lib/views/contratos_tela.dart`

Ela permite:

- escolher um imovel;
- escolher um inquilino;
- definir inicio e fim do contrato;
- definir dia de vencimento;
- definir valor mensal;
- salvar contrato.

Fala pronta:

> "O contrato liga um imovel a um inquilino. Ele tambem guarda valor mensal, periodo e dia de vencimento."

Regra importante:

> "Quando um contrato ativo e salvo, o sistema atualiza o status do imovel para alugado."

## 14. Tela financeira

Arquivo:

`lib/views/pagamentos_tela.dart`

Ela permite:

- registrar pagamento;
- escolher contrato;
- informar vencimento;
- informar data de pagamento;
- escolher forma de pagamento;
- ver relatorio rapido;
- gerar avisos de vencimento.

Fala pronta:

> "Na parte financeira eu registro os pagamentos dos alugueis. Depois disso o dashboard e os relatorios atualizam automaticamente."

Pontos para nao esquecer de mostrar:

- Lista de pagamentos registrados;
- Busca/filtro dos pagamentos;
- Botao para registrar novo pagamento;
- Cartao `Relatorio rapido`;
- Cartao `Avisos de vencimento`;
- Botao para gerar avisos.

Fala pronta:

> "Na tela financeira ficam os pagamentos registrados. Eu consigo ver o historico, filtrar pagamentos, registrar um novo pagamento, ver o relatorio rapido e gerar avisos de vencimento."

## 15. Notificacoes de vencimento

As notificacoes aparecem na tela financeira.

Arquivos principais:

- `lib/views/pagamentos_tela.dart`: mostra o cartao de avisos de vencimento;
- `lib/mvvm/viewmodels/app_state.dart`: tem o metodo `gerarAvisosVencimento`;
- `lib/data/models/notificacao_aluguel.dart`: modelo usado pelo app;
- `lib/models/notificacao_tabela.dart`: conversao para a tabela do Supabase;
- tabela `notificacoes_aluguel`: guarda os avisos no Supabase.

Como funciona:

1. O usuario entra na tela financeira.
2. Ele toca no botao para gerar avisos.
3. O AppState percorre os contratos ativos.
4. O sistema verifica os vencimentos dos proximos 7 dias.
5. Para cada vencimento encontrado, cria uma notificacao.
6. O repositorio salva essas notificacoes no Supabase.
7. A tela recarrega e mostra os avisos gerados.

Fala pronta:

> "As notificacoes sao avisos de vencimento. O sistema olha os contratos ativos e verifica quais alugueis vencem nos proximos 7 dias. Depois ele gera os avisos e salva na tabela notificacoes_aluguel do Supabase."

Pontos para nao esquecer de mostrar:

- O cartao `Avisos de vencimento` na tela financeira;
- O botao que gera os avisos;
- A lista de avisos gerados;
- A tabela `notificacoes_aluguel` no Supabase, se quiser provar que salvou.

Trecho para mostrar:

```dart
Future<int> gerarAvisosVencimento() async {
  final agora = DateTime.now();
  final limite = hoje.add(const Duration(days: 7));
}
```

Explicacao simples:

> "Esse metodo calcula a janela dos proximos 7 dias e gera os avisos para os contratos que estao perto de vencer."

## 16. Relatorios e indicadores

Os relatorios nao ficam em uma pasta separada. Eles estao dentro das telas que mostram os dados resumidos.

Principais arquivos:

- `lib/views/dashboard_tela.dart`: mostra o dashboard principal;
- `lib/views/pagamentos_tela.dart`: mostra o relatorio rapido da tela financeira;
- `lib/data/models/metricas_aluguel.dart`: calcula os numeros usados nos relatorios;
- `lib/mvvm/viewmodels/app_state.dart`: disponibiliza os dados e chama `MetricasAluguel.dosDados`.

No dashboard (`dashboard_tela.dart`) aparecem:

- total de imoveis;
- imoveis alugados;
- recebido no mes;
- pendencias;
- vencimentos proximos;
- contratos ativos.

Na tela financeira (`pagamentos_tela.dart`) existe o cartao `Relatorio rapido`, que mostra:

- contratos ativos;
- contratos vencidos;
- pagamentos no mes;
- parcelas pendentes.

Tambem existe a lista de pagamentos registrados na propria tela financeira.
Essa lista mostra os pagamentos que ja foram salvos no Supabase.

Fala pronta:

> "Os relatorios ficam principalmente no dashboard e na tela financeira. O calculo dos indicadores fica no arquivo metricas_aluguel.dart. Ele recebe as listas de imoveis, contratos e pagamentos, calcula os totais e entrega esses numeros para as telas mostrarem."

Trecho para mostrar:

```dart
MetricasAluguel get metricas => MetricasAluguel.dosDados(
  imoveis: _imoveis,
  contratos: _contratos,
  pagamentos: _pagamentos,
);
```

Explicacao simples:

> "Esse trecho fica no AppState. Ele monta os indicadores sempre com os dados atuais do Supabase."

Pontos para nao esquecer de mostrar:

- `Relatorio rapido` na tela financeira;
- `Pagamentos registrados` na tela financeira;
- `Vencimentos proximos` no dashboard;
- `Contratos ativos` no dashboard;
- Cards de resumo no dashboard.

## 17. Fluxo completo para demonstrar

Siga esta ordem na apresentacao:

1. Abrir o app no celular.
2. Fazer login com o usuario do Supabase.
3. Mostrar o dashboard.
4. No dashboard, mostrar cards de resumo.
5. No dashboard, mostrar `Vencimentos proximos`.
6. No dashboard, mostrar `Contratos ativos`.
7. Cadastrar um imovel.
8. Cadastrar um inquilino.
9. Criar um contrato.
10. Registrar um pagamento.
11. Na tela financeira, mostrar `Pagamentos registrados`.
12. Na tela financeira, mostrar o `Relatorio rapido`.
13. Gerar avisos de vencimento.
14. Mostrar os avisos gerados.
15. Voltar ao dashboard e mostrar os numeros atualizados.
16. Mostrar no Supabase que os dados foram salvos nas tabelas.

Fala pronta:

> "Agora vou demonstrar o fluxo completo. Primeiro faco login com o usuario do Supabase. Depois cadastro imovel, inquilino, contrato e pagamento. No final os dados aparecem no dashboard e tambem ficam salvos no Supabase."

Observacao para falar se perguntarem:

> "Eu tambem testei o app em um celular Android conectado por USB. Ajustei a permissao de internet no Android e corrigi um overflow visual no formulario de contrato."

## 18. Explicacao do caminho dos dados

Fluxo:

1. Usuario toca no botao salvar.
2. A tela chama um metodo do `AppState`.
3. O `AppState` cria ou atualiza um objeto.
4. O `AppState` chama o `RepositorioAluguel`.
5. A implementacao `RepositorioAluguelSupabase` salva no Supabase.
6. O `AppState` recarrega os dados.
7. A tela atualiza sozinha por causa do Provider.

Fala pronta:

> "O caminho dos dados e simples: tela, AppState, repositorio e Supabase. Depois o AppState recarrega e o Provider atualiza a interface."

## 19. Perguntas provaveis

### Por que usou Provider?

> "Usei Provider para compartilhar os dados entre as telas e atualizar a interface quando algo muda."

### Por que usou Supabase?

> "Usei Supabase porque ele ja oferece login, banco de dados e API pronta para o Flutter acessar."

### O que e o AppState?

> "E a classe que guarda o estado principal do app e chama os metodos de salvar, excluir e carregar dados."

### O que e o Repository?

> "E a camada que conversa com o banco. No meu caso, ele conversa com as tabelas do Supabase."

### Onde esta o login?

> "O login esta no UsuarioControle e usa Supabase Auth."

### O app funciona no celular?

> "Sim. Eu rodei no celular Android conectado por USB."

### Onde ficam os relatorios?

> "Os relatorios ficam no dashboard_tela.dart e no pagamentos_tela.dart. Ja os calculos ficam no metricas_aluguel.dart, que calcula recebidos, pendencias, contratos vencidos e outros indicadores."

### Onde ficam as notificacoes?

> "As notificacoes ficam na tela financeira, dentro do pagamentos_tela.dart. A regra que gera os avisos fica no AppState, no metodo gerarAvisosVencimento, e os dados sao salvos na tabela notificacoes_aluguel do Supabase."

## 20. Fechamento

Fala final:

> "Resumindo, meu projeto e um controle de aluguel feito em Flutter. Ele tem login com Supabase, cadastro de imoveis, inquilinos, contratos, pagamentos, avisos e dashboard financeiro. Eu organizei o codigo em camadas para ficar mais facil de explicar e manter."
