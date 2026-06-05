create extension if not exists "pgcrypto";

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  avatar_url text,
  current_skills text[] not null default '{}',
  education_level text,
  years_of_experience integer not null default 0 check (years_of_experience >= 0),
  user_current_role text,
  desired_field text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.career_paths (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text,
  target_role text not null,
  estimated_duration_months integer check (estimated_duration_months is null or estimated_duration_months > 0),
  difficulty_level text not null default 'intermediate',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.milestones (
  id uuid primary key default gen_random_uuid(),
  career_path_id uuid not null references public.career_paths(id) on delete cascade,
  title text not null,
  description text,
  order_index integer not null default 0,
  is_completed boolean not null default false,
  resources jsonb not null default '[]'::jsonb,
  skills_gained text[] not null default '{}',
  estimated_weeks integer check (estimated_weeks is null or estimated_weeks > 0),
  completed_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.user_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  career_path_id uuid not null references public.career_paths(id) on delete cascade,
  completion_percentage numeric(5,2) not null default 0 check (completion_percentage between 0 and 100),
  last_activity_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, career_path_id)
);

create table if not exists public.ai_recommendations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  prompt_context jsonb not null default '{}'::jsonb,
  raw_response text,
  parsed_career_paths jsonb,
  model_used text,
  tokens_used integer,
  created_at timestamptz not null default now()
);

create table if not exists public.user_analytics (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade unique,
  learning_hours integer not null default 0,
  milestones_completed integer not null default 0,
  skills_acquired integer not null default 0,
  current_streak integer not null default 0,
  longest_streak integer not null default 0,
  last_activity_date timestamptz,
  weekly_progress jsonb,
  monthly_progress jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.daily_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  date date not null default current_date,
  milestones_worked integer not null default 0,
  learning_minutes integer not null default 0,
  skills_worked_on integer not null default 0,
  created_at timestamptz not null default now(),
  unique (user_id, date)
);

