# pmichel 18 Sep 2017

param	(
	[Parameter(Mandatory=$True,Position=1)]
	[string]$changesetting,
	[Parameter(Mandatory=$True,Position=2)]
	[string]$command,
	[Parameter(Mandatory=$True,ValueFromRemainingArguments=$true)]
	[string[]]$details
	)

function IsFileAccessible()
{
	$HOSTSFILE = "c:\windows\system32\drivers\etc\hosts"
	[Boolean] $IsAccessible = $false

  try
  {
    Rename-Item $HOSTSFILE $HOSTSFILE -ErrorVariable LockError -ErrorAction Stop
    $IsAccessible = $true
  }
  catch
  {
    $IsAccessible = $false
  }
  return $IsAccessible
}
	
	
	switch ($changesetting)
	{
	"HOSTS"
		{
		switch ($command)
			{
			"ADD"
				{
				$CONTAINERNAME=$details[0]
				$CONTAINERIP=$details[1]
				$CONTAINERHOST=$details[2]
				(Get-Content c:\windows\system32\drivers\etc\hosts) -notmatch " $CONTAINERNAME " | Set-Content c:\windows\system32\drivers\etc\hosts
				$hostsstatus=IsFileAccessible
				do	{
					sleep 0.5
					$hostsstatus=IsFileAccessible
					}
				while ($hostsstatus -eq $false)
				Add-Content c:\windows\system32\drivers\etc\hosts "$CONTAINERIP $CONTAINERNAME #$CONTAINERHOST#"
				}
			"REMOVE"
				{
				$CONTAINERNAME=$details[0]
				(Get-Content c:\windows\system32\drivers\etc\hosts) -notmatch " $CONTAINERNAME " | Set-Content c:\windows\system32\drivers\etc\hosts				
				}

			"PURGE"
				{
				$CONTAINERHOST=$details[0]
				(Get-Content c:\windows\system32\drivers\etc\hosts) -notmatch " #$CONTAINERHOST#" | Set-Content c:\windows\system32\drivers\etc\hosts
				}
			}
		}
	"RDP"
		{
		switch ($command)
			{
			"ADD"
				{
				$CONTAINERNAME=$details[0]
				$CONTAINERHOST=$details[1]
				Copy-Item rdptemplate.txt newrdp
				Add-Content newrdp "full address:s:$CONTAINERNAME"
				Copy-Item newrdp Desktop\$CONTAINERNAME.$CONTAINERHOST.rdp
				Remove-Item newrdp
				}

			"REMOVE"
				{
				$CONTAINERNAME=$details[0]
				$CONTAINERHOST=$details[1]
				Remove-Item Desktop\$CONTAINERNAME.$CONTAINERHOST.rdp
				}

			"PURGE"
				{
				$CONTAINERHOST=$details[0]
				Remove-Item Desktop\*.$CONTAINERHOST.rdp
				}


			}
	
		}
	"STUDIO"
		{
		switch ($command)
			{
			"ADD"
				{
				$REGISTRYPATH="HKLM:SOFTWARE\WOW6432Node\Intersystems\Cache\Servers\"
				$CONTAINERNAME=$details[0]
				$CONTAINERHOST=$details[1]
				$THISPATH=$REGISTRYPATH + "\" + $CONTAINERNAME
				if(!(Test-Path $THISPATH))
					{
					New-Item -Path $REGISTRYPATH -Name $CONTAINERNAME | Out-Null
					New-ItemProperty -Path $THISPATH -Name "Address" -Value "$CONTAINERNAME" | Out-Null
					New-ItemProperty -Path $THISPATH -Name "Port" -Value "1972" | Out-Null
					New-ItemProperty -Path $THISPATH -Name "Telnet" -Value "23" | Out-Null
					New-ItemProperty -Path $THISPATH -Name "Comment" -Value "$CONTAINERHOST" | Out-Null
					New-ItemProperty -Path $THISPATH -Name "AuthenticationMethod" -Value "0" | Out-Null
					New-ItemProperty -Path $THISPATH -Name "ConnectionSecurityLevel" | Out-Null
					New-ItemProperty -Path $THISPATH -Name "ServicePrincipalName" | Out-Null
					New-ItemProperty -Path $THISPATH -Name "ServerType"| Out-Null
					New-ItemProperty -Path $THISPATH -Name "WebServerPort" -Value "57772" | Out-Null
					New-ItemProperty -Path $THISPATH -Name "WebServerAddress" -Value "$CONTAINERNAME" | Out-Null
					New-ItemProperty -Path $THISPATH -Name "WebServerInstanceName" | Out-Null
					}
				}
			"REMOVE"
				{
				$entries=$details.split(" ")
				$REGISTRYPATH="HKLM:SOFTWARE\WOW6432Node\Intersystems\Cache\Servers\"
				foreach ($CONTAINER in $entries)
					{
						$THISPATH=$REGISTRYPATH + "\" + $CONTAINER
						if(Test-Path $THISPATH)
						{
							Remove-Item -Path $THISPATH
						}
					}
				}
			"PURGE"
				{
				$REGISTRYPATH="HKLM:SOFTWARE\WOW6432Node\Intersystems\Cache\Servers\"
				$DOCKERHOST=$details[0]
				foreach ($THISCOMMENT in Get-ChildItem -path $REGISTRYPATH -recurse -EA silentlycontinue)
					{
						$THATCOMMENT=(Get-ItemProperty -Path $THISCOMMENT.PsPath).Comment
						if ($THATCOMMENT -like $DOCKERHOST)
							{
								Remove-Item -Path $THISCOMMENT.PsPath
							}
					}
				}
			}
		}
	default {
		"$changesetting,$command,$details"
		"Usage: powershell /c ./j2dconfig.ps1 HOSTS|STUDIO|RDP ADD|REMOVE|PURGE <container name><ip><container host>"
		}
	}
	
	
