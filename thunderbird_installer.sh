#!/usr/bin/env bash
# shellcheck disable=SC2140,SC2206,SC2068,SC2181,SC2086,SC2034

## Author: Tommy Miland (@tmiland) - Copyright (c) 2025


######################################################################
####                  thunderbird_installer.sh                    ####
####                   Thunderbird Installer                      ####
####      Install any version of thunderbird from Mozilla.org     ####
####                   Maintained by @tmiland                     ####
######################################################################

VERSION='1.0.1'

#------------------------------------------------------------------------------#
#
# MIT License
#
# Copyright (c) 2025 Tommy Miland
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#------------------------------------------------------------------------------#
## For debugging purpose
if [[ $* =~ "debug" ]]
then
  set -o errexit
  set -o pipefail
  set -o nounset
  set -o xtrace
fi
# Get script filename
SCRIPT_FILENAME=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")
# Set default thunderbird version
THUNDERBIRD_VER_NAME=${THUNDERBIRD_VER_NAME:-thunderbird}
# Set default language
THUNDERBIRD_LANG=${THUNDERBIRD_LANG:-en-US}
# Set default install dir
THUNDERBIRD_INSTALL_DIR=/opt
shopt -s nocasematch
if lsb_release -si >/dev/null 2>&1; then
  DISTRO=$(lsb_release -si)
else
  if [[ -f /etc/debian_version ]]; then
    DISTRO=$(cat /etc/issue.net)
  elif [[ -f /etc/redhat-release ]]; then
    DISTRO=$(cat /etc/redhat-release)
  elif [[ -f /etc/os-release ]]; then
    DISTRO=$(cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}')
  fi
fi
case "$DISTRO" in
  Debian*|Ubuntu*|LinuxMint*|PureOS*|Pop*|Devuan*)
    DISTRO_GROUP=Debian
    ;;
esac
shopt -s nocasematch
if [[ $DISTRO_GROUP == "Debian" ]]
then
  export DEBIAN_FRONTEND=noninteractive
  UPDATE="apt-get -o Dpkg::Progress-Fancy="1" update -qq"
  INSTALL="apt-get -o Dpkg::Progress-Fancy="1" install -qq"
  UNINSTALL="apt-get -o Dpkg::Progress-Fancy="1" remove -qq"
  INSTALL_PKGS=("menu" "debianutils")
else
  echo -e "Error: Sorry, your OS is not supported."
  exit 1;
fi

ARCH=$(uname -m)

case "$ARCH" in
  x86_64)
    ARCH=linux64
    ;;
  i686)
    ARCH=linux
    ;;
esac

if [[ ! $(command -v curl) ]]
then
  sudo ${INSTALL} curl
fi

mozilla_custom_url=https://download-installer.cdn.mozilla.net/pub/thunderbird/releases/

THUNDERBIRD_VER=$(curl -sSL $mozilla_custom_url |
grep -Po 'a href="/pub/thunderbird/releases/.*">\K.*(?=</a)' |
grep -v 'b.*' |
grep -v 'esr.*' |
grep -v 'rc[1|2|3].*' |
grep -v 'a[1|2|3].*' |
sort -nr |
head -n1 |
sed "s|\/||g")
THUNDERBIRD_ESR_VER=$(curl -sSL $mozilla_custom_url |
grep -Po 'a href="/pub/thunderbird/releases/.*esr.*">\K.*esr.*(?=</a)' |
sed "s|/||g" |
sort -nr |
head -n1)
THUNDERBIRD_BETA_VER=$(curl -sSL $mozilla_custom_url |
grep -Po 'a href="/pub/thunderbird/releases/.*b.*">\K.*b.*(?=</a)' |
sed "s|/||g" |
sort -nr |
head -n1)
# Set default THUNDERBIRD_ versions
THUNDERBIRD_VER=${THUNDERBIRD_VER:-$THUNDERBIRD_VER}
THUNDERBIRD_ESR_VER=${THUNDERBIRD_ESR_VER:-$THUNDERBIRD_ESR_VER}
THUNDERBIRD_BETA_VER=${THUNDERBIRD_BETA_VER:-$THUNDERBIRD_BETA_VER}

if [ -f $THUNDERBIRD_INSTALL_DIR/thunderbird/thunderbird ]
then
  THUNDERBIRD_INSTALLED_VER=$($THUNDERBIRD_INSTALL_DIR/thunderbird/thunderbird -v |
  sed "s|Mozilla Thunderbird ||g")
