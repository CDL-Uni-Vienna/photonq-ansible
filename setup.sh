#!/usr/bin/env bash
# shellcheck disable=SC1090

# It is highly recommended to use set -eEuo pipefail for every setup script
set -o errexit  # Used to exit upon error, avoiding cascading errors
set -o errtrace # Activate traps to catch errors on exit
set -o pipefail # Unveils hidden failures
set -o nounset  # Exposes unset variables

#### SPECIAL FUNCTIONS #####
# Functions with the purpose of making coding more convenient and
# debugging a bit easier.
# Disclaimer: "SPECIAL FUNCTIONS" are not test functions!
#
# NOTE: SPECIAL FUNCTIONS start with three CAPS letter.
#
# IF YOU ARE AWARE OF A BETTER FORM OF NAMING FEEL FREE TO OPEN A ISSUE
# OTHERWISE PLEASE USE THIS AS A GUIDELINE FOR ANY COMMIT.
EOS_string(){
    # allows to store EOFs in strings
    IFS=$'\n' read -r -d '' $1 || true;
    return $?
} 2>/dev/null

source /etc/os-release # source os release environment variables

# SYSTEM / USER VARIABLES
readonly __DISTRO="${ID}" # get distro id from /etc/os-release
readonly __DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # workdir
readonly __FILE="${__DIR}/$(basename "${BASH_SOURCE[0]}")" # self
readonly __BASE="$(basename ${__FILE})" # workdir/self
readonly __ROOT="$(cd "$(dirname "${__DIR}")" && pwd)" # homedir

# DEPENDENCY / LOGS VARIABLES
# GINAvbs has currently one dependency that needs to be installed
readonly __GINA_DEPS=(python3)
# Location of installation logs
readonly __GINA_LOGS="${__DIR}/install.log"

# SETUP VARIABLES
# Define and set default for enviroment variables
SSHKEY=${GINA_SSHKEY:-""}
HOSTS=${SETUP_HOSTS:-""}
USER=${GINA_USER:-""}
PASSWORD=${GINA_PASSWORD:-""}

# COLOR / FORMAT VARIABLES
# Set some colors because without them ain't fun
COL_NC='\e[0m' # default color

COL_LIGHT_GREEN='\e[1;32m' # green
COL_LIGHT_RED='\e[1;31m' # red
COL_LIGHT_MAGENTA='\e[1;95m' # magenta

TICK="[${COL_LIGHT_GREEN}✓${COL_NC}]" # green thick
CROSS="[${COL_LIGHT_RED}✗${COL_NC}]" # red cross
INFO="[i]" # info sign

# shellcheck disable=SC2034
DONE="${COL_LIGHT_GREEN} done!${COL_NC}" # a small motivation ^^
OVER="\\r\\033[K" # back to line start

# LOGO / LICENSE / MANPAGE VARIABLES
# Our temporary logo, might be updated in the future
EOS_string LOGO <<-'EOS'
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
+                      ___________   _____        __                           +
+                     / ____/  _/ | / /   |_   __/ /_  _____                   +
+                    / / __ / //  |/ / /| | | / / __ \/ ___/                   +
+                   / /_/ // // /|  / ___ | |/ / /_/ (__  )                    +
+                   \____/___/_/ |_/_/  |_|___/_.___/____/                     +
+                                                                              +
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
EOS

# Licensing, recommedations and warnings
EOS_string LICENSE <<-'EOS'
+ # MIT License
+ #
+ # Copyright (c) 2022 Florian Herbert Kleber IT
+ #
+ # Permission is hereby granted, free of charge, to any person obtaining a copy
+ # of this software and associated documentation files (the "Software"), to deal
+ # in the Software without restriction, including without limitation the rights
+ # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
+ # copies of the Software, and to permit persons to whom the Software is
+ # furnished to do so, subject to the following conditions:
+ #
+ # The above copyright notice and this permission notice shall be included in all
+ # copies or substantial portions of the Software.
+ #
+ # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
+ # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ # SOFTWARE.
+
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
EOS

# This line serves decorative purposes only
EOS_string COOL_LINE <<-'EOS'
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
EOS


######## FUNCTIONS #########
#
# FUNCTIONS are written in lowercase
#
# IF YOU ARE AWARE OF A BETTER NAMING SCHEME FEEL FREE TO OPEN AN ISSUE
# OTHERWISE PLEASE USE THIS AS A GUIDELINE FOR ANY COMMIT

