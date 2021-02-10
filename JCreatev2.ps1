Function Jira
{    
    
    [CmdletBinding()]
    Param
        (
            #Param1 help description
            [Parameter(Mandatory=$true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
            [String]$jobid,

            #Param2
            [Parameter(Mandatory=$true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
            [String]$jobname,

            #Param3
            [Parameter(Mandatory=$true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
            [String]$Agent
        )

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host "Job ID: $jobid || Job Name: $jobname"


#$jobid = 123123.03   #Testing
[int]$ticketcheck = $jobid.Substring($jobid.IndexOf('.') + 1, $jobid.Length - $jobid.IndexOf('.') -1)
$Aborted = ($ticketcheck + 1)
[int]$tid = $jobid.Substring(0,$jobid.IndexOf('.')) 

Write-Host "Ticketcheck: $ticketcheck"

Switch ( $Agent ) 
{
    #AWPRDO
    #{
     #   $AttachmentPath = "\\BatchProdM01.cu.nwcu.com\d$\Appworx\AWPROD\out\o$jobid"
    #}
    #OSIPROD1
    #{
    #    $AttachmentPath = "\\batchproda01.cu.nwcu.com\d$\Appworx\AWPROD\out\o$jobid"
    #}
    #OSIPROD2
    #{
     #   $AttachmentPath = "\\batchproda02.cu.nwcu.com\d$\Appworx\AWPROD\out\o$jobid"
    #}
    AWTEST
    {
        $AttachmentPath = "\\batchTestm01.cu.nwcu.com\D$\Appworx\AWTEST\out\o$jobid"
    }
}

If ($ticketcheck -eq 0)
{

Write-host "Ticket not yet Created $ticketcheck"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Basic SmlyYVNlcnZpY2VBY2NvdW50QG53Y3UuY29tOlQzcGlCRmFvRHBvdzU0MWlTTmpjOTZGOQ==")
$headers.Add("Content-Type", "application/json")
$headers.Add("Cookie", "atlassian.xsrf.token=BFYB-DXFF-ZTXR-H6MP_4bf520b6bdc85a6f21adbaab09f3eeab87a0e800_lin")

  
 $body = "{
`n    `"fields`":  {
`n                   `"summary`":  `"$jobname`",
`n                   `"project`":  {
`n                                   `"id`":  `"10446`"
`n                               },
`n                   `"issuetype`":  {
`n                                     `"id`":  `"10614`"
`n                                 },
`n                    `"customfield_11405`" : `"$jobname`", 
`n                    `"customfield_11404`" : `"$tid`",
`n                    `"description`": {
`n      `"type`": `"doc`",
`n      `"version`": 1,
`n      `"content`": [
`n        {
`n          `"type`": `"paragraph`",
`n          `"content`": [
`n                        {
`n                        `"text`": `"$jobname has aborted.`",
`n                        `"type`": `"text`"
`n                        }
`n                     ]
`n                }
`n            ]
`n        }
`n    }
`n}"

$response = Invoke-RestMethod 'https://nwcu.atlassian.net/rest/api/3/issue/' -Method 'POST' -Headers $headers -Body $body
$response | ConvertTo-Json

$jirakey = $response.key

$TicketURL = 'https://nwcu.atlassian.net/rest/api/latest/issue/' + $jirakey + '/attachments'


function Upload-JiraAttachment
{
    $wc = new-object System.Net.WebClient
    $wc.Headers.Add("X-Atlassian-Token", "no-check")
    $wc.Headers.Add("Authorization", "Basic SmlyYVNlcnZpY2VBY2NvdW50QG53Y3UuY29tOlQzcGlCRmFvRHBvdzU0MWlTTmpjOTZGOQ==")
    $wc.UploadFile($TicketURL, $AttachmentPath) > $null
}


$AttachmentResponse = Upload-JiraAttachment
$AttachmentResponse | ConvertTo-Json

$JiraID = $response.self.Substring($response.self.LastIndexOf('/') + 1,$response.self.Length - $response.self.LastIndexOf('/') - 1)
}
Else
{
    Write-host "Ticket already Created $ticketcheck"
    #$jobid = 2763287.02
    #$tid = $jobid.Substring(0,$jobid.IndexOf('.'))

 

$GETURL = 'https://nwcu.atlassian.net/rest/api/3/search?jql=project%20%3D%20apwx%20and%20"Run%20ID%5BShort%20text%5D"%20~%20"' + $tid + '"&fields=id'

Write-Host $GETURL

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Basic SmlyYVNlcnZpY2VBY2NvdW50QG53Y3UuY29tOlQzcGlCRmFvRHBvdzU0MWlTTmpjOTZGOQ==")
$headers.Add("Content-Type", "application/json")
$headers.Add("Cookie", "atlassian.xsrf.token=BFYB-DXFF-ZTXR-H6MP_4bf520b6bdc85a6f21adbaab09f3eeab87a0e800_lin")
 

$getResponse = Invoke-RestMethod $GETURL -Method 'GET' -Headers $headers 
$getResponse | ConvertTo-Json

 

 
$UpdateURL = ''
$UpdateURL = $getresponse.issues.self.ToString()
$UpdateURL = $UpdateURL+ '/comment'

 

 

$body = "{
`n  `"body`": {
`n    `"type`": `"doc`",
`n    `"version`": 1,
`n    `"content`": [
`n      {
`n        `"type`": `"paragraph`",
`n        `"content`": [
`n          {
`n            `"text`": `"$jobname has aborted $Aborted times.`",
`n            `"type`": `"text`"
`n          }
`n        ]
`n      }
`n    ]
`n  }
`n}"

 

$response = Invoke-RestMethod $UpdateURL -Method 'POST' -Headers $headers -Body $body
$response | ConvertTo-Json
}
}


Jira $args[0] $args[1] $args[2]