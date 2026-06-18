const router = require('express').Router();
const db     = require('../db');
const { requireAuth, requireRole } = require('../middleware/auth');

// GET /api/lawyers  — directorio público de abogados aprobados
router.get('/', async (req, res) => {
  const { city, specialty, search } = req.query;

  let sql = `
    select u.id, u.full_name, u.avatar_path,
           lp.city, lp.rating, lp.total_cases, lp.hourly_rate,
           lp.experience_years, lp.about, lp.avail_weekdays,
           lp.avail_weekends, lp.avail_urgent,
           array_agg(ls.specialty order by ls.specialty) filter (where ls.specialty is not null) as specialties
    from lawyer_profiles lp
    join users u on u.id = lp.id
    left join lawyer_specialties ls on ls.lawyer_id = lp.id
    where lp.verification_status = 'approved'
  `;
  const params = [];

  if (city) {
    params.push(city);
    sql += ` and lower(lp.city) = lower($${params.length})`;
  }
  if (specialty) {
    params.push(specialty);
    sql += ` and ls.specialty = $${params.length}`;
  }
  if (search) {
    params.push(`%${search}%`);
    sql += ` and (lower(u.full_name) like lower($${params.length}) or lower(lp.about) like lower($${params.length}))`;
  }

  sql += ' group by u.id, u.full_name, u.avatar_path, lp.city, lp.rating, lp.total_cases, lp.hourly_rate, lp.experience_years, lp.about, lp.avail_weekdays, lp.avail_weekends, lp.avail_urgent';
  sql += ' order by lp.rating desc';

  const { rows } = await db.query(sql, params);
  res.json(rows);
});

// GET /api/lawyers/:id  — perfil completo de abogado
router.get('/:id', async (req, res) => {
  const { rows } = await db.query(
    `select u.id, u.full_name, u.avatar_path,
            lp.city, lp.rating, lp.total_cases, lp.hourly_rate,
            lp.experience_years, lp.about, lp.colegiacion_number,
            lp.avail_weekdays, lp.avail_weekends, lp.avail_urgent,
            lp.verification_status,
            array_agg(ls.specialty order by ls.specialty) filter (where ls.specialty is not null) as specialties
     from lawyer_profiles lp
     join users u on u.id = lp.id
     left join lawyer_specialties ls on ls.lawyer_id = lp.id
     where lp.id = $1 and lp.verification_status = 'approved'
     group by u.id, u.full_name, u.avatar_path,
              lp.city, lp.rating, lp.total_cases, lp.hourly_rate,
              lp.experience_years, lp.about, lp.colegiacion_number,
              lp.avail_weekdays, lp.avail_weekends, lp.avail_urgent,
              lp.verification_status`,
    [req.params.id]
  );
  if (!rows[0]) return res.status(404).json({ error: 'Abogado no encontrado' });
  res.json(rows[0]);
});

// GET /api/lawyers/me/profile  — abogado autenticado ve su propio perfil
router.get('/me/profile', requireAuth, requireRole('lawyer'), async (req, res) => {
  const { rows } = await db.query(
    `select lp.*, array_agg(ls.specialty) filter (where ls.specialty is not null) as specialties
     from lawyer_profiles lp
     left join lawyer_specialties ls on ls.lawyer_id = lp.id
     where lp.id = $1
     group by lp.id`,
    [req.user.id]
  );
  if (!rows[0]) return res.status(404).json({ error: 'Perfil no encontrado' });
  res.json(rows[0]);
});

// PUT /api/lawyers/me/profile  — abogado edita su perfil
router.put('/me/profile', requireAuth, requireRole('lawyer'), async (req, res) => {
  const { about, city, hourly_rate, avail_weekdays, avail_weekends, avail_urgent, specialties } = req.body;

  await db.query(
    `update lawyer_profiles set
       about          = coalesce($1, about),
       city           = coalesce($2, city),
       hourly_rate    = coalesce($3, hourly_rate),
       avail_weekdays = coalesce($4, avail_weekdays),
       avail_weekends = coalesce($5, avail_weekends),
       avail_urgent   = coalesce($6, avail_urgent)
     where id = $7`,
    [about, city, hourly_rate, avail_weekdays, avail_weekends, avail_urgent, req.user.id]
  );

  if (Array.isArray(specialties)) {
    await db.query('delete from lawyer_specialties where lawyer_id = $1', [req.user.id]);
    for (const s of specialties) {
      await db.query(
        'insert into lawyer_specialties (lawyer_id, specialty) values ($1, $2) on conflict do nothing',
        [req.user.id, s]
      );
    }
  }

  res.json({ message: 'Perfil actualizado' });
});

// GET /api/lawyers/:id/reviews
router.get('/:id/reviews', async (req, res) => {
  const { rows } = await db.query(
    `select r.id, r.rating, r.comment, r.created_at,
            u.full_name as reviewer_name
     from reviews r
     join users u on u.id = r.reviewer_id
     where r.lawyer_id = $1
     order by r.created_at desc`,
    [req.params.id]
  );
  res.json(rows);
});

module.exports = router;
