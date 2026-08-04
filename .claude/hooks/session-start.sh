#!/bin/bash
set -euo pipefail

# Only needed in Claude Code on the web (remote) sessions
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Elixir (with Erlang/OTP) via apt — skip if already present
if ! command -v elixir >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq || true
  apt-get install -y -qq elixir
fi

# Rust via rustup — preinstalled in the base image, install only if missing
if ! command -v rustc >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --default-toolchain stable --profile minimal
  if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$CLAUDE_ENV_FILE"
  fi
  export PATH="$HOME/.cargo/bin:$PATH"
fi

echo "Toolchains ready: $(elixir --version | tail -1); $(rustc --version)"
