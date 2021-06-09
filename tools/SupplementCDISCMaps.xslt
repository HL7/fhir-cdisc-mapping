<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" encoding="UTF-8"/>
	<xsl:variable name="cdash-domains" select="document('CDASHIGv2-1.xml')/cdiscLibrary/product/class/domain" as="element(domain)*"/>
	<xsl:variable name="cdash-lab" select="document('CDASHIGv2-1.xml')/cdiscLibrary/product/class/scenario[domain='Labs']" as="element(scenario)*"/>
	<xsl:variable name="sdtm-domains" select="document('SDTMIGv3-2.xml')/cdiscLibrary/product/class/dataset" as="element(dataset)*"/>
	<xsl:variable name="resources" select="document('../temp/resources.xml')/resources/resource" as="element(resource)+"/>
	<xsl:template match="/">
    <xsl:if test="count($cdash-domains)=0">
      <xsl:message terminate="yes">Unable to load CDASH domains</xsl:message>
    </xsl:if>
    <xsl:if test="count($sdtm-domains)=0">
      <xsl:message terminate="yes">Unable to load SDTM domains</xsl:message>
    </xsl:if>
    <xsl:apply-templates select="*"/>
	</xsl:template>
	<xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
	</xsl:template>
	<xsl:template match="domain">
    <xsl:variable name="cdash" select="$cdash-domains[name=current()/@code]" as="element(domain)?"/>
    <xsl:variable name="sdtm" select="$sdtm-domains[name=current()/@code]" as="element(dataset)?"/>
    <xsl:if test="not($cdash/name) and @code!='LAB'">
      <xsl:message terminate="yes" select="concat('Unable to find CDASH domain ', @code)"/>
    </xsl:if>
    <xsl:if test="not($sdtm/name) and @code!='LAB'">
      <xsl:message terminate="yes" select="concat('Unable to find SDTM domain ', @code)"/>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()">
        <xsl:with-param name="cdash" tunnel="yes" select="$cdash"/>
        <xsl:with-param name="sdtm" tunnel="yes" select="$sdtm"/>
      </xsl:apply-templates>
    </xsl:copy>
	</xsl:template>
	<xsl:template match="cdisc">
    <xsl:param name="cdash" tunnel="yes"/>
    <xsl:param name="sdtm" tunnel="yes"/>
    <xsl:variable name="cdisc" as="element()?">
<!--      <xsl:variable name="effectiveDomain" as="element()?">-->
      <xsl:variable name="effectiveDomain" as="element()*">
        <xsl:choose>
          <xsl:when test="not(@label) or ends-with(@label, '*') or starts-with(@label, 'SUPP')"/>
          <xsl:when test="starts-with(@label, 'DM.') and @spec='CDASH' and @label and $cdash/name">
            <xsl:copy-of select="$cdash-domains[name='DM']"/>
          </xsl:when>
          <xsl:when test="starts-with(@label, 'DM.') and @spec='SDTM' and @label and $sdtm/name">
            <xsl:copy-of select="$sdtm-domains[name='DM']"/>
          </xsl:when>
          <xsl:when test="@spec='CDASH' and ancestor::domain/@code='LB' and $cdash/name">
            <xsl:copy-of select="$cdash-lab"/>
          </xsl:when>
          <xsl:when test="@spec='CDASH' and @label and $cdash/name">
            <xsl:copy-of select="$cdash"/>
          </xsl:when>
          <xsl:when test="@spec='SDTM' and @label and $sdtm/name">
            <xsl:copy-of select="$sdtm"/>
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="effectiveLabel" select="if (starts-with(@label, 'DM.')) then substring-after(@label, '.') else @label"/>
      <xsl:variable name="value" as="element()*" select="$effectiveDomain/*[name=$effectiveLabel]"/>
      <xsl:if test="$effectiveDomain/name and not($value/name)">
        <xsl:message select="concat('Unable to find element ', normalize-space(@label), '(label=', parent::*/@name,') in ', @spec, ' domain ', $sdtm/name)"/>
      </xsl:if>
      <xsl:for-each select="$value">
        <xsl:if test="position()=1">
          <xsl:copy-of select="."/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="$cdisc/label and normalize-space($cdisc/label)!=normalize-space(parent::element/@name) and not(preceding-sibling::cdisc[@spec='CDASH'])">
      <xsl:message select="concat('Labels disagree.  Found ', parent::element/@name, ' but ', @spec, ' ', ancestor::domain/@code ,' ', @label, ' expected ', $cdisc/label)"/>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="$cdisc/name">
          <xsl:attribute name="core" select="$cdisc/core"/>
          <xsl:attribute name="type" select="$cdisc/simpleDatatype"/>
          <xsl:attribute name="link" select="$cdisc/_links/self/href"/>
          <xsl:for-each select="$cdisc/describedValueDomain">
            <xsl:attribute name="valueDomain" select="."/>
          </xsl:for-each>
          <xsl:variable name="normalizedDesc" select="upper-case(normalize-space(translate(description, '-.', ' ')))"/>
          <xsl:variable name="normalizedLabel" select="upper-case(normalize-space(translate($cdisc/label, '-.', ' ')))"/>
          <xsl:variable name="normalizedDef" select="upper-case(normalize-space(translate($cdisc/definition, '-.', ' ')))"/>
          <xsl:choose>
            <xsl:when test="$normalizedDesc=''"/>
            <xsl:when test="$normalizedDesc=$normalizedLabel
                         or $normalizedDesc=$normalizedDef
                         or $normalizedDesc=concat($normalizedLabel, ' ', $normalizedDef)">
              <xsl:message select="concat('Stripped description from ', ancestor::domain/@code ,' ', @label)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="description"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="description"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:copy-of select="$cdisc/definition|$cdisc/valueList"/>
      <xsl:if test="$cdisc/description">
        <definition>
          <xsl:copy-of select="$cdisc/description/node()"/>
        </definition>
      </xsl:if>
    </xsl:copy>
	</xsl:template>
	<xsl:template match="mapping">
    <xsl:variable name="resource" select="$resources[@name=current()/@resource]" as="element(resource)?"/>
    <xsl:if test="not($resource)">
      <xsl:message select="concat('Unable to find resource ', @resource)"/>
    </xsl:if>
    <xsl:variable name="element" select="$resource/element[@path=concat(current()/@resource, '.', current()/@path)]" as="element(element)?"/>
    <xsl:if test="not($element)">
      <xsl:message select="concat('Unable to find element ', @resource, '.', @path, ' for element ', ancestor::domain/@code, ' ', parent::element/@name)"/>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:copy-of select="$element/@*[not(local-name(.)='path')]"/>
      <xsl:apply-templates select="node()"/>
      <xsl:copy-of select="$element/path"/>
      <xsl:copy-of select="$element/type"/>
      <xsl:copy-of select="$element/binding"/>
      <xsl:copy-of select="$element/condition"/>
      <xsl:copy-of select="$element/definition"/>
      <xsl:copy-of select="$element/comment"/>
    </xsl:copy>
	</xsl:template>
</xsl:stylesheet>
