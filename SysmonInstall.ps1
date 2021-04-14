$url = "https://github.com/Scutum/sysmon/blob/main/Sysmon64.exe?raw=true"
$urlConfig = "https://raw.githubusercontent.com/Scutum/sysmon/main/sysconfig.xml" 
$output = "$PSScriptRoot\Sysmon64.exe"
$outputConfig = "$PSScriptRoot\sysconfig.xml"
$start_time = Get-Date

echo "Fazendo o download dos arquivos"

Invoke-WebRequest -Uri $url -OutFile $output
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
Invoke-WebRequest -Uri $urlConfig  -OutFile $outputConfig
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

echo "Instalando o Sysmon"
Sysmon64.exe -accepteula -i sysconfig.xml

echo "Configurando o Sysmon"
Sysmon64.exe -accepteula -c sysconfig.xml

echo "Processo finalizado com sucesso"

pause 