# SRAST Development Log

## Repository Status

SRAST is currently an early-stage executable prototype built on top of the AIDE architecture.

Current state:
- SQLite-backed
- Protocol-driven
- Deterministic adjudication
- Minimal Shiny UI operational
- Structured JSON parsing implemented
- Initial testing infrastructure added

---

# Implemented Components

## 1. SQLite Database Layer

File:
```text
R/db.R
```

Implemented function:
```r
initialize_database()
```

Current database tables:

### references
Stores imported citations.

Columns:
- id
- title
- abstract
- doi
- authors
- year
- journal
- source_file
- screening_status
- decision
- confidence
- created_at

### protocols
Stores protocol metadata.

Columns:
- id
- name
- version
- sha256
- json
- created_at

### screening_results
Stores question-level LLM extraction results.

Columns:
- id
- reference_id
- question_id
- answer
- confidence
- evidence
- model
- created_at

### overrides
Stores human overrides.

Columns:
- id
- reference_id
- human_decision
- reviewer
- reason
- created_at

Current limitations:
- No indexing yet
- No migration system yet
- No transaction batching yet

---

# 2. Protocol Engine

File:
```text
R/protocol_engine.R
```

Implemented functions:
- load_protocol()
- validate_protocol()
- filter_questions_by_phase()

Current protocol requirements:

Required top-level fields:
- name
- version
- questions

Required question-level fields:
- id
- text
- phase
- type

Current supported phases:
- initial

Current supported question types:
- boolean

Current limitations:
- No nested logic
- No exclusion-rule DSL
- No schema versioning
- No conditional branching
- No multi-select questions

---

# 3. Decision Engine

File:
```text
R/decision_engine.R
```

Implemented function:
```r
apply_decision_rules()
```

Current deterministic logic:

Rules:
1. Any FALSE answer → exclude
2. Any confidence below threshold → doubt
3. Otherwise → include

Default confidence threshold:
```r
0.70
```

Important architectural rule:
- LLM never determines final inclusion/exclusion.
- Decision engine alone determines verdict.

Current limitations:
- No weighted rules
- No question-specific thresholds
- No hierarchical exclusion logic
- No reviewer conflict handling

---

# 4. Import Engine

File:
```text
R/import_engine.R
```

Implemented functions:
- import_csv_references()
- get_unscreened_references()

Current supported import format:
- CSV only

Current required CSV columns:
```text
title
abstract
```

Example valid CSV:
```csv
title,abstract
Study title,Study abstract
```

Automatically added fields:
- screening_status = unscreened
- decision = NA
- confidence = NA

Current limitations:
- No RIS support yet
- No BibTeX support yet
- No PMID parsing
- No DOI normalization
- No deduplication yet
- No schema mapping UI

---

# 5. LLM Layer

File:
```text
R/llm_caller.R
```

Implemented functions:
- build_screening_prompt()
- parse_llm_json()

Current capabilities:
- Protocol-aware prompt construction
- Structured JSON parsing
- Strict answers-field validation

Current expected LLM output schema:

```json
{
  "answers": [
    {
      "question_id": "human_population",
      "answer": true,
      "confidence": 0.95,
      "evidence": "Adults with diabetes"
    }
  ]
}
```

Current limitations:
- No real API calls yet
- No retry system
- No malformed JSON repair
- No provider abstraction yet
- No token accounting
- No batching yet
- No async execution

---

# 6. Screening Engine

File:
```text
R/screening_engine.R
```

Implemented function:
```r
screen_reference()
```

Current workflow:

```text
LLM JSON
→ parse answers
→ deterministic adjudication
→ save screening results
→ update reference status
→ return verdict
```

Current persisted data:
- question-level answers
- confidence values
- evidence snippets
- model name
- adjudicated decision

Current limitations:
- No batch orchestration
- No retries
- No resumable queues
- No async workers
- No caching

---

# 7. Shiny Application

File:
```text
app.R
```

Current UI capabilities:
- Initialize SQLite database
- Import CSV references
- Load example protocol
- Display unscreened references
- Show basic system status

Current UI components:
- fileInput()
- actionButton()
- DT table
- status panel

Current limitations:
- No modularization yet
- No screening execution button
- No evidence viewer
- No PDF viewer
- No reviewer workflow
- No keyboard shortcuts
- No PRISMA dashboard

---

# 8. Tests

Files:
```text
tests/test_decision_engine.R
tests/test_screening_engine.R
```

Current test coverage:
- deterministic adjudication
- JSON parsing
- include/exclude/doubt behavior

Current limitations:
- No automated CI
- No integration tests
- No database tests
- No UI tests
- No API mock tests

---

# Current Operational State

The system can currently:

```text
Import CSV
→ store references in SQLite
→ load protocol JSON
→ build prompts
→ parse structured LLM responses
→ apply deterministic adjudication
→ persist screening results
→ run minimal Shiny UI
```

---

# Immediate Next Development Targets

Priority order:

1. Real LLM API integration
2. One-click screening execution from UI
3. Structured evidence display
4. RIS import support
5. Deduplication engine
6. Batch processing queue
7. Retry + malformed JSON repair
8. Full-text PDF ingestion
9. Reviewer workflow
10. PRISMA rendering

---

# Architectural Principles Locked In

1. LLMs extract evidence only.
2. Deterministic engine applies inclusion logic.
3. Human reviewer retains final authority.
4. All decisions must be auditable.
5. Every stage must be restartable.
6. No silent data deletion.
7. Persistence before optimization.
