   [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ClientId,
        [Parameter()]
        [string]$Username,
        [string]$Password,
        $ProjectId,
        [string]$EnvironmentId)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Check Modules installed
$NuGet = Get-PackageProvider -Name nuget -ErrorAction SilentlyContinue
function installModules {
     Param(
         [String[]] $modules
     )
     begin{
         Set-MpPreference -DisableRealtimeMonitoring $true
     }
     process{
         $modules | ForEach-Object {
             if($_ -eq "Az")
             {
                 Set-ExecutionPolicy RemoteSigned
                 try {
                     Uninstall-AzureRm
                 }
                 catch {
                 }
             }
             if (-not (get-installedmodule -Name $_ -ErrorAction SilentlyContinue)) {
                 Write-Host "Installing module $_"
                 Install-Module $_ -Force -AllowClobber | Out-Null
             }
         }
         $modules | ForEach-Object { 
             Write-Host "Importing module $_"
             Import-Module $_ -DisableNameChecking -WarningAction SilentlyContinue | Out-Null
         }
     }
     end{
         Set-MpPreference -DisableRealtimeMonitoring $false
     }
 }

if([string]::IsNullOrEmpty($NuGet))
{
    Install-PackageProvider nuget -Scope CurrentUser -Force -Confirm:$false
}

installModules AZ,Azure.Storage,d365fo.tools
Get-D365LcsApiToken -ClientId $ClientId -Username $Username -Password $Password -LcsApiUri "https://lcsapi.lcs.dynamics.com" -Verbose | Set-D365LcsApiConfig -ProjectId $ProjectId
return Invoke-D365LcsEnvironmentStop -EnvironmentId $EnvironmentId
