---
description: Review whether repository SQL, models, or code paths have enough Metatate policy coverage.
---

# Policy Coverage Review

Inspect local files for candidate Snowflake assets, SQL, dbt models, notebooks,
or application code paths that touch governed data. Use Metatate MCP tools for
policy facts and decisions.

Preferred sequence:

1. Identify changed files and candidate data assets.
2. Use `discover-context` to narrow governed assets when names are partial.
3. Use `get-decision-context`, `inspect-data-meaning`, and
   `inspect-governance-rules` for asset context.
4. Use `validate-query-context` for SQL statements or generated query paths.
5. Use `authorize-use` for explicit intended-use questions.

Return coverage gaps, missing context, risky assumptions, and concrete
recommendations. Do not mutate policy or deploy changes.
