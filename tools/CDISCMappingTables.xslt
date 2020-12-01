<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
	<xsl:template match="/mappings">
<!--    <html>
      <head>
        <title>Foo</title>
      </head>
      <body>
        <xsl:for-each select="domain">
          <xsl:apply-templates select="."/>
        </xsl:for-each>
      </body>
    </html>-->
    <xsl:for-each select="domain">
      <xsl:result-document href="../input/includes/{@code}-table.xml" encoding="UTF-8">
        <xsl:apply-templates select="."/>
      </xsl:result-document>
    </xsl:for-each>
	</xsl:template>
	<xsl:template match="domain">
    <xsl:variable name="cdiscConcepts" as="xs:string+" select="distinct-values(element/cdisc/@spec)"/>
    <div>
      <p>
        Guidance on interpreting the table can be found <a href="overview.html#mappings">here</a>.
      </p>
      <table class="grid" style="width:150%;word-break:break-word;table-layout:fixed;">
        <xsl:choose>
          <xsl:when test="count($cdiscConcepts)=1">
            <col style="width:15%"/>
            <col style="width:20%"/>
            <col style="width:15%;"/>
            <col style="width:20%;"/>
            <col style="width:30%;"/>
          </xsl:when>
          <xsl:otherwise>
            <col style="width:15%"/>
            <col style="width:7.5%"/>
            <col style="width:7.5%"/>
            <col style="width:15%;"/>
            <col style="width:20%;"/>
            <col style="width:35%;"/>
          </xsl:otherwise>
        </xsl:choose>
        <thead style="background-color:PowderBlue;">
          <tr>
            <th colspan="{count($cdiscConcepts)+1}" style="text-align:center;">CDISC</th>
            <th colspan="2" style="text-align:center;">FHIR map (or gap)</th>
            <th rowspan="2" style="vertical-align:bottom;text-align:center;">Comment</th>
          </tr>
          <tr style="text-align:center;">
            <th style="text-align:center;">Name</th>
            <xsl:for-each select="$cdiscConcepts">
              <th style="text-align:center;">
                <xsl:value-of select="."/>
              </th>
            </xsl:for-each>
            <th style="text-align:center;">Element</th>
            <th style="text-align:center;">FHIRPath</th>
          </tr>
        </thead>
        <tbody>
          <xsl:for-each select="element">
            <xsl:variable name="element" as="element(element)" select="."/>
            <xsl:variable name="rows" as="xs:integer" select="if (mapping) then count(mapping) else 1"/>
            <tr>
              <th>
                <xsl:if test="$rows!=1">
                  <xsl:attribute name="rowspan" select="$rows"/>
                </xsl:if>
                <xsl:value-of select="@name"/>
              </th>
              <xsl:for-each select="$cdiscConcepts">
                <td>
                  <xsl:if test="$rows!=1">
                    <xsl:attribute name="rowspan" select="$rows"/>
                  </xsl:if>
                  <xsl:for-each select="$element/cdisc[@spec=current()]">
                    <span>
                      <xsl:for-each select="description">
                        <xsl:attribute name="title">
                          <xsl:apply-templates mode="htmlToString" select="node()"/>
                        </xsl:attribute>
                      </xsl:for-each>
                      <xsl:value-of select="@label"/>
                    </span>
                  </xsl:for-each>
                </td>
              </xsl:for-each>
              <xsl:apply-templates select="mapping[1]|gap"/>
              <td>
                <xsl:if test="$rows!=1">
                  <xsl:attribute name="rowspan" select="$rows"/>
                </xsl:if>
                <xsl:copy-of select="comment/node()"/>
              </td>
            </tr>
            <xsl:for-each select="mapping[position()&gt;1]">
              <tr>
                <xsl:apply-templates select="."/>              
              </tr>
            </xsl:for-each>
          </xsl:for-each>
        </tbody>
      </table>
    </div>
	</xsl:template>
	<xsl:template match="gap">
    <td colspan="2" style="background-color:LightGray">
      <xsl:copy-of select="node()"/>
    </td>
	</xsl:template>
	<xsl:template match="mapping">
    <td>
      <xsl:value-of select="@element"/>
    </td>
    <td>
      <xsl:for-each select="path">
        <p>
          <xsl:value-of select="@value"/>
        </p>
      </xsl:for-each>
    </td>
	</xsl:template>
	<xsl:template mode="htmlToString" match="text()">
    <xsl:value-of select="."/>
	</xsl:template>
	<xsl:template mode="htmlToString" match="br">
    <xsl:text>&#xa;&#xa;</xsl:text>
	</xsl:template>
	<xsl:template mode="htmlToString" match="*">
    <xsl:message terminate="yes" select="concat('Unsupported HTML element: ', local-name(.))"/>
	</xsl:template>
</xsl:stylesheet>
