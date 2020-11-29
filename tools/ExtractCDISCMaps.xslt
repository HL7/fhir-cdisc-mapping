<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="urn:schemas-microsoft-com:office:spreadsheet" xmlns:t="http://example.org" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40" exclude-result-prefixes="xs o x ss html t">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:variable name="normalizedExcel" as="element(Workbook)">
    <xsl:apply-templates mode="normalize" select="Workbook"/>
	</xsl:variable>
	<xsl:variable name="fakeCell" as="element(Cell)">
    <Cell xmlns="urn:schemas-microsoft-com:office:spreadsheet" fake="true"/>
	</xsl:variable>
  <xsl:variable name="columnNames" as="element()">
    <names>
      <name>Description</name>
      <name>FHIR Resource Name</name>
      <name>FHIR Attribute Name</name>
      <name>FHIR Path Origin</name>
      <name>FHIR Path Reference</name>
      <name>R4 vs R5</name>
      <name>Gap Mitigation</name>
      <name>Comments</name>
      <name>FHIR XML Path Reference</name>
      <name>LAB XML Xpath</name>
      <name>Mandatory in LAB?</name>
      <name>LAB IG Rules</name>
      <name>CDASH Variable</name>
      <name>CDASH Mapping Instructions &amp; Description</name>
      <name>SDTM Variable</name>
      <name>SDTM Mapping Instructions &amp; Description</name>
    </names>
  </xsl:variable>
	<xsl:template match="/">
