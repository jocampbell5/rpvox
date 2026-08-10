# Changelog

## 4.6 — 2026-08-10

### Speech bubbles that other people can see

Lines used to be yours alone: they arrived in a nearby player's chat frame and
nothing more. Now a line raises a **speech bubble for whoever said it**, on
everybody's screen, floating above their character and following them as they
move.

**This needs friendly nameplates.** There is no way for an addon to work out
where a character is on screen — the client will not tell it — so the only
handle on a character's position is their nameplate. Turn it on with:

    /rpvox bubble world

That switches friendly player nameplates on for you, switches them on out of
combat as well, and **hides the health bars and names** they would otherwise
draw, so all you see is the bubble. Turning it off puts every setting back
exactly as it was, and refuses to run mid-fight, because the client locks those
settings during combat.

Enemy nameplates and friendly NPC nameplates are never touched. Your enemy
health bars stay exactly as you have them.

Without world mode, bubbles still work — they stack in the corner of the screen,
labelled with the speaker's name. With it on, a line from someone you cannot see
is not shown at all rather than falling back to the corner; it is still in your
chat frame.

Your own bubble stays on screen: this client draws no nameplate above your own
head, so there is nowhere in the world to put it. `/rpvox bubble mine` hides it
if you would rather see nothing — your lines still appear above your character
on everyone else's screen.

### Combat is moments, not one trigger per spell

A profile used to carry over a hundred triggers, and three quarters of them
meant the same thing — "I pressed a button", written out once per spell. They
are replaced by seven **moments**: a spell hits, crits or misses, a swing, a
heal, a buff, and something being held down.

One set of lines now covers your whole spellbook, including spells you have not
learned yet, and it keeps covering them when you learn more. A fresh profile is
about twenty entries worth writing rather than a hundred and nine.

A spell can still have its own lines when it earns them: drag it in from your
spellbook under **Spells Override** and it takes priority over the general set.

Lines can also be written for how a blow landed, using `<crit>`, `<miss>`,
`<resist>` and the rest as a tag at the front of the line. Melee, heals and
crowd control use these; the three spell moments have a trigger each instead.

### One chance number for the whole character

Per-trigger chance is gone, replaced by a single **Speaks on N% of the moments**
slider running from 1% to 100%.

The old number could not keep its promise. Dozens of combat triggers competed
for one quiet gap, so a spell set to 100% still missed most of its casts — and
the scale ran down to 0.01%, which is one line in ten thousand swings and
indistinguishable from switched off.

Rare moments now count for more than common ones automatically, because a swing
happens twenty-five times a minute and a level-up once an evening and they were
never going to want the same percentage. A crit is three times likelier to be
spoken than an ordinary hit, for the same reason.

Existing profiles carry over on the average of their old combat settings, so a
talkative character stays talkative.

### A new voice: Priest-Dirge

A priest who speaks only in verse, and only ever grimly. Every line is a
self-contained rhyming couplet — lines fire independently and in any order, so a
rhyme can never depend on the next one arriving.

> The prayer is finished. The mace is not. A blunt amen for everything you brought.

Written for the moment triggers, so one set of lines covers the whole spellbook.

**Mage-Animated** has been rewritten for the new moments in its own song-lyric
voice, with crit, miss, resist and immune lines throughout.

### Tidier line lists

Every set used to be given target-free variants by copying a line and deleting
the name off the end, so half of most lists read as the same thing twice. Those
copies are removed — except that two are always kept per set, because a set with
none goes silent whenever you have nothing targeted, which is why they existed.
Your saved profiles are swept once and told how many lines went.

New lines written for the stock voices can now reach a profile you already have,
rather than only new ones.

### The bubble is silent

The typewriter tick and the coloured accent sounds are gone, along with
`/rpvox bubble sound`. They were assembled from whatever sound kits happened to
exist on this client rather than anything that suited the character speaking —
every race, class and spell school made the same noise. A tick that says nothing
about who is talking is worse than no tick.

### Working out why a line did or did not fire

- `/rpvox why` — counts what happened to every trigger and names the reason: the
  quiet gap, the chance roll, the flood ceiling, no eligible line.
- `/rpvox trace` — prints the line every swing and cast *would* have said, and
  which set it came from, without sending anything and without waiting on the
  chance roll.
- `/rpvox bubble test` — with a player targeted, walks the whole bubble chain and
  names the link that broke.
