# PRD — Elux Dribbble Theme Planner v1

## 1. Product Name
**Elux Dribbble Theme Planner v1**

Alternative internal names:
- Dribbble Topic Engine
- Shot Planner OS
- Elux Theme Prioritizer

## 2. Product Goal
Help Elux Space automatically filter and prioritize Dribbble/Behance themes based on:
- macro themes
- target market
- target country / region
- target publish month

Then generate outputs that are immediately usable by marketing and design:
- ranked niche list
- score per niche
- rationale
- production priority label
- auto-generated shot brief
- auto-generated Dribbble title, description, and tags

The main objective is to reduce founder and marketing review work to a small final approval layer.

## 3. Problem Statement
The current Dribbble shot workflow has 3 main problems:

### 3.1 Weak theme selection
Themes are often too generic, too cheap-looking, or not relevant to Elux’s target buyers.
Examples:
- finance with weak angle
- AI but too generic
- visually nice concepts that do not support inbound demand

### 3.2 Weak brief quality
Designers choose from a theme pool that is too broad, so shots often feel random, unrealistic, or disconnected from real business use cases.

### 3.3 Weak packaging / copywriting
Sometimes the visual is acceptable, but the title, description, and tags are poor.
This causes:
- weak positioning
- low discoverability
- weak SEO / keyword clarity
- lower inbound value

## 4. Target Outcome
A user enters:
- macro themes
- target market
- target country / region
- target month

The system automatically returns:
- best-fit niche shortlist
- production priority
- designer-ready brief
- publish-ready packaging

This should:
- block weak themes early
- stop designers from starting from zero
- improve publishing consistency
- reduce founder review load

## 5. Scope v1

### In Scope
1. Input macro themes
2. Input target market / buyer type
3. Input target country / region
4. Input target publish month
5. Match input to approved theme library
6. Score candidate niches
7. Rank topic recommendations
8. Generate short rationale
9. Generate production priority label
10. Generate shot brief per selected topic
11. Generate Dribbble packaging:
   - title options
   - description draft
   - tags
12. Save runs to history

### Out of Scope
1. AI visual critique from screenshot
2. Auto Figma generation
3. Auto thumbnail scoring
4. External keyword tool integrations
5. Trend scraping from Dribbble / Behance / Google
6. Multi-user approval workflow
7. Designer task assignment
8. Direct publishing to Dribbble

## 6. Primary Users

### Primary User 1 — Marketing Lead
Needs:
- fast theme direction
- shortlist that avoids weak themes
- solid early packaging
- better prioritization by market and timing

### Primary User 2 — Founder
Needs:
- pre-filtered outputs
- visibility into only top recommendations
- positioning and authority control
- much less manual review

### Secondary User — UI Designer
Needs:
- clear brief
- clear product angle
- recommended screens / modules
- visual direction and avoid notes

## 7. Core User Stories

### Marketing
- As a marketing lead, I want to enter macro themes and target market so the system can return the best niche shortlist automatically.
- As a marketing lead, I want country and month to influence results so the selected topics match real demand timing.
- As a marketing lead, I want every ranked topic to include a reason so I can explain the recommendation to the team.

### Founder
- As a founder, I want only filtered topics so my review effort drops to a small final step.
- As a founder, I want packaging drafts so I do not write titles and descriptions from zero.

### Designer
- As a designer, I want generated briefs so I do not guess the product angle.
- As a designer, I want recommended screens and modules so the shot feels realistic and premium.

## 8. Product Principles
1. **Filter first, generate second**
2. **Region + timing matters**
3. **Business relevance over generic beauty**
4. **Premium B2B bias**
5. **Designer should not start from zero**

## 9. Inputs

### Required Inputs
1. **Macro Themes**
   - multi-select or comma-separated
   - examples: finance, healthcare, logistics, HR, real estate, field ops

2. **Target Market**
   - multi-select
   - examples:
     - SaaS founders
     - Product Managers
     - Agencies
     - SMB owners
     - Enterprise buyers

