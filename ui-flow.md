# UI Flow — Elux Dribbble Shot Planner v1

## Page Map

```
/                    → Home: New Run (Input Form)
/results/:runId      → Results: Ranked Topic List
/topic/:topicId      → Topic Detail + Brief
/package/:topicId    → Packaging Output
/history             → Run History
```

---

## Page 1: Home — New Run (`/`)

### Purpose
Single entry point. User sets all parameters and hits generate.

### Layout
Full-width centered card (max-w-2xl). Clean, minimal, tool-like feel.

### Sections

#### Header
- App title: "Dribbble Shot Planner"
- Subtitle: "Filter → Score → Brief → Publish"
- Small Elux Space badge

#### Form — Required Inputs

**1. Macro Themes** (multi-select chips)
- Options: Finance, Healthcare, Logistics, HR/Recruitment, Real Estate, Field Ops, Construction, Hospitality, Education, Compliance, Procurement, Cybersecurity, E-commerce, SaaS/General
- Interaction: click to toggle on/off, active chips highlighted
- Minimum: 1 selected

**2. Target Market** (multi-select chips)
- Options: SaaS Founders, Product Managers, Agencies, SMB Owners, Enterprise Buyers
- Minimum: 1 selected

**3. Target Country / Region** (multi-select chips)
- Options: United States, United Kingdom, Germany, Netherlands, France, Sweden, Australia, UAE, Saudi Arabia, Qatar
- Grouped visually by region (Americas / Europe / APAC / Gulf)
- Minimum: 1 selected

**4. Publish Month** (single-select dropdown or horizontal month strip)
- Jan–Dec
- Current month pre-selected
- Visual indicator if selected month is "weak" or "dead" for chosen countries (yellow/red dot)

#### Form — Optional Settings (collapsible "Advanced" section)

**5. Output Count** — slider or number input (3–15, default 10)

**6. Platform** — radio: Dribbble / Behance / Both (default: Dribbble)

**7. Product Type** — radio: App / Website / Both (default: Both)

**8. Style Preference** — single-select: Premium / Enterprise / Startup-friendly / Bold (default: Premium)

**9. Difficulty Level** — single-select: Easy / Medium / Advanced (default: Medium)

#### Action
- **[Generate Recommendations]** button (primary, full-width)
- Disabled until all required inputs have at least 1 selection
- On click → POST /api/runs → loading state → redirect to /results/:runId

### States
- **Empty:** form with defaults
- **Filling:** chips active, month selected
- **Submitting:** button shows spinner, form disabled
- **Error:** toast notification if API fails, form re-enabled

### Demand Hint (subtle)
Below the month selector, show a small inline hint based on current country + month selection:
- "🟢 Strong demand window for US, AU in March"
- "🟡 Mixed demand — AU is strong, UK is weak in August"
- "🔴 Low demand window for all selected regions"

This updates live as user changes country/month selections.

---

## Page 2: Results — Ranked Topic List (`/results/:runId`)

### Purpose
Show scored + ranked recommendations. User can drill into any topic for brief or packaging.

### Layout
Left sidebar (run summary) + main content (ranked list).

### Sections

#### Left Sidebar — Run Summary (sticky, 280px)
- Input recap: themes, buyers, countries, month
- Total results count
- Label distribution (e.g. "3 Produce Now, 4 Secondary, 2 Experimental, 1 Reject")
- **[New Run]** button → back to `/`
- **[View History]** link → `/history`

#### Main Content — Ranked Cards

Each recommendation is a horizontal card:

```
┌──────────────────────────────────────────────────┐
│  #1  FinOps Cloud Cost Control Dashboard    91/100│
│       finance · app · US, AU                      │
│                                                   │
│  ██████████████████░░  Region Timing  19.0/20    │
│  ████████████████████  Buyer Fit      20.0/20    │
│  ████████████████░░░░  Visual         12.8/15    │
│  ██████████████████░░  Authority      18.0/20    │
│  █████████████████░░░  Business       13.5/15    │
│  ████████████░░░░░░░░  Discovery       8.5/10    │
│  ░░░░░░░░░░░░░░░░░░░░  Penalty        -0.8      │
│                                                   │
│  "Strong fit for US SaaS founders in March..."   │
│                                                   │
│  [🟢 Produce Now]                                │
│                                                   │
│  [Generate Brief]  [Generate Packaging]  [Expand] │
└──────────────────────────────────────────────────┘
```

#### Card Components
- **Rank number** — large, bold
- **Niche name** — title
- **Score** — large number + /100
- **Meta tags** — macro_theme, product_type, country_fit (small pills)
- **Score breakdown** — mini horizontal bar chart per criterion
- **Rationale** — 1–2 lines, gray text
- **Label badge** — color coded:
  - Produce Now → green
  - Secondary Queue → blue
  - Experimental → amber
  - Reject → red/gray