- `/rpvox bubble client` and `/rpvox bubble cvars` — what your client is and
  which nameplate settings it actually has.

### Also

- The addon no longer touches keyboard, gamepad or mouse input at all. It used
  to hold every line until the next keypress, because sending to public chat
  needs one; lines have travelled as addon messages since 4.4 and cannot be
  refused, so the whole input gate was watching your keyboard for nothing.
- The settings window is grouped into **Spells Override · Moments · Reactions ·
  Idle**, and only the first can add or remove entries.
- Fixed: the drag hint sat underneath the category tabs and was unreadable.
- Fixed: the last row of the trigger list was drawn across the bottom border.
- `/rpvox autotest` is gone with the problem it existed to diagnose.

## 4.5 — 2026-08-09

- **Five new voices, as alternative class packs.** Pick them from the class
  list in the settings window, the same place you pick Mage or Priest:
  - **Mage-Lyrics** and **Priest-Lyrics** — every line bends a well-known
    rock, hip hop or R&B hook into the spell being cast. Frostbolt opens on
    "Ice, ice, %t", Greater Heal on "And I will always love you, %t, but you
    have to stop standing in things."
  - **Priest-Rhyming** — a priest who speaks only in verse, and never once
    breaks. Holy spells get measured hymnal couplets, Shadow spells get
    manic doggerel, so he sounds like a different man the moment he specs.
  - **Hunter-ValleyGirl** — Feign Death is "I'm literally dead. Like.
    Literally dead." Revive Pet is a genuine meltdown.
  - **Warrior-Barbarian** — a barbarian who mostly wants to hit things,
    written the way Arnold would say it. "It's naht a tumah. It is chust
    anger."
- These sit **alongside** the existing voices rather than replacing them. The
  stock Mage, Priest, Hunter and Warrior packs are untouched, so switching is
  a dropdown away and switching back costs nothing.
- Each new pack covers its class's full spellbook — 54 to 75 abilities — plus
  every reaction and idle trigger, at around a dozen lines each.
- **Fixed: an alternate pack claimed its spells would never fire.** A profile
  built on one of the new packs warned at login that it was on the wrong
  class, and said its spells were dead. Both were wrong — the check compared
  the pack's key against your class, and `PRIEST_RHYMING` is not the string
  `PRIEST`. Lines fired perfectly well throughout; the warning was the only
  broken part. The same comparison also stopped a new pack ever being
  auto-selected for the right character. A pack now states which class it
  serves, and both checks ask it.
- **RP lines are parchment, not cyan.** Cyan was distinct but cold and the eye
  slid past it. Cream turned out no better: on a dark chat background it is
  brightness, not hue, that separates one colour from another, so a warm
  near-white just read as `/say`. The new colour drops brightness as well as
  blue, and stays clear of yellow.
- **The addon stopped advertising a command it is not called.** Ten places —
  the whole `/rpvox help` listing among them — told you to type `/rpcry`.
  That still works and always will, but it is the old name, and nothing
  should be teaching it to new players.

## 4.4.1 - 2026-08-09

- **Fixed: every popup button did nothing.** New profile, Copy, Rename, Add
  spell and New mood all read the dialog's edit box as `self.editBox`. The
  anniversary client rebuilt StaticPopup and renamed it `self.EditBox`, so
  every one of those handlers threw an error the moment it ran -- and because
  WoW hides Lua errors by default, the buttons simply looked dead. Resolved
  whichever way the client spells it, and the enter-to-accept handlers no
  longer assume the edit box's parent is the dialog.
- Added `/rpvox copy <name>` as a route that avoids the popup entirely.

## 4.4 — 2026-08-07

- **Silent in raids, nearly silent in dungeons.** In a raid group, or inside a
  raid, RPVox says nothing at all until you leave. In a five-man the chance is
  capped at 1% however high you have set it. Neither is a setting: group
  content is not the place for it, and nobody should have to remember to turn
  it down on the way in.
- **No more output choice.** Every line goes to nearby RPVox users, always.
  Having two answers to "who can hear me" was worse than having one, so the
  checkbox and `/rpvox output` are gone.
- **Make your own moods.** A mood is just a tag in front of a line, and any
  name works. Pick "New mood..." at the bottom of the mood list or run
  `/rpvox mood add brooding`, then tag lines with `[brooding]`. Previously a
  mood could not be selected until something was already tagged with it,
  which made your own impossible to start.
