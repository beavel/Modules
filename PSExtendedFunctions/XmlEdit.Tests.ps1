Get-Module PSExtendedFunctions | Remove-Module -Force
Import-Module $PSScriptRoot\PSExtendedFunctions.psm1 -Force

Describe "Set-XmlConfigValue" {

[XML]$testXMLNamedElement = @"
<?xml version="1.0"?>
<configuration>
  <microsoft.identityServer.web>
    <localAuthenticationTypes>
      <add name="Forms" page="FormsSignIn.aspx" />
      <add name="Integrated" page="auth/integrated/" />
    </localAuthenticationTypes>
    <acceptedFederationProtocols saml="true" wsFederation="true" />
  </microsoft.identityServer.web>
</configuration>
"@

[XML]$expectedXMLNamedElement = @"
<?xml version="1.0"?>
<configuration>
  <microsoft.identityServer.web>
    <localAuthenticationTypes>
      <add name="Forms" page="FormsSignIn.aspx" />
      <add name="Integrated" page="auth/integrated/" />
    </localAuthenticationTypes>
    <acceptedFederationProtocols saml="true" wsFederation="true" />
    <useRelayStateForIdpInitiatedSignOn enabled="true" />
  </microsoft.identityServer.web>
</configuration>
"@

[XML]$expectedXMLNamedElementUpdated = @"
<?xml version="1.0"?>
<configuration>
  <microsoft.identityServer.web>
    <localAuthenticationTypes>
      <add name="Forms" page="FormsSignIn.aspx" />
      <add name="Integrated" page="auth/integrated/" />
    </localAuthenticationTypes>
    <acceptedFederationProtocols saml="true" wsFederation="true" />
    <useRelayStateForIdpInitiatedSignOn enabled="false" />
  </microsoft.identityServer.web>
</configuration>
"@

    Context "When inserting via a named element"{
        $params = @{
            XML = $testXMLNamedElement
            XPath = 'configuration/microsoft.identityServer.web/useRelayStateForIdpInitiatedSignOn'
            XmlNode = '<useRelayStateForIdpInitiatedSignOn enabled="true" />'  
        }

        [XML]$xmlResult = Set-XmlConfigValue @params
        It "Should return updated XML with new element" {
            $xmlResult.OuterXml | Should Be $expectedXMLNamedElement.OuterXml
        }
    }

    Context "When updating via a named element"{
        $params = @{
            XML = $expectedXMLNamedElement
            XPath = 'configuration/microsoft.identityServer.web'
            XmlNode = '<useRelayStateForIdpInitiatedSignOn enabled="false" />'  
        }

        [XML]$xmlResult = Set-XmlConfigValue @params
        It "Should return updated XML with attributes updated" {
            $xmlResult.OuterXml | Should Be $expectedXMLNamedElementUpdated.OuterXml
        }
    }

    Context "When removing via a named element"{
        $params = @{
            XML = $expectedXMLNamedElement
            XPath = 'configuration/microsoft.identityServer.web/useRelayStateForIdpInitiatedSignOn'
            XmlNode = '<useRelayStateForIdpInitiatedSignOn enabled="true" />'
            Operation = 'Remove'
        }
        [XML]$xmlResult = Set-XmlConfigValue @params
        It "Should return updated XML without XmlNode" {
            $xmlResult.OuterXml | Should Be $testXMLNamedElement.OuterXml
        }
    }

    Context "When there are no changes via a named element" {
        $params = @{
            XML = $expectedXMLNamedElement
            XPath = 'configuration/microsoft.identityServer.web'
            XmlNode = '<useRelayStateForIdpInitiatedSignOn enabled="true" />'  
        }

        [XML]$xmlResult = Set-XmlConfigValue @params
        It "Should return nothing" {
            $xmlResult | Should Be $null
        }
    }

    Context "When there are no removals via a named element" {
        $params = @{
            XML = $testXMLNamedElement
            XPath = 'configuration/microsoft.identityServer.web/useRelayStateForIdpInitiatedSignOn'
            XmlNode = '<useRelayStateForIdpInitiatedSignOn enabled="true" />'
            Operation = 'Remove'  
        }

        [XML]$xmlResult = Set-XmlConfigValue @params
        It "Should return nothing" {
            $xmlResult | Should Be $null
        }
    }

[XML]$originalXML = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<configuration>
  <appSettings>
    <add key="Key1" value="Value1" />
    <add key="Url" value="https://somewhere.com/site/" />
    <add key="Secret" value="123sadfoife" />
  </appSettings>
  <connectionStrings>
    <add name="ConnectionString1" connectionString="NotTheCorrectString" />
    <add name="ConnectionString2" connectionString="Data Source=Server1;Initial Catalog=Database ;Integrated Security=True;" providerName="System.Data.SqlClient" />
  </connectionStrings>
</configuration>
"@

[XML]$expectedXML = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<configuration>
  <appSettings>
    <add key="Key1" value="Value1" />
    <add key="Url" value="https://somewhere.com/site/" />
    <add key="Secret" value="123sadfoife" />
  </appSettings>
  <connectionStrings>
    <add name="ConnectionString1" connectionString="NotTheCorrectString" />
    <add name="ConnectionString2" connectionString="Data Source=Server2;Initial Catalog=Database2;Integrated Security = true" providerName="System.Data.SqlClient" />
  </connectionStrings>
</configuration>
"@

[XML]$expectedXMLInserted = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<configuration>
  <appSettings>
    <add key="Key1" value="Value1" />
    <add key="Url" value="https://somewhere.com/site/" />
    <add key="Secret" value="123sadfoife" />
  </appSettings>
  <connectionStrings>
    <add name="ConnectionString1" connectionString="NotTheCorrectString" />
    <add name="ConnectionString2" connectionString="Data Source=Server2;Initial Catalog=Database2;Integrated Security = true" providerName="System.Data.SqlClient" />
    <add name="ConnectionString3" connectionString="Data Source=Server3;Initial Catalog=Database3;Integrated Security = true" providerName="System.Data.SqlClient" />
  </connectionStrings>
</configuration>
"@

    Context "When updating via attribute 'name'"{
        $params = @{
            XML = $originalXML
            XPath = '/configuration/connectionStrings'
            XmlNode = '<add name="ConnectionString2" connectionString="Data Source=Server2;Initial Catalog=Database2;Integrated Security = true" providerName="System.Data.SqlClient" />'
        }

        [XML]$xmlResult = Set-XmlConfigValue @params
        It "Should return updated XML with new element" {
            $xmlResult.OuterXml | Should Be $expectedXML.OuterXml
        }
    }

    Context "When inserting via attribute 'name'"{
        $params = @{
            XML = $expectedXML
            XPath = '/configuration/connectionStrings/add[@name="ConnectionString3"]'
            XmlNode = '<add name="ConnectionString3" connectionString="Data Source=Server3;Initial Catalog=Database3;Integrated Security = true" providerName="System.Data.SqlClient" />'
        }

        [XML]$xmlResult = Set-XmlConfigValue @params
        It "Should return updated XML with new element" {
            $xmlResult.OuterXml | Should Be $expectedXMLInserted.OuterXml
        }
    }

    Context "When removing element via attribute 'name'"{
        $params = @{
            XML = $expectedXMLInserted
            XPath = '/configuration/connectionStrings/add[@name="ConnectionString3"]'
            XmlNode = '<add name="ConnectionString3" connectionString="Data Source=Server3;Initial Catalog=Database3;Integrated Security = true" providerName="System.Data.SqlClient" />'
            Operation = 'Remove'
        }

        [XML]$xmlResult = Set-XmlConfigValue @params
        It "Should return updated XML with element removed" {
            $xmlResult.OuterXml | Should Be $expectedXML.OuterXml
        }
    }
}

Describe "Get-XPathParentNode" {
    InModuleScope PSExtendedFunctions{
        Context "Straight node selection" {
            $result = Get-XPathParentNode -XPath 'configuration/microsoft.identityServer.web/useRelayStateForIdpInitiatedSignOn'
            It "Should return with last node removed" {
                $result | Should Be 'configuration/microsoft.identityServer.web'
            }
        }

        Context "Relative node selection" {
            $result = Get-XPathParentNode -XPath '/configuration/microsoft.identityServer.web//useRelayStateForIdpInitiatedSignOn'
            It "Should return with last node removed" {
                $result | Should Be '/configuration/microsoft.identityServer.web'
            }
        }

        Context "Node selection with attributes" {
            $result = Get-XPathParentNode -XPath '/configuration/connectionStrings/add[@name="ConnectionString2"]'
            It "Should return with last node removed" {
                $result | Should Be '/configuration/connectionStrings'
            }
        }
    }
}