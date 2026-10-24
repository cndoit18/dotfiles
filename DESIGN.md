---
title: "Design System: DeepSeek Harness Web GUI"
---

# Design System: DeepSeek Harness Web GUI

Design system reverse-engineered from the live DeepSeek Harness web app (`dsh web`, `@deepseek-ai/dsh` 0.2.1-rc.2, frontend 0.2.1-rc.2), the browser-surface GUI of the DSH agent workbench. All values below were read from the running app's computed styles and its 434 CSS custom properties (`--dsw-*` design tokens), in both light and dark appearance modes.

## 1. Visual Theme & Atmosphere

DeepSeek Harness Web is a quiet, high-density developer workbench that borrows the visual language of a well-crafted native desktop app rather than a marketing site. The mood is calm, neutral, and precision-driven: near-black ink on clean white, a single electric-blue accent reserved for interactive commitment, and layered surfaces separated by hairline strokes and soft, diffuse shadows instead of heavy borders. The overall feeling is "serious tool, thoughtfully softened" — superellipse corners (the token `--dsw-corner-shape: superellipse(1.5)`) give every container a subtle iOS-like continuous-curve feel, and the signature 28px-radius floating composer card makes the conversation the hero of the screen.

Visual density is compact and information-first. The UI type scale bottoms out at 11px (code, badges) and the workhorse sizes are 13–14px; chat answers render at a comfortable 14px/24px markdown rhythm. Whitespace is generous around the composer and empty states but tight inside lists and tool rows, so the product reads as an IDE-adjacent console rather than a consumer chat app.

Brand posture is restrained and technical. Chrome is almost entirely achromatic; the brand near-black `#0f1115` is itself the primary button color. Color appears only when it means something: blue for links, the send action, and selected state; green/amber/red exclusively for diff and status semantics. A whale/fish logomark and the poetic empty-state headline "探索未至之境" ("explore the uncharted") are the only playful notes, paired with a low-key "预览版" (preview) pill.

### Key Characteristics

- Shadow-as-border: every elevated surface carries a `0 0 0 0.5px` hairline stroke as the first shadow layer, so cards read as crisp bordered modules at rest and softly lift on larger shadows.
- Superellipse corners on containers; pill (999px) buttons and badges; a strict 4/8/12/16/20/28px radius ladder.
- Universal translucent hover wash (`#263148` at ~6% in light, `#ffffff` at ~8% in dark) applied to rows, icon buttons, and ghost controls.
- A 1200px fixed-width centered app frame with a resizable three-column workbench (sidebar | conversation | right rail), collapsing to a 56px icon rail on mobile.
- Chat-first composition: floating white composer card anchored to the bottom of the center column in every view.
- True dual-theme token architecture: the same `--dsw-alias-*` tokens re-resolve for dark mode, inverting ink/surface and re-tuning the accent brighter.

## 2. Color Palette & Roles

Semantic names map to the app's own `--dsw-alias-*` token names. Hex values are exact; alpha notation `#RRGGBBAA` is used where the token itself is an alpha blend.

