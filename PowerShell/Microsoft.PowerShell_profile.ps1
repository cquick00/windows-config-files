# =========
# FUNCTIONS
# =========
#region
function Get-Latency {
  param (
      # Time you'd like the function to stop running in 24 hour time (good values are 1, 2, 3, ..., 24) (default is 24)
      [Parameter (Mandatory = $false)]
      [ValidateSet (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24)]
      [int]
      $endTime = 24,

      # Computer Name, IP Address, or URL you'd like to ping (default is localhost)
      [Parameter (Mandatory = $false)]
      [string]
      $pingAddress = "localhost",

      # The location you'd like to output to be saved (default is ~\Documents)
      [Parameter (Mandatory = $false)]
      [string]
      $outputLocation = "~\Documents",

      # The name and type you'd like the output file to be saved as
      [Parameter (Mandatory = $false)]
      [string]
      $outputName = "latency.csv",

      # The name and type you'd like the output file to be saved as
      [Parameter (Mandatory = $false)]
      [int]
      $waitTime = 10
  )

  # Variables
  $data = New-Object -TypeName psobject
  $dataCollection = @()
  $date = ""
  $latency = 0
  $output = "$outputLocation\$outputName"
  $time = (Get-Date).Hour

  # Main
  while ($time -le $endTime) {

      # Get the date and then add it to $data
      $date = Get-Date
      $data | Add-Member -MemberType NoteProperty -Name Date -Value $date

      # Ping entered computer/ip/url and select only the response time then add it to $data
      $latency = Test-Connection -Ping $pingAddress -Count 1 | ForEach-Object { $_.Latency }
      $data | Add-Member -MemberType NoteProperty -Name Latency -Value $latency
      
      # Put $data in $dataCollection
      $dataCollection += $data

      # Export to CSV
      $dataCollection | Export-Csv -LiteralPath $output

      # Reset $data back to a new PSObject
      $data = New-Object -TypeName psobject

      # Sleep for 10 seconds
      Start-Sleep -Seconds $waitTime
      
      # Set time variable to check for end condition
      $time = (Get-Date).Hour

  }
}

function Get-LoggedOnUsers {
  param (
      $ComputerName
  )

  # variables
  $computer = $ComputerName
  $user = @()

  # main
  if ($PSBoundParameters.ContainsKey("ComputerName")) {
      Write-Host "`nComputerName: $computer"
      $user = (&"query" user /SERVER:$computer) -replace "^[\s]USERNAME[\s]+SESSIONNAME.*$", "" -replace "[\s]{2,}", "," -replace ">", "" | ConvertFrom-Csv -Delimiter "," -Header "Username", "SessionName", "Id", "State", "IdleTime", "LogonTime"
      for ($i = 0; $i -lt $user.Count; $i++) {
        if ($null -eq $user[$i].LogonTime) {
          $user[$i].LogonTime = $user[$i].IdleTime
          $user[$i].IdleTime = $user[$i].State
          $user[$i].State = $user[$i].Id
          $user[$i].Id = $user[$i].SessionName
          $user[$i].SessionName = ""
        }
      }
      Write-Output $user
  }
  else {
      $computer = HOSTNAME.EXE
      Write-Host "`nComputerName: $computer"
      $user = (&"query" user) -replace "^[\s]USERNAME[\s]+SESSIONNAME.*$", "" -replace "[\s]{2,}", "," -replace ">", "" | ConvertFrom-Csv -Delimiter "," -Header "Username", "SessionName", "Id", "State", "IdleTime", "LogonTime"
      for ($i = 0; $i -lt $user.Count; $i++) {
        if ($null -eq $user[$i].LogonTime) {
          $user[$i].LogonTime = $user[$i].IdleTime
          $user[$i].IdleTime = $user[$i].State
          $user[$i].State = $user[$i].Id
          $user[$i].Id = $user[$i].SessionName
          $user[$i].SessionName = ""
        }
      }
      Write-Output $user
  }
}

function Get-Profile {
  & $PROFILE
}

#endRegion

# =======
# ALIASES
# =======
#region
Set-Alias -Name GetUsers -Value Get-LoggedOnUsers
Set-Alias -Name ReloadProfile -Value Get-Profile
Set-Alias -Name GetLatency -Value Get-Latency
#endRegion

# =======
# STARTUP
# =======
#region
Invoke-Expression (&starship init powershell)
Set-Location ~
Clear-Host
Get-Content "~\Documents\PowerShell\banner.txt"
#endRegion

# ==========
# CHOCOLATEY
# ==========
#region
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
#endRegion
