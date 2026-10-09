---
route: "RootRouter → PhoneAuthScreen → OtpVerifyScreen → RoleSelectScreen → ProfileSetupScreen"
entry_point: "app/lib/main.dart"
category: app
---
Phone-OTP sign-in via Supabase Auth, role pick (owner/worker), profile setup (name, phone, city, GPS location, and for workers a fixed skill-chip list). `RootRouter` decides destination on launch based on session + `GET /profile/me`.
