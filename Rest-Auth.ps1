
$TenantID = '8b19ff35-468a-47f2-8d1a-d8b0392309cb'
$ClientID= '25dc0583-b5ca-456e-8288-a8fd6a72bb4b'
$SecretID = 'uGwH1lH10.jY_Ef-R_4~4.H36~HAbiq2.E'

$RestURI = 'https://login.microsoftonline.com/8b19ff35-468a-47f2-8d1a-d8b0392309cb/oauth2/v2.0/token'
$body = "client_id=$ClientID&client_secret=$SecretID&scope=https://graph.microsoft.com/.default&grant_type=client_credentials"
$RestMethod = 'POST' 
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.add('Content-Type','application/x-www-form-urlencoded')




$response = Invoke-RestMethod $RestURI  -Method $RestMethod -Headers $headers -ContentType $RestContentType -Body $body
$response | ConvertTo-Json

$token = $response.access_token
$headers.add('Authorization', 'Bearer $token')



$QuertyResponse = Invoke-RestMethod "https://graph.microsoft.com/v1.0/users/279e1da5-b6df-4f23-9df8-1e6afc644f29"  -Method "GET" -Headers $headers 
$QueryResponse | ConvertTo-Json