install() {
    # Install GINAvbs and dependency packages passed in via an argument array
    declare -a _argArray1=(${!1})
    declare -a _installArray=("")
    
    # Debian based package install - debconf will download the entire package
    # list so we just create an array of any packages missing to
    # cut down on the amount of download traffic.
    
    for i in "${_argArray1[@]}"; do
        echo -ne "+ ${INFO} Checking for ${i}..."
        if [[ $(which "${i}" 2>/dev/null) ]]; then
            echo -e "+ [${TICK}] Checking for ${i} (is installed)"
        else
            echo -e "+ ${INFO} Checking for ${i} (will be installed)"
            _installArray+=("${i}")
        fi 2>/dev/null
    done
    
    case ${__DISTRO} in
        'alpine')
            if [[ ${_installArray[@]} ]]; then
                # Installing Packages
                apk add --force ${_installArray[@]}
                # Cleaning cached files
                rm -rf /var/cache/apk/* /var/cache/distfiles/*
                
                echo -e "+ [${TICK}] All dependencies are now installed"
            fi
        ;;
        'arch'|'manjaro')
            if [[ ${_installArray[@]} ]]; then
                # Installing Packages if script was started as root
                if [[ $(pacman -S --noconfirm ${_installArray[@]}) ]]; then
                    # Cleaning cached files
                    pacman -Scc --noconfirm
                    
                    # Installing if sudo is installed
                    elif [[ $(sudo pacman -S --noconfirm ${_installArray[@]}) ]]; then
                    # Cleaning cached files
                    sudo pacman -Scc --noconfirm
                    
                    # Try again as root
                else
                    echo "+ ${INFO} retry as root again"
                    return 43
                fi
                
                echo -e "+ [${TICK}] All dependencies are now installed"
            fi
            
        ;;
        'debian'|'ubuntu'|'mint'|'kali')
            if [[ ${_installArray[@]} ]]; then
                # Installing Packages if the script was started as root
                if [[ $(apt-get install ${_installArray[@]} -y) ]]; then
                    # Cleaning cached files
                    apt-get clean -y
                    
                    # Installing if sudo is installed
                    elif [[ $(sudo apt-get install ${_installArray[@]} -y) ]]; then
                    # Cleaning cached files
                    sudo apt-get clean -y
                    
                    # Try again as root
                else
                    echo "+ ${INFO} retry as root again"
                    return 43
                fi
                
                echo -e "+ [${TICK}] All dependencies are now installed"
            fi
        ;;
        *) return 1;;
    esac
    
    # curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    # python3 get-pip.py
    python3 -m pip install ansible
    
    return $?
} 2>/dev/null

exit_handler(){
    # Copy the temp log file into final log location for storage
    #copy_to_install_log # TODO logging still doesn't working like expected
    local error_code=$?
    
    if [[ ${error_code} == 0 ]]; then
        echo -e "+"
        echo -e "${COL_LIGHT_MAGENTA}${COOL_LINE}"
        echo -e "+"
        echo "+ Thanks for using GINAvbs"
        echo -e "+"
        echo -e "${COOL_LINE}"
        
        return ${error_code};
    fi
    
    echo -e "+"
    echo -e "${COL_LIGHT_RED}${COOL_LINE}"
    echo -e "+"
    error_handler ${error_code}
    echo -e "+"
    echo -e "${COOL_LINE}"
    
    exit ${error_code}
} 2>/dev/null

######## ENTRYPOINT #########

main(){
    echo -e "${COL_LIGHT_MAGENTA}${LOGO}"
    echo -e "+"
    echo -e "${COL_LIGHT_GREEN}${LICENSE}"
    echo -e "${COL_NC}+"
    
    set -o xtrace
    
    # Install packages used by this installation script
    install __GINA_DEPS[@]
    
    local _hosts="${HOSTS}"
    local _hostsArray=()
    
    if ! [[ ${_hosts} ]]; then
        read -p 'Hostnames: ' _hosts
        
        if ! [[ ${_hosts} ]]; then
            # Check if username or password and/or sshkey was added
            return 44
        fi
    fi
    
    _hosts="${_hosts// /}"
    _hostsArray=(${_hosts//,/ })
    
    python3 -m ansible playbook -i , -e "hosts=${_hosts}" playbooks/local_setup.yml
    
    export ANSIBLE_HOST_KEY_CHECKING=False
    
    for i in "${_hostsArray[@]}"; do
        python3 -m ansible playbook -i ${i}, -u root -k playbooks/remote_setup.yml --ask-vault-pass
    done
    
    return $?
}

# Traps everything
trap exit_handler 0 1 2 3 13 15 # EXIT HUP INT QUIT PIPE TERM

main "$@" 3>&1 1>&2 2>&3

exit 0
