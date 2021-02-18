<#

        .DESCRIPTION
            This Script integrates Appworx with Jira. It Resolves tickets based on the runid.

        .NOTES
            ScriptName   : Jira Integration
            Created by   : Appworx_Team
            Date Coded   : 

#>
# Prerequisites ===================================================================================================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# =================================================================================================================================================
# Passed Variables ================================================================================================================================

$Agent = (GI -Path Env:Agent).Value
$comp = (GI -Path Env:Computername).Value
$jobalias = (GI -Path Env:module).Value
$job = (GI -Path Env:job).Value
$runid = (GI -Path Env:run_id).Value
$AttachmentPath = (GI -Path Env:stdout).Value
     # Before the . is used as the $tid and reported into jira as the Run ID
     # Last two characters are used for $ticketcheck

# =================================================================================================================================================
# Variables Required ==============================================================================================================================

$AuthToken = "Basic SmlyYVNlcnZpY2VBY2NvdW50QG53Y3UuY29tOlQzcGlCRmFvRHBvdzU0MWlTTmpjOTZGOQ=="
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
[int]$tid = $runid.Substring(0,$runid.IndexOf('.'))

# =================================================================================================================================================
# Header Creation =================================================================================================================================

$headers.Add("Authorization", $AuthToken)
$headers.Add("Content-Type", "application/json")

# =================================================================================================================================================
##########################################################################################################################
# Log Variables ##########################################################################################################
$LogFolder = '\\Fileserver1\tsttccus\Logs\Jira-Appworx-Integration\'
$LogName = "$TID-$Jobalias.txt"

$LogLocation = $LogFolder + $LogName

##########################################################################################################################
# Body Creation ===================================================================================================================================

# Transition ID: ID of the transition in the workflow in which you want to traverse 
     #*note that if you are resolving a ticket, you must add the resolution field

$body = "{
`n `"update`": {},   
`n `"transition`": {
`n `"id`": `"71`"
`n },
`n `"fields`": {
`n `"resolution`": {
`n `"name`": `"Done`"
`n }
`n }
`n}"

# Ticket Check ====================================================================================================================================

[int]$tid = $runid.Substring(0,$runid.IndexOf('.')) 
[int]$ticketcheck = $runid.Substring($runid.IndexOf('.') + 1, $runid.Length - $runid.IndexOf('.') -1)

# =================================================================================================================================================

If ($ticketcheck -gt 0) 
{
write-host 'Running GET'

# GET Request for Ticket ID =======================================================================================================================

$GETURL = 'https://nwcu.atlassian.net/rest/api/3/search?jql=project%20%3D%20apwx%20and%20"Run%20ID%5BShort%20text%5D"%20~%20"' + $tid + '"&fields=id'
$getResponse = Invoke-RestMethod $GETURL -Method 'GET' -Headers $headers 
$getResponse | ConvertTo-Json

# =================================================================================================================================================
# Generation of UpdateURL =========================================================================================================================

$UpdateURL = ''
$UpdateURL = $getresponse.issues.self.ToString()
$UpdateURL = $UpdateURL+ '/transitions'

# =================================================================================================================================================
# POST Request for Resolution Transition ==========================================================================================================

$response = Invoke-RestMethod $UpdateURL -Method 'POST' -Headers $headers -Body $body
$response | ConvertTo-Json


Remove-Item -Path $LogLocation



}

else {
Write-Host 'Ticket does not exist'
}
