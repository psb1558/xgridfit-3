<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"
		exclude-result-prefixes="xgf"
                version="1.0">

  <xsl:output method="xml" indent="yes"/>

  <xsl:include href="expressions-sh.xsl"/>

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="make-points">
    <xsl:param name="s"/>
    <xsl:variable name="current">
      <xsl:call-template name="get-first-token">
        <xsl:with-param  name="s" select="$s"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="remaining">
      <xsl:call-template name="get-remaining-tokens">
	<xsl:with-param  name="s" select="$s"/>
      </xsl:call-template>
    </xsl:variable>
    <xgf:pt>
      <xsl:attribute name="n">
	<xsl:value-of select="$current"/>
      </xsl:attribute>
    </xgf:pt>
    <xsl:if test="string-length($remaining) &gt; 0">
      <xsl:call-template name="make-points">
	<xsl:with-param name="s" select="$remaining"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="make-params">
    <xsl:param name="s"/>
    <!-- Isolate the key-value pair; set aside what remains -->
    <xsl:variable name="thispair">
      <xsl:choose>
	<xsl:when test="contains($s,',')">
	  <xsl:value-of select="normalize-space(substring-before($s,','))"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$s"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="remaining">
      <xsl:value-of select="normalize-space(substring-after($s,','))"/>
    </xsl:variable>
    <!-- Divide into key and value -->
    <xsl:variable name="keystr">
      <xsl:value-of
	  select="normalize-space(substring-before($thispair,':'))"/>
    </xsl:variable>
    <xsl:variable name="valstr">
      <xsl:value-of
	  select="normalize-space(substring-after($thispair,':'))"/>
    </xsl:variable>
    <!-- Test validity of key-value pair -->
    <xsl:if test="string-length($keystr) = 0 or
		  string-length($valstr) = 0">
      <xsl:message terminate="yes">
	<xsl:text>Ill-formed key-value pair in &lt;pms&gt;</xsl:text>
      </xsl:message>
    </xsl:if>
    <!-- Output the parameter -->
    <xgf:wpm>
      <xsl:attribute name="nm">
	<xsl:value-of select="$keystr"/>
      </xsl:attribute>
      <xsl:attribute name="val">
	<xsl:value-of select="$valstr"/>
      </xsl:attribute>
    </xgf:wpm>
    <!-- Recurs if necessary -->
    <xsl:if test="string-length($remaining) &gt; 0">
      <xsl:call-template name="make-params">
	<xsl:with-param name="s" select="$remaining"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xgf:pms">
    <xsl:call-template name="make-params">
      <xsl:with-param name="s" select="text()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="xgf:ip">
    <xsl:copy>
      <xsl:if test="@r">
	<xgf:ref>
	  <xsl:call-template name="make-points">
	    <xsl:with-param name="s" select="normalize-space(@r)"/>
	  </xsl:call-template>
	</xgf:ref>
      </xsl:if>
      <xsl:if test="@p">
	<xsl:call-template name="make-points">
	  <xsl:with-param name="s" select="normalize-space(@p)"/>
	</xsl:call-template>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xgf:mv">
    <xsl:copy>
      <xsl:if test="@di">
	<xsl:attribute name="di">
	  <xsl:value-of select="@di"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@round">
	<xsl:attribute name="round">
	  <xsl:value-of select="@round"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@cut-in">
	<xsl:attribute name="cut-in">
	  <xsl:value-of select="@cut-in"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@min-distance">
	<xsl:attribute name="min-distance">
	  <xsl:value-of select="@min-distance"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@color">
	<xsl:attribute name="color">
	  <xsl:value-of select="@color"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@compile-if">
	<xsl:attribute name="compile-if">
	  <xsl:value-of select="@compile-if"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@r">
	<xgf:ref>
	  <xsl:call-template name="make-points">
	    <xsl:with-param name="s" select="normalize-space(@r)"/>
	  </xsl:call-template>
	</xgf:ref>
      </xsl:if>
      <xsl:if test="@p">
	<xsl:call-template name="make-points">
	  <xsl:with-param name="s" select="normalize-space(@p)"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xgf:sh">
    <xsl:copy>
      <xsl:if test="@round">
	<xsl:attribute name="round">
	  <xsl:value-of select="@round"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@compile-if">
	<xsl:attribute name="compile-if">
	  <xsl:value-of select="@compile-if"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@ref-ptr">
	<xsl:attribute name="ref-ptr">
	  <xsl:value-of select="@ref-ptr"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@r">
	<xgf:ref>
	  <xsl:call-template name="make-points">
	    <xsl:with-param name="s" select="normalize-space(@r)"/>
	  </xsl:call-template>
	</xgf:ref>
      </xsl:if>
      <xsl:if test="@p">
	<xsl:call-template name="make-points">
	  <xsl:with-param name="s" select="normalize-space(@p)"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xgf:al">
    <xsl:copy>
      <xsl:if test="@compile-if">
	<xsl:attribute name="compile-if">
	  <xsl:value-of select="@compile-if"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@r">
	<xgf:ref>
	  <xsl:call-template name="make-points">
	    <xsl:with-param name="s" select="normalize-space(@r)"/>
	  </xsl:call-template>
	</xgf:ref>
      </xsl:if>
      <xsl:if test="@p">
	<xsl:call-template name="make-points">
	  <xsl:with-param name="s" select="normalize-space(@p)"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xgf:srp">
    <xsl:copy>
      <xsl:if test="@whichpointer">
	<xsl:attribute name="whichpointer">
	  <xsl:value-of select="@whichpointer"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@p">
	<xsl:call-template name="make-points">
	  <xsl:with-param name="s" select="normalize-space(@p)"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xgf:set">
    <xsl:copy>
      <xsl:if test="@nm">
	<xsl:attribute name="nm">
	  <xsl:value-of select="@nm"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@ref">
	<xsl:attribute name="ref">
	  <xsl:value-of select="@ref"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@p">
	<xsl:call-template name="make-points">
	  <xsl:with-param name="s" select="normalize-space(@p)"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xgf:range">
    <xsl:copy>
      <xsl:if test="@nm">
	<xsl:attribute name="nm">
	  <xsl:value-of select="@nm"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@ref">
	<xsl:attribute name="ref">
	  <xsl:value-of select="@ref"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@p">
	<xsl:call-template name="make-points">
	  <xsl:with-param name="s" select="normalize-space(@p)"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
