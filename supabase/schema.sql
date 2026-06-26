-- Schema Supabase/Postgres para o app Controle de Aluguel.
-- Use este arquivo para criar uma base nova ja com nomes em portugues.
-- Se a base atual ainda usa nomes em ingles, execute antes:
-- supabase/migracao_para_portugues.sql

begin;

create table if not exists public.locadores (
  id text primary key,
  nome text not null,
  cpf text not null,
  telefone text not null,
  email text not null,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create table if not exists public.inquilinos (
  id text primary key,
  nome text not null,
  cpf text not null,
  telefone text not null,
  email text not null,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create table if not exists public.imoveis (
  id text primary key,
  endereco text not null,
  tipo text not null,
  valor_aluguel numeric(12, 2) not null check (valor_aluguel >= 0),
  status text not null default 'disponivel'
    check (status in ('disponivel', 'alugado', 'inativo')),
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create table if not exists public.contratos_aluguel (
  id text primary key,
  imovel_id text not null references public.imoveis(id) on delete restrict,
  imovel_endereco text not null,
  locador_id text not null references public.locadores(id) on delete restrict,
  locador_nome text not null,
  inquilino_id text not null references public.inquilinos(id) on delete restrict,
  inquilino_nome text not null,
  data_inicio timestamptz not null,
  data_fim timestamptz not null,
  dia_vencimento integer not null check (dia_vencimento between 1 and 31),
  valor_mensal numeric(12, 2) not null check (valor_mensal >= 0),
  status text not null default 'ativo'
    check (status in ('ativo', 'encerrado', 'cancelado')),
  observacoes text not null default '',
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  check (data_fim >= data_inicio)
);

create table if not exists public.pagamentos_aluguel (
  id text primary key,
  contrato_id text not null references public.contratos_aluguel(id) on delete cascade,
  data_vencimento timestamptz not null,
  data_pagamento timestamptz not null,
  valor_pago numeric(12, 2) not null check (valor_pago >= 0),
  forma_pagamento text not null
    check (forma_pagamento in ('dinheiro', 'pix', 'cartao', 'transferencia_bancaria')),
  status text not null default 'pago'
    check (status in ('pago', 'cancelado')),
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create table if not exists public.notificacoes_aluguel (
  id text primary key,
  contrato_id text not null references public.contratos_aluguel(id) on delete cascade,
  inquilino_nome text not null,
  mensagem text not null,
  enviado_em timestamptz not null,
  status text not null,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create index if not exists idx_locadores_nome
  on public.locadores (nome);

create index if not exists idx_inquilinos_nome
  on public.inquilinos (nome);

create index if not exists idx_imoveis_status
  on public.imoveis (status);

create index if not exists idx_contratos_status
  on public.contratos_aluguel (status);

create index if not exists idx_contratos_imovel_id
  on public.contratos_aluguel (imovel_id);

create index if not exists idx_contratos_locador_id
  on public.contratos_aluguel (locador_id);

create index if not exists idx_contratos_inquilino_id
  on public.contratos_aluguel (inquilino_id);

create index if not exists idx_pagamentos_contrato_id
  on public.pagamentos_aluguel (contrato_id);

create index if not exists idx_pagamentos_data_vencimento
  on public.pagamentos_aluguel (data_vencimento);

create index if not exists idx_notificacoes_contrato_id
  on public.notificacoes_aluguel (contrato_id);

create index if not exists idx_notificacoes_enviado_em
  on public.notificacoes_aluguel (enviado_em);

create or replace function public.definir_atualizado_em()
returns trigger
language plpgsql
as $$
begin
  new.atualizado_em = now();
  return new;
end;
$$;

drop trigger if exists definir_locadores_atualizado_em on public.locadores;
create trigger definir_locadores_atualizado_em
before update on public.locadores
for each row execute function public.definir_atualizado_em();

drop trigger if exists definir_inquilinos_atualizado_em on public.inquilinos;
create trigger definir_inquilinos_atualizado_em
before update on public.inquilinos
for each row execute function public.definir_atualizado_em();

drop trigger if exists definir_imoveis_atualizado_em on public.imoveis;
create trigger definir_imoveis_atualizado_em
before update on public.imoveis
for each row execute function public.definir_atualizado_em();

drop trigger if exists definir_contratos_atualizado_em on public.contratos_aluguel;
create trigger definir_contratos_atualizado_em
before update on public.contratos_aluguel
for each row execute function public.definir_atualizado_em();

drop trigger if exists definir_pagamentos_atualizado_em on public.pagamentos_aluguel;
create trigger definir_pagamentos_atualizado_em
before update on public.pagamentos_aluguel
for each row execute function public.definir_atualizado_em();

drop trigger if exists definir_notificacoes_atualizado_em on public.notificacoes_aluguel;
create trigger definir_notificacoes_atualizado_em
before update on public.notificacoes_aluguel
for each row execute function public.definir_atualizado_em();

alter table public.locadores enable row level security;
alter table public.inquilinos enable row level security;
alter table public.imoveis enable row level security;
alter table public.contratos_aluguel enable row level security;
alter table public.pagamentos_aluguel enable row level security;
alter table public.notificacoes_aluguel enable row level security;

-- Policies liberadas para usuario autenticado.
-- Se o app usar a anon key sem login, troque "authenticated" por "anon"
-- ou adicione policies especificas para o fluxo desejado.
drop policy if exists "authenticated can manage locadores" on public.locadores;
create policy "authenticated can manage locadores"
on public.locadores for all
to authenticated
using (true)
with check (true);

drop policy if exists "authenticated can manage inquilinos" on public.inquilinos;
create policy "authenticated can manage inquilinos"
on public.inquilinos for all
to authenticated
using (true)
with check (true);

drop policy if exists "authenticated can manage imoveis" on public.imoveis;
create policy "authenticated can manage imoveis"
on public.imoveis for all
to authenticated
using (true)
with check (true);

drop policy if exists "authenticated can manage contratos aluguel" on public.contratos_aluguel;
create policy "authenticated can manage contratos aluguel"
on public.contratos_aluguel for all
to authenticated
using (true)
with check (true);

drop policy if exists "authenticated can manage pagamentos aluguel" on public.pagamentos_aluguel;
create policy "authenticated can manage pagamentos aluguel"
on public.pagamentos_aluguel for all
to authenticated
using (true)
with check (true);

drop policy if exists "authenticated can manage notificacoes aluguel" on public.notificacoes_aluguel;
create policy "authenticated can manage notificacoes aluguel"
on public.notificacoes_aluguel for all
to authenticated
using (true)
with check (true);

commit;
