# Snowflake Administrator Setup

This guide prepares a Snowflake account so Cortex Code can reach the Metatate
Snowflake-managed MCP server.

Use a Snowflake programmatic access token (PAT) restricted to the Metatate
Cortex Code role. This avoids the Cortex Code OAuth `session:role:all` behavior
seen with Snowflake-managed MCP protected-resource metadata and keeps each MCP
request pinned to the intended Snowflake role with `X-Snowflake-Role`.

## 1. Confirm The Metatate MCP Server Exists

Use an administrative Snowflake role that can inspect the installed Native App.

```sql
SHOW MCP SERVERS IN SCHEMA METATATE_APP.CORE;
```

Expected server:

```text
METATATE_MCP
```

If your Native App database, schema, or server name differs, give users those
actual values. They are used in the Cortex MCP URL:

```text
https://<account-url>/api/v2/databases/<app-db>/schemas/<schema>/mcp-servers/<server>
```

## 2. Choose The Cortex Code Snowflake Role

Create or select a least-privilege role for Cortex Code users. The examples
below use:

```text
METATATE_CORTEX_USER
```

Use a role that is allowed to call the Metatate Native App and managed MCP
server. Do not use `ACCOUNTADMIN`, `SECURITYADMIN`, `ORGADMIN`, or other broad
administration roles for day-to-day Cortex Code use.

Grant the role to each user who should use the Cortex Code integration:

```sql
GRANT ROLE METATATE_CORTEX_USER TO USER <snowflake_user>;
```

Also grant the Metatate Native App privileges required by your Metatate
deployment to this role. The exact grants depend on how your application
package was installed and configured.

## 3. Create A Role-Restricted PAT

Use either Snowsight or SQL to create a PAT for each user. The PAT must be
restricted to the same role that users will configure in Cortex Code.

Example SQL:

```sql
USE ROLE ACCOUNTADMIN;

ALTER USER <snowflake_user>
  ADD PROGRAMMATIC ACCESS TOKEN metatate_cortex_code
  ROLE_RESTRICTION = 'METATATE_CORTEX_USER'
  DAYS_TO_EXPIRY = 30
  COMMENT = 'Metatate Cortex Code MCP token';
```

If the user is not covered by a network policy and your account requires one
for PAT use, add a temporary bypass while you complete the test:

```sql
ALTER USER <snowflake_user>
  ADD PROGRAMMATIC ACCESS TOKEN metatate_cortex_code
  ROLE_RESTRICTION = 'METATATE_CORTEX_USER'
  DAYS_TO_EXPIRY = 30
  MINS_TO_BYPASS_NETWORK_POLICY_REQUIREMENT = 240
  COMMENT = 'Metatate Cortex Code MCP token';
```

Snowflake prints the PAT secret once in the `token_secret` column. Give that
secret only to the token owner through your approved secret handoff process.
Do not put PATs in GitHub, Slack history, README files, screenshots, or issue
trackers.

## 4. Give Users The Setup Values

Give each user:

- Snowflake account URL, for example `https://<account>.snowflakecomputing.com`.
- PAT secret restricted to the Metatate Cortex Code role.
- Snowflake role, for example `METATATE_CORTEX_USER`.
- App database, schema, and server name if they differ from
  `METATATE_APP.CORE.METATATE_MCP`.

## 5. Verify With A Test User

Ask one user to export the PAT in their shell:

```bash
export METATATE_CORTEX_PAT='<snowflake-pat-secret>'
```

Then register the MCP server:

```bash
./bin/metatate-cortex-mcp-add \
  --account-url https://<account-url> \
  --snowflake-role METATATE_CORTEX_USER \
  --write
```

Then have them run:

```bash
cortex mcp start
```

Successful setup means:

- Cortex Code connects without opening an OAuth browser flow.
- Cortex Code shows the `metatate` MCP server as connected.
- Cortex Code can call the Metatate tools.

## OAuth Fallback

OAuth is not the recommended Cortex Code path for Snowflake-managed Metatate
MCP today. In tested Cortex Code builds, Snowflake-managed MCP resource
metadata advertises `session:role:all`, and Cortex Code follows that metadata
even when `mcp.json` contains `scope: session:role:<ROLE>`. That causes the
Snowflake authorization page to request role `ALL`, which many Snowflake OAuth
integrations correctly block.

Keep OAuth for clients where you have verified the managed MCP resource
metadata and client behavior request the intended role-specific scope.

## Operational Notes

- Rotate PATs on a defined schedule.
- Use role-restricted PATs only; do not use an unrestricted PAT for MCP access.
- Keep the `X-Snowflake-Role` header aligned with the PAT `ROLE_RESTRICTION`.
- If changing the Cortex Code role, issue a new PAT restricted to that role and
  update the local MCP registration.
