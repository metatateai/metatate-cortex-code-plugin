# Snowflake Administrator Setup

This guide prepares a Snowflake account so Cortex Code can reach the Metatate
Snowflake-managed MCP server through Snowflake OAuth.

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

## 3. Create The OAuth Security Integration

Cortex Code's MCP OAuth configuration is local to the developer workstation and
does not store a client secret in the plugin repository. For this local CLI
flow, use a Snowflake OAuth public client with PKCE enforced.

Use a Snowflake role that can create security integrations.

```sql
USE ROLE ACCOUNTADMIN;

CREATE SECURITY INTEGRATION METATATE_CORTEX_CODE_OAUTH
  TYPE = OAUTH
  OAUTH_CLIENT = CUSTOM
  ENABLED = TRUE
  OAUTH_CLIENT_TYPE = 'PUBLIC'
  OAUTH_REDIRECT_URI = 'http://127.0.0.1:8585/'
  OAUTH_ALLOW_NON_TLS_REDIRECT_URI = TRUE
  OAUTH_ENFORCE_PKCE = TRUE
  OAUTH_ISSUE_REFRESH_TOKENS = TRUE;
```

If your Cortex Code version uses a different local OAuth callback URI, alter
the integration to match the exact loopback URI emitted during the first OAuth
attempt. Keep the port aligned with the plugin helper's `--redirect-port`
value.

Then restrict the OAuth integration to the role users should request from
Cortex Code:

```sql
ALTER SECURITY INTEGRATION METATATE_CORTEX_CODE_OAUTH
  SET ALLOWED_ROLES_LIST = ('METATATE_CORTEX_USER')
      PRE_AUTHORIZED_ROLES_LIST = ('METATATE_CORTEX_USER');
```

The Cortex MCP registration must request the matching OAuth scope:

```text
session:role:METATATE_CORTEX_USER
```

This prevents Snowflake from attempting to authorize the user's default role or
secondary role `ALL`.

## 4. Delegate Authorization For Users

For each Snowflake user who will authenticate from Cortex Code:

```sql
ALTER USER <snowflake_user>
  ADD DELEGATED AUTHORIZATION OF ROLE METATATE_CORTEX_USER
  TO SECURITY INTEGRATION METATATE_CORTEX_CODE_OAUTH;
```

If your Snowflake account policy relies only on preauthorized roles, this may
not be necessary for every account. It is still a clear rollout pattern for a
controlled user allowlist.

## 5. Retrieve OAuth Client Values

Fetch the OAuth client values:

```sql
SELECT SYSTEM$SHOW_OAUTH_CLIENT_SECRETS('METATATE_CORTEX_CODE_OAUTH');
```

Give users:

- Snowflake account URL, for example `https://<account>.snowflakecomputing.com`.
- OAuth client ID.
- Snowflake role, for example `METATATE_CORTEX_USER`.
- App database, schema, and server name if they differ from
  `METATATE_APP.CORE.METATATE_MCP`.

Do not put OAuth secrets, access tokens, refresh tokens, screenshots, or
customer data in GitHub, Slack history, README files, or issue trackers.

## 6. Verify With A Test User

Ask one user to register the MCP server with:

```bash
./bin/metatate-cortex-mcp-add \
  --account-url https://<account-url> \
  --client-id <snowflake-oauth-client-id> \
  --snowflake-role METATATE_CORTEX_USER \
  --write
```

Then have them run:

```bash
cortex mcp start
```

Successful setup means:

- Snowflake login completes.
- Cortex Code shows the `metatate` MCP server as connected.
- Cortex Code can call the Metatate tools.

## Operational Notes

- Keep the OAuth redirect port and Snowflake redirect URI aligned.
- If changing the Cortex Code role, update both the Snowflake OAuth integration
  and the Cortex MCP registration.
- If users see a role-blocked error, confirm the MCP config contains
  `session:role:<role>` and that the same role is in `ALLOWED_ROLES_LIST` and
  `PRE_AUTHORIZED_ROLES_LIST`.
- For Claude Code, continue using the Claude plugin's confidential OAuth setup.
  This Cortex Code plugin uses a separate local CLI OAuth profile.
