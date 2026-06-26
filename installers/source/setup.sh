#!/bin/bash
# Colors schemes for echo:
RD='\033[0;31m' # Red
BL='\033[1;34m' # Blue
GN='\033[0;32m' # Green
MG='\033[0;95m' # Magenta
NC='\033[0m'    # No Color

if [[ -z "${TERM:-}" || "${TERM}" == "unknown" ]]; then
  export TERM=xterm
fi

get_term_cols() {
  local cols
  if cols=$(tput cols 2>/dev/null) && [[ "$cols" =~ ^[0-9]+$ ]] && (( cols > 0 )); then
    echo "$cols"
  else
    echo 80
  fi
}

TERM_COLS="$(get_term_cols)"
ERROR_STRING="Installation error. Exiting"
CURRENT_PATH=$(pwd)

DEFAULT_PHP_VERSION="php8.5"

CURRENT_KERNEL=$(grep -w ID /etc/os-release | cut -d "=" -f 2 | tr -d '"')
CURRENT_OS=$(grep -e VERSION_ID /etc/os-release | cut -d "=" -f 2 | cut -d "." -f 1 | tr -d '"')

ERROR_STRING="Installation error. Exiting"

STATE_DIR="/var/lib/dreamfactory-installer"
STATE_FILE="$STATE_DIR/state.env"
ANSWERS_FILE="$STATE_DIR/answers.env"
LOCK_FILE="$STATE_DIR/install.lock"
MIN_ROOT_FREE_GB="${MIN_ROOT_FREE_GB:-8}"
INSTALL_MODE="${INSTALL_MODE:-}"

PHASE_ORDER=(
  PHASE_SYSTEM_DEPS
  PHASE_PHP
  PHASE_WEBSTACK
  PHASE_PHP_EXTENSIONS
  PHASE_COMPOSER
  PHASE_DATABASE
  PHASE_DF_SOURCE
  PHASE_DF_COMPOSER_FILES
  PHASE_DF_CODE
  PHASE_DF_CONFIG
  PHASE_DF_BOOTSTRAP
  PHASE_FINAL_VERIFY
)

# Generate a strong random admin password for non-interactive installs.
# Guarantees upper/lower/digit/special so it satisfies DreamFactory's policy.
generate_admin_password() {
  local base=""
  if command -v openssl >/dev/null 2>&1; then
    base="$(openssl rand -base64 24 2>/dev/null | tr -dc 'A-Za-z0-9' | cut -c1-20)"
  fi
  if [[ -z "$base" ]]; then
    base="$(head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n' | cut -c1-20)"
  fi
  printf '%sAa9!' "$base"
}

init_state_files() {
  mkdir -p "$STATE_DIR"
  touch "$STATE_FILE" "$ANSWERS_FILE"
}

load_state() {
  if [[ -f "$STATE_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$STATE_FILE"
  fi
  if [[ -f "$ANSWERS_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$ANSWERS_FILE"
  fi
}

save_state_value() {
  local key="$1"
  local value="$2"

  if grep -qE "^${key}=" "$STATE_FILE"; then
    sed -i "s|^${key}=.*|${key}=\"${value}\"|" "$STATE_FILE"
  else
    echo "${key}=\"${value}\"" >> "$STATE_FILE"
  fi
}

save_answer_value() {
  local key="$1"
  local value="$2"

  if grep -qE "^${key}=" "$ANSWERS_FILE"; then
    sed -i "s|^${key}=.*|${key}=\"${value}\"|" "$ANSWERS_FILE"
  else
    echo "${key}=\"${value}\"" >> "$ANSWERS_FILE"
  fi
}

acquire_lock() {
  if [[ -f "$LOCK_FILE" ]]; then
    LOCK_PID=$(cat "$LOCK_FILE" 2>/dev/null)
    if [[ -n "$LOCK_PID" ]] && kill -0 "$LOCK_PID" 2>/dev/null; then
      echo_with_color red "Another DreamFactory installer process is running (PID: $LOCK_PID). Exiting."
      exit 1
    fi
    echo_with_color magenta "Found stale installer lock file. Removing and continuing."
    rm -f "$LOCK_FILE"
  fi

  echo $$ > "$LOCK_FILE"
}

release_lock() {
  rm -f "$LOCK_FILE"
}

mark_phase_done() {
  local phase_name="$1"
  save_state_value "$phase_name" "done"
}

mark_phase_failed() {
  local phase_name="$1"
  save_state_value "$phase_name" "failed"
}

mark_phase_started() {
  local phase_name="$1"
  save_state_value "$phase_name" "started"
}

phase_status() {
  local phase_name="$1"
  local phase_value
  phase_value=$(eval "echo \${$phase_name}")
  echo "${phase_value:-pending}"
}

is_phase_done() {
  local phase_name="$1"
  local phase_value
  phase_value=$(eval "echo \${$phase_name}")
  [[ "$phase_value" == "done" ]]
}

clear_phase_from() {
  local phase_name="$1"
  local clear_now=FALSE
  local phase

  for phase in "${PHASE_ORDER[@]}"; do
    if [[ "$phase" == "$phase_name" ]]; then
      clear_now=TRUE
    fi
    if [[ "$clear_now" == TRUE ]]; then
      save_state_value "$phase" ""
      unset "$phase"
    fi
  done
}

print_phase_table() {
  local index=1
  local phase

  for phase in "${PHASE_ORDER[@]}"; do
    printf "  [%2d] %-24s %s\n" "$index" "$phase" "$(phase_status "$phase")"
    index=$((index + 1))
  done
}

select_phase_by_number() {
  local selection="$1"
  local index=1
  local phase

  for phase in "${PHASE_ORDER[@]}"; do
    if [[ "$selection" == "$index" || "$selection" == "$phase" ]]; then
      echo "$phase"
      return 0
    fi
    index=$((index + 1))
  done

  return 1
}

clear_loaded_state() {
  local state_var
  while read -r state_var; do
    unset "$state_var"
  done < <(compgen -v | grep '^PHASE_' || true)
  unset INSTALL_MODE
}

resume_prompt() {
  if grep -qE '^PHASE_' "$STATE_FILE"; then
    draw_box "Previous Installer State" \
      "A prior DreamFactory installer run left state in $STATE_FILE." \
      "Choose how this run should continue."
    print_phase_table
    echo -e ""
    echo -e "  [1] Resume from first incomplete or failed phase"
    echo -e "  [2] Repair existing install using current state"
    echo -e "  [3] Pick a phase to resume from"
    echo -e "  [4] Mark a phase successful"
    echo -e "  [5] Start over (clear installer state files only)"
    read -r RESUME_MODE

    case "$RESUME_MODE" in
      5)
        : > "$STATE_FILE"
        : > "$ANSWERS_FILE"
        clear_loaded_state
        echo_with_color green "Installer state cleared. Starting fresh run."
        ;;
      4)
        echo_with_color magenta "Enter phase number or name to mark done:"
        read -r PHASE_SELECTION
        SELECTED_PHASE="$(select_phase_by_number "$PHASE_SELECTION")" || {
          echo_with_color red "Unknown phase. Exiting."
          exit 1
        }
        mark_phase_done "$SELECTED_PHASE"
        echo_with_color green "$SELECTED_PHASE marked done."
        ;;
      3)
        echo_with_color magenta "Enter phase number or name to resume from:"
        read -r PHASE_SELECTION
        SELECTED_PHASE="$(select_phase_by_number "$PHASE_SELECTION")" || {
          echo_with_color red "Unknown phase. Exiting."
          exit 1
        }
        clear_phase_from "$SELECTED_PHASE"
        save_state_value "INSTALL_MODE" "resume"
        echo_with_color green "State cleared from $SELECTED_PHASE onward."
        ;;
      2)
        save_state_value "INSTALL_MODE" "repair"
        echo_with_color green "Running in repair mode."
        ;;
      *)
        save_state_value "INSTALL_MODE" "resume"
        echo_with_color green "Resuming previous installation state."
        ;;
    esac

    load_state
  fi
}

ensure_pkg_manager_healthy() {
  if [[ "$CURRENT_KERNEL" == "ubuntu" || "$CURRENT_KERNEL" == "debian" ]]; then
    export DEBIAN_FRONTEND=noninteractive

    local dpkg_audit_output
    dpkg_audit_output="$(dpkg --audit 2>&1 || true)"

    if [[ -n "$dpkg_audit_output" ]]; then
      echo_with_color magenta "Detected interrupted dpkg state. Attempting recovery..." >&5
      dpkg --configure -a || true
      apt-get -f install -y || true
    fi
  fi
}

check_root_free_space() {
  local available_kb
  local required_kb
  local available_gb

  available_kb=$(df --output=avail / 2>/dev/null | tail -n 1 | tr -d ' ')

  if [[ -z "$available_kb" || ! "$available_kb" =~ ^[0-9]+$ ]]; then
    echo_with_color red "Could not determine root filesystem free space. Exiting..." >&5
    exit 1
  fi

  required_kb=$((MIN_ROOT_FREE_GB * 1024 * 1024))
  available_gb=$((available_kb / 1024 / 1024))

  if ((available_kb < required_kb)); then
    echo_with_color red "Root filesystem has ${available_gb} GB free. DreamFactory installer requires at least ${MIN_ROOT_FREE_GB} GB free before starting. Expand disk or clean up space, then rerun. Exiting..." >&5
    exit 1
  fi

  echo_with_color green "Root filesystem free space check passed (${available_gb} GB available)." >&5
}

