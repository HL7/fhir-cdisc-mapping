<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://hl7.org/fhir">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
	<xsl:template match="/">
    <resources>
      <xsl:for-each select="/Bundle/entry/resource/StructureDefinition">
        <xsl:if test="id/@value=('Observation','Specimen','Patient','AllergyIntolerance','Procedure','MedicationStatement','MedicationAdministration','MedicationDispense','MedicationRequest','Condition','ResearchStudy','ResearchSubject','Practitioner','Organization','ActivityDefinition','DiagnosticReport','Encounter','ServiceRequest','AdverseEvent','Immunization','Medication','BodyStructure')">
          <xsl:apply-templates select="."/>
        </xsl:if>
      </xsl:for-each>
    </resources>
	</xsl:template>
	<xsl:template match="StructureDefinition">
    <resource name="{id/@value}">
      <xsl:apply-templates select="snapshot/element[contains(path/@value, '.')]"/>
    </resource>
	</xsl:template>
	<xsl:template match="element">
    <xsl:choose>
      <xsl:when test="ends-with(path/@value, '[x]')">
        <xsl:variable name="path" select="substring-before(path/@value, '[x]')"/>
        <xsl:for-each select="type">
          <xsl:variable name="type" select="if (code/@value='http://hl7.org/fhirpath/System.String') then 'string' else code/@value"/>
          <xsl:variable name="name" select="concat($path, upper-case(substring($type,1,1)),substring($type,2))"/>
          <element path="{$name}" min="{min/@value}" max="{max/@value}">
            <xsl:for-each select="parent::element">
              <xsl:attribute name="min" select="min/@value"/>
              <xsl:attribute name="max" select="max/@value"/>
              <xsl:apply-templates select="definition|comment|binding|condition"/>
            </xsl:for-each>
            <xsl:choose>
              <xsl:when test="$type='string'">
                <type><code value="string"/></type>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="."/>
              </xsl:otherwise>
            </xsl:choose>
          </element>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <element path="{path/@value}" min="{min/@value}" max="{max/@value}">
          <xsl:apply-templates select="definition|comment|binding|condition|type"/>
        </element>
      </xsl:otherwise>
    </xsl:choose>
	</xsl:template>
	<xsl:template match="binding">
    <binding name="{extension[contains(@url,'bindingName')]/valueString/@value}" strength="{strength/@value}" valueSet="{valueSet/@value}"/>
	</xsl:template>
	<xsl:template match="*">
    <xsl:element name="{local-name(.)}">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
	</xsl:template>
	<xsl:template match="@*">
    <xsl:copy-of select="."/>
	</xsl:template>
	<xsl:template match="text()[normalize-space(.)='']"/>
</xsl:stylesheet>
