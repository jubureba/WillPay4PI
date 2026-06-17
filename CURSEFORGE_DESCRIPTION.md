# Will Pay 4 PI

**Automatic Power Infusion requesting for the shameless DPS player.**

Stop begging in chat. Let the addon do it for you — with dignity. Well, some dignity.

---

## What Does It Do?

1. You pop your burst cooldown (Metamorphosis, Combustion, Recklessness, etc.)
2. The addon instantly whispers your priest: *"PI please - DEVOUR bursting"*
3. You get PI. You do big deeps. Everyone is happy.

That's it. That's the addon.

---

## Key Features

- **Auto-detects your burst CDs** — Works out of the box for 11 specs
- **Smart priest targeting** — Tracks all priests in group, auto-failover if one dies
- **Customizable messages** — Use variables like {spec}, {priest}, {time}
- **Multiple channels** — Whisper, Party, Raid, Say, Yell
- **Cooldown protection** — Won't spam your priest (configurable 15s-300s)
- **PI received tracking** — Knows when you actually get PI
- **Full statistics** — Success rate, response times, history
- **Modern dark UI** — Purple accent, card-based, sidebar navigation
- **WeakAuras events** — Hook into PI_BURST, PI_RECEIVED for custom triggers
- **Midnight 12.x native** — No CLEU, no taint, fully compatible

---

## Quick Start

1. Install and `/reload`
2. Join a group with a Priest
3. Type `/pi` to open
4. Your spec's burst spells are pre-loaded
5. Priest is auto-detected and selected
6. Burst away — the addon handles the rest

---

## Slash Commands

- `/pi` — Open/close the main window
- `/wp4pi` — Same thing, alternate command
- `/pi test` — Simulate a burst (no message sent)
- `/pi snoop` — Debug: watch spell events for 10 seconds
- `/pi status` — Print current state to chat

---

## Supported Specs (Pre-configured)

| Class | Specs |
|-------|-------|
| Demon Hunter | Devour (new!), Havoc, Vengeance |
| Warrior | Fury, Arms |
| Mage | Fire, Frost |
| Hunter | Beast Mastery, Marksmanship |
| Rogue | Assassination, Outlaw, Subtlety |

> Any spec can be configured by adding custom spell IDs.

---

## Screenshots

### Dashboard — Your PI command center
![Dashboard](https://i.imgur.com/PLACEHOLDER_DASHBOARD.png)

### Priests — Track and prioritize your PI suppliers
![Priests](https://i.imgur.com/PLACEHOLDER_PRIESTS.png)

### Burst — Configure which spells trigger requests
![Burst](https://i.imgur.com/PLACEHOLDER_BURST.png)

### Messages — Craft the perfect PI plea
![Messages](https://i.imgur.com/PLACEHOLDER_MESSAGES.png)

### Statistics — Know your PI success rate
![Statistics](https://i.imgur.com/PLACEHOLDER_STATS.png)

---

## Message Examples

```
PI please - {spec} bursting
→ "PI please - DEVOUR bursting"

will pay 4 PI, am desperate
→ "will pay 4 PI, am desperate"

Burst active, PI me ({time})
→ "Burst active, PI me (21:35)"
```

---

## Technical Info

- **Interface**: 120005 (Midnight 12.0.5)
- **SavedVariables**: WillPay4PIDB
- **Memory**: ~200KB
- **Dependencies**: None (libs embedded)
- **Taint-free**: Uses UNIT_SPELLCAST_SUCCEEDED + C_UnitAuras (safe in Midnight)

---

## FAQ

**It's not detecting my burst!**
→ `/pi snoop`, cast your spell, check if the ID shows. Add it manually in Burst tab if needed.

**No priest showing up?**
→ You need to be in a group/raid with at least one Priest class player.

**Does it work in rated PvP?**
→ Detection works, but Blizzard blocks addon chat messages in rated content.

---

## Feedback & Bugs

Found a bug? Have a suggestion? Open an issue or leave a comment.

If a priest gives you PI because of this addon, you owe them a cookie. 🍪