wait_for_package_manager_locks() {
  if [[ "$CURRENT_KERNEL" != "ubuntu" && "$CURRENT_KERNEL" != "debian" ]]; then
    return 0
  fi

  local timeout_seconds=300
  local waited=0
  local lock_pids

  while (( waited < timeout_seconds )); do
    lock_pids="$(fuser /var/lib/dpkg/lock-frontend /var/lib/apt/lists/lock /var/cache/apt/archives/lock 2>/dev/null | xargs echo 2>/dev/null || true)"
    if [[ -z "$lock_pids" ]] && ! pgrep -x apt >/dev/null 2>&1 && ! pgrep -x apt-get >/dev/null 2>&1 && ! pgrep -x dpkg >/dev/null 2>&1; then
      return 0
    fi

    if (( waited == 0 )); then
      echo_with_color magenta "Detected active apt/dpkg work on first boot. Waiting for package manager locks to clear..." >&5
    fi

    sleep 5
    waited=$((waited + 5))
  done

  echo_with_color red "Timed out waiting for apt/dpkg locks to clear. Exiting..." >&5
  exit 1
}

echo_with_color() {
  case $1 in
  Red | RED | red)
    echo -e "${NC}${RD} $2 ${NC}"
    ;;
  Green | GREEN | green)
    echo -e "${NC}${GN} $2 ${NC}"
    ;;
  Magenta | MAGENTA | magenta)
    echo -e "${NC}${MG} $2 ${NC}"
    ;;
  Blue | BLUE | blue)
    echo -e "${NC}${BL} $2 ${NC}"
    ;;
  *)
    echo -e "${NC} $2 ${NC}"
    ;;
  esac
}

## Puts text in the center of the terminal, just for layout / making things pretty
print_centered() {
  [[ $# == 0 ]] && return 1

  declare -i TERM_COLS="$(get_term_cols)"
  declare -i str_len="${#1}"
  [[ $str_len -ge $TERM_COLS ]] && {
      echo "$1";
      return 0;
  }

  declare -i filler_len="$(( (TERM_COLS - str_len) / 2 ))"
  [[ $# -ge 2 ]] && ch="${2:0:1}" || ch=" "
  filler=""
  for (( i = 0; i < filler_len; i++ )); do
      filler="${filler}${ch}"
  done

  printf "%s%s%s" "$filler" "$1" "$filler"
  [[ $(( (TERM_COLS - str_len) % 2 )) -ne 0 ]] && printf "%s" "${ch}"
  printf "\n"

  return 0
}

draw_rule() {
  local width="${1:-72}"
  printf '+'
  printf '%*s' "$width" '' | tr ' ' '-'
  printf '+\n'
}

draw_box() {
  local title="$1"
  shift
  local width=72
  local line

  draw_rule "$width"
  printf '| %-70s |\n' "$title"
  draw_rule "$width"
  for line in "$@"; do
    printf '| %-70s |\n' "$line"
  done
  draw_rule "$width"
}

draw_section() {
  echo -e ""
  echo_with_color blue "$1"
  printf '%s\n' "----------------------------------------------------------------------"
}

read_with_default() {
  local prompt="$1"
  local default_value="$2"
  local answer

  if [[ -n "$default_value" ]]; then
    printf "%s [%s]: " "$prompt" "$default_value" >&5
  else
    printf "%s: " "$prompt" >&5
  fi
  read -r answer
  echo "${answer:-$default_value}"
}

path_has_composer_files() {
  local candidate_path="$1"
  [[ -f "$candidate_path/composer.json" && -f "$candidate_path/composer.lock" && -f "$candidate_path/composer.json-dist" ]]
}

default_license_path() {
  if [[ -n "${DF_LICENSE_PATH:-}" ]]; then
    echo "$DF_LICENSE_PATH"
  else
    echo "/home/${CURRENT_USER}/df-license-files"
  fi
}

install_composer_files_if_available() {
  local default_path="${1:-$(default_license_path)}"
  local answer="${LICENSE_FILE_ANSWER:-}"
  local selected_path="${LICENSE_PATH:-}"

  if [[ "$LICENSE_PATH_AUTO" == TRUE && -n "$selected_path" ]]; then
    answer=Y
  elif [[ -z "$answer" ]]; then
    if [[ $DF_CLEAN_INSTALLATION == FALSE && -f /opt/dreamfactory/composer.json && -f /opt/dreamfactory/composer.lock && -f /opt/dreamfactory/composer.json-dist ]]; then
      echo_with_color magenta "Existing composer files detected. Replace them with commercial composer files? [Yy/Nn] " >&5
    else
      echo_with_color magenta "Use commercial DreamFactory composer files? [Yy/Nn] " >&5
    fi
    read -r answer
    answer="${answer:-N}"
  fi

  save_answer_value "LICENSE_FILE_ANSWER" "$answer"

  if [[ ! $answer =~ ^[Yy]$ ]]; then
    echo_with_color red "Installing DreamFactory OSS version.\n" >&5
    return 0
  fi

  if [[ -z "$selected_path" ]]; then
    selected_path="$(read_with_default "Enter absolute path to composer/license files" "$default_path")"
  fi
  selected_path="${selected_path%/}"
  save_answer_value "LICENSE_PATH" "$selected_path"

  if ! path_has_composer_files "$selected_path"; then
    echo_with_color red "Composer files not found in ${selected_path}. Installing DreamFactory OSS version.\n" >&5
    return 0
  fi

  cp "$selected_path"/composer.{json,lock,json-dist} /opt/dreamfactory/
  LICENSE_INSTALLED=TRUE
  save_state_value "LICENSE_INSTALLED" "TRUE"
  echo_with_color green "Commercial composer files installed from ${selected_path}.\n" >&5
}

fix_dreamfactory_runtime_permissions() {
  if [[ ! -d /opt/dreamfactory ]]; then
    return 0
  fi

  if [[ ! $APACHE == TRUE ]]; then
    if ! id dreamfactory >/dev/null 2>&1; then
      useradd dreamfactory
    fi
    chown -R dreamfactory:dreamfactory /opt/dreamfactory
    chmod -R u=rwX,g=rX,o= /opt/dreamfactory
    find /opt/dreamfactory -type d -exec chmod g+s {} \;
    chmod g+w /opt/dreamfactory/.env 2>/dev/null || true
    chmod -R g+rwX /opt/dreamfactory/storage /opt/dreamfactory/bootstrap/cache 2>/dev/null || true
  elif [[ $CURRENT_KERNEL == "debian" || $CURRENT_KERNEL == "ubuntu" ]]; then
    chown -R "www-data:$CURRENT_USER" /opt/dreamfactory/
    chmod -R 2775 /opt/dreamfactory/
  else
    chown -R "apache:$CURRENT_USER" /opt/dreamfactory/
    chmod -R 2775 /opt/dreamfactory/
  fi

  # RHEL/CentOS/Oracle Linux ship SELinux enforcing. Without these booleans the web
  # server (php-fpm) is blocked from opening network connections, so DreamFactory
  # cannot reach its own system database (SQLSTATE 2002 Permission denied) nor any
  # remote connector database / AI endpoint. Set them when SELinux is present.
  if command -v setsebool >/dev/null 2>&1 && command -v getenforce >/dev/null 2>&1 && [[ "$(getenforce)" != "Disabled" ]]; then
    setsebool -P httpd_can_network_connect_db 1 2>/dev/null || true
    setsebool -P httpd_can_network_connect 1 2>/dev/null || true

    # /opt/dreamfactory inherits the usr_t label (it lives under /opt), which php-fpm
    # (httpd_t domain) cannot write. Without relabeling storage/ and bootstrap/cache to
    # httpd_sys_rw_content_t, every request 500s on "Permission denied" opening the log
    # file -- and SELinux's dontaudit rule HIDES the AVC, so ausearch shows nothing.
    # semanage ships in policycoreutils-python-utils (installed in system deps).
    if command -v semanage >/dev/null 2>&1; then
      for d in /opt/dreamfactory/storage /opt/dreamfactory/bootstrap/cache; do
        semanage fcontext -a -t httpd_sys_rw_content_t "${d}(/.*)?" 2>/dev/null || \
          semanage fcontext -m -t httpd_sys_rw_content_t "${d}(/.*)?" 2>/dev/null || true
      done
      command -v restorecon >/dev/null 2>&1 && \
        restorecon -R /opt/dreamfactory/storage /opt/dreamfactory/bootstrap/cache 2>/dev/null || true
    fi
  fi
}

## Build the MCP daemon and install it as a persistent systemd service.
## The bundled fire-and-forget `start-daemon.sh &` died with the installer shell, left no
## logs, and never survived a reboot. Node 20 must already be on PATH (install_node).
setup_mcp_daemon_service () {
  local mcp_dir="/opt/dreamfactory/vendor/dreamfactory/df-mcp-server"
  local daemon_dir="${mcp_dir}/daemon"
  if [[ ! -d "$daemon_dir" ]]; then
    echo_with_color red "MCP daemon directory not found ($daemon_dir); skipping MCP setup." >&5
    return 0
  fi
  if ! command -v node >/dev/null 2>&1; then
    echo_with_color red "Node.js not found; cannot set up MCP daemon." >&5
    return 1
  fi

  # Run the daemon as the same service account that owns /opt/dreamfactory.
  local run_user=dreamfactory
  id "$run_user" >/dev/null 2>&1 || run_user="$CURRENT_USER"

  # Build (npm install incl. devDeps for tsc, then tsc -> dist/server.js) as that user so
  # node_modules/ and dist/ are owned correctly. HOME/cache point at the owned tree.
  runuser -u "$run_user" -- env HOME=/opt/dreamfactory npm_config_cache=/opt/dreamfactory/.npm \
    bash -lc "cd '$daemon_dir' && npm install --include=dev && npm run build" || {
    echo_with_color red "MCP daemon build failed." >&5
    return 1
  }

  cat > /etc/systemd/system/df-mcp.service <<EOF
[Unit]
Description=DreamFactory MCP Daemon
After=network.target

[Service]
Type=simple
User=${run_user}
WorkingDirectory=${daemon_dir}
Environment=NODE_ENV=production
Environment=MCP_DAEMON_HOST=127.0.0.1
Environment=MCP_DAEMON_PORT=8006
ExecStart=/usr/bin/node dist/server.js
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

  command -v restorecon >/dev/null 2>&1 && restorecon /etc/systemd/system/df-mcp.service 2>/dev/null || true
  systemctl daemon-reload
  systemctl enable --now df-mcp.service
}

## Used for each of the individual components to be installed
run_process () {
  local process_name="$1"
  shift

  while true; do
    { echo -n . >&5; } 2>/dev/null || break
    sleep 1
  done &
  BGPID=$!
  trap 'kill "$BGPID" 2>/dev/null || true; exit' INT
  echo -n "$process_name" >&5
  if [[ -n "${ACTIVE_PHASE:-}" ]]; then
    mark_phase_started "$ACTIVE_PHASE"
  fi
  "$@"
  PROCESS_STATUS=$?
  kill "$BGPID" 2>/dev/null || true
  wait "$BGPID" 2>/dev/null || true
  if ((PROCESS_STATUS >= 1)); then
    if [[ -n "${ACTIVE_PHASE:-}" ]]; then
      mark_phase_failed "$ACTIVE_PHASE"
    fi
    echo failed >&5
    echo_with_color red "\n${process_name} failed. Check /tmp/dreamfactory_installer.log when running in debug mode." >&5
    exit "$PROCESS_STATUS"
  fi
  echo done >&5
}

fix_php_extension_permissions() {
  local ext
  local extension_dir

  extension_dir="$(php-config --extension-dir 2>/dev/null || true)"
  for ext in "$@"; do
    if [[ -n "$extension_dir" && -f "$extension_dir/${ext}.so" ]]; then
      chmod 0644 "$extension_dir/${ext}.so"
    fi
    find /etc/php /etc/php.d -name "*${ext}.ini" -exec chmod 0644 {} + 2>/dev/null || true
  done
}

clear

# Make sure script run as sudo
if ((EUID != 0)); then
  echo -e "${RD}\nPlease run script with root privileges: sudo ./dfsetup.run \n"
  exit 1
fi

init_state_files
load_state
acquire_lock
trap release_lock EXIT
resume_prompt

#### Check Current OS is compatible with the installer ####
case $CURRENT_KERNEL in
  ubuntu)
    if ((CURRENT_OS != 22)) && ((CURRENT_OS != 24)); then
      echo_with_color red "The installer only supports Ubuntu 22 and 24. Exiting...\n"
      exit 1
    fi
    ;;
  debian)
    if ((CURRENT_OS != 12)) && ((CURRENT_OS != 13)); then
      echo_with_color red "The installer only supports Debian 12 and 13. Exiting...\n"
      exit 1
    fi
    ;;
  centos | rhel | almalinux | rocky | ol | oracle)
    if ((CURRENT_OS != 8)) && ((CURRENT_OS != 9)); then
      echo_with_color red "The installer only supports Rhel/CentOS/Oracle Linux 8 and 9. Exiting...\n"
      exit 1
    fi
    ;;
  fedora)
    if ((CURRENT_OS < 39)); then
      echo_with_color red "The installer only supports Fedora 39 and newer. Exiting...\n"
      exit 1
    fi
    ;;
  *)
    echo_with_color red "Installer only supported on Ubuntu, Debian, Rhel (Centos) and Fedora. Exiting...\n"
    exit 1
    ;;

