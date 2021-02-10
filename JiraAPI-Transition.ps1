
# Passed Variables ================================================================================================================================

#$runid = (GI -Path Env:run_id).Value
$runid = '2274119.01' #Last two characters are used for $ticketcheck

# =================================================================================================================================================
# Variables Required ==============================================================================================================================

$AuthToken = "Basic SmlyYVNlcnZpY2VBY2NvdW50QG53Y3UuY29tOlQzcGlCRmFvRHBvdzU0MWlTTmpjOTZGOQ=="
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"

# =================================================================================================================================================
# Header Creation =================================================================================================================================

$headers.Add("Authorization", $AuthToken)
$headers.Add("Content-Type", "application/json")

# =================================================================================================================================================
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

}

else {
Write-Host 'Ticket does not exist'
}
