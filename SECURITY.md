# Security

## Supported Versions

The latest tagged release receives documentation and helper fixes.

## Reporting A Vulnerability

Report security issues privately to security@getmetatate.com.

Do not open public GitHub issues for vulnerabilities, credentials, customer
metadata, screenshots containing Snowflake account details, OAuth tokens, or
policy data.

## Credential Handling

- Do not commit OAuth client secrets, access tokens, refresh tokens, Snowflake
  session tokens, generated MCP credential stores, or customer data.
- The helper writes only local Cortex MCP configuration and OAuth client
  metadata. It does not write a client secret.
- Customer-specific Snowflake account URLs, OAuth client IDs, roles, app names,
  and server names should be treated as environment-specific configuration.
- Use least-privilege Snowflake roles for Cortex Code users.
- Pin OAuth to one Snowflake session role with `session:role:<ROLE>`.
