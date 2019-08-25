param (
    [Parameter(Mandatory=$true)][string]$nomad_version
)

choco install 7zip -y --no-progress
choco install notepadplusplus -y --no-progress
choco install nssm -y --no-progress

$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12';
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols;

(new-object system.net.webclient).downloadfile("https://releases.hashicorp.com/nomad/$($nomad_version)/nomad_$($nomad_version)_windows_amd64.zip","C:\nomad\nomad.zip")

Set-Alias sz "$env:ProgramFiles\7-Zip\7z.exe"

sz x "C:\nomad\nomad.zip" -oC:\nomad

Remove-Item C:\nomad\nomad.zip