3. **Target Country / Region**
   - multi-select
   - examples:
     - United States
     - United Kingdom
     - Germany
     - Australia
     - United Arab Emirates
     - Saudi Arabia
     - Qatar

4. **Target Publish Month**
   - single select
   - Jan–Dec

### Optional Inputs
1. Output count
2. Platform target:
   - Dribbble
   - Behance
   - Both
3. Product type preference:
   - app
   - website
   - both
4. Style preference:
   - premium
   - enterprise
   - startup-friendly
   - bold
5. Difficulty level:
   - easy
   - medium
   - advanced

## 10. Outputs

### Output A — Ranked Topic List
For each topic:
- niche name
- macro theme
- country fit
- target buyer fit
- score
- recommendation label
- rationale
- warnings

Recommendation labels:
- **Produce Now**
- **Secondary Queue**
- **Experimental**
- **Reject / Low Priority**

### Output B — Topic Detail Card
For selected topic:
- niche title
- why this is recommended
- target user
- core problem
- product concept
- suggested app / website direction
- recommended screens / modules
- visual direction
- avoid notes

### Output C — Dribbble Packaging
For selected topic:
- 3 title options
- 1 short description
- 1 medium description
- tags
- positioning angle

## 11. Functional Requirements

### 11.1 Input Form
System must allow entry of:
- macro themes
- target buyers
- target countries
- target publish month
- optional preferences

### 11.2 Theme Library Matching
System must match macro themes to a pre-approved niche library.

Examples:
- finance → FinOps, billing portal, accounting workflow, SME budgeting
- healthcare → clinic booking, claims companion, queue system
- logistics → dispatch, proof-of-delivery, customs docs, last-mile delivery

### 11.3 Regional Demand Weighting
System must adjust topic score based on region seasonality and month.

Examples:
- US strong in Mar → boost
- Europe in Aug → downweight
- Australia in Jul → boost
- UAE in Nov → strong boost

### 11.4 Scoring Engine
System must compute weighted score using:
- region timing fit
- buyer fit
- visual potential
- authority fit
- business relevance
- discovery potential
- generic penalty

### 11.5 Short Rationale Generation
System must explain briefly why a topic is recommended.

Example:
“Strong fit for US SaaS founders in March due to B2B buying momentum and strong trust-heavy SaaS visual potential.”

### 11.6 Brief Generation
System must generate a production-ready brief for a selected topic.

### 11.7 Copy Packaging Generation
System must generate:
- title options
- short and medium descriptions
- tags

### 11.8 History
System should save previous runs for reuse and review.

## 12. Scoring Logic v1

### Final Score Formula
`Final Score = RegionTimingFit + BuyerFit + VisualPotential + AuthorityFit + BusinessRelevance + DiscoveryPotential - GenericPenalty`

### Suggested Weight
- Region Timing Fit = 20
- Buyer Fit = 20
- Visual Potential = 15
- Authority Fit = 20
- Business Relevance = 15
- Discovery Potential = 10
- Generic Penalty = -15

Final normalized score:
0–100

### Score Meaning
- **85–100** = Produce Now
- **70–84** = Secondary Queue
- **55–69** = Experimental
- **Below 55** = Reject / Low Priority

## 13. Topic Evaluation Criteria

### Region Timing Fit
How suitable the topic is for the selected country and publish month.

### Buyer Fit
How relevant the topic is to the selected target market.

### Visual Potential
How likely the topic can produce a rich, premium-looking UI shot.

### Authority Fit
How strongly the topic makes Elux look capable, premium, and agency-grade.

### Business Relevance
How close the topic is to real buyers with real budget.

### Discovery Potential
How likely the topic can support clear title, description, and tags.

### Generic Penalty
Penalty for themes that are:
- too broad
- too consumerish
- overused
- template-ish
- low-trust
- “Dribbble for Dribbble”

