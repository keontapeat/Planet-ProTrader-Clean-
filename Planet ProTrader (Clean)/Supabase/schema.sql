-- Supabase tables for Flip Mode + Bridge

create table if not exists public.flip_sessions (
  id uuid primary key,
  title text not null,
  created_at timestamptz not null default now(),
  target_equity numeric not null,
  starting_balance numeric not null,
  is_live_routing_enabled boolean not null default false,
  coinexx_credentials jsonb,
  bots jsonb not null,
  is_completed boolean not null default false,
  winner_bot_id uuid
);

create table if not exists public.flip_trades (
  id uuid primary key,
  session_id uuid not null references public.flip_sessions(id) on delete cascade,
  bot_id uuid not null,
  symbol text not null,
  action text not null,
  volume numeric not null,
  price numeric not null,
  profit numeric not null,
  timestamp timestamptz not null default now()
);

create table if not exists public.trade_commands (
  id uuid primary key,
  created_at timestamptz not null default now(),
  executed_at timestamptz,
  status text not null default 'pending', -- pending | executed | failed
  symbol text not null,
  volume numeric not null,
  type text not null, -- buy | sell
  account_login text,
  account_server text,
  bot_id uuid not null,
  bot_name text not null,
  mode text not null default 'flip',
  notes text
);

-- Helpful RLS (customize as needed)
alter table public.flip_sessions enable row level security;
alter table public.flip_trades enable row level security;
alter table public.trade_commands enable row level security;

-- Public read, auth write (simplified)
create policy "read all flip" on public.flip_sessions for select using (true);
create policy "read all flip trades" on public.flip_trades for select using (true);
create policy "read all commands" on public.trade_commands for select using (true);
create policy "insert commands" on public.trade_commands for insert with check (true);
create policy "update commands" on public.trade_commands for update using (true);