esac

# Retrieve executing user's username before showing install defaults.
CURRENT_USER=$(logname 2>/dev/null || true)

if [[ -n $SUDO_USER ]]; then
  CURRENT_USER=${SUDO_USER}
fi

if [[ -z $SUDO_USER ]] && [[ -z $CURRENT_USER ]]; then
  echo_with_color red "Enter username for installation DreamFactory:"
  read -r CURRENT_USER
  if [[ $CURRENT_KERNEL == "debian" ]]; then
    su "${CURRENT_USER}" -c "echo 'Checking user availability'"
    if (($? >= 1)); then
      echo 'Please provide another user'
      exit 1
    fi
  fi
fi

if [[ $CURRENT_USER == "root" ]]; then
  echo -e "WARNING: Although this script must be run with sudo, it is not recommended to install DreamFactory as root (specifically 'composer' commands) Would you like to:\n [1] Continue as root\n [2] Provide username for installing DreamFactory"
  read -r INSTALL_AS_ROOT
  if [[ $INSTALL_AS_ROOT == 1 ]]; then
    echo -e "Continuing installation as root"
  else
    echo -e "Enter username for installing DreamFactory"
    read -r CURRENT_USER
    echo -e "User: ${CURRENT_USER} selected. Continuing"
  fi
fi

DEFAULT_LICENSE_PATH="$(default_license_path)"
AUTO_LICENSE_FOUND=FALSE
if path_has_composer_files "$DEFAULT_LICENSE_PATH"; then
  AUTO_LICENSE_FOUND=TRUE
fi

draw_box "DreamFactory Linux Installer" \
  "Detected: ${CURRENT_KERNEL^} ${CURRENT_OS} | Target PHP: ${DEFAULT_PHP_VERSION#php} | User: ${CURRENT_USER}" \
  "Default commercial composer path: ${DEFAULT_LICENSE_PATH}" \
  "Commercial composer files found: ${AUTO_LICENSE_FOUND}"

draw_section "Install Mode"
echo -e "  [0] Recommended install"
echo -e "      Nginx + MariaDB + base PHP extensions/connectors"
echo -e "      Uses ${DEFAULT_LICENSE_PATH} automatically when composer files are present"
echo -e ""
echo -e "  [1] Custom install"
echo -e "      Choose web server, database, connector drivers, debug logging, MCP"
echo -e ""
echo -e "  [9] Upgrade existing DreamFactory"
echo -e ""
echo_with_color magenta "Select install mode. Press Enter for recommended install."
# Honor a pre-set INSTALLER_TUI_MODE (unattended/automated installs set it via env,
# consistent with DF_ADMIN_EMAIL/DF_LICENSE_KEY/LICENSE_*). Only prompt interactively
# when it is unset; otherwise a piped/empty stdin would clobber the chosen profile.
if [[ -z "${INSTALLER_TUI_MODE:-}" ]]; then
  read -r INSTALLER_TUI_MODE
fi
INSTALLER_TUI_MODE="${INSTALLER_TUI_MODE:-0}"

case "$INSTALLER_TUI_MODE" in
  *,*)
    INSTALLATION_OPTIONS="$INSTALLER_TUI_MODE"
    INSTALLER_TUI_MODE="custom"
    ;;
  1 | custom | Custom | CUSTOM)
    draw_section "Custom Options"
    echo -e "  [0] Base DreamFactory + Nginx"
    echo -e "  [1] Oracle OS driver/PHP extension"
    echo -e "  [2] IBM DB2 OS driver/PHP extension"
    echo -e "  [3] Cassandra PHP extension"
    echo -e "  [4] Apache2 instead of Nginx"
    echo -e "  [5] MariaDB system database"
    echo -e "  [6] Specific DreamFactory version"
    echo -e "  [7] Trino ODBC driver"
    echo -e "  [8] Debug logging to /tmp/dreamfactory_installer.log"
    echo -e "  [10] MCP daemon"
    echo -e "  [11] Advanced analytics connectors (Snowflake + ODBC packs)"
    echo -e ""
    echo_with_color magenta "Enter comma-separated options. Example: 0,5,8"
    read -r INSTALLATION_OPTIONS
    INSTALLATION_OPTIONS="${INSTALLATION_OPTIONS:-0}"
    ;;
  9 | upgrade | Upgrade | UPGRADE)
    INSTALLATION_OPTIONS="9"
    ;;
  *)
    INSTALLER_TUI_MODE="0"
    INSTALLATION_OPTIONS="0,5"
    RECOMMENDED_INSTALL=TRUE
    AUTO_LICENSE=TRUE
    ;;
esac

INSTALLATION_OPTIONS_NORMALIZED="${INSTALLATION_OPTIONS//[[:space:]]/}"
save_answer_value "INSTALLER_TUI_MODE" "$INSTALLER_TUI_MODE"
save_answer_value "INSTALLATION_OPTIONS" "$INSTALLATION_OPTIONS"
save_answer_value "DEFAULT_LICENSE_PATH" "$DEFAULT_LICENSE_PATH"

selected_option() {
  local option="$1"
  [[ ",${INSTALLATION_OPTIONS_NORMALIZED}," == *",${option},"* ]]
}

