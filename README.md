License:
--------------------------
GPL3 Licensed.

Configuration:
--------------------------
Mineserver uses a file called ``config`` stored in the same directory as the
script for configuration. These should be defined by the user before the first
run. The file is interpreted by sourcing it in bash via ``source config`` and
therefore should be valid bash.

```
#Location of all servers, should be an absolute path to avoid confusion.
SERVERS=
#The server jar name. Used to start the server and identify directories that contain servers.
SERVER_JAR=minecraft_server.jar
#Location of the servers backup, should be an absolute path to avoid confusion.
BACKUP_DIR=
```

SERVERS should point to the directory where Minecraft servers are stored.  
SERVER_JAR is the name of the minecraft server jar file__
BACKUP_DIR should specify the directory where backup archives will be stored.__

USAGE:
--------------------------
The script will execute all the flags provided in the command line sequentially.  
program options server_name

options:

-h help

-R remove server

-r restore server

-b backup server

-s start server (creates one if missing)

-l list servers

Example:
``
./Server -sb our_sever
``
This will run the server and then back it up when it is stopped.