- **Warning** — if present, yellow inline alert
- **Actions:**
  - [Generate Brief] → navigates to `/topic/:topicId`
  - [Generate Packaging] → navigates to `/package/:topicId`
  - [Expand] → toggles showing full score breakdown inline

#### Filters (top bar, above cards)
- Filter by label: All / Produce Now / Secondary / Experimental / Reject
- Sort: Score (default) / Alphabetical / Region Fit

### States
- **Loading:** skeleton cards (3–5 placeholder shimmer cards)
- **Loaded:** full list
- **Empty:** "No themes matched. Try broadening your inputs." + [Back to New Run]
- **Partial AI failure:** scores show, rationale shows "Generating..." or "[Retry]"

---

## Page 3: Topic Detail + Brief (`/topic/:topicId`)

### Purpose
Deep dive into one topic. Shows full brief for the designer.

### Layout
Single column, max-w-3xl centered. Print-friendly.

### Sections

#### Header
- Back link → /results/:runId
- Niche name (h1)
- Score badge + label badge
- Meta: macro theme, countries, buyers, month

#### Score Breakdown (visual)
- Radar chart or horizontal stacked bar showing all 7 criteria
- Hover/tap for exact values

#### Rationale
- Full rationale text (AI-generated)

#### Brief Section

If `brief_json` is null → show **[Generate Brief]** button.
On click → POST /api/topics/:id/brief → loading spinner → render brief.

Once generated:

```
┌─ Brief ──────────────────────────────────────────┐
│                                                   │
│  Target User                                      │
│  Startup CFOs and finance ops leads managing      │
│  multi-cloud infrastructure budgets               │
│                                                   │
│  Core Problem                                     │
│  Cloud costs spiral without real-time visibility  │
│  across AWS, GCP, and Azure                       │
│                                                   │
│  Product Concept                                  │
│  FinOps dashboard that consolidates cloud spend,  │
│  flags anomalies, and sets team-level budgets     │
│                                                   │
│  Must-Have Modules                                │
│  ┌────────────────────────────────────────────┐  │
│  │ • Cost Overview (multi-cloud summary)      │  │
│  │ • Anomaly Alerts (spike detection)         │  │
│  │ • Team Breakdown (dept-level attribution)  │  │
│  │ • Budget Caps (threshold + notification)   │  │
│  │ • Forecast Panel (30/60/90 day projection) │  │
│  │ • Recommendation Engine (right-sizing)     │  │
│  └────────────────────────────────────────────┘  │
│                                                   │
│  Visual Direction                                 │
│  Dark mode primary. Dense data layout. Trust      │
│  heavy typography. Subtle green/red for deltas.   │
│                                                   │
│  Avoid                                            │
│  • Decorative illustrations                       │
│  • Neon gradients                                 │
│  • Generic bar charts with no labels              │
│  • Stock avatar cards                             │
│                                                   │
└───────────────────────────────────────────────────┘
```

#### Actions (bottom)
- **[Copy Brief]** — copies formatted markdown to clipboard
- **[Generate Packaging]** → navigates to /package/:topicId
- **[Back to Results]**

### States
- **Loading topic:** skeleton
- **Brief not generated:** CTA button visible
- **Generating brief:** spinner inside brief section
- **Brief loaded:** full render
- **AI error:** "Failed to generate. [Retry]"

---

## Page 4: Packaging Output (`/package/:topicId`)

### Purpose
Generate and display publish-ready Dribbble copy for the selected topic.

### Layout
Single column, max-w-3xl centered. Optimized for copy-paste.

### Sections

#### Header
- Back link → /topic/:topicId or /results/:runId
- Niche name
- Label badge

#### Packaging Section

If `package_json` is null → show **[Generate Packaging]** button.
On click → POST /api/topics/:id/package → loading → render.

Once generated:

```
┌─ Packaging ──────────────────────────────────────┐
│                                                   │
│  Title Options                                    │
│  1. FinOps Dashboard for Cloud Cost Control       │  [Copy]
│  2. Cloud Spend Management Platform for Startups  │  [Copy]
│  3. Multi-Cloud Budget Tracker and Anomaly Hub    │  [Copy]
│                                                   │
│  Short Description                                │
│  A FinOps dashboard that helps startup teams      │  [Copy]
│  monitor, allocate, and control multi-cloud       │
│  infrastructure costs in real time.               │
│                                                   │
│  Medium Description                               │
│  Designed for startup CFOs and finance ops leads  │  [Copy]
│  managing AWS, GCP, and Azure budgets. Features   │
│  anomaly detection, team-level cost attribution,  │
│  budget cap alerts, and 90-day spend forecasting. │
│  Built to reduce cloud cost surprises and give    │
│  leadership clear financial visibility.           │
│                                                   │
│  Tags                                             │
│  ┌──────┬──────────┬──────────┬───────────┐      │
│  │finops│cloud cost│dashboard │saas       │      │
│  │b2b   │startup   │budget    │operations │      │
│  │ui/ux │web app   │analytics │finance ops│      │
│  └──────┴──────────┴──────────┴───────────┘      │
│                                              [Copy All]
│                                                   │
│  Positioning Angle                                │
│  "Trust-heavy operational tool for startup        │
│  finance teams — not another generic fintech UI"  │
│                                                   │
└───────────────────────────────────────────────────┘
```

