function Get-ReplayIDs {
    param([String]$APIKey, [Hashtable]$Parameters)
    $URIParameterString = ConvertTo-URIParameterString -Parameters $Parameters
    $Response =
        cURL "https://ballchasing.com/api/replays$URIParameterString" `
        -H "Authorization: $APIKey" | ConvertFrom-Json
    $Replays = $Response.list | ForEach-Object {return $_.id}
    $NextURL = $Response.next
    if ($null -ne $NextURL) {
        $Replays += Get-NextReplayIDs -APIKey $APIKey -Next $NextURL
    }
    return $Replays
}

function Get-MyReplayIDs {
    param([String]$APIKey)
    $Response =
        cURL "https://ballchasing.com/api/replays?uploader=me&count=200" `
        -H "Authorization: $APIKey" | ConvertFrom-Json
    $Replays = $Response.list | ForEach-Object {return $_.id}
    $NextURL = $Response.next
    if ($null -ne $NextURL) {
        $Replays += Get-NextReplayIDs -APIKey $APIKey -Next $NextURL
    }
    return $Replays
}

function Get-NextReplayIDs {
    param([String]$APIKey, [String]$URL)
    $Response = cURL $URL -H "Authorization: $APIKey" | ConvertFrom-Json
    $Replays = $Response.list | ForEach-Object {return $_.id}
    $NextURL = $Response.next
    if ($null -ne $NextURL) {
        $Replays += Get-NextReplayIDs -APIKey $APIKey -Next $Next
    }
    return $Replays
}

function Get-ReplayContentByID {
    param([String]$ReplayID, [String]$OutputPath)
    cURL -X POST "https://ballchasing.com/dl/$ReplayID" --output "$OutputPath\$ReplayID.replay"
}

filter Get-ReplayContentsByID {
    param([String]$OutputPath)
    Get-ReplayContentByID -ReplayID $_ -OutputPath $OutputPath
}

function ConvertTo-URIParameterString {
    param([Hashtable]$Parameters)
    $Keys = $Parameters.Keys
    $Result = $Keys | ForEach-Object {"$_=" + $Parameters.Item($_)}
    $Result = "?" + ($Result -join "&")
    return $Result
}
