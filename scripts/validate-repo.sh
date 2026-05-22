#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 -m json.tool "${repo_root}/.cortex-plugin/plugin.json" >/dev/null
bash -n "${repo_root}/bin/metatate-cortex-mcp-add"

dry_run_output="$(
  "${repo_root}/bin/metatate-cortex-mcp-add" \
    --account-url https://example.snowflakecomputing.com \
    --client-id test-client-id \
    --snowflake-role METATATE_CORTEX_USER
)"

DRY_RUN_OUTPUT="${dry_run_output}" python3 -c 'import json, os
server = json.loads(os.environ["DRY_RUN_OUTPUT"])
assert server["type"] == "http"
assert server["url"] == "https://example.snowflakecomputing.com/api/v2/databases/METATATE_APP/schemas/CORE/mcp-servers/METATATE_MCP"
assert server["oauth"]["client_id"] == "test-client-id"
assert server["oauth"]["redirect_port"] == 8585
assert server["oauth"]["scope"] == "session:role:METATATE_CORTEX_USER"
'

if command -v cortex >/dev/null 2>&1; then
  cortex plugin validate "${repo_root}"
else
  echo "cortex CLI not found; skipped cortex plugin validate"
fi

echo "Validation passed"
