'Script for hidden usbHidWatcher.ps1 run from taskschd'
command = "powershell.exe  -executionpolicy unrestricted -nologo -windowstyle hidden -file C:\log\usbHid\source\usbHidWatcher.ps1"
	set shell = CreateObject("WScript.Shell")
	shell.Run command,0