---
name: o-meu-salmo-design
description: Use this skill to generate well-branded interfaces and assets for "O meu Salmo" — a Portuguese-language (pt-BR) app of Psalms curated by emotion. Contains the essential design guidelines, colors, type, fonts, brand assets and a UI kit. Use for production code or throwaway prototypes/mocks.
user-invocable: true
---

# O meu Salmo — Design Skill

Read `README.md` first — it holds the full brand context, voice & tone, visual foundations, logo/icon rules, iconography and accessibility notes. Then explore the other files.

## Quick start
- **Tokens:** import `colors_and_type.css`. Use `var(--cobalt-500)`, `var(--scripture)`, `var(--night-*)`, `var(--day-*)`, the emotion vars, and the `.ds-*` helper classes.
- **Default mode is NIGHT.** For day mode set `data-theme="day"` on the container or `<html>`.
- **UI kit:** `ui_kits/app/` has the real screens (emotions → collection → reading) and reusable JSX components (StatusBar, EmotionChip, PsalmCard, VerseLine, AudioPlayer, Logotype). Copy/adapt these.
- **Fonts:** Playfair Display (display/italic), Cormorant (verses/italic), Instrument Sans (UI). Load from Google Fonts.
- **Brand assets:** `assets/app-icon-512.png` (raster, para lojas) e `assets/app-icon.svg` (vetorial, para inline web/React). Logotype is reproducible in CSS (`.ds-logotype`).

## Non-negotiables
- Two assets only: **logotype** (site/LP) and **icon** (app/social). No isolated symbol.
- Cobalt `#2A47DD` is the only UI accent. Amber is used sparingly — only the highlighted verse and social pieces; never as UI/text color (use `#8A6A28` if amber text on light is unavoidable).
- Voice: "você", intimate, calm, sentence case, **no emoji**, no "gospel app" tropes (no purple/gold gradients, no crosses/halos), no Inter/Roboto/Arial.
- Icons: outline only, thin rounded stroke (Lucide recommended). Never heavy filled.

## How to deliver
If making visual artifacts (slides, mocks, throwaway prototypes), copy assets out and produce static HTML files for the user to view. If working on production code, copy assets and apply the rules here as an expert in this brand.

If invoked without guidance, ask what the user wants to build, ask a few focused questions, then act as an expert designer who outputs HTML artifacts **or** production code as needed.
