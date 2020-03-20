#!/bin/sh
echo 'Installer "Noto Color Emoji" 😎😘😱😍🎨'
sudo echo
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
  rm ${fileError}
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

main(){

  # Deleting flags
  $(rm ${fileError} > /dev/null 2>&1) &
  $(rm ${flagCache} > /dev/null 2>&1) &

  if "${next}" ; then
    # Installing 'Noto Color Emoji'
    if ! installed "fonts-noto-color-emoji"; then
      echo "💪 Installing 'Noto Color Emoji'"
      sudo apt install fonts-noto-color-emoji 2>> ${fileError}
      echo
      show_err "❌ Error installing 'Noto Color Emoji'";
    fi
  fi

  if "${next}" ; then
    # Updating 'Noto Color Emoji'
    if [ -f "./${notoFont}" ]; then
      echo "📝 Copying ./${notoFont} to ${notoFolder}"
      sudo cp "./${notoFont}" "${notoFolder}" 2>> ${fileError}
      echo
      show_err "❌ Error Copying './${notoFont}'";
    else 
      echo "🔽 Downloading ${notoFont} updated to ${notoFolder}"
      sudo wget "$notoGit" -O "${notoFolder}/${notoFont}"
      echo
    fi
  fi

  if "${next}" ; then
    # Create local fonts folder
    if [ ! -d "${localFontsFolder}" ]; then
      echo "📁 Creating local fonts folder ${localFontsFolder}"
      mkdir "${localFontsFolder}"
      echo
    fi

    # Copying NotoColorEmoji.ttf to local fonts folder
    echo "📝 Copying .../${notoFont} to local fonts folder ${localFontsFolder}"
    cp "${notoFolder}/${notoFont}" "${localFontsFolder}"
    echo

    # Create fontconfig folder
    if [ ! -d "${fontconfig}" ]; then
      echo "📁 Creating fontconfig folder ${fontconfig}"
      mkdir -p "${fontconfig}"
      echo
    fi

    # Adding font setting
    echo "🗄 Adding font setting ${fontconfig}/${nameConf}"
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
  fi


  if "${next}" ; then
    # Creating a link to read the setting
    if [ ! -f "${conf}/${nameConf}" ]; then
      echo "🔗 Creating a link to read the setting ${conf}/${nameConf}"
      sudo ln -s "${fontconfig}/${nameConf}" "${conf}" 2>> ${fileError}
      echo
      show_err "❌ Error creating a link 'Noto Color Emoji'";
    fi
  fi

  if ! installed "fonts-noto-color-emoji"; then next=false ;fi
  if [ ! -f "${fontconfig}/${nameConf}" ]; then next=false ;fi
  if [ ! -f "${conf}/${nameConf}" ]; then next=false ;fi

  if "${next}" ; then
    # Updating font cache
    echo -n "♻️ Updating fonts cache, wait a moment"
    $(fc-cache -f -v 2>> ${fileError} 1> /dev/null && touch "${flagCache}") &

    while [ ! -f "${flagCache}" ]; do
      echo -n '.'
      sleep 12
    done
    $(rm ${flagCache} > /dev/null 2>&1) & 

    echo
    show_err "❌ Sorry, failed installation";
  fi

  if "${next}" ; then
    echo '🙌 Successfull instalation'
    echo
  fi
}

main "$@"