 <#
    .SYNOPSIS
        PowerShell script used to add EagerZeroedThick disk to the ontap simulator vm
    .DESCRIPTION
        This powershell script add 12 EagerZeroedThick disk with the multi-writer Advanced option. Also, its add and configure a SCSCI controller (VirtualLsiLogicSAS) with the BusSharingMode Virtual
    .NOTES
        Version:        0.1
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         https://github.com/rebelinux

    .LINK
        https://github.com/rebelinux/NetappCode
    #>

$VMs = @('cluster1-01')
$DCLUSTER = "SSD-HIGH-PERF"
foreach ($VM in $VMs) {
    $scsi = get-vm $VM | Get-ScsiController
    if (!$scsi){ 
        foreach($x in (0..11)) {
            if ($scsi.Name -notlike "SCSI controller 0"){ 
                Get-VM $VM | New-HardDisk -CapacityGB 30 -StorageFormat EagerZeroedThick | New-ScsiController -Type VirtualLsiLogicSAS -BusSharingMode Virtual
                $scsi = get-vm $VM | Get-ScsiController
                }
            else {
                Write-Host "Scsi Adapter Found in VM adding disks number $($x)"
                Get-VM $VM | New-HardDisk -CapacityGB 30 -StorageFormat EagerZeroedThick -Controller "SCSI controller 0" -Datastore $DCLUSTER
                new-advancedsetting -entity $VM -name "scsi0:$X.sharing" -value "multi-writer" -confirm:$false -Force
                new-advancedsetting -entity $VM -name "scsi0:$X.virtualSSD" -value 1 -confirm:$false -Force
                new-advancedsetting -entity $VM -name "scsi0:$X.ctkEnabled" -value "false" -confirm:$false -Force
            }
        }
    }
}