<!--    <xsl:copy-of select="$normalizedExcel"/>-->
    <mappings>
      <xsl:apply-templates select="$normalizedExcel/Worksheet"/>
    </mappings>
	</xsl:template>
	<xsl:template match="Worksheet">
    <xsl:variable name="domainLabel">
      <xsl:choose>
        <xsl:when test="ends-with(@ss:Name, ' FHIR Mapping')">
          <xsl:value-of select="normalize-space(substring-before(@ss:Name, ' FHIR Mapping'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@ss:Name"/>
          <xsl:message select="concat('Unexpected worksheet name.  Should end with '' FHIR Mapping'':', @ss:Name)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="domains" as="element()+">
      <domain code="LAB" name="Laboratory"/>
      <domain code="LB" name="Laboratory2"/>
      <domain code="VS" name="Vital Signs"/>
      <domain code="AE" name="Adverse Event"/>
      <domain code="MH" name="Medical History"/>
      <domain code="CM" name="Concomitant Medications"/>
      <domain code="PR" name="Procedure"/>
      <domain code="DM" name="Demographics"/>
    </xsl:variable>
    <xsl:variable name="domainCode" select="$domains[@code=$domainLabel or @name=$domainLabel]/@code"/>
    <xsl:variable name="domainName" select="$domains[@code=$domainLabel or @name=$domainLabel]/@name"/>
    <xsl:if test="$domainCode=''">
      <xsl:message select="concat('Unable to find code for label ', $domainLabel)"/>
    </xsl:if>
    <xsl:variable name="domain" as="element()">
      <domain code="{$domainCode}" name="{$domainName}">
        <xsl:for-each select="Table">
          <xsl:for-each select="Row[1]/Cell/Data[not(normalize-space(.)=$columnNames/*:name)]">
            <xsl:message select="concat('Unrecognized column name: ', ., ' on domain sheet ', $domainName)"/>
          </xsl:for-each>
          <xsl:variable name="itemNameColumn" select="count(Row[1]/Cell[normalize-space(Data)='Description']/preceding-sibling::Cell)+1"/><!-- Done -->
          <xsl:variable name="resourceColumn" select="count(Row[1]/Cell[normalize-space(Data)='FHIR Resource Name']/preceding-sibling::Cell)+1"/>
          <xsl:variable name="elementColumn" select="count(Row[1]/Cell[normalize-space(Data)='FHIR Attribute Name']/preceding-sibling::Cell)+1"/>
          <xsl:variable name="pathColumn" select="count(Row[1]/Cell[normalize-space(Data)='FHIR Path Origin']/preceding-sibling::Cell)+1"/>
          <xsl:variable name="pathReferenceColumn" select="count(Row[1]/Cell[normalize-space(Data)='FHIR Path Reference']/preceding-sibling::Cell)+1"/>
          <xsl:variable name="gapColumn" select="count(Row[1]/Cell[normalize-space(Data)='Gap Mitigation']/preceding-sibling::Cell)+1"/>
          <xsl:variable name="commentsColumn" select="count(Row[1]/Cell[normalize-space(Data)='Comments']/preceding-sibling::Cell)+1"/>
          <xsl:variable name="xPathColumn" select="count(Row[1]/Cell[normalize-space(Data)='FHIR XML Path Reference']/preceding-sibling::Cell)+1"/>
          <xsl:variable name="labXPathColumn" select="count(Row[1]/Cell[normalize-space(Data)='LAB XML Xpath']/preceding-sibling::Cell)+1"/>
          <xsl:variable name="labMandatoryColumn" select="count(Row[1]/Cell[normalize-space(Data)='Mandatory in LAB?']/preceding-sibling::Cell)+1"/>
          <xsl:variable name="labRulesColumn" select="count(Row[1]/Cell[normalize-space(Data)='LAB IG Rules']/preceding-sibling::Cell)+1"/>
          <xsl:variable name="cdashColumn" select="count(Row[1]/Cell[normalize-space(Data)='CDASH Variable']/preceding-sibling::Cell)+1"/><!-- Done -->
          <xsl:variable name="cdashMappingColumn" select="count(Row[1]/Cell[normalize-space(Data)='CDASH Mapping Instructions &amp; Description']/preceding-sibling::Cell)+1"/><!-- Done -->
          <xsl:variable name="sdtmColumn" select="count(Row[1]/Cell[normalize-space(Data)='SDTM Variable']/preceding-sibling::Cell)+1"/><!-- Done -->
          <xsl:variable name="sdtmMappingColumn" select="count(Row[1]/Cell[normalize-space(Data)='SDTM Mapping Instructions &amp; Description']/preceding-sibling::Cell)+1"/><!-- Done -->
          <xsl:for-each select="Row[not(position()=1)]">
            <xsl:if test="t:hasCellValue(., $itemNameColumn)">
              <element name="{t:cellValue(., $itemNameColumn)}">
                <xsl:if test="$labXPathColumn!=1">
                  <cdisc spec="LAB" label="{t:cellValue(., $labXPathColumn)}">
                    <xsl:if test="t:hasCellValue(., $labRulesColumn)">
                      <description>
                        <xsl:copy-of select="t:htmlValue(., $labRulesColumn)"/>
                      </description>
                    </xsl:if>
                  </cdisc>
                </xsl:if>
                <xsl:if test="$cdashColumn!=1 and (t:hasCellValue(., $cdashColumn) or t:hasCellValue(., $cdashMappingColumn))">
                  <cdisc spec="CDASH">
                    <xsl:if test="t:hasCellValue(., $cdashColumn)">
                      <xsl:attribute name="label" select="t:cellValue(., $cdashColumn)"/>
                    </xsl:if>
                    <xsl:if test="t:hasCellValue(., $cdashMappingColumn)">
                      <description>
                        <xsl:copy-of select="t:htmlValue(., $cdashMappingColumn)"/>
                      </description>
                    </xsl:if>
                  </cdisc>
                </xsl:if>
                <xsl:if test="$sdtmColumn!=1 and (t:hasCellValue(., $sdtmColumn) or t:hasCellValue(., $sdtmMappingColumn))">
                  <cdisc spec="SDTM">
                    <xsl:if test="t:hasCellValue(., $sdtmColumn)">
                      <xsl:attribute name="label" select="t:cellValue(., $sdtmColumn)"/>
                    </xsl:if>
                    <xsl:if test="t:hasCellValue(., $sdtmMappingColumn)">
                      <description>
                        <xsl:copy-of select="t:htmlValue(., $sdtmMappingColumn)"/>
                      </description>
                    </xsl:if>
                  </cdisc>
                </xsl:if>
                <xsl:variable name="mappings" as="element()?">
                  <xsl:if test="t:hasCellValue(., $resourceColumn)">
                    <mapping>
                      <xsl:variable name="element" select="concat(t:cellValue(., $resourceColumn), '.', t:cellValue(., $elementColumn))"/>
                      <xsl:attribute name="element" select="$element"/>
                      <xsl:if test="t:hasCellValue(., $pathColumn)">
                        <path value="{t:cellValue(., $pathColumn)}"/>
                      </xsl:if>
                    </mapping>
                  </xsl:if>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="contains($mappings/@element, ',')">
                    <xsl:choose>
                      <xsl:when test="count(tokenize($mappings/@element, ','))=count(tokenize($mappings/@path, ','))">
                        <xsl:for-each select="tokenize($mappings/@element, ',')">
                          <mapping element="{.}" path="{tokenize($mappings/@element, ',')[position()]}"/>
                        </xsl:for-each>
                      </xsl:when>
                    </xsl:choose>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:copy-of select="$mappings"/>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="t:hasCellValue(., $gapColumn)">
                  <gap>
                    <xsl:copy-of select="t:htmlValue(., $gapColumn)"/>
                  </gap>
                </xsl:if>
                <xsl:if test="t:hasCellValue(., $commentsColumn)">
                  <comment>
                    <xsl:copy-of select="t:htmlValue(., $commentsColumn)"/>
                  </comment>
                </xsl:if>
              </element>
            </xsl:if>
          </xsl:for-each>
        </xsl:for-each>
      </domain>
    </xsl:variable>
    <xsl:for-each select="$domain">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:for-each select="*:element">
          <xsl:if test="not(preceding-sibling::*:element[@name=current()/@name])">
            <xsl:variable name="elements" select="parent::*:domain/*:element[@name=current()/@name]" as="element()+"/>
            <xsl:choose>
              <xsl:when test="count($elements)=1">
                <xsl:copy-of select="$elements"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:copy>
                  <xsl:copy-of select="@*"/>
                  <xsl:for-each select="*:cdisc">
                    <xsl:if test="@label and count(distinct-values($elements/*:cdisc[@spec=current()/@spec]/@label))!=1">
                      <xsl:message select="$elements"/>
                      <xsl:message terminate="yes" select="concat('cdisc labels for spec ', @spec, ' are not the same')"/>
                    </xsl:if>
                    <xsl:if test="*:description and count(distinct-values($elements/*:cdisc[@spec=current()/@spec]/*:description))!=1">
                      <xsl:message select="$elements"/>
                      <xsl:message terminate="yes" select="concat('cdisc descriptions for spec ', @spec, ' are not the same')"/>
                    </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="*:comment and count(distinct-values($elements/*:comment))!=1">
                    <xsl:message select="$elements"/>
                    <xsl:message terminate="yes" select="'cdisc comments are not the same'"/>
                  </xsl:if>
                  <xsl:copy-of select="*:cdisc"/>
                  <xsl:copy-of select="$elements/*:mapping"/>
                  <xsl:copy-of select="*:comment"/>
                </xsl:copy>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </xsl:for-each>
      </xsl:copy>
    </xsl:for-each>
	</xsl:template>
	<xsl:function name="t:hasCellValue" as="xs:boolean">
    <xsl:param name="node" as="element()"/>
    <xsl:param name="column" as="xs:integer"/>
    <xsl:variable name="value" select="$node/Cell[$column]/Data"/>
    <xsl:value-of select="not(normalize-space($value)=('','N/A'))"/>
  </xsl:function>
	<xsl:function name="t:cellValue" as="xs:string?">
    <xsl:param name="node" as="element()"/>
    <xsl:param name="column" as="xs:integer"/>
    <xsl:if test="t:hasCellValue($node, $column)">
      <xsl:variable name="value" select="$node/Cell[$column]/Data"/>
      <xsl:value-of select="$value/node()"/>
    </xsl:if>
	</xsl:function>
	<xsl:function name="t:htmlValue" as="node()*">
    <xsl:param name="node" as="element()"/>
    <xsl:param name="column" as="xs:integer"/>
    <xsl:variable name="value" select="$node/Cell[$column]/Data"/>
    <xsl:if test="not(normalize-space($value)=('','N/A'))">
      <xsl:apply-templates mode="html" select="$value/node()"/>
    </xsl:if>
	</xsl:function>
	<xsl:template mode="html" match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates mode="html" select="@*|node()"/>
    </xsl:copy>
	</xsl:template>
	<xsl:template mode="html" match="text()" priority="5">
    <xsl:copy-of select="t:insertBreaks(.)"/>
  </xsl:template>
  <xsl:function name="t:insertBreaks" as="node()*">
    <xsl:param name="text" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="contains($text, '&#xa;&#xa;')">
        <xsl:value-of select="substring-before($text, '&#xa;&#xa;')"/>
        <br/>
        <xsl:value-of select="t:insertBreaks(substring-before($text, '&#xa;&#xa;'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
	</xsl:function>
	<xsl:template mode="normalize" match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates mode="normalize" select="@*|node()"/>
    </xsl:copy>
	</xsl:template>
	<xsl:template mode="normalize" match="Table">
    <xsl:copy>
      <xsl:apply-templates mode="normalize" select="@*|Column|Row[1]"/>
    </xsl:copy>
	</xsl:template>
	<xsl:template mode="normalize" match="Row">
    <xsl:param name="prevRow" as="element(Row)?"/>
    <xsl:variable name="row" as="element(Row)">
      <xsl:copy>
        <xsl:apply-templates mode="normalize" select="@*|Cell[1]">
          <xsl:with-param name="prevRow" select="$prevRow"/>
          <xsl:with-param name="position" select="1"/>
        </xsl:apply-templates>
      </xsl:copy>
    </xsl:variable>
    <xsl:apply-templates mode="stripAttributes" select="$row"/>
    <xsl:apply-templates mode="normalize" select="following-sibling::Row[1]">
      <xsl:with-param name="prevRow" select="$row"/>
    </xsl:apply-templates>
	</xsl:template>
	<xsl:template mode="normalize" match="Cell">
    <xsl:param name="prevRow" as="element(Row)?"/>
    <xsl:param name="position" as="xs:integer"/>
    <xsl:choose>
      <xsl:when test="$prevRow/Cell[$position][@ss:MergeDown&gt;0]">
        <xsl:for-each select="$prevRow/Cell[$position]">
          <xsl:copy>
            <xsl:apply-templates mode="normalize" select="@*"/>
            <xsl:attribute namespace="urn:schemas-microsoft-com:office:spreadsheet" name="MergeDown" select="@ss:MergeDown - 1"/>
            <xsl:apply-templates mode="normalize" select="node()"/>
          </xsl:copy>
        </xsl:for-each>
        <xsl:apply-templates mode="normalize" select=".">
          <xsl:with-param name="prevRow" select="$prevRow"/>
          <xsl:with-param name="position" select="$position+1"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@fake"> 
        <!-- This isn't a real cell - it was just being used to trigger copying of cells from the prior row, so do nothing -->
      </xsl:when>
      <xsl:when test="@ss:Index&gt;$position">
        <Cell xmlns="urn:schemas-microsoft-com:office:spreadsheet">
          <xsl:apply-templates mode="normalize" select="@*"/>
        </Cell>
        <xsl:apply-templates mode="normalize" select=".">
          <xsl:with-param name="prevRow" select="$prevRow"/>
          <xsl:with-param name="position" select="$position+1"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates mode="normalize" select="@*|node()"/>
        </xsl:copy>
        <xsl:choose>
          <xsl:when test="following-sibling::Cell">
            <xsl:apply-templates mode="normalize" select="following-sibling::Cell[1]">
              <xsl:with-param name="prevRow" select="$prevRow"/>
              <xsl:with-param name="position" select="$position+1"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="$prevRow/Cell[$position+1][@ss:MergeDown&gt;0]">
            <xsl:apply-templates mode="normalize" select="$fakeCell">
              <xsl:with-param name="prevRow" select="$prevRow"/>
              <xsl:with-param name="position" select="$position+1"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="$prevRow/Cell[$position+1]">
            <xsl:message select="$prevRow/Cell[$position+1]"/>
            <xsl:message terminate="yes" select="concat('Extra cell:', $position, ' ', ancestor::Worksheet/@ss:Name, ' - ', count(parent::Row/preceding-sibling::Row)+1, ', ', count(preceding-sibling::Cell)+1)"/>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
	</xsl:template>
	<xsl:template mode="stripAttributes" match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates mode="stripAttributes" select="@*|node()"/>
    </xsl:copy>
	</xsl:template>
	<xsl:template mode="stripAttributes" match="Cell/@ss:MergeDown|Cell/@ss:Index"/>
</xsl:stylesheet>