if [[ $RECOMMENDED_INSTALL == TRUE ]]; then
  echo_with_color green "Recommended install selected: Nginx + MariaDB + base connectors."
  if [[ $AUTO_LICENSE_FOUND == TRUE ]]; then
    LICENSE_FILE_ANSWER=Y
    LICENSE_PATH="$DEFAULT_LICENSE_PATH"
    LICENSE_PATH_AUTO=TRUE
    save_answer_value "LICENSE_PATH" "$LICENSE_PATH"
    echo_with_color green "Commercial composer files will be used from ${LICENSE_PATH}."
  else
    echo_with_color magenta "No commercial composer files found at ${DEFAULT_LICENSE_PATH}; installer will use OSS composer files."
  fi
fi

draw_section "Installation Summary"
echo -e "  OS:                 ${CURRENT_KERNEL^} ${CURRENT_OS}"
echo -e "  PHP target:         ${DEFAULT_PHP_VERSION#php}"
echo -e "  Web server:         $(selected_option 4 && echo Apache || echo Nginx)"
echo -e "  System database:    $(selected_option 5 && echo MariaDB || echo Existing/manual)"
echo -e "  Composer files:     $([[ $LICENSE_PATH_AUTO == TRUE ]] && echo "${LICENSE_PATH}" || echo "Prompt or OSS")"
echo -e "  Debug log:          $(selected_option 8 && echo /tmp/dreamfactory_installer.log || echo Disabled)"
echo -e "  Optional drivers:   Oracle=$(selected_option 1 && echo yes || echo no), DB2=$(selected_option 2 && echo yes || echo no), Cassandra=$(selected_option 3 && echo yes || echo no), Trino=$(selected_option 7 && echo yes || echo no)"
echo -e "  Advanced bundle:    $(selected_option 11 && echo yes || echo no)"
echo -e "  MCP daemon:         $(selected_option 10 && echo yes || echo no)"
echo -e ""
echo_with_color magenta "Press Enter to continue, or Ctrl-C to cancel."
read -r _

if selected_option 1; then
  ORACLE=TRUE
  echo_with_color green "Oracle selected."
fi

if selected_option 2; then
  DB2=TRUE
  echo_with_color green "DB2 selected."
fi

if selected_option 3; then
  CASSANDRA=TRUE
  echo_with_color green "Cassandra selected."
fi

if selected_option 4; then
  APACHE=TRUE
  echo_with_color green "Apache selected."
fi

if selected_option 5; then
  MYSQL=TRUE
  echo_with_color green "MariaDB System Database selected."
fi

if selected_option 6; then
  echo_with_color magenta "What version of DreamFactory would you like to install? (E.g. 4.9.0)"
  read -r -p "DreamFactory Version: " DREAMFACTORY_VERSION_TAG
  echo_with_color green "DreamFactory Version ${DREAMFACTORY_VERSION_TAG} selected."
fi

if selected_option 7; then
  SIMBA_TRINO_ODBC=TRUE
  echo_with_color green "Simba Trino ODBC selected."
fi

if selected_option 8; then
  DEBUG=TRUE
  echo_with_color green "Running in debug mode. Run this command: tail -f /tmp/dreamfactory_installer.log in a new terminal session to follow logs during installation"
fi

if selected_option 10; then
  ENABLE_MCP_DAEMON=TRUE
  echo_with_color green "MCP Daemon selected."
fi

if selected_option 11; then
  ADVANCED_CONNECTORS=TRUE
  echo_with_color green "Advanced analytics connectors selected."
fi

if [[ ! $DEBUG == TRUE ]]; then
  exec 5>&1            # Save a copy of STDOUT
  exec >/dev/null 2>&1 # Redirect STDOUT to Null
else
  exec 5>&1 # Save a copy of STDOUT. Used because all echo redirects output to 5.
  exec >/tmp/dreamfactory_installer.log 2>&1
fi

echo -e "${CURRENT_KERNEL^} ${CURRENT_OS} detected. Installing DreamFactory...\n" >&5
#Go into the individual scripts here
case $CURRENT_KERNEL in
  ubuntu)
    source ./ubuntu.sh
    ;;
  debian)
    source ./debian.sh
    ;;
  centos | rhel | almalinux | rocky | ol | oracle)
    source ./centos.sh
    ;;
  fedora)
    source ./fedora.sh
    ;;
esac

ensure_pkg_manager_healthy
check_root_free_space
wait_for_package_manager_locks

#### INSTALLER ####

if selected_option 9; then
  echo_with_color green "Upgrading DreamFactory selected.\n" >&5
  run_process "   Upgrading DreamFactory" upgrade_dreamfactory
  echo_with_color green "\nFinished Upgrading DreamFactory." >&5

  exit 0
fi

### STEP 1. Install system dependencies
echo_with_color blue "Step 1: Installing system dependencies...\n" >&5
if ! is_phase_done "PHASE_SYSTEM_DEPS"; then
  ACTIVE_PHASE="PHASE_SYSTEM_DEPS"
  run_process "   Updating System" system_update
  run_process "   Installing System Dependencies" install_system_dependencies
  mark_phase_done "PHASE_SYSTEM_DEPS"
  unset ACTIVE_PHASE
else
  echo_with_color green "   Phase already complete. Skipping system dependencies.\n" >&5
fi
echo_with_color green "\nThe system dependencies have been successfully installed.\n" >&5

### Step 2. Install PHP
echo_with_color blue "Step 2: Installing PHP...\n" >&5
if ! is_phase_done "PHASE_PHP"; then
  ACTIVE_PHASE="PHASE_PHP"
  run_process "   Installing PHP" install_php
  mark_phase_done "PHASE_PHP"
  unset ACTIVE_PHASE
else
  echo_with_color green "   Phase already complete. Skipping PHP installation.\n" >&5
fi
echo_with_color green "\nPHP installed.\n" >&5

### Step 3. Install web stack
if ! is_phase_done "PHASE_WEBSTACK"; then
  ACTIVE_PHASE="PHASE_WEBSTACK"
  if [[ $APACHE == TRUE ]]; then ### Only with key --apache
    echo_with_color blue "Step 3: Installing Apache...\n" >&5
    # Check Apache installation status
    check_apache_installation_status
    if ((CHECK_APACHE_PROCESS == 0)) || ((CHECK_APACHE_INSTALLATION == 0)); then
      echo_with_color red "Apache2 detected. Skipping installation. Configure Apache2 manually.\n" >&5
    else
      # Install Apache
      # Check if running web server on port 80
      lsof -i :80 | grep LISTEN
      if (($? == 0)); then
        echo_with_color red "Port 80 taken.\n " >&5
        echo_with_color red "Skipping installation Apache2. Install Apache2 manually.\n " >&5
      else
        run_process "   Installing Apache" install_apache
        run_process "   Restarting Apache" restart_apache
        echo_with_color green "\nApache2 installed.\n" >&5
      fi
    fi

  else
    echo_with_color blue "Step 3: Installing Nginx...\n" >&5 ### Default choice
    # Check nginx installation in the system
    check_nginx_installation_status
    if ((CHECK_NGINX_PROCESS == 0)) || ((CHECK_NGINX_INSTALLATION == 0)); then
      echo_with_color red "Nginx detected. Skipping installation. Configure Nginx manually.\n" >&5
    else
      # Install nginx
      # Checking running web server
      lsof -i :80 | grep LISTEN
      if (($? == 0)); then
        echo_with_color red "Port 80 taken.\n " >&5
        echo_with_color red "Skipping Nginx installation. Install Nginx manually.\n " >&5
      else
        run_process "   Installing Nginx" install_nginx
        run_process "   Restarting Nginx" restart_nginx
        echo_with_color green "\nNginx installed.\n" >&5
      fi
    fi
  fi
  mark_phase_done "PHASE_WEBSTACK"
  unset ACTIVE_PHASE
else
  echo_with_color green "   Phase already complete. Skipping web stack installation.\n" >&5
fi

### Step 4. Configure PHP development tools
if ! is_phase_done "PHASE_PHP_EXTENSIONS"; then
  ACTIVE_PHASE="PHASE_PHP_EXTENSIONS"
  echo_with_color blue "Step 4: Configuring PHP Extensions...\n" >&5

  ## Install PHP PEAR
  run_process "   Installing PHP PEAR" install_php_pear
  echo_with_color green "    PHP PEAR installed\n" >&5

### Install ZIP
if [[ $CURRENT_KERNEL == "fedora" ]]; then
  php -m | grep -E "^zip"
  if (($? >= 1)); then
    run_process "   Installing zip" install_zip
    php -m | grep -E "^zip"
    if (($? >= 1)); then
      echo_with_color red "\nExtension Zip has errors..." >&5
    else
      echo_with_color green "   Zip installed\n" >&5
    fi
  fi
fi

### Install MCrypt
php -m | grep -E "^mcrypt"
if (($? >= 1)); then
  run_process "   Installing Mcrypt" install_mcrypt
  php -m | grep -E "^mcrypt"
  if (($? >= 1)); then
    echo_with_color magenta "    Mcrypt not enabled (expected on PHP 8.5; not required by DreamFactory).\n" >&5
  else
    echo_with_color green "    Mcrypt installed\n" >&5
  fi
fi

### Install MongoDB drivers
php -m | grep -E "^mongodb"
if (($? >= 1)); then
  run_process "   Installing Mongodb" install_mongodb
  php -m | grep -E "^mongodb"
  if (($? >= 1)); then
    echo_with_color red "\nMongoDB installation error." >&5
  else
    echo_with_color green "    MongoDB installed\n" >&5
  fi
fi