fi
if [ -f $THUNDERBIRD_INSTALL_DIR/thunderbird-esr/thunderbird ]
then
  THUNDERBIRD_ESR_INSTALLED_VER=$($THUNDERBIRD_INSTALL_DIR/thunderbird-esr/thunderbird -v |
  sed "s|Thunderbird ||g")
fi
if [ -f $THUNDERBIRD_INSTALL_DIR/thunderbird-beta/thunderbird ]
then
  THUNDERBIRD_BETA_INSTALLED_VER=$($THUNDERBIRD_INSTALL_DIR/thunderbird-beta/thunderbird -v |
  sed "s|Mozilla Thunderbird ||g")
fi

mozilla_url=https://download.mozilla.org

lang_array=(
  "English (US)               lang=en-US"
  "Albanian                   lang=sq"
  "Arabic                     lang=ar"
  "Armenian                   lang=hy-AM"
  "Asturian                   lang=ast"
  "Basque                     lang=eu"
  "Belarusian                 lang=be"
  "Bengali (Bangladesh)       lang=bn-BD"
  "Breton                     lang=br"
  "Bulgarian                  lang=bg"
  "Catalan                    lang=ca"
  "Chinese (Simplified)       lang=zh-CN"
  "Chinese (Traditional)      lang=zh-TW"
  "Croatian                   lang=hr"
  "Czech                      lang=cs"
  "Danish                     lang=da"
  "Dutch                      lang=nl"
  "English (British)          lang=en-GB"
  "Estonian                   lang=et"
  "Finnish                    lang=fi"
  "French                     lang=fr"
  "Frisian                    lang=fy-NL"
  "Gaelic (Scotland)          lang=gd"
  "Galician                   lang=gl"
  "German                     lang=de"
  "Greek                      lang=el"
  "Hebrew                     lang=he"
  "Hungarian                  lang=hu"
  "Icelandic                  lang=is"
  "Indonesian                 lang=id"
  "Irish                      lang=ga-IE"
  "Italian                    lang=it"
  "Korean                     lang=ko"
  "Lithuanian                 lang=lt"
  "Lower Sorbian              lang=dsb"
  "Norwegian (BokmÃ¥l)         lang=nb-NO"
  "Norwegian (Nynorsk)        lang=nn-NO"
  "Polish                     lang=pl"
  "Portuguese (Brazilian)     lang=pt-BR"
  "Portuguese (Portugal)      lang=pt-PT"
  "Punjabi (India)            lang=pa-IN"
  "Romanian                   lang=ro"
  "Romansh                    lang=rm"
  "Russian                    lang=ru"
  "Serbian                    lang=sr"
  "Sinhala                    lang=si"
  "Slovak                     lang=sk"
  "Slovenian                  lang=sl"
  "Spanish (Argentina)        lang=es-AR"
  "Spanish (Spain)            lang=es-ES"
  "Swedish                    lang=sv-SE"
  "Tamil (Sri Lanka)          lang=ta-LK"
  "Turkish                    lang=tr"
  "Ukrainian                  lang=uk"
  "Upper Sorbian              lang=hsb"
  "Vietnamese                 lang=vi"
  "Welsh                      lang=cy"
)

