import express from 'express';
import { supabase } from './supabase.js';
import { requireAuth, requireAdmin } from './auth.js';

const app = express();
app.use(express.json());

app.get('/health', (_req, res) => res.json({ ok: true }));

app.post('/profile', requireAuth, async (req, res) => {
  const { role, full_name, phone, photo_url, city, lat, lng, skills } = req.body;
  if (!role || !full_name || !phone) {
    return res.status(400).json({ error: 'role, full_name, phone are required' });
  }

  const { error: profileError } = await supabase
    .from('profiles')
    .upsert({ id: req.userId, role, full_name, phone, photo_url, city, lat, lng });
  if (profileError) return res.status(500).json({ error: profileError.message });

  if (role === 'worker' && Array.isArray(skills)) {
    await supabase.from('worker_skills').delete().eq('worker_id', req.userId);
    if (skills.length) {
      const rows = skills.map((skill) => ({ worker_id: req.userId, skill }));
      const { error: skillsError } = await supabase.from('worker_skills').insert(rows);
      if (skillsError) return res.status(500).json({ error: skillsError.message });
    }
  }

  res.json({ ok: true });
});

app.get('/profile/me', requireAuth, async (req, res) => {
  const { data, error } = await supabase
    .from('profiles')
    .select('*, worker_skills(skill)')
    .eq('id', req.userId)
    .maybeSingle();
  if (error) return res.status(500).json({ error: error.message });
  if (!data) return res.status(404).json({ error: 'profile not found' });
  res.json(data);
});

app.post('/jobs', requireAuth, async (req, res) => {
  const { title, description, skill_needed, lat, lng, address_text, start_date, end_date, daily_wage } = req.body;
  if (!title || !skill_needed || lat == null || lng == null || !start_date || !end_date) {
    return res.status(400).json({ error: 'title, skill_needed, lat, lng, start_date, end_date are required' });
  }

  const { data, error } = await supabase
    .from('jobs')
    .insert({
      owner_id: req.userId,
      title,
      description,
      skill_needed,
      lat,
      lng,
      address_text,
      start_date,
      end_date,
      daily_wage,
    })
    .select()
    .single();
  if (error) return res.status(500).json({ error: error.message });
  res.status(201).json(data);
});

app.get('/jobs/nearby', requireAuth, async (req, res) => {
  const lat = Number(req.query.lat);
  const lng = Number(req.query.lng);
  const radius = req.query.radius ? Number(req.query.radius) : 5000;
  if (Number.isNaN(lat) || Number.isNaN(lng)) {
    return res.status(400).json({ error: 'lat and lng query params are required' });
  }

  const { data, error } = await supabase.rpc('nearby_jobs', {
    in_lat: lat,
    in_lng: lng,
    radius_m: radius,
  });
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
});

app.get('/applications/mine', requireAuth, async (req, res) => {
  const { data, error } = await supabase
    .from('job_applications')
    .select('status, job:jobs(*)')
    .eq('worker_id', req.userId)
    .order('created_at', { ascending: false });
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
});

app.get('/jobs/mine', requireAuth, async (req, res) => {
  const { data, error } = await supabase
    .from('jobs')
    .select('*')
    .eq('owner_id', req.userId)
    .order('created_at', { ascending: false });
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
});

app.get('/jobs/:id', requireAuth, async (req, res) => {
  const { data: job, error } = await supabase
    .from('jobs')
    .select('*, owner:profiles!jobs_owner_id_fkey(phone, full_name), hired_worker:profiles!jobs_hired_worker_id_fkey(phone, full_name)')
    .eq('id', req.params.id)
    .maybeSingle();
  if (error) return res.status(500).json({ error: error.message });
  if (!job) return res.status(404).json({ error: 'not found' });

  const isOwner = job.owner_id === req.userId;
  const isHiredWorker = job.hired_worker_id === req.userId;
  const contactRevealed = job.status !== 'open' && (isOwner || isHiredWorker);

  res.json({
    ...job,
    owner: isHiredWorker && contactRevealed ? job.owner : undefined,
    hired_worker: isOwner && contactRevealed ? job.hired_worker : undefined,
  });
});

app.post('/jobs/:id/apply', requireAuth, async (req, res) => {
  const { data, error } = await supabase
    .from('job_applications')
    .insert({ job_id: req.params.id, worker_id: req.userId })
    .select()
    .single();
  if (error) return res.status(500).json({ error: error.message });
  res.status(201).json(data);
});

app.get('/jobs/:id/applicants', requireAuth, async (req, res) => {
  const { data: job, error: jobError } = await supabase
    .from('jobs')
    .select('owner_id')
    .eq('id', req.params.id)
    .maybeSingle();
  if (jobError) return res.status(500).json({ error: jobError.message });
  if (!job || job.owner_id !== req.userId) return res.status(403).json({ error: 'forbidden' });

  const { data, error } = await supabase
    .from('job_applications')
    .select('*, worker:profiles!job_applications_worker_id_fkey(full_name, phone, is_verified, lat, lng)')
    .eq('job_id', req.params.id)
    .eq('status', 'pending');
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
});

app.post('/jobs/:id/hire/:workerId', requireAuth, async (req, res) => {
  const { id, workerId } = req.params;

  const { data: job, error: jobError } = await supabase
    .from('jobs')
    .select('owner_id, status')
    .eq('id', id)
    .maybeSingle();
  if (jobError) return res.status(500).json({ error: jobError.message });
  if (!job || job.owner_id !== req.userId) return res.status(403).json({ error: 'forbidden' });
  if (job.status !== 'open') return res.status(409).json({ error: 'job is not open' });

  const { error: hireError } = await supabase
    .from('jobs')
    .update({ status: 'hired', hired_worker_id: workerId })
    .eq('id', id);
  if (hireError) return res.status(500).json({ error: hireError.message });

  await supabase.from('job_applications').update({ status: 'accepted' }).eq('job_id', id).eq('worker_id', workerId);
  await supabase.from('job_applications').update({ status: 'rejected' }).eq('job_id', id).neq('worker_id', workerId);

  res.json({ ok: true });
});

app.post('/jobs/:id/complete', requireAuth, async (req, res) => {
  const { data: job, error: jobError } = await supabase
    .from('jobs')
    .select('owner_id, status')
    .eq('id', req.params.id)
    .maybeSingle();
  if (jobError) return res.status(500).json({ error: jobError.message });
  if (!job || job.owner_id !== req.userId) return res.status(403).json({ error: 'forbidden' });
  if (job.status !== 'hired') return res.status(409).json({ error: 'job is not hired' });

  const { error } = await supabase.from('jobs').update({ status: 'completed' }).eq('id', req.params.id);
  if (error) return res.status(500).json({ error: error.message });
  res.json({ ok: true });
});

app.patch('/admin/verify/:userId', requireAdmin, async (req, res) => {
  const { error } = await supabase
    .from('profiles')
    .update({ is_verified: true })
    .eq('id', req.params.userId);
  if (error) return res.status(500).json({ error: error.message });
  res.json({ ok: true });
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`jugaadi backend listening on ${port}`));