- **Instructions button** in the settings window: what the addon does, who can
  hear it, how the two frequency controls differ, how `%t` and moods work, and
  every command.
- **Received lines are cyan, not purple.** Purple sat too close to whispers.
  Nothing else in the default chat uses cyan.

## 4.3 — 2026-08-07

- **Emotes are now stripped from saved profiles too.** Removing them from the
  packs in 4.2.1 was not enough: a profile seeded before that still had
  hundreds sitting in saved variables, and any list you had edited yourself was
  never reseeded at all. They are removed on load now, edited or not.
- **Stale triggers are cleared out.** A profile kept every trigger it had ever
  been seeded with — spells from older builds, triggers that no longer belong
  to your class — each one still full of lines nothing would ever refresh.
  Anything the addon no longer defines for your class is dropped. Triggers you
  created yourself are always kept.
- **New: `/rpvox rebuild`.** Throws away every stock line in the current
  profile and seeds it again from scratch, then reports the before and after
  counts. The only way to be certain a profile holds exactly what the addon
  defines today.
- **Received lines are now coloured.** White text reading "Name says: ..." was
  indistinguishable from real `/say`. The whole line is purple and tagged
  `[RP]`, so it is obvious at a glance that it came from RPVox.

## 4.2.1 — 2026-08-07

- **Received lines now carry an `[RP]` tag** so they are never mistaken for
  something a player actually typed in `/say`.
- **All emote lines removed** — 1,144 of them across every pack. Faking emote
  formatting over a message channel read badly; emotes need their own
  mechanism, which is not built yet. A `/em` line you write yourself in the
  line editor still works.
- Added `/rpvox nettest` for diagnosing whether lines are reaching other
  players.

## 4.2 — 2026-08-07

- **Lines no longer go into public chat.** RPVox now sends each line to the
  players around you who are also running RPVox, using an addon message at
  say range. The server limits the distance exactly as it does for `/say`, so
  only people genuinely nearby receive it — but nothing appears in public chat,
  so a talkative character no longer fills the screen for everybody else.
  Speech and actions are rendered locally in the usual colours.
  The trade is that only RPVox users see anything. Untick the box in `/rpvox`,
  or run `/rpvox output say`, to go back to real `/say` and `/em` that
  everybody nearby can read.
- **Every class now has its own melee lines.** Melee was falling back to the
  generic set for all nine classes, which meant a paladin swinging a hammer
  spoke in the voice of a Forsaken shadow priest. Nine new sets.
- **Priest: 32 missing spells added.** The pack covered ten abilities and the
  priest has far more. Added the full healing ladder including Greater Heal,
  the blessings, Inner Fire, the dispels and cures, Shackle Undead, Mind
  Control, Holy Fire, Holy Nova, Shadow Word: Death, the vampiric line,
  Shadowform, Silence, Shadowfiend, and the Forsaken racials.
- **Content pass.** Removed lines that read as sexual coercion when seen
  without the context of which ability fired — chiefly two Mind Flay sets that
  worked line by line but not read together. Same menace, moved firmly into
  the mental and magical register.
- Fixed lines that made no sense out of context, two emotes that rendered
  ungrammatically, and all remaining raid jargon.

## 4.1.1 — 2026-08-07

- **Fixed: updating RPVox reset your settings.** Any release that re-applied
  stock chances overwrote every trigger's chance with the built-in value, so a
  player who had tuned their sliders lost the lot on update. A chance you set
  yourself is now marked as yours and is never overwritten again — the same way
  an edited line list already was. The old migration that capped hand-made
  triggers at 0.5% no longer touches them either.
- **The quiet gap now defaults to 5 seconds** instead of 3 minutes. Existing
  profiles keep whatever you have set; this only changes what a new profile
  starts with.

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
- **Line clean-up pass.** Fixed lines that read as nonsense to anyone who only
  sees the chat text and not the ability that fired — `"Hands will do."` on a
  melee swing now reads `"I do not need a weapon for you."` Two emotes began
  with an article, so they rendered as "Name the body settles into the dirt";
  both now begin with a verb. Removed all game-mechanics vocabulary, most of it
  a Fade set written entirely in raid jargon ("Dropping threat", "That should
  hold the pull"), now rewritten in character.
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