install_thunderbird() {
  if [ "$mode" != "uninstall" ] && [ "$mode" != "profile-backup" ]
  then
    language=("${lang_array[@]}")
    read -rp "$(
          f=0
          for l in "${language[@]}"
          do
            echo "$((++f)): $l"
          done
          echo -ne "Please select a language: "
    )" selection
    selected_language="${language[$((selection-1))]}"
    THUNDERBIRD_LANG=$(echo "$selected_language" | grep -o "lang=.*" | sed "s|lang=||g")
    language_selected=$(echo "$selected_language" | grep -o ".* lang=" | sed "s|lang=||g")

    echo "You selected $language_selected"
    if [[ "$release" == "custom" ]]
    then
      case "$THUNDERBIRD_VER_NAME" in
        thunderbird)
          # thunderbird
          thunderbird_url=$mozilla_custom_url"$THUNDERBIRD_VERSION"/linux-"$(uname -m)"/"$THUNDERBIRD_LANG"/thunderbird-"$THUNDERBIRD_VERSION".tar.xz
          ;;
        thunderbird-esr)
          # esr
          thunderbird_url=$mozilla_custom_url"$THUNDERBIRD_VERSION"/linux-"$(uname -m)"/"$THUNDERBIRD_LANG"/thunderbird-"$THUNDERBIRD_VERSION".tar.xz
          ;;
        thunderbird-beta)
          # beta
          thunderbird_url=$mozilla_custom_url"$THUNDERBIRD_VERSION"/linux-"$(uname -m)"/"$THUNDERBIRD_LANG"/thunderbird-"$THUNDERBIRD_VERSION".tar.xz
          ;;
      esac
    else
      thunderbird_url="$mozilla_url/?product=$THUNDERBIRD_VER_NAME-latest&os=$ARCH&lang=$THUNDERBIRD_LANG"
    fi
    if [[ $DISTRO_GROUP == "Debian" ]]
    then
      echo -e "Checking Prerequisites"
      for PKG in "${INSTALL_PKGS[@]}"
      do
        if ! dpkg-query -W --showformat='${Status}\n' "${PKG}" |
        grep "install ok installed" >/dev/null 2>&1
        then
          echo "${PKG} is not installed, installing."
          sudo ${INSTALL} "$PKG" 2> /dev/null
        fi
      done
      echo -e "Done."
    fi
    echo "Installing $THUNDERBIRD_VER_NAME to $THUNDERBIRD_INSTALL_DIR"
    cd /tmp || exit 0
    sudo wget -O "$THUNDERBIRD_VER_NAME".tar.xz -q "$thunderbird_url"
    sudo tar -xf "$THUNDERBIRD_VER_NAME".tar.xz
    sudo mv thunderbird "$THUNDERBIRD_INSTALL_DIR"/"$THUNDERBIRD_VER_NAME" >/dev/null 2>&1
    sudo ln -snf "$THUNDERBIRD_INSTALL_DIR"/"$THUNDERBIRD_VER_NAME"/thunderbird /usr/local/bin/"$THUNDERBIRD_VER_NAME"
    if [ ! -d /usr/local/share/applications ]
    then
      sudo mkdir /usr/local/share/applications
    fi
    # Download desktop shortcut from repo
    curl -SsL https://github.com/tmiland/thunderbird-installer/raw/refs/heads/main/res/"$THUNDERBIRD_VER_NAME".desktop |
    sudo tee /usr/local/share/applications/"$THUNDERBIRD_VER_NAME".desktop >/dev/null 2>&1
    sudo sed -i "s|Icon=thunderbird|Icon=$THUNDERBIRD_INSTALL_DIR/$THUNDERBIRD_VER_NAME/chrome/icons/default/default128.png|g" /usr/local/share/applications/"$THUNDERBIRD_VER_NAME".desktop >/dev/null 2>&1
    sudo update-menus
    sudo rm "$THUNDERBIRD_VER_NAME".tar.xz
    if [ $? -eq 0 ]
    then
      echo "Done."
    else
      echo "Installing $THUNDERBIRD_VER_NAME to $THUNDERBIRD_INSTALL_DIR FAILED."
    fi
    cd - >/dev/null 2>&1 || exit 0
  fi
}

uninstall_thunderbird() {
    echo "Deleting files for $THUNDERBIRD_VER_NAME"
    sudo rm /usr/local/share/applications/"$THUNDERBIRD_VER_NAME".desktop
    sudo rm /usr/local/bin/"$THUNDERBIRD_VER_NAME"
    sudo rm -rf "$THUNDERBIRD_INSTALL_DIR/$THUNDERBIRD_VER_NAME"
    echo "Done."
}

