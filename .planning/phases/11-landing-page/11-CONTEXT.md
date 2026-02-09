# Phase 11: Landing Page - Context

**Gathered:** 2026-02-09
**Status:** Ready for planning

<domain>
## Phase Boundary

Design and create the director.cc homepage — a single-page marketing site that communicates what Director is, who it's for, and how to get started. The page drives two conversions: install the plugin and explore the GitHub repo.

</domain>

<decisions>
## Implementation Decisions

### Page structure
- Long-form single page with sticky anchor navigation
- Bold tagline hero (punchy identity line + supporting subtext + CTA)
- 7+ sections telling the full story — visitors want to understand the tool completely before installing
- Animated terminal walkthrough showing Director's workflow (onboard → blueprint → build)
- Each section earns its spot — comprehensive but scannable, not walls of text

### Visual identity
- Bold & expressive design feel — strong colors, large type, personality-driven (think Stripe, Raycast)
- Dark mode only — dark background throughout, terminal content pops naturally
- Neutral base (black/white/gray) with one bold accent color for CTAs and highlights
- Logo assets exist: `/director` wordmark and `/d` square mark in dark/light variants at `docs/logos/`
- Favicon/icon: use the `/d` square dark variant

### Messaging & audience
- Lead with aspiration: describe the persona first ("You have the ideas. AI writes the code."), then introduce the vibe coder identity as something they're becoming
- Target entrepreneurs who want confidence that they can build their ideas — empowering, not gatekeeping
- Core emotional hook: **confidence** — "I can actually build this"
- Light technical flavor — mostly plain language, but terms like "plugin", "commands", "CLI" are fine where natural
- Subtle differentiation from competitors — don't name them, but address the gap ("Other tools give you AI. Director gives you structure.")

### Conversion & CTAs
- Two equal primary actions: install command (copy-paste) and GitHub repo link
- Install command and GitHub link both prominent — ready visitors install, curious ones explore
- Optional email signup near bottom for developer's personal newsletter (not Director-specific)
  - Framed as the developer's newsletter for cross-promoting future plugins
  - Non-intrusive — small section, no popups, no gates
  - Service: Buttondown, ConvertKit, or similar (Claude's discretion)

### Claude's Discretion
- Specific accent color (must pop against dark sections and complement the monochrome logo)
- Typography choices (complement the bold geometric sans-serif logo)
- Motion/animation level (beyond the terminal walkthrough)
- CTA placement frequency across the long-form page
- Whether to include brief prerequisites ("You'll need Claude Code") or assume visitors already have it
- Section ordering below the hero
- Footer content

</decisions>

<specifics>
## Specific Ideas

- "Entrepreneurs will resonate with the messaging that 'you have the ideas', and this platform will give them the confidence that they can become vibe coders and make their ideas reality"
- Email list serves dual purpose: Director updates AND future plugin announcements under the developer's personal brand (not director.cc domain)
- Terminal animation should demonstrate the core loop: onboard → blueprint → build
- Page should feel like Stripe or Raycast — opinionated and confident, not generic SaaS

</specifics>

<deferred>
## Deferred Ideas

- Multi-page site structure (docs, blog, etc.) — future iteration if needed
- User testimonials / social proof section — needs real users first
- Pricing page — Director is free, but future plugins may not be

</deferred>

---

*Phase: 11-landing-page*
*Context gathered: 2026-02-09*
