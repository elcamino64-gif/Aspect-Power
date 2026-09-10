-- Aspect Power — Turn ON sign-in security
-- ---------------------------------------------------------------------------
-- This locks every table so it can ONLY be read or written by someone who is
-- signed in. Until you run this, the app's sign-in screen appears but the data
-- is still technically reachable with the public key, so run it once you have
-- created your login users AND confirmed you can sign in on the app.
--
-- BEFORE running this:
--   1. Dashboard -> Authentication -> Users -> "Add user" -> create each login
--      (email + password). Turn on "Auto Confirm User" so it's active.
--      Make one for yourself and one for Troy (any emails you like).
--   2. Open the app, reload with the newest ?v= number, and sign in with one of
--      those logins to confirm it works.
--   3. THEN run everything below (Dashboard -> SQL Editor -> New query -> Run).
--
-- Safe to run more than once. It does not delete any data.
-- ---------------------------------------------------------------------------

-- Helper: only allow signed-in requests.
--   auth.role() = 'authenticated'  is true only for a logged-in user token,
--   and false for the app's public (anon) key.

do $$
declare t text;
begin
  foreach t in array array[
    'work_orders','properties','technicians','materials_db','categories',
    'board_jobs','property_directory'
  ] loop
    execute format('alter table %I enable row level security;', t);
    execute format('drop policy if exists %I on %I;', t||'_all', t);
    execute format('drop policy if exists %I on %I;', t||'_authed', t);
    execute format(
      'create policy %I on %I for all to authenticated using (true) with check (true);',
      t||'_authed', t);
  end loop;
end $$;

-- ---------------------------------------------------------------------------
-- TO TURN SECURITY BACK OFF (revert to open access) — only if something breaks
-- and you need the app working again while we fix it. Uncomment and run:
--
-- do $$
-- declare t text;
-- begin
--   foreach t in array array[
--     'work_orders','properties','technicians','materials_db','categories',
--     'board_jobs','property_directory'
--   ] loop
--     execute format('drop policy if exists %I on %I;', t||'_authed', t);
--     execute format('drop policy if exists %I on %I;', t||'_all', t);
--     execute format('create policy %I on %I for all using (true) with check (true);', t||'_all', t);
--   end loop;
-- end $$;
-- ---------------------------------------------------------------------------
