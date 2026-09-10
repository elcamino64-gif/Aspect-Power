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
-- Scheduled-for date on each job (used to sort the board columns).
alter table board_jobs add column if not exists scheduled_date text;

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
-- Structured address parts.
alter table property_directory add column if not exists city  text;
alter table property_directory add column if not exists state text;
alter table property_directory add column if not exists zip   text;
alter table property_directory enable row level security;
drop policy if exists property_directory_all on property_directory;
create policy property_directory_all on property_directory for all using (true) with check (true);
grant all on property_directory to anon, authenticated;

-- ---------------------------------------------------------------------------
-- CORE TABLES — Work Orders, Properties, Technicians, Materials, Categories.
-- These make your WORK ORDERS sync across every device, and make entered data
-- (customer/property info, prices, materials) persist and sync. Run this file
-- once. Safe to run more than once; it never deletes your existing data.
-- ---------------------------------------------------------------------------

-- Work orders (the ones you email to the office)
create table if not exists work_orders (
  id             bigint primary key,
  date           text,
  by             text,
  park           text,
  space_location text,
  description    text,
  materials      jsonb default '[]'::jsonb,
  testing        jsonb default '[]'::jsonb,
  tech_labor     jsonb default '[]'::jsonb,
  tech_assist    jsonb default '[]'::jsonb,
  laborers       jsonb default '[]'::jsonb,
  fuel_vehicles  text,
  status         text,
  other_notes    text,
  total          numeric,
  created_at     timestamptz default now()
);
-- If work_orders already existed from an earlier version, make sure the newer
-- columns are present (all safe to run repeatedly).
alter table work_orders add column if not exists space_location text;
alter table work_orders add column if not exists testing     jsonb default '[]'::jsonb;
alter table work_orders add column if not exists tech_assist jsonb default '[]'::jsonb;
alter table work_orders add column if not exists other_notes text;
alter table work_orders add column if not exists created_at  timestamptz default now();
alter table work_orders enable row level security;
drop policy if exists work_orders_all on work_orders;
create policy work_orders_all on work_orders for all using (true) with check (true);
grant all on work_orders to anon, authenticated;

-- Properties (name + office-calculated mileage)
create table if not exists properties (
  name    text primary key,
  mileage numeric
);
alter table properties add column if not exists mileage numeric;
alter table properties enable row level security;
drop policy if exists properties_all on properties;
create policy properties_all on properties for all using (true) with check (true);
grant all on properties to anon, authenticated;

-- Technicians
create table if not exists technicians (
  name text primary key
);
alter table technicians enable row level security;
drop policy if exists technicians_all on technicians;
create policy technicians_all on technicians for all using (true) with check (true);
grant all on technicians to anon, authenticated;

-- Materials price book — remembers the last price per unit for each material
create table if not exists materials_db (
  name         text primary key,
  cost         text,
  category     text,
  manufacturer text
);
alter table materials_db add column if not exists manufacturer text;
alter table materials_db enable row level security;
drop policy if exists materials_db_all on materials_db;
create policy materials_db_all on materials_db for all using (true) with check (true);
grant all on materials_db to anon, authenticated;

-- Material categories
create table if not exists categories (
  id   bigint generated always as identity primary key,
  name text unique not null
);
alter table categories enable row level security;
drop policy if exists categories_all on categories;
create policy categories_all on categories for all using (true) with check (true);
grant all on categories to anon, authenticated;
grant usage, select on all sequences in schema public to anon, authenticated;
