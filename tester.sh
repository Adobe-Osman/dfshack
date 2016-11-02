#!/bin/bash
version="V0.0.3"
usage="$(basename "$0") [-help] [-v] -- Simple test suite for dfshack

where:
    -h,   show this help text
    -v,   Shows version information"

###############################################################################
#Function: auto_testing                                                       #
#Prupose: Runs auto test case for dfshack by creating severle files changing  #
#         their permissions and moving them around                            #
#arguments: none                                                              #
#return: none                                                                 #
###############################################################################
function auto_testing {
  echo -e "\033[1;33mAutomated dfshack test\033[0m"
 
  echo -e "\033[1;35mCreating folder outer\033[0m"
  file="/nethome/users/$USER/outer"
  mkdir "$file"
  ensure $file

  echo -e "\033[1;35mCreating folder inner\033[0m"
  file="/nethome/users/$USER/inner"
  mkdir "$file" 
  ensure $file

  folder="/nethome/users/$USER/outer/"
  file="/nethome/users/$USER/inner"
  ACL=777
  file_nesting $folder $file
  file="$folder${file:22}"
  ensure $file 

  echo -e "\033[1;35mCreating symlink in dfs\033[0m"
  file="$file""/sym" 
  ln -s "/mnt/dfs/$USER/Users/$USER/${folder:22}" "/mnt/dfs/$USER/UserS/$USER/${file:22}"
  #the above line is here to show that dfs can create symlinks
  ensure $file

  echo -e "\033[1;35mCreating file this_file.sub\033[0m"
  file="/nethome/users/$USER/this_file.sub"
  touch "$file"
  ensure $file

  permissions $ACL $file
  file_nesting $folder $file
  file="$folder${file:22}"
  ensure $file

  echo -e "\033[1;35mDeleting containing folder\033[0m"
  rm -r "$folder"
  file="$folder"
  ensure $file #expecting $file to not exist
}

###############################################################################
#Function: permissions                                                        #
#Prupose: Changes the permissions of file to the ACL                          #
#arguments:  file, ACL                                                        #
#return: none                                                                 #
###############################################################################
function permissions() {
  echo -e "\033[1;35mChanging Permissions\033[0m"
  chmod $ACL $file 
  if [ $( stat -c "%a" "$file" ) != "$ACL" ]; then
    echo -e "\033[1;31m\tFailed to change permissions of ${file:22} to $ACL\033[0m"
  else
    echo -e "\033[1;32m\tPermissions of ${file:22} changed to $ACL"
  fi
}


###############################################################################
#Function: file_nesting                                                       #
#Prupose: Puts file into folder                                               #
#arguments:  file, folder                                                     #
#return: none                                                                 #
###############################################################################
function file_nesting () {
  echo -e "\033[1;35mFile nesting\033[0m"
  mv $file $folder
}

###############################################################################
#Function: ensure                                                             #
#Prupose: ensure that file exists in both the mounted SDRIVE and in dfs       #
#arguments:  file                                                             #
#return: none                                                                 #
###############################################################################
function ensure () {
  if [ -e $file ]; then
      echo -e "\033[1;32m\t${file:22} present in mount\033[0m"
        else
    echo -e "\033[1;31m\t${file:22} not present in mount \033[0m"
  fi

  if [ -e "/mnt/dfs/$USER/Users/$USER/${file:22}"  ]; then
        echo -e "\033[1;32m\t${file:22} present in dfs\033[0m"
  else
         echo -e "\033[1;31m\t${file:22} not present in dfs\033[0m"
  fi

}

if [[ $# = 0 ]]; then
  auto_testing
else
while getopts ":hv" opt; do
    case $opt in
      h)
        echo "$usage"
      ;;
      v)
        echo "$version"
      ;;
      \?)
          echo -e "\033[1;31mInvalid option -$OPTARG\033[0m"
      ;;
      esac
  done
fi
