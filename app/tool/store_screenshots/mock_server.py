#!/usr/bin/env python3
"""Mock Jugaadi backend for Play Store screenshots. DEMO data only (invented names/areas/numbers).

Mirrors the response shapes of backend/src/controllers/*.ts. Also exposes a tiny control channel
the screenshot app polls:  GET /__screen -> {"n": N, "rev": R};  POST /__screen?n=N -> show screen N;  POST /__fill ["a","b"] -> fill the on-screen text fields in order.
Task photos are generated flat illustrations (PIL), served from /img/<name>.jpg.

Run: python3 mock_server.py 8787
"""
import io, json, sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse, parse_qs

from PIL import Image, ImageDraw

ME = "00000000-0000-4000-8000-000000000001"
OWNER = "00000000-0000-4000-8000-0000000000aa"
LAT, LNG = 12.9784, 77.6408  # Indiranagar, Bengaluru
state = {"n": 0, "rev": 0, "fill": [], "frev": 0}


# ---------------------------------------------------------------- photos
def _grad(w, h, top, bot):
    img = Image.new("RGB", (w, h))
    d = ImageDraw.Draw(img)
    for y in range(h):
        t = y / h
        d.line([(0, y), (w, y)], fill=tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3)))
    return img, d


def _box(d, x, y, w, h, col):
    dark = tuple(int(c * 0.78) for c in col)
    d.rectangle([x, y, x + w, y + h], fill=col, outline=dark, width=3)
    d.rectangle([x + w // 2 - 7, y, x + w // 2 + 7, y + h], fill=(214, 190, 140))
    d.rectangle([x + 8, y + h - 26, x + 52, y + h - 12], fill=(245, 245, 240))


def photo(name):
    W, H = 640, 480
    if name == "cartons":
        img, d = _grad(W, H, (205, 214, 224), (150, 158, 168))
        d.rectangle([0, 340, W, H], fill=(112, 112, 118))
        cols = [(196, 150, 96), (186, 140, 88), (204, 160, 104)]
        y = 340
        for row, n in enumerate([4, 3, 2]):
            for i in range(n):
                _box(d, 60 + i * 140 + row * 70, y - 100 * (row + 1), 130, 98, cols[(i + row) % 3])
        d.rectangle([470, 120, 620, 340], fill=(60, 90, 140))  # tempo
        d.rectangle([490, 140, 600, 210], fill=(170, 205, 235))
    elif name == "shop":
        img, d = _grad(W, H, (245, 232, 205), (226, 204, 160))
        d.rectangle([0, 380, W, H], fill=(140, 110, 80))
        for sy in (110, 230, 350):
            d.rectangle([40, sy, 600, sy + 10], fill=(110, 78, 50))
            x = 60
            for i in range(12):
                col = [(214, 70, 60), (60, 140, 200), (240, 190, 50), (80, 170, 100)][i % 4]
                h = 50 + (i * 17) % 40
                d.rectangle([x, sy - h, x + 34, sy], fill=col)
                x += 44
    else:  # furniture
        img, d = _grad(W, H, (226, 232, 238), (190, 196, 204))
        d.rectangle([0, 350, W, H], fill=(150, 124, 98))
        d.rounded_rectangle([90, 220, 420, 350], 24, fill=(70, 110, 120))
        d.rounded_rectangle([90, 170, 420, 250], 24, fill=(86, 128, 140))
        d.rectangle([450, 260, 580, 350], fill=(120, 84, 56))
        d.rectangle([470, 350, 480, 400], fill=(90, 60, 40))
        d.rectangle([550, 350, 560, 400], fill=(90, 60, 40))
        d.ellipse([480, 200, 550, 262], fill=(230, 200, 90))
    buf = io.BytesIO()
    img.save(buf, "JPEG", quality=88)
    return buf.getvalue()


PHOTOS = {n: photo(n) for n in ("cartons", "shop", "furniture")}


# ---------------------------------------------------------------- data
def job(id, title, skill, area, line2, start, end, wage, status="open", need=1, hired=0, owner=OWNER, photos=(), lat=LAT, lng=LNG, created="2026-10-13T09:30:00+00:00", **extra):
    return {
        "id": id, "owner_id": owner, "title": title, "description": None, "skill_needed": skill,
        "lat": lat, "lng": lng, "address_text": area, "address_line2": line2,
        "start_date": start, "end_date": end, "daily_wage": wage, "status": status,
        "hired_worker_id": None, "created_at": created, "photo_urls": list(photos),
        "workers_needed": need, "hired_count": hired, **extra,
    }


def worker(name, phone, verified, city, bio, skills):
    return {"full_name": name, "phone": phone, "is_verified": verified, "city": city, "bio": bio,
            "worker_skills": [{"skill": s} for s in skills]}


W = {
    "w1": ("00000000-0000-4000-8000-000000000b01", worker("Suresh Gowda", "+919876501201", True, "Indiranagar, Bengaluru", "5 years in godown and truck unloading. Own helper available.", ["loading-unloading", "packing"])),
    "w2": ("00000000-0000-4000-8000-000000000b02", worker("Imran Pasha", "+919876501202", True, "Shivajinagar, Bengaluru", "Strong, punctual. Worked with Diwali sweet shops last year.", ["loading-unloading", "helper"])),
    "w3": ("00000000-0000-4000-8000-000000000b03", worker("Manjunath R", "+919876501203", False, "Domlur, Bengaluru", "New to the app, 2 years of warehouse work.", ["loading-unloading"])),
    "w4": ("00000000-0000-4000-8000-000000000b04", worker("Venkatesh Naik", "+919876501204", True, "Ulsoor, Bengaluru", "Delivery and shop-floor helper. Speaks Kannada, Hindi, Telugu.", ["helper", "delivery"])),
    "w5": ("00000000-0000-4000-8000-000000000b05", worker("Lakshmi Devi", "+919876501205", True, "Jeevan Bima Nagar, Bengaluru", "Careful with fragile items, 4 years in shops.", ["packing", "cleaning"])),
}

# Worker-side (nearby / applications) jobs, posted by other owners.
P = lambda *n: [f"@{x}" for x in n]  # photo placeholders resolved per-request (host aware)
NEAR = [
    job(101, "Unload tempo truck - 40 cartons", "loading-unloading", "Indiranagar, Bengaluru", "Sri Lakshmi Traders, 100 Feet Road", "2026-10-15", "2026-10-15", 700, my_application_status="pending", photos=P("cartons")),
    job(102, "Shop helper for Diwali rush", "helper", "Koramangala, Bengaluru", "Bangalore Sweets, 5th Block", "2026-10-16", "2026-10-25", 650, need=2, my_application_status="accepted", photos=P("shop")),
    job(103, "Move furniture to new flat", "loading-unloading", "HSR Layout, Bengaluru", "Sector 2, near Agara Lake", "2026-10-18", "2026-10-18", 900, my_application_status=None, photos=P("furniture", "cartons", "shop")),
    job(104, "Delivery helper with own bike", "delivery", "Jayanagar, Bengaluru", "4th Block Kirana Mart", "2026-10-15", "2026-10-20", 600, my_application_status="rejected"),
    job(105, "Home deep cleaning after painting", "cleaning", "BTM Layout, Bengaluru", "2nd Stage, Flat 3B", "2026-10-17", "2026-10-18", 800, my_application_status=None),
    job(106, "Festive gift box packing", "packing", "Malleshwaram, Bengaluru", "Gift Studio, 8th Cross", "2026-10-19", "2026-10-24", 550, need=3, my_application_status="pending"),
    job(107, "Cook for family function (40 people)", "cook", "JP Nagar, Bengaluru", "Phase 6", "2026-10-22", "2026-10-22", 1200, my_application_status=None),
    job(108, "Counter helper - sweet shop", "helper", "Jayanagar, Bengaluru", "Shree Mithai, 3rd Block", "2026-10-16", "2026-10-30", 600, my_application_status=None),
    job(109, "Maid for 3-bedroom flat", "cleaning", "Indiranagar, Bengaluru", "HAL 2nd Stage", "2026-10-15", "2026-10-19", 500, my_application_status=None),
]
# GET /applications/mine rows: {status, job}
APPS = [
    ("pending", 101), ("accepted", 102), ("rejected", 104), ("pending", 106),
    ("accepted", job(110, "Warehouse stock arranging", "loading-unloading", "Peenya, Bengaluru", None, "2026-10-12", "2026-10-13", 750, status="done")),
    ("accepted", job(111, "Wedding hall setup helper", "helper", "Rajajinagar, Bengaluru", None, "2026-10-20", "2026-10-21", 850, status="hired", need=1, hired=1)),
]

# Owner-side jobs (owned by ME's alter ego); same demo user acts as owner in owner screens.
MINE = [
    job(201, "Unload tempo truck - 40 cartons", "loading-unloading", "Indiranagar, Bengaluru", "Sri Lakshmi Traders, 100 Feet Road", "2026-10-16", "2026-10-17", 700, need=3, hired=1, owner=ME, photos=P("cartons"), created="2026-10-14T05:10:00+00:00"),
    job(202, "Shop helper for Diwali rush", "helper", "Koramangala, Bengaluru", "Bangalore Sweets, 5th Block", "2026-10-16", "2026-10-25", 650, status="hired", need=2, hired=2, owner=ME, photos=P("shop", "cartons"), created="2026-10-13T11:00:00+00:00"),
    job(203, "Home deep cleaning after painting", "cleaning", "BTM Layout, Bengaluru", "2nd Stage, Flat 3B", "2026-10-18", "2026-10-18", 800, owner=ME, created="2026-10-12T16:45:00+00:00"),
    job(204, "Festive gift box packing", "packing", "Malleshwaram, Bengaluru", "Gift Studio, 8th Cross", "2026-10-19", "2026-10-24", 550, need=3, hired=0, owner=ME, created="2026-10-11T08:20:00+00:00"),
    job(205, "Delivery helper with own bike", "delivery", "Jayanagar, Bengaluru", "4th Block Kirana Mart", "2026-10-08", "2026-10-12", 600, status="done", owner=ME, created="2026-10-06T10:00:00+00:00"),
]
HIRED = {
    201: ["w1"],
    202: ["w2", "w4"],
}
APPLICANTS = {201: ["w3", "w4", "w5"]}
OWNER_CONTACT = {"full_name": "Anitha K", "phone": "+919876501299", "email": None, "is_verified": True, "bio": None, "city": "Koramangala, Bengaluru", "worker_skills": []}

PROFILE = {
    "id": ME, "role": "worker", "full_name": "Ravi Kumar", "phone": "+919876501100", "photo_url": None,
    "city": "Indiranagar, Bengaluru", "lat": LAT, "lng": LNG, "is_verified": True,
    "created_at": "2026-09-02T07:00:00+00:00", "contact_phone": None, "bio": "Reliable and punctual. 3 years of godown and shop work around Indiranagar and Koramangala.",
    "is_deleted": False, "is_admin": False, "email": "ravi.kumar@example.com", "lang": "en",
    "worker_skills": [{"skill": s} for s in ("loading-unloading", "helper", "delivery", "packing")],
}


def all_jobs():
    return {j["id"]: j for j in NEAR + MINE + [a[1] for a in APPS if isinstance(a[1], dict)]}


def resolve(j, host):
    j = dict(j)
    j["photo_urls"] = [f"http://{host}/img/{p[1:]}.jpg" if p.startswith("@") else p for p in j["photo_urls"]]
    return j


def detail(jid, host):
    j = all_jobs().get(jid)
    if not j:
        return None
    out = resolve(j, host)
    out["my_review"] = None
    if j["owner_id"] == ME:
        out["hired_workers"] = [{"worker_id": W[k][0], **{k2: v for k2, v in W[k][1].items()}} for k in HIRED.get(jid, [])]
        out["my_application_status"] = None
    else:
        out["my_application_status"] = j.get("my_application_status")
        if out["my_application_status"] == "accepted":
            out["owner"] = OWNER_CONTACT
    return out


class H(BaseHTTPRequestHandler):
    def log_message(self, *a):
        pass

    def send(self, code, body, ctype="application/json"):
        data = body if isinstance(body, bytes) else json.dumps(body).encode()
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        u = urlparse(self.path)
        q = {k: v[0] for k, v in parse_qs(u.query).items()}
        p = u.path
        host = self.headers.get("Host", "10.0.2.2:8787")
        lim, off = int(q.get("limit", 50)), int(q.get("offset", 0))
        if p == "/__screen":
            return self.send(200, state)
        if p.startswith("/img/"):
            return self.send(200, PHOTOS[p[5:-4]], "image/jpeg")
        if p == "/profile/me":
            return self.send(200, PROFILE)
        if p == "/jobs/nearby":
            return self.send(200, [resolve(j, host) for j in NEAR][off:off + lim])
        if p == "/jobs/mine":
            return self.send(200, [resolve(j, host) for j in MINE])
        if p == "/applications/mine":
            rows = []
            for st, j in APPS:
                jj = j if isinstance(j, dict) else all_jobs()[j]
                if "from" in q and jj["start_date"] < q["from"]:
                    continue
                if "to" in q and jj["start_date"] > q["to"]:
                    continue
                rows.append({"status": st, "job": {k: v for k, v in resolve(jj, host).items() if k != "my_application_status"}})
            return self.send(200, rows[off:off + lim])
        if p == "/billing/me":
            return self.send(200, {"plan": "free", "status": "expired", "unlimited": False, "limit": 3, "trial_ends_at": "2026-10-09T07:00:00+00:00",
                                   "current_period_end": None, "usageThisMonth": {"owner": 2, "worker": 2}, "priceByRole": {"owner": 399, "worker": 199}})
        parts = p.strip("/").split("/")
        if parts[0] == "jobs" and len(parts) == 3 and parts[2] == "applicants":
            jid = int(parts[1])
            rows = [{"id": 900 + i, "job_id": jid, "worker_id": W[k][0], "status": "pending", "created_at": "2026-10-14T06:00:00+00:00", "worker": W[k][1]}
                    for i, k in enumerate(APPLICANTS.get(jid, []))]
            return self.send(200, rows)
        if parts[0] == "jobs" and len(parts) == 2 and parts[1].isdigit():
            d = detail(int(parts[1]), host)
            return self.send(200 if d else 404, d or {"error": "not found"})
        if parts[0] == "profiles" and len(parts) == 3 and parts[2] == "reviews":
            return self.send(200, [])
        self.send(404, {"error": "not found"})

    def do_POST(self):
        u = urlparse(self.path)
        if u.path == "/__screen":
            state["n"] = int(parse_qs(u.query)["n"][0])
            state["rev"] += 1
            return self.send(200, state)
        if u.path == "/__fill":  # body: JSON list of strings -> app sets visible text fields in order
            state["fill"] = json.loads(self.rfile.read(int(self.headers.get("Content-Length", 0))))
            state["frev"] += 1
            return self.send(200, state)
        self.send(200, {"ok": True})

    do_PATCH = do_POST


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8787
    ThreadingHTTPServer(("0.0.0.0", port), H).serve_forever()
