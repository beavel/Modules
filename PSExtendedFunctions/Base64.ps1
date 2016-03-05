function ConvertTo-Base64{
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]$String
    )
    $bytes  = [System.Text.Encoding]::UTF8.GetBytes($string);
    $encoded = [System.Convert]::ToBase64String($bytes); 

    return $encoded;
}

function ConvertFrom-Base64{
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]$String
    )
    $bytes  = [System.Convert]::FromBase64String($string);
    $decoded = [System.Text.Encoding]::UTF8.GetString($bytes); 

    return $decoded;
}

Export-ModuleMember -Function @(
    'ConvertTo-Base64'
    ,'ConvertFrom-Base64'
) 