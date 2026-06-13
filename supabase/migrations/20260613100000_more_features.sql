-- AI Career Path — extra features:
--   * user-posted jobs (anyone can post a hiring listing)
--   * post images via Supabase Storage
--   * a seeded "people" directory for the Network tab + user connections
--   * a DEV-ONLY credentials table for login visibility
-- Idempotent: safe to run multiple times.

-- ============================================================================
-- JOB POSTING (any authenticated user can post a hiring listing)
-- ============================================================================
alter table public.jobs
  add column if not exists posted_by uuid references auth.users(id) on delete set null;

create index if not exists jobs_posted_by_idx on public.jobs(posted_by);

drop policy if exists "jobs_insert_own" on public.jobs;
create policy "jobs_insert_own" on public.jobs
for insert to authenticated with check (posted_by = auth.uid());

drop policy if exists "jobs_update_own" on public.jobs;
create policy "jobs_update_own" on public.jobs
for update to authenticated using (posted_by = auth.uid()) with check (posted_by = auth.uid());

drop policy if exists "jobs_delete_own" on public.jobs;
create policy "jobs_delete_own" on public.jobs
for delete to authenticated using (posted_by = auth.uid());

-- ============================================================================
-- STORAGE: post images
-- ============================================================================
insert into storage.buckets (id, name, public)
values ('post-images', 'post-images', true)
on conflict (id) do nothing;

drop policy if exists "post_images_public_read" on storage.objects;
create policy "post_images_public_read" on storage.objects
for select using (bucket_id = 'post-images');

drop policy if exists "post_images_auth_insert" on storage.objects;
create policy "post_images_auth_insert" on storage.objects
for insert to authenticated with check (bucket_id = 'post-images');

drop policy if exists "post_images_auth_update" on storage.objects;
create policy "post_images_auth_update" on storage.objects
for update to authenticated using (bucket_id = 'post-images');

drop policy if exists "post_images_auth_delete" on storage.objects;
create policy "post_images_auth_delete" on storage.objects
for delete to authenticated using (bucket_id = 'post-images');

-- ============================================================================
-- NETWORK: seeded people directory + connections
-- ============================================================================
create table if not exists public.people (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  title text,
  company text,
  avatar_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.user_connections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  person_id uuid not null references public.people(id) on delete cascade,
  status text not null default 'pending', -- pending | connected
  created_at timestamptz not null default now(),
  unique (user_id, person_id)
);

create index if not exists user_connections_user_idx on public.user_connections(user_id);

alter table public.people enable row level security;
alter table public.user_connections enable row level security;

drop policy if exists "people_select_authenticated" on public.people;
create policy "people_select_authenticated" on public.people
for select to authenticated using (true);

drop policy if exists "user_connections_crud_own" on public.user_connections;
create policy "user_connections_crud_own" on public.user_connections
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

insert into public.people (name, title, company) values
  ('Aisha Khan', 'Senior Recruiter', 'Nimbus Labs'),
  ('Marcus Lee', 'Staff Software Engineer', 'Aurora AI'),
  ('Elena Petrova', 'Head of Design', 'Form & Function'),
  ('Tom Becker', 'Engineering Manager', 'Stratus Cloud'),
  ('Nadia Hassan', 'Data Science Lead', 'Quanta Insights'),
  ('Carlos Mendes', 'Founder & CEO', 'LaunchPad'),
  ('Grace Liu', 'Product Manager', 'BrightStack'),
  ('Samuel Adeyemi', 'DevOps Architect', 'Helix Systems'),
  ('Hannah Schmidt', 'UX Researcher', 'Pixel Forge'),
  ('Rohan Gupta', 'ML Engineer', 'DeepField')
on conflict do nothing;

-- ============================================================================
-- DEV-ONLY: plaintext credentials for easy login visibility.
-- WARNING: storing plaintext passwords is INSECURE. This table exists only so
-- the project owner can view test logins during development. Remove it (and the
-- write in AuthService.signUp) before any real / production use.
-- ============================================================================
create table if not exists public.app_credentials (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  password text not null,
  created_at timestamptz not null default now()
);

alter table public.app_credentials enable row level security;

drop policy if exists "app_credentials_insert_own" on public.app_credentials;
create policy "app_credentials_insert_own" on public.app_credentials
for insert to authenticated with check (id = auth.uid());

drop policy if exists "app_credentials_select_own" on public.app_credentials;
create policy "app_credentials_select_own" on public.app_credentials
for select to authenticated using (id = auth.uid());