#### Actions
- Individual **[Copy]** buttons per section
- **[Copy All]** — copies entire packaging as formatted text
- **[Regenerate]** — re-calls OpenAI for a fresh version
- **[Back to Brief]** / **[Back to Results]**

### States
- Same pattern as Brief page (not generated → CTA → loading → rendered → error/retry)

---

## Page 5: Run History (`/history`)

### Purpose
Browse previous runs. Quick re-entry to past results.

### Layout
Full-width table or card list.

### Sections

#### Header
- "Run History"
- **[New Run]** button

#### History List

Each row / card:

```
┌──────────────────────────────────────────────────┐
│  Mar 8, 2026 · 10:15 AM                          │
│                                                   │
│  Themes: Finance, Logistics                       │
│  Buyers: SaaS Founders, SMB Owners                │
│  Countries: US, AU                                │
│  Month: March                                     │
│                                                   │
│  Results: 10 topics                               │
│  🟢 3 Produce Now  🔵 4 Secondary  🟡 2 Exp  🔴 1│
│                                                   │
│  [View Results]                          [Delete] │
└──────────────────────────────────────────────────┘
```

#### Features
- Sort by date (newest first, default)
- Delete run (with confirmation modal)
- Click → navigate to /results/:runId

### States
- **Loading:** skeleton rows
- **Empty:** "No runs yet. Start your first one." + [New Run]
- **Loaded:** list of runs

---

## Global UI Components

### Navigation Bar (top, persistent)
- Logo / App name (left)
- Nav links: New Run, History (center or right)
- Small "Powered by Elux Space" badge

### Toast Notifications
- Success: green, auto-dismiss 3s
- Error: red, persistent until dismissed
- Info: blue, auto-dismiss 5s

### Loading States
- Skeleton shimmer for cards/lists
- Inline spinner for AI generation
- Full-page spinner only on initial app load

### Copy Feedback
- On any [Copy] action → toast "Copied to clipboard" + brief button text change to "Copied ✓" for 2s

### Responsive Behavior
- Desktop: sidebar + main layout on results page
- Tablet: sidebar collapses to top summary bar
- Mobile: single column, stacked cards, collapsible score breakdowns

---

## User Flow Diagram

```
                    ┌─────────┐
                    │  Home   │
                    │  (/)    │
                    └────┬────┘
                         │
                    Fill inputs
                    Click Generate
                         │
                    ┌────▼────┐
                    │ Results │
                    │ /:runId │
                    └──┬───┬──┘
                       │   │
          ┌────────────┘   └────────────┐
          │                             │
     Click topic                   Click packaging
     "Generate Brief"              "Generate Packaging"
          │                             │
     ┌────▼─────┐                 ┌─────▼──────┐
     │  Topic   │                 │  Packaging  │
     │ /:topicId│────────────────▶│  /:topicId  │
     └────┬─────┘  Click          └──────┬──────┘
          │        "Gen Packaging"       │
          │                              │
          └──────────┐  ┌────────────────┘
                     │  │
                     ▼  ▼
               Copy outputs
               Start new run
               Browse history
                     │
               ┌─────▼─────┐
               │  History   │
               │  /history  │
               └────────────┘
```

---

## Design Notes

### Visual Style
- Dark neutral base (#0F1117) with white/light gray text
- Accent: teal or blue-green for primary actions and "Produce Now" labels
- Score bars use muted color gradient (gray → accent)
- Cards: subtle border, slight shadow, rounded-lg
- Typography: clean sans-serif (Satoshi, General Sans, or similar)
- Minimal chrome — this is a tool, not a marketing site

### Spacing
- Consistent 16/24/32px spacing rhythm
- Cards: 24px internal padding
- Sections: 48px vertical gap between major sections

### Interaction Patterns
- Chip selectors use immediate toggle (no submit needed per chip)
- Score breakdown bars animate on load (subtle, 300ms ease-out)
- Copy buttons show instant feedback
- AI generation shows pulsing dots or typing indicator
- Page transitions use simple fade (no heavy animations)
