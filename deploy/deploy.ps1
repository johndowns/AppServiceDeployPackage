$sourceAlias = '_Packages-CI'
$resourceGroupName = 'MyResourceGroup'

$storageContext = New-AzureStorageContext -StorageAccountName $env:StorageAccountName -StorageAccountKey $env:StorageAccountKey

$containerName = 'packages'
$guid = [guid]::NewGuid()
$blobName = "$env:Build_DefinitionName/$env:Build_BuildNumber-$guid.zip"
$expiry = (Get-Date).AddYears(100)

$appPackagePath = [IO.Path]::Combine($env:Agent_ReleaseDirectory, $sourceAlias, 'app', 'EmptyApp.zip')
Set-AzureStorageBlobContent -File $appPackagePath -Container $containerName -Blob $blobName -Context $storageContext
$blobSasUrl = New-AzureStorageBlobSASToken -Container $containerName -Context $storageContext -Blob $blobName -ExpiryTime $expiry -Permission r -FullUri

$armTemplatePath = [IO.Path]::Combine($env:Agent_ReleaseDirectory, $sourceAlias, 'deploy', 'template-app.json')
$armDeploymentParameters = @{}
$armDeploymentParameters.Add('packageUrl', $blobSasUrl)
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $armTemplatePath -TemplateParameterObject $armDeploymentParameters