| Role | Semantic Name | Value | Usage |
| --- | --- | --- | --- |
| Primary action | `--dsw-alias-brand-primary` / `button-primary-fill` | `#0f1115` | Primary buttons (black fill, white text), brand bar, primary ink |
| Primary action hover | `--dsw-alias-button-primary-hover` | `#43454a` | Hover on black buttons |
| Accent / link | `--dsw-alias-link` / `state-business-primary` | `#4176e6` | Links, send button, selected tabs, info emphasis, focus rings |
| Accent hover | `--dsw-alias-button-info-hover` | `#7aaaff` | Hover on accent surfaces |
| Accent tint | `--dsw-alias-state-business-tertiary` | `#e4edfd` | Preview badge fill, active accent items, selection washes |
| User bubble | (session bubble token) | `#edf3fe` | Current-user message bubble (light mode only) |
| Background | `--dsw-alias-bg-base` | `#ffffff` | App frame, dialogs, cards |
| Module background | `--dsw-alias-bg-module-platform` / `turn-trigger-bg` | `#f5f6f7` / `#f9fafb` | Sidebar (`#f9fafb`), attachment pills, code blocks (`#f9fafb`) |
| Overlay background | `--dsw-alias-bg-overlay` | `#e9ecf2` | Sheet/backdrop surfaces |
| Text primary | `--dsw-alias-label-primary` | `#0f1115` | Headlines, body, strong labels |
| Text secondary | `--dsw-alias-label-secondary` | `#61666b` | Metadata, descriptions, icons |
| Text tertiary | `--dsw-alias-label-tertiary` | `#81858c` | Timestamps, placeholders-in-text, disabled-feel captions |
| Placeholder | (composer placeholder observed) | `#adb2b8` | Input placeholder text |
| Border L1 | `--dsw-alias-border-l1` | `#0000000a` | Faintest dividers |
| Border L2 | `--dsw-alias-border-l2` | `#0000001a` | Hairline card borders, icon tiles |
| Border L4 | `--dsw-alias-border-l4` | `#00000029` | The 0.5px elevation stroke color, ghost button borders |
| Success | `--dsw-alias-state-success-primary/tertiary` | `#22c55e` / `#e6faed` | Checkmarks, added-line washes |
| Warning | `--dsw-alias-state-warn-primary/tertiary` | `#f59e0b` / `#fef5e7` | Caution states |
| Error | `--dsw-alias-state-error-primary/secondary` | `#ec1313` / `#f25a5a` | Errors, deleted-line washes |
| Diff added | `--dsw-alias-file-diff-added-bg/marker` | `#e6f4e7` / `#01a241` | File diff added rows and gutter markers |
| Diff deleted | `--dsw-alias-file-diff-deleted-bg/marker` | `#fce6e2` / `#ba2723` | File diff deleted rows and markers |
| Modal mask | `--dsw-alias-bg-mask-1/3` | `#0000003d` / `#0000007a` | Dialog scrims |

### Primary

- Brand ink `#0f1115` is the product's primary color: primary buttons are solid black with white 13px text, and the same near-black serves as the main text ink. It inverts to `#f9fafb` in dark mode.
- The accent `#4176e6` is a functional blue, never decorative: send action, links, selected tabs, focus rings, and the "business" info state all share it.

### Interactive

- Hover wash: `--dsw-alias-interactive-bg-hover = #2631480f` (~6% indigo-black) on rows, ghost buttons, menu items; hover-accent `#26314824` (~14%) for accent-tinted rows.
- Active/pressed: `--dsw-alias-interactive-bg-active = #2631481a` (~10%).
- Sidebar uses solid hovers instead: nav-item hover `#f1f3f5`, active `#ebeef2`, active-accent `#e4edfd`.
- Focus ring: `2px solid` accent (`--dsw-focus-ring-width: 2px`, color falls back to `state-business-primary`).
- Links underline dotted on hover with `text-underline-offset: 3px`.

### Neutral Scale

- Ink / primary text: `#0f1115`; dimmed primary: `#151517` (light) / `#ebeef2` (dark).
- Secondary: `#61666b`; tertiary: `#81858c`; placeholder: `#adb2b8`.
- Surfaces: white `#ffffff` → `#f9fafb` → `#f5f6f7` → `#e9ecf2` → `#ebeef2` (light); `#151517` → `#232324` → `#2c2c2e` → `#353638` (dark layers 1–4).
- Scrollbars: track `#e5e5e5`, thumb hover `#d4d4d4`.

### Surface & Overlay

- Base surface: `#ffffff` (light) / `#151517` (dark).
- Raised layers (dark): layer-2 `#2c2c2e` is the composer card and user-bubble surface; layer-3 `#353638` is the toast background.
- Overlays/masks: `#0000003d`, `#0000001f`, `#0000007a`, plus `#ffffffb3` drop-mask and `#000000e0` photo-mask.
- Skeleton shimmer: `#0000000a` base with a white/indigo gradient sweep.

