-- Execute no SQL Editor do seu projeto Supabase.
-- SkillUp: perfis, cursos, aulas, progresso e período de teste.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  role text not null default 'student' check (role in ('student','teacher','admin')),
  created_at timestamptz not null default now()
);
create table if not exists public.subscriptions (
  user_id uuid primary key references auth.users(id) on delete cascade,
  status text not null default 'trialing' check (status in ('trialing','active','past_due','canceled','expired')),
  trial_start timestamptz not null default now(),
  trial_end timestamptz not null default (now() + interval '3 months'),
  current_period_end timestamptz,
  provider text,
  provider_customer_id text,
  provider_subscription_id text,
  updated_at timestamptz not null default now()
);
create table if not exists public.courses (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  title text not null,
  description text,
  track text not null,
  level text not null default 'Iniciante',
  published boolean not null default false,
  created_at timestamptz not null default now()
);
create table if not exists public.lessons (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  title text not null,
  content text,
  video_url text,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);
create table if not exists public.lesson_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  course_slug text not null,
  lesson_index int not null,
  completed boolean not null default false,
  completed_at timestamptz,
  unique(user_id, course_slug, lesson_index)
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path=public
as $$
begin
  insert into public.profiles(id, display_name) values(new.id, coalesce(new.raw_user_meta_data->>'display_name',''));
  insert into public.subscriptions(user_id) values(new.id);
  return new;
end; $$;
drop trigger if exists on_auth_user_created_skillup on auth.users;
create trigger on_auth_user_created_skillup after insert on auth.users
for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.subscriptions enable row level security;
alter table public.courses enable row level security;
alter table public.lessons enable row level security;
alter table public.lesson_progress enable row level security;

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.profiles where id=auth.uid() and role='admin'); $$;

drop policy if exists "profile read own or admin" on public.profiles;
create policy "profile read own or admin" on public.profiles for select using (id=auth.uid() or public.is_admin());
drop policy if exists "profile update own basic" on public.profiles;
create policy "profile update own basic" on public.profiles for update using (id=auth.uid()) with check (id=auth.uid() and role='student');
drop policy if exists "subscription read own or admin" on public.subscriptions;
create policy "subscription read own or admin" on public.subscriptions for select using (user_id=auth.uid() or public.is_admin());
drop policy if exists "courses visible published" on public.courses;
create policy "courses visible published" on public.courses for select using (published=true or public.is_admin());
drop policy if exists "lessons visible for published courses" on public.lessons;
create policy "lessons visible for published courses" on public.lessons for select using (
  public.is_admin() or exists(select 1 from public.courses c where c.id=course_id and c.published=true)
);
drop policy if exists "progress own read" on public.lesson_progress;
create policy "progress own read" on public.lesson_progress for select using (user_id=auth.uid() or public.is_admin());
drop policy if exists "progress own insert" on public.lesson_progress;
create policy "progress own insert" on public.lesson_progress for insert with check (user_id=auth.uid());
drop policy if exists "progress own update" on public.lesson_progress;
create policy "progress own update" on public.lesson_progress for update using (user_id=auth.uid()) with check (user_id=auth.uid());

-- IMPORTANTE: depois de criar sua conta pelo site, execute este comando trocando
-- pelo UUID do seu usuário (Authentication > Users). Nunca permita autoelevação.
-- update public.profiles set role='admin' where id='COLE-SEU-UUID-AQUI';

-- O preço é R$ 29,99/mês após 3 meses grátis. A cobrança real exige gateway
-- (ex.: Stripe/Mercado Pago) e webhook seguro usando chave secreta somente no servidor.
