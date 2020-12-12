Get-Module PSConfigReader | Remove-Module -Force
Import-Module $PSScriptRoot\PSConfigReader.psm1 -Force

InModuleScope PSConfigReader{

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

    Describe "Parseing Config XML for properties" {
        BeforeEach{
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
        <HashtableArraySingle>
            <Hashtable>
                <hash key='First' value='1' />
                <hash key='Second' value='2' />
            </Hashtable>
        </HashtableArraySingle>
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
</Environments>
"@
            
            $xpath = "//Environment[@Name='DEV' and not(@Version)]"

            $config = $environmentConfig.SelectSingleNode($xpath)

        }
        Context "Test-IsArray" {
            It "Should match a single array element" {
                Test-IsArray -XmlElement $config.SelectSingleNode("SingleArray") | Should Be $true
            }

            It "Should match array element" {
                Test-IsArray -XmlElement $config.SelectSingleNode("TestArray") | Should Be $true
            }

            It "Should match an array of Hashtables" {
                Test-IsArray -XmlElement $config.SelectSingleNode("HashtableArray") | Should Be $true
            }

            It "Should match an array of a single Hashtable" {
                Test-IsArray -XmlElement $config.SelectSingleNode("HashtableArraySingle") | Should Be $true
            }

            It "Should not match on a Hashtable with a single key value pair" {
                Test-IsArray -XmlElement $config.SelectSingleNode("SingleKeyValuePair") | Should Be $false
            }
        }

        Context "Test-IsHashtable" {
            It "Should match a hashtable element" {
                Test-IsHashtable -XmlElement $config.SelectSingleNode("TestHash") | Should Be $true
            }

            It "Should match hashtable element with a single key value pair" {
                Test-IsHashtable -XmlElement $config.SelectSingleNode("SingleKeyValuePair") | Should Be $true
            }

            It "Should not match on an array of a single Hashtable" {
                Test-IsHashtable -XmlElement $config.SelectSingleNode("HashtableArraySingle") | Should Be $false
            }

            It "Should not match on an array of Hashtables" {
                Test-IsHashtable -XmlElement $config.SelectSingleNode("HashtableArray") | Should Be $false
            }
        }

        Context "Retrieving Array properties with Search-ConfigForPropertyType -Type Array"{
            BeforeEach{
                $result = Search-ConfigForPropertyType -Config $config -Type Array
                $expectedResult = @('HashtableArray','HashtableArraySingle','SingleArray','TestArray','TestArray2')
            }

            It "Should return an array of System.Xml.Element" {
                $result | Should BeOfType 'System.Xml.XmlElement'
            }

            It "Should have 5 keys for matching the array nodes" {
                $resultingNodes = @()
                foreach($r in $result){
                    $resultingNodes += $r.Name
                }
                $resultingNodes = $resultingNodes | sort
                Assert-ArrayEqual -First $resultingNodes -Second $expectedResult
            }
        }

        Context "Retrieving Array properties with Search-ConfigForPropertyType -Type Hashtable"{
            BeforeEach{
                $result = Search-ConfigForPropertyType -Config $config -Type Hashtable
                $expectedResult = @('SingleKeyValuePair','TestHash')
            }

            It "Should return an array of System.Xml.Element" {
                $result | Should BeOfType 'System.Xml.XmlElement'
            }

            It "Should have 2 keys for matching the hashtable nodes" {
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