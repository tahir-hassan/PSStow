Import-Module "$PSScriptRoot\PSStow.psm1" -Force

GetAbsoluteStoragePath "C:\Users\th203\hello\world" "C:\MyStore";
# C:\MyStore\-C\Users\th203\hello\world
GetAbsoluteStoragePath "D:\Java\FurtherJava" "C:\MyStore";

GetAbsoluteStoragePath -Path "D:\Java\FurtherJava" -Store "\\network\store";

GetAbsoluteStoragePath -Path "\\network\Users\th203\hello\world" -Store "C:\MyStore"; 

GetAbsoluteStoragePath -Path "\\network\Users\th203\hello\world" -Store "C:\MyStore"; 

GetAbsoluteStoragePath "\\network\Users\th203\hello\world" "\\network\MyStore";
