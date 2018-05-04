Import-Module "$PSScriptRoot\PSStow.psm1" -Force

Get-AbsoluteStowStoragePath "C:\Users\th203\hello\world" "C:\MyStore";
# C:\MyStore\-C\Users\th203\hello\world
Get-AbsoluteStowStoragePath "D:\Java\FurtherJava" "C:\MyStore";

Get-AbsoluteStowStoragePath -Path "D:\Java\FurtherJava" -Store "\\network\store";

Get-AbsoluteStowStoragePath -Path "\\network\Users\th203\hello\world" -Store "C:\MyStore"; 

Get-AbsoluteStowStoragePath -Path "\\network\Users\th203\hello\world" -Store "C:\MyStore"; 

Get-AbsoluteStowStoragePath "\\network\Users\th203\hello\world" "\\network\MyStore";
