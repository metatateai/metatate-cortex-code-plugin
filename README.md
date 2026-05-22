# Metatate Cortex Code Plugin

Bring Metatate's structured context and decision layer into Snowflake Cortex
Code.

Metatate gives AI agents structured, machine-readable context for Snowflake data
workflows: data meaning, business logic, policies, lineage, access rules,
runtime conditions, and decision evidence. This plugin lets Cortex Code work
with that context through the Snowflake-managed MCP server installed by the
Metatate Snowflake Native App.

Cortex Code remains the Snowflake-native developer workspace. Metatate remains
the source of truth for governed data context, intended-use validation,
authorization decisions, explanations, and audit evidence. This plugin does not
run a Metatate-hosted MCP gateway and it does not store Snowflake credentials in
the plugin repository.

## What You Get

- Cortex Code slash commands for governed data workflows: discover governed
  assets, inspect meaning and rules, authorize use, validate query context,
  explain decisions, review policy coverage, and run advisory release gates.
- A Cortex Code skill that keeps the agent grounded in Metatate as the
  decision layer instead of guessing from schema names, copied policy text, or
  local code alone.
- A governance reviewer subagent for repository, SQL, dbt, notebook, and
  application release reviews.
- A local helper that creates the correct Cortex MCP configuration for the
  Snowflake-managed Metatate MCP server.
- Customer-facing setup docs for Snowflake administrators and Cortex Code
  users.

## Repository Layout

```text
metatate-cortex-code-plugin/
  .cortex-plugin/
    plugin.json
  bin/
    metatate-cortex-mcp-add
  commands/
  skills/
  agents/
  docs/
    cortex-code-install.md
    snowflake-admin-setup.md
    troubleshooting.md
  examples/
    prompts.md
  scripts/
    validate-repo.sh
  SECURITY.md
  CHANGELOG.md
  LICENSE
```

## Requirements

For the Snowflake administrator:

- Metatate Snowflake Native App installed in the target Snowflake account. If it
  is not installed yet, start from the Snowflake Marketplace listing:
  https://app.snowflake.com/marketplace/listing/GZ2FTZU03OAS.
- The app exposes the managed MCP server, normally
  `METATATE_APP.CORE.METATATE_MCP`.
- A Snowflake role for Cortex Code users. Use a least-privilege role that is
  allowed to use Metatate, not an account administration role.
- A role-restricted Snowflake programmatic access token (PAT) policy for Cortex
  Code users.

For each Cortex Code user:

- Cortex Code CLI installed and connected to Snowflake.
- Access to the target Snowflake account in a role authorized for Metatate.
- A Snowflake PAT restricted to the Metatate Cortex Code role, for example
  `METATATE_CORTEX_USER`.

## Install The Plugin

Install the plugin from GitHub:

```bash
cortex plugin install metatateai/metatate-cortex-code-plugin
```

Confirm it is active:

```bash
cortex plugin list
```

You can validate a local checkout before installing:

```bash
cortex plugin validate .
```

## Configure The Snowflake MCP Connection

The plugin and the MCP connection are separate:

- The plugin adds Cortex Code commands, skills, and agent guidance.
- The MCP connection gives Cortex Code access to the Snowflake-managed Metatate
  tools.

Clone this repository locally if you did not already:

```bash
git clone https://github.com/metatateai/metatate-cortex-code-plugin.git
cd metatate-cortex-code-plugin
```

Register the MCP server with the helper. Replace the placeholders with values
from your Snowflake administrator:

```bash
./bin/metatate-cortex-mcp-add \
  --account-url https://<account-url> \
  --snowflake-role <snowflake-role> \
  --write
```

The helper writes a user-level Cortex MCP entry to
`~/.snowflake/cortex/mcp.json`. It references the PAT through the
`METATATE_CORTEX_PAT` environment variable and does not write the token secret
to the config file.

The generated server entry is equivalent to:

```json
{
  "mcpServers": {
    "metatate": {
      "type": "http",
      "url": "https://<account-url>/api/v2/databases/METATATE_APP/schemas/CORE/mcp-servers/METATATE_MCP",
      "headers": {
        "Authorization": "Bearer ${METATATE_CORTEX_PAT}",
        "X-Snowflake-Authorization-Token-Type": "PROGRAMMATIC_ACCESS_TOKEN",
        "X-Snowflake-Role": "<snowflake-role>"
      }
    }
  }
}
```

The PAT should be restricted to the same role used in `X-Snowflake-Role`. This
keeps MCP calls explicit, isolated, and auditable without relying on the user's
default role or secondary roles.

## Authenticate

Export the role-restricted PAT in the same shell where you run Cortex Code:

```bash
export METATATE_CORTEX_PAT='<snowflake-pat-secret>'
```

Start the MCP connection:

```bash
cortex mcp start
```

Cortex Code should connect without opening a Snowflake OAuth browser flow.
Confirm the `metatate` server is connected:

```bash
cortex mcp list
```

You can also open Cortex Code and use:

```text
/mcp
```

## Smoke Test

Start Cortex Code:

```bash
cortex
```

Run:

```text
/metatate:discover-context
```

Ask Metatate to find governed assets available in your environment:

```text
Show governed assets I can inspect. If you need to narrow the search, ask me
for a database, schema, domain, sensitivity level, or compliance tag.
```

Pick one fully qualified table name returned by Metatate before running the
next checks.

Then test one decision workflow:

```text
/metatate:authorize-use
```

Example prompt:

```text
Can role <your-snowflake-role> read <fully-qualified-governed-table> for
<your-intended-use>?
```

Cortex Code should call the Metatate MCP tools and return a governed result
with policy context, rationale, and any decision or validation IDs returned by
Metatate.

## Available Commands

- `/metatate:discover-context`
- `/metatate:inspect-data`
- `/metatate:inspect-rules`
- `/metatate:authorize-use`
- `/metatate:validate-query`
- `/metatate:explain-decision`
- `/metatate:policy-review`
- `/metatate:release-gate`

See [examples/prompts.md](examples/prompts.md) for end-to-end examples.

## MCP Tools Expected From Metatate

The Snowflake-managed MCP server should expose these tools:

- `discover-context`
- `get-decision-context`
- `inspect-data-meaning`
- `inspect-governance-rules`
- `authorize-use`
- `validate-query-context`
- `explain-why`

## Documentation

- [Snowflake administrator setup](docs/snowflake-admin-setup.md)
- [Cortex Code install guide](docs/cortex-code-install.md)
- [Troubleshooting](docs/troubleshooting.md)

## Security

Do not commit PATs, OAuth client secrets, access tokens, refresh tokens,
generated MCP credential stores, screenshots of consent pages, or customer data. See
[SECURITY.md](SECURITY.md).
