# Dynamic IP/CIDR Blocklist for the Unifi UXG-Lite router

Having a UXG-Lite I wanted to create a script that kept a daily dynamic blocklist updated
from several reputable sources.  The script itself is quite simple but requires setup within the controller to work
correctly.

1. Setup a firewall IPv4 group called "FireHOL" with one place holder IPv4 address or subnet such as "192.168.0.0/16" as this address will always be in the list anyway as it is a bogon.  The name is important because it's used by the script.
1. Setup firewall Internet In, Internet Local, and Internet Out rules to drop traffic from/to this group.
1. Download the blocklist.sh file to your PC and use a tool like FileZilla to upload the file to your UXG-Lite. Upload it to /persistent/system on the UXG-Lite.  Please check the files before running.
1. SSH into your UXG-Lite and make the script executable.
   
   ```
   chmod +x /persistent/system/blocklist.sh
   ```
1. SSH into UXG-Lite to edit the default crontab file so the script runs on reboot in addition to a scheduled interval

   ```
   vi /etc/crontab
   ```
   Press ```a``` on your keyboard to enter Insert mode,
   enter these two lines below after the last line in the file
   ```
   @reboot /persistent/system/blocklist.sh
   @daily /persistent/system/blocklist.sh
   ```
   Press ESC on your keyboard, then enter ```:wq``` to quit and write the crontab file.

1. Then enter ```service cron reload``` and you should then see ```Reloading configuration files for periodic command scheduler: cron.```
   
1. Reboot UXG-Lite to force immediate script execution or SSH into UXG-Lite and run below command to force immediate script execution

   ```
   /persistent/system/blocklist.sh
   ```

You can use a tool like FileZilla FTP client to SFTP to your UXG-Lite and browse the file system.  After the script executes you should be able to see the backup file and the log of the script execution in the /persistent/system directory.
You can also see the logging of the blocked addresses within the controller in the System Log > Triggers area.
This configuration will make the script persistent across reboots and firmware upgrades.
Example screenshots showing the configuration areas in the controller, system logs to show the blocklist script is working, crontab file example, and FileZilla client showing the script log location are also included.
