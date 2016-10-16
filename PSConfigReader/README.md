PSConfigReader Module
=====================

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
        <testArray>
            <array>1</array>
            <array>2</array>
            <array>3</array>
            <array>4</array>
            <array>5</array>
            <array>6</array>
            <array>7</array>
        </testArray>
        <testHash>
            <hash key='first' value='1' />
            <hash key='second' value='2' />
            <hash key='third' value='3' />
            <hash key='fourth' value='4' />
        </testHash>
    </Environment>
    <Environment Name="TEST">
    </Environment>
    <Environment Name="PROD">
    </Environment>
</Environments>
```

- `Claims` node becomes `Claims` key of type `String` in output hashtable with value `.\TestFile.txt`
- `testArray` node becomes `testArray` key of type `Array` with values from all of the `<array>` elements
- `testHash` noded comes `testHash` key of type `Hashtable` with keys and values as defined in the elements.
  - Attribute names of `key` and `value` are required