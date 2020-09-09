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
  This file converts from old or expanded syntax to the
  new or compact syntax.
-->

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

  <xsl:template match="@reference-ptr">
   <xsl:attribute name="ref-ptr">
      <xsl:value-of select="."/>
   </xsl:attribute>
  </xsl:template>

  <xsl:template match="@type">
    <xsl:variable name="currentval" select="."/>
    <xsl:attribute name="type">
      <xsl:choose>
        <xsl:when test="$currentval = 'color'">
          <xsl:text>col</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
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

  <xsl:template match="@value" mode="mod">
    <xsl:variable name="thisval" select="."/>
    <xsl:attribute name="val">
      <xsl:choose>
        <xsl:when test="$thisval = 'black'">
          <xsl:text>b</xsl:text>
        </xsl:when>
        <xsl:when test="$thisval = 'white'">
          <xsl:text>w</xsl:text>
        </xsl:when>
        <xsl:when test="$thisval = 'gray'">
          <xsl:text>g</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$thisval"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="xgf:modifier">
    <xgf:modifier>
      <xsl:apply-templates select="@type"/>
      <xsl:apply-templates select="@value" mode="mod"/>
    </xgf:modifier>
  </xsl:template>

  <xsl:template name="make-point-list">
    <xsl:param name="pset"/>
    <xsl:for-each select="$pset">
      <xsl:variable name="p-att"
                    select="normalize-space(./@num)"/>
      <xsl:choose>
        <xsl:when test="contains($p-att,' ')">
          <xsl:value-of select="concat('(',$p-att,')')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$p-att"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="position() != last()">
        <xsl:text> </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="xgf:move">
    <xgf:mv>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="xgf:reference">
        <xsl:attribute name="r">
          <xsl:call-template name="make-point-list">
            <xsl:with-param name="pset" select="xgf:reference/xgf:point"/>
          </xsl:call-template>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="xgf:point">
        <xsl:attribute name="p">
          <xsl:call-template name="make-point-list">
            <xsl:with-param name="pset" select="xgf:point"/>
          </xsl:call-template>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="xgf:delta | xgf:align |
                                   xgf:interpolate | xgf:shift | xgf:move"/>
    </xgf:mv>
  </xsl:template>

  <xsl:template match="xgf:interpolate">
    <xgf:ip>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="xgf:reference">
        <xsl:attribute name="r">
          <xsl:call-template name="make-point-list">
            <xsl:with-param name="pset" select="xgf:reference/xgf:point"/>
          </xsl:call-template>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="xgf:point">
        <xsl:attribute name="p">
          <xsl:call-template name="make-point-list">
            <xsl:with-param name="pset" select="xgf:point"/>
          </xsl:call-template>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="xgf:range | xgf:set"/>
    </xgf:ip>
  </xsl:template>

  <xsl:template match="xgf:shift">
    <xgf:sh>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="xgf:reference">
        <xsl:attribute name="r">
          <xsl:call-template name="make-point-list">
            <xsl:with-param name="pset" select="xgf:reference/xgf:point"/>
          </xsl:call-template>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="xgf:point">
        <xsl:attribute name="p">
          <xsl:call-template name="make-point-list">
            <xsl:with-param name="pset" select="xgf:point"/>
          </xsl:call-template>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="xgf:range | xgf:set | xgf:contour |
                                   xgf:zone"/>
    </xgf:sh>
  </xsl:template>

  <xsl:template match="xgf:set">
    <xgf:set>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="xgf:point">
        <xsl:attribute name="p">
          <xsl:call-template name="make-point-list">
            <xsl:with-param name="pset" select="xgf:point"/>
          </xsl:call-template>
        </xsl:attribute>
      </xsl:if>
    </xgf:set>
  </xsl:template>

  <xsl:template match="xgf:align">
    <xgf:al>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="xgf:reference">
        <xsl:attribute name="r">
          <xsl:call-template name="make-point-list">
            <xsl:with-param name="pset" select="xgf:reference/xgf:point"/>
          </xsl:call-template>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="xgf:point">
        <xsl:attribute name="p">
          <xsl:call-template name="make-point-list">
            <xsl:with-param name="pset" select="xgf:point"/>
          </xsl:call-template>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="xgf:range | xgf:set"/>
    </xgf:al>
  </xsl:template>

  <xsl:template match="xgf:srp">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xgf:call-function">
    <xgf:callf>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="xgf:with-param and (count(xgf:with-param) =
                        count(xgf:with-param/@value))">
          <xsl:call-template name="make-param-list">
            <xsl:with-param name="pset" select="xgf:with-param"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="xgf:with-param | xgf:param-set"/>
        </xsl:otherwise>
      </xsl:choose>
    </xgf:callf>
  </xsl:template>

  <xsl:template name="make-param-list">
    <xsl:param name="pset"/>
    <xsl:for-each select="$pset">
      <xsl:variable name="thisval"
                    select="normalize-space(./@value)"/>
      <xsl:value-of select="normalize-space(./@name)"/>
      <xsl:text>: </xsl:text>
      <xsl:choose>
        <xsl:when test="contains($thisval,' ')">
          <xsl:text>(</xsl:text>
          <xsl:value-of select="$thisval"/>
          <xsl:text>)</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$thisval"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="position() != last()">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="xgf:call-glyph">
    <xgf:callg>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="xgf:with-param and (count(xgf:with-param) =
                        count(xgf:with-param/@value))">
          <xsl:call-template name="make-param-list">
            <xsl:with-param name="pset" select="xgf:with-param"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="xgf:with-param | xgf:param-set"/>
        </xsl:otherwise>
      </xsl:choose>
    </xgf:callg>
  </xsl:template>

  <xsl:template match="xgf:call-macro">
    <xgf:callm>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="xgf:with-param and (count(xgf:with-param) =
                        count(xgf:with-param/@value))">
          <xsl:call-template name="make-param-list">
            <xsl:with-param name="pset" select="xgf:with-param"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="xgf:with-param | xgf:param-set"/>
        </xsl:otherwise>
      </xsl:choose>
    </xgf:callm>
  </xsl:template>

  <xsl:template match="xgf:param-set">
    <xgf:pmset>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="xgf:with-param and (count(xgf:with-param) =
                        count(xgf:with-param/@value))">
          <xsl:call-template name="make-param-list">
            <xsl:with-param name="pset" select="xgf:with-param"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="xgf:with-param"/>
        </xsl:otherwise>
      </xsl:choose>
    </xgf:pmset>
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