## 14. Hard Rules / Guardrails
System should deprioritize or reject themes such as:
- personal finance tracker
- generic crypto wallet
- generic AI chatbot landing page
- generic to-do app
- basic meditation app
- social media dashboard without clear angle
- banking cards / neon fintech clichés without business context

System should prefer:
- B2B SaaS
- workflows
- operations
- approvals
- field ops
- dashboards with real logic
- service/business use cases
- trust-heavy UI
- admin/product depth
- buyer-facing conversion pages

## 15. User Flow

### Flow A — Create Recommendation Run
1. User opens app
2. User enters macro themes
3. User selects target buyer(s)
4. User selects target country(ies)
5. User selects publish month
6. User clicks generate
7. System scores and ranks topics
8. User sees recommendation list

### Flow B — Open Topic Detail
1. User clicks one recommendation
2. System shows topic detail card
3. System shows rationale, modules, and visual direction

### Flow C — Generate Packaging
1. User selects one topic
2. User clicks generate packaging
3. System returns title, description, and tags

## 16. Screens v1

### 16.1 Home / New Run
Contains:
- macro theme input
- target market input
- target country input
- month select
- optional settings
- generate button

### 16.2 Results Screen
Contains:
- ranked topic list
- score badges
- labels
- short rationale
- filter by recommendation label

### 16.3 Topic Detail Screen
Contains:
- topic overview
- why this topic
- target user
- product concept
- recommended screens/modules
- visual direction
- avoid notes

### 16.4 Packaging Screen
Contains:
- title options
- descriptions
- tags
- export / copy button

### 16.5 Run History
Contains:
- previous runs
- input summary
- generated recommendations

## 17. Data Model v1

### Table: demand_calendar
Fields:
- id
- country
- month
- demand_level
- demand_note
- region
- global_signal

### Table: theme_library
Fields:
- id
- macro_theme
- niche_name
- country_fit
- buyer_fit
- product_type
- website_type
- visual_potential_score
- authority_score
- business_relevance_score
- discovery_score
- generic_penalty
- complexity_level
- notes
- recommended_modules
- avoid_notes

### Table: recommendation_runs
Fields:
- id
- created_at
- input_themes
- input_buyers
- input_countries
- input_month
- input_preferences
- result_json

### Table: topic_recommendations
Fields:
- id
- run_id
- niche_name
- score
- label
- rationale
- detail_json

## 18. Success Metrics v1

### Primary
- Reduction of manual review time by Arya + Dewi

### Secondary
- % of generated topics considered usable
- % of generated topics moved into design production
- reduction in low-quality / too-generic theme selection
- number of reused recommendations from history
- qualitative satisfaction from founder and marketing

### Early Benchmarks
- 70% of top 10 recommendations judged usable
- 50%+ of manual theme discussion removed
- packaging draft accepted with minor edits in at least 60% of cases

## 19. Non-Functional Requirements
- Fast generation response
- Easy export / copy-paste
- Clear score explanation
- No overly academic reasoning
- Output should be concise and team-usable
- Optimized as an internal planning tool first

## 20. Risks

### Risk 1 — Output too generic
Mitigation:
- strong theme library
- hard reject rules
- generic penalty

### Risk 2 — Score sounds smart but is not accurate
Mitigation:
- transparent scoring
- visible rationale
- tunable theme library

### Risk 3 — Country fit is too broad
Mitigation:
- start with curated country-theme mapping
- refine using internal feedback

### Risk 4 — Packaging sounds too AI-generated
Mitigation:
- concise B2B tone
- avoid exaggerated fluff

## 21. V1 Limitations
- not a final design quality checker
- does not guarantee Dribbble virality
- does not replace senior creative judgment
- depends on quality of internal theme library and region mapping

## 22. Future Roadmap

### V2
- screenshot / visual critique
- cover image critique
- stronger SEO / keyword signal
- style profile per region
- duplication detection
- stronger competitor / trend context

### V3
- Figma integration
- designer workflow
- approval workflow
- publish checklist
- content repurposing for LinkedIn / Behance / website case study
