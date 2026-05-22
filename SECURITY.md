# Security

## Supported Versions

The latest tagged release receives documentation and helper fixes.

## Reporting A Vulnerability

Report security issues privately to security@getmetatate.com.

Do not open public GitHub issues for vulnerabilities, credentials, customer
metadata, screenshots containing Snowflake account details, PATs, OAuth tokens, or
policy data.

## Credential Handling

- Do not commit PATs, OAuth client secrets, access tokens, refresh tokens,
  Snowflake session tokens, generated MCP credential stores, or customer data.
- The helper writes only local Cortex MCP configuration. In default PAT mode it
  references the PAT through an environment variable and does not write the
  token secret into `mcp.json`.
- Customer-specific Snowflake account URLs, PAT environment variable names,
  roles, app names, and server names should be treated as environment-specific
  configuration.
- Use least-privilege Snowflake roles for Cortex Code users.
- Use role-restricted PATs and keep `X-Snowflake-Role` aligned with the PAT
  `ROLE_RESTRICTION`.
