-- =====================================================================
-- Nação Capoeira – mise en place Supabase
-- À coller dans Supabase > SQL Editor > New query, puis "Run".
-- Le script peut être relancé sans risque.
-- =====================================================================

-- ---------- 1. Admins ----------
-- Seuls les comptes listés ici peuvent modifier le contenu du site.
create table if not exists public.admins (
  user_id uuid primary key references auth.users on delete cascade
);
alter table public.admins enable row level security;  -- aucune policy : invisible depuis le site

create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;

-- ---------- 2. Nouvelles tables ----------
create table if not exists public.photos (
  id bigint generated always as identity primary key,
  image_url text not null,
  caption text,
  path text,                      -- chemin du fichier dans le stockage (pour le supprimer)
  created_at timestamptz default now()
);

create table if not exists public.annonces (
  id bigint generated always as identity primary key,
  titre text not null,
  texte text,
  date_evenement date,            -- vide = annonce sans date ; sinon masquée après la date
  created_at timestamptz default now()
);

create table if not exists public.cordes (
  id bigint generated always as identity primary key,
  nom text not null,
  couleur1 text not null default '#cccccc',
  couleur2 text,                  -- vide = corde d'une seule couleur
  description text,
  ordre int default 0
);

create table if not exists public.club_info (
  key text primary key,
  value text
);
insert into public.club_info (key, value) values ('presentation', '')
  on conflict (key) do nothing;

-- ---------- 3. Sécurité des tables ----------
-- Tout le monde peut lire, seuls les admins connectés peuvent écrire.
-- Les anciennes règles (qui laissaient tout le monde écrire) sont supprimées.
do $$
declare
  t text;
  pol record;
begin
  foreach t in array array['songs', 'videos', 'photos', 'annonces', 'cordes', 'club_info'] loop
    for pol in select policyname from pg_policies where schemaname = 'public' and tablename = t loop
      execute format('drop policy %I on public.%I', pol.policyname, t);
    end loop;
    execute format('alter table public.%I enable row level security', t);
    execute format('create policy "lecture publique" on public.%I for select using (true)', t);
    execute format('create policy "ecriture admin" on public.%I for all to authenticated using (public.is_admin()) with check (public.is_admin())', t);
  end loop;
end $$;

-- ---------- 4. Stockage des photos ----------
insert into storage.buckets (id, name, public) values ('photos', 'photos', true)
  on conflict (id) do nothing;

drop policy if exists "photos admin lecture" on storage.objects;
drop policy if exists "photos admin ajout" on storage.objects;
drop policy if exists "photos admin suppression" on storage.objects;
create policy "photos admin lecture" on storage.objects for select to authenticated
  using (bucket_id = 'photos' and public.is_admin());
create policy "photos admin ajout" on storage.objects for insert to authenticated
  with check (bucket_id = 'photos' and public.is_admin());
create policy "photos admin suppression" on storage.objects for delete to authenticated
  using (bucket_id = 'photos' and public.is_admin());

-- ---------- 5. Ton compte admin ----------
-- D'abord : Authentication > Users > Add user > Create new user
--           (ton e-mail + un mot de passe, coche "Auto Confirm User").
-- Ensuite remplace l'e-mail ci-dessous et lance uniquement cette ligne :
--
-- insert into public.admins (user_id) select id from auth.users where email = 'ton.email@exemple.fr';
