<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:f="http://example.org/foo">
	<xsl:output method="text" encoding="UTF-8"/>
	<xsl:template match="/mappings">
    <xsl:text>Domain,CDISC Spec1,CDISC Element1,CDISC Description1,CDISC Spec2,CDISC Element2,CDISC Description2,FHIR Element,FHIR Path,FHIR Gap,Comment&#xa;</xsl:text>
    <xsl:for-each select="domain/element">
      <xsl:for-each select="mapping/path|gap">
        <xsl:value-of select="concat(ancestor::domain/@code, ',', f:escape(ancestor::element/cdisc[1]/@spec), ',&quot;', f:escape(ancestor::element/cdisc[1]/@label), '&quot;,&quot;')"/>
        <xsl:apply-templates mode="htmlToString" select="ancestor::element/cdisc[1]/description/node()"/>
        <xsl:value-of select="concat('&quot;,', f:escape(ancestor::element/cdisc[2]/@spec), ',&quot;', f:escape(ancestor::element/cdisc[2]/@label), '&quot;,&quot;')"/>
        <xsl:apply-templates mode="htmlToString" select="ancestor::element/cdisc[2]/description/node()"/>
        <xsl:value-of select="concat('&quot;,&quot;', f:escape(parent::mapping/@element), '&quot;,&quot;', f:escape(@value), '&quot;,&quot;')"/>
        <xsl:apply-templates mode="htmlToString" select="self::gap/node()"/>
        <xsl:text>","</xsl:text>
        <xsl:apply-templates mode="htmlToString" select="ancestor::element/comment/node()"/>
        <xsl:text>"&#xa;</xsl:text>
      </xsl:for-each>
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
