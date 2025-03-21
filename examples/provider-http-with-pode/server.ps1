function New-RandomPassword {
  param (
      [int]$Length = 12
  )

  $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+'
  -join ((1..$Length) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
}



Start-PodeServer {
  Add-PodeEndpoint -Address * -Port 8080 -Protocol Http
  
  New-PodeLoggingMethod -Terminal | Enable-PodeRequestLogging

  New-PodeAuthScheme -Bearer | Add-PodeAuth -Name 'Authenticate' -Sessionless -ScriptBlock {
    param($token)

    if ($token -eq 'dcbcb128-1c7a-4de4-b8c2-612566325d10') {
        return @{ User = "admin" }
    }
    return $null
  }

  # disposablerequest: NOTIFY
  Add-PodeRoute -Method POST -Path '/notify' -Authentication 'Authenticate' -ScriptBlock {
    $obj = [pscustomobject]@{
      status    = "sent"
      notification = "hello $($WebEvent.Data.userId)"
    }

    $obj | ConvertTo-Json | Write-PodeJsonResponse
  }


  # request: CREATE
  Add-PodeRoute -Method POST -Path '/databases' -Authentication 'Authenticate' -ScriptBlock {
    $id = Get-Random -Maximum 999999
    $obj = [pscustomobject]@{
      id        = $id
      dbname    = $WebEvent.Data.dbname
      collation = $WebEvent.Data.collation
      user      = $WebEvent.Data.user
      password  = New-RandomPassword -Length 12
    }
    $json = $obj | ConvertTo-Json
    $json | Out-File -FilePath "$($id).json"
    start-sleep -Seconds 2
    $json | Write-PodeJsonResponse
  }


  # request: OBSERVE
  Add-PodeRoute -Method GET -Path '/databases/:id' -Authentication 'Authenticate' -ScriptBlock {
    $id = $WebEvent.Parameters['id']
    if (Test-Path "$($id).json"){
      Write-PodeJsonResponse -Path "$($id).json"
    }else{
      Write-PodeJsonResponse -StatusCode 404 -Value @{ error = "User not found" }
    }
  }

  # request: UPDATE
  Add-PodeRoute -Method PUT -Path '/databases/:id' -Authentication 'Authenticate' -ScriptBlock {
    $id = $WebEvent.Parameters['id']
    if (Test-Path "$($id).json"){
      $obj = get-content "$($id).json" -raw | ConvertFrom-Json
      $obj.collation = $WebEvent.Data.collation
      $obj.user = $WebEvent.Data.user
      $json = $obj | ConvertTo-Json
      $json | Out-File -FilePath "$($id).json"
      $json | Write-PodeJsonResponse
    }else{
      Write-PodeJsonResponse -StatusCode 404 -Value @{ error = "DB not found" }
    }
  }

  # request: REMOVE
  Add-PodeRoute -Method DELETE -Path '/databases/:id' -Authentication 'Authenticate' -ScriptBlock {
    $id = $WebEvent.Parameters['id']
    if (Test-Path "$($id).json"){
      Remove-Item -Path "$($id).json"
      Write-PodeJsonResponse -Value @{ status = "deleted" }
    }else{
      Write-PodeJsonResponse -StatusCode 404 -Value @{ error = "DB not found" }
    }
  }
}