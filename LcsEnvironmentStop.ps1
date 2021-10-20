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
$Az = Get-InstalledModule -Name AZ -ErrorAction SilentlyContinue
$DfoTools = Get-InstalledModule -Name d365fo.tools -ErrorAction SilentlyContinue

if([string]::IsNullOrEmpty($NuGet))
{
    Install-PackageProvider nuget -Scope CurrentUser -Force -Confirm:$false
}
if([string]::IsNullOrEmpty($Az))
{
    Install-Module -Name AZ -AllowClobber -Scope CurrentUser -Force -Confirm:$False -SkipPublisherCheck
}
if([string]::IsNullOrEmpty($DfoTools))
{
    Install-Module -Name d365fo.tools -AllowClobber -Scope CurrentUser -Force -Confirm:$false
}
Get-D365LcsApiToken -ClientId $ClientId -Username $Username -Password $Password -LcsApiUri "https://lcsapi.lcs.dynamics.com" -Verbose | Set-D365LcsApiConfig -ProjectId $ProjectId
return Invoke-D365LcsEnvironmentStop -EnvironmentId $EnvironmentId
