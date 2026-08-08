# RPVox

Gives your character a voice.

RPVox speaks roleplay lines in `/say` and `/em` as you play — when you cast, when
you drop below a quarter health, when you die, when you come back, when you eat,
fish, mine, mount up or discover somewhere new. You set how often it happens and
it does the rest.

Built for **Burning Crusade Classic (2.5.x)**.

## What it does

- **Combat lines.** Every ability in your class pack gets its own set. Cast
  Aimed Shot and she may say something about it.
- **Reactions.** Low health, death, resurrection, killing blow, entering and
  leaving combat, being interrupted, levelling, falling, drowning, and noticing
  your gear is in pieces.
- **Everyday life.** Eating, drinking, fishing, mining, herbalism, skinning,
  mounting, accepting quests, discovering a new area, and crafting in ten
  professions.
- **Moods.** Switch mood and the same character speaks differently. The priest
  ships with four: happy, serious, weary, grim.
- **Profiles.** One per character, each with its own class, mood, lines and
  frequency. Edit any line in the settings window; anything you touch is yours
  and never gets overwritten.

Lines are targeted where it makes sense — `%t` becomes whatever you are fighting,
and a targeted line simply will not fire when you have no target.

It never yells. `/say` and `/em` only.

## Included voices

Every class ships with its own written character, several thousand lines deep:

- **Priest** — a Forsaken shadow priest. Dry, cold, unimpressed, annoyed about
  having died. Four moods.
- **Mage** — an arcanist. Precise, superior, treats combat as applied theory.
- **Hunter** — a Sin'dorei noblewoman who treats a battlefield as a badly
  organised court. Offended by dust, blood and bad manners. Soft only with her
  pet.
- **Druid** — a Kaldorei only half returned from the Emerald Dream, speaking
  slightly out of step with the present and unsure which war this is.
- **Rogue** — a guild-trained professional who regards killing as skilled trade
  work. Rates, tools, standards, and no cruelty at all.
- **Warlock** — a contract lawyer who deals in souls. Terms, clauses and
  arrears, and demons who are simply difficult staff.
- **Paladin** — a Blood Knight who takes the Light by force and resents needing
  it. He does not pray and he will not kneel.
- **Shaman** — an old orc who negotiates with elements that are frequently in a
  mood, and gets better conversation from the wind than from people.
- **Warrior** — included in a single voice.

If you would rather have your own character than one of mine, clear a trigger in
the settings window and write your own — the stock lines are a starting point,
not the point.

## Install

Drop the `RPVox` folder into your client's AddOns directory. On the current
Burning Crusade anniversary client that is:

```
World of Warcraft\_anniversary_\Interface\AddOns\
```

Note it is `_anniversary_`, not `_classic_` — dropping it in the wrong branch is
the usual reason an addon does not appear in the character-select list.

The folder must be named exactly `RPVox`.

## Commands

```
/rpvox                  open settings   (/vox also works)
/rpvox on | off         kill switch for the active profile
/rpvox profile <name>   switch profile, binds it to this character
/rpvox mood <name>      set mood, or "any"
/rpvox status           profile, class, mood, armed triggers, line counts
/rpvox testfire         send one line immediately
```

## A note on frequency

The default is deliberately low. A character who comments on every single
fireball stops being a character and starts being a nuisance in other people's
chat logs. The slider runs from 0.01% to 100%, and the useful range is the
bottom of it. One global gap (three minutes by default) governs everything, so
RPVox will not talk over itself.

## Licence

MIT. See [LICENSE](LICENSE).
