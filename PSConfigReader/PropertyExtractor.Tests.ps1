Get-Module PSConfigReader | Remove-Module -Force
Import-Module $PSScriptRoot\PSConfigReader.psm1 -Force

InModuleScope PSConfigReader {

Describe "Property Extraction" {

BeforeEach {
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
            $First[$i] | Should BeExactly $Second[$i]
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
        <SingleArray>
            <array>{Write-Output "Test string"}</array>
        </SingleArray>
        <HashtableArray>
            <Hashtable>
                <hash key='First' value='1' />
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
        <SingleKeyValuePair>
            <hash key='First' value='1' />
        </SingleKeyValuePair>
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
    $devConfig = Get-EnvironmentNode -Config $environmentConfig -Environment 'Dev'
    $prodConfig = Get-EnvironmentNode -Config $environmentConfig -Environment 'Prod'
}

    Context "When parsing the environment config with Get-Environment" {
        It "Should return System.Xml.XmlElement for the dev node" {                
            $devConfig | Should BeOfType 'System.Xml.XmlElement'
        }
    }

    Context "When parsing the 'DEV' environment config node for properties, Get-StringProperties" {
        BeforeEach {
            $result = Get-StringProperties -Config $devConfig -ExcludedProperty Name
        }

        It "Should return an array" {
            $result | Should BeOfType 'System.Object'
        }

        It "Should return an array with 1 element for the String node" {
            Assert-ArrayEqual -First $result -Second @('Claims')
        }
    }

    Context "When parsing the 'PROD' environment config node for properties, Get-StringProperties" {
        BeforeEach {
            $result = Get-StringProperties -Config $prodConfig -ExcludedProperty 'Name'
            $resultWithoutExclude = Get-StringProperties -Config $prodConfig
        }

        It "Should return an array" {
            $result | Should BeOfType 'System.Object'
        }

        It "Should return an array with 3 elements for the String node" {
            Assert-ArrayEqual -First $result -Second @('Force','Process','ScriptBlock')
        }

        It "Should return an array with 4 elements without ExcludeProperty" {
            Assert-ArrayEqual -First $resultWithoutExclude -Second @('Force','Name','Process','ScriptBlock')
        }
    }

    Context "When parsing the environment config node for properties, Get-ArrayProperties" {
        BeforeEach {
            $result = Get-ArrayProperties -Config $devConfig 
            $expectedResult = @('HashtableArray','SingleArray','TestArray','TestArray2')
        }

        It "Should return a System.Xml.XmlElement" {
            $result | Should BeOfType 'System.Xml.XmlElement'
        }

        It "Should have 4 keys for matching the array nodes" {
            $resultingNodes = @()
            foreach($r in $result){
                $resultingNodes += $r.Name
            }
            $resultingNodes = $resultingNodes | sort
            Assert-ArrayEqual -First $resultingNodes -Second $expectedResult
        }
    }

    Context "When parsing the environment config node for properties, Get-HashProperties" {
        BeforeEach {
            $result = Get-HashProperties -Config $devConfig 
            $expectedResult =  @('SingleKeyValuePair','TestHash')
        }

        It "Should return a System.Xml.XmlElement" {
            $result | Should BeOfType 'System.Xml.XmlElement'
        }

        It "Should have 2 keys for the Hashtable node" {
            $resultingNodes = @()
            foreach($r in $result){
                $resultingNodes += $r.Name
            }
            $resultingNodes = $resultingNodes | sort
            Assert-ArrayEqual -First $resultingNodes -Second $expectedResult
        }
    }
}
}