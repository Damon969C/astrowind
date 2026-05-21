#!/usr/bin/env bash
set -euo pipefail

GATEWAY="10.0.0.20"
METRIC="50"
SYSCTL_KEYS=(
  "net.ipv6.conf.all.disable_ipv6"
  "net.ipv6.conf.default.disable_ipv6"
  "net.ipv6.conf.lo.disable_ipv6"
)

resolve_command() {
  local name="$1"
  local path

  if command -v "$name" >/dev/null 2>&1; then
    command -v "$name"
    return
  fi

  for path in "/usr/sbin/$name" "/sbin/$name" "/usr/bin/$name" "/bin/$name"; do
    if [ -x "$path" ]; then
      printf '%s\n' "$path"
      return
    fi
  done

  printf 'Error: required command not found: %s\n' "$name" >&2
  exit 1
}

IP_CMD="$(resolve_command ip)"
SYSCTL_CMD="$(resolve_command sysctl)"

usage() {
  cat >&2 <<USAGE
Usage: ${0##*/} on|off|status

  on      Disable IPv6 and replace the default route via ${GATEWAY}.
  off     Enable IPv6 and delete the default route via ${GATEWAY}.
  status  Show detected interface, IPv6 values, and matching default route.
USAGE
}

require_root() {
  if [ "$(id -u)" != "0" ]; then
    printf 'Error: %s must be run as root for this action.\n' "${0##*/}" >&2
    exit 1
  fi
}

detect_interface() {
  local iface

  iface="$(
    "$IP_CMD" -o link show |
      awk -F': ' '{
        name = $2
        sub(/@.*/, "", name)
        if (name != "lo") {
          print name
          exit
        }
      }'
  )"

  if [ -z "$iface" ]; then
    printf 'Error: no non-loopback network interface found.\n' >&2
    exit 1
  fi

  printf '%s\n' "$iface"
}

set_ipv6_disable_value() {
  local value="$1"
  local key

  for key in "${SYSCTL_KEYS[@]}"; do
    "$SYSCTL_CMD" -w "${key}=${value}"
  done
}

turn_on() {
  local iface

  require_root
  iface="$(detect_interface)"

  set_ipv6_disable_value "1"
  "$IP_CMD" route replace default via "$GATEWAY" dev "$iface" metric "$METRIC"

  printf 'IPv6 disabled. Default route set via %s dev %s metric %s.\n' "$GATEWAY" "$iface" "$METRIC"
}

turn_off() {
  local iface

  require_root
  iface="$(detect_interface)"

  set_ipv6_disable_value "0"
  "$IP_CMD" route del default via "$GATEWAY" dev "$iface" metric "$METRIC"

  printf 'IPv6 enabled. Default route removed via %s dev %s metric %s.\n' "$GATEWAY" "$iface" "$METRIC"
}

show_status() {
  local iface
  local key
  local route

  iface="$(detect_interface)"

  printf 'Interface: %s\n' "$iface"
  printf 'IPv6 disable values:\n'
  for key in "${SYSCTL_KEYS[@]}"; do
    "$SYSCTL_CMD" "$key"
  done

  route="$("$IP_CMD" route show default via "$GATEWAY" dev "$iface" metric "$METRIC" || true)"
  if [ -n "$route" ]; then
    printf 'Default route: %s\n' "$route"
  else
    printf 'Default route: not found\n'
  fi
}

main() {
  case "${1:-}" in
    on)
      turn_on
      ;;
    off)
      turn_off
      ;;
    status)
      show_status
      ;;
    -h|--help)
      usage
      ;;
    *)
      usage
      exit 2
      ;;
  esac
}

main "$@"
