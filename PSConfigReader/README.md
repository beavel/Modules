PSConfigReader Module
=====================
## Goals ##
- Create config file readable by someone not familiar with PowerShell syntax.
- Take on no external dependencies so it can be used on PS v2 and above.

## Intention ##
- Allows creation of XML files to fill in parameters for script execution. This allows for easy splatting of config values.
- Two types of configs
  - Environment
    - Allow for defining a different set of values per environment
    - Simplifies script call down to `.\Script.ps1 -Config .\PSConfig.xml -Environment QA` & easy tracking of configuration changes over time by making sure the `PSConfig.xml` is checked in.
    - **Case Sensitive**
      - Environment Nodes
      - Name Attribute
      - Environment Name needs to be upper case.
  - ParameterSets
    - Allows for multiple parameter sets to be run against a single script. Returns an array of Hashtables that should match 

## Examples ##

### Environment ###
```XML
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
        <Force>$false</Force>
        <ScriptBlock>{Write-Output 'Hello World'}</ScriptBlock>
    </Environment>
</Environments>
```

- `Claims` node becomes `Claims` key of type `String` in output hashtable with value `.\TestFile.txt`
- `testArray` node becomes `testArray` key of type `Array` with values from all of the `<array>` elements
- `testHash` noded comes `testHash` key of type `Hashtable` with keys and values as defined in the elements.
  - Attribute names of `key` and `value` are required

```PowerShell
# Dev Node
$params = @{
    Claims = '.\TestFile.txt'
    TestArray = @('1','2','3','4','5','6','7')
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
```