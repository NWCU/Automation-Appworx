<#

        .DESCRIPTION
            This Script integrates Appworx with Jira. It Creates and updates tickets based on the runid.

        .NOTES
            ScriptName   : Jira Integration
            Created by   : Appworx_Team
            Date Coded   : 

#>
##########################################################################################################################
# Script Requirements ####################################################################################################

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

##########################################################################################################################
# Application Variables ##################################################################################################
###### System Variables Needed for Script ################################################################################
#$Agent = (GI -Path Env:Agent).Value
#$comp = (GI -Path Env:Computername).Value
#$jobalias = (GI -Path Env:module).Value
#$job = (GI -Path Env:job).Value
#$runid = (GI -Path Env:run_id).Value
#$AttachmentPath = (GI -Path Env:stdout).Value

### For Testing ###
#$Agent = 
#$comp = 
$jobalias = 'Test'
$AttachmentPath = 'C:\Temp\Random_Log.txt'
$job = 'Test'
$runid = '1122.06'

##########################################################################################################################
# Script Variables #######################################################################################################
###### Required Variables ################################################################################################
[int]$ticketcheck = $runid.Substring($runid.IndexOf('.') + 1, $runid.Length - $runid.IndexOf('.') -1)
$Aborted = ($ticketcheck + 1)
[int]$tid = $runid.Substring(0,$runid.IndexOf('.'))


##########################################################################################################################
#JIRA Variables ##########################################################################################################
###### JSON Values: System ###############################################################################################
$Token = "Basic SmlyYVNlcnZpY2VBY2NvdW50QG53Y3UuY29tOlQzcGlCRmFvRHBvdzU0MWlTTmpjOTZGOQ=="
$Jira_Summary= '$runid || $jobalias'
$Jira_Project = '10446'
$JiraProjectKey = 'APWX'
$Jira_IssueType = '10614'
$Jira_Description = '$jobalias has aborted.'

###### JSON Values: Application Fields ###################################################################################
$Jira_CF_JobName = $Job
$Jira_CF_RunID = $tid

##########################################################################################################################
# Log Variables ##########################################################################################################
$LogFolder = 'C:\Temp\'
$LogName = "$TID-$Job.txt"

$LogLocation = $LogFolder + $LogName

##########################################################################################################################


If ($ticketcheck -eq 0)
{
Start-Transcript -Path $LogLocation
Write-Host '================================================================================================================'
Write-host "Ticket not yet Created $ticketcheck"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", $Token)
$headers.Add("Content-Type", "application/json")


  
 $body = "{
`n    `"fields`":  {
`n                   `"summary`":  `"$Jira_Summary`",
`n                   `"project`":  {
`n                                   `"id`":  `"$Jira_Project`"
`n                               },
`n                   `"issuetype`":  {
`n                                     `"id`":  `"$Jira_IssueType`"
`n                                 },
`n                    `"customfield_11405`" : `"$Jira_CF_JobName`", 
`n                    `"customfield_11404`" : `"$Jira_CF_RunID`",
`n                    `"description`": {
`n      `"type`": `"doc`",
`n      `"version`": 1,
`n      `"content`": [
`n        {
`n          `"type`": `"paragraph`",
`n          `"content`": [
`n                        {
`n                        `"text`": `"$Jira_Description`",
`n                        `"type`": `"text`"
`n                        }
`n                     ]
`n                }
`n            ]
`n        }
`n    }
`n}"

Write-host 'Submitting information to Jira'
Write-Host '================================================================================================================'
Write-Host 'Remote Jira Response:'
Write-host ''

$response = Invoke-RestMethod 'https://nwcu.atlassian.net/rest/api/3/issue/' -Method 'POST' -Headers $headers -Body $body
$response | ConvertTo-Json

Write-Host '================================================================================================================'

$jirakey = $response.key

$TicketURL = 'https://nwcu.atlassian.net/rest/api/latest/issue/' + $jirakey + '/attachments'

Write-Host "Ticket Creation Successful, Jira Key is $Jirakey"

sleep 2

function Upload-JiraAttachment
{
    $wc = new-object System.Net.WebClient
    $wc.Headers.Add("X-Atlassian-Token", "no-check")
    $wc.Headers.Add("Authorization", $Token)
    $wc.UploadFile($TicketURL, $AttachmentPath) > $null
}


$AttachmentResponse = Upload-JiraAttachment
$AttachmentResponse | ConvertTo-Json
}


Else
{

Start-Transcript -Path $LogLocation -Append
Write-Host '================================================================================================================'

$GETURL = 'https://nwcu.atlassian.net/rest/api/3/search?jql=project%20%3D%20'+ $JiraProjectKey +'%20and%20"Run%20ID%5BShort%20text%5D"%20~%20"' + $tid + '"&fields=id'

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", $Token)
$headers.Add("Content-Type", "application/json")

Write-host "Ticket already Created $ticketcheck" 
Write-Host 'Checking $GETURL to Receive Ticket Key'
Write-Host '================================================================================================================'
Write-Host 'Remote Jira Response:'
Write-host ''

$getResponse = Invoke-RestMethod $GETURL -Method 'GET' -Headers $headers 
$getResponse | ConvertTo-Json

Write-Host '================================================================================================================'

$UpdateURL = ''
$UpdateURL = $getresponse.issues.self.ToString()
$UpdateURL = $UpdateURL+ '/comment'

Write-host ''
write-host "URL for Updating Ticket is: $UpdateURL"
 
$body = "{
`n  `"body`": {
`n    `"type`": `"doc`",
`n    `"version`": 1,
`n    `"content`": [
`n      {
`n        `"type`": `"paragraph`",
`n        `"content`": [
`n          {
`n            `"text`": `"$Jira_Description`",
`n            `"type`": `"text`"
`n          }
`n        ]
`n      }
`n    ]
`n  }
`n}"
 
Write-Host '================================================================================================================'
Write-Host 'Remote Jira Response:'
$response = Invoke-RestMethod $UpdateURL -Method 'POST' -Headers $headers -Body $body
$response | ConvertTo-Json
}

Write-Host '================================================================================================================'
Stop-Transcript