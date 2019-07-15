choco install 7zip -y
choco install notepadplusplus -y
choco install nssm -y

$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12';
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols;

(new-object system.net.webclient).downloadfile('https://releases.hashicorp.com/nomad/0.9.3/nomad_0.9.3_windows_amd64.zip','C:\nomad\nomad.zip')

Set-Alias sz "$env:ProgramFiles\7-Zip\7z.exe"

sz x "C:\nomad\nomad.zip" -oC:\nomad

Remove-Item C:\nomad\nomad.zip

