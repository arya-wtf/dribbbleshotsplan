# spec.md — Elux Dribbble Shot Planner v1

## 1. Overview

A full-stack internal tool for Elux Space that filters, scores, ranks, and packages Dribbble/Behance shot themes. Users input macro parameters and receive scored recommendations, designer-ready briefs, and publish-ready copy — all powered by a local scoring engine + OpenAI API for brief/packaging generation.

---

## 2. Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | React 18 + TypeScript + Tailwind CSS |
| State | React Context + useReducer |
| Backend API | Next.js API Routes (or Express if standalone) |
| Database | SQLite via `better-sqlite3` |
| AI Layer | OpenAI API (`gpt-4o` or `gpt-4o-mini`) |
| Deployment | Vercel (frontend + serverless API routes) |
| ORM / Query | Drizzle ORM (lightweight, SQLite-native) |

> **Note on Vercel + SQLite:** For production, use Turso (libSQL) as the hosted SQLite provider. For local dev, use `better-sqlite3` directly. Drizzle ORM supports both seamlessly.

---

## 3. Architecture

```
┌─────────────────────────────────────────────┐
│                   Frontend                   │
│  React + TypeScript + Tailwind               │
│                                              │
│  Pages:                                      │
│  ├── /              → New Run (Input Form)   │
│  ├── /results/:id   → Ranked Results         │
│  ├── /topic/:id     → Topic Detail + Brief   │
│  ├── /package/:id   → Packaging Output       │
│  └── /history       → Run History            │
└──────────────────┬──────────────────────────┘
                   │ API calls
┌──────────────────▼──────────────────────────┐
│              API Layer (Next.js)              │
│                                              │
│  POST /api/runs          → create new run    │
│  GET  /api/runs          → list all runs     │
│  GET  /api/runs/:id      → get run + results │
│  POST /api/runs/:id/brief   → generate brief │
│  POST /api/runs/:id/package → generate copy  │
│  GET  /api/themes        → list theme library│
│  GET  /api/calendar      → demand calendar   │
└──────┬──────────────┬───────────────────────┘
       │              │
┌──────▼──────┐ ┌─────▼──────┐
│   SQLite    │ │  OpenAI    │
│  (Turso)    │ │  API       │
│             │ │            │
│ theme_lib   │ │ Brief gen  │
│ demand_cal  │ │ Package gen│
│ runs        │ │ Rationale  │
│ topics      │ │            │
└─────────────┘ └────────────┘
```

---

## 4. Database Schema

### 4.1 `theme_library`

Seed data — the curated niche library.

