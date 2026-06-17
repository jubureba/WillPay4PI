# Will Pay 4 PI

> *Detects your burst windows and automatically requests Power Infusion from your priest. Will trade gold, dignity, or both.*

**Will Pay 4 PI** is a lightweight World of Warcraft addon for **Midnight (12.x)** that monitors your burst cooldowns and sends a PI request to your assigned priest — automatically or on demand.

No more typing in chat mid-rotation. No more missing PI windows. Just pure, shameless PI begging with style.

---

## Features

- **Automatic Burst Detection** — Detects when you pop major cooldowns (Metamorphosis, Combustion, Recklessness, etc.)
- **Smart Priest Tracking** — Scans your group/raid for Priests, tracks their online/alive/range status
- **Auto PI Request** — Sends a customizable message to your priest when burst is detected
- **Priority System** — Rank multiple priests; auto-failover if your selected priest dies or disconnects
- **PI Received Detection** — Knows when you actually get PI (via secure aura API)
- **Full Statistics** — Tracks bursts, requests sent, PI received, success rate, response times
- **Modern Dark UI** — Clean sidebar navigation, card-based dashboard, dark purple theme
- **WeakAuras Integration** — Fires custom events (`PI_BURST`, `PI_RECEIVED`, `PI_REQUESTED`, `PI_FAILED`) for WA triggers
- **Multi-spec Profiles** — Auto-loads correct burst spells when you switch specs
- **Zero CLEU dependency** — Uses `UNIT_SPELLCAST_SUCCEEDED` + `C_UnitAuras` (Midnight-safe, no taint)

---

## Installation

1. Download and extract to your `Interface/AddOns/` folder
2. Folder name should be `PIAssistant` (the display name is "Will Pay 4 PI")
3. `/reload` in-game
4. Type `/pi` or `/wp4pi` to open

---

## Slash Commands

| Command | Action |
|---------|--------|
| `/pi` | Toggle main window |
| `/wp4pi` | Toggle main window (alternate) |
| `/pi test` | Simulate a burst detection |
| `/pi snoop` | Debug mode: prints spell events for 10 seconds |
| `/pi status` | Print addon diagnostics to chat |
| `/pi debug` | Toggle debug log window |
| `/pi options` | Open AceConfig options |
| `/pi reset` | Reset window position/size |

---

## Screenshots