### Shadows & Depth

- Card shadow: `0 0 0 .5px #00000029, 0 4px 16px 0 #00000008, 0 0 24px 0 #00000008`
- Ring border: `0 0 0 0.5px #00000029`
- Elevation stroke (signature): the half-pixel "shadow border" hairline that leads every elevation layer, so cards read as crisp bordered modules at rest and softly lift with the blur layers; the ring border is the stroke-only level (white-alpha variant in dark mode).
- Panel / dialog (`--dsw-elevation-panel`): `0 0 0 .5px #00000029, 0 3px 8px 0 #00000008, 0 0 16px 0 #00000005`.
- Prominent: `0 0 0 .5px #00000029, 0 3px 8px 0 #0000000a, 0 0 20px 0 #0000000d`.
- Utility levels: lv1 `0 2px 4px 0 #0000000d`; lv2 `0 4px 12px 0 #00000005, 0 2px 8px 0 #0000000a`; lv3 `0 0 1px 0 #0003, 0 0 4px 0 #00000005, 0 12px 32px 0 #00000014`.
- Focus: `2px solid` accent ring; no glow.

## Theme Modes

The product ships three appearance options (设置 → 外观: 浅色 / 深色 / 跟随系统) selected via cube-shaped swatch buttons. The same alias tokens re-resolve per mode; borders switch from black-alpha hairlines to white-alpha hairlines.

### Light Mode

- Background: `#ffffff` frame; sidebar `#f9fafb`.
- Surface: cards/dialogs `#ffffff` with black-alpha hairline stroke (`#00000029`) plus soft shadow.
- Text: primary `#0f1115`, secondary `#61666b`, tertiary `#81858c`.
- Accent: `#4176e6` (send, links, selected tabs); accent hover `#7aaaff`.
- Notes: user bubble is a blue tint `#edf3fe`; hover wash is indigo-black `#2631480f`.

### Dark Mode

- Background: `#151517` frame; sidebar `#1b1b1c`.
- Surface: cards/dialogs `#2c2c2e` (layer-2), settings cards `#2c2c2e`, code blocks `#1b1b1c`.
- Text: primary `#f9fafb`, secondary `#cfd3d6`, tertiary `#adb2b8`.
- Accent: re-tuned brighter `#5686fe` (primary actions); links `#7aaaff`.
- Notes: hairline stroke becomes white-alpha `rgba(255,255,255,0.12)`; hover wash becomes `#ffffff14` (~8%); the primary button inverts to near-white `#f9fafb` fill with `#0f1115` text; the user bubble loses its blue tint and becomes the neutral raised surface `#2c2c2e`.


## 3. Typography Rules

A single system-ui stack carries the whole UI, tuned for dense bilingual (Chinese/Latin) reading. The brand face Montserrat appears only in the wordmark slot. Code gets a dedicated mono stack. Hierarchy is flat-on-purpose: weight (400/500/600/700) and size do the work, with tight line-heights to keep tool UIs scannable.

### Font Family

- Primary: `-apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", "Helvetica Neue", Helvetica, Arial, sans-serif`
- Brand/display: `"Montserrat", -apple-system, BlinkMacMacSystemFont, …` (same fallback stack)
- Monospace: `"SF Mono", "JetBrains Mono", "Fira Code", Consolas, "Liberation Mono", Menlo, Courier, "PingFang SC", "Microsoft YaHei"` (CJK fallback inside code)
- OpenType Features: none observed; tabular numerals not enforced.

### Hierarchy

