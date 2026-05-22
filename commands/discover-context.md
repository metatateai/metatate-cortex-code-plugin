---
description: Discover governed assets and available Metatate context in the connected Snowflake environment.
---

# Discover Governed Context

Use the `metatate` MCP tool `discover-context`.

Ask for filters when the request is too broad:

- `database_name`
- `schema_name`
- `domain`
- `min_sensitivity`
- `compliance_framework`
- `has_pii`

Return governed assets with enough context for the user to choose a fully
qualified table name before running deeper inspection or authorization checks.
