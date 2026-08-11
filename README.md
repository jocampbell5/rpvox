# RPVox

Gives your character a voice.

RPVox speaks roleplay lines in `/say` and `/em` as you play — when you cast, when
you drop below a quarter health, when you die, when you come back, when you eat,
fish, mine, mount up or discover somewhere new. You set how often it happens and
it does the rest.

Built for **Burning Crusade Classic (2.5.x)**.

## What it does

- **Combat.** Seven moments rather than one entry per spell: a spell hits, crits
  or misses, a swing, a heal, a buff, and something held down. One set of lines
  covers your whole spellbook, including spells you have not learned yet.
- **Reactions.** Low health, death, resurrection, killing blow, entering and
  leaving combat, being interrupted, levelling, falling, drowning, noticing your
  gear is in pieces, eating, drinking, mounting up, quests and discovery.
- **Everyday life.** Fishing, mining, herbalism, skinning, potions, and crafting
  in ten professions.
- **Speech bubbles.** Your lines float above your character on the screens of
  other people running RPVox. See [Speech bubbles](#speech-bubbles) — this one
  has a requirement.
- **Moods.** Switch mood and the same character speaks differently. The priest
  ships with four: happy, serious, weary, grim.
- **Profiles.** One per character, each with its own class, mood, lines and
  frequency. Edit any line in the settings window; anything you touch is yours
  and never gets overwritten.

Lines are targeted where it makes sense — `%t` becomes whatever you are fighting,
and a targeted line simply will not fire when you have no target.

## Speech bubbles

A line raises a bubble above your character on the screen of every nearby RPVox
user, following you as you move. Theirs appear above them, the same way.

**This needs friendly nameplates turned on.** There is no way for an addon on
this client to work out where a character sits on screen — the game will not
tell it — so a nameplate is the only handle it has on a character's position.

Turn it on with:

```
/rpvox bubble world
```

That switches on friendly player nameplates, switches them on out of combat as
well, and **hides the health bars and names** they would normally draw, so you
see the bubble and nothing else. Turning it off restores every setting exactly
as it was. It will not run mid-fight, because the client locks those settings
during combat.

Never touched: enemy nameplates, friendly NPC nameplates, pets and minions.
Your enemy health bars stay exactly as you have them.

Without world mode bubbles still work — they stack in the corner, labelled with
the speaker's name. With it on, a line from somebody you cannot see is not shown
at all rather than dropping to the corner; it is still in your chat frame.

**Your own bubble stays on screen.** The client draws no nameplate above your
own head, so there is nowhere in the world to put it. `/rpvox bubble mine` hides
it — your lines still appear above your character for everyone else.

If bubbles are not appearing, `/rpvox bubble test` with a player targeted walks
the whole chain and names the step that failed.

## Hits, crits and misses

A combat line can be written for how the blow actually landed:

```
<crit> Ash. Nothing left of %t but ash.
<miss> ... and it goes wide. Again.
```

Tag one line in a spell that way and that spell stops speaking the instant the
cast goes off, and waits for the combat log instead — so it knows the difference
between a crit, a resist and a Fireball that missed a second after it left your
hand. Where you have lines for what happened, only those are used; otherwise the
untagged ones fire as always. A spell with no tagged lines is untouched.

Available: `<hit> <crit> <miss> <dodge> <parry> <block> <resist> <immune>
<absorb> <reflect>`. Anything without its own lines falls back to `<miss>`, so
`<crit>` and `<miss>` alone cover most of it. Melee swings, wand shots and heal
crits work the same way. Moods combine with outcomes in either order:
`[grim] <miss> Even the fire has stopped listening.`

## Where the lines go

RPVox speaks **only to nearby players who also run RPVox**. The line travels as
an addon message at say range, so the distance limit is the same one `/say`
uses — but nothing ever lands in public chat. Lines arrive tagged `[RP]` and
coloured cyan, so nobody mistakes them for something you typed.

The trade is that only RPVox users see anything. That is the whole design;
there is no public-chat mode.

## Group content

Inside **dungeons, raids, battlegrounds and arenas** — and in any raid group —
RPVox switches off entirely: no lines, no bubbles, until you step back out.
This is not a setting. People in there are reading chat for pulls and marks,
and nobody should have to remember to turn it down on the way in.

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

Alongside those, alternative voices for the same classes:

- **Priest-Dirge** — speaks only in verse, and only ever grimly. Every line a
  self-contained rhyming couplet. Written for the moment triggers.
- **Priest-Rhyming** — a priest who never once breaks metre. Holy spells get
  measured hymnal couplets, Shadow gets manic doggerel.
- **Mage-Lyrics**, **Priest-Lyrics** — every line bends a well-known rock, hip
  hop or R&B hook into what you just did.
- **Mage-Animated** — the same, with the bubble markup used properly.
- **Hunter-ValleyGirl** — Feign Death is "I'm literally dead. Like. Literally
  dead."
- **Warrior-Barbarian** — written the way Arnold would say it.

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
/rpvox                  open the settings window
/rpvox on | off         silence this character, or wake it
/rpvox profile <name>   switch profile
/rpvox mood <name>      set mood, or "any"
/rpvox rebuild          reset this profile's stock lines

/rpvox bubble           pin the bubble so you can drag it
/rpvox bubble world     float lines above the character models
/rpvox bubble mine      show or hide your own bubble
/rpvox bubble others    show or hide other players' bubbles
/rpvox bubble test      test a bubble on your target, step by step
/rpvox bubble demo      step through the text effects

/rpvox why              what stopped each trigger speaking
/rpvox trace            print every decision, send nothing
/rpvox status           what is loaded and armed
/rpvox debug            log why lines do or do not fire
```

## A note on frequency

Two settings, and they do different things.

**Speaks on N% of the moments** is one number for the whole character, 1 to 100.
Rare moments count for more than common ones automatically — a swing happens
twenty-five times a minute and a level-up once an evening, so they were never
going to want the same percentage, and a crit is three times likelier to be
spoken than an ordinary hit.

**One line every...** is the quiet gap: after anything is said, everything stays
silent for that long.

Start low on both. A character who comments on every single fireball stops being
a character and becomes noise. Underneath everything there is a hard ceiling you
cannot raise — never two lines within 1.5 seconds, never more than four in ten —
because sustained chatter gets you disconnected for flooding.

## Licence

MIT. See [LICENSE](LICENSE).