| Role | Font | Size | Weight | Line Height | Letter Spacing | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Empty-state headline | System | 26px | 500 | 32px | normal | "探索未至之境" hero line above the composer |
| Page title | System | 20px | 500 | 28px | normal | `--dsw-font-l-20`; view headers |
| Section heading | System | 16px | 500 | 28px | normal | `--dsw-font-m-18`; card/group titles |
| Body (base) | System | 16px | 400 | 24px | normal | `--dsw-font-base-16`; frame default |
| UI workhorse | System | 14px | 400 | 22–24px | normal | Sidebar, composer input, buttons |
| Secondary UI | System | 13px | 400/500 | 20px | normal | Workspace picker, model badge, metadata |
| Caption / meta | System | 12px | 400 | 20px | normal | Timestamps, badges, empty-state subcopy |
| Badge micro | System | 10–11px | 500 | ~14px | normal | "实验性" experimental pill at 10px/500 |
| Markdown body | System | 14px | 400 | 24px | normal | Chat answers; adjustable 12–20px in settings |
| Markdown h1 | System | 21px | 700 | 30px | normal | Agent-rendered headings |
| Markdown h2 | System | 19px | 700 | 28px | normal | Agent-rendered headings |
| Markdown h3 | System | 18px | 700 | 26px | normal | Agent-rendered headings |
| Markdown h4 | System | 14px | 600 | 24px | normal | Agent-rendered headings |
| Inline code | Mono | 12.25px | 400 | 19px | normal | `#fafafa` chip, radius 8px, pad 0/5px |
| Code block | Mono | 11px | 400 | 19px | normal | `#f9fafb` surface, banner header, bottom radius 16px |
| Terminal | Mono | 13px | 400 | ~19px | normal | Terminal panes |

### Principles

- One stack for everything; never introduce a second UI typeface. Weight contrast (400 vs 500 vs 700) is the hierarchy.
- Keep UI text at 13–14px; reserve 16px for page framing and 20px+ for true view titles. 11–12px is metadata-only.
- Chat content is 14px/24px by default and user-adjustable (settings 字号大小, default 14px) — never hard-code chat text size.
- Chinese and Latin glyphs share the same stack; no letter-spacing adjustments observed anywhere.
- Code always renders in the mono stack at 11–13px with a light gray chip/block surface.

## 4. Component Stylings

### Buttons and Links

- **Primary CTA:** solid brand-black fill `#0f1115`, white 13px text, radius 12px, padding ~8px 12px; hover fill `#43454a`; 0.1s background-color transition. In dark mode the fill inverts to `#f9fafb` with `#0f1115` text (hover `#ebeef2`).
- **Send action (accent pill):** `#4176e6` fill (dark: `#7aaaff`), radius 999px, compact ~1px/6px padding around a 13.33px arrow icon.
- **Secondary CTA / ghost:** transparent fill, 0.5px hairline border (`#0000001f`), white or transparent background; hover uses the translucent wash `#2631480f`; active fill `#ebeef2` with border `#979da6`.
- **Icon buttons:** 36px square, radius 8px (small) or 12px (rail), secondary-gray icon `#61666b`, hover wash.
- **Text links:** accent `#4176e6`, no underline at rest; hover switches to dotted underline (`text-decoration: underline dotted`, offset 3px).
- **"New session" sidebar button:** white card, 0.5px border `rgba(0,0,0,0.12)`, radius 12px, 8px/12px padding, 14px label + right-aligned shortcut hint (⌥⌘N).

### Cards and Containers

- Surface style: white fill, elevation-stroke hairline + soft layered shadow (see Shadows & Depth).
- Radius ladder: composer/dialog 28px; plugin card 20px; user bubble 20px; icon tiles 16px; rows and buttons 12px; small icon buttons 8px; badges pill 999px.
- Border: prefer the 0.5px hairline stroke over visible 1px borders; only inputs and ghost buttons use real borders.
- Internal spacing: 8px base padding on composer card inner rows; 10px/16px in user bubbles; 8px/12px on list rows.
- The composer card is the signature container: 28px superellipse corners, white, floating above the conversation with the soft elevation; its border turns accent-blue on focus-within.

### Inputs and Interactive Controls

