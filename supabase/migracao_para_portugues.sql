-- Migra uma base existente dos nomes em ingles para nomes em portugues.
-- Execute uma vez no SQL Editor do Supabase antes de subir o app atualizado.

begin;

do $$
begin
  if to_regclass('public.landlords') is not null then
    execute 'drop policy if exists "authenticated can manage landlords" on public.landlords';
    execute 'drop trigger if exists set_landlords_updated_at on public.landlords';
  end if;

  if to_regclass('public.tenants') is not null then
    execute 'drop policy if exists "authenticated can manage tenants" on public.tenants';
    execute 'drop trigger if exists set_tenants_updated_at on public.tenants';
  end if;

  if to_regclass('public.properties') is not null then
    execute 'drop policy if exists "authenticated can manage properties" on public.properties';
    execute 'drop trigger if exists set_properties_updated_at on public.properties';
  end if;

  if to_regclass('public.rental_contracts') is not null then
    execute 'drop policy if exists "authenticated can manage rental contracts" on public.rental_contracts';
    execute 'drop trigger if exists set_rental_contracts_updated_at on public.rental_contracts';
  end if;

  if to_regclass('public.rent_payments') is not null then
    execute 'drop policy if exists "authenticated can manage rent payments" on public.rent_payments';
    execute 'drop trigger if exists set_rent_payments_updated_at on public.rent_payments';
  end if;

  if to_regclass('public.rent_notifications') is not null then
    execute 'drop policy if exists "authenticated can manage rent notifications" on public.rent_notifications';
    execute 'drop trigger if exists set_rent_notifications_updated_at on public.rent_notifications';
  end if;
end;
$$;

do $$
begin
  if to_regclass('public.landlords') is not null
     and to_regclass('public.locadores') is null then
    alter table public.landlords rename to locadores;
  end if;

  if to_regclass('public.tenants') is not null
     and to_regclass('public.inquilinos') is null then
    alter table public.tenants rename to inquilinos;
  end if;

  if to_regclass('public.properties') is not null
     and to_regclass('public.imoveis') is null then
    alter table public.properties rename to imoveis;
  end if;

  if to_regclass('public.rental_contracts') is not null
     and to_regclass('public.contratos_aluguel') is null then
    alter table public.rental_contracts rename to contratos_aluguel;
  end if;

  if to_regclass('public.rent_payments') is not null
     and to_regclass('public.pagamentos_aluguel') is null then
    alter table public.rent_payments rename to pagamentos_aluguel;
  end if;

  if to_regclass('public.rent_notifications') is not null
     and to_regclass('public.notificacoes_aluguel') is null then
    alter table public.rent_notifications rename to notificacoes_aluguel;
  end if;
end;
$$;

create or replace function public._renomear_coluna(
  tabela text,
  coluna_antiga text,
  coluna_nova text
)
returns void
language plpgsql
as $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = tabela
      and column_name = coluna_antiga
  ) and not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = tabela
      and column_name = coluna_nova
  ) then
    execute format(
      'alter table public.%I rename column %I to %I',
      tabela,
      coluna_antiga,
      coluna_nova
    );
  end if;
end;
$$;

select public._renomear_coluna('locadores', 'name', 'nome');
select public._renomear_coluna('locadores', 'phone', 'telefone');
select public._renomear_coluna('locadores', 'created_at', 'criado_em');
select public._renomear_coluna('locadores', 'updated_at', 'atualizado_em');

select public._renomear_coluna('inquilinos', 'name', 'nome');
select public._renomear_coluna('inquilinos', 'phone', 'telefone');
select public._renomear_coluna('inquilinos', 'created_at', 'criado_em');
select public._renomear_coluna('inquilinos', 'updated_at', 'atualizado_em');

select public._renomear_coluna('imoveis', 'address', 'endereco');
select public._renomear_coluna('imoveis', 'type', 'tipo');
select public._renomear_coluna('imoveis', 'rent_value', 'valor_aluguel');
select public._renomear_coluna('imoveis', 'created_at', 'criado_em');
select public._renomear_coluna('imoveis', 'updated_at', 'atualizado_em');

select public._renomear_coluna('contratos_aluguel', 'property_id', 'imovel_id');
select public._renomear_coluna('contratos_aluguel', 'property_address', 'imovel_endereco');
select public._renomear_coluna('contratos_aluguel', 'landlord_id', 'locador_id');
select public._renomear_coluna('contratos_aluguel', 'landlord_name', 'locador_nome');
select public._renomear_coluna('contratos_aluguel', 'tenant_id', 'inquilino_id');
select public._renomear_coluna('contratos_aluguel', 'tenant_name', 'inquilino_nome');
select public._renomear_coluna('contratos_aluguel', 'start_date', 'data_inicio');
select public._renomear_coluna('contratos_aluguel', 'end_date', 'data_fim');
select public._renomear_coluna('contratos_aluguel', 'due_day', 'dia_vencimento');
select public._renomear_coluna('contratos_aluguel', 'monthly_rent', 'valor_mensal');
select public._renomear_coluna('contratos_aluguel', 'notes', 'observacoes');
select public._renomear_coluna('contratos_aluguel', 'created_at', 'criado_em');
select public._renomear_coluna('contratos_aluguel', 'updated_at', 'atualizado_em');

