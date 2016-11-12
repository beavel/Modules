Get-Module PSConfigReader | Remove-Module -Force
Import-Module $PSScriptRoot\PSConfigReader.psm1 -Force

Describe "New-EnvironmentConfig" {

function Assert-HashtableEqual
{
    param(
        [ValidateNotNullOrEmpty()]
        [Hashtable]$First,

        [ValidateNotNullOrEmpty()]
        [Hashtable]$Second
    )

    $First.Keys.Count | Should Be $Second.Keys.Count
    [String]::Compare(($First.Keys | sort | ConvertTo-Json),
                ($Second.Keys | sort | ConvertTo-Json),$true) | Should Be 0

    foreach($key in $First.Keys){
        if(($First.$key).GetType().FullName -eq 'System.Collections.Hashtable')
        {
            Assert-HashtableEqual -First $First.$key -Second $Second.$key
        }
        elseif(($First.$key).GetType().FullName -eq 'System.Object[]')
        {
            Assert-ArrayEqual -First $First.$key -Second $Second.$key
        }
        else
        {
            $First.$key | Should BeExactly $Second.$key
        }
    }
}

function Assert-ArrayEqual
{
    param(
        [ValidateNotNullOrEmpty()]
        [Array]$First,

        [ValidateNotNullOrEmpty()]
        [Array]$Second
    )

    $First.Count | Should Be $Second.Count

    for($i=0;$i -lt $First.Count;$i++)
    {
        if($First[$i].GetType().FullName -eq 'System.Collections.Hashtable')
        {
            Assert-HashtableEqual -First $First[$i] -Second $Second[$i]
        }
        else
        {
            $First[$i] | Should BeExactly $Second[$i]
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
        <TestArray2>
            <array>One</array>
            <array>Two</array>
        </TestArray2>
        <HashtableArray>
            <Hashtable>
                <hash key='First' value='true' />
                <hash key='Second' value='2' />
            </Hashtable>
            <Hashtable>
                <hash key='First' value='1' />
                <hash key='Second' value='2' />
            </Hashtable>
        </HashtableArray>
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
        <Process>true</Process>
        <Force>`$false</Force>
        <ScriptBlock>{Write-Output 'Hello World'}</ScriptBlock>
    </Environment>
</Environments>
"@

# Reused variables #
$devHashtable = New-EnvironmentConfig -ConfigXML $environmentConfig -Environment Dev

    Context "When processing 'DEV' node"{
        $expectedResult = @{
            Claims = '.\TestFile.txt'
            TestArray  = @('1','2','3','4','5','6','7')
            TestArray2 = @('One','Two')
            HashtableArray = @(
                @{
                    First = $true
                    Second = '2'
                }
                ,@{
                    First = '1'
                    Second = '2'
                }
            )
            TestHash = @{
                First = '1'
                Second = '2'
                Third = '3'
                Fourth = '4'
            }
        }

        It "Should return a Hashtable" {
            $devHashtable | Should BeOfType Hashtable
        }
        
        It "Should have the expected set of keys" {
            $devHashtable.Keys.Count | Should Be $expectedResult.Keys.Count
            [String]::Compare(($devHashtable.Keys | sort | ConvertTo-Json),
                ($expectedResult.Keys | sort | ConvertTo-Json),$true) | Should Be 0
        }

        It "Should match the expected result" {
            Assert-HashtableEqual -First $devHashtable -Second $expectedResult
        }
    }

    Context "When processing the empty 'TEST' node"{
        $expectedResult = @{}
        $config = New-EnvironmentConfig -ConfigXML $environmentConfig -Environment Test

        It "Should return a Hashtable" {
            $config | Should BeOfType Hashtable
        }
    }

    Context "When processing the 'PROD' node"{
        $config = New-EnvironmentConfig -ConfigXML $environmentConfig -Environment PROD

        It "Should convert 'Process' bool without '$' to a boolean"{
            $config['Process'] | Should BeOfType Boolean
        }

        It "Should make the 'Process' boolean `$true" {
            $config['Process'] | Should BeExactly $true
        }

        It "Should convert 'Force' bool with '$' to a boolean"{
            $config['Process'] | Should BeOfType Boolean
        }

        It "Should make the 'Force' boolean `$false" {
            $config['Process'] | Should BeExactly $true
        }

        It "Should convert the 'ScriptBlock' element to a ScriptBlock" {
            $config['ScriptBlock'] | Should BeOfType ScriptBlock
        }
    }
}