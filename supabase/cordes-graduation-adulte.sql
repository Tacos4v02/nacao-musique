-- =====================================================================
-- Cordes de la graduation adulte Nação Capoeira (d'après le tableau officiel)
-- À coller dans Supabase > SQL Editor > New query, puis "Run".
-- ATTENTION : remplace toutes les cordes déjà enregistrées.
-- =====================================================================

alter table public.cordes add column if not exists categorie text;

delete from public.cordes;

insert into public.cordes (ordre, categorie, nom, couleur1, couleur2) values
  ( 1, 'Débutants',      'Vert',                 '#3cc83c', null),
  ( 2, 'Débutants',      'Vert / Jaune',         '#3cc83c', '#f5e04a'),
  ( 3, 'Débutants',      'Jaune',                '#f5e04a', null),
  ( 4, 'Intermédiaires', 'Jaune / Turquoise',    '#f5e04a', '#3cc8c8'),
  ( 5, 'Intermédiaires', 'Turquoise',            '#3cc8c8', null),
  ( 6, 'Intermédiaires', 'Turquoise / Vert foncé','#3cc8c8', '#1f7a2e'),
  ( 7, 'Gradés',         'Vert foncé',           '#1f7a2e', null),
  ( 8, 'Gradés',         'Vert foncé / Orange',  '#1f7a2e', '#e07b39'),
  ( 9, 'Monitors',       'Orange',               '#e07b39', null),
  (10, 'Monitors',       'Orange / Bleu',        '#e07b39', '#2a52a8'),
  (11, 'Formado',        'Bleu',                 '#2a52a8', null),
  (12, 'Formado',        'Bleu / Violet',        '#2a52a8', '#9c27a0'),
  (13, 'Professor',      'Violet',               '#9c27a0', null),
  (14, 'Professor',      'Violet / Rouge',       '#9c27a0', '#c0392b'),
  (15, 'Professor',      'Rouge',                '#c0392b', null),
  (16, 'Contra Mestre',  'Marron',               '#7a5230', null),
  (17, 'Contra Mestre',  'Marron / Noir',        '#7a5230', '#1a1a1a'),
  (18, 'Mestre',         'Noir',                 '#1a1a1a', null);

notify pgrst, 'reload schema';
