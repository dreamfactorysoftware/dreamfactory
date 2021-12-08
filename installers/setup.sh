#!/bin/bash
# Colors schemes for echo:
RD='\033[0;31m' # Red
BL='\033[1;34m' # Blue
GN='\033[0;32m' # Green
MG='\033[0;95m' # Magenta
NC='\033[0m'    # No Color

ERROR_STRING="Installation error. Exiting"
CURRENT_PATH=$(pwd)

DEFAULT_PHP_VERSION="php7.4"

CURRENT_KERNEL=$(grep -w ID /etc/os-release | cut -d "=" -f 2 | tr -d '"')
CURRENT_OS=$(grep -e VERSION_ID /etc/os-release | cut -d "=" -f 2 | cut -d "." -f 1 | tr -d '"')

ERROR_STRING="Installation error. Exiting"

CURRENT_PATH=$(pwd)
# CHECK FOR KEYS
while [[ -n $1 ]]; do
  case "$1" in
  --with-oracle) ORACLE=TRUE ;;
  --with-mysql) MYSQL=TRUE ;;
  --with-apache) APACHE=TRUE ;;
  --with-db2) DB2=TRUE ;;
  --with-cassandra) CASSANDRA=TRUE ;;
  --with-tag=*)
    DREAMFACTORY_VERSION_TAG="${1/--with-tag=/}"
    ;;
  --with-tag)
    DREAMFACTORY_VERSION_TAG="$2"
    shift
    ;;
  --debug) DEBUG=TRUE ;;
  --help) HELP=TRUE ;;
  -h) HELP=TRUE ;;
  *)
    echo -e "\n${RD}Invalid flag detected… aborting.${NC}"
    HELP=TRUE
    break
    ;;
  esac
  shift
done

if [[ $HELP == TRUE ]]; then
  echo -e "\nList of available keys:\n"
  echo "   --with-oracle                  Install driver and PHP extensions for work with Oracle DB"
  echo "   --with-mysql                   Install MariaDB as default system database for DreamFactory"
  echo "   --with-apache                  Install Apache2 web server for DreamFactory"
  echo "   --with-db2                     Install driver and PHP extensions for work with IBM DB2"
  echo "   --with-cassandra               Install driver and PHP extensions for work with Cassandra DB"
  echo "   --with-tag=<tag name>          Install DreamFactory with specific version.  "
  echo "   --debug                        Enable installation process logging to file in /tmp folder."
  echo -e "   -h, --help                     Show this help\n"
  exit 1
fi

if [[ ! $DEBUG == TRUE ]]; then
  exec 5>&1            # Save a copy of STDOUT
  exec >/dev/null 2>&1 # Redirect STDOUT to Null
else
  exec 5>&1 # Save a copy of STDOUT. Used because all echo redirects output to 5.
  exec >/tmp/dreamfactory_installer.log 2>&1
fi

clear >&5

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

#### INSTALLER ####

### Check installers will run in current environment.
case $CURRENT_KERNEL in
  ubuntu)
    if ((CURRENT_OS != 18)) && ((CURRENT_OS != 20)); then
      echo_with_color red "The installer only supports Ubuntu 18 and 20. Exiting...\n" >&5
      exit 1
    fi 
    ;;
  debian)
    if ((CURRENT_OS == 9)) && ((CURRENT_OS == 10)); then
      echo_with_color red "The installer only supports Debian 9 and 10. Exiting...\n" >&5
      exit 1
    fi
    ;;
  centos | rhel)
    if ((CURRENT_OS == 7)) && ((CURRENT_OS == 8)); then
      echo_with_color red "The installer only supports Rhel (Centos) 7 and 8. Exiting...\n" >&5
      exit 1
    fi
    ;;
  fedora)
    if ((CURRENT_OS == 32)) && ((CURRENT_OS == 33)) && ((CURRENT_OS == 34)); then
      echo_with_color red "The installer only supports Fedora 32, 33, and 34. Exiting...\n" >&5
      exit 1
    fi
    ;;
  *)
    echo_with_color red "Installer only supported on Ubuntu, Debian, Rhel (Centos) and Fedora. Exiting...\n" >&5
    exit 1
    ;;

esac

# Make sure script run as sudo
if ((EUID != 0)); then
  echo -e "${RD}\nPlease run script with root privileges: sudo $0 \n" >&5
  exit 1
fi

# Retrieve executing user's username
CURRENT_USER=$(logname)

if [[ -z $SUDO_USER ]] && [[ -z $CURRENT_USER ]]; then
  echo_with_color red "Enter username for installation DreamFactory:" >&5
  read -r CURRENT_USER
  if [[ $CURRENT_KERNEL == "debian" ]]; then
    su "${CURRENT_USER}" -c "echo 'Checking user availability'" >&5
    if (($? >= 1)); then
      echo 'Please provide another user' >&5
      exit 1
    fi
  fi
fi

if [[ -n $SUDO_USER ]]; then
  CURRENT_USER=${SUDO_USER}
fi

# Sudo should be used to run the script, but CURRENT_USER themselves should not be root (i.e should be another user running with sudo),
# otherwise composer will get annoyed. If the user wishes to continue as root, then an environment variable will be set when 'composer install' is run later on in the script.
if [[ $CURRENT_USER == "root" ]]; then
  echo -e "WARNING: Although this script must be run with sudo, it is not recommended to install DreamFactory as root (specifically 'composer' commands) Would you like to:\n [1] Continue as root\n [2] Provide username for installing DreamFactory" >&5
  read -r INSTALL_AS_ROOT
  if [[ $INSTALL_AS_ROOT == 1 ]]; then
    echo -e "Continuing installation as root" >&5
  else
    echo -e "Enter username for installing DreamFactory" >&5
    read -r CURRENT_USER
    echo -e "User: ${CURRENT_USER} selected. Continuing" >&5
  fi
fi

#Go into the individual scripts here
case $CURRENT_KERNEL in

  ubuntu)
    source ./ubuntu.sh
    ;;

  debian)
    source ./debian.sh
    ;;

  centos | rhel)
    source ./centos.sh
    ;;

  fedora)
    source ./fedora.sh
    ;;
esac

exit 0