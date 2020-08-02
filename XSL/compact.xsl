<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"
		exclude-result-prefixes="xgf"
                version="1.0">

  <xsl:output method="xml" indent="yes"/>

  <xsl:include href="expressions.xsl"/>

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@num">
   <xsl:attribute name="n">
      <xsl:value-of select="."/>
   </xsl:attribute>
  </xsl:template>

  <xsl:template match="@value">
   <xsl:attribute name="val">
      <xsl:value-of select="."/>
   </xsl:attribute>
  </xsl:template>

  <xsl:template match="@name">
   <xsl:attribute name="nm">
      <xsl:value-of select="."/>
   </xsl:attribute>
  </xsl:template>

  <xsl:template match="@ps-name">
   <xsl:attribute name="pnm">
      <xsl:value-of select="."/>
   </xsl:attribute>
  </xsl:template>

  <xsl:template match="@distance">
   <xsl:attribute name="di">
      <xsl:value-of select="."/>
   </xsl:attribute>
  </xsl:template>

  <xsl:template match="reference-ptr">
   <xsl:attribute name="ref-ptr">
      <xsl:value-of select="."/>
   </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="@color">
    <xsl:attribute name="col">
      <xsl:variable name="color" select="."/>
      <xsl:choose>
	<xsl:when test="$color = 'black'">
	  <xsl:text>b</xsl:text>
	</xsl:when>
	<xsl:when test="$color = 'white'">
	  <xsl:text>w</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>g</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
   </xsl:attribute>
  </xsl:template>

  <xsl:template match="xgf:point">
    <xgf:pt>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:pt>
  </xsl:template>

  <xsl:template match="xgf:move">
    <xgf:mv>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:mv>
  </xsl:template>

  <xsl:template match="xgf:interpolate">
    <xgf:ip>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:ip>
  </xsl:template>

  <xsl:template match="xgf:shift">
    <xgf:sh>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:sh>
  </xsl:template>

  <xsl:template match="xgf:align">
    <xgf:al>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:al>
  </xsl:template>

  <xsl:template match="xgf:srp">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xgf:call-function">
    <xgf:callf>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:callf>
  </xsl:template>

  <xsl:template match="xgf:call-glyph">
    <xgf:callg>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:callg>
  </xsl:template>

  <xsl:template match="xgf:call-macro">
    <xgf:callm>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:callm>
  </xsl:template>

  <xsl:template match="xgf:call-param">
    <xgf:callp>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:callp>
  </xsl:template>

  <xsl:template match="xgf:constant">
    <xgf:cn>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:cn>
  </xsl:template>

  <xsl:template match="xgf:control-value">
    <xgf:cv>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:cv>
  </xsl:template>

  <xsl:template match="xgf:function">
    <xgf:fn>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:fn>
  </xsl:template>

  <xsl:template match="xgf:glyph">
    <xgf:gl>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:gl>
  </xsl:template>

  <xsl:template match="xgf:interpolate-untouched-points">
    <xgf:iup>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:iup>
  </xsl:template>
  
  <xsl:template match="xgf:macro">
    <xgf:mo>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:mo>
  </xsl:template>

  <xsl:template match="xgf:param-set">
    <xgf:pmset>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:pmset>
  </xsl:template>

  <xsl:template match="xgf:pre-program">
    <xgf:prep>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:prep>
  </xsl:template>

  <xsl:template match="xgf:reference">
    <xgf:ref>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:ref>
  </xsl:template>
  
  <xsl:template match="xgf: set-control-value">
    <xgf:setcv>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:setcv>
  </xsl:template>

  <xsl:template match="xgf: with-control-value">
    <xgf:wcv>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:wcv>
  </xsl:template>

  <xsl:template match="xgf:set-vectors">
    <xgf:setvs>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:setvs>
  </xsl:template>

  <xsl:template match="xgf:with-vectors">
    <xgf:wvs>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:wvs>
  </xsl:template>

  <xsl:template match="xgf:variable">
    <xgf:var>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:var>
  </xsl:template>

  <xsl:template match="xgf:with-param">
    <xgf:wpm>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:wpm>
  </xsl:template>

  <xsl:template match="xgf:param">
    <xgf:pm>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:pm>
  </xsl:template>

</xsl:stylesheet>
