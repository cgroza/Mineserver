#!/bin/bash

removeserver()
{
    #ask the user for permission to backup
    read -p "Do you wish to remove $SERVER_DIR? y/N:" asw

    if [ $asw == "y" ]; then
	echo "Deleting $SERVER_DIR..."
	echo "rm $SERVER_DIR"
	rm -rv $SERVER_DIR
    fi
}

update_server()
{
    echo "CHECKING FOR UPDATES: "
    #get minecraft jar download urld from the website
    update_url=$(wget -O - "https://minecraft.net/download" | grep -o "\"https.*minecraft_server.[0-9]*.[0-9]*.[0-9]*.jar\"" | tr -d "\"")
    #strip the rest of url to get the filename
    minecraft_file=$(basename "$update_url")
    #strip non numerical characters name.d.d.d.jar --> ddd
    link_version=$(echo -n $minecraft_file | sed -e s/[^0-9]//g)
    #local version is saved in $SERVER_DIR/version
    local_version=$(cat version)
    echo $update_url
    if [ "$link_version" -gt "$local_version" ]; then
	echo "SERVER UPDATE AVAILABLE... UPDATING TO $link_version"
	echo "Downloading $update_url..."
	wget $update_url
	if [ $? -eq 0 ]; then
	    echo "UPDATE SUCCESSFUL! Renaming and editing version file..."
	    echo "mv $minecraft_file minecraft_server.jar"
	    mv "$minecraft_file" minecraft_server.jar
	    echo $link_version > version
	else
	    echo "UPDATE FAILED. Fix it and restart it!"
	fi
    else
	echo "NO NEW SERVER VERSION AVAILABLE"
    fi
}

runserver()
{
    #working in the server directory from here.
    cd $SERVER_DIR
    #create server if it does not exist
    if [ $? -eq 1 ]; then
	read -p "SERVER NOT FOUND! Create? y/n: " asw
	if [ $asw == "y" ]; then
	    # create dir and version file
	    mkdir $SERVER_DIR
	    cd $SERVER_DIR
	    echo "0" > version
	    # agree to eula and crack the server
	    echo "eula=true" > eula.txt
	    $EDITOR server.properties
	else
	    exit 0
	fi
    fi    
    read SERVER_SIZE rest <<< $(du -hs $SERVER_DIR)
    update_server

    echo "Starting $SERVER_NAME... Have fun."
    echo "java -Xms1024M -Xmx1024M -jar $SERVER_JAR nogui"
    wget -q --read-timeout=0.0 --waitretry=5 --tries=400 --background http://ipv4.cloudns.net/api/dynamicURL/?q=NTgzODI5OjUxMDc3Njg6OWViNDczM2QzNjIwZGYwYWJlYzg2ZTBmM2ZhOTFhYzliY2ZhZDA4YjA5NTFkN2YxNzk4NWMwZjJmZjUxOGUwNw
    rm index.html* >> /dev/null
    java -Xms1024M -Xmx1024M -jar "$SERVER_JAR" nogui
    echo "The server has stopped."
    #print server size
    read NEW_SERVER_SIZE rest <<< $(du -hs $SERVER_DIR)
    echo -e "\nOld server size: "$SERVER_SIZE
    echo -e "New server size: "$NEW_SERVER_SIZE"\n"
}

backup()
{
    #ask the user for permission to backup
    read -p "Do you wish to back it up to $BACKUP_DIR? y/N:" asw
    if [ $asw == "y" ]; then
	BACKUP=$BACKUP_DIR/$SERVER_NAME.tar.gz
	if [ -f $BACKUP ]; then
	    echo "Deleting old backup..."
	    echo "rm $BACKUP"
	    rm $BACKUP
	fi
	echo "Backing up to $BACKUP ..."
	echo "tar -cvzf $BACKUP $SERVER_DIR"
	#compress the server and move it to $BACKUP
	tar -cvzf $BACKUP $SERVER_DIR
	if [ $? -eq "0" ]; then
	    echo "Backup succesful."
	else
	    echo "Backup failed. cp: Code $?"
	fi
    fi
}

listservers()
{
    echo "SERVERS IN $SERVERS:"
    cd $SERVERS
    for server in *
    do
	if [ $(ls "$server" | grep "minecraft_server.jar") ]
	then
	    echo $server
	fi
    done
}

TEMP=`getopt -o srbl -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

source config
#Location of all servers
SERVERS=/media/Storage
#This variable contains the server name. It is used to support multiple servers.
SERVER_NAME=${@: -1} #get last argument on argument list (server-name)
#The server directory is only refered by this variable.
SERVER_DIR=${SERVERS}/${SERVER_NAME}
#The server jar. Used to swtich between bukkit or vanilla.
SERVER_JAR=minecraft_server.jar
BACKUP_DIR=/media/Storage/Backups

while true
do
    case "$1" in
	"-s") runserver; shift;;
	"-b") backup; shift;;
	"-r") removeserver; shift;;
	"-l")  listservers; shift;;
	"-h") echo "Server.sh [-s -b -r -l] server-name";;
	*) break;;
    esac
done
