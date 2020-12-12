Get-Module PSConfigReader | Remove-Module -Force
Import-Module $PSScriptRoot\PSConfigReader.psm1 -Force

InModuleScope PSConfigReader {

    Describe "XmlElement Conversion to Type" {
        
        Context "When converting to Array" {
            BeforeEach{
            [XML]$config = @"
<Environment Name="DEV">
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
    <BadArray>
        <prop1>1</prop1>
        <prop2>2</prop2>
    </BadArray>
    <EmptyArray>
    </EmptyArray>
</Environment>
"@
            }

            It "Should convert the XmlElement to a System.Object[]" {
                $element = $config.SelectSingleNode('//TestArray')
                $result = Get-ArrayFromXmlElement -XmlElement $element

                $result | Should BeOfType System.Object
            }

            It "Should convert the XmlElement to a System.Object[] - Single" {
                $element = $config.SelectSingleNode('//SingleArray')
                $result = Get-ArrayFromXmlElement -XmlElement $element

                $result | Should BeOfType System.Object
            }

            It "Should throw an error if elements do not match" {
                $element = $config.SelectSingleNode('//BadArray')
                { Get-ArrayFromXmlElement -XmlElement $element } | Should Throw
            }

            It "Should throw an error if no inner elements" {
                $element = $config.SelectSingleNode('//EmptyArray')
                { Get-ArrayFromXmlElement -XmlElement $element } | Should Throw
            }
        }

        Context "When converting to Hashtable" {
            BeforeEach{
            [XML]$config = @"
<Environment Name="DEV">
    <TestHash>
        <hash key='First' value='1' />
        <hash key='Second' value='2' />
        <hash key='Third' value='3' />
        <hash key='Fourth' value='4' />
    </TestHash>
    <SingleKeyValuePair>
        <hash key='First' value='1' />
    </SingleKeyValuePair>
    <BadHash>
        <random key='First' value='1' />
        <notradom key='Second' value='2' />
    </BadHash>
    <duplicateKeys>
        <hash key='First' value='1' />
        <hash key='First' value='2' />
    </duplicateKeys>
    <noKeyAttribute>
        <hash notkey='First' value='1' />
    </noKeyAttribute>
    <noValueAttribute>
        <hash key='Second' notvalue='2' />
    </noValueAttribute>
    <EmptyHash>
    </EmptyHash>
</Environment>
"@
            }
            It "Should convert the XmlElement to a Hashtable - Single" {
                $element = $config.SelectSingleNode('//SingleKeyValuePair')
                $result = Get-HashtableFromXmlElement -XmlElement $element

                $result | Should BeOfType Hashtable
            }

            It "Should convert the XmlElement to a Hashtable - Multiple" {
                $element = $config.SelectSingleNode('//TestHash')
                $result = Get-HashtableFromXmlElement -XmlElement $element

                $result | Should BeOfType Hashtable
            }

            It "Should throw an error if keys are duplicated" {
                $element = $config.SelectSingleNode('//duplicateKeys')
                { Get-HashtableFromXmlElement -XmlElement $element } | Should Throw
            }

            It "Should throw an error if elements don't match" {
                $element = $config.SelectSingleNode('//BadHash')
                { Get-HashtableFromXmlElement -XmlElement $element } | Should Throw
            }

            It "Should throw an error if key is not present" {
                $element = $config.SelectSingleNode('//noKeyAttribute')

                { Get-HashtableFromXmlElement -XmlElement $element } | 
                    Should Throw "Missing 'key' or 'value' attribute on element"
            }

            It "Should throw an error if value is not present" {
                $element = $config.SelectSingleNode('//noValueAttribute')

                { Get-HashtableFromXmlElement -XmlElement $element } | 
                    Should Throw "Missing 'key' or 'value' attribute on element"
            }

            It "Should throw an error if element has no child elements" {
                $element = $config.SelectSingleNode('//EmptyHash')
                { Get-HashtableFromXmlElement -XmlElement $element } | Should Throw
            }
        }
    }
}