select public._renomear_coluna('pagamentos_aluguel', 'contract_id', 'contrato_id');
select public._renomear_coluna('pagamentos_aluguel', 'due_date', 'data_vencimento');
select public._renomear_coluna('pagamentos_aluguel', 'payment_date', 'data_pagamento');
select public._renomear_coluna('pagamentos_aluguel', 'amount_paid', 'valor_pago');
select public._renomear_coluna('pagamentos_aluguel', 'payment_method', 'forma_pagamento');
select public._renomear_coluna('pagamentos_aluguel', 'created_at', 'criado_em');
select public._renomear_coluna('pagamentos_aluguel', 'updated_at', 'atualizado_em');

select public._renomear_coluna('notificacoes_aluguel', 'contract_id', 'contrato_id');
select public._renomear_coluna('notificacoes_aluguel', 'tenant_name', 'inquilino_nome');
select public._renomear_coluna('notificacoes_aluguel', 'message', 'mensagem');
select public._renomear_coluna('notificacoes_aluguel', 'sent_at', 'enviado_em');
select public._renomear_coluna('notificacoes_aluguel', 'created_at', 'criado_em');
select public._renomear_coluna('notificacoes_aluguel', 'updated_at', 'atualizado_em');

drop function public._renomear_coluna(text, text, text);

alter table public.imoveis drop constraint if exists properties_rent_value_check;
alter table public.imoveis drop constraint if exists properties_status_check;
alter table public.imoveis drop constraint if exists imoveis_valor_aluguel_check;
alter table public.imoveis drop constraint if exists imoveis_status_check;

alter table public.contratos_aluguel drop constraint if exists rental_contracts_due_day_check;
alter table public.contratos_aluguel drop constraint if exists rental_contracts_monthly_rent_check;
alter table public.contratos_aluguel drop constraint if exists rental_contracts_status_check;
alter table public.contratos_aluguel drop constraint if exists rental_contracts_check;
alter table public.contratos_aluguel drop constraint if exists contratos_dia_vencimento_check;
alter table public.contratos_aluguel drop constraint if exists contratos_valor_mensal_check;
alter table public.contratos_aluguel drop constraint if exists contratos_status_check;
alter table public.contratos_aluguel drop constraint if exists contratos_periodo_check;

alter table public.pagamentos_aluguel drop constraint if exists rent_payments_amount_paid_check;
alter table public.pagamentos_aluguel drop constraint if exists rent_payments_payment_method_check;
alter table public.pagamentos_aluguel drop constraint if exists rent_payments_status_check;
alter table public.pagamentos_aluguel drop constraint if exists pagamentos_valor_pago_check;
alter table public.pagamentos_aluguel drop constraint if exists pagamentos_forma_pagamento_check;
alter table public.pagamentos_aluguel drop constraint if exists pagamentos_status_check;

update public.imoveis
set status = case status
  when 'available' then 'disponivel'
  when 'rented' then 'alugado'
  when 'inactive' then 'inativo'
  else status
end;

update public.contratos_aluguel
set status = case status
  when 'active' then 'ativo'
  when 'finished' then 'encerrado'
  when 'canceled' then 'cancelado'
  else status
end;

update public.pagamentos_aluguel
set status = case status
  when 'paid' then 'pago'
  when 'canceled' then 'cancelado'
  else status
end,
forma_pagamento = case forma_pagamento
  when 'cash' then 'dinheiro'
  when 'card' then 'cartao'
  when 'bank_transfer' then 'transferencia_bancaria'
  else forma_pagamento
end;

alter table public.imoveis
  alter column status set default 'disponivel';

alter table public.contratos_aluguel
  alter column status set default 'ativo';

alter table public.pagamentos_aluguel
  alter column status set default 'pago';

alter table public.imoveis
  add constraint imoveis_valor_aluguel_check check (valor_aluguel >= 0),
  add constraint imoveis_status_check
    check (status in ('disponivel', 'alugado', 'inativo'));

alter table public.contratos_aluguel
  add constraint contratos_dia_vencimento_check check (dia_vencimento between 1 and 31),
  add constraint contratos_valor_mensal_check check (valor_mensal >= 0),
  add constraint contratos_status_check
    check (status in ('ativo', 'encerrado', 'cancelado')),
  add constraint contratos_periodo_check check (data_fim >= data_inicio);

alter table public.pagamentos_aluguel
  add constraint pagamentos_valor_pago_check check (valor_pago >= 0),
  add constraint pagamentos_forma_pagamento_check
    check (forma_pagamento in ('dinheiro', 'pix', 'cartao', 'transferencia_bancaria')),
  add constraint pagamentos_status_check check (status in ('pago', 'cancelado'));

drop index if exists public.idx_landlords_name;
drop index if exists public.idx_tenants_name;
drop index if exists public.idx_properties_status;
drop index if exists public.idx_contracts_status;
drop index if exists public.idx_contracts_property_id;
drop index if exists public.idx_contracts_landlord_id;
drop index if exists public.idx_contracts_tenant_id;
drop index if exists public.idx_payments_contract_id;
drop index if exists public.idx_payments_due_date;
drop index if exists public.idx_notifications_contract_id;
drop index if exists public.idx_notifications_sent_at;

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

drop function if exists public.set_updated_at();

alter table public.locadores enable row level security;
alter table public.inquilinos enable row level security;
alter table public.imoveis enable row level security;
alter table public.contratos_aluguel enable row level security;
alter table public.pagamentos_aluguel enable row level security;
alter table public.notificacoes_aluguel enable row level security;

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
