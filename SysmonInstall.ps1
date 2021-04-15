$url = "https://github.com/Scutum/sysmon/blob/main/Sysmon64.exe?raw=true"
$urlConfig = "https://raw.githubusercontent.com/Scutum/sysmon/main/sysconfig.xml" 
$output = "$PSScriptRoot\Sysmon64.exe"
$outputConfig = "$PSScriptRoot\sysconfig.xml"
$start_time = Get-Date
$wazuh_config = 'C:\Program Files (x86)\ossec-agent\ossec.conf'

<# INICIANDO O DOWNLOAD DO SYSMON E CONFIGURANDO #>

echo "################################"
echo "Fazendo o download dos arquivos"
echo "################################"

Invoke-WebRequest -Uri $url -OutFile $output
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
Invoke-WebRequest -Uri $urlConfig  -OutFile $outputConfig
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

echo "################################"
echo "	   Instalando o sysmon        "
echo "################################"

Sysmon64.exe -accepteula -i sysconfig.xml

echo "################################"
echo "    Configurando o sysmon       "
echo "################################"

Sysmon64.exe -accepteula -c sysconfig.xml


<# INICIANDO O DOWNLOAD DO WAZUH E INSTALANDO #>

Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.1.0-1.msi -OutFile wazuh-agent.msi; ./wazuh-agent.msi /q WAZUH_MANAGER='api.scutum.seg.br' WAZUH_REGISTRATION_SERVER='api.scutum.seg.br'

echo "#################################"
echo "Espere wazuh iniciar, tecle enter"
echo "#################################"

pause 

<# CONFIGURANDO AGENT PARA USAR O SYSMON #>
 
$out_content = "
    <localfile>
    <location>Sysmon\Operational</location>
    <log_format>eventchannel</log_format>
    </localfile>
 
    <localfile>
    <location>PowerShell\Operational</location>
    <log_format>eventchannel</log_format>
    </localfile>
 
    <localfile>
    <location>TerminalServices-RemoteConnectionManager\Operational</location>
    <log_format>eventchannel</log_format>
    </localfile>
 
    <localfile>
    <location>WMI-Activity\Operational</location>
    <log_format>eventchannel</log_format>
    </localfile>"


$fileContent = Get-Content -Path $wazuh_config
$fileContent[203] = "{0}`r`n{1}" -f $out_content, $fileContent[203]
$fileContent | Set-Content $wazuh_config

echo "################################"
echo "Processo configurado com sucesso"
echo "################################"

pause