- Input treatment: borderless 14px text inside the composer card; placeholder `#adb2b8`; the card's hairline stroke is the only boundary.
- Focus behavior: focus-within on the composer switches border color to accent `#4176e6`; a 2px solid accent focus ring appears on tabs, switches, checkboxes, and copyable blocks.
- Selection: document selection is a translucent accent (`color-mix(in srgb, #3b82f6 40%, transparent)`); code segments use `#fff` selected / `#f1f3f5` unselected chips.
- Settings cards: white fill with `#00000029` stroke (dark: `#2c2c2e` fill, `#fff3` stroke), radius 20px.
- Theme picker: cube swatch buttons showing mini light/dark previews, `aria-pressed` state.
- Switch/checkbox: accent fill when on; focus-visible ring 2px accent.
- Scrollbar: thin, `#e5e5e5` thumb, `#d4d4d4` on hover.

### Navigation

- Structure: left sidebar (279.5px at 1200px frame) with logo row, "新会话" action, plugin/task nav rows, workspace groups with expandable session lists, and a footer with account menu; plus tab-style sub-navigation inside views (对话 / 轨迹).
- Background treatment: sidebar `#f9fafb` against white content (dark `#1b1b1c` against `#151517`).
- Link/row style: 14px label rows, radius 12px, hover `#f1f3f5`, active `#ebeef2`; session/workspace child rows radius 8px.
- Sticky/scroll behavior: sidebar is fixed; conversation scrolls inside `scrollBody`; the composer stays anchored at the bottom of the center column.
- View tabs (对话/轨迹): 13px, selected = accent `#4176e6`, unselected = tertiary `#81858c`; focus shows 1px underline.

### Image Treatment

- Icons: thin-stroke SVG line icons in secondary gray `#61666b`, rendered at 13–16px inside 36px hit areas; the logo is a playful whale/fish glyph.
- Plugin icons: rounded tiles (radius 16px) with 0.5px hairline border `rgba(0,0,0,0.12)`, transparent interior.
- Screenshots/photos: masked overlays available (`#000000e0` photo mask); diff images use green/red gutter markers.

### Distinctive Components

- **Floating composer card:** the product's hero. 28px radius, white, hairline + soft shadow, internal tools row with pill buttons (add `#f5f6f7`, send `#4176e6`), 14px input, workspace picker above it.
- **User message bubble:** `#edf3fe` light-blue tint, 20px radius, 10px/16px padding, left-aligned in its own column (not right-aligned bubbles), 14px/22px text.
- **Agent markdown body:** 14px/24px ink text; h1–h4 at 700/700/700/600; inline code chips `#fafafa`; fenced blocks `#f9fafb` with a banner header row and 16px bottom corners, 11px mono.
- **Activity/trigger rows:** collapsible "更多" (more) rows at 12px tertiary gray showing tool-call metadata such as "用量 879K tok".
- **Badges:** "预览版" pill — `#e4edfd` fill, 12px text, 0.5px border; "实验性" pill — 10px/500 accent text on a 10% accent wash, pill, 7px horizontal padding.
- **Preview dialog:** 800px white dialog, 28px radius, panel elevation, scrim `#0000003d`; focused-heading layout with an error slot ("暂时无法保存确认状态，请重试。").

## 5. Layout Principles

### Spacing System

- Base unit: 8px (all observed paddings/gaps are multiples or simple halves of 8).
- Repeated spacing values: 4px (icon gaps), 8px (card inner padding, tile padding, list item gaps), 12px (button horizontal padding, composer gaps), 16px (bubble horizontal padding, section gaps), 20px (radius + large gaps), 28px (panel radius/composer), 36px (touch targets).

### Grid & Container

- Grid logic: fixed three-column app frame — `sidebar 279.5px | center fluid (~920px at 1200 frame) | right rail 0–collapsible`, separated by an 8px drag handle; a `bottomRow` and `overlayLayer` span the frame.
- Max content width: the app frame is 1200px centered with a white background; inside, the conversation column is fluid between sidebar and right rail.
- Section spacing: 8–16px between stacked controls; dialogs pad content in 24–32px.

### Whitespace Philosophy

- Whitespace philosophy: compact-but-breathable; lists are tight, framing is airy. The composer and empty states get generous surrounding space to focus attention on the conversation.
- Alignment tendencies: left-aligned everything; the user column is left-aligned, metadata sits above or beside titles in small gray text.
- Content width behavior: chat/markdown content maxes out around ~76ch inside the center column; sidebars truncate with ellipsis.

### Border Radius Scale

- Micro: 4px (badge corners, small chips).
- Small: 8px (icon buttons, workspace picker, session rows).
- Standard: 12px (primary/ghost buttons, nav rows, mobile rail buttons).
- Large: 16px (code-block bottom corners, plugin icon tiles).
- XL: 20px (user bubble, plugin cards, settings cards).
- Panel: 28px (composer card, dialogs) with superellipse corner shaping.
- Pill: 999px (send button, add button, badges, segmented controls).

## 6. Depth & Elevation

| Level | Treatment | Use |
| --- | --- | --- |
| Flat | No shadow, transparent or solid `#f5f6f7/#f9fafb` fill | Sidebar, code blocks, attachment pills, skeletons |
| Ring | `0 0 0 0.5px` hairline stroke only (`#00000029` / dark white 12%) | Ghost buttons, icon tiles, inputs at rest |
| Card | hairline + `0 4px 16px #00000008, 0 0 24px #00000008` | Composer card, floating panels |
| Panel | hairline + `0 3px 8px #00000008, 0 0 16px #00000005` | Dialogs, menus, popovers |
| Prominent | hairline + `0 3px 8px #0000000a, 0 0 20px #0000000d` | Calls-to-action needing lift |
| Focus | `2px solid #4176e6` ring | Tabs, switches, checkboxes, copyables |
| lv3 | `0 0 1px #0003, 0 0 4px #00000005, 0 12px 32px #00000014` | Dropdowns, contextual popovers |

### Depth Principles

- Surface hierarchy: white frame > gray sidebar > white/elevated cards; in dark mode, depth is expressed by lightening layers (`#151517` → `#353638`) rather than darker shadows.
- Shadow language: shadows are diffuse, low-opacity, and never harsh; the 0.5px stroke is what defines the edge, the blur layers only lift.
- Blur/glass: scrims are flat color (`#0000003d` etc.), no backdrop blur observed.
- When depth is avoided: lists, nav rows, and static content stay flat; elevation is reserved for the composer, dialogs, menus, and popovers.

## 7. Do's and Don'ts

### Do

- Do use the 8px spacing base and the exact radius ladder (4/8/12/16/20/28/999).
- Do put the primary action in a black (light mode) or white (dark mode) 12px-radius button; reserve `#4176e6` for the single most important commitment (send, links, selected).
- Do separate surfaces with the 0.5px hairline stroke plus a soft layered shadow.
- Do use the universal hover wash (`#2631480f` light / `#ffffff14` dark) on any interactive row.
- Do keep text at 13–14px in tool UI and 14px/24px in chat content.
- Do switch the whole token set (not individual colors) when changing themes.

### Don't

- Don't use saturated color for decoration — color is semantic (accent/info/success/warn/error) only.
- Don't use 1px+ solid borders on cards; the half-pixel stroke shadow is the border.
- Don't right-align user messages or use heavy bubble shadows; bubbles are quiet tinted/solid blocks.
- Don't introduce new fonts or letter-spacing; the system stack and default tracking are mandatory.
- Don't use sharp 2–4px corners on containers; small radii are for chips and icon buttons only.
- Don't animate with long durations; keep transitions at 0.1–0.3s with `cubic-bezier(.4,0,.2,1)`.

## 8. Responsive Behavior

### Breakpoints

| Name | Width | Key Changes |
| --- | --- | --- |
| Mobile | 390px | Sidebar collapses to 56px icon rail; center column takes remaining ~334px |
| Tablet | ~768–1024px | Frame fluid; sidebar may stay narrow; right rail hidden by default |
| Desktop | 1280px+ | Full 1200px centered frame: 279.5px sidebar, ~920px center, collapsible right rail |

