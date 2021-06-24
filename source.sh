#!/bin/bash
PATH="/usr/local/bin:$PATH"
#
# Load Static Settings
#
BOLDF="\e[1m"
NORMALF="\e[0m"

DEFAULTC="\e[39m"
YELLOWC="\e[93m"
REDC="\e[31m"
CYANC="\e[36m"
GREENC="\e[32m"

VERSION="0.1.1"

PREFIX="${YELLOWC}[Backup System]"
TEMP_FOLDER="/home/.$(uuidgen)/"
DATE=$(date +%m-%d-%y-%T)

#
# Load Configuration Settings
#
debug=$(yq e ".debug" backup.yml)
endpoint_url=$(yq e ".bucket-settings.endpoint-url" backup.yml)
secret_key=$(yq e ".bucket-settings.secret-key" backup.yml)
access_key=$(yq e ".bucket-settings.access-key" backup.yml)
region=$(yq e ".bucket-settings.region" backup.yml)
bucket=$(yq e ".bucket-settings.bucket" backup.yml)
host=$(yq e ".mysql-settings.host" backup.yml)
username=$(yq e ".mysql-settings.username" backup.yml)
password=$(yq e ".mysql-settings.password" backup.yml)

#
# Run Backup Function
#
function runBackup {
  # Get the number of servers in the configuration
  serverCount=$(expr $(yq e ".servers | length" backup.yml) - 1)

  # Print starting backup message
  echo -e "${PREFIX} Starting Backup ($(date +%D\ %H:%M:%S))${DEFAULTC}"
  echo -e "${CYANC}Backing up the servers:"

  # List servers in the configuration
  for s in $(sudo seq 0 ${serverCount})
  do
    # Set current server name
    server=$(yq e ".servers[$s].name" backup.yml)
    # Print it out
    echo -e "${GREENC}- ${server}"
  done

  # Loop through each server and run backup
  for s in $(sudo seq 0 ${serverCount})
  do
    # Set current server name, folder, database length, and if the different modules are enabled
    serverName=$(yq e ".servers[$s].name" backup.yml)
    serverFolder=$(yq e ".servers[$s].sources.server-folder" backup.yml)
    serverDatabasesLength=$(expr $(yq e ".servers[$s].sources.mysql-databases | length" backup.yml) - 1)
    nonCompressedEnabled=$(yq e ".servers[$s].modules.non-compressed.enabled" backup.yml)
    compressedEnabled=$(yq e ".servers[$s].modules.compressed.enabled" backup.yml)
    sqlEnabled=$(yq e ".servers[$s].modules.sql.enabled" backup.yml)

    # Print out server name and set sources message
    echo -e "\n\n${BOLDF}${REDC}BACKING UP: ${NORMALF}${GREENC}${serverName}"
    echo -e "${PREFIX} Setting sources..."

    # Print out the set folder and print out the database messages
    echo -e "${CYANC}Set ${GREENC}${serverName}${CYANC} server folder to ${GREENC}${serverFolder}"
    echo -e "${CYANC}Set ${GREENC}${serverName}${CYANC} databases to:"

    # Print out the databases (For each database)
    for d in $(sudo seq 0 ${serverDatabasesLength})
    do
      # Set current database in the loop
      serverDatabase=$(yq e ".servers[$s].sources.mysql-databases[$d]" backup.yml)
      # Print it out
      echo -e "${GREENC}- ${serverDatabase}"
    done

    # Print checking for enabled modules message and message for the different formats
    echo -e "${PREFIX} Checking enabled modules..."
    echo -e "${CYANC}Backups in the following formats will be made:"


    # Print the available options
    if [[ ${nonCompressedEnabled} == true ]]; then echo -e "${GREENC}- Non Compressed"; fi
    if [[ ${compressedEnabled} == true ]]; then echo -e "${GREENC}- Compressed"; fi
    if [[ ${sqlEnabled} == true ]]; then echo -e "${GREENC}- SQL"; fi
    if [[ ((${nonCompressedEnabled} == false) && (${compressedEnabled} == false)) && ${sqlEnabled} == false ]]; then echo -e "${GREENC}- None"; fi


    # Non Compress Backup
    if [[ $nonCompressedEnabled == true ]]; then
      # Set destination
      destination=$(yq e ".servers[$s].modules.non-compressed.destination" backup.yml)
      # Print out that the process is starting
      echo -e "${PREFIX} Starting Non Compressed Backup Process${CYANC}"

      # If debug is true then put debug tag
      if [[ ${debug} == true ]]; then
        # AWS S3 Backup from Server Folder to Non Compressed destination with Endpoint ${endpoint_url}
        aws s3 cp --debug --recursive --endpoint-url ${endpoint_url} ${serverFolder} s3://${bucket}/${destination}$DATE
      # Nothing if debug is not true
      else
        # AWS S3 Backup from Server Folder to Non Compressed destination with Endpoint ${endpoint_url}
        aws s3 cp --quiet --no-progress --only-show-errors --recursive --endpoint-url ${endpoint_url} ${serverFolder} s3://${bucket}/${destination}$DATE
      fi
      # Print out that the Non Compressed Process is completed
      echo -e "${PREFIX} Completed Non Compressed Backup Process"
    fi

    # Compressed Backup
    if [[ $compressedEnabled == true ]]; then
      # Set destination
      destination=$(yq e ".servers[$s].modules.compressed.destination" backup.yml)
      # Print out that the process is starting
      echo -e "${PREFIX} Starting Compressed Backup Process${CYANC}"

      # If debug is true then put debug tag
      if [[ $debug == true ]]; then
        # Compress folder with Debug
        sudo tar -czvf ${TEMP_FOLDER}${DATE}.tar.gz -C ${serverFolder} .
        # AWS S3 Backup from ZIP File to Compressed destination with Endpoint ${endpoint_url}
        aws s3 cp --debug --endpoint-url ${endpoint_url} ${TEMP_FOLDER}${DATE}.tar.gz s3://${bucket}/${destination}
      else
        # Compress folder without Debug
        sudo tar -czf ${TEMP_FOLDER}${DATE}.tar.gz -C ${serverFolder} .
        # AWS S3 Backup from ZIP File to Compressed destination with Endpoint ${endpoint_url}
        aws s3 cp --quiet --no-progress --only-show-errors --endpoint-url ${endpoint_url} ${TEMP_FOLDER}${DATE}.tar.gz s3://${bucket}/${destination}
      fi
      # Delete the temp file
      sudo rm -rf ${TEMP_FOLDER}${DATE}.tar.gz
      # Print out that the Compressed Process is completed
      echo -e "${PREFIX} Completed Compressed Backup Process"
    fi

    # SQL Backup
    if [[ $sqlEnabled == true ]]; then
      # Set destination
      destination=$(yq e ".servers[$s].modules.sql.destination" backup.yml)
      # Print out that the process is starting
      echo -e "${PREFIX} Starting SQL Backup Process${CYANC}"
      # Do for each SQL database
      for d in $(sudo seq 0 ${serverDatabasesLength})
      do
        # Set current database
        serverDatabase=$(yq e ".servers[$s].sources.mysql-databases[$d]" backup.yml)
        # Check if debug is true
        if [[ ${debug} == true ]]; then
          # Check if password is null
          if [[ $password == "" ]]; then
            # Make a dump without password
            mysqldump -vl -u ${username} -h ${host} ${serverDatabase} > ${TEMP_FOLDER}${serverDatabase}-${DATE}.sql
          else
            # Make a dump with password
            mysqldump -vl -u ${username} -p${password} -h ${host} ${serverDatabase} > ${TEMP_FOLDER}${serverDatabase}-${DATE}.sql
          fi
          # Upload database with debug mode on
          aws s3 cp --debug --endpoint-url ${endpoint_url} ${TEMP_FOLDER}${serverDatabase}-${DATE}.sql s3://${bucket}/${destination}
        # If debug is false
        else
          # Check if password is null
          if [[ $password == "" ]]; then
            # Make a dump without debug and without password
            mysqldump -l -u ${username} -h ${host} ${serverDatabase} > ${TEMP_FOLDER}${serverDatabase}-${DATE}.sql
          else
            # Make a dump with password and wiithout debug
            mysqldump -l -u ${username} -p${password} -h ${host} ${serverDatabase} > ${TEMP_FOLDER}${serverDatabase}-${DATE}.sql
          fi
          # Upload database with quiet mode on
          aws s3 cp --quiet --no-progress --only-show-errors --endpoint-url ${endpoint_url} ${TEMP_FOLDER}${serverDatabase}-${DATE}.sql s3://${bucket}/${destination}
        fi
      done
      # Pring out a message that SQL Backup is complete.
      echo -e "${PREFIX} Completed SQL Backup Process"
    fi
  done

  # Print out backup complete message
  echo -e "\n${PREFIX} Backup Complete ($(date +%D\ %H:%M:%S))${DEFAULTC}"
}

