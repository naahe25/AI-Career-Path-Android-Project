-- AI Career Path — Jobs (Indeed-style) + Professional Network (LinkedIn-style)
-- Adds: jobs, saved_jobs, job_applications, posts, post_likes, post_comments, connections.
-- Relies on public.set_updated_at() and the profiles table from the initial schema.

-- ============================================================================
-- JOBS
-- ============================================================================
create table if not exists public.jobs (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  company text not null,
  company_logo_url text,
  location text not null default 'Remote',
  is_remote boolean not null default false,
  employment_type text not null default 'full_time', -- full_time | part_time | contract | internship
  experience_level text not null default 'mid',      -- entry | mid | senior | lead
  category text,
  salary_min integer,
  salary_max integer,
  salary_currency text not null default 'USD',
  description text not null default '',
  requirements text[] not null default '{}',
  tags text[] not null default '{}',
  posted_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table if not exists public.saved_jobs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  job_id uuid not null references public.jobs(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (user_id, job_id)
);

create table if not exists public.job_applications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  job_id uuid not null references public.jobs(id) on delete cascade,
  status text not null default 'applied', -- applied | viewed | interview | rejected | offer
  cover_note text,
  applied_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (user_id, job_id)
);

create index if not exists jobs_posted_at_idx on public.jobs(posted_at desc);
create index if not exists saved_jobs_user_idx on public.saved_jobs(user_id);
create index if not exists job_applications_user_idx on public.job_applications(user_id);

-- ============================================================================
-- PROFESSIONAL NETWORK / FEED
-- ============================================================================
-- author_id is nullable so seeded/demo posts can exist before any real users.
-- Author display fields are denormalized for fast feed rendering.
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid references auth.users(id) on delete cascade,
  author_name text not null default 'Member',
  author_title text,
  author_avatar_url text,
  content text not null,
  image_url text,
  likes_count integer not null default 0,
  comments_count integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.post_likes (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (post_id, user_id)
);

create table if not exists public.post_comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  author_name text not null default 'Member',
  author_avatar_url text,
  content text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.connections (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references auth.users(id) on delete cascade,
  addressee_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'pending', -- pending | accepted
  created_at timestamptz not null default now(),
  unique (requester_id, addressee_id),
  check (requester_id <> addressee_id)
);

create index if not exists posts_created_at_idx on public.posts(created_at desc);
create index if not exists post_likes_post_idx on public.post_likes(post_id);
create index if not exists post_comments_post_idx on public.post_comments(post_id);
create index if not exists connections_requester_idx on public.connections(requester_id);
create index if not exists connections_addressee_idx on public.connections(addressee_id);

-- Keep denormalized counters in sync.
create or replace function public.bump_post_likes()
returns trigger language plpgsql as $$
begin
  if (tg_op = 'INSERT') then
    update public.posts set likes_count = likes_count + 1 where id = new.post_id;
  elsif (tg_op = 'DELETE') then
    update public.posts set likes_count = greatest(likes_count - 1, 0) where id = old.post_id;
  end if;
  return null;
end;
$$;

drop trigger if exists post_likes_counter on public.post_likes;
create trigger post_likes_counter
after insert or delete on public.post_likes
for each row execute function public.bump_post_likes();

create or replace function public.bump_post_comments()
returns trigger language plpgsql as $$
begin
  if (tg_op = 'INSERT') then
    update public.posts set comments_count = comments_count + 1 where id = new.post_id;
  elsif (tg_op = 'DELETE') then
    update public.posts set comments_count = greatest(comments_count - 1, 0) where id = old.post_id;
  end if;
  return null;
end;
$$;

drop trigger if exists post_comments_counter on public.post_comments;
create trigger post_comments_counter
after insert or delete on public.post_comments
for each row execute function public.bump_post_comments();

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================
alter table public.jobs enable row level security;
alter table public.saved_jobs enable row level security;
alter table public.job_applications enable row level security;
alter table public.posts enable row level security;
alter table public.post_likes enable row level security;
alter table public.post_comments enable row level security;
alter table public.connections enable row level security;

-- Jobs catalog is readable by everyone signed in.
drop policy if exists "jobs_select_authenticated" on public.jobs;
create policy "jobs_select_authenticated" on public.jobs
for select to authenticated using (true);

