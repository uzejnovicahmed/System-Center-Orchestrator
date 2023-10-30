

param(

    [string]$ServerInstance = "Server\Instance",
    [string]$Database = "orchestrator",
    [string]$BasePath = "c:\SCO_PS_STRUCTURE\Runbooks\"

)


function Execute-SqlSelectQuery {
    param (
        [string]$ServerInstance,
        [string]$Database,
        [string]$Query
    )

    $connectionString = "Server=$ServerInstance;Database=$Database;Integrated Security=True"
    
    try {
        $result = Invoke-SqlCmd -Query $Query -ServerInstance $ServerInstance -Database $Database

        # Output the results
        $result
    } catch {
        Write-Error "Error executing query: $_"
    }
}

$query = @"
DECLARE @BasePath NVARCHAR(255) = '$($basepath)';

SELECT
    @BasePath + ISNULL(F2.Name, '') + '\' + F1.Name + '\' + P.Name + '\' + O.Name + '.ps1' AS FolderPath,
    R.ScriptBody
FROM FOLDERS AS F1
JOIN Policies AS P ON F1.UniqueID = P.ParentID
JOIN Objects AS O ON P.UniqueID = O.ParentID
JOIN RUNDOTNETSCRIPT AS R ON O.UniqueID = R.UniqueID
LEFT JOIN FOLDERS AS F2 ON F1.ParentID = F2.UniqueID
WHERE R.ScriptType = 'PowerShell';
"@

$result = Execute-SqlSelectQuery -ServerInstance $serverInstance -Database $database -Query $query



foreach ($object in $result) {
    $filePath = $object.FolderPath
    $fileContent = $object.ScriptBody

    if (Test-Path -Path $filePath -PathType Leaf) {
        # File already exists, so overwrite it
        Set-Content -Path $filePath -Value $fileContent
        Write-Host "File '$filePath' already exists and has been overwritten."
    } else {
        # File doesn't exist, create it
        New-Item -Path $filePath -ItemType File -Force
        Set-Content -Path $filePath -Value $fileContent
        Write-Host "File '$filePath' has been created."
    }
}
