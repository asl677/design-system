# Alfa Design System
**Product:** Alfa by Boosted.ai  
**File:** `boosted-alfa-deck.html`  
**Stack:** Vanilla HTML/CSS/JS — no build step, no framework

---

## Fonts

Load via Google Fonts:
```
https://fonts.googleapis.com/css2?family=EB+Garamond:ital,wght@0,400;0,500;1,400;1,500&family=DM+Mono:wght@300;400&family=Inter:wght@300;400;500&display=swap
```

| Token | Family | Use |
|-------|--------|-----|
| `--serif` | `'EB Garamond', Georgia, serif` | Headings, body copy, pull quotes |
| `--body` | `'EB Garamond', Georgia, serif` | Same as serif — unified |
| `--mono` | `'DM Mono', monospace` | Labels, tags, captions, metadata |
| Classic override | `'Inter', 'Helvetica Neue', Arial, sans-serif` | All roles in Classic theme |

**Weight usage:**
- `300` — body copy, descriptors
- `400` — standard serif
- `500` — emphasis (rare)
- Italic EB Garamond used for accent words in headings (e.g. coral highlights)

---

## Colour Tokens

### Dark (default)
```css
--coral:         #d4622a        /* Primary accent — CTAs, highlights, italic headings */
--coral-dim:     rgba(212,98,42,.15)  /* Coral tint backgrounds */
--bg:            #0f0d0a        /* Page background */
--bg2:           #161310        /* Slightly lifted surfaces */
--surface:       #1c1810        /* Cards, panels */
--cream:         #ede0c8        /* Primary text */
--cream2:        #b0a08a        /* Secondary text */
--dust:          #7a6a54        /* Muted labels, metadata */
--rule:          rgba(255,255,255,0.12)  /* Dividers, borders */
--inv-btn:       #ede0c8        /* Inverted button background */
--inv-btn-text:  #0f0d0a        /* Inverted button text */
--ease-out:      cubic-bezier(0.16, 1, 0.3, 1)  /* Spring easing */
```

### Light (`[data-theme="light"]`)
```css
--bg:            #fefefe
--bg2:           #f5f5f5
--surface:       #efefef
--cream:         #1a1208
--cream2:        #5a4a36
--dust:          #8a7a64
--rule:          #d8cfc0
--coral-dim:     rgba(212,98,42,1)
--inv-btn:       #1a1208
--inv-btn-text:  #faf6ef
```

### Classic (`[data-theme="classic"]`)
```css
--bg:            #000000
--bg2:           #0a0a0a
--surface:       #141414
--cream:         #ffffff
--cream2:        #999999
--dust:          #555555
--rule:          rgba(255,255,255,0.12)
--coral:         #ffffff        /* Accent becomes white in Classic */
--coral-dim:     rgba(255,255,255,0.1)
--inv-btn:       #ffffff
--inv-btn-text:  #000000
--serif / --body / --mono: 'Inter', 'Helvetica Neue', Arial, sans-serif
```

---

## Type Scale

| Role | Class | Size | Font |
|------|-------|------|------|
| Hero / wordmark | `.alfa-wordmark` | `clamp(64px, 11.5vw, 148px)` | Serif, weight 300 |
| Section title | `.sec-title` | `clamp(36px, 5vw, 64px)` | Serif, weight 300, italic accent |
| Chapter title | `.ch-title` | `clamp(20px, 2.4vw, 32px)` | Serif, weight 300 |
| Audit label | `.audit-label` | `clamp(18px, 2.2vw, 26px)` | Serif, weight 300 |
| Pull quote | `.pullquote-text` | `clamp(26px, 4vw, 52px)` | Serif italic, weight 300 |
| Center quote | `.center-quote-text` | `clamp(32px, 5vw, 64px)` | Serif italic |
| Stat number | `.pq-stat` | `clamp(36px, 4vw, 52px)` | Serif, weight 300, coral |
| Body copy | `.body-col` | `17px` | Serif, weight 300, line-height 1.75 |
| Feature title | `.feat-title` | `21px` | Serif, weight 300 |
| Step title | `.step-title` | `19px` | Serif, weight 300 |
| Sub-section body | `.ta-text` | `16px` | Serif, weight 300 |
| Feature body | `.feat-body` | `15px` | Serif, weight 300 |
| Step body | `.step-body` | `15px` | Serif, weight 300, dust colour |
| Quote text | `.qc-text` | `18px` | Serif italic |
| Labels / mono | `.sec-num`, `.bc-label`, etc. | `9–10px` | DM Mono, uppercase, tracked |

**Text colour pattern:**
- Headlines → `var(--cream)`
- Body → `var(--cream2)`
- Metadata / labels → `var(--dust)`
- Accent words in headlines → `var(--coral)` + `font-style: italic`

---

## Spacing & Layout

```
Page padding:    120px left (clears fixed logo), 64px right
Mobile padding:  20px both sides (≤600px)
Section padding: 64px top (via .sec-hd)
Gap between sections: border-bottom rules, no margin stacking
Grid gap:        0 — borders used as dividers, not gap
```

**Page structure:**
```
html → overflow-x: hidden
body → overflow-x: hidden
.page → width: 100%; box-sizing: border-box; padding: 0 64px 0 120px
```

**Fixed element:**
- `#alfa-logo` — fixed top-left, `z-index: 100`, `left: 32px`, `top: 28px`
- Font: EB Garamond, 17px, `#ede0c8`

---

## Grid Components

### Bento / stat grid (`.perception-grid`, `.feat-grid`)
```css
display: grid;
grid-template-columns: 1fr 1fr;
border-top: 1px solid var(--rule);
border-left: 1px solid var(--rule);
/* cells get border-right + border-bottom */
/* odd cells get padding-left: 20px */
```

