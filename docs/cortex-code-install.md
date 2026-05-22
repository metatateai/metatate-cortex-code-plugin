# Cortex Code Install Guide

This guide is for users after a Snowflake administrator has prepared Metatate
MCP access and issued a role-restricted Snowflake programmatic access token
(PAT).

## Values You Need

Ask your administrator for:

- Snowflake account URL.
- PAT secret restricted to the Metatate Cortex Code role.
- Snowflake role to use with Metatate.
- App database, schema, and MCP server name if they differ from
  `METATATE_APP.CORE.METATATE_MCP`.

## 1. Install Cortex Code

Install and configure Cortex Code using Snowflake's official Cortex Code CLI
instructions. Confirm the CLI is available:

```bash
cortex --version
```

Then confirm you can start a Cortex Code session:

```bash
cortex
```

Exit the session before continuing.

## 2. Install The Plugin

Install the Metatate plugin from GitHub:

```bash
cortex plugin install metatateai/metatate-cortex-code-plugin
```

Confirm it is active:

```bash
cortex plugin list
```

If the plugin is installed but inactive, enable it:

```bash
cortex plugin enable metatate
```

## 3. Register The MCP Server

Clone the plugin repository locally if needed:

```bash
git clone https://github.com/metatateai/metatate-cortex-code-plugin.git
cd metatate-cortex-code-plugin
```

Export the PAT in the same shell where you run Cortex Code:

```bash
export METATATE_CORTEX_PAT='<snowflake-pat-secret>'
```

Register the MCP server:

```bash
./bin/metatate-cortex-mcp-add \
  --account-url https://<account-url> \
  --snowflake-role <snowflake-role> \
  --write
```

If your administrator gave you a different app database, schema, or MCP server
name, add `--app`, `--schema`, or `--server`.

To preview the config without writing it:

```bash
./bin/metatate-cortex-mcp-add \
  --account-url https://<account-url> \
  --snowflake-role <snowflake-role>
```

## 4. Authenticate

Start the MCP connection:

```bash
cortex mcp start
```

Cortex Code should connect without opening a Snowflake OAuth page. Confirm the
server is connected:

```bash
cortex mcp list
```

You can also open Cortex Code and check:

```text
/mcp
```

## 5. Confirm It Works

Start Cortex Code:

```bash
cortex
```

Run:

```text
/metatate:discover-context
```

Then ask for governed context your Metatate deployment knows about:

```text
Show governed assets I can inspect. If you need to narrow the search, ask me
for a database, schema, domain, sensitivity level, or compliance tag.
```

Pick one fully qualified table name returned by Metatate. You can then test
query validation with that asset:

```text
/metatate:validate-query
```

Example:

```text
Validate this SQL for <your-intended-use> by role <your-snowflake-role>:
select <column_list>
from <fully-qualified-governed-table>
limit 10;
```

## Updating

Update the plugin:

```bash
cortex plugin update metatate
```

If your Cortex Code version does not update a single plugin by name, run:

```bash
cortex plugin update
```

## Removing

Remove the MCP server:

```bash
cortex mcp remove metatate
```

Then uninstall the plugin:

```bash
cortex plugin uninstall metatate
```
