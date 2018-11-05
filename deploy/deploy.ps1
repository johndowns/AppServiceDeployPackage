$storageContext = New-AzureStorageContext -StorageAccountName $env:StorageAccountName -StorageAccountKey $env:StorageAccountKey

$containerName = 'packages'
$guid = [guid]::NewGuid()
$blobName = "$env:Build__DefinitionName/$env:Build__BuildId-$guid.zip"
$expiry = (Get-Date).AddYears(100)

$filePath = [io.path]::combine($env:Agent_ReleaseDirectory, $env:Build__DefinitionName, 'EmptyApp.zip')

Write-Host $filePath

Write-Host $blobName

Set-AzureStorageBlobContent -File $filePath -Container $containerName -Blob $blobName -Context $storageContext

$blobSasUrl = New-AzureStorageBlobSASToken -Container $containerName -Context $storageContext -Blob $blobName -ExpiryTime $expiry -Permission r -FullUri

Write-Host $blobSasUrl




#New-AzureStorageBlobSASToken

#New-AzureRmResourceGroupDeployment -TemplateParameterFile template-app.json
