<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"
                xmlns:xgfd="http://www.engl.virginia.edu/OE/xgridfit-data"
		xmlns:excom="http://exslt.org/common"
                version="1.0"
                exclude-result-prefixes="xgf xgfd excom"
		extension-element-prefixes="excom">

  <xsl:output method="xml"/>
  
  <xsl:key name="cvt" match="xgf:cv" use="@nm"/>

  <xsl:template name="get-cvt-index">
    <xsl:param name="name"/>
    <xsl:param name="need-number-now"/>
    <xsl:value-of
	select="count(key('cvt',$name)/preceding-sibling::xgf:cv)"/>
  </xsl:template>

  
    <xsl:template match="@*|node()">
        <xsl:apply-templates select="@*|node()"/>
    </xsl:template>
  <!--   <xsl:template match="@*|node()"/>
  <xsl:template match="*"/> -->

  <xsl:template match="xgf:cvar">
    <ttFont>
      <cvar>
	<version major="1" minor="0"/>
	<xsl:apply-templates select="xgf:axis"/>
      </cvar>
    </ttFont>
  </xsl:template>

  <xsl:template match="xgf:axis">
    <tuple>
    <coord axis="{@tag}" value="{@val}"/>
    <xsl:for-each select="xgf:cvv">
      <xsl:variable name="default-cv">
	<xsl:value-of select="key('cvt',@nm)/@val"/>
      </xsl:variable>
      <xsl:variable name="this-cv">
	<xsl:value-of select="@val"/>
      </xsl:variable>
      <xsl:variable name="diff" select="number($this-cv) - number($default-cv)"/>
      <xsl:if test="$diff != 0">
	<delta>
	  <xsl:attribute name="cvt">
	    <xsl:call-template name="get-cvt-index">
	      <xsl:with-param name="name">
		<xsl:value-of select="@nm"/>
	      </xsl:with-param>
	      <xsl:with-param name="need-number-now" select="0"/>
	    </xsl:call-template>
	  </xsl:attribute>
	  <xsl:attribute name="delta">
	    <xsl:value-of select="$diff"/>
	  </xsl:attribute>
	</delta>
      </xsl:if>
    </xsl:for-each>
    </tuple>
  </xsl:template>

</xsl:stylesheet>