### Install MS SQL Drivers
php -m | grep -E "^sqlsrv"
if (($? >= 1)); then
  run_process "   Installing MS SQL Server" install_sql_server
  run_process "   Installing pdo_sqlsrv" install_pdo_sqlsrv
  php -m | grep -E "^sqlsrv"
  if (($? >= 1)); then
    echo_with_color red "\nMS SQL Server extension installation error." >&5
  else
    echo_with_color green "    MS SQL Server extension installed\n" >&5
  fi
  php -m | grep -E "^pdo_sqlsrv"
  if (($? >= 1)); then
    echo_with_color red "\nCould not install pdo_sqlsrv extension" >&5
  else
    echo_with_color green "    pdo_sqlsrv installed\n" >&5
  fi
fi


### DRIVERS FOR ORACLE ( ONLY WITH KEY --with-oracle )
php -m | grep -E "^oci8"
if (($? >= 1)); then
  if [[ $ORACLE == TRUE ]]; then
    echo_with_color magenta "Enter absolute path to the Oracle drivers, complete with trailing slash: [/] " >&5
    read -r DRIVERS_PATH
    if [[ -z $DRIVERS_PATH ]]; then
      DRIVERS_PATH="."
    fi
    if [[ $CURRENT_KERNEL == "ubuntu" || $CURRENT_KERNEL == "debian" ]]; then
      unzip "$DRIVERS_PATH/instantclient-*.zip" -d /opt/oracle
    else
      ls -f $DRIVERS_PATH/oracle-instantclient*-*-[12][19].*.0.0.0*.x86_64.rpm
    fi
    if (($? == 0)); then
      run_process "   Drivers Found. Installing Oracle Drivers" install_oracle
      php -m | grep -E "^oci8"
      if (($? >= 1)); then
        echo_with_color red "\nCould not install oci8 extension." >&5
      else
        echo_with_color green "    Oracle drivers and oci8 extension installed\n" >&5
      fi
    else
      echo_with_color red "Drivers not found. Skipping...\n" >&5
    fi
    unset DRIVERS_PATH
  fi
fi

### DRIVERS FOR SIMBA TRINO ODBC (ONLY WITH KEY --with-simba-trino-odbc)
if [[ $SIMBA_TRINO_ODBC == TRUE ]]; then
  echo_with_color magenta "Enter absolute path to the Simba Trino ODBC driver package (.deb or .rpm), complete with filename: " >&5
  read -r SIMBA_TRINO_DRIVER_PATH

  # Prompt for SimbaTrinoODBCDriver.lic license file
  echo_with_color magenta "Enter absolute path to the SimbaTrinoODBCDriver.lic license file: " >&5
  read -r SIMBA_TRINO_LICENSE_PATH

  if [[ -z $SIMBA_TRINO_DRIVER_PATH || ! -f $SIMBA_TRINO_DRIVER_PATH ]]; then
    echo_with_color red "Simba Trino ODBC driver file not found. Skipping installation." >&5
  elif [[ -z $SIMBA_TRINO_LICENSE_PATH || ! -f $SIMBA_TRINO_LICENSE_PATH ]]; then
    echo_with_color red "Simba Trino ODBC licence file not found. Skipping installation." >&5
  else
    run_process "   Installing Simba Trino ODBC driver" install_simba_trino_odbc "$SIMBA_TRINO_DRIVER_PATH"
  fi
fi

### DRIVERS FOR IBM DB2 PDO ( ONLY WITH KEY --with-db2 )
php -m | grep -E "^pdo_ibm"
if (($? >= 1)); then
  if [[ $DB2 == TRUE ]]; then
    echo_with_color magenta "Enter absolute path to the IBM DB2 drivers, complete with trailing slash: [/] " >&5
    read -r DRIVERS_PATH
    if [[ -z $DRIVERS_PATH ]]; then
      DRIVERS_PATH="."
    fi
    tar xzf $DRIVERS_PATH/ibm_data_server_driver_package_linuxx64_v11.5.tar.gz -C /opt/
    if (($? == 0)); then
      run_process "   Drivers Found. Installing DB2" install_db2
      php -m | grep pdo_ibm
      if (($? >= 1)); then
        echo_with_color red "\nCould not install pdo_ibm extension." >&5
      else
        ### DRIVERS FOR IBM DB2 ( ONLY WITH KEY --with-db2 )
        php -m | grep -E "^ibm_db2"
        if (($? >= 1)); then
          run_process "   Installing ibm_db2 extension" install_db2_extension
          php -m | grep ibm_db2
          if (($? >= 1)); then
            echo_with_color red "\nCould not install ibm_db2 extension." >&5
          else
            echo_with_color green "    IBM DB2 installed\n" >&5
          fi
        fi
      fi
    else
      echo_with_color red "Drivers not found. Skipping...\n" >&5
    fi
    unset DRIVERS_PATH
    cd "${CURRENT_PATH}" || exit 1
    rm -rf /opt/PDO_IBM-1.3.4-patched
  fi
fi

### DRIVERS FOR CASSANDRA ( ONLY WITH KEY --with-cassandra )
php -m | grep -E "^cassandra"
if (($? >= 1)); then
  if [[ $CASSANDRA == TRUE ]]; then
    run_process "   Installing Cassandra" install_cassandra
    php -m | grep cassandra
    if (($? >= 1)); then
      echo_with_color red "\nCould not install cassandra extension." >&5
    else
      echo_with_color green "    Cassandra installed\n" >&5
    fi
  fi
fi

### INSTALL IGBINARY EXT.
php -m | grep -E "^igbinary"
if (($? >= 1)); then
  run_process "   Installing igbinary" install_igbinary
  php -m | grep igbinary
  if (($? >= 1)); then
    echo_with_color red "\nCould not install igbinary extension." >&5
  else
    echo_with_color green "    igbinary installed\n" >&5
  fi
fi

### INSTALL PYTHON BUNCH
if [[ $ADVANCED_CONNECTORS == TRUE ]]; then
  run_process "   Installing python2" install_python2
  check_bunch_installation
  if (($? >= 1)); then
    run_process "   Installing bunch" install_bunch
    check_bunch_installation
    if (($? >= 1)); then
      echo_with_color red "\nCould not install python bunch extension." >&5
    else
      echo_with_color green "    python2 installed\n" >&5
    fi
  fi
else
  echo_with_color green "Skipping legacy python2/bunch baseline install.\n" >&5
fi

### INSTALL PYTHON3 MUNCH
run_process "   Installing python3" install_python3
check_munch_installation
if (($? >= 1)); then
  run_process "   Installing munch" install_munch
  check_munch_installation
  if (($? >= 1)); then
    echo_with_color red "\nCould not install python3 munch extension." >&5
  else
    echo_with_color green "    python3 installed\n" >&5
  fi
fi

### Install Node.js (advanced connectors OR the MCP daemon need it)
if [[ $ADVANCED_CONNECTORS == TRUE || $ENABLE_MCP_DAEMON == TRUE ]]; then
  node -v
  if (($? >= 1)); then
    run_process "   Installing node" install_node
    echo_with_color green "    node installed\n" >&5
  fi
else
  echo_with_color green "Skipping legacy Node.js baseline install.\n" >&5
fi

### INSTALL Snowflake / Advanced ODBC Connector Packs
if [[ $ADVANCED_CONNECTORS == TRUE ]]; then
  if [[ $CURRENT_KERNEL == "debian" || $CURRENT_KERNEL == "ubuntu" ]]; then
    if [[ $APACHE == TRUE ]]; then ### Only with key --apache
      ls /etc/php/${PHP_VERSION_INDEX}/apache2/conf.d | grep "snowflake"
      if (($? >= 1)); then
        run_process "   Installing snowflake" install_snowflake_apache
        echo_with_color green "    Snowflake installed\n" >&5
      fi
    else
      ls /etc/php/${PHP_VERSION_INDEX}/fpm/conf.d | grep "snowflake"
      if (($? >= 1)); then
        run_process "   Installing snowflake" install_snowflake_nginx
        echo_with_color green "    Snowflake installed\n" >&5
      fi
    fi
  else
    #fedora / centos
    ls /etc/php.d | grep "snowflake"
    if (($? >= 1)); then
      if ((CURRENT_OS == 7)); then
        # pdo_snowflake requires gcc 5.2 to install, centos7 only has 4.8 available
        echo_with_color red "Snowflake only supported on CentOS / RHEL 8. Skipping...\n" >&5
      else
        run_process "   Installing Snowflake" install_snowflake
        echo_with_color green "    snowflake installed\n" >&5
      fi
    fi
  fi

  ### INSTALL Hive ODBC Driver
  php -m | grep -E "^odbc"
  if (($? >= 1)); then
    run_process "   Installing hive odbc" install_hive_odbc
    if [[ "${HIVE_ODBC_INSTALLED:-}" != "odbc" ]]; then
      echo_with_color red "\nCould not build hive odbc driver." >&5
    else
      echo_with_color green "    hive odbc installed\n" >&5
    fi
  fi

  ### INSTALL Dremio ODBC Driver
  php -m | grep -E "^odbc"
  if (($? >= 1)); then
    run_process "   Installing dremio odbc" install_dremio_odbc
    if [[ "${DREMIO_ODBC_INSTALLED:-}" != "odbc" ]]; then
      echo_with_color red "\nCould not build dremio odbc driver." >&5
    else
      echo_with_color green "    dremio odbc installed\n" >&5
    fi
  fi

  ### INSTALL Databricks ODBC Driver
  php -m | grep -E "^odbc"
  if (($? >= 1)); then
    run_process "   Installing databricks odbc" install_databricks_odbc
    if [[ "${DATABRICKS_ODBC_INSTALLED:-}" != "odbc" ]]; then
      echo_with_color red "\nCould not build databricks odbc driver." >&5
    else
      echo_with_color green "    databricks odbc installed\n" >&5
    fi
  fi

  ### INSTALL SAP HANA ODBC Driver
  php -m | grep -E "^odbc"
  if (($? >= 1)); then
    run_process "   Installing SAP HANA odbc" install_hana_odbc
    if [[ "${HANA_ODBC_INSTALLED:-}" != "odbc" ]]; then
      echo_with_color red "\nCould not build SAP HANA odbc driver." >&5
    else
      echo_with_color green "    SAP HANA odbc installed\n" >&5
    fi
  fi
