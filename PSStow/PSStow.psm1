Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop';

Function CreateResult($Success, $Message, $Item, $Store) {
	return [pscustomobject]@{
		'Success' = $Success;
        'Message' = $Message;
        'Item' = $Item;
		'Store' = $Store
	};
}

Function GetRoot([string]$Path) {
    return [System.IO.Path]::GetPathRoot($Path);
}

Function GetAbsolutePath {
    param([string]$Path)
    
    [IO.Path]::GetFullPath([IO.Path]::Combine((Get-Location).ProviderPath, $Path));
}

Function RemoveRoot([string]$Path) {
    $root = GetRoot $Path
    $Path.Replace($root, '') -replace '^(/|\\)','';
}

Function CombinePath {
    [IO.Path]::Combine(([string[]]$args));
}

Function ValidatePathStoreRelationship {
    param([string]$Path, [string]$Store)

    $Path = GetAbsolutePath $Path;
    $Store = GetAbsolutePath $Store;

    # for now, then change it to allow different roots.
    if ((GetRoot $Path) -ne (GetRoot $Store)) {
        return 'Item Path and Store must in the same root';
    }

    if ($Path.StartsWith($Store)) {
        return 'Item cannot be be a sub-directory of Store';
    }

    if ($Store.StartsWith($Path)) {
        return 'Item cannot be a parent directory of Store';
    }
}

Function GetAbsoluteStoragePath {
    param([string]$Path, $Store) 
   
    # if you have a store path like
    # C:\MyStore 
    # and an item
    # C:\Users\th203\hello\world
    # you get 
    # C:\MyStore\-C\Users\th203\hello\world
    # if there was a directory in the D:\ drive:
    # D:\Java\FurtherJava
    # you get 
    # C:\MyStore\-D\Java\FurtherJava

    $absPath = GetAbsolutePath $Path;

    $rootDir = "";

    $absPathRoot = [IO.Path]::GetPathRoot($absPath)
    if ($absPathRoot -match '^[a-z]+:\\$') {
        $driveLetter = $absPathRoot -replace '^([a-z]+):\\$','$1';
        $rootDir = "-$driveLetter";
    } else {
        $rootDir = ($absPathRoot -replace '^(//|\\\\)','--') -replace '/','\'
    }

    CombinePath (GetAbsolutePath $Store) ($rootDir) (RemoveRoot $absPath);
}

Function Stow-Item {
    param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)][string[]]$Path, 
        [Parameter(Mandatory=$true,Position=1)][string]$Store
    )
    
    process {
        foreach ($Item in $Path) {
            
            $createResult = { 
                param($Success, $Message)
                return CreateResult -Success $Success -Item $Item -Message $Message -Store $Store
            };

            $validationResult = ValidatePathStoreRelationship -Path $Item -Store $Store;

            if ($validationResult) {
                return &$createResult $false $validationResult
            }

            if (-not (Test-Path $Item)) {
                return &$createResult $null 'Item does not exist'
            }
            
            try {
                $fullStorePath = GetAbsoluteStoragePath $Item $Store;

                if (Test-Path $fullStorePath) {
                    return &$createResult $false "There is already a folder $fullStorePath"  
                }
                
                # given a fullpath of C:\Dirs\MyStore\Users\th203\hello\world, you get 
                # C:\Dirs\MyStore\Users\th203\hello\
                $storeParent = Split-Path $fullStorePath;
                if (-not (Test-Path $storeParent)) {
                    # create the parent directory if it does not exist
                    try {
                        mkdir $storeParent -ErrorAction Stop | Out-Null
                    } catch {
                        return &$createResult $false "Could not create directory '$storeParent': $($_.Exception.Message)" 
                    }
                }
                
                Move-Item $Item $storeParent -ErrorAction Stop
                return &$createResult $true "Successfully moved $Item to $storeParent"
                
            } catch {
                return &$createResult $false $_.Exception.Message  
            }
        }
    }
}

Function Unstow-Item {
    param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)][string[]]$Path,
        [Parameter(Mandatory=$true,Position=1)][string]$Store
    )

    process {
        foreach ($Item in $Path) {

            $createResult = { 
                param($Success, $Message)
                return CreateResult -Success $Success -Item $Item -Message $Message -Store $Store
            };

            # given $store C:\_data\Store
            # and a $Item C:\mydata\myjavadata
            # $storeLocation will be  C:\_data\Store\mydata\myjavadata
            $storeLocation = GetAbsoluteStoragePath $Item $Store;

            $validationResult = ValidatePathStoreRelationship -Path $Item -Store $Store;

            if ($validationResult) {
                return &$createResult $false $validationResult;
            }

            if (-not (Test-Path $storeLocation)) {
                return &$createResult $null "Store location does not exist"  
            }
            
            if (Test-Path $Item) {
                return &$createResult $false "Destination exists: $( GetAbsolutePath $Item )"  
            }
            
            try {
                $parentPath = Split-Path $Item;

                if (-not (Test-Path $parentPath)) {
                    mkdir $parentPath -ErrorAction Stop | Out-Null
                }

                Move-Item $storeLocation $parentPath -ErrorAction Stop;
                return &$createResult $true "Successfully returned to $Item"  
            } catch {
                return &$createResult $false $_.Exception.Message  
            }
        }
    }
}

Export-ModuleMember -Function Stow-Item
Export-ModuleMember -Function Unstow-Item
