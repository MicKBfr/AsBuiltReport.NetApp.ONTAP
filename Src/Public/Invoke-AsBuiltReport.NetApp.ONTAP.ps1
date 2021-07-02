function Invoke-AsBuiltReport.NetApp.ONTAP {
    <#
    .SYNOPSIS
        PowerShell script to document the configuration of NetApp ONTAP in Word/HTML/Text formats
    .DESCRIPTION
        Documents the configuration of NetApp ONTAP in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        0.1.0
        Author:         Jonathan Colon Feliciano
        Twitter:
        Github:
        Credits:        Iain Brighton (@iainbrighton) - PScribo module

    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.NetApp.ONTAP
    #>

	# Do not remove or add to these parameters
    param (
        [String[]] $Target,
        [PSCredential] $Credential
    )

    # Check if the required version of Modules are installed
    Get-AbrOntapRequiredModule

    # Import Report Configuration
    $Report = $ReportConfig.Report
    $InfoLevel = $ReportConfig.InfoLevel
    $Options = $ReportConfig.Options

    # General information
    $TextInfo = (Get-Culture).TextInfo

    #Connect to Ontap Storage Array using supplied credentials
    foreach ($OntapArray in $Target) {
        Try {
            Write-PScriboMessage "Connecting to NetApp Storage '$OntapArray'."
            $Array = Connect-NcController -Name $OntapArray -Credential $Credential -ErrorAction Stop
        } Catch {
            Write-Verbose "Unable to connect to the $OntapArray Array"
            throw
        }

        #region VxRail Section
        Section -Style Heading1 "Report for Cluster $($ClusterInfo.ClusterName)" {
            Paragraph "The following section provides a summary of the array configuration for $($ClusterInfo.ClusterName)."
            BlankLine
            #region Cluster Section
            Write-PScriboMessage "Cluster InfoLevel set at $($InfoLevel.Cluster)."
            if ($InfoLevel.Cluster -gt 0) {
                Section -Style Heading2 'Cluster Information' {
                    # Ontap Cluster
                    Get-AbrOntapCluster
                    Section -Style Heading3 'Cluster HA Status' {
                        Paragraph "The following section provides a summary of the Cluster HA Status on $($ClusterInfo.ClusterName)."
                        BlankLine
                        Get-AbrOntapClusterHA
                    }
                    Section -Style Heading3 'Cluster Auto Support Status' {
                        Paragraph "The following section provides a summary of the Cluster AutoSupport Status on $($ClusterInfo.ClusterName)."
                        BlankLine
                        Get-AbrOntapClusterASUP
                    }
                }
            }
        }#endregion Cluster Section
            #region Node Section
            Write-PScriboMessage "Node InfoLevel set at $($InfoLevel.Node)."
            if ($InfoLevel.Node -gt 0) {
            Section -Style Heading2 'Node Summary' {
            Paragraph "The following section provides a summary of the Node on $($ClusterInfo.ClusterName)."
            BlankLine
                Section -Style Heading3 'Node Inventory' {
                    Paragraph "The following section provides the node inventory on $($ClusterInfo.ClusterName)."
                    BlankLine
                    Get-AbrOntapNodes
                    Section -Style Heading4 'Node Hardware Inventory' {
                        Paragraph "The following section provides the node hardware inventory on $($ClusterInfo.ClusterName)."
                        BlankLine
                        Get-AbrOntapNodesHW
                    }
                    Section -Style Heading4 'Node Service-Processor Inventory' {
                        Paragraph "The following section provides the node service-processor information on $($ClusterInfo.ClusterName)."
                        BlankLine
                        Get-AbrOntapNodesSP
                    }
                }
            }
        }#endregion Node Section
    }
}
