Get-Module PSConfigReader | Remove-Module -Force
Import-Module $PSScriptRoot\PSConfigReader.psm1 -Force

Describe "New-EnvironmentConfig" {

function Assert-HashtableEqual
{
    param(
        [Hashtable]$First,
        [Hashtable]$Second
    )

    $First.Keys.Count | Should Be $Second.Keys.Count
    [String]::Compare(($First.Keys | sort | ConvertTo-Json),
                ($Second.Keys | sort | ConvertTo-Json),$true) | Should Be 0

    foreach($key in $First.Keys){
        if(($First.$key).GetType().FullName -eq 'System.Collections.Hashtable'){
            Assert-HashtableEqual -First $First.$key -Second $Second.$key
        }else{
            $First.$key | Should BeExactly $Second.$key
        }
    }
}

[XML]$environmentConfig = @"
<Environments>
    <Environment Name="DEV">
        <Claims>.\TestFile.txt</Claims>
        <TestArray>
            <array>1</array>
            <array>2</array>
            <array>3</array>
            <array>4</array>
            <array>5</array>
            <array>6</array>
            <array>7</array>
        </TestArray>
        <TestHash>
            <hash key='First' value='1' />
            <hash key='Second' value='2' />
            <hash key='Third' value='3' />
            <hash key='Fourth' value='4' />
        </TestHash>
    </Environment>
    <Environment Name="TEST">
    </Environment>
    <Environment Name="PROD">
    </Environment>
</Environments>
"@

    Context "When processing 'DEV' node"{
        $expectedResult = @{
            Claims = '.\TestFile.txt'
            TestArray = @('1','2','3','4','5','6','7')
            TestHash = @{
                First = '1'
                Second = '2'
                Third = '3'
                Fourth = '4'
            }
        }

        $config = New-EnvironmentConfig -ConfigXML $environmentConfig -Environment Dev
        It "Should return a Hashtable" {
            $config | Should BeOfType Hashtable
        }
        
        It "Should have the expected set of keys" {
            $config.Keys.Count | Should Be $expectedResult.Keys.Count
            [String]::Compare(($config.Keys | ConvertTo-Json),
                ($expectedResult.Keys | ConvertTo-Json),$true) | Should Be 0
        }

        It "Should match the expected result" {
            Assert-HashtableEqual -First $config -Second $expectedResult
        }
    }

}