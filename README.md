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
1. SSH into UXG-Lite to create a crontab file so the script runs on reboot in addition to a scheduled interval

   ```
   crontab -e
   ```
   a - to enter Insert mode,
   enter these two lines below after the last line in the file
   ```
   @reboot /persistent/system/blocklist.sh
   @daily /persistent/system/blocklist.sh
   ```
   :wq - to quit and write the crontab file,
   crontab: installing new crontab - should be displayed after writing and quiting the editor
   
1. Reboot UXG-Lite to force immediate script execution or SSH into UXG-Lite and run below command to force immediate script execution

   ```
   /persistent/system/blocklist.sh
   ```

You can use a tool like FileZilla FTP client to SFTP to your UXG-Lite and browse the file system.  After the script executes you should be able to see the backup file and the log of the script execution in the /persistent/system directory.
You can also see the logging of the blocked addresses within the conrtoller in the System Log > Triggers area.
