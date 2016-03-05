function Format-XML{
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [Xml]$Xml, 
        [Int]$indent=2
    )
    $StringWriter = New-Object System.IO.StringWriter
    $XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter
    $xmlWriter.Formatting = "indented"
    $xmlWriter.Indentation = $Indent
    $xml.WriteContentTo($XmlWriter)
    $XmlWriter.Flush()
    $StringWriter.Flush()
    Write-Output $StringWriter.ToString()
    <#
    .LINK
    http://blogs.msdn.com/b/powershell/archive/2008/01/18/format-xml.aspx    
    #>
}

Export-ModuleMember -Function @(
    'Format-Xml'
)