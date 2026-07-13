-- Aspect Power — Job Board migration
-- ---------------------------------------------------------------------------
-- Run this ONCE in your Supabase project so the Job Board's extra fields
-- (project/service type, checklist, status tag, contact) sync across every
-- device instead of living only on the device that entered them.
--
-- HOW TO RUN (about 30 seconds):
--   1. Open your project at https://supabase.com/dashboard
--   2. Left sidebar → "SQL Editor" → "New query"
--   3. Paste the line below, then press "Run"
--
-- Safe to run more than once (uses IF NOT EXISTS). It does not touch or delete
-- any existing work orders.
--
-- Note: the board already works WITHOUT running this — every job still sorts
-- into the correct stage column and stage moves save everywhere, because the
-- stage is stored in the existing `status` column. Running this simply adds
-- cloud sync for the type badge, checklist, status tag, and contact too.
-- ---------------------------------------------------------------------------

alter table work_orders
  add column if not exists board jsonb default '{}'::jsonb;