else
  echo_with_color green "Skipping advanced analytics connectors (Snowflake + ODBC packs).\n" >&5
fi

### Configuring PHP OPCache and JIT compilation
run_process "   Configuring PHP OPCache and JIT compilation" enable_opcache
mark_phase_done "PHASE_PHP_EXTENSIONS"
unset ACTIVE_PHASE
else
  echo_with_color green "   Phase already complete. Skipping PHP extensions configuration.\n" >&5
fi

if [[ $APACHE == TRUE ]]; then
  if [[ $CURRENT_KERNEL == "ubuntu" || $CURRENT_KERNEL == "debian" ]]; then
    service apache2 reload
  else
    #fedora / centos
    systemctl restart httpd.service
  fi
else
  if [[ $CURRENT_KERNEL == "ubuntu" || $CURRENT_KERNEL == "debian" ]]; then
    service ${PHP_VERSION}-fpm reload
  else
    #fedora / centos
    systemctl restart php-fpm.service
  fi
fi
echo_with_color green "PHP Extensions configured.\n" >&5

### Step 5. Installing Composer
echo_with_color blue "Step 5: Installing Composer...\n" >&5
if ! is_phase_done "PHASE_COMPOSER"; then
  ACTIVE_PHASE="PHASE_COMPOSER"
  run_process "   Installing Composer" install_composer
  mark_phase_done "PHASE_COMPOSER"
  unset ACTIVE_PHASE
else
  echo_with_color green "   Phase already complete. Skipping Composer installation.\n" >&5
fi
echo_with_color green "Composer installed.\n" >&5

### Step 6. Installing MySQL
if ! is_phase_done "PHASE_DATABASE"; then
ACTIVE_PHASE="PHASE_DATABASE"
if [[ $MYSQL == TRUE ]]; then ### Only with key --with-mysql
  echo_with_color blue "Step 6: Installing System Database for DreamFactory...\n" >&5
  run_process "  Checking for existing MySqlDatabase" check_mysql_exists

  if ((CHECK_MYSQL_PROCESS == 0)) || ((CHECK_MYSQL_INSTALLATION == 0)) || ((CHECK_MYSQL_PORT == 0)); then
    echo_with_color red "MySQL Database detected in the system. Skipping installation. \n" >&5
    DB_FOUND=TRUE
  else
    if [[ $CURRENT_KERNEL == "ubuntu" || $CURRENT_KERNEL == "debian" ]]; then
      run_process "   Adding mariadb repo" add_mariadb_repo
      run_process "   Updating System" system_update
    fi
    if [[ -t 0 ]]; then
      echo_with_color magenta "Please choose a strong MySQL root user password: " >&5
      read -r -s DB_PASS
      if [[ -z $DB_PASS ]]; then
        until [[ -n $DB_PASS ]]; do
          echo_with_color red "The password can't be empty!" >&5
          read -r -s DB_PASS
        done
      fi
    else
      DB_PASS="${DB_PASS:-${MYSQL_ROOT_PASSWORD:-$(generate_admin_password)}}"
    fi
    echo_with_color green "\nPassword accepted.\n" >&5
    if [[ $CURRENT_KERNEL == "ubuntu" || $CURRENT_KERNEL == "debian" ]]; then
      # Disable interactive mode in installation mariadb. Set generated above password.
      export DEBIAN_FRONTEND="noninteractive"
      debconf-set-selections <<<"mariadb-server mysql-server/root_password password $DB_PASS"
      debconf-set-selections <<<"mariadb-server mysql-server/root_password_again password $DB_PASS"
    fi
    run_process "   Installing MariaDB" install_mariadb
  fi
  echo_with_color green "Database for DreamFactory installed.\n" >&5

  ### Step 7. Configuring DreamFactory system database
  echo_with_color blue "Step 7: Configure DreamFactory system database.\n" >&5

  DB_INSTALLED=FALSE

  # The MySQL database has already been installed, so let's configure
  # the DreamFactory system database.
  if [[ $DB_FOUND == TRUE ]]; then
    echo_with_color magenta "Is DreamFactory MySQL system database already configured? [Yy/Nn] " >&5
    if [[ -t 0 ]]; then
      read -r DB_ANSWER
    else
      DB_ANSWER="${DF_SYSTEM_DB_CONFIGURED:-N}"
    fi
    if [[ -z $DB_ANSWER ]]; then
      DB_ANSWER=Y
    fi
    if [[ $DB_ANSWER =~ ^[Yy]$ ]]; then
      DB_INSTALLED=TRUE
    # MySQL system database is not installed, but MySQL is, so let's
    # prompt the user for the root password.
    else
      echo_with_color magenta "\n Enter MySQL root password:  " >&5
      if [[ -t 0 ]]; then
        read -r DB_PASS
      else
        DB_PASS="${DB_PASS:-${MYSQL_ROOT_PASSWORD:-}}"
      fi

      # Test DB access
      mysql -h localhost -u root "-p$DB_PASS" -e"quit"
      if (($? >= 1)); then
        ACCESS=FALSE
        TRYS=0
        until [[ $ACCESS == TRUE ]]; do
          echo_with_color red "\nPassword incorrect!\n " >&5
          echo_with_color magenta "Enter root user password:\n " >&5
          if [[ -t 0 ]]; then
            read -r -s DB_PASS
          else
            echo_with_color red "\nNon-interactive MySQL configuration requires DB_PASS or MYSQL_ROOT_PASSWORD for an existing database. Exit.\n" >&5
            exit 1
          fi
          mysql -h localhost -u root "-p$DB_PASS" -e"quit"
          if (($? == 0)); then
            ACCESS=TRUE
          fi
          TRYS=$((TRYS + 1))
          if ((TRYS == 3)); then
            echo_with_color red "\nExit.\n" >&5
            exit 1
          fi
        done
      fi
    fi
  fi
  # If the DreamFactory system database not already installed,
  # let's install it.
  if [[ $DB_INSTALLED == FALSE ]]; then

    # Test DB access
    mysql -h localhost -u root "-p$DB_PASS" -e"quit"
    if (($? >= 1)); then
      echo_with_color red "Connection to Database failed. Exit \n" >&5
      exit 1
    fi
    echo_with_color magenta "\n What would you like to name your system database? (e.g. dreamfactory) " >&5
    if [[ -t 0 ]]; then
      read -r DF_SYSTEM_DB
      if [[ -z $DF_SYSTEM_DB ]]; then
        until [[ -n $DF_SYSTEM_DB ]]; do
          echo_with_color red "\nThe name can't be empty!" >&5
          read -r DF_SYSTEM_DB
        done
      fi
    else
      DF_SYSTEM_DB="${DF_SYSTEM_DB:-dreamfactory}"
    fi

    echo "CREATE DATABASE ${DF_SYSTEM_DB};" | mysql -u root "-p${DB_PASS}" 2>&5
    if (($? >= 1)); then
      echo_with_color red "\nCreating database error. Exit" >&5
      exit 1
    fi
    echo_with_color magenta "\n Please create a MySQL DreamFactory system database user name (e.g. dfadmin): " >&5
    if [[ -t 0 ]]; then
      read -r DF_SYSTEM_DB_USER
      if [[ -z $DF_SYSTEM_DB_USER ]]; then
        until [[ -n $DF_SYSTEM_DB_USER ]]; do
          echo_with_color red "The name can't be empty!" >&5
          read -r DF_SYSTEM_DB_USER
        done
      fi
    else
      DF_SYSTEM_DB_USER="${DF_SYSTEM_DB_USER:-dfadmin}"
    fi
    echo_with_color magenta "\n Please create a secure MySQL DreamFactory system database user password: " >&5
    if [[ -t 0 ]]; then
      read -r -s DF_SYSTEM_DB_PASSWORD
      if [[ -z $DF_SYSTEM_DB_PASSWORD ]]; then
        until [[ -n $DF_SYSTEM_DB_PASSWORD ]]; do
          echo_with_color red "The password can't be empty!" >&5
          read -r -s DF_SYSTEM_DB_PASSWORD
        done
      fi
    else
      DF_SYSTEM_DB_PASSWORD="${DF_SYSTEM_DB_PASSWORD:-$(generate_admin_password)}"
    fi
    # Generate password for user in DB
    echo "GRANT ALL PRIVILEGES ON ${DF_SYSTEM_DB}.* to \"${DF_SYSTEM_DB_USER}\"@\"localhost\" IDENTIFIED BY \"${DF_SYSTEM_DB_PASSWORD}\";" | mysql -u root "-p${DB_PASS}" 2>&5
    if (($? >= 1)); then
      echo_with_color red "\nCreating new user error. Exit" >&5
      exit 1
    fi
    echo "FLUSH PRIVILEGES;" | mysql -u root "-p${DB_PASS}"

    echo -e "\nDatabase configuration finished.\n" >&5
    if [[ ! -t 0 ]]; then
      DB_CRED_FILE="/var/lib/dreamfactory-installer/db_credentials.env"
      printf 'mysql_root_password=%s\ndb_name=%s\ndb_user=%s\ndb_password=%s\n' \
        "$DB_PASS" "$DF_SYSTEM_DB" "$DF_SYSTEM_DB_USER" "$DF_SYSTEM_DB_PASSWORD" > "$DB_CRED_FILE"
      chmod 600 "$DB_CRED_FILE"
      echo_with_color green "Database credentials saved to $DB_CRED_FILE (chmod 600)." >&5
    fi
  else
    echo_with_color green "Skipping...\n" >&5
  fi
