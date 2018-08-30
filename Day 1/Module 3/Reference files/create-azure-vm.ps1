$ErrorActionPreference = 'Stop'

# Deployment specific variables 
$dnsName    = "edurekadns"  
$saName     = "opsvmrmrgdiag392"
$location   = "southeastasia"

$cred = Get-Credential -Message "Enter Admin Credentials"

# Resource group values
$rgName     = "opsvmrmrg"   
$rgVNETName = "OpsVNETRmRG" 
$VNETName   = "OpsTrainingVNET"

# WebVM-2 specific variables 
$pubName    = "MicrosoftWindowsServer"
$offerName  = "WindowsServer"
$skuName    = "2012-R2-Datacenter"
$ipName     = "webVM-2"
$nicName    = "webVMNIC2"
$vmName     = "WebVM-2"
$vmSize     = "Standard_DS1_v2"
$nsgName    = "APPSNSG"
$avSet      = "WebAVSET"


Write-Host "Getting Existing Resources from resource group $rgName" -ForegroundColor Green

# Get the existing storage account  
$storageAcc = Get-AzureRmStorageAccount -ResourceGroupName $rgName `
                                        -Name $saName

$blobEndpoint = $storageAcc.PrimaryEndpoints.Blob.ToString()

# Get the existing availability set
$avSet = Get-AzureRmAvailabilitySet -ResourceGroupName $rgName `
                                    -Name $avSet 

# Get a reference to the existing virtual network 
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $rgVNETName `
                                  -Name $VNETName   

# Get a reference to the existing network security group 
$nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $rgName `
                                       -Name $nsgName

Write-Host "Creating new resources for VM $vmName" -ForegroundColor Green

# Create a new public IP address
$pip = New-AzureRmPublicIpAddress -Name $ipName `
                                -ResourceGroupName $rgName `
                                -Location $location `
                                -AllocationMethod Dynamic `
                                -DomainNameLabel $dnsName  

# Create a new network interface in the Apps subnet .Subnets[0]
$nic = New-AzureRmNetworkInterface -Name $nicName `
                                 -ResourceGroupName $rgName `
                                 -Location $location `
                                 -SubnetId $vnet.Subnets[0].Id `
                                 -PublicIpAddressId $pip.Id `
                                 -NetworkSecurityGroupId $nsg.ID 

# Create a new virtual machine configuration object
$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize `
                          -AvailabilitySetId $avSet.Id

# Associate the network interface with the VM 
Add-AzureRmVMNetworkInterface -Id $nic.Id -VM $vm


# Set the OS credentials
Set-AzureRmVMOperatingSystem -Windows `
                             -ComputerName $vmName `
                             -Credential $cred `
                             -ProvisionVMAgent `
                             -VM $vm

# Set the source image 
Set-AzureRmVMSourceImage -PublisherName $pubName `
                         -Offer $offerName `
                         -Skus $skuName `
                         -Version "latest" `
                         -VM $vm

# Set the OS disk location 
$osDiskName = "vm2-osdisk"
$osDiskUri    = $blobEndpoint + "vhds/" + $osDiskName  + ".vhd"

# Set the OS disk on the virtual machine configuration
Set-AzureRmVMOSDisk -Name $osDiskName `
                    -VhdUri $osDiskUri `
                    -CreateOption fromImage `
                    -VM $vm

Write-Host "Creating virtual machine $vmName" -ForegroundColor Green

# Create the virtual machine 
New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vm

# SQLVM-1 specific variables 
$pubName    = "MicrosoftSQLServer"
$offerName  = "SQL2014SP2-WS2012R2"
$skuName    = "Web"
$nicName    = "sqlVMNIC1"
$vmName     = "SQLVM-1"
$vmSize     = "Standard_D1_V2"


Write-Host "Creating new resources for VM $vmName" -ForegroundColor Green

# Create a new network interface in the Data subnet .Subnets[1].Id
$nic = New-AzureRmNetworkInterface -Name $nicName `
                                 -ResourceGroupName $rgName `
                                 -Location $location `
                                 -SubnetId $vnet.Subnets[1].Id 

# Create a new virtual machine configuration object
$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize 

# Associate the network interface with the VM 
Add-AzureRmVMNetworkInterface -Id $nic.Id -VM $vm

# Create the URI for data disk 1
$dataDiskName = "sqlvm1-datadisk1" 
$dataDiskUri = $blobEndpoint + "vhds/" + $dataDiskName  + ".vhd"

# Attach data disk 1 to the VM configuration
Add-AzureRmVMDataDisk -Name $dataDiskName `
                      -VhdUri $dataDiskUri -Caching None `
                      -DiskSizeInGB 1023 -Lun 0 -CreateOption empty `
                      -VM $vm

# Create the URI for data disk 2
$dataDiskName = "sqlvm1-datadisk2" 
$dataDiskUri = $blobEndpoint + "vhds/" + $dataDiskName  + ".vhd"

# Attach data disk 2 to the VM configuration 
Add-AzureRmVMDataDisk -Name $dataDiskName `
                      -VhdUri $dataDiskUri -Caching None `
                      -DiskSizeInGB 1023 -Lun 1 -CreateOption empty `
                      -VM $vm


# Set the local administrative credentials 
Set-AzureRmVMOperatingSystem -Windows `
                             -ComputerName $vmName `
                             -Credential $cred `
                             -ProvisionVMAgent  `
                             -VM $vm

# Set the source image 
Set-AzureRmVMSourceImage -PublisherName $pubName `
                         -Offer $offerName `
                         -Skus $skuName `
                         -Version "latest" `
                         -VM $vm

# Create the URI to the OS disk of the SLQ server
$osDiskName = "sqlvm1-osdisk0"
$osDiskUri    = $blobEndpoint + "vhds/" + $osDiskName  + ".vhd"

# Set the OS disk on the VM configuration object
Set-AzureRmVMOSDisk -Name $osDiskName `
                    -VhdUri $osDiskUri `
                    -CreateOption fromImage `
                    -VM $vm

Write-Host "Creating virtual machine $vmName" -ForegroundColor Green


# Create the VM 
New-AzureRmVM -ResourceGroupName $rgName `
                -Location $location `
                -VM $vm


