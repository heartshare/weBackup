#!/bin/bash
# Script to set up a new host backup
# At the moment we have no way to control if ssh-keys are well setted
#+and I don't know if I'll implement this... :s

# Colors for prompt.
COLOR_RED=$(tput setaf 1)
COLOR_GREEN=$(tput setaf 2)
COLOR_YELLOW=$(tput setaf 3)
COLOR_BLUE=$(tput setaf 4)
COLOR_MAGENTA=$(tput setaf 5)
COLOR_CYAN=$(tput setaf 6)
COLOR_GRAY=$(tput setaf 7)
COLOR_WHITE=$(tput setaf 7 && tput bold)
COLOR_LIGHTRED=$(tput setaf 1 && tput bold)
COLOR_LIGHTGREEN=$(tput setaf 2 && tput bold)
COLOR_LIGHTYELLOW=$(tput setaf 3 && tput bold)
COLOR_LIGHTBLUE=$(tput setaf 4 && tput bold)
COLOR_LIGHTMAGENTA=$(tput setaf 5 && tput bold)
COLOR_LIGHTCYAN=$(tput setaf 6 && tput bold)
COLOR_BOLD=$(tput bold)
COLOR_RESET=$(tput sgr0)

# Colorized feedback functions.
# Helper feedback functions
function info() {
  echo "${COLOR_BOLD}    * ${1}${COLOR_RESET}"
}
function success() {
  echo "${COLOR_BOLD}${COLOR_GREEN}   ** ${1}${COLOR_RESET}"
}
function warning() {
  echo "${COLOR_BOLD}${COLOR_YELLOW}  *** ${1}${COLOR_RESET}"
}
function error() {
  echo "${COLOR_BOLD}${COLOR_RED} **** ${1}${COLOR_RESET}"
}
function question() {
  echo -ne "${COLOR_BOLD}${COLOR_BLU}    ? ${1}?${COLOR_RESET} "
}

. configure

question "Hi guy! Do  you want to set up a now host backup? [y] [n]: "
read go

if [[ $go != 'n' ]] && [[ $go != 'y' ]]; then
  error "That was only the first answer...>_> Please, retry and type y for yes or n for no"; exit 1
elif [[ $go == 'n' ]]; then
  info "Mmmm, ok...see you"; exit 0
else
  success "Here we go!"
fi

question "What is the name of the host to add? If it \n\t is a remote host you MUST use its FQDN or IP: "
read host

if [[ -f  ${CONF_DIR}/${host}/host.conf ]]; then
  error "Hey! We have another host named $host. You have to choose another."
  exit 1
else
  hostconfig=${CONF_DIR}/${host}/host.conf
  cp -r $CONF_DIR/template.tpl ${CONF_DIR}/${host}
  success "Creating configuration file in ${CONF_DIR}/${host}"
fi

# getconf ( string array_to_configure, string substitution )
function getconf(){
  sed -i "s|^\[$1\]=$|\[$1\]=$2|" $hostconfig
  return 0
}

question "Is the host a remote host? [y] [n]: "
read remote

if [[ $remote == 'n' ]]; then
  getconf 0 false
  success "Not a remote one"
  question "So we have to backup a local directory or a \n\t sshfs mounted directory? [local] [sshfs]: "
  read sshfs
  
  if [[ $sshfs == 'local' ]]; then
    getconf 3 false
    success "A local directory!"
    info "Please, specify its path."
    info "Start with / and omit the trailing slash."
    question "Local path: "
    read path
    
    if [ $path == '' ]; then
      error "Path was not optional... Please restart the script now... >_>"
      exit 1
    else   
      getconf 2 $path
      success "Path setted to $path"
    fi
    
  elif [[ $sshfs == 'sshfs' ]]; then
    getconf 3 true
    success "SSHFS! Also good for us."
    info "Please, specify the path where it is mounted."
    info "Start with / and omit the trailing slash."
    question "Local path: "
    read path
    
    if [ $path == '' ]; then
      error "Path was not optional... Please restart the script now... >_>"
      exit 1
    else   
      getconf 2 $path
      success "So your mountpoint is $path"
    fi
    
    question "What is the name of the SSH user you want to use? "
    read user
    
    if [ $user == '' ]; then
      error "Username was not optional... Please restart the script now... >_>"
      exit 1
    else
      getconf 1 $user
      success "We welcome you, $user"
    fi
    
    info "What is the path directory you want to backup?"
    info "Please, specify the path of the directory"
    info "Start with / and omit the trailing slash..."
    info "...unless it is / (root) :)"
    question "Remote path: "
    read rpath
    
    if [ $rpath == '' ]; then
      error "Path was not optional... Please restart the script now... >_>"
      exit 1
    else   
      getconf 4 $rpath
      success "Ok: we want to backup $rpath on the remote server!"
    fi
  else #in any of the cases
    error "That was not optional to follow instructions... Please restart the script now... >_>"; exit 1
  fi
  
elif [[ $remote == 'y' ]]; then
  getconf 0 true
  question "What is your SSH user? "
  read user
  
  if [ $user == '' ]; then
    error "Username was not an optional... Please restart the script now... >_>"
    exit 1
  else
    getconf 1 $user
    success "We will connect with: $user@$remote, all right? :)"
  fi
fi

success "All showld be done. Take a look in $hostconfig."
success "Do not forget to ssh-copy-id if needed"
success "and to configure globbing.conf for your needs."
success "ByeBye"