else
  echo_with_color green "Step 6: Skipping DreamFactory system database installation.\n" >&5
  echo_with_color green "Step 7: Skipping DreamFactory system database configuration.\n" >&5
fi
mark_phase_done "PHASE_DATABASE"
unset ACTIVE_PHASE
else
  echo_with_color green "   Phase already complete. Skipping system database installation/configuration.\n" >&5
fi

### Step 8. Install DreamFactory
echo_with_color blue "Step 8: Installing DreamFactory...\n " >&5

ls -d /opt/dreamfactory
if (($? >= 1)); then
  if ! is_phase_done "PHASE_DF_SOURCE"; then
    ACTIVE_PHASE="PHASE_DF_SOURCE"
    run_process "   Cloning DreamFactory repository" clone_dreamfactory_repository
    mark_phase_done "PHASE_DF_SOURCE"
    unset ACTIVE_PHASE
  else
    echo_with_color green "   Phase already complete. Skipping DreamFactory source clone." >&5
  fi
else
  echo_with_color red "DreamFactory detected.\n" >&5
  DF_CLEAN_INSTALLATION=FALSE
  mark_phase_done "PHASE_DF_SOURCE"
fi

if ! is_phase_done "PHASE_DF_COMPOSER_FILES"; then
  install_composer_files_if_available "$DEFAULT_LICENSE_PATH"
  mark_phase_done "PHASE_DF_COMPOSER_FILES"
else
  echo_with_color green "   Phase already complete. Skipping commercial composer file check." >&5
fi

chown -R "$CURRENT_USER" /opt/dreamfactory && cd /opt/dreamfactory || exit 1

if ! is_phase_done "PHASE_DF_CODE"; then
  ACTIVE_PHASE="PHASE_DF_CODE"
  run_process "   Installing DreamFactory"  run_composer_install
  mark_phase_done "PHASE_DF_CODE"
  unset ACTIVE_PHASE
else
  echo_with_color green "   Phase already complete. Skipping composer install." >&5
fi

### Shutdown silent mode because php artisan df:setup and df:env will get troubles with prompts.
exec 1>&5 5>&-

if ! is_phase_done "PHASE_DF_CONFIG"; then
  if [[ $DB_INSTALLED == FALSE ]]; then
    sudo -u "$CURRENT_USER" bash -c "php artisan df:env -q \
                  --db_connection=mysql \
                  --db_host=127.0.0.1 \
                  --db_port=3306 \
                  --db_database=${DF_SYSTEM_DB} \
                  --db_username=${DF_SYSTEM_DB_USER} \
                  --db_password=${DF_SYSTEM_DB_PASSWORD//\'/} \
                  --df_install=Linux"
    sed -i 's/\#DB\_CHARSET\=/DB\_CHARSET\=utf8/g' .env
    sed -i 's/\#DB\_COLLATION\=/DB\_COLLATION\=utf8\_unicode\_ci/g' .env
    echo -e "\n"
    MYSQL_INSTALLED=TRUE

  elif [[ ! $MYSQL == TRUE && $DF_CLEAN_INSTALLATION == TRUE ]] || [[ $DB_INSTALLED == TRUE ]]; then
    sudo -u "$CURRENT_USER" bash -c "php artisan df:env --df_install=Linux"
    if [[ $DB_INSTALLED == TRUE ]]; then
      sed -i 's/\#DB\_CHARSET\=/DB\_CHARSET\=utf8/g' .env
      sed -i 's/\#DB\_COLLATION\=/DB\_COLLATION\=utf8\_unicode\_ci/g' .env
    fi
  fi

  # Guardrail: on non-interactive sqlite installs, DB_DATABASE can remain blank.
  # Force the standard sqlite path so migrate/seed does not fail with SQLSTATE[HY000] [14].
  if grep -q '^DB_CONNECTION=sqlite$' .env && grep -q '^DB_DATABASE=$' .env; then
    sed -i 's|^DB_DATABASE=$|DB_DATABASE=/opt/dreamfactory/storage/databases/database.sqlite|' .env
    touch /opt/dreamfactory/storage/databases/database.sqlite
    chown "$CURRENT_USER":"$CURRENT_USER" /opt/dreamfactory/storage/databases/database.sqlite
  fi

  mark_phase_done "PHASE_DF_CONFIG"
else
  echo_with_color green "   Phase already complete. Skipping DreamFactory env configuration." 
fi

if ! is_phase_done "PHASE_DF_BOOTSTRAP"; then
  if [[ $DF_CLEAN_INSTALLATION == TRUE ]]; then
    if [[ -t 0 ]]; then
      sudo -u "$CURRENT_USER" bash -c "php artisan df:setup"
    else
      DF_ADMIN_FIRST_NAME="${DF_ADMIN_FIRST_NAME:-DreamFactory}"
      DF_ADMIN_LAST_NAME="${DF_ADMIN_LAST_NAME:-Admin}"
      DF_ADMIN_PHONE="${DF_ADMIN_PHONE:-555-0100}"
      if [[ -z "${DF_ADMIN_EMAIL:-}" ]]; then
        echo_with_color red "Non-interactive install requires an admin email. Set DF_ADMIN_EMAIL=you@example.com (and optionally DF_ADMIN_PASSWORD) and rerun. Exiting..." >&5
        exit 1
      fi
      DF_ADMIN_PASSWORD_GENERATED=FALSE
      if [[ -z "${DF_ADMIN_PASSWORD:-}" ]]; then
        DF_ADMIN_PASSWORD="$(generate_admin_password)"
        DF_ADMIN_PASSWORD_GENERATED=TRUE
      fi
      sudo -u "$CURRENT_USER" bash -c "php artisan df:setup --force --no-interaction \
        --admin_first_name='${DF_ADMIN_FIRST_NAME}' \
        --admin_last_name='${DF_ADMIN_LAST_NAME}' \
        --admin_email='${DF_ADMIN_EMAIL}' \
        --admin_password='${DF_ADMIN_PASSWORD}' \
        --admin_phone='${DF_ADMIN_PHONE}'"
      if [[ $DF_ADMIN_PASSWORD_GENERATED == TRUE ]]; then
        DF_CRED_FILE="/opt/dreamfactory/.admin_credentials"
        printf 'admin_email=%s\nadmin_password=%s\n' "$DF_ADMIN_EMAIL" "$DF_ADMIN_PASSWORD" > "$DF_CRED_FILE"
        chown "$CURRENT_USER":"$CURRENT_USER" "$DF_CRED_FILE" 2>/dev/null || true
        chmod 600 "$DF_CRED_FILE"
        echo_with_color green "A random admin password was generated and saved to $DF_CRED_FILE (chmod 600). Retrieve it, then change it after first login." >&5
      fi
    fi
  fi
  mark_phase_done "PHASE_DF_BOOTSTRAP"
else
  echo_with_color green "   Phase already complete. Skipping DreamFactory bootstrap." 
fi

