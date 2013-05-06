$packageFolder = "package:>"
$ProjectName = "AzureTest"
$subscription = "hluw01"
$service = "os-test1"

$cert = Get-Item Cert:\LocalMachine\My\98A654EF795A70153D681E8C0CEF606FD6CF5A2D

$slot = "staging" #staging or production
$package = "$packageFolder\$ProjectName.cspkg"
$configuration = "$packageFolder\ServiceConfiguration.Cloud.cscfg"
$timeStampFormat = "g"
$deploymentLabel = "ContinuousDeploy to $service v%build.number%"
 
#Set-AzureSubscription -CurrentStorageAccount $service -SubscriptionName $subscription -certificate $cert
Set-AzureSubscription -SubscriptionName $subscription -SubscriptionId bdc2f900-6fd7-4e1a-bb5c-c4a97310496c -Certificate $cert
Select-AzureSubscrsption -SubscriptionName hluw01
$storageAccounts = Get-AzureStorageAccount
Set-AzureStorageAccount $storageAccounts[0].Label
Set-AzureSubscription $subscription  -CurrentStorageAccount $storageAccounts[0].Label
 
function Publish(){
 $deployment = Get-AzureDeployment -ServiceName $service -Slot $slot -ErrorVariable a -ErrorAction silentlycontinue 
 
 if ($a[0] -ne $null) {
    Write-Output "$(Get-Date -f $timeStampFormat) - No deployment is detected. Creating a new deployment. "
 }
 
 if ($deployment.Name -ne $null) {
    #Update deployment inplace (usually faster, cheaper, won't destroy VIP)
    Write-Output "$(Get-Date -f $timeStampFormat) - Deployment exists in $servicename.  Upgrading deployment."
    UpgradeDeployment
 } else {
    CreateNewDeployment
 }
}
 
function CreateNewDeployment()
{
    write-progress -id 3 -activity "Creating New Deployment" -Status "In progress"
    Write-Output "$(Get-Date -f $timeStampFormat) - Creating New Deployment: In progress"
 
    $opstat = New-AzureDeployment -Slot $slot -Package $package -Configuration $configuration -label $deploymentLabel -ServiceName $service
 
    $completeDeployment = Get-AzureDeployment -ServiceName $service -Slot $slot
    $completeDeploymentID = $completeDeployment.deploymentid
 
    write-progress -id 3 -activity "Creating New Deployment" -completed -Status "Complete"
    Write-Output "$(Get-Date -f $timeStampFormat) - Creating New Deployment: Complete, Deployment ID: $completeDeploymentID"
}
 
function UpgradeDeployment()
{
    write-progress -id 3 -activity "Upgrading Deployment" -Status "In progress"
    Write-Output "$(Get-Date -f $timeStampFormat) - Upgrading Deployment: In progress"
    Write-Output "Updating $package"
 
    # perform Update-Deployment
    $setdeployment = Set-AzureDeployment -Upgrade -Slot $slot -Package $package -Configuration $configuration -label $deploymentLabel -ServiceName $service -Force
 
    $completeDeployment = Get-AzureDeployment -ServiceName $service -Slot $slot
    $completeDeploymentID = $completeDeployment.deploymentid
 
    write-progress -id 3 -activity "Upgrading Deployment" -completed -Status "Complete"
    Write-Output "$(Get-Date -f $timeStampFormat) - Upgrading Deployment: Complete, Deployment ID: $completeDeploymentID"
}
 
Write-Output "Create Azure Deployment"
Publish


