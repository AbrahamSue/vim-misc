#!powershell powershell -ExecutionPolicy ByPass -File
#

$Exploder = New-Object -Com InternetExplorer.Application
$Exploder.Visible=$false
$Exploder.Navigate($args[0])
while ($Exploder.Busy) {}                                        # this should be done with a listener on the onload event
$OLECMDID_SELECTALL=17                                           # see http://msdn.microsoft.com/en-us/library/ms691264%28v=vs.85%29.aspx
$OLECMDID_COPY=12                                                # see http://msdn.microsoft.com/en-us/library/ms691264%28v=vs.85%29.aspx
$wdFormatOriginalFormatting=16                                   # see http://msdn.microsoft.com/en-us/library/bb237976%28v=office.12%29.aspx
$Exploder.ExecWB($OLECMDID_SELECTALL,0,$null,[ref]$null)         # select all the page
$Exploder.ExecWB($OLECMDID_COPY,0,$null,[ref]$null)              # and copy the selection to the clipboard
$Exploder.Quit()
