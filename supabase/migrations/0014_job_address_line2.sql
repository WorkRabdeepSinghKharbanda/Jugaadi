-- Free-text second address line (shop name, landmark, floor/unit) alongside the picked
-- address_text — the map pick gives a street address, not "Shop 4, Ganesh Market".
alter table jobs add column address_line2 text;