### Touch Targets

- Icon buttons are 36×36px minimum (mobile rail uses 36×36 at radius 12px).
- Nav/session rows keep ~40px height; badge hit areas padded to ≥7px horizontally.
- Composer tools remain thumb-reachable pills at the bottom of the screen.

### Collapsing Strategy

- Desktop behavior: full three-column workbench with draggable 8px handles between columns.
- Tablet behavior: frame shrinks proportionally; right rail (轨迹/trace) overlays instead of docking.
- Mobile behavior: sidebar becomes a 56px rail with 7 icon buttons (open sidebar, new session, plugins, automated tasks, add workspace, search sessions, account menu); workspace text labels truncate; composer keeps 28px radius and stacks its tool rows.
- Breakpoint-driven component changes: text labels hide before icons do; session groups collapse to counts (展开其余 N 个会话).
- Touch target and spacing adjustments: 8px base padding preserved; buttons grow to 36px squares; dialogs go full-bleed at small widths.

## 9. Agent Prompt Guide

### Quick Color Reference

- Background: `#ffffff` app frame with `#f9fafb` sidebar
- Elevated surface: `#ffffff` cards and dialogs with `#00000029` hairline stroke
- Heading text: `#0f1115` near-black ink, weight 500–700 (dark mode: `#f9fafb`)
- Body text: `#61666b` secondary ink for descriptions and metadata (primary text is `#0f1115`)
- Ring / border: `#00000029` half-pixel hairline stroke (dark mode: white at 12%)
- Accent / focus: `#4176e6` links, send, selected tabs, and 2px focus rings (dark mode: `#5686fe`)

### Quick Summary

DeepSeek Harness Web is a 1200px-centered, three-column agent workbench with a chat-first layout. It is chrome-light and nearly achromatic: near-black ink `#0f1115` doubles as the primary button color, one electric blue `#4176e6` marks interactivity, and elevated surfaces use a signature 0.5px hairline "shadow border" with soft diffuse blur layers. Corners are superellipse-smooth with a strict 4/8/12/16/20/28/999px radius ladder. Type is a single system-ui stack at 13–14px UI sizes with a 14px/24px markdown rhythm and SF Mono code at 11–13px. Hovering anything applies a translucent `#2631480f` wash; focus gets a 2px accent ring. Dual light/dark themes fully re-resolve the same tokens, inverting ink/surface and brightening the accent in dark mode.

### Example Component Prompts

- Hero: "Build an empty-state hero: 26px/500 headline in `#0f1115`, a small 12px '预览版' pill with `#e4edfd` fill and 0.5px border next to the title, a whale-glyph SVG, and a 28px-radius white composer card below with a soft hairline-shadow, all on white."
- Card: "Create a chat composer card: white fill, 28px superellipse radius, `0 0 0 .5px #00000029, 0 4px 16px #00000008, 0 0 24px #00000008` shadow, 8px inner padding, a 14px borderless input with `#adb2b8` placeholder, a `#f5f6f7` pill add-button, and a `#4176e6` pill send button; border turns `#4176e6` on focus-within."
- Navigation: "Build a workbench sidebar: 279.5px wide, `#f9fafb` background, logo row, a white 12px-radius '新会话' card button with 0.5px border, 14px nav rows (radius 12px, hover `#f1f3f5`, active `#ebeef2`), expandable workspace groups with 8px-radius session rows, and a footer account menu."
- Button or badge: "Style a primary button: 12px radius, `#0f1115` fill, white 13px text, 8px/12px padding, hover `#43454a`, 0.1s background-color transition. An 'experimental' badge is a 999px pill, 10px/500 accent text on a 10% `#4176e6` wash, 7px horizontal padding."

### Ready-to-Use Prompt

