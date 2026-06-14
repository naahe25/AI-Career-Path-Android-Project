-- AI Career Path — profile pictures, CV uploads on Apply, and hiring-post applicants.
--   * avatars + cvs public storage buckets (+ policies)
--   * job_applications: CV + denormalized applicant info
--   * RLS so a job's poster can see who applied to their listing
--   * app_credentials: allow upsert (insert OR update) so login also records creds
-- Idempotent: safe to run multiple times.

-- ============================================================================
-- STORAGE: profile avatars + applicant CVs (public buckets)
-- ============================================================================
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('cvs', 'cvs', true)
on conflict (id) do nothing;

-- Avatars
drop policy if exists "avatars_public_read" on storage.objects;
create policy "avatars_public_read" on storage.objects
for select using (bucket_id = 'avatars');

drop policy if exists "avatars_auth_insert" on storage.objects;
create policy "avatars_auth_insert" on storage.objects
for insert to authenticated with check (bucket_id = 'avatars');

drop policy if exists "avatars_auth_update" on storage.objects;
create policy "avatars_auth_update" on storage.objects
for update to authenticated using (bucket_id = 'avatars');

drop policy if exists "avatars_auth_delete" on storage.objects;
create policy "avatars_auth_delete" on storage.objects
for delete to authenticated using (bucket_id = 'avatars');

-- CVs
drop policy if exists "cvs_public_read" on storage.objects;
create policy "cvs_public_read" on storage.objects
for select using (bucket_id = 'cvs');

drop policy if exists "cvs_auth_insert" on storage.objects;
create policy "cvs_auth_insert" on storage.objects
for insert to authenticated with check (bucket_id = 'cvs');

drop policy if exists "cvs_auth_update" on storage.objects;
create policy "cvs_auth_update" on storage.objects
for update to authenticated using (bucket_id = 'cvs');

drop policy if exists "cvs_auth_delete" on storage.objects;
create policy "cvs_auth_delete" on storage.objects
for delete to authenticated using (bucket_id = 'cvs');

-- ============================================================================
-- JOB APPLICATIONS: CV + denormalized applicant info (LinkedIn-style Apply)
-- ============================================================================
alter table public.job_applications
  add column if not exists cv_url text,
  add column if not exists cv_name text,
  add column if not exists applicant_name text,
  add column if not exists applicant_avatar_url text,
  add column if not exists applicant_headline text;

create index if not exists job_applications_job_idx
  on public.job_applications(job_id);

-- A job's poster can read every application submitted to a job they posted,
-- in addition to the existing "own application" policy.
drop policy if exists "job_applications_select_poster" on public.job_applications;
create policy "job_applications_select_poster" on public.job_applications
for select to authenticated
using (
  exists (
    select 1 from public.jobs
    where jobs.id = job_applications.job_id
      and jobs.posted_by = auth.uid()
  )
);

-- ============================================================================
-- DEV-ONLY app_credentials: allow updates so sign-in can upsert the row too.
-- (Table created in 20260613100000_more_features.sql.)
-- ============================================================================
drop policy if exists "app_credentials_update_own" on public.app_credentials;
create policy "app_credentials_update_own" on public.app_credentials
for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
