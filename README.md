# OBSKiller
OBSKiller sets up DNS monitoring on a machine and ties in an event trigger to immediatly shut down OBS if certain DNS requests are made.  This can be used to prevent disclosing personal information while forgetting your stream is running, or accidentaly 'Violating Streaming Policy' by visiting 'Certain Websites'.

# What OBSKiller Does
* Enables the DNS Client Log in Event Monitor
* Puts a small vbs script in the Public folder
* Creates a scheduled task to trigger off of DNS Requests via DNS Client log

The VBS script is soley to make the powershell script that fires completly silent as opposed to getting the P$ Console pop-up normally shown in scheduled tasks (source: http://www.leporelo.eu/blog.aspx?id=run-scheduled-tasks-with-winform-gui-in-powershell)

# Installing OBSKiller
You will probably have to enable script execution to install:
1. Hit the windows key and start searching for "powershell"
2. Right-Click the Powershell icon and click 'Run as Aministrator'
3. Type `Set-ExecutionPolicy -Bypass`

To install, simply edit the sites.txt file included with the script, and run with admin privileges. If your username is User01 and it's in your download folder, you could open an administrative prompt (CMD or P$) and run:

* `powershell.exe "c:\Users\User01\Downloads\obsKiller.ps1"` -CMD Prompt
* `"c:\Users\User01\Downloads\obsKiller.ps1"` -Powershell 

# Changing Monitored Sites

To change the sites included simply edit your sites.txt folder and run the script with the -reload tag
* `powershell.exe "c:\Users\User01\Downloads\obsKiller.ps1 -reload"` -CMD Prompt
* `"c:\Users\User01\Downloads\obsKiller.ps1 -reload"` -Powershell 

# Uninstalling
Run the Script with the -Uninstall Flag
* `powershell.exe "c:\Users\User01\Downloads\obsKiller.ps1 -uninstall"` -CMD Prompt
* `"c:\Users\User01\Downloads\obsKiller.ps1 -uninstall"` -Powershell 

# Other Notes
* This is off of DNS Queries so this wont work on back to back to back queries unless you clear out your DNS cache
* Browsers like to keep their own DNS cache - so you may have to clear those out as well if you're testing (incognito tabs always seem to work though)
* This only works on *LITERALS*, no partial matches, 'Likes', etc
* Some site will redirect to a new entry so they can be missed (I've had sites I found out I had to explicitly add www. to even though I was attempting the site without it).
* sites.txt needs to be in the same directory as obskiller.ps1 (obviously)
* **TEST AND VALIDATE YOUR OWN CONFIG AND USE AT YOUR OWN RISK**
