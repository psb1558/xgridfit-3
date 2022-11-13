<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"
                exclude-result-prefixes="xgf"
                version="1.0">

<!--
  This file is part of xgridfit, version 3.
  Licensed under the Apache License, Version 2.0.
  Copyright (c) 2006-20 by Peter S. Baker
-->

<!--
  Convert from compact syntax to the old (expanded) syntax.
  Since the Xgridfit compiler only recognizes the expanded
  syntax, this is run before processing, but it is also a
  standalone service.
-->

  <xsl:output method="xml" indent="yes"/>

  <xsl:include href="expressions.xsl"/>

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@n">
   <xsl:attribute name="num">
      <xsl:value-of select="."/>
   </xsl:attribute>
  </xsl:template>

  <xsl:template match="@val">
   <xsl:attribute name="value">
      <xsl:value-of select="."/>
   </xsl:attribute>
  </xsl:template>

  <xsl:template match="@nm">
   <xsl:attribute name="name">
      <xsl:value-of select="."/>
   </xsl:attribute>
  </xsl:template>

  <xsl:template match="@coord">
    <xsl:attribute name="coordinate">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@pnm">
   <xsl:attribute name="ps-name">
      <xsl:value-of select="."/>
   </xsl:attribute>
  </xsl:template>

  <xsl:template match="@di">
   <xsl:attribute name="distance">
      <xsl:value-of select="."/>
   </xsl:attribute>
  </xsl:template>

  <xsl:template match="@ref-ptr">
   <xsl:attribute name="reference-ptr">
      <xsl:value-of select="."/>
   </xsl:attribute>
  </xsl:template>

  <xsl:template match="@col">
    <xsl:attribute name="color">
      <xsl:variable name="color" select="."/>
      <xsl:choose>
        <xsl:when test="$color = 'b'">
          <xsl:text>black</xsl:text>
        </xsl:when>
        <xsl:when test="$color = 'w'">
          <xsl:text>white</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>gray</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
   </xsl:attribute>
  </xsl:template>

  <xsl:template name="make-points">
    <xsl:param name="s"/>
    <xsl:variable name="current">
      <xsl:call-template name="get-first-token">
        <xsl:with-param  name="s" select="$s"/>
        <xsl:with-param name="left-paren-sep" select="'('"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="remaining">
      <xsl:call-template name="get-remaining-tokens">
        <xsl:with-param  name="s" select="$s"/>
      </xsl:call-template>
    </xsl:variable>
    <xgf:point>
      <xsl:attribute name="num">
        <xsl:value-of select="$current"/>
      </xsl:attribute>
    </xgf:point>
    <xsl:if test="string-length($remaining) &gt; 0">
      <xsl:call-template name="make-points">
        <xsl:with-param name="s" select="$remaining"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@r">
    <xgf:reference>
      <xsl:call-template name="make-points">
        <xsl:with-param name="s" select="."/>
      </xsl:call-template>
    </xgf:reference>
  </xsl:template>

  <xsl:template match="@p">
    <xsl:call-template name="make-points">
      <xsl:with-param name="s" select="."/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="make-params">
    <xsl:param name="s"/>
    <xsl:message terminate="no">
      <xsl:text>Called make-params with "</xsl:text>
      <xsl:value-of select="$s"/>
      <xsl:text>"</xsl:text>
    </xsl:message>
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
        <xsl:text>Ill-formed key-value pair in param string "</xsl:text>
        <xsl:value-of select='$s'/>
        <xsl:text>"</xsl:text>
      </xsl:message>
    </xsl:if>
    <!-- Output the parameter -->
    <xgf:with-param>
      <xsl:attribute name="name">
        <xsl:value-of select="$keystr"/>
      </xsl:attribute>
      <xsl:attribute name="value">
        <xsl:value-of select="$valstr"/>
      </xsl:attribute>
    </xgf:with-param>
    <!-- Recurs if necessary -->
    <xsl:if test="string-length($remaining) &gt; 0">
      <xsl:call-template name="make-params">
        <xsl:with-param name="s" select="$remaining"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xgf:pt">
    <xgf:point>
      <xsl:apply-templates select="@zone"/>
      <xsl:apply-templates select="@n"/>
    </xgf:point>
  </xsl:template>

  <xsl:template match="xgf:mv">
    <xgf:move>
      <xsl:apply-templates select="@pixel-distance"/>
      <xsl:apply-templates select="@round"/>
      <xsl:apply-templates select="@cut-in"/>
      <xsl:apply-templates select="@min-distance"/>
      <xsl:apply-templates select="@di"/>
      <xsl:apply-templates select="@col"/>
      <xsl:apply-templates select="@r"/>
      <xsl:apply-templates select="@p"/>
      <xsl:apply-templates select="node()"/>
    </xgf:move>
  </xsl:template>

  <xsl:template match="xgf:modifier">
    <xsl:copy>
      <xsl:attribute name="type">
        <xsl:choose>
          <xsl:when test="@type = 'col'">
            <xsl:text>color</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@type"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="value">
        <xsl:choose>
          <xsl:when test="@val = 'b'">
            <xsl:text>black</xsl:text>
          </xsl:when>
          <xsl:when test="@val = 'w'">
            <xsl:text>white</xsl:text>
          </xsl:when>
          <xsl:when test="@val = 'g'">
            <xsl:text>gray</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@val"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xgf:ip">
    <xgf:interpolate>
      <xsl:apply-templates select="@round"/>
      <xsl:apply-templates select="@compile-if"/>
      <xsl:apply-templates select="@r"/>
      <xsl:apply-templates select="@p"/>
      <xsl:apply-templates select="node()"/>
    </xgf:interpolate>
  </xsl:template>

  <xsl:template match="xgf:sh">
    <xgf:shift>
      <xsl:apply-templates select="@round"/>
      <xsl:apply-templates select="@compile-if"/>
      <xsl:apply-templates select="@ref-ptr"/>
      <xsl:apply-templates select="@r"/>
      <xsl:apply-templates select="@p"/>
      <xsl:apply-templates select="node()"/>
    </xgf:shift>
  </xsl:template>

  <xsl:template match="xgf:al">
    <xgf:align>
      <xsl:apply-templates select="@compile-if"/>
      <xsl:apply-templates select="@r"/>
      <xsl:apply-templates select="@p"/>
      <xsl:apply-templates select="node()"/>
    </xgf:align>
  </xsl:template>

  <xsl:template match="xgf:srp">
    <xsl:copy>
      <xsl:apply-templates select="@whichpointer"/>
      <xsl:apply-templates select="@p"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xgf:set">
    <xsl:copy>
      <xsl:apply-templates select="@ref"/>
      <xsl:apply-templates select="@nm"/>
      <xsl:apply-templates select="@p"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xgf:range">
    <xsl:copy>
      <xsl:apply-templates select="@nm"/>
      <xsl:apply-templates select="@ref"/>
      <xsl:apply-templates select="@p"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xgf:callf">
    <xgf:call-function>
      <xsl:apply-templates select="@nm"/>
      <xsl:apply-templates select="@result-to"/>
      <xsl:apply-templates select="node()"/>
    </xgf:call-function>
  </xsl:template>

  <xsl:template match="xgf:callg">
    <xgf:call-glyph>
      <xsl:apply-templates select="@pnm"/>
      <xsl:apply-templates select="node()"/>
    </xgf:call-glyph>
  </xsl:template>

  <xsl:template match="xgf:callm/text() | xgf:callf/text()
    | xgf:callg/text() | xgf:pmset/text()">
    <xsl:variable name="s" select="normalize-space(.)"/>
    <xsl:if test="string-length($s) &gt; 0">
      <xsl:call-template name="make-params">
        <xsl:with-param name="s" select="$s"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xgf:callm">
    <xgf:call-macro>
      <xsl:apply-templates select="@nm"/>
      <xsl:apply-templates select="node()"/>
    </xgf:call-macro>
  </xsl:template>

  <xsl:template match="xgf:callp">
    <xgf:call-param>
      <xsl:apply-templates select="@nm"/>
      <xsl:apply-templates select="node()"/>
    </xgf:call-param>
  </xsl:template>

  <xsl:template match="xgf:cn">
    <xgf:constant>
      <xsl:apply-templates select="@nm"/>
      <xsl:apply-templates select="@val"/>
      <xsl:apply-templates select="@coord"/>
      <xsl:apply-templates select="node()"/>
    </xgf:constant>
  </xsl:template>

  <xsl:template match="xgf:cv">
    <xgf:control-value>
      <xsl:apply-templates select="@index"/>
      <xsl:apply-templates select="@nm"/>
      <xsl:apply-templates select="@val"/>
      <xsl:apply-templates select="@col"/>
      <xsl:apply-templates select="node()"/>
    </xgf:control-value>
  </xsl:template>

  <xsl:template match="xgf:fn">
    <xgf:function>
      <xsl:apply-templates select="@primitive"/>
      <xsl:apply-templates select="@return"/>
      <xsl:apply-templates select="@xml:id"/>
      <xsl:apply-templates select="@nm"/>
      <xsl:apply-templates select="@n"/>
      <xsl:apply-templates select="@stack-safe"/>
      <xsl:apply-templates select="node()"/>
    </xgf:function>
  </xsl:template>

  <xsl:template match="xgf:gl">
    <xgf:glyph>
      <xsl:apply-templates select="@xml:id"/>
      <xsl:apply-templates select="@init-graphics"/>
      <xsl:apply-templates select="@pnm"/>
      <xsl:apply-templates select="@assume-y"/>
      <xsl:apply-templates select="@compact"/>
      <xsl:apply-templates select="@xoffset"/>
      <xsl:apply-templates select="@yoffset"/>
      <xsl:apply-templates select="node()"/>
    </xgf:glyph>
  </xsl:template>

  <xsl:template match="xgf:iup">
    <xgf:interpolate-untouched-points>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:interpolate-untouched-points>
  </xsl:template>

  <xsl:template match="xgf:mo">
    <xgf:macro>
      <xsl:apply-templates select="@nm"/>
      <xsl:apply-templates select="@xml:id"/>
      <xsl:apply-templates select="node()"/>
    </xgf:macro>
  </xsl:template>

  <xsl:template match="xgf:pmset">
    <xgf:param-set>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="node()"/>
    </xgf:param-set>
  </xsl:template>

  <xsl:template match="xgf:prep">
    <xgf:pre-program>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:pre-program>
  </xsl:template>

  <xsl:template match="xgf:ref">
    <xgf:reference>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:reference>
  </xsl:template>

  <xsl:template match="xgf:setcv">
    <xgf:set-control-value>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:set-control-value>
  </xsl:template>

  <xsl:template match="xgf:wcv">
    <xgf:with-control-value>
      <xsl:apply-templates select="@unit"/>
      <xsl:apply-templates select="@nm"/>
      <xsl:apply-templates select="@val"/>
      <xsl:apply-templates select="node()"/>
    </xgf:with-control-value>
  </xsl:template>

  <xsl:template match="xgf:setvs">
    <xgf:set-vectors>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:set-vectors>
  </xsl:template>

  <xsl:template match="xgf:wvs">
    <xgf:with-vectors>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:with-vectors>
  </xsl:template>

  <xsl:template match="xgf:var">
    <xgf:variable>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:variable>
  </xsl:template>

  <xsl:template match="xgf:wpm">
    <xgf:with-param>
      <xsl:apply-templates select="@nm"/>
      <xsl:apply-templates select="@val"/>
      <xsl:apply-templates select="node()"/>
    </xgf:with-param>
  </xsl:template>

  <xsl:template match="xgf:pm">
    <xgf:param>
      <xsl:apply-templates select="@* | node()"/>
    </xgf:param>
  </xsl:template>

</xsl:stylesheet>