profile_backup() {
  # From https://github.com/tmiland/Firefox-Backup
  BACKUP_DEST=${BACKUP_DEST:-$HOME/.thunderbird-backup}

  if [ ! -d "$BACKUP_DEST" ]
  then
    mkdir "$BACKUP_DEST"
  fi

  readIniFile () { # expects one argument: absolute path of profiles.ini
    declare -r inifile="$1"
    declare -r tfile=$(mktemp)

    if [ $(grep '^\[Profile' "$inifile" | wc -l) == "1" ]
    then ### only 1 profile found
      grep '^\[Profile' -A 4 "$inifile" | grep -v '^\[Profile' > "$tfile"
    else
      grep -E -v '^\[General\]|^StartWithLastProfile=|^IsRelative=' "$inifile"
      echo -e ""
      read -p 'Select the profile number (0 for Profile0, 1 for Profile1, etc): ' -r
      echo -e "\n"
      if [[ $REPLY =~ ^(0|[1-9][0-9]*)$ ]]
      then
        grep '^\[Profile'${REPLY} -A 4 "$inifile" | grep -v '^\[Profile'${REPLY} > "$tfile"
        if [[ "$?" != "0" ]]
        then
          echo -e "Profile${REPLY} does not exist!" && exit 1
        fi
      else
        echo -e " Invalid selection!" && exit 1
      fi
    fi

    declare -r profpath=$(grep '^Path=' "$tfile")
    declare -r pathisrel=$(grep '^IsRelative=' "$tfile")
    rm "$tfile"
    # update global variable
    if [[ ${pathisrel#*=} == "1" ]]
    then
      PROFILE_PATH="$(dirname "$inifile")/${profpath#*=}"
      PROFILE_ID="${profpath#*=}"
    else
      PROFILE_PATH="${profpath#*=}"
    fi
  }

  declare -r f1="$HOME/Library/Application Support/Thunderbird/profiles.ini"
  declare -r f2="$HOME/.thunderbird/profiles.ini"
  local ini=''
  if [[ -f "$f1" ]]
  then
    ini="$f1"
  elif [[ -f "$f2" ]]
  then
    ini="$f2"
  else
    echo -e "Error: Sorry, -l is not supported for your OS"
    exit 1
  fi
  readIniFile "$ini" # updates PROFILE_PATH or exits on error
  echo -e "Backing up thunderbird profile..."
  BACKUP_FILE_NAME=${PROFILE_ID}-$(date +"%Y-%m-%d_%H%M").tar.gz
  if [ -f "$HOME/.thunderbird/profiles.ini" ]
  then
    cp -rp "$HOME/.thunderbird/profiles.ini" "$PROFILE_PATH"/installs.ini.bak
  fi
  cp -rp "$ini" "$PROFILE_PATH"/profiles.ini.bak
  tar -zcf "$BACKUP_FILE_NAME" "$PROFILE_PATH" > /dev/null 2>&1
  mv "$BACKUP_FILE_NAME" "$BACKUP_DEST"
  echo
  echo -e "Done!"
  echo
  if [ $? -eq 0 ]
  then
    echo -e "Thunderbird profile successfully backed up to $BACKUP_DEST"
  else
    echo -e "Backup to $BACKUP_DEST FAILED."
  fi
  echo
}

usage() {
  #header
  ## shellcheck disable=SC2046
  printf "Usage: %s [options]" "${SCRIPT_FILENAME}"
  echo
  if [[ -n "$THUNDERBIRD_INSTALLED_VER" ]]
  then
    echo
    echo "Installed: $THUNDERBIRD_INSTALLED_VER"
  fi
  if [[ -n "$THUNDERBIRD_ESR_INSTALLED_VER" ]]
  then
    echo
    echo "Installed esr: $THUNDERBIRD_ESR_INSTALLED_VER"
  fi
  if [[ -n "$THUNDERBIRD_BETA_INSTALLED_VER" ]]
  then
    echo
    echo "Installed beta: $THUNDERBIRD_BETA_INSTALLED_VER"
  fi
  echo
  cat <<EOF
  --help                 |-h   display this help and exit
  --latest               |-l   latest (${THUNDERBIRD_VER})
  --esr                  |-e   esr (${THUNDERBIRD_ESR_VER})
  --beta                 |-b   beta (${THUNDERBIRD_BETA_VER})
  --release              |-rl  select custom release to install*
  --backup-profile       |-bp  backup thunderbird profile
  --uninstall            |-u   uninstall thunderbird

  install from mozilla: [-t|-e|-b]
  uninstall:            [-t|-e|-b] -u
  * custom release for mozilla [-rl <release>]
EOF
  echo
}

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]
do
  case $1 in
    --help | -h)
      usage
      exit 0
      ;;
    --thunderbird | -l)
      shift
      THUNDERBIRD_VERSION=$THUNDERBIRD_VER
      THUNDERBIRD_VER_NAME=thunderbird
      ;;
    --esr | -e)
      shift
      THUNDERBIRD_VERSION=$THUNDERBIRD_ESR_VER
      THUNDERBIRD_VER_NAME=thunderbird-esr
      ;;
    --beta | -b)
      shift
      THUNDERBIRD_VERSION=$THUNDERBIRD_BETA_VER
      THUNDERBIRD_VER_NAME=thunderbird-beta
      ;;
    --release | -rl)
      shift
      release="custom"
      THUNDERBIRD_VERSION="$1"
      ;;
    --backup-profile | -bp)
      shift
      profile_backup
      mode="profile-backup"
      ;;
    --uninstall | -u)
      shift
      uninstall_thunderbird
      mode="uninstall"
      ;;
    --* | -*)
      printf "%s\\n\\n" "Unrecognized option: $1"
      usage
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if ! install_thunderbird
then
  echo "thunderbird installation returned an error."
fi