drop policy if exists "saved_jobs_crud_own" on public.saved_jobs;
create policy "saved_jobs_crud_own" on public.saved_jobs
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "job_applications_crud_own" on public.job_applications;
create policy "job_applications_crud_own" on public.job_applications
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Feed posts are visible to all signed-in members; you can only edit your own.
drop policy if exists "posts_select_authenticated" on public.posts;
create policy "posts_select_authenticated" on public.posts
for select to authenticated using (true);

drop policy if exists "posts_insert_own" on public.posts;
create policy "posts_insert_own" on public.posts
for insert to authenticated with check (author_id = auth.uid());

drop policy if exists "posts_update_own" on public.posts;
create policy "posts_update_own" on public.posts
for update to authenticated using (author_id = auth.uid()) with check (author_id = auth.uid());

drop policy if exists "posts_delete_own" on public.posts;
create policy "posts_delete_own" on public.posts
for delete to authenticated using (author_id = auth.uid());

drop policy if exists "post_likes_select_authenticated" on public.post_likes;
create policy "post_likes_select_authenticated" on public.post_likes
for select to authenticated using (true);

drop policy if exists "post_likes_crud_own" on public.post_likes;
create policy "post_likes_crud_own" on public.post_likes
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "post_comments_select_authenticated" on public.post_comments;
create policy "post_comments_select_authenticated" on public.post_comments
for select to authenticated using (true);

drop policy if exists "post_comments_crud_own" on public.post_comments;
create policy "post_comments_crud_own" on public.post_comments
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "connections_select_related" on public.connections;
create policy "connections_select_related" on public.connections
for select to authenticated
using (requester_id = auth.uid() or addressee_id = auth.uid());

drop policy if exists "connections_insert_own" on public.connections;
create policy "connections_insert_own" on public.connections
for insert to authenticated with check (requester_id = auth.uid());

drop policy if exists "connections_update_related" on public.connections;
create policy "connections_update_related" on public.connections
for update to authenticated
using (requester_id = auth.uid() or addressee_id = auth.uid())
with check (requester_id = auth.uid() or addressee_id = auth.uid());

drop policy if exists "connections_delete_related" on public.connections;
create policy "connections_delete_related" on public.connections
for delete to authenticated
using (requester_id = auth.uid() or addressee_id = auth.uid());

-- Allow members to discover each other (needed for the Network tab).
drop policy if exists "profiles_select_authenticated" on public.profiles;
create policy "profiles_select_authenticated" on public.profiles
for select to authenticated using (true);

-- ============================================================================
-- SEED DATA
-- ============================================================================
insert into public.jobs
  (title, company, location, is_remote, employment_type, experience_level, category,
   salary_min, salary_max, description, requirements, tags, posted_at)