### Dashboard
![Dashboard](https://i.imgur.com/PLACEHOLDER_DASHBOARD.png)

The main dashboard shows your current class/spec, selected priest, available priests count, last burst detected, last PI received, and session request count — all in real-time info cards.

### Priests Tab
![Priests](https://i.imgur.com/PLACEHOLDER_PRIESTS.png)

View all priests in your group with their spec, online/alive status. Set priority order and select your preferred PI target. Auto-failover to next available priest if your target goes down.

### Burst Spells Tab
![Burst](https://i.imgur.com/PLACEHOLDER_BURST.png)

Configure which spell IDs trigger a PI request. Enable/disable individual spells, see their event types and weight. Load defaults for your spec or add custom spell IDs manually.

### Messages Tab
![Messages](https://i.imgur.com/PLACEHOLDER_MESSAGES.png)

Customize your PI request message with variables like `{spec}`, `{priest}`, `{time}`. Choose delivery channel (Whisper, Party, Raid, etc.), set cooldown between requests, and preview your message in real-time.

### Statistics Tab
![Statistics](https://i.imgur.com/PLACEHOLDER_STATS.png)

Track your PI success rate over time. See total bursts detected, requests sent, PI received, failures, top priest, average response time, and full request history.

---

## How It Works

```
You pop Metamorphosis
       |
       v
UNIT_SPELLCAST_SUCCEEDED fires for "player"
       |
       v
BurstDetector matches spellID in your configured list
       |
       v
PI request sent to your selected priest via chosen channel
       |
       v
Priest gives you PI (hopefully)
       |
       v
UNIT_AURA detects Power Infusion buff on you
       |
       v
Statistics updated, alert shown
```

---

## Supported Classes (Default Profiles)

| Class | Spec | Primary Burst Spell |
|-------|------|-------------------|
| Demon Hunter | Devour (Midnight) | Chaos Metamorphosis |
| Demon Hunter | Havoc | Metamorphosis + Essence Break |
| Warrior | Fury | Recklessness |
| Warrior | Arms | Bladestorm |
| Mage | Fire | Combustion |
| Mage | Frost | Icy Veins |
| Hunter | Beast Mastery | Aspect of the Wild |
| Hunter | Marksmanship | Trueshot |
| Rogue | Assassination | Deathmark |
| Rogue | Outlaw | Adrenaline Rush |
| Rogue | Subtlety | Shadow Blades |

> Any class/spec can be configured manually by adding spell IDs in the Burst tab.

---

## Message Variables

Use these in your message template:

| Variable | Output |
|----------|--------|
| `{player}` | Your character name |
| `{spec}` | Your current spec |
| `{class}` | Your class |
| `{priest}` | Selected priest name |
| `{instance}` | Current instance/zone |
| `{group}` | Group type (Solo/Party/Raid) |
| `{time}` | Current time (HH:MM) |

### Example Messages

```
PI please - {spec} bursting
```
→ "PI please - DEVOUR bursting"

```
Need PI now - {priest}
```
→ "Need PI now - Holypriest"

```
will pay 4 PI, am desperate
```
→ "will pay 4 PI, am desperate"

---

## WeakAuras Integration

The addon fires custom events you can use in WeakAuras:

| Event | Payload | When |
|-------|---------|------|
| `PI_BURST` | spellID, spellName | Burst cooldown detected |
| `PI_RECEIVED` | sourceName | Power Infusion applied to you |
| `PI_REQUESTED` | priestName, message | PI request message sent |
| `PI_FAILED` | reason | Request blocked (cooldown, no priest, etc.) |
| `PI_TEST` | spellID, spellName | Test burst triggered |

**WeakAura Trigger Setup:**
- Type: Custom → Event
- Event(s): `PI_BURST` (or any from above)
- Custom Trigger:
```lua
function(event, ...)
    if event == "PI_BURST" then
        return true
    end
end
```

---

## Configuration

### First Time Setup

1. Join a group/raid with at least one Priest
2. Open `/pi` → Priests tab
3. The addon auto-detects priests; select your preferred one
4. Go to Burst tab → verify your spec's spells are loaded
5. Go to Messages tab → customize your template and channel
6. Done! The addon will now auto-request PI when you burst

### Adding Custom Spells

1. Open `/pi` → Burst tab
2. Enter the spell ID in the input box (find IDs on Wowhead)
3. Click "Add"
4. The spell will trigger on `SPELL_CAST_SUCCESS` by default

### Priest Priority

When multiple priests are available:
1. The addon uses your priority order (set with Up/Dn buttons)
2. If your selected priest dies → auto-selects next available
3. If priest disconnects → auto-selects next available
4. You can manually override at any time

---

## Technical Notes

- **No COMBAT_LOG_EVENT_UNFILTERED** — Fully Midnight-compatible. Uses `UNIT_SPELLCAST_SUCCEEDED` for cast detection and `C_UnitAuras.GetPlayerAuraBySpellID` for PI tracking (avoids "secret value" taint).
- **No taint** — All aura checks use safe APIs that don't trigger ADDON_ACTION_FORBIDDEN.
- **Lightweight** — No OnUpdate polling. Pure event-driven architecture.
- **AceDB profiles** — Full profile system with per-character, per-spec configs.
- **SavedVariables**: `WillPay4PIDB`

---

## Compatibility

- **WoW Version**: Midnight 12.0+ (Interface 120005)
- **Dependencies**: None (all libraries embedded)
- **Conflicts**: None known
- **Memory**: ~200KB loaded

---

## FAQ

**Q: Why isn't my burst being detected?**
A: Run `/pi snoop` and cast your ability. Check if the spell ID appears. If not, add it manually in the Burst tab.

**Q: Can I use this without a priest in my group?**
A: The detection works always, but messages won't send without a target priest. You can still use the WeakAura events for personal alerts.

**Q: Does this work in arenas/rated PvP?**
A: Addon communication (SendChatMessage) is restricted in rated content. The detection and alerts still work, but auto-whisper may be blocked by Blizzard.

**Q: My old settings from PI Assistant are gone!**
A: The SavedVariables name changed from `PIAssistantDB` to `WillPay4PIDB`. Your old settings won't carry over — reconfigure in the new UI (it's fast).

**Q: The addon shows "incompatible" in the addon list**
A: Make sure you have the latest version with `## Interface: 120005` in the .toc file.

---

## Changelog

### v2.0.0 — "Will Pay 4 PI"
- Complete rename from "PI Assistant"
- Brand new modern dark UI with sidebar navigation
- Removed COMBAT_LOG_EVENT_UNFILTERED dependency (Midnight fix)
- Burst detection via UNIT_SPELLCAST_SUCCEEDED
- PI detection via C_UnitAuras (no taint)
- Added Demon Hunter Devour spec (Midnight new spec, ID 1480)
- Card-based dashboard
- Statistics tracking with history
- WeakAuras event bridge

### v1.0.0 — "PI Assistant"
- Initial release
- CLEU-based detection (broken in Midnight)

---

## License

MIT — Do whatever you want. If a priest gives you PI because of this addon, you owe them a cookie.
# WillPay4PI