```sql
CREATE TABLE theme_library (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  macro_theme     TEXT NOT NULL,          -- e.g. "finance", "healthcare"
  niche_name      TEXT NOT NULL,          -- e.g. "FinOps Cloud Cost Control Dashboard"
  country_fit     TEXT NOT NULL,          -- JSON array: ["US", "UK", "DE"]
  buyer_fit       TEXT NOT NULL,          -- JSON array: ["SaaS founders", "PMs"]
  product_type    TEXT DEFAULT 'both',    -- "app" | "website" | "both"
  visual_potential    INTEGER DEFAULT 70, -- 0–100
  authority_score     INTEGER DEFAULT 70,
  business_relevance  INTEGER DEFAULT 70,
  discovery_score     INTEGER DEFAULT 70,
  generic_penalty     INTEGER DEFAULT 0,  -- 0–100 (higher = more generic)
  complexity_level    TEXT DEFAULT 'medium', -- "easy" | "medium" | "advanced"
  recommended_modules TEXT,               -- JSON array of strings
  avoid_notes         TEXT,
  notes               TEXT,
  created_at      DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### 4.2 `demand_calendar`

Seed data — monthly demand by region.

```sql
CREATE TABLE demand_calendar (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  country       TEXT NOT NULL,        -- e.g. "US", "UK", "AU", "UAE"
  region        TEXT NOT NULL,        -- e.g. "North America", "Europe", "APAC", "Gulf"
  month         INTEGER NOT NULL,     -- 1–12
  demand_level  TEXT NOT NULL,        -- "peak" | "strong" | "medium" | "weak" | "dead"
  demand_note   TEXT,
  demand_score  INTEGER NOT NULL      -- numeric: peak=95, strong=80, medium=60, weak=35, dead=15
);
```

### 4.3 `recommendation_runs`

Stores each generation session.

```sql
CREATE TABLE recommendation_runs (
  id              TEXT PRIMARY KEY,      -- UUID
  created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
  input_themes    TEXT NOT NULL,         -- JSON array
  input_buyers    TEXT NOT NULL,         -- JSON array
  input_countries TEXT NOT NULL,         -- JSON array
  input_month     INTEGER NOT NULL,
  input_preferences TEXT,               -- JSON object (optional fields)
  status          TEXT DEFAULT 'completed'
);
```

### 4.4 `topic_recommendations`

Stores scored results per run.

```sql
CREATE TABLE topic_recommendations (
  id              TEXT PRIMARY KEY,      -- UUID
  run_id          TEXT NOT NULL REFERENCES recommendation_runs(id),
  niche_name      TEXT NOT NULL,
  macro_theme     TEXT NOT NULL,
  score           REAL NOT NULL,
  label           TEXT NOT NULL,         -- "Produce Now" | "Secondary Queue" | "Experimental" | "Reject"
  rationale       TEXT,
  warnings        TEXT,
  country_fit     TEXT,                  -- JSON
  buyer_fit_detail TEXT,                 -- JSON
  score_breakdown TEXT,                  -- JSON object with per-criterion scores
  brief_json      TEXT,                  -- generated brief (nullable, filled on demand)
  package_json    TEXT,                  -- generated packaging (nullable, filled on demand)
  created_at      DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

---

## 5. Scoring Engine Logic

The scoring engine runs server-side in the API route. It is deterministic (no AI needed).

### 5.1 Input

```typescript
interface RunInput {
  themes: string[];          // ["finance", "healthcare"]
  buyers: string[];          // ["SaaS founders", "PMs"]
  countries: string[];       // ["US", "AU"]
  month: number;             // 1–12
  preferences?: {
    outputCount?: number;    // default 10
    platform?: "dribbble" | "behance" | "both";
    productType?: "app" | "website" | "both";
    style?: "premium" | "enterprise" | "startup-friendly" | "bold";
    difficulty?: "easy" | "medium" | "advanced";
  };
}
```

### 5.2 Step 1 — Filter Theme Library

```typescript
// Pseudo-code
const candidates = themeLibrary.filter(theme => {
  // Must match at least one input macro_theme
  const themeMatch = input.themes.some(t =>
    theme.macro_theme.toLowerCase().includes(t.toLowerCase())
  );
  if (!themeMatch) return false;

  // Must fit at least one input country
  const countryFit = JSON.parse(theme.country_fit);
  const countryMatch = input.countries.some(c => countryFit.includes(c));
  if (!countryMatch) return false;

  // Must fit at least one input buyer
  const buyerFit = JSON.parse(theme.buyer_fit);
  const buyerMatch = input.buyers.some(b =>
    buyerFit.some(bf => bf.toLowerCase().includes(b.toLowerCase()))
  );
  if (!buyerMatch) return false;

  // Optional: product type filter
  if (input.preferences?.productType && input.preferences.productType !== "both") {
    if (theme.product_type !== "both" && theme.product_type !== input.preferences.productType) {
      return false;
    }
  }

  // Optional: difficulty filter
  if (input.preferences?.difficulty) {
    if (theme.complexity_level !== input.preferences.difficulty) return false;
  }

  return true;
});
```

### 5.3 Step 2 — Score Each Candidate

```typescript
function scoreTheme(theme: ThemeRow, input: RunInput, demandCalendar: DemandRow[]): ScoredTheme {

  // 1. Region Timing Fit (weight: 20)
  // Average demand_score across all input countries for input month
  const demandScores = input.countries.map(country => {
    const entry = demandCalendar.find(d => d.country === country && d.month === input.month);
    return entry ? entry.demand_score : 50; // fallback neutral
  });
  const avgDemand = demandScores.reduce((a, b) => a + b, 0) / demandScores.length;
  const regionTimingFit = (avgDemand / 100) * 20;

  // 2. Buyer Fit (weight: 20)
  const buyerFitArr = JSON.parse(theme.buyer_fit);
  const buyerMatchCount = input.buyers.filter(b =>
    buyerFitArr.some(bf => bf.toLowerCase().includes(b.toLowerCase()))
  ).length;
  const buyerFitScore = (buyerMatchCount / Math.max(input.buyers.length, 1)) * 20;

  // 3. Visual Potential (weight: 15)
  const visualScore = (theme.visual_potential / 100) * 15;

  // 4. Authority Fit (weight: 20)
  const authorityScore = (theme.authority_score / 100) * 20;

  // 5. Business Relevance (weight: 15)
  const businessScore = (theme.business_relevance / 100) * 15;

  // 6. Discovery Potential (weight: 10)
  const discoveryScore = (theme.discovery_score / 100) * 10;

  // 7. Generic Penalty (max: -15)
  const genericPenalty = (theme.generic_penalty / 100) * 15;

  const finalScore = Math.round(
    regionTimingFit + buyerFitScore + visualScore +
    authorityScore + businessScore + discoveryScore - genericPenalty
  );

  const clampedScore = Math.max(0, Math.min(100, finalScore));

  return {
    ...theme,
    score: clampedScore,
    label: getLabel(clampedScore),
    scoreBreakdown: {
      regionTimingFit: Math.round(regionTimingFit * 10) / 10,
      buyerFit: Math.round(buyerFitScore * 10) / 10,
      visualPotential: Math.round(visualScore * 10) / 10,
      authorityFit: Math.round(authorityScore * 10) / 10,
      businessRelevance: Math.round(businessScore * 10) / 10,
      discoveryPotential: Math.round(discoveryScore * 10) / 10,
      genericPenalty: Math.round(genericPenalty * 10) / 10,
    }
  };
}

function getLabel(score: number): string {
  if (score >= 85) return "Produce Now";
  if (score >= 70) return "Secondary Queue";
  if (score >= 55) return "Experimental";
  return "Reject";
}
```

### 5.4 Step 3 — Rank and Return

```typescript
const ranked = scored
  .sort((a, b) => b.score - a.score)
  .slice(0, input.preferences?.outputCount || 10);
```

---

## 6. AI Generation Layer (OpenAI)

Used for three on-demand tasks. The system prompt from `system-prompt.md` is injected as the system message.

### 6.1 Rationale Generation

Triggered during scoring (lightweight, can use `gpt-4o-mini`).

```typescript
// Prompt
`Generate a 1-2 sentence rationale for why "${niche_name}" is a ${label} recommendation
for ${countries.join(", ")} in ${monthName}, targeting ${buyers.join(", ")}.
Score: ${score}/100. Be direct, commercial, no fluff.`
```

### 6.2 Brief Generation

Triggered when user clicks "Generate Brief" on a topic.

```typescript
// Prompt
`Generate a production-ready designer brief for: "${niche_name}"

Target market: ${buyers.join(", ")}
Target country: ${countries.join(", ")}
Month: ${monthName}

Return JSON:
{
  "target_user": "...",
  "core_problem": "...",
  "product_concept": "...",
  "must_have_modules": ["...", "..."],   // 5-8 realistic, specific modules
  "visual_direction": "...",
  "avoid": ["...", "..."]
}

Modules must feel like real product screens. No filler (no random profile cards, decorative stats, meaningless charts).`
```

### 6.3 Packaging Generation

Triggered when user clicks "Generate Packaging" on a topic.

```typescript
// Prompt
`Generate Dribbble publish packaging for: "${niche_name}"

Return JSON:
{
  "title_options": ["...", "...", "..."],
  "short_description": "...",
  "medium_description": "...",
  "tags": ["...", "...", "..."],        // 8-12 tags
  "positioning_angle": "..."
}

Titles: clear, buyer-readable, no hype words, no "Modern Dashboard Exploration".
Descriptions: practical, mention target users, no adjective overload.
Tags: niche + product type + buyer context + UI category + industry keywords.`
```

---

## 7. API Routes

| Method | Route | Description |
|--------|-------|-------------|
| `POST` | `/api/runs` | Create new run → filter, score, rank, save to DB, return results |
| `GET` | `/api/runs` | List all runs (history), ordered by `created_at` desc |
| `GET` | `/api/runs/[id]` | Get single run + all topic recommendations |
| `POST` | `/api/topics/[id]/brief` | Generate brief via OpenAI, save to `brief_json` |
| `POST` | `/api/topics/[id]/package` | Generate packaging via OpenAI, save to `package_json` |
| `GET` | `/api/themes` | List full theme library (for admin/debug) |
| `GET` | `/api/calendar` | List full demand calendar (for admin/debug) |

### Request/Response Examples

**POST /api/runs**

Request:
```json
{
  "themes": ["finance", "logistics"],
  "buyers": ["SaaS founders", "SMB owners"],
  "countries": ["US", "AU"],
  "month": 3,
  "preferences": {
    "outputCount": 10,
    "platform": "dribbble",
    "productType": "both",
    "style": "premium"
  }
}
```

Response:
```json
{
  "run_id": "uuid-xxx",
  "created_at": "2026-03-08T10:00:00Z",
  "recommendations": [
    {
      "id": "uuid-yyy",
      "niche_name": "FinOps Cloud Cost Control Dashboard",
      "macro_theme": "finance",
      "score": 91,
      "label": "Produce Now",
      "rationale": "Strong fit for US SaaS founders in March...",
      "warnings": null,
      "score_breakdown": {
        "regionTimingFit": 19.0,
        "buyerFit": 20.0,
        "visualPotential": 12.8,
        "authorityFit": 18.0,
        "businessRelevance": 13.5,
        "discoveryPotential": 8.5,
        "genericPenalty": 0.8
      }
    }
  ]
}
```

---

## 8. Environment Variables

```env
# .env.local
OPENAI_API_KEY=sk-...
DATABASE_URL=file:./data/elux-shots.db    # local dev
TURSO_DATABASE_URL=libsql://...            # production
TURSO_AUTH_TOKEN=...                       # production
```

---

## 9. Seed Data Strategy

On first deploy / DB migration, seed:

1. **theme_library** — ~60 rows from the Knowledge doc's Theme Library Seed (US, UK, DE, NL, FR, SE, AU, UAE, SA, QA), each with pre-assigned scores for visual_potential, authority_score, business_relevance, discovery_score, generic_penalty, and country/buyer fit arrays.

2. **demand_calendar** — ~48 rows (4 regions × 12 months) with demand_level and demand_score derived from the Knowledge doc's Demand Calendar Seed.

Seed script: `scripts/seed.ts` — runs via `npx tsx scripts/seed.ts`.

---

## 10. Key Business Rules (Enforced in Code)

1. Themes with `generic_penalty > 60` are auto-labeled "Experimental" max, regardless of other scores.
2. If ALL input countries are in "dead" or "weak" demand for the input month, append a warning: "Low regional demand window — consider shifting publish month."
3. Maximum 15 recommendations per run (even if library produces more matches).
4. Brief and Packaging are generated lazily (on-demand), not during initial scoring.
5. Rationale is generated during scoring via a lightweight AI call (can be batched).
6. Run history is kept indefinitely — no auto-cleanup.

---

## 11. Error Handling

| Scenario | Behavior |
|----------|----------|
| No theme matches found | Return empty results + message: "No themes matched your filters. Try broadening macro themes or country selection." |
| OpenAI API fails | Return error toast + allow retry. Score results still show (they don't depend on AI). |
| OpenAI returns invalid JSON | Parse with fallback: try `JSON.parse`, then regex extract JSON block, then return raw text with warning. |
| DB write fails | Return 500 + log error. Frontend shows retry option. |

---

## 12. Deployment Notes (Vercel)

- Use **Turso** as the SQLite provider (Vercel serverless doesn't support file-based SQLite in production).
- API routes run as serverless functions.
- Seed data via a one-time migration script or Turso CLI.
- OpenAI calls use `gpt-4o-mini` for rationale (fast, cheap) and `gpt-4o` for brief/packaging (quality matters).
- Add rate limiting on `/api/runs` (max 20 runs/hour per session) to control OpenAI spend.
