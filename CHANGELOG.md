# Changelog

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
