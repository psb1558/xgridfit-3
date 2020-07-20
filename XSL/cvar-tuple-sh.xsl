<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"
                xmlns:xgfd="http://www.engl.virginia.edu/OE/xgridfit-data"
		xmlns:excom="http://exslt.org/common"
                version="1.0"
                exclude-result-prefixes="xgf xgfd excom"
		extension-element-prefixes="excom">

  <xsl:output method="text"/>
  
  <xsl:key name="cvt" match="xgf:cv" use="@nm"/>

  <xsl:variable name="newline"><xsl:text>
</xsl:text></xsl:variable>

  <xsl:template name="get-cvt-index">
    <xsl:param name="name"/>
    <xsl:param name="need-number-now"/>
    <xsl:value-of
	select="count(key('cvt',$name)/preceding-sibling::xgf:cv)"/>
  </xsl:template>

  
    <xsl:template match="@*|node()">
        <xsl:apply-templates select="@*|node()"/>
    </xsl:template>

  <xsl:template match="xgf:cvar">
    <xsl:text>CVAR_VARIATIONS = [</xsl:text>
    <xsl:value-of select="$newline"/>
    <xsl:apply-templates select="xgf:axis"/>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="xgf:axis">
    <xsl:text>    TupleVariation({'</xsl:text>
    <xsl:value-of select="@tag"/>
    <xsl:text>': (</xsl:text>
    <xsl:value-of select="@bot"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="@val"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="@top"/>
    <xsl:text>)}, [</xsl:text>
    <xsl:variable name="cvvs" select="*"/>
    <xsl:for-each select="/xgf:xgridfit/xgf:cv">
      <xsl:variable name="cvname" select="@nm"/>
      <xsl:choose>
	<xsl:when test="$cvvs[@nm = $cvname]">
	  <xsl:variable name="defcv" select="number(@val)"/>
	  <xsl:variable name="varcv" select="number($cvvs[@nm
					     = $cvname]/@val)"/>
	  <xsl:variable name="r" select="$varcv - $defcv"/>
	  <xsl:choose>
	    <xsl:when test="$r = 0">
	      <xsl:text>None</xsl:text>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="$r"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>None</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:if test="position() != last()">
	<xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>]),</xsl:text>
    <xsl:value-of select="$newline"/>
  </xsl:template>

</xsl:stylesheet>