function initiateBackup {
    # Print out setting AWS settings
    echo -e "${PREFIX} Setting Amazon S3 Settings $DEFAULTC"

    # Set the region, secret, and access key
    aws configure set default.region $region
    aws configure set aws_secret_access_key $secret_key
    aws configure set aws_access_key_id $access_key

    # Run the backup
    runBackup

}



FILENAMERAN=`basename "$0"`
# If argument is nothing or --help
if [[ $1 == "" || $1 == "--help" ]]; then
  # Print usage text
  printf "\n$CYANC ___          _               ___         _\n| _ ) __ _ __| |___  _ _ __  / __|_  _ __| |_ ___ _ __\n| _ \\/ _\` / _| / / || | \'_ \\ \\__ \\ || (_-<  _/ -_) \'  \\ \n|___/\\__,_\\__|_\\_\\\\\_,_| .__/ |___/\\_, /__/\\__\\___|_|_|_|\n                      |_|         |__/                 \nBy Intriguing#0001 | Version: v${VERSION}${DEFAULTC}\n\n"
  printf "${YELLOWC}Usage:\n  ./${FILENAMERAN} [flags]\n  ./${FILENAMERAN} [commands]\n\nCommands:\n  start          Begin the backup process\n\nFlags:\n  --help         Show this help menu\n  --version      Show the script version\n\n${DEFAULTC}"