if ! is_phase_done "PHASE_FINAL_VERIFY"; then
  if [[ $LICENSE_INSTALLED == TRUE || $DF_CLEAN_INSTALLATION == FALSE ]]; then
    fix_dreamfactory_runtime_permissions
    sudo -u "$CURRENT_USER" bash -c "php artisan migrate --seed --force"
    sudo -u "$CURRENT_USER" bash -c "php artisan config:clear -q"

    if [[ $LICENSE_INSTALLED == TRUE ]]; then
      if [[ -n "${DF_LICENSE_KEY:-}" || ! -t 0 ]]; then
        # Non-interactive install: take the license key from the DF_LICENSE_KEY env var (or skip).
        if [[ -n "${DF_LICENSE_KEY:-}" ]]; then
          if grep -q '^DF_LICENSE_KEY=' .env 2>/dev/null; then
            sed -i "s|^DF_LICENSE_KEY=.*|DF_LICENSE_KEY=${DF_LICENSE_KEY}|" .env
          else
            echo -e "\nDF_LICENSE_KEY=${DF_LICENSE_KEY}" >>.env
          fi
          echo_with_color green "   License key configured from DF_LICENSE_KEY env." >&5
        else
          echo_with_color red "   Non-interactive install with no DF_LICENSE_KEY set; skipping license key." >&5
        fi
      else
      grep DF_LICENSE_KEY .env >/dev/null 2>&1 # Check for existing key.
      if (($? == 0)); then
        echo_with_color red "\nThe license key is already installed. Do you want to install a new key? [Yy/Nn]"
        read -r KEY_ANSWER
        if [[ -z $KEY_ANSWER ]]; then
          KEY_ANSWER=N
        fi
        NEW_KEY=TRUE
      fi

      if [[ $NEW_KEY == TRUE ]]; then
        if [[ $KEY_ANSWER =~ ^[Yy]$ ]]; then #Install new key
          CURRENT_KEY=$(grep DF_LICENSE_KEY .env)
          echo_with_color magenta "\nPlease provide your new license key:"
          read -r LICENSE_KEY
          size=${#LICENSE_KEY}
          if [[ -z $LICENSE_KEY ]]; then
            until [[ -n $LICENSE_KEY ]]; do
              echo_with_color red "\nThe field can't be empty!"
              read -r LICENSE_KEY
              size=${#LICENSE_KEY}
            done
          elif ((size != 32)); then
            until ((size == 32)); do
              echo_with_color red "\nInvalid License Key provided"
              echo_with_color magenta "\nPlease provide your license key:"
              read -r LICENSE_KEY
              size=${#LICENSE_KEY}
            done
          fi
          ###Change license key in .env file
          sed -i "s/$CURRENT_KEY/DF_LICENSE_KEY=$LICENSE_KEY/" .env
        else
          echo_with_color red "\nSkipping..." #Skip if key found in .env file and no need to update
        fi
      else
        echo_with_color magenta "\nPlease provide your license key:" #Install key if not found existing key.
        read -r LICENSE_KEY
        size=${#LICENSE_KEY}
        if [[ -z $LICENSE_KEY ]]; then
          until [[ -n $LICENSE_KEY ]]; do
            echo_with_color red "The field can't be empty!"
            read -r LICENSE_KEY
            size=${#LICENSE_KEY}
          done
        elif ((size != 32)); then
          until ((size == 32)); do
            echo_with_color red "\nInvalid License Key provided"
            echo_with_color magenta "\nPlease provide your license key:"
            read -r LICENSE_KEY
            size=${#LICENSE_KEY}
          done
        fi
        ###Add license key to .env file
        echo -e "\nDF_LICENSE_KEY=${LICENSE_KEY}" >>.env
      fi
      fi
    fi
  fi

  if [[ $APACHE == TRUE ]]; then
    chmod -R 2775 /opt/dreamfactory/
    if [[ $CURRENT_KERNEL == "debian" || $CURRENT_KERNEL == "ubuntu" ]]; then
      chown -R "www-data:$CURRENT_USER" /opt/dreamfactory/
    else
      chown -R "apache:$CURRENT_USER" /opt/dreamfactory/
    fi
  fi

  NODE_PATH="${NODE_PATH:-$(command -v node 2>/dev/null || true)}"
  if [[ -n "$NODE_PATH" ]]; then
    sed -i "s|^#DF_NODEJS_PATH=.*|DF_NODEJS_PATH=$NODE_PATH|" .env
    sed -i "s|^DF_NODEJS_PATH=$|DF_NODEJS_PATH=$NODE_PATH|" .env
  fi

  PYTHON_BIN_PATH="$(command -v python2 2>/dev/null || command -v python3 2>/dev/null || true)"
  if [[ -n "$PYTHON_BIN_PATH" ]]; then
    sed -i "s|^#DF_PYTHON_PATH=.*|DF_PYTHON_PATH=$PYTHON_BIN_PATH|" .env
    sed -i "s|^DF_PYTHON_PATH=$|DF_PYTHON_PATH=$PYTHON_BIN_PATH|" .env
  fi

  fix_dreamfactory_runtime_permissions
  sudo -u "$CURRENT_USER" bash -c "php artisan cache:clear -q"

  #Add rules if SELinux enabled, redhat systems only
  if [[ $CURRENT_KERNEL == "centos" || $CURRENT_KERNEL == "rhel" || $CURRENT_KERNEL == "almalinux" || $CURRENT_KERNEL == "rocky" || $CURRENT_KERNEL == "fedora" ]]; then
    sestatus | grep SELinux | grep enabled >/dev/null
    if (($? == 0)); then
      setsebool -P httpd_can_network_connect_db 1
      chcon -t httpd_sys_content_t storage -R
      chcon -t httpd_sys_content_t bootstrap/cache/ -R
      chcon -t httpd_sys_rw_content_t storage -R
      chcon -t httpd_sys_rw_content_t bootstrap/cache/ -R
    fi
  fi

  ### Add Permissions and Ownerships
  if [[ ! $APACHE == TRUE ]]; then
    echo_with_color blue "Adding Permissions and Ownerships...\n"
    if id dreamfactory >/dev/null 2>&1; then
      echo_with_color blue "    User 'dreamfactory' already exists"
    else
      echo_with_color blue "    Creating user 'dreamfactory'"
      useradd dreamfactory
    fi
    if [[ $CURRENT_KERNEL == "ubuntu" || $CURRENT_KERNEL == "debian" ]]; then
      PHP_VERSION_NUMBER=$(php --version 2>/dev/null | head -n 1 | cut -d " " -f 2 | cut -c 1,2,3)
    fi
    echo_with_color blue "    Updating php-fpm user, group, and owner"
    if [[ $CURRENT_KERNEL == "ubuntu" || $CURRENT_KERNEL == "debian" ]]; then
      sed -i "s,www-data,dreamfactory," /etc/php/$PHP_VERSION_NUMBER/fpm/pool.d/www.conf
    else
      # centos, fedora
      sed -i "s,;listen.owner = nobody,listen.owner = dreamfactory," /etc/php-fpm.d/www.conf
      sed -i "s,;listen.group = nobody,listen.group = dreamfactory," /etc/php-fpm.d/www.conf
      sed -i "s,;listen.mode = 0660,listen.mode = 0660\nuser = dreamfactory\ngroup = dreamfactory," /etc/php-fpm.d/www.conf
      sed -i "s,listen.acl_users,;listen.acl_users," /etc/php-fpm.d/www.conf
    fi
    if (($? == 0)); then
      usermod -a -G dreamfactory "$CURRENT_USER"
      if [[ $CURRENT_KERNEL == "ubuntu" || $CURRENT_KERNEL == "debian" ]]; then
        usermod -a -G dreamfactory www-data
      else
        # centos, fedora
        usermod -a -G dreamfactory nginx
      fi
      echo_with_color blue "    Changing ownership and permission of /opt/dreamfactory to 'dreamfactory' user"
      fix_dreamfactory_runtime_permissions
      echo_with_color blue "    Restarting nginx and php-fpm"
      if [[ $CURRENT_KERNEL == "ubuntu" || $CURRENT_KERNEL == "debian" ]]; then
        service nginx restart
      else
        systemctl restart nginx.service
      fi
      if (($? >= 1)); then
        echo_with_color red "nginx failed to restart\n"
        exit 1
      else
        if [[ $CURRENT_KERNEL == "ubuntu" || $CURRENT_KERNEL == "debian" ]]; then
          service php$PHP_VERSION_NUMBER-fpm restart
        else
          # centos, fedora
          systemctl restart php-fpm.service
        fi
        if (($? >= 1)); then
          echo_with_color red "php-fpm failed to restart\n"
          exit 1
        fi
        echo_with_color green "Done! Ownership and Permissions changed to user 'dreamfactory'\n"
      fi
    else
      echo_with_color red "Unable to update php-fpm www.conf file. Please check the file location of www.conf"
    fi
  fi

  ### Build and install the MCP daemon as a systemd service if enabled
  if [[ $ENABLE_MCP_DAEMON == TRUE ]]; then
    echo_with_color blue "Setting up MCP daemon (build + systemd service)...\n" >&5
    if setup_mcp_daemon_service; then
      echo_with_color green "MCP daemon installed and started (df-mcp.service on 127.0.0.1:8006).\n" >&5
    else
      echo_with_color red "MCP daemon setup failed; DreamFactory is installed but MCP is not running.\n" >&5
    fi
  fi

  echo_with_color green "Installation finished! DreamFactory has been installed in /opt/dreamfactory "

  if [[ $DEBUG == TRUE ]]; then
    echo_with_color red "\nThe log file saved in: /tmp/dreamfactory_installer.log "
  fi

  ### Summary table
  if [[ $MYSQL_INSTALLED == TRUE ]]; then
    sed -i "s/\#DB\_CONNECTION\=sqlite/DB\_CONNECTION\=mysql/g" .env
    sed -i "s/\#DB\_HOST\=/DB\_HOST\=127.0.0.1/g" .env
    sed -i "s/\#DB\_PORT\=/DB\_PORT\=3306/g" .env
    sed -i "s/\#DB\_DATABASE\=/DB\_DATABASE\=$DF_SYSTEM_DB/g" .env
    sed -i "s/\#DB\_USERNAME\=/DB\_USERNAME\=$DF_SYSTEM_DB_USER/g" .env
    sed -i "s/\#DB\_PASSWORD\=/DB\_PASSWORD\=$DF_SYSTEM_DB_PASSWORD/g" .env

    echo -e "\n "
    echo_with_color magenta "******************************"
    echo -e " DB for system table: mysql "
    echo -e " DB host: 127.0.0.1         "
    echo -e " DB port: 3306              "
    if [[ ! $DB_FOUND == TRUE ]]; then
      echo -e " DB root password: $DB_PASS"
    fi
    echo -e " DB name: $DF_SYSTEM_DB"
    echo -e " DB user: $DF_SYSTEM_DB_USER"
    echo -e " DB password: $DF_SYSTEM_DB_PASSWORD"
    echo -e "******************************\n"
  fi

  mark_phase_done "PHASE_FINAL_VERIFY"
else
  echo_with_color green "   Phase already complete. Skipping final verification and ownership updates." 
fi

exit 0
