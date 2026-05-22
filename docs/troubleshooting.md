# Troubleshooting

## The Role ALL Is Blocked

Error:

```text
The role ALL requested has been explicitly blocked for use with this application by an administrator.
```

Cause:

Snowflake received an OAuth request for the user's default role or secondary
role `ALL` instead of the role intended for Metatate.

Fix:

1. Remove the existing Cortex MCP registration.

   ```bash
   cortex mcp remove metatate
   ```

2. Register again with an explicit Snowflake role scope.

   ```bash
   ./bin/metatate-cortex-mcp-add \
     --account-url https://<account-url> \
     --client-id <snowflake-oauth-client-id> \
     --snowflake-role <snowflake-role> \
     --write
   ```

3. Ask your Snowflake administrator to confirm the same role is allowed and
   preauthorized on the OAuth security integration.

Users should not need to change their default Snowflake role to fix this.

## Browser Login Fails With Redirect URI Mismatch

Check:

- The redirect URI in Snowflake matches the loopback URI used by Cortex Code.
- The helper's `--redirect-port` value matches the port in the Snowflake
  security integration.
- No other local process is occupying the redirect port during authentication.

The default examples use:

```text
http://127.0.0.1:8585/
```

If your Cortex Code build emits a different loopback redirect URI, ask your
administrator to alter `OAUTH_REDIRECT_URI` on the security integration to the
exact value used by Cortex Code.

## Cortex Code Cannot Find The Metatate MCP Tools

Check the MCP registration:

```bash
cortex mcp get metatate
```

The URL should look like:

```text
https://<account-url>/api/v2/databases/METATATE_APP/schemas/CORE/mcp-servers/METATATE_MCP
```

Ask your administrator to confirm:

```sql
SHOW MCP SERVERS IN SCHEMA METATATE_APP.CORE;
```

Expected tools:

- `discover-context`
- `get-decision-context`
- `inspect-data-meaning`
- `inspect-governance-rules`
- `authorize-use`
- `validate-query-context`
- `explain-why`

## Plugin Installed But Slash Commands Are Missing

Check:

```bash
cortex plugin list
```

Confirm `metatate` is installed and active.

Validate the plugin:

```bash
cortex plugin validate metatate
```

Then restart Cortex Code or run:

```text
/plugin reload
```

## MCP Server Is Missing From Cortex Code

Plugin-declared MCP servers are skipped when an administrator disables user MCP
servers. This plugin does not declare a hardcoded MCP server because the
Snowflake account URL, OAuth client ID, and role are customer-specific.

Ask your administrator whether user MCP servers are allowed for your Cortex
Code environment. If they are disabled, the MCP server should be provided by a
managed Cortex Code profile instead of user-level `mcp.json`.

## Permission Or Policy Result Looks Unexpected

Metatate is the source of truth for governance decisions. Capture:

- User Snowflake role.
- Table or asset name.
- Operation and intended use.
- Decision ID or validation ID returned by Metatate.
- Cortex Code prompt used.

Then review the decision with:

```text
/metatate:explain-decision
```
