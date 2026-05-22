# Example Prompts

These prompts assume the `metatate` MCP server is connected in Cortex Code and
the Metatate plugin is active.

## Discover Governed Assets

```text
/metatate:discover-context
Show governed assets I can inspect. If you need to narrow the search, ask me
for a database, schema, domain, sensitivity level, or compliance tag.
```

## Inspect Data Meaning

```text
/metatate:inspect-data
Explain the governed meaning, sensitivity, PII flags, masking facts, and policy
references for <fully-qualified-governed-table>.
```

## Inspect Governance Rules

```text
/metatate:inspect-rules
What active governance rules apply to <fully-qualified-governed-table> for
analytics and model training use cases?
```

## Authorize Data Use

```text
/metatate:authorize-use
Can role <snowflake-role> read <fully-qualified-governed-table> for
<intended-use>? Include conditions, obligations, prohibitions, and the
decision ID.
```

## Validate Query Context

```text
/metatate:validate-query
Validate this SQL for <intended-use> by role <snowflake-role>:

select <column_list>
from <fully-qualified-governed-table>
limit 10;
```

## Review A Repository Change

```text
/metatate:release-gate
Review my current git diff for governed Snowflake data references. Validate any
SQL paths against Metatate and return pass, warn, or block with evidence IDs.
```
