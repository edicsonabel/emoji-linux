#!/bin/sh

# Variables to be used
notoFolder='/usr/share/fonts/truetype/noto'
notoFont='NotoColorEmoji.ttf'
notoGit='https://github.com/googlefonts/noto-emoji/raw/master/fonts/NotoColorEmoji.ttf'
localFontsFolder="$HOME/.local/share/fonts"
fontconfig="$HOME/.config/fontconfig"
conf='/etc/fonts/conf.d'
nameConf='90-noto-color-emoji.conf'
fileError='/tmp/.noto-err.log'
flagCache='/tmp/cache.ready'
next=true

show_err(){
  if [ -s ${fileError} ]; then
    echo "$@"
    cat ${fileError}
    next=false
  fi
  rm ${fileError} > /dev/null 2>&1
}

installed(){
  for i in "$@"; do
    dpkg -s "${i}" 1> ok 2> err
    if [ -s ok ];then
      rm ok err
      # Installed
      return 0
    else
      rm ok err
      # Not installed
      return 1
    fi
  done
}

setup_color() {
  # Only use colors if connected to a terminal
  if [ -t 1 ]; then
    RED=$(printf '\033[31m')
    GREEN=$(printf '\033[32m')
    YELLOW=$(printf '\033[33m')
    BLUE=$(printf '\033[34m')
    BOLD=$(printf '\033[1m')
    RESET=$(printf '\033[m')
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    RESET=""
  fi
}

main(){

  # Deleting flags
  $(rm ${fileError} > /dev/null 2>&1) &
  $(rm ${flagCache} > /dev/null 2>&1) &

  if "${next}" ; then
    # Installing 'Noto Color Emoji'
    if ! installed "fonts-noto-color-emoji"; then
      echo "${BLUE}${BOLD}Installing 'Noto Color Emoji'${RESET}"
      sudo apt install fonts-noto-color-emoji 2>> ${fileError}
      echo
      show_err "${RED}${BOLD}Error installing${RESET} ${YELLOW}'Noto Color Emoji'${RESET}";
    fi
  fi

  if "${next}" ; then
    # Updating 'Noto Color Emoji'
    if [ -f "./${notoFont}" ]; then
      echo "${BLUE}${BOLD}Copying${RESET} ${YELLOW}./${notoFont}${RESET} ${BLUE}${BOLD}to${RESET} ${YELLOW}${notoFolder}${RESET}"
      sudo cp "./${notoFont}" "${notoFolder}" 2>> ${fileError}
      echo
      show_err "${RED}${BOLD}Error Copying${RESET} ${YELLOW}'./${notoFont}'${RESET}";
    else 
      echo "${BLUE}${BOLD}Downloading${RESET} ${YELLOW}${notoFont}${RESET} ${BLUE}${BOLD}updated to${RESET} ${YELLOW}${notoFolder}${RESET}"
      sudo wget "$notoGit" -O "${notoFolder}/${notoFont}"
      echo
    fi
  fi

  if "${next}" ; then
    # Create local fonts folder
    if [ ! -d "${localFontsFolder}" ]; then
      echo "${BLUE}${BOLD}Creating local fonts folder${RESET} ${YELLOW}${localFontsFolder}${RESET}"
      mkdir "${localFontsFolder}"
      echo
    fi

    # Copying NotoColorEmoji.ttf to local fonts folder
    echo "${BLUE}${BOLD}Copying${RESET} ${YELLOW}.../${notoFont}${RESET} ${BLUE}${BOLD}to local fonts folder${RESET} ${YELLOW}${localFontsFolder}${RESET}"
    cp "${notoFolder}/${notoFont}" "${localFontsFolder}"
    echo
  fi

  if "${next}"; then
    
    # Create fontconfig folder
    if [ ! -d "${fontconfig}" ]; then
      echo "${BLUE}${BOLD}Creating fontconfig folder${RESET} ${YELLOW}${fontconfig}${RESET}"
      mkdir -p "${fontconfig}"
      echo
    fi

    # Adding font setting
    echo "${BLUE}${BOLD}Adding font setting${RESET} ${YELLOW}${fontconfig}/${nameConf}${RESET}"
    echo
cat << EOF > "${fontconfig}/${nameConf}"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>sans-serif</family>
    <prefer><family>Noto Color Emoji</family></prefer>
    <default><family>Noto Color Emoji</family></default>
  </alias>
</fontconfig>
EOF

    # Creating a link to read the setting
    if [ ! -f "${conf}/${nameConf}" ]; then
      echo "${BLUE}${BOLD}Creating a link to read the setting${RESET} ${YELLOW}${conf}/${nameConf}${RESET}"
      sudo ln -s "${fontconfig}/${nameConf}" "${conf}" 2>> ${fileError}
      echo
      show_err "${RED}${BOLD}Error creating a link${RESET} ${YELLOW}'Noto Color Emoji'${RESET}";
    fi

  fi

  if ! installed "fonts-noto-color-emoji"; then next=false ;fi
  if [ ! -f "${fontconfig}/${nameConf}" ]; then next=false ;fi
  if [ ! -f "${conf}/${nameConf}" ]; then next=false ;fi

  if "${next}" ; then
    # Updating font cache
    echo -n "${BLUE}${BOLD}Updating fonts cache, wait a moment${RESET}"
    $(fc-cache -f -v 2>> ${fileError} 1> /dev/null && touch "${flagCache}") &

    while [ ! -f "${flagCache}" ]; do
      echo -n "${BLUE}${BOLD}.${RESET}"
      sleep 12
    done
    $(rm ${flagCache} > /dev/null 2>&1) & 

    echo
    show_err "${RED}${BOLD}Sorry, failed installation${RESET}";
  fi

  if "${next}" ; then
    echo
    echo "${GREEN}${BOLD}Successfull instalation${RESET} ${BLUE}${BOLD}|${RESET} ${YELLOW}${BOLD}Open a new terminal to view the changes${RESET}"
    echo
  fi
}

# Adding colors
setup_color

echo "${GREEN}${BOLD}Installer 'Emojix'${RESET}"
sudo echo

main "$@"