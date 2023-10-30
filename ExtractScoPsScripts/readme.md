# PS Script to Retrieve and Save System Center Orchestrator PowerShell Scripts

This PowerShell script connects to a SQL Server database, retrieves PowerShell scripts, and saves them to the local filesystem. It provides flexibility through configurable parameters.

## Parameters

- **ServerInstance**: The SQL Server instance to connect to. Default is "SERVER\INSTANCE".

- **Database**: The name of the database to query. Default is "orchestrator".

- **BasePath**: The base directory where the script files will be saved. Default is "c:\SCO_PS_STRUCTURE\Runbooks\".

## Function: Execute-SqlSelectQuery

This function executes a SQL query and returns the result.

### Parameters

- **ServerInstance**: The SQL Server instance.

- **Database**: The name of the database.

- **Query**: The SQL query to execute.


## Expected Result

After running the PowerShell script, you can expect to receive a collection of objects representing the results of the SQL query. Each object includes two properties:

- `FolderPath`: A string representing the file path where the script file will be saved.

- `ScriptBody`: A string containing the content of the PowerShell script.

Here is an example representation of a single object in the result:

```json
{
  "FolderPath": "c:\SCO_PS_STRUCTURE\Runbooks\SomeFolder\SomeScript.ps1",
  "ScriptBody": "Write-Host 'Hello, World!'"
}
```

From this results we are generating the Powershell Files located in the System Center Orchestrator


## Example Usage

```powershell
# Define the SQL Server connection parameters
$serverInstance = "SERVER\INSTANCE"
$database = "orchestrator"

# Specify the base path where the PowerShell script files will be saved
$basePath = "c:\SCO_PS_STRUCTURE\Runbooks\"

# Execute the SQL query to retrieve script data from the database
$query = @"
# Your SQL Query Here
"@

# Execute the SQL query and save the script files
$result = Execute-SqlSelectQuery -ServerInstance $serverInstance -Database $database -Query $query

# Process the query results and save script files
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
```