create table if not exists public.skills (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text,
  category text,
  difficulty text not null default 'intermediate',
  estimated_hours integer not null default 0,
  icon_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.user_skills (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  skill_id uuid not null references public.skills(id) on delete cascade,
  proficiency_level integer not null default 0 check (proficiency_level between 0 and 100),
  hours_invested integer not null default 0,
  started_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  unique (user_id, skill_id)
);

create table if not exists public.skill_resources (
  id uuid primary key default gen_random_uuid(),
  skill_id uuid not null references public.skills(id) on delete cascade,
  resource_type text not null,
  title text not null,
  url text,
  difficulty text,
  duration_hours integer,
  created_at timestamptz not null default now()
);

create table if not exists public.achievements (
  id text primary key,
  title text not null,
  description text not null default '',
  icon_url text,
  threshold integer,
  type text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.user_achievements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  achievement_id text not null references public.achievements(id) on delete cascade,
  earned_at timestamptz not null default now(),
  unique (user_id, achievement_id)
);

create table if not exists public.badges (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  level integer not null default 1,
  progress integer not null default 0,
  max_progress integer not null default 100,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_settings (
  id text primary key default gen_random_uuid()::text,
  user_id uuid not null references auth.users(id) on delete cascade unique,
  theme text not null default 'system',
  notifications_enabled boolean not null default true,
  email_notifications boolean not null default true,
  push_notifications boolean not null default true,
  newsletter_subscribed boolean not null default true,
  language text not null default 'en',
  privacy_level text not null default 'private',
  two_factor_enabled boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.learning_resources (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  resource_type text not null,
  url text,
  provider text,
  difficulty text,
  estimated_hours integer,
  rating numeric(3,2),
  reviews_count integer not null default 0,
  thumbnail_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.user_bookmarks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  resource_id uuid not null references public.learning_resources(id) on delete cascade,
  bookmarked_at timestamptz not null default now(),
  unique (user_id, resource_id)
);

create table if not exists public.resource_completions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  resource_id uuid not null references public.learning_resources(id) on delete cascade,
  completed_at timestamptz not null default now(),
  notes text,
  created_at timestamptz not null default now(),
  unique (user_id, resource_id)
);

create index if not exists career_paths_user_id_idx on public.career_paths(user_id);
create index if not exists milestones_career_path_id_idx on public.milestones(career_path_id);
create index if not exists user_skills_user_id_idx on public.user_skills(user_id);
create index if not exists daily_progress_user_date_idx on public.daily_progress(user_id, date desc);

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists career_paths_set_updated_at on public.career_paths;
create trigger career_paths_set_updated_at
before update on public.career_paths
for each row execute function public.set_updated_at();

drop trigger if exists user_progress_set_updated_at on public.user_progress;
create trigger user_progress_set_updated_at
before update on public.user_progress
for each row execute function public.set_updated_at();

drop trigger if exists user_analytics_set_updated_at on public.user_analytics;
create trigger user_analytics_set_updated_at
before update on public.user_analytics
for each row execute function public.set_updated_at();

drop trigger if exists badges_set_updated_at on public.badges;
create trigger badges_set_updated_at
before update on public.badges
for each row execute function public.set_updated_at();

drop trigger if exists user_settings_set_updated_at on public.user_settings;
create trigger user_settings_set_updated_at
before update on public.user_settings
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)))
  on conflict (id) do nothing;

  insert into public.user_settings (id, user_id)
  values ('settings_' || new.id::text, new.id)
  on conflict (user_id) do nothing;

  insert into public.user_analytics (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.career_paths enable row level security;
alter table public.milestones enable row level security;
alter table public.user_progress enable row level security;
alter table public.ai_recommendations enable row level security;
alter table public.user_analytics enable row level security;
alter table public.daily_progress enable row level security;
alter table public.skills enable row level security;
alter table public.user_skills enable row level security;
alter table public.skill_resources enable row level security;
alter table public.achievements enable row level security;
alter table public.user_achievements enable row level security;
alter table public.badges enable row level security;
alter table public.user_settings enable row level security;
alter table public.learning_resources enable row level security;
alter table public.user_bookmarks enable row level security;
alter table public.resource_completions enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles
for select to authenticated using (id = auth.uid());

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own" on public.profiles
for insert to authenticated with check (id = auth.uid());

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists "career_paths_crud_own" on public.career_paths;
create policy "career_paths_crud_own" on public.career_paths
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "milestones_crud_own_path" on public.milestones;
create policy "milestones_crud_own_path" on public.milestones
for all to authenticated
using (
  exists (
    select 1 from public.career_paths
    where career_paths.id = milestones.career_path_id
      and career_paths.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.career_paths
    where career_paths.id = milestones.career_path_id
      and career_paths.user_id = auth.uid()
  )
);

drop policy if exists "user_progress_crud_own" on public.user_progress;
create policy "user_progress_crud_own" on public.user_progress
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "ai_recommendations_select_own" on public.ai_recommendations;
create policy "ai_recommendations_select_own" on public.ai_recommendations
for select to authenticated using (user_id = auth.uid());

drop policy if exists "analytics_crud_own" on public.user_analytics;
create policy "analytics_crud_own" on public.user_analytics
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "daily_progress_crud_own" on public.daily_progress;
create policy "daily_progress_crud_own" on public.daily_progress
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "skills_select_authenticated" on public.skills;
create policy "skills_select_authenticated" on public.skills
for select to authenticated using (true);

drop policy if exists "user_skills_crud_own" on public.user_skills;
create policy "user_skills_crud_own" on public.user_skills
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "skill_resources_select_authenticated" on public.skill_resources;
create policy "skill_resources_select_authenticated" on public.skill_resources
for select to authenticated using (true);

drop policy if exists "achievements_select_authenticated" on public.achievements;
create policy "achievements_select_authenticated" on public.achievements
for select to authenticated using (true);

drop policy if exists "user_achievements_crud_own" on public.user_achievements;
create policy "user_achievements_crud_own" on public.user_achievements
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "badges_crud_own" on public.badges;
create policy "badges_crud_own" on public.badges
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "user_settings_crud_own" on public.user_settings;
create policy "user_settings_crud_own" on public.user_settings
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "learning_resources_select_authenticated" on public.learning_resources;
create policy "learning_resources_select_authenticated" on public.learning_resources
for select to authenticated using (true);

drop policy if exists "user_bookmarks_crud_own" on public.user_bookmarks;
create policy "user_bookmarks_crud_own" on public.user_bookmarks
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "resource_completions_crud_own" on public.resource_completions;
create policy "resource_completions_crud_own" on public.resource_completions
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

create or replace function public.get_total_learning_time(user_id uuid)
returns integer
language sql
stable
as $$
  select coalesce(sum(learning_minutes), 0)::integer
  from public.daily_progress
  where daily_progress.user_id = $1;
$$;

create or replace function public.get_current_streak(user_id uuid)
returns integer
language sql
stable
as $$
  select coalesce(current_streak, 0)
  from public.user_analytics
  where user_analytics.user_id = $1
  limit 1;
$$;

insert into public.achievements (id, title, description, threshold, type)
values
  ('first-path', 'First Roadmap', 'Generate and save your first career roadmap.', 1, 'roadmap'),
  ('streak-7', 'Seven Day Streak', 'Keep learning for seven days.', 7, 'streak'),
  ('resume-ready', 'Resume Ready', 'Complete a resume review workflow.', 1, 'resume'),
  ('interview-ready', 'Interview Ready', 'Reach an interview readiness score of 80 or higher.', 80, 'interview'),
  ('skill-master', 'Skill Mastery', 'Complete your first tracked skill.', 1, 'skill'),
  ('network-builder', 'Network Builder', 'Start building your professional network.', 5, 'network')
on conflict (id) do update set
  title = excluded.title,
  description = excluded.description,
  threshold = excluded.threshold,
  type = excluded.type;

insert into public.skills (name, description, category, difficulty, estimated_hours)
values
  ('Flutter Architecture', 'Build scalable Flutter apps with clean architecture and Riverpod.', 'Mobile Development', 'intermediate', 45),
  ('AI Product UX', 'Design practical AI workflows for recommendations, coaching, and feedback.', 'Artificial Intelligence', 'intermediate', 32),
  ('ATS Resume Writing', 'Create resumes that are clear, measurable, and ATS-friendly.', 'Career Growth', 'beginner', 12),
  ('Interview Storytelling', 'Practice behavioral stories, confidence, and communication.', 'Career Growth', 'intermediate', 16),
  ('SQL Analytics', 'Analyze product and career progress data with SQL.', 'Data', 'beginner', 24),
  ('Machine Learning Basics', 'Understand model training, evaluation, and responsible usage.', 'Artificial Intelligence', 'advanced', 60),
  ('LinkedIn Optimization', 'Improve professional branding and search visibility.', 'Professional Branding', 'beginner', 10)
on conflict (name) do update set
  description = excluded.description,
  category = excluded.category,
  difficulty = excluded.difficulty,
  estimated_hours = excluded.estimated_hours;

insert into public.learning_resources
  (title, description, resource_type, url, provider, difficulty, estimated_hours, rating, reviews_count)
values
  ('Flutter Clean Architecture Guide', 'A practical guide for scalable app structure.', 'article', 'https://docs.flutter.dev', 'Flutter', 'intermediate', 4, 4.8, 128),
  ('AI Product Management Foundations', 'Core ideas for building useful AI-powered products.', 'course', 'https://www.coursera.org', 'Coursera', 'intermediate', 10, 4.7, 942),
  ('ATS Resume Checklist', 'Checklist for resume structure, keywords, and measurable impact.', 'article', 'https://www.linkedin.com', 'LinkedIn', 'beginner', 2, 4.5, 310),
  ('SQL for Data Analysis', 'Practice SQL queries for dashboards and reports.', 'course', 'https://www.khanacademy.org', 'Khan Academy', 'beginner', 8, 4.6, 802),
  ('Mock Interview Practice Plan', 'A repeatable plan for technical and behavioral interviews.', 'project', 'https://github.com', 'GitHub', 'intermediate', 6, 4.4, 166)
on conflict do nothing;
