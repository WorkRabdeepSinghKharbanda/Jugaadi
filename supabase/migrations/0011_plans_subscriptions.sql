create table plans (
  id text primary key,
  name text not null,
  price_paise int not null default 0,
  period_days int not null default 30,
  monthly_limit int -- null = unlimited
);

insert into plans (id, name, price_paise, period_days, monthly_limit) values
  ('free', 'Free', 0, 30, 3),
  ('pro', 'Pro', 19900, 30, null);

create table subscriptions (
  id bigint generated always as identity primary key,
  profile_id uuid not null unique references profiles(id) on delete cascade,
  plan_id text not null references plans(id),
  status text not null check (status in ('trialing','active','expired','cancelled')),
  trial_ends_at timestamptz,
  current_period_end timestamptz,
  razorpay_subscription_id text,
  created_at timestamptz not null default now()
);