values
  ('Senior Flutter Engineer', 'Nimbus Labs', 'San Francisco, CA', true, 'full_time', 'senior', 'Mobile Development',
   140000, 185000,
   'Build delightful cross-platform experiences used by millions. You will own the mobile architecture, mentor engineers, and partner with design on a polished, animated UI.',
   array['5+ years mobile development', 'Expert in Flutter & Dart', 'Strong understanding of state management', 'Experience shipping to the App Store & Play Store'],
   array['Flutter','Dart','Riverpod','CI/CD'], now() - interval '1 day'),
  ('AI Product Manager', 'Aurora AI', 'New York, NY', false, 'full_time', 'mid', 'Artificial Intelligence',
   130000, 170000,
   'Define and ship AI-powered product experiences. Translate user needs into roadmaps and work closely with ML engineers and designers.',
   array['3+ years product management', 'Understanding of LLMs and AI UX', 'Excellent communication', 'Data-informed decision making'],
   array['AI','Product','Strategy','LLM'], now() - interval '2 days'),
  ('Frontend Developer (React)', 'BrightStack', 'Remote', true, 'full_time', 'mid', 'Web Development',
   95000, 125000,
   'Craft fast, accessible web interfaces with React and TypeScript. Collaborate in a fully remote, async-friendly team.',
   array['React & TypeScript', 'CSS architecture', 'Testing with Jest', 'Attention to accessibility'],
   array['React','TypeScript','CSS','Remote'], now() - interval '3 days'),
  ('Data Analyst', 'Quanta Insights', 'Austin, TX', false, 'full_time', 'entry', 'Data',
   70000, 95000,
   'Turn raw data into actionable insight. Build dashboards, run SQL analyses, and present findings to stakeholders.',
   array['SQL proficiency', 'Dashboarding (Looker/Tableau)', 'Statistics fundamentals', 'Clear storytelling'],
   array['SQL','Analytics','Tableau','Dashboards'], now() - interval '4 days'),
  ('Machine Learning Engineer', 'DeepField', 'Seattle, WA', true, 'full_time', 'senior', 'Artificial Intelligence',
   150000, 200000,
   'Design, train, and deploy ML models in production. Own the full lifecycle from data pipelines to monitoring.',
   array['Python & PyTorch/TensorFlow', 'MLOps experience', 'Strong CS fundamentals', 'Production model deployment'],
   array['Python','PyTorch','MLOps','ML'], now() - interval '5 days'),
  ('UX/UI Designer', 'Form & Function', 'Remote', true, 'contract', 'mid', 'Design',
   80000, 110000,
   'Design clean, modern, 3D-inspired interfaces. Build prototypes, run usability tests, and maintain a design system.',
   array['Figma mastery', 'Design systems', 'Prototyping & motion', 'Portfolio of shipped products'],
   array['Figma','UI','UX','Design Systems'], now() - interval '6 days'),
  ('Backend Engineer (Node.js)', 'Stratus Cloud', 'Boston, MA', false, 'full_time', 'mid', 'Web Development',
   110000, 145000,
   'Build scalable APIs and services. Work with Postgres, queues, and cloud infrastructure to support rapid growth.',
   array['Node.js & TypeScript', 'PostgreSQL', 'REST/GraphQL APIs', 'Cloud (AWS/GCP)'],
   array['Node.js','PostgreSQL','AWS','API'], now() - interval '7 days'),
  ('Junior Software Engineer', 'LaunchPad', 'Remote', true, 'full_time', 'entry', 'Software Engineering',
   75000, 95000,
   'Kickstart your career in a supportive team. Pair with senior engineers, write tested code, and grow fast.',
   array['CS fundamentals', 'One modern language', 'Eagerness to learn', 'Good collaboration'],
   array['Entry Level','Mentorship','Growth'], now() - interval '8 days'),
  ('Product Designer Intern', 'Pixel Forge', 'Los Angeles, CA', false, 'internship', 'entry', 'Design',
   null, null,
   'A paid internship to learn product design end to end. Contribute to real features under mentorship.',
   array['Design coursework or portfolio', 'Figma basics', 'Curiosity', 'Team player'],
   array['Internship','Design','Figma'], now() - interval '9 days'),
  ('DevOps Engineer', 'Helix Systems', 'Denver, CO', true, 'full_time', 'senior', 'Infrastructure',
   125000, 165000,
   'Automate everything. Own CI/CD, infrastructure-as-code, observability, and reliability for our platform.',
   array['Kubernetes & Docker', 'Terraform', 'CI/CD pipelines', 'Monitoring & alerting'],
   array['Kubernetes','Terraform','CI/CD','DevOps'], now() - interval '10 days')
on conflict do nothing;

insert into public.posts
  (author_name, author_title, content, likes_count, comments_count, created_at)
values
  ('Maya Chen', 'Senior Flutter Engineer @ Nimbus Labs',
   'Just shipped a fully animated, 3D-inspired UI in Flutter 🎉 The trick to a "classy" feel on a light background? Soft dual shadows, generous radii, and restrained motion. Happy to share the design tokens we used!',
   42, 7, now() - interval '3 hours'),
  ('David Okafor', 'AI Product Manager @ Aurora AI',
   'Career tip: your roadmap matters more than your resume. Pick a target role, reverse-engineer the skills, and ship one project per milestone. Consistency beats intensity. 🚀',
   88, 12, now() - interval '8 hours'),
  ('Priya Nair', 'Data Analyst @ Quanta Insights',
   'Landed my first analyst role after 4 months of focused learning! SQL + a portfolio of 3 dashboards made all the difference. To everyone grinding: keep going. 💪',
   215, 34, now() - interval '1 day'),
  ('Liam Walsh', 'Engineering Manager @ Stratus Cloud',
   'We are hiring backend engineers. But more importantly — we hire for curiosity and kindness, not just credentials. Tag someone who deserves a shot. 👇',
   63, 19, now() - interval '2 days'),
  ('Sofia Romero', 'Product Designer @ Form & Function',
   'Light mode is back in a big way. Clean canvases, soft depth, and one confident accent color. Less neon, more craft. What design trend are you loving right now?',
   127, 21, now() - interval '3 days')
on conflict do nothing;
