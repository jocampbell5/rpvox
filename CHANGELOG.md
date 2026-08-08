# Changelog

## 4.1 — 2026-08-07

- **Every class now has a pack.** Druid, Rogue, Warlock, Paladin and Shaman
  join Priest, Mage, Warrior and Hunter. 2,056 new hand-written lines across
  136 abilities, each class with its own voice:
  - **Druid** — a Kaldorei only half returned from the Emerald Dream, speaking
    slightly out of step with the present and unsure which war this is.
  - **Rogue** — a guild-trained professional who regards killing as skilled
    trade work. Rates, tools, standards, and no cruelty whatsoever.
  - **Warlock** — a contract lawyer who deals in souls. Everything is terms,
    clauses and arrears, and his demons are difficult staff.
  - **Paladin** — a Blood Knight who takes the Light by force and resents
    needing it. He does not pray and he will not kneel.
  - **Shaman** — an old orc who negotiates with elements that are frequently
    in a mood, and gets better conversation from the wind than from people.
- **Fixed: your character addressed herself when self-targeted.** Healing,
  shielding or buffing yourself leaves you as your own target, and the target
  token was filling in your own name — so a line meant for an enemy came out
  aimed at you. You no longer count as a target: lines that name one become
  ineligible while you are self-targeted, and the untargeted lines in each set
  are used instead. Every healing set has plenty of those, so self-healing
  still speaks; it simply stops saying your name.
- **Combat ability chance raised to 10%.** Every class ability and melee now
  rolls at 10% rather than the old 0.05–5% spread. The single global gap still
  governs everything, so this changes how promptly a character speaks once the
  gap has elapsed, not how often they speak overall.

## 4.0.2 — 2026-08-07

- **Fixed: mashing a key bought extra chance rolls.** Every press of an ability
  rolled separately, including the dead presses players make while waiting on a
  cooldown. Anyone who taps quickly triggered lines far more often than their
  setting implied — at 20%, four rapid presses fired 59% of the time. There is
  now at most one roll per 1.5 seconds, whatever is pressed, so the frequency
  you set is the frequency you get. No roll is lost for an action you actually
  took.

## 4.0.1 — 2026-08-07

- **Fixed: RPVox blocked mouse wheel camera zoom.** The addon watched the mouse
  wheel as one of its input surfaces, which consumed the event before the
  camera zoom bindings could see it. There is no API to propagate a handled
  wheel event, so the wheel is now left alone entirely. Clicks, keys and
  gamepad buttons still serve as flush triggers.

## 4.0 — 2026-08-07

First public release.

### What is in it

- Speaks roleplay lines in `/say` and `/em` for combat, reactions and everyday
  life. Never yells, and there is no setting to make it.
- **Combat** — a line set per ability, matched on spell name so every rank
  works.
- **Reactions** — low health, death, resurrection, killing blow, entering and
  leaving combat, being interrupted, levelling, falling, drowning, and gear
  falling apart.
- **Idle** — eating, drinking, healthstones, mana potions, fishing, mining,
  herbalism, skinning, mounting, accepting and completing quests, discovering
  an area, and crafting across ten professions.
- **Moods** — four for the priest: grim, weary, serious, happy. The same
  character on four different days rather than four different characters.
- **Profiles** — one per character, each with its own class, mood, lines and
  frequency, bound to whoever you log in as.
- **Line editor** — every trigger is editable in the settings window. A trigger
  you have touched is marked as yours and is never overwritten by an update.
- **One global gap** governs all speech, so RPVox never talks over itself. The
  frequency slider is logarithmic, because the useful range is the bottom of it.

### Included voices

- **Priest** — a Forsaken shadow priest, in four moods.
- **Mage** — an arcanist, single voice.
- **Hunter** — a Sin'dorei noblewoman, single voice.
- **Warrior** — single voice.
- Druid, Rogue, Warlock, Paladin and Shaman fall back to the generic set.

### Recent work leading up to this release

- **Hunter pack added.** 666 lines: 27 abilities including the full pet suite,
  traps, Feign Death and Arcane Torrent; all seven core reactions at 40 lines
  each; the four newer reactions at 20; seven idle sets at 12.
- **Targeting pass.** Combat lines now name what you are fighting. 5,355 of
  5,528 combat lines carry the target token — 97%, or every single one
  excluding emotes, which read as stage directions and are deliberately left
  untargeted. A line that names a target will not fire when you have none, so
  each set keeps untargeted fallbacks.
- Non-combat triggers are deliberately **not** targeted. There is no enemy to
  name while you are fishing.

### Known gaps

- Mage and warrior have no mood packs yet; both speak in a single voice.
- Druid, rogue, warlock, paladin and shaman have no class pack.
- The priest's newer reactions and all idle triggers have base lines only, with
  no mood variation.
