# Phase 11: Landing Page - Research

**Researched:** 2026-02-09
**Domain:** Static marketing landing page (HTML/CSS/JS), dark-mode, developer tool positioning
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Page structure
- Long-form single page with sticky anchor navigation
- Bold tagline hero (punchy identity line + supporting subtext + CTA)
- 7+ sections telling the full story -- visitors want to understand the tool completely before installing
- Animated terminal walkthrough showing Director's workflow (onboard -> blueprint -> build)
- Each section earns its spot -- comprehensive but scannable, not walls of text

#### Visual identity
- Bold & expressive design feel -- strong colors, large type, personality-driven (think Stripe, Raycast)
- Dark mode only -- dark background throughout, terminal content pops naturally
- Neutral base (black/white/gray) with one bold accent color for CTAs and highlights
- Logo assets exist: `/director` wordmark and `/d` square mark in dark/light variants at `docs/logos/`
- Favicon/icon: use the `/d` square dark variant

#### Messaging & audience
- Lead with aspiration: describe the persona first ("You have the ideas. AI writes the code."), then introduce the vibe coder identity as something they're becoming
- Target entrepreneurs who want confidence that they can build their ideas -- empowering, not gatekeeping
- Core emotional hook: **confidence** -- "I can actually build this"
- Light technical flavor -- mostly plain language, but terms like "plugin", "commands", "CLI" are fine where natural
- Subtle differentiation from competitors -- don't name them, but address the gap ("Other tools give you AI. Director gives you structure.")