# If argument is start
elif [[ $1 == "start" ]]; then
  # Create Temp Folder
  sudo mkdir -p ${TEMP_FOLDER}
  # Initiate Backup
  initiateBackup
  # Remove Temp Folder
  sudo rm -rf ${TEMP_FOLDER}
# If argument is version
elif [[ $1 == "--version" ]]; then
  # Print version
  printf "${YELLOWC}Backup Script v$VERSION\n${DEFAULTC}"
# If arguent is something random
else
  # Print usage text
  printf "\n$CYANC ___          _               ___         _\n| _ ) __ _ __| |___  _ _ __  / __|_  _ __| |_ ___ _ __\n| _ \\/ _\` / _| / / || | \'_ \\ \\__ \\ || (_-<  _/ -_) \'  \\ \n|___/\\__,_\\__|_\\_\\\\\_,_| .__/ |___/\\_, /__/\\__\\___|_|_|_|\n                      |_|         |__/                 \nBy Intriguing#0001 | Version: v${VERSION}${DEFAULTC}\n\n"
  printf "${YELLOWC}Usage:\n  ./${FILENAMERAN} [flags]\n  ./${FILENAMERAN} [commands]\n\nCommands:\n  start          Begin the backup process\n\nFlags:\n  --help         Show this help menu\n  --version      Show the script version\n\n${DEFAULTC}"
fi
