# fs-rescan-service

FusionStorm Drive Rescan Service - 4/25/2008 - v1.10

## History
This service was developed for use with PlateSpin P2V distaster recovery of OS volumes and EMC RecoverPoint replication for DB data and log volumes.
Problem addressed:  When attaching of RecoverPoint volumes on Windows 2000 and Windows 2003 VMs following P2V failover of OS with PlateSpin the volume drive letters were inconsistent.


## Requirements
- Windows 2003 Resource Kit (https://www.microsoft.com/en-us/download/details.aspx?id=17657)
-- instsrv.exe
-- srvany.exe


## Usage
##### Web Server
- Download code from GitHub
    - _Note:  If you don't have Git installed you can also just grab the zip:  https://github.com/rbocchinfuso/opsgenie2osticket-for-slack/archive/master.zip_
```
    git clone https://github.com/rbocchinfuso/opsgenie2osticket-for-slack.git
```


##### Syntax
```
Usage:  fs_rescan_service.vbs [-h] [-install] [-uninstall] [-scan]

		-h - prints this help text
		-install - installs the fs_rescan_service
		-uninstall - uninstalls the fs_rescan_service
		-scan - manually rescans and assigns drive letters 
			(this can also be accomplished by restarting 
			the service if it is installed)

	install.bat file installs the fs_rescan_service
	(this is the preferred method for initial installation)
	
```

##### Notes
