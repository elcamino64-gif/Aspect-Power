-- Aspect Power — File storage for job attachments (photos, contracts, permits)
-- ---------------------------------------------------------------------------
-- This moves attachments out of the job records and into Supabase Storage, so
-- each file downloads on its own (fast) instead of every file loading at once.
--
-- HOW TO RUN (about 30 seconds):
--   1. Open your project at https://supabase.com/dashboard
--   2. Left sidebar -> "SQL Editor" -> "New query"
--   3. Paste everything below, then press "Run"
--
-- Safe to run more than once.
-- ---------------------------------------------------------------------------

-- A PRIVATE bucket for all job attachments (not publicly listable).
insert into storage.buckets (id, name, public)
values ('attachments', 'attachments', false)
on conflict (id) do nothing;

-- Let signed-in users read / upload / update / delete files in that bucket.
drop policy if exists att_read   on storage.objects;
drop policy if exists att_insert on storage.objects;
drop policy if exists att_update on storage.objects;
drop policy if exists att_delete on storage.objects;

create policy att_read   on storage.objects for select to authenticated
  using (bucket_id = 'attachments');
create policy att_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'attachments');
create policy att_update on storage.objects for update to authenticated
  using (bucket_id = 'attachments');
create policy att_delete on storage.objects for delete to authenticated
  using (bucket_id = 'attachments');