#### Conversion & CTAs
- Two equal primary actions: install command (copy-paste) and GitHub repo link
- Install command and GitHub link both prominent -- ready visitors install, curious ones explore
- Optional email signup near bottom for developer's personal newsletter (not Director-specific)
  - Framed as the developer's newsletter for cross-promoting future plugins
  - Non-intrusive -- small section, no popups, no gates
  - Service: Buttondown, ConvertKit, or similar (Claude's discretion)

### Claude's Discretion
- Specific accent color (must pop against dark sections and complement the monochrome logo)
- Typography choices (complement the bold geometric sans-serif logo)
- Motion/animation level (beyond the terminal walkthrough)
- CTA placement frequency across the long-form page
- Whether to include brief prerequisites ("You'll need Claude Code") or assume visitors already have it
- Section ordering below the hero
- Footer content

### Deferred Ideas (OUT OF SCOPE)
- Multi-page site structure (docs, blog, etc.) -- future iteration if needed
- User testimonials / social proof section -- needs real users first
- Pricing page -- Director is free, but future plugins may not be
</user_constraints>

## Summary

This phase creates the director.cc homepage as a single-page static site served via GitHub Pages. The site is a long-form dark-mode marketing page targeting entrepreneurs/vibe coders, driving two conversions: plugin installation and GitHub exploration.

The standard approach for this type of page is **plain HTML + CSS + minimal vanilla JS** -- no framework, no build step, no dependencies. The project currently has no package.json, no build tools, and no frontend framework. A single-page marketing site does not benefit from React, Next.js, or even a static site generator. The page needs to load instantly, be easily maintainable, and deploy from the repo with zero build pipeline. Modern CSS (custom properties, scroll-driven features, grid, clamp) handles everything that used to require preprocessors or frameworks.

The site files should live in a dedicated `site/` directory at the project root, with GitHub Pages configured to serve from that directory. This keeps the landing page separate from the existing `docs/` folder (which contains design documents, not the website). The terminal animation uses a custom implementation inspired by termynal.js but hand-written for zero dependencies, since the animation requirements are specific and simple.

**Primary recommendation:** Build as plain HTML/CSS/JS in a `site/` directory, deploy via GitHub Pages with custom domain director.cc, use Inter font family for body and headings, electric blue (#3B82F6) as the accent color, and Buttondown for newsletter signup.

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Plain HTML5 | -- | Page structure | Zero dependencies, instant load, trivially deployable to GitHub Pages |
| Modern CSS3 | -- | All styling, layout, animations | Custom properties, grid, scroll-behavior, clamp() eliminate need for preprocessors |
| Vanilla JavaScript | ES2020+ | Terminal animation, copy-to-clipboard, scroll spy, intersection observer | No framework overhead for a single marketing page |
| GitHub Pages | -- | Hosting | Free, automatic HTTPS, custom domain support, deploys from repo |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Inter (Google Fonts) | Variable | Typography -- body and headings | Primary typeface, geometric sans-serif that complements the logo |
| JetBrains Mono (Google Fonts) | Variable | Monospace for terminal/code blocks | Clean monospace that pairs well with Inter for code |
| Buttondown | API | Newsletter email capture | Embed form via HTML form action, no JS required |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Plain HTML | Astro | Adds build step and complexity for zero benefit on a single page |
| Plain CSS | Tailwind | Requires build tooling, class soup in HTML, overkill for one page |
| Vanilla JS terminal | termynal.js | External dependency, less control over animation timing/content |
| GitHub Pages | Vercel/Netlify | Adds deployment complexity, the repo already lives on GitHub |
| Buttondown | Kit (ConvertKit) | Kit requires JS embed or more complex form; Buttondown works as plain HTML form POST |

**Installation:**
```bash
# No installation needed -- plain HTML/CSS/JS
# Only step: configure GitHub Pages in repo settings
```

## Architecture Patterns

### Recommended Project Structure
```
site/
  index.html           # The entire landing page
  css/
    styles.css         # All styles (custom properties, sections, components)
  js/
    main.js            # Terminal animation, copy-to-clipboard, scroll spy
  assets/
    director-logo.png  # Light variant of wordmark (white text for dark bg)
    favicon.png        # /d square dark variant
    og-image.png       # Open Graph social sharing image (1200x630)
  CNAME                # Contains "director.cc" for GitHub Pages custom domain
```

### Pattern 1: CSS Custom Properties Design System
**What:** Define all colors, spacing, and typography as CSS custom properties at `:root`, then reference them everywhere. This creates a single source of truth for the visual system.
**When to use:** Always -- this is the foundation of the entire page.
**Example:**
```css
/* Source: Modern CSS best practices */
:root {
  /* Colors */
  --color-bg: #0A0A0A;
  --color-bg-elevated: #141414;
  --color-bg-surface: #1A1A1A;
  --color-text-primary: #E0E0E0;
  --color-text-secondary: #9CA3AF;
  --color-text-muted: #6B7280;
  --color-accent: #3B82F6;
  --color-accent-hover: #2563EB;
  --color-white: #F5F5F5;

  /* Typography */
  --font-body: 'Inter', system-ui, -apple-system, sans-serif;
  --font-mono: 'JetBrains Mono', 'Fira Code', monospace;

  /* Spacing */
  --section-padding: clamp(4rem, 8vw, 8rem);
  --container-max: 1200px;
  --container-narrow: 800px;
}
```

### Pattern 2: Responsive Typography with clamp()
**What:** Use CSS `clamp()` for fluid typography that scales between mobile and desktop without media queries.
**When to use:** All headings and hero text.
**Example:**
```css
/* Source: Modern CSS best practices */
.hero-title {
  font-size: clamp(2.5rem, 5vw + 1rem, 5rem);
  font-weight: 800;
  line-height: 1.1;
  letter-spacing: -0.02em;
}

.section-title {
  font-size: clamp(1.75rem, 3vw + 0.5rem, 3rem);
  font-weight: 700;
  line-height: 1.2;
}
```

### Pattern 3: Scroll-Triggered Section Reveals with Intersection Observer
**What:** Sections fade/slide in as they enter the viewport, using IntersectionObserver for performant detection and CSS transitions for the animation.
**When to use:** All content sections below the hero.
**Example:**
```javascript
// Source: MDN IntersectionObserver API
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
      observer.unobserve(entry.target);
    }
  });
}, { threshold: 0.1 });

document.querySelectorAll('.section').forEach(el => observer.observe(el));
```
```css
.section {
  opacity: 0;
  transform: translateY(2rem);
  transition: opacity 0.6s ease, transform 0.6s ease;
}
.section.visible {
  opacity: 1;
  transform: translateY(0);
}
/* Respect user preferences */
@media (prefers-reduced-motion: reduce) {
  .section { opacity: 1; transform: none; transition: none; }
}
```

### Pattern 4: Sticky Navigation with Active Section Highlighting
**What:** Fixed navigation bar at the top with anchor links that highlight based on current scroll position.
**When to use:** The sticky navigation for the long-form page.
**Example:**
```css
/* Source: Modern CSS smooth scroll + sticky patterns */
html {
  scroll-behavior: smooth;
  scroll-padding-top: 5rem; /* Offset for sticky header height */
}

@media (prefers-reduced-motion: reduce) {
  html { scroll-behavior: auto; }
}

.nav {
  position: sticky;
  top: 0;
  z-index: 100;
  backdrop-filter: blur(12px);
  background: rgba(10, 10, 10, 0.85);
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
}
```

### Pattern 5: Terminal Animation (Custom)
**What:** A lightweight, custom terminal animation that types out commands and displays output, demonstrating the Director workflow (onboard -> blueprint -> build).
**When to use:** The animated terminal walkthrough section.
**Example:**
```javascript
// Custom terminal animation - no external dependencies
class TerminalAnimation {
  constructor(element, lines, options = {}) {
    this.el = element;
    this.lines = lines;
    this.typeDelay = options.typeDelay || 50;
    this.lineDelay = options.lineDelay || 800;
    this.outputDelay = options.outputDelay || 400;
  }

  async type(text, container) {
    for (const char of text) {
      container.textContent += char;
      await this.delay(this.typeDelay);
    }
  }

  async run() {
    for (const line of this.lines) {
      const lineEl = document.createElement('div');
      lineEl.className = `terminal-line ${line.type}`;

      if (line.type === 'input') {
        const prompt = document.createElement('span');
        prompt.className = 'terminal-prompt';
        prompt.textContent = '$ ';
        lineEl.appendChild(prompt);

        const text = document.createElement('span');
        lineEl.appendChild(text);
        this.el.appendChild(lineEl);
        await this.type(line.text, text);
        await this.delay(this.lineDelay);
      } else {
        lineEl.textContent = line.text;
        this.el.appendChild(lineEl);
        lineEl.classList.add('fade-in');
        await this.delay(this.outputDelay);
      }
    }
  }

  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
```

### Anti-Patterns to Avoid
- **Framework overhead for a single page:** Don't add React, Vue, Next.js, or Astro. The build/deploy complexity provides zero value for one HTML file.
- **CSS preprocessors:** Modern CSS custom properties and nesting eliminate the need for Sass/Less.
- **Heavy animation libraries:** Don't add GSAP, Framer Motion, or AOS.js. Intersection Observer + CSS transitions handle everything needed.
- **External dependency for clipboard:** The native `navigator.clipboard.writeText()` API works in all modern browsers over HTTPS (which GitHub Pages provides).
- **Over-engineering the terminal animation:** A simple async/await loop is sufficient. No need for a canvas-based or WebGL terminal emulator.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Newsletter signup | Custom email storage/sending | Buttondown embed form | Email deliverability, GDPR compliance, unsubscribe handling |
| Font loading | Self-hosted font files | Google Fonts CDN | Caching, performance, automatic format serving |
| Hosting/SSL | Custom server setup | GitHub Pages | Free, automatic HTTPS, zero maintenance, deploys on push |
| Social sharing images | Dynamic OG image generation | Static 1200x630 PNG | One page, one image, no dynamic generation needed |
| Favicon generation | Manual multi-size creation | Single 32x32 PNG + SVG | Modern browsers handle scaling; the /d square mark works at any size |
| Copy-to-clipboard | Custom clipboard library | `navigator.clipboard.writeText()` | Native API, works on HTTPS, 97%+ browser support |

**Key insight:** This is a single marketing page, not a web application. Every dependency adds complexity with no user benefit. The page should be deployable by dropping files into a directory.

## Common Pitfalls

### Pitfall 1: Pure Black Background Fatigue
**What goes wrong:** Using `#000000` as the background causes eye strain and makes the page feel harsh, especially on OLED screens where pure black creates stark contrast halos around text.
**Why it happens:** "Dark mode" gets equated with "black."
**How to avoid:** Use near-black (`#0A0A0A` to `#121212`) for the main background. Use slightly lighter dark grays (`#141414`, `#1A1A1A`) for elevated surfaces like the terminal window and card backgrounds. This creates depth without harshness.
**Warning signs:** Text feels like it's floating or vibrating against the background.

### Pitfall 2: Anchor Links Hidden Behind Sticky Header
**What goes wrong:** Clicking a nav link scrolls the target section behind the sticky header, hiding the section title.
**Why it happens:** Default browser scroll-to-anchor doesn't account for sticky/fixed elements.
**How to avoid:** Use `scroll-padding-top` on the `html` element set to at least the header height (e.g., `5rem`). This is a one-line CSS fix.
**Warning signs:** Section titles disappear when navigating via anchor links.

### Pitfall 3: Terminal Animation Not Visible When Triggered
**What goes wrong:** The terminal animation plays immediately on page load, so users who scroll down to it see it already completed or mid-way through.
**Why it happens:** Animation starts on DOMContentLoaded instead of when the element enters the viewport.
**How to avoid:** Use IntersectionObserver to trigger the terminal animation only when it scrolls into view. Include a "replay" button so users can watch it again.
**Warning signs:** Users see a static terminal with all text already displayed.

### Pitfall 4: Copy Button Fails on HTTP
**What goes wrong:** The `navigator.clipboard.writeText()` API silently fails or throws an error.
**Why it happens:** The Clipboard API requires a secure context (HTTPS). If testing locally via `file://` or `http://`, it won't work.
**How to avoid:** GitHub Pages provides HTTPS automatically. For local development, use `python3 -m http.server` and test on `localhost` (which is treated as secure). Add a fallback that selects text in an input element for edge cases.
**Warning signs:** Click "copy" but nothing happens, no feedback.

### Pitfall 5: Logo Wrong Variant on Dark Background
**What goes wrong:** Using the dark logo variant (dark text on transparent background) on the dark page background makes the logo invisible.
**Why it happens:** The naming convention is counterintuitive -- "dark" variant means dark-colored text (designed for light backgrounds).
**How to avoid:** Use `director-logo-light.png` (white text) for the dark page background. The "light" variant has light/white text designed for dark backgrounds. Verify: the light wordmark is 346x68px white text on transparent; the light square is 150x150px dark text on light background -- actually use `director-logo-dark.png` for the wordmark on dark backgrounds because the image shows "/director" in dark/black text. Wait -- the actual image content needs checking.
**Warning signs:** Logo invisible or barely visible against the page background.

**IMPORTANT NOTE on logo variants:** Based on examining the actual image files:
- `director-logo-dark.png` = Dark/black text "/director" on transparent background (for use on LIGHT backgrounds)
- `director-logo-light.png` = White text "/director" on transparent background (for use on DARK backgrounds)
- `director-logo-sq-dark.png` = White "/d" on dark/black square background (works on any background)
- `director-logo-sq-light.png` = Dark "/d" on light/white square background (works on any background)

**For the dark landing page, use:** `director-logo-light.png` for the header wordmark, and `director-logo-sq-dark.png` for the favicon.

### Pitfall 6: Font Loading Flash (FOUT)
**What goes wrong:** Page renders with system fonts, then jumps to Inter when Google Fonts loads.
**Why it happens:** Web fonts load asynchronously after HTML renders.
**How to avoid:** Use `font-display: swap` (Google Fonts does this by default) and specify system font fallbacks that closely match Inter's metrics. Preload the font file using `<link rel="preload">`.
**Warning signs:** Visible text reflow/jump on initial page load.

### Pitfall 7: GitHub Pages CNAME Reset
**What goes wrong:** Custom domain setting gets lost after a push.
**Why it happens:** GitHub Pages looks for a `CNAME` file in the publishing source. If it's missing, the custom domain configuration can be dropped.
**How to avoid:** Include a `CNAME` file in the site directory containing `director.cc` (no protocol, no trailing slash). This file must be committed to the repo.
**Warning signs:** Site reverts to `username.github.io/repo` URL after deployment.

## Code Examples

### Copy-to-Clipboard Install Command
```html
<!-- Source: MDN Clipboard API -->
<div class="install-block">
  <code class="install-command" id="installCmd">
    /plugin marketplace add noahrasheta/director && /plugin install director@director-marketplace
  </code>
  <button class="copy-btn" onclick="copyInstall()" aria-label="Copy install command">
    <span class="copy-icon">Copy</span>
    <span class="copy-success" hidden>Copied!</span>
  </button>
</div>

<script>
async function copyInstall() {
  const text = document.getElementById('installCmd').textContent.trim();
  try {
    await navigator.clipboard.writeText(text);
    const btn = document.querySelector('.copy-btn');
    btn.querySelector('.copy-icon').hidden = true;
    btn.querySelector('.copy-success').hidden = false;
    setTimeout(() => {
      btn.querySelector('.copy-icon').hidden = false;
      btn.querySelector('.copy-success').hidden = true;
    }, 2000);
  } catch (err) {
    // Fallback: select text for manual copy
    const range = document.createRange();
    range.selectNodeContents(document.getElementById('installCmd'));
    window.getSelection().removeAllRanges();
    window.getSelection().addRange(range);
  }
}
</script>
```

### Buttondown Newsletter Form
```html
<!-- Source: Buttondown embed docs -->
<form
  action="https://buttondown.com/api/emails/embed-subscribe/USERNAME"
  method="post"
  class="newsletter-form"
>
  <input type="hidden" name="embed" value="1" />
  <input
    type="email"
    name="email"
    placeholder="your@email.com"
    required
    class="newsletter-input"
  />
  <button type="submit" class="newsletter-btn">Subscribe</button>
</form>
```

### GitHub Pages CNAME File
```
director.cc
```

### Meta Tags for SEO and Social Sharing
```html
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Director - Orchestration for Vibe Coders</title>
  <meta name="description" content="Director is an opinionated orchestration framework for solo builders who use AI to build software. From vision to shipped product." />

  <!-- Open Graph -->
  <meta property="og:title" content="Director - Orchestration for Vibe Coders" />
  <meta property="og:description" content="You have the ideas. AI writes the code. Director is the structure between them." />
  <meta property="og:image" content="https://director.cc/assets/og-image.png" />
  <meta property="og:url" content="https://director.cc" />
  <meta property="og:type" content="website" />

  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="Director - Orchestration for Vibe Coders" />
  <meta name="twitter:description" content="You have the ideas. AI writes the code. Director is the structure between them." />
  <meta name="twitter:image" content="https://director.cc/assets/og-image.png" />

  <!-- Favicon -->
  <link rel="icon" type="image/png" href="assets/favicon.png" />

  <!-- Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet" />
</head>
```

### Dark Mode Color System
```css
/* Source: Material Design dark theme guidelines + research findings */
:root {
  /* Background layers (darkest to lightest) */
  --color-bg-base: #0A0A0A;          /* Page background */
  --color-bg-elevated: #141414;       /* Terminal window, cards */
  --color-bg-surface: #1C1C1C;       /* Hover states, active nav */
  --color-bg-overlay: rgba(255, 255, 255, 0.04); /* Subtle separators */

  /* Text hierarchy */
  --color-text-primary: #EDEDED;      /* Headings, important text */
  --color-text-secondary: #A1A1A1;    /* Body text, descriptions */
  --color-text-muted: #666666;        /* Captions, labels */

  /* Accent */
  --color-accent: #3B82F6;            /* CTAs, links, highlights */
  --color-accent-hover: #2563EB;      /* Hover state */
  --color-accent-subtle: rgba(59, 130, 246, 0.12); /* Accent backgrounds */

  /* Borders */
  --color-border: rgba(255, 255, 255, 0.08);
  --color-border-accent: rgba(59, 130, 246, 0.3);
}
```

## Discretionary Recommendations

These are recommendations for the areas left to Claude's discretion.

### Accent Color: Electric Blue (#3B82F6)
**Recommendation:** Use Tailwind's blue-500 (`#3B82F6`) as the accent color.
**Rationale:**
- Achieves 4.6:1 contrast ratio against `#0A0A0A` (passes WCAG AA for large text)
- Pops vibrantly against dark backgrounds without feeling garish
- Complements the monochrome black/white logo by adding a single bold color dimension
- Associated with trust, technology, and professionalism -- fits the "confidence" emotional hook
- Works for both CTA buttons (solid fill) and subtle highlights (low-opacity background)
- Avoids green (too "terminal hacker"), red (too aggressive), orange (too playful), purple (too creative-agency)
**Confidence:** MEDIUM -- this is a subjective design choice, but it follows dark-mode UI conventions and contrast requirements.

### Typography: Inter for Everything
**Recommendation:** Use Inter variable font for all text (body, headings, navigation). Use JetBrains Mono for terminal/code content.
**Rationale:**
- Inter is a geometric sans-serif designed for screens, matching the logo's geometric character
- Variable font means one file serves all weights (400-800), reducing load time
- Inter at weight 800 creates bold, impactful headings that match the Stripe/Raycast aesthetic
- JetBrains Mono is crisp, readable at small sizes, and free -- ideal for the terminal animation
- No need for a second display font -- Inter's bold weights are expressive enough for a dark-mode page
**Confidence:** HIGH -- Inter is the industry standard for developer tool landing pages and complements the logo style.

### Motion/Animation Level: Restrained
**Recommendation:** Limit animation to three elements: (1) the terminal walkthrough, (2) section fade-in reveals on scroll, (3) subtle hover transitions on buttons/links. No parallax, no background animations, no complex page transitions.
**Rationale:**
- Stripe and Raycast use restrained motion -- the content is the star, not the effects
- Every animation must serve comprehension, not decoration
- `prefers-reduced-motion` must be respected with all animations disabled
- Performance stays high with no animation libraries
**Confidence:** HIGH -- matches the "bold & expressive through typography and color, not motion" design direction.

### CTA Placement: Hero + Mid-Page + Footer
**Recommendation:** Place the dual CTA (install command + GitHub link) in three locations:
1. **Hero section** -- immediately visible, the primary conversion point
2. **After the terminal walkthrough** -- visitors who just watched the demo are primed to act
3. **Bottom of page / footer** -- visitors who read everything are ready to decide
**Rationale:** Three placements is standard for long-form landing pages. More would feel pushy; fewer would require scrolling back to the top. The Evil Martians study of 100 dev tool landing pages confirms that the best pages include CTAs at natural decision points, not repetitively.
**Confidence:** HIGH -- follows established landing page conversion patterns.

### Prerequisites Section: Yes, Brief
**Recommendation:** Include a small prerequisites note near the install CTA: "Requires Claude Code v1.0.33+" with a link to Claude Code. Keep it one line, not a separate section.
**Rationale:** The target audience may be discovering Director through search or social sharing. Not everyone arriving at director.cc will already have Claude Code installed. A brief prerequisite prevents installation failures and frustration. But it should not be prominent enough to create a barrier -- just a helpful note.
**Confidence:** HIGH -- this is standard for plugin/extension landing pages.

### Section Ordering Below Hero
**Recommendation:**
1. **Hero** -- Tagline, subtext, dual CTA
2. **The Problem** -- What vibe coders struggle with (builds empathy, creates "that's me" moment)
3. **How Director Works** -- Terminal walkthrough animation (onboard -> blueprint -> build), the core loop explained visually
4. **What Director Does** -- Feature breakdown by category (Blueprint/Build/Inspect), command showcase
5. **Why Director** -- Differentiation section (addresses the gap: "Other tools give you AI. Director gives you structure.")
6. **Get Started** -- Install command + GitHub link (mid-page CTA)
7. **Commands** -- Quick reference of all 12 commands with one-line descriptions
8. **Newsletter** -- Email signup (developer's personal newsletter)
9. **Footer** -- Logo, links (GitHub, license), credit
**Confidence:** MEDIUM -- section ordering is subjective, but this follows the narrative arc research recommends: identity -> problem -> solution -> proof -> action.

### Footer Content
**Recommendation:** Minimal footer with: logo (small), link to GitHub repo, MIT license badge, "Built by Noah Rasheta" credit. No sitemap, no multi-column navigation (single page doesn't need it).
**Confidence:** HIGH -- single-page sites need minimal footers.

## Hosting & Deployment

### GitHub Pages Configuration
**Approach:** Use a `site/` directory at the project root as the GitHub Pages publishing source.

**Why not `docs/`:** The existing `docs/` folder contains design documents (PRD, research, competitive analysis). Using it for the website would mix concerns and potentially expose internal design docs.

**Why not a separate branch:** A `gh-pages` branch creates deployment complexity. Keeping the site in the main branch's `site/` folder means changes are visible in PRs, reviewed normally, and deployed on merge.

**Setup steps:**
1. Create `site/` directory with `index.html`, `css/`, `js/`, `assets/`, `CNAME`
2. In GitHub repo Settings > Pages: set Source to "Deploy from a branch", Branch to `main`, Folder to `/site`
3. Set custom domain to `director.cc`
4. DNS: Configure A records pointing to GitHub Pages IPs (185.199.108.153, 185.199.109.153, 185.199.110.153, 185.199.111.153)
5. Enable "Enforce HTTPS"

**Confidence:** HIGH -- verified against GitHub Pages official documentation.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| jQuery for DOM manipulation | Vanilla JS + IntersectionObserver | 2020+ | No library needed for scroll effects |
| Sass/Less preprocessors | CSS custom properties + nesting | 2023+ | No build step needed for variables and nesting |
| `document.execCommand('copy')` | `navigator.clipboard.writeText()` | 2020+ | Async, clean API, requires HTTPS |
| Font Awesome for icons | Inline SVG or CSS | 2022+ | No icon library needed for a few icons |
| Media queries for responsive type | `clamp()` for fluid typography | 2021+ | One declaration scales across all viewports |
| JavaScript smooth scroll libraries | `scroll-behavior: smooth` CSS | 2020+ | CSS-only, no JS needed |
| AOS.js / ScrollReveal | IntersectionObserver + CSS transitions | 2021+ | Native API, no library overhead |

**Deprecated/outdated:**
- `document.execCommand('copy')`: Deprecated, use Clipboard API instead
- jQuery: Not needed for any modern landing page pattern
- Font preloading via `<link rel="preload" as="font">`: Google Fonts handles this; preconnect to the domain is sufficient

## Open Questions

1. **Buttondown username**
   - What we know: Buttondown uses `https://buttondown.com/api/emails/embed-subscribe/USERNAME` as the form action
   - What's unclear: The developer's Buttondown username hasn't been established yet
   - Recommendation: Use a placeholder in the implementation that can be swapped when the account is created. The form structure is correct regardless of username.

2. **OG Image Design**
   - What we know: A 1200x630px PNG is needed for social sharing (Twitter, LinkedIn, etc.)
   - What's unclear: The exact design -- whether to use the logo alone, add the tagline, or create a more elaborate branded image
   - Recommendation: Create a simple OG image with the `/director` wordmark centered on a dark background with the tagline below it. Keep it minimal and on-brand.

3. **Domain DNS Configuration**
   - What we know: director.cc needs A records pointing to GitHub Pages IPs
   - What's unclear: Where the domain is registered and who manages DNS
   - Recommendation: Document the required DNS records in the plan; the developer will configure them with their registrar.

4. **GitHub Pages Source Directory Support**
   - What we know: GitHub Pages supports publishing from `/` (root) or `/docs` of a branch
   - What's unclear: Whether GitHub Pages supports a custom directory like `/site` directly
   - Recommendation: Since GitHub Pages only supports root or `/docs`, the site files should go in the `docs/` folder (moving design docs elsewhere) OR use a GitHub Actions workflow to deploy. The simplest path may be a `gh-pages` branch managed by a simple GitHub Action, or restructuring to use a `site/` directory with a deployment action. **UPDATE:** GitHub Pages natively supports only `/` (root) or `/docs`. For a `/site` directory, a GitHub Actions deployment workflow is needed. Alternatively, place the site in `docs/` and move design documents to a different location like `design/` at the project root.

## Sources

### Primary (HIGH confidence)
- GitHub Pages official docs - custom domain setup, publishing sources, DNS configuration
- MDN Web Docs - Clipboard API, IntersectionObserver API, CSS scroll-behavior
- Google Fonts - Inter and JetBrains Mono availability and usage

### Secondary (MEDIUM confidence)
- Evil Martians "100 dev tool landing pages" study - section structure and conversion patterns
- Raycast.com landing page analysis - section ordering and dark-mode design reference
- Material Design dark theme guidelines - color choices, background values, desaturation
- Buttondown documentation - embed form structure and API endpoint
- W3Schools, CSS-Tricks, FreeCodeCamp - CSS smooth scroll, sticky header, Intersection Observer patterns

### Tertiary (LOW confidence)
- termynal.js GitHub repo - terminal animation inspiration (used for pattern reference, not as dependency)
- Various landing page design galleries (Lapa Ninja, SaaS Landing Page) - design reference only

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Plain HTML/CSS/JS is unambiguously correct for a single static marketing page
- Architecture: HIGH - File structure, CSS patterns, and JS APIs are well-documented standards
- Pitfalls: HIGH - Based on verified browser APIs and GitHub Pages documentation
- Design choices (color, typography): MEDIUM - Subjective but supported by dark-mode design research
- Hosting deployment path: MEDIUM - GitHub Pages `/docs` vs `/site` directory needs resolution (see Open Questions)

**Research date:** 2026-02-09
**Valid until:** 2026-04-09 (60 days -- these are stable technologies with slow change rates)