Build a page in DeepSeek Harness's design language: a centered 1200px white frame with a 279.5px `#f9fafb` sidebar on the left and a fluid conversation column; near-black `#0f1115` ink and primary buttons; a single `#4176e6` accent for links, selection, and the pill-shaped send button; the signature floating composer card (28px superellipse radius, white, hairline stroke + soft layered shadow); 8px spacing base; the system-ui font stack at 13–14px UI size and 14px/24px markdown; the universal translucent hover wash `#2631480f`; 2px accent focus rings; and full dark-mode support via inverted tokens (`#151517` base, `#2c2c2e` surfaces, `#5686fe` accent).

### Iteration Guide

1. Start from the composer card and sidebar — they define the whole spatial system; everything else hangs off the 8px grid.
2. Lock color semantics before styling: pick ink/accent/semantic states first, then derive tints (`#e4edfd`, `#e6faed`, `#fef5e7`) from them.
3. Prototype both themes together; if a component works in one mode only, re-check the alias tokens rather than adding overrides.
4. Verify hover/focus/active on every interactive element — the wash + 2px ring system is easy to break accidentally.
5. Stress-test with real agent markdown (headings, code blocks, diffs) at 14px; that is the primary reading surface.

## Optional Appendix: Interaction Patterns

- Scroll behavior: conversation scrolls inside a fixed `scrollBody`; composer and header stay anchored; sidebar scrolls independently.
- Hover behavior: universal translucent wash (`#2631480f` light, `#ffffff14` dark); sidebar rows use solid `#f1f3f5`; chevrons/icons fade-swap on hover (idle icon fades out, hover chevron fades in).
- Click behavior: active/pressed state at ~10% wash; selected nav items move to solid `#ebeef2` or accent-tint `#e4edfd`; dialogs focus-trap with the title focused on open.
- Animation tone: restrained and fast — CSS transitions only at 0.1s (hover) / 0.2s / 0.3s with `cubic-bezier(.4,0,.2,1)`; no decorative keyframes observed; skeletons shimmer via a slow gradient sweep; motion is functional, never celebratory.
- Collapse/expand: session groups and tool-call steps accordion with height transitions; "更多" reveals hidden items inline.

## Optional Appendix: Content & Messaging Patterns

- Headline pattern: short, often poetic for empty states ("探索未至之境"), plain and functional for views ("安装、启用和配置插件").
- CTA language: terse verbs — 继续 (continue), 新会话 (new session), 添加插件 (add plugin), 选择工作区 (choose workspace); shortcut hints rendered as key caps (⌥⌘N, ⌥⌘,).
- Trust signal pattern: status pills and metadata lines ("已完成，用时 4分56秒", "用量 879K tok", relative timestamps like "2小时") instead of badges or review counts.
- Voice and tone: Chinese-first, precise, low-hype; onboarding copy is formal and community-oriented ("在开源、可复用、可组合的基础设施之上，共同探索智能上限"); error copy is plain and actionable ("暂时无法保存确认状态，请重试。").

## Optional Appendix: Observed Pages

- `http://127.0.0.1:8720/` (workspace overview + empty state): frame/grid system, sidebar anatomy, composer card, empty-state hero, preview badge, onboarding dialog.
- Session conversation view (用 dotfiles 管理 dsh 配置): header with model badge + tabs, user bubble, agent markdown (headings/inline code/code blocks/lists), activity/trigger rows, status metadata.
- Plugins view (插件): nav/page header, plugin cards with icon tiles and experimental badges, "添加插件" segmented control, settings cards.
- Settings dialog (设置): theme cube picker (浅色/深色/跟随系统), font-size and verbosity controls, switch/checkbox/slider controls.
- Dark mode sweep (via `prefers-color-scheme: dark`): all core tokens re-resolved, component-level dark surfaces verified.
- Mobile sweep (390×844): 56px icon rail, 36px touch targets, fluid center column.

Evidence basis: DOM structure, computed styles, and CSS custom properties extracted live with `agent-browser eval` from `dsh web` 0.2.1-rc.2 (desktop app build is 0.2.1-rc.3; the token architecture is shared, minor value drift possible). Values labeled "observed" are measured; a few role names are inferred from token usage.
