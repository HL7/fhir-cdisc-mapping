<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:f="http://example.org/foo">
	<xsl:output method="text" encoding="UTF-8"/>
	<xsl:template match="/mappings">
    <xsl:text>Domain,CDASH/Lab Element,CDASH Core,CDASH Type,CDASH Definition,CDASH Link,CDASH-SDTM Map Comments,SDTM Element,SDTM Core,SDTM Type,SDTM Terminology,SDTM Definition,SDTM Link,FHIR Resource,FHIR Element,FHIR Path,FHIR Min,FHIR Max,FHIR Type,FHIR Binding Name,FHIR Binding Strength,FHIR Binding Valueset,FHIR Condition,FHIR Definition,FHIR Comment,FHIR Gap,Comment&#xa;</xsl:text>
    <xsl:for-each select="domain/element">
      <xsl:call-template name="doElement">
        <xsl:with-param name="pos" select="1"/>
      </xsl:call-template>
      <xsl:if test="count(cdisc[@spec='SDTM'])>1">
        <xsl:call-template name="doElement">
          <xsl:with-param name="pos" select="2"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="count(cdisc[@spec='SDTM'])>2">
        <xsl:message terminate="yes" select="'Need to update transform to support more than 2 SDTM mappings per element'"/>
      </xsl:if>
    </xsl:for-each>
	</xsl:template>
	<xsl:template name="doElement">
    <xsl:param name="pos" as="xs:integer"/>
    <xsl:for-each select="mapping|gap">
      <xsl:value-of select="concat(ancestor::domain/@code, ',')"/>
      <xsl:if test="not(ancestor::element/cdisc[@spec=('LAB','CDASH')])">,,,,,</xsl:if>
      <xsl:for-each select="ancestor::element/cdisc[@spec=('LAB','CDASH')]">
        <xsl:value-of select="concat('&quot;', f:escape(@label), '&quot;,&quot;', @core, '&quot;,&quot;', @type, '&quot;,&quot;')"/>
        <xsl:apply-templates mode="htmlToString" select="definition/node()"/>
        <xsl:value-of select="concat('&quot;,&quot;', @link, '&quot;,')"/>
      </xsl:for-each>
      <xsl:if test="not(ancestor::element/cdisc[@spec='SDTM'])">,,,,,,</xsl:if>
      <xsl:for-each select="ancestor::element/cdisc[@spec='SDTM'][position()=$pos]">
        <xsl:variable name="values" select="string-join(valueList/value, ', ')"/>
        <xsl:text>"</xsl:text>
        <xsl:apply-templates mode="htmlToString" select="description/node()"/>
        <xsl:value-of select="concat('&quot;,&quot;', f:escape(@label), '&quot;,&quot;', @core, '&quot;,&quot;', @type, '&quot;,&quot;',f:escape(@valueDomain), f:escape($values), '&quot;,&quot;')"/>
        <xsl:apply-templates mode="htmlToString" select="definition/node()"/>
        <xsl:value-of select="concat('&quot;,&quot;', @link, '&quot;')"/>
      </xsl:for-each>
      <xsl:choose>
        <xsl:when test="self::mapping">
          <xsl:variable name="paths" as="xs:string+">
            <xsl:for-each select="path">
              <xsl:value-of select="f:escape(@value)"/>
            </xsl:for-each>
          </xsl:variable>
          <xsl:value-of select="concat(',&quot;', f:escape(@resource),'&quot;,&quot;', f:escape(@path), '&quot;,&quot;', string-join($paths, '\r\n'), '&quot;,', @min, ',', @max, ',', type/code/@value, ',&quot;', f:escape(binding/@name),'&quot;,&quot;',
            f:escape(binding/@strength), '&quot;,&quot;', f:escape(binding/@valueSet), '&quot;,&quot;', string-join(condition/@value, ', '), '&quot;,&quot;', f:escape(definition/@value), '&quot;,&quot;', f:escape(comment/@value), '&quot;,&quot;')"/>
        </xsl:when>
        <xsl:otherwise>,,,,,,,,,,,,,"</xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates mode="htmlToString" select="parent::*/gap/node()"/>
      <xsl:text>","</xsl:text>
      <xsl:apply-templates mode="htmlToString" select="parent::*/comment/node()"/>
      <xsl:text>"&#xa;</xsl:text>
    </xsl:for-each>
	</xsl:template>
	<xsl:template mode="htmlToString" match="text()">
    <xsl:value-of select="f:escape(.)"/>
	</xsl:template>
	<xsl:template mode="htmlToString" match="br">
    <xsl:text>&#xa;&#xa;</xsl:text>
	</xsl:template>
	<xsl:template mode="htmlToString" match="*">
    <xsl:message terminate="yes" select="concat('Unsupported HTML element: ', local-name(.))"/>
	</xsl:template>
	<xsl:function name="f:escape">
    <xsl:param name="string"/>
    <xsl:choose>
      <xsl:when test="contains($string, '&quot;')">
        <xsl:value-of select="concat(substring-before($string, '&quot;'), '&quot;&quot;', f:escape(substring-after($string, '&quot;')))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
	</xsl:function>
</xsl:stylesheet>
