-- Aspect Power — Job Board storage
-- ---------------------------------------------------------------------------
-- The Job Board is SEPARATE from your Orders. Board jobs are stored in their
-- own table (board_jobs) — adding a job to the board never creates a work
-- order, and the two lists never mix.
--
-- Run this ONCE so the board syncs across every device. Without it the board
-- still works, but board jobs are saved only on the phone that added them.
--
-- HOW TO RUN (about 30 seconds):
--   1. Open your project at https://supabase.com/dashboard
--   2. Left sidebar → "SQL Editor" → "New query"
--   3. Paste everything below, then press "Run"
--
-- Safe to run more than once. It does not touch your work orders.
-- ---------------------------------------------------------------------------

create table if not exists board_jobs (
  id          bigint primary key,
  park        text,
  type        text,
  stage       text,
  technician  text,
  location    text,
  description text,
  amount      numeric,
  status_tag  text,
  contact     text,
  notes       text,
  checklist   jsonb default '[]'::jsonb,
  attachments jsonb default '[]'::jsonb,
  created_at  timestamptz default now()
);

-- If board_jobs already existed from an earlier run, make sure the newer
-- columns are present (safe to run repeatedly).
alter table board_jobs add column if not exists attachments jsonb default '[]'::jsonb;

-- Allow the app (anon key) to read/write, matching the existing tables.
alter table board_jobs enable row level security;
drop policy if exists board_jobs_all on board_jobs;
create policy board_jobs_all on board_jobs for all using (true) with check (true);
grant all on board_jobs to anon, authenticated;

-- ---------------------------------------------------------------------------
-- Property directory: one saved contact + address per property, so new jobs
-- auto-fill contact info and the Contacts screen can edit it. Run this too.
-- ---------------------------------------------------------------------------
create table if not exists property_directory (
  name          text primary key,
  contact_name  text,
  contact_phone text,
  contact_email text,
  address       text
);
-- Multiple contacts per property (each: name, title, phone, email) live here.
alter table property_directory add column if not exists contacts jsonb default '[]'::jsonb;
alter table property_directory enable row level security;
drop policy if exists property_directory_all on property_directory;
create policy property_directory_all on property_directory for all using (true) with check (true);
grant all on property_directory to anon, authenticated;