### Comparison grid (`.bc-grid`)
```css
grid-template-columns: 1fr 1fr;  /* 2×2 with 4 items */
border-top + border-left
/* each .bc-col: padding 22px, border-right + border-bottom */
```

### Stats row (`.boosted-stats`)
```css
grid-template-columns: repeat(4, 1fr);
border-top: 1px solid var(--rule);
/* each .bstat: padding 18px 20px, border-right */
```

**Padding rule:** All grid cells need `≥ 20px` horizontal padding. Never `padding: Npx 0`.

---

## Animation System

### Scroll reveal (`.ln`)
Every `.ln` element fades up on scroll via GSAP ScrollTrigger:
```js
gsap.from(el, {
  y: 24, opacity: 0, duration: 0.7, ease: 'power3.out',
  scrollTrigger: { trigger: el, start: 'top 105%' }
});
```
Cover elements animate on load (no scroll trigger).

### Merge circles
Two CSS `div` rings below the cover hero. Scroll-driven — no CSS transitions:
```
Left ring:  solid 1px border, starts left: 0
Right ring: dashed 1px border, starts right: 0
On scroll:  each travels 80px toward center (full overlap)
            left spins CW up to 200°, right CCW up to 200°
            dashed ring fades out at ~90% convergence → single solid circle
```

### Quote carousel
```js
setInterval(() => showNext(), 4000);  // auto-advance
// dot clicks for manual nav
// CSS: @keyframes qcFadeIn { opacity 0→1, translateY 6px→0 }
```

### Chat input
Cycling demo queries with typewriter-style rotation.  
Agent dots pulse via `@keyframes adotpulse`.

### Easing standard
```css
--ease-out: cubic-bezier(0.16, 1, 0.3, 1)  /* expo-out spring */
```

---

## Component Tokens

| Component | Key styles |
|-----------|-----------|
| `.audit-item` | `padding: 20px 4px`, coral SVG checkmark, serif label + body desc |
| `.pq-card` | `padding: 28px`, large coral stat number, body in `--cream2` |
| `.bc-col` | `padding: 22px`, brand name in serif 22px, verdict pill |
| `.cover-goal` | `padding: 14px 4px`, `border-bottom`, no top border on first |
| `.feat` | `padding: 28px`, mono number label in coral, serif title |
| `.step` | flex row, icon SVG + title + body, `border-bottom` |
| `.ios-notif` | `border-radius: 14px`, surface bg, icon + title + body |
| `.agent-row` | flex space-between, iOS-style toggle `.tog` / `.tog.on` |
| `.rm-item` | `padding: 24px 20px`, coral dot, mono quarter label |

---

## Verdict / Tag Pills

```css
/* Positive */
background: var(--coral-dim); color: var(--coral);

/* Warning / neutral */
background: rgba(255,255,255,.04); color: var(--dust); border: 1px solid var(--rule);

/* Tag inline (brand comparison) */
font-size: 8px; padding: 2px 6px; border-radius: 3px; border: 1px solid var(--rule);
.bc-tag--good { border-color: var(--coral); color: var(--coral); }
```

---

## Borders & Dividers

```css
/* Standard rule */
border: 1px solid var(--rule)    /* var(--rule) = rgba(255,255,255,0.12) dark */

/* Section header underline */
.sec-hd → border-bottom: 1px solid var(--rule)

/* Left accent (callouts, trust argument) */
width: 2px; background: var(--coral); opacity: 0.5

/* Grid cell borders */
border-right + border-bottom on cells; border-top + border-left on container
```

---

## Figma Variables (recommended mapping)

```
Color/Brand/Coral          #d4622a
Color/Brand/CoralDim       rgba(212,98,42,0.15)

Color/Dark/Background      #0f0d0a
Color/Dark/Surface         #1c1810
Color/Dark/TextPrimary     #ede0c8
Color/Dark/TextSecondary   #b0a08a
Color/Dark/TextMuted       #7a6a54
Color/Dark/Rule            rgba(255,255,255,0.12)

Color/Light/Background     #fefefe
Color/Light/TextPrimary    #1a1208
Color/Light/TextSecondary  #5a4a36
Color/Light/Rule           #d8cfc0

Color/Classic/Background   #000000
Color/Classic/TextPrimary  #ffffff
Color/Classic/TextMuted    #555555

Typography/Display         EB Garamond / 300 / clamp(64–148px)
Typography/Title           EB Garamond / 300 / clamp(36–64px)
Typography/Body            EB Garamond / 300 / 17px / lh 1.75
Typography/Label           DM Mono / 400 / 9–10px / uppercase / tracked
Typography/Mono            DM Mono / 300 / 12–14px

Spacing/PageLeft           120px (desktop), 20px (mobile)
Spacing/PageRight          64px (desktop), 20px (mobile)
Spacing/SectionGap         64px
Spacing/CardPadding        20–28px
```

---

## Themes — switching

Set `data-theme` attribute on `<html>`:
```js
document.documentElement.setAttribute('data-theme', 'light')  // 'dark' | 'light' | 'classic'
```
All CSS variables cascade from `:root` → `[data-theme="X"]` overrides.  
Classic theme forces `font-style: normal !important` on all italic headings.

---

## Figma MCP / Claude Code notes

- All layout is **single-column fluid** with left-padding gutter — no centered container
- Grid components use **border-as-divider** pattern (no gaps), suitable for Auto Layout with strokes
- All interactive states (hover, active) use `transition: color .15s, border-color .15s`
- Scroll animations are JS-driven — in Figma, represent as static converged/final state
- Mobile breakpoint: `600px` — padding collapses, grids go single column
- The fixed logo is the only `position: fixed` element; everything else is in normal flow
