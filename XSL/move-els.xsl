<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"
                version="1.0">

<!--
  This file is part of xgridfit, version 3.
  Licensed under the Apache License, Version 2.0.
  Copyright (c) 2006-20 by Peter S. Baker
-->

  <!--
    If the color default is "auto," the choice is between black and
    gray. If we have a reference element or the parent of this move
    element is another move, the color is black. It's not a great
    guess, but it should serve in the majority of cases.
  -->
  <xsl:template name="process-color-param">
    <xsl:choose>
      <xsl:when test="$color = 'auto'">
        <xsl:choose>
<!--
  At present this template is only called from xgf:move. If it is ever
  called from elsewhere the test should be

          <xsl:when test="self::xgf:move
                  and (./xgf:reference or ./parent::xgf:move)">
-->
          <xsl:when test="./xgf:reference or ./parent::xgf:move">
            <xsl:text>black</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>gray</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$color"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xgf:mirp">
    <xsl:param name="mp-container"/>
    <xsl:variable name="local-color">
      <xsl:choose>
        <xsl:when test="@color">
          <xsl:value-of select="@color"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$color"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="check-for-move-points"/>
    <xsl:call-template name="do-mirp">
      <xsl:with-param name="distance" select="@distance"/>
      <xsl:with-param name="round" select="@round"/>
      <xsl:with-param name="cut-in" select="boolean(not(@cut-in) or @cut-in = 'yes')"/>
      <xsl:with-param name="min-distance"
                      select="boolean(not(@min-distance) or @min-distance = 'yes')"/>
      <xsl:with-param name="set-rp0" select="boolean(@set-rp0 = 'yes')"/>
      <xsl:with-param name="l-color" select="$local-color"/>
      <xsl:with-param name="move-pt" select="xgf:point"/>
      <xsl:with-param name="ref-pt" select="xgf:reference/xgf:point"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:miap">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="check-for-move-points"/>
    <xsl:call-template name="do-miap">
      <xsl:with-param name="distance" select="@distance"/>
      <xsl:with-param name="round" select="@round"/>
      <xsl:with-param name="cut-in" select="boolean(not(@cut-in) or @cut-in = 'yes')"/>
      <xsl:with-param name="move-pt" select="xgf:point[1]"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:mdrp">
    <xsl:param name="mp-container"/>
    <xsl:variable name="local-color">
      <xsl:choose>
        <xsl:when test="@color">
          <xsl:value-of select="@color"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$color"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="check-for-move-points"/>
    <xsl:call-template name="do-mdrp">
      <xsl:with-param name="round" select="@round"/>
      <xsl:with-param name="min-distance"
                      select="boolean(not(@min-distance) or @min-distance = 'yes')"/>
      <xsl:with-param name="set-rp0" select="boolean(@set-rp0 = 'yes')"/>
      <xsl:with-param name="l-color" select="$local-color"/>
      <xsl:with-param name="move-pt" select="xgf:point"/>
      <xsl:with-param name="ref-pt" select="xgf:reference/xgf:point"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:mdap">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="check-for-move-points"/>
    <xsl:call-template name="do-mdap">
      <xsl:with-param name="round" select="@round"/>
      <xsl:with-param name="move-pt" select="xgf:point[1]"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:align">
    <xsl:param name="phantom-ref-pt"/>
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="comp-if">
      <xsl:call-template name="compile-if-test">
        <xsl:with-param name="test" select="@compile-if"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="number($comp-if)">
      <xsl:call-template name="check-for-move-points"/>
      <xsl:call-template name="do-alignrp">
        <xsl:with-param name="move-pts" select="xgf:point"/>
        <xsl:with-param name="ref-pt" select="xgf:reference/xgf:point"/>
        <xsl:with-param name="phantom-ref-pt" select="$phantom-ref-pt"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
      <xsl:apply-templates select="xgf:range|xgf:set" mode="push-me">
        <xsl:with-param name="with-cmd" select="'ALIGNRP'"/>
        <xsl:with-param name="rp-a-o">
          <xsl:if test="xgf:reference/xgf:point">
            <xsl:value-of select="xgf:reference/xgf:point/@num"/>
          </xsl:if>
        </xsl:with-param>
        <xsl:with-param name="rp-a">
          <xsl:if test="$phantom-ref-pt">
            <xsl:value-of select="$phantom-ref-pt/@num"/>
          </xsl:if>
        </xsl:with-param>
        <xsl:with-param name="zp" select="'1'"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:apply-templates>
    </xsl:if>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:shift">
    <xsl:param name="rptr"/>
    <xsl:param name="phantom-ref-pt"/>
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="comp-if">
      <xsl:call-template name="compile-if-test">
        <xsl:with-param name="test" select="@compile-if"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="assume-y">
      <xsl:choose>
        <xsl:when test="ancestor::xgf:glyph/@assume-y">
          <xsl:value-of select="ancestor::xgf:glyph/@assume-y"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$assume-always-y"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="number($comp-if)">
      <!-- First establish which reference pointer to use: the default
           is 1. -->
      <xsl:variable name="ref-ptr">
        <xsl:choose>
          <xsl:when test="$rptr">
            <xsl:value-of select="$rptr"/>
          </xsl:when>
          <xsl:when test="@reference-ptr">
            <xsl:value-of select="@reference-ptr"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="1"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="not($ref-ptr='1' or $ref-ptr='2')">
        <xsl:call-template name="error-message">
          <xsl:with-param name="msg">
            <xsl:text>Illegal reference-ptr attribute in shift element: </xsl:text>
            <xsl:value-of select="$ref-ptr"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <!-- If there is a reference point, set the reference pointer
           and, if applicable, the appropriate zone pointer. -->
      <xsl:if test="xgf:reference/xgf:point">
        <xsl:call-template name="push-point">
          <xsl:with-param name="pt" select="xgf:reference/xgf:point"/>
          <xsl:with-param name="zp" select="string(number($ref-ptr)-1)"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="concat('SRP', $ref-ptr)"/>
        </xsl:call-template>
      </xsl:if>
      <!-- If points are present, execute SHP once for all of them. -->
      <xsl:if test="xgf:point">
        <xsl:call-template name="push-points">
          <xsl:with-param name="pts" select="xgf:point"/>
          <xsl:with-param name="zp" select="'2'"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
        <xsl:if test="count(xgf:point) &gt; 1">
          <xsl:call-template name="number-command">
            <xsl:with-param name="num" select="count(xgf:point)"/>
            <xsl:with-param name="cmd" select="'SLOOP'"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'SHP'"/>
          <xsl:with-param name="modifier">
            <xsl:call-template name="ref-ptr-bit">
              <xsl:with-param name="ref-ptr" select="$ref-ptr"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:if test="xgf:point[1]/@zone">
          <xsl:call-template name="set-zone-pointer">
            <xsl:with-param name="z" select="'glyph'"/>
            <xsl:with-param name="zp" select="'2'"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      <!-- If any ranges or sets are present, execute SHP for each of them. -->
      <xsl:apply-templates select="xgf:range|xgf:set" mode="push-me">
        <xsl:with-param name="with-cmd" select="'SHP'"/>
        <xsl:with-param name="ref-ptr" select="$ref-ptr"/>
        <xsl:with-param name="zp" select="'2'"/>
        <xsl:with-param name="rp-a-o">
          <xsl:if test="xgf:reference/xgf:point">
            <xsl:value-of select="xgf:reference/xgf:point/@num"/>
          </xsl:if>
        </xsl:with-param>
        <xsl:with-param name="rp-a">
          <xsl:if test="$phantom-ref-pt">
            <xsl:value-of select="$phantom-ref-pt/@num"/>
          </xsl:if>
        </xsl:with-param>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:apply-templates>
      <!-- If any contours are present, execute SHC for each of
           them. -->
      <xsl:for-each select="xgf:contour">
        <!--
            There is no programmatic difference between pushing a
            point and pushing a contour; so we'll just use the
            "push-point" template to do this.
        -->
        <xsl:call-template name="push-point">
          <xsl:with-param name="pt" select="."/>
          <xsl:with-param name="zp" select="'2'"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'SHC'"/>
          <xsl:with-param name="modifier">
            <xsl:call-template name="ref-ptr-bit">
              <xsl:with-param name="ref-ptr" select="$ref-ptr"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:if test="./@zone">
          <xsl:call-template name="set-zone-pointer">
            <xsl:with-param name="z" select="'glyph'"/>
            <xsl:with-param name="zp" select="'2'"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:for-each>
      <!-- And finally shift any zones. -->
      <xsl:for-each select="xgf:zone">
        <xsl:choose>
          <xsl:when test="./@zone='glyph'">
            <xsl:call-template name="push-num">
              <xsl:with-param name="num" select="'1'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="./@zone='twilight'">
            <xsl:call-template name="push-num">
              <xsl:with-param name="num" select="'0'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="error-message">
              <xsl:with-param name="msg">
                <xsl:text>Zone must be either "glyph" or "twilight."</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'SHZ'"/>
          <xsl:with-param name="modifier">
            <xsl:call-template name="ref-ptr-bit">
              <xsl:with-param name="ref-ptr" select="$ref-ptr"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:if test="xgf:point and @round != 'no'">
        <xsl:choose>
          <xsl:when test="$assume-y = 'yes'">
            <xsl:call-template name="round-always-y">
              <xsl:with-param name="pts" select="xgf:point"/>
              <xsl:with-param name="mp-container" select="$mp-container"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="round-points-with-scfs">
              <xsl:with-param name="pts" select="xgf:point"/>
              <xsl:with-param name="round" select="@round"/>
              <xsl:with-param name="mp-container" select="$mp-container"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:call-template name="set-zone-pointers-to-glyph"/>
    </xsl:if>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:interpolate">
    <xsl:param name="phantom-ref-pt-a"/>
    <xsl:param name="phantom-ref-pt-b"/>
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="comp-if">
      <xsl:call-template name="compile-if-test">
        <xsl:with-param name="test" select="@compile-if"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="assume-y">
      <xsl:choose>
        <xsl:when test="ancestor::xgf:glyph/@assume-y">
          <xsl:value-of select="ancestor::xgf:glyph/@assume-y"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$assume-always-y"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="number($comp-if)">
      <xsl:call-template name="check-for-move-points"/>
      <xsl:if test="count(xgf:reference/xgf:point) = 1">
        <xsl:call-template name="error-message">
          <xsl:with-param name="msg">
            <xsl:text>There must be two "relative-to" points, if any, in an</xsl:text>
            <xsl:text>interpolate instruction.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="count(xgf:reference/xgf:point) &gt;= 2">
        <xsl:call-template name="push-point">
          <xsl:with-param name="pt" select="xgf:reference/xgf:point[1]"/>
          <xsl:with-param name="zp" select="'0'"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'SRP1'"/>
        </xsl:call-template>
        <xsl:call-template name="push-point">
          <xsl:with-param name="pt" select="xgf:reference/xgf:point[2]"/>
          <xsl:with-param name="zp" select="'1'"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'SRP2'"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="xgf:point">
        <xsl:call-template name="push-points">
          <xsl:with-param name="pts" select="xgf:point"/>
          <xsl:with-param name="zp" select="'2'"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
        <xsl:if test="count(xgf:point) &gt; 1">
          <xsl:call-template name="number-command">
            <xsl:with-param name="num" select="count(xgf:point)"/>
            <xsl:with-param name="cmd" select="'SLOOP'"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'IP'"/>
        </xsl:call-template>
        <xsl:if test="xgf:point[1]/@zone">
          <xsl:call-template name="set-zone-pointer">
            <xsl:with-param name="z" select="'glyph'"/>
            <xsl:with-param name="zp" select="'2'"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates select="xgf:range|xgf:set" mode="push-me">
        <xsl:with-param name="with-cmd" select="'IP'"/>
        <xsl:with-param name="rp-a-o">
          <xsl:if test="xgf:reference/xgf:point[1]">
            <xsl:value-of select="xgf:reference/xgf:point[1]/@num"/>
          </xsl:if>
        </xsl:with-param>
        <xsl:with-param name="rp-a">
          <xsl:if test="$phantom-ref-pt-a">
            <xsl:value-of select="$phantom-ref-pt-a/@num"/>
          </xsl:if>
        </xsl:with-param>
        <xsl:with-param name="rp-b-o">
          <xsl:if test="xgf:reference/xgf:point[2]">
            <xsl:value-of select="xgf:reference/xgf:point[2]/@num"/>
          </xsl:if>
        </xsl:with-param>
        <xsl:with-param name="rp-b">
          <xsl:if test="$phantom-ref-pt-b">
            <xsl:value-of select="$phantom-ref-pt-b/@num"/>
          </xsl:if>
        </xsl:with-param>
        <xsl:with-param name="zp" select="'2'"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:apply-templates>
      <xsl:if test="xgf:point and @round != 'no'">
        <xsl:choose>
          <xsl:when test="$assume-y = 'yes'">
            <xsl:call-template name="round-always-y">
              <xsl:with-param name="pts" select="xgf:point"/>
              <xsl:with-param name="mp-container" select="$mp-container"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="round-points-with-scfs">
              <xsl:with-param name="pts" select="xgf:point"/>
              <xsl:with-param name="round" select="@round"/>
              <xsl:with-param name="mp-container" select="$mp-container"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:call-template name="set-zone-pointers-to-glyph"/>
    </xsl:if>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:flip-on | xgf:flip-off">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:choose>
      <xsl:when test="xgf:range">
        <xsl:apply-templates select="xgf:range" mode="push-me">
          <xsl:with-param name="with-cmd">
            <xsl:choose>
              <xsl:when test="local-name() = 'flip-on'">
                <xsl:value-of select="'FLIPRGON'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'FLIPRGOFF'"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="zp" select="'0'"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:interpolate-untouched-points">
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="do-iup">
      <xsl:with-param name="axis" select="@axis"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:move-point-to-intersection">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="check-for-move-points"/>
    <xsl:call-template name="do-isect">
      <xsl:with-param name="move-pt" select="xgf:point"/>
      <xsl:with-param name="line-a" select="xgf:line[1]"/>
      <xsl:with-param name="line-b" select="xgf:line[2]"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:shift-absolute">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="check-for-move-points"/>
    <xsl:call-template name="do-shpix">
      <xsl:with-param name="pts" select="xgf:point"/>
      <xsl:with-param name="val" select="@pixel-distance"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:apply-templates select="xgf:range|xgf:set" mode="push-me">
      <xsl:with-param name="with-cmd" select="'SHPIX'"/>
      <xsl:with-param name="zp" select="'2'"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:apply-templates>
    <xsl:call-template name="set-zone-pointers-to-glyph"/>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:toggle-points">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="check-for-move-points"/>
    <xsl:call-template name="do-flippt">
      <xsl:with-param name="pts" select="xgf:point"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:apply-templates select="xgf:range|xgf:set" mode="push-me">
      <xsl:with-param name="with-cmd" select="'FLIPPT'"/>
      <xsl:with-param name="zp" select="'0'"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:apply-templates>
    <xsl:call-template name="set-zone-pointers-to-glyph"/>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:align-midway">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="check-for-move-points"/>
    <xsl:call-template name="do-alignpts">
      <xsl:with-param name="pt-one" select="xgf:point[1]"/>
      <xsl:with-param name="pt-two" select="xgf:point[2]"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:set-coordinate">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="check-for-move-points"/>
    <xsl:call-template name="do-set-coordinate">
      <xsl:with-param name="pt" select="xgf:point[1]"/>
      <xsl:with-param name="coord" select="@coordinate"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:untouch">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="check-for-move-points"/>
    <xsl:call-template name="push-point">
      <xsl:with-param name="pt" select="xgf:point[1]"/>
      <xsl:with-param name="zp" select="'0'"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'UTP'"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:move">
    <xsl:param name="mp-container"/>
    <xsl:variable name="local-dist">
      <xsl:choose>
        <xsl:when test="@distance">
          <xsl:choose>
            <xsl:when test="key('alias-index',@distance)">
              <xsl:value-of select="key('alias-index',@distance)/@target"/>
            </xsl:when>
            <xsl:when test="key('cvt',@distance)">
              <xsl:value-of select="@distance"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="false()"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="false()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!--
      Here are the priorities: if there is a color attribute
      on this move element, use that. If not, check for a color
      attribute on the control-value (dist) for this move, if any.
      Failing that, use the default, which may be black, white,
      gray or auto. This default is interpreted by the
      process-color-param template (the only complication being
      "auto")
    -->
    <xsl:variable name="local-color">
      <xsl:choose>
        <xsl:when test="@color">
          <xsl:value-of select="@color"/>
        </xsl:when>
        <xsl:when test="$local-dist and key('cvt',$local-dist)/@color">
          <xsl:value-of select="key('cvt',$local-dist)/@color"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="process-color-param"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- A little optimization: because a "move" instruction always
         sets RP0 to the "move" point after the move, we check to see
          1. if the preceding instruction was a "move" instruction;
          2. if the "move" point in that instruction was the same as
              the "reference" point in this one.
         If both of these conditions are true, we can suppress setting
         the RP0 before the move in MIRP and MDRP instructions. -->
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="comp-if">
      <xsl:call-template name="compile-if-test">
        <xsl:with-param name="test" select="@compile-if"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="number($comp-if)">
      <xsl:variable name="set-min-dist-bit" select="not(@min-distance = 'no')"/>
      <xsl:variable name="set-min-dist-val"
                    select="$set-min-dist-bit and @min-distance != 'yes'"/>
      <xsl:variable name="set-cut-in-bit" select="not(@cut-in = 'no')"/>
      <xsl:variable name="set-cut-in-val" select="$set-cut-in-bit and @cut-in != 'yes'"/>
      <xsl:if test="$set-cut-in-val">
        <xsl:call-template name="number-command">
          <xsl:with-param name="num">
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-control-value-cut-in"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="cmd" select="'RS'"/>
        </xsl:call-template>
        <xsl:call-template name="set-simple-graphics-var">
          <xsl:with-param name="value" select="@cut-in"/>
          <xsl:with-param name="loc">
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-control-value-cut-in"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="cmd" select="'SCVTCI'"/>
          <xsl:with-param name="may-record-default" select="false()"/>
          <xsl:with-param name="stack-source-permitted" select="false()"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="$set-min-dist-val">
        <xsl:call-template name="number-command">
          <xsl:with-param name="num">
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-minimum-distance"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="cmd" select="'RS'"/>
        </xsl:call-template>
        <xsl:call-template name="set-simple-graphics-var">
          <xsl:with-param name="value" select="@min-distance"/>
          <xsl:with-param name="loc">
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-minimum-distance"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="cmd" select="'SMD'"/>
          <xsl:with-param name="may-record-default" select="false()"/>
          <xsl:with-param name="stack-source-permitted" select="false()"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:variable name="rnd">
        <xsl:choose>
          <xsl:when test="@round">
            <xsl:value-of select="@round"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>yes</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="prev-el-point">
        <xsl:choose>
          <xsl:when test="local-name(preceding-sibling::*[1]) = 'move'">
            <xsl:call-template name="expression-with-offset">
              <xsl:with-param name="val"
                              select="preceding-sibling::xgf:move[1]/xgf:point/@num"/>
              <xsl:with-param name="permitted" select="'1nf'"/>
              <xsl:with-param name="mp-container" select="$mp-container"/>
              <xsl:with-param name="called-from" select="'move-1'"/>
              <xsl:with-param name="to-stack" select="false()"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>NaN</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="this-el-point">
        <xsl:choose>
          <xsl:when test="xgf:reference/xgf:point">
            <xsl:call-template name="expression-with-offset">
              <xsl:with-param name="val" select="xgf:reference/xgf:point/@num"/>
              <xsl:with-param name="permitted" select="'1nf'"/>
              <xsl:with-param name="mp-container" select="$mp-container"/>
              <xsl:with-param name="called-from" select="'move-2'"/>
              <xsl:with-param name="to-stack" select="false()"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>NaN</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="nested" select="boolean(ancestor::xgf:move
                                          or ancestor::xgf:move)"/>
      <xsl:variable name="suppress-set-rp0"
                    select="boolean($prev-el-point != 'NaN' and
                            number($prev-el-point) = number($this-el-point))"/>
      <xsl:variable name="set-rp0-after"
                    select="not($nested) or boolean(xgf:move) or
                            boolean(xgf:align)"/>
      <xsl:call-template name="check-for-move-points"/>
      <!--
          If this is a nested move and it's going to do anything to
          change RP0, then we've got to save the point of the parent
          move on the stack so that we can restore it to RP0
          afterwards.
      -->
      <xsl:variable name="save-rp0-point-on-stack"
                    select="$nested and ($set-rp0-after or xgf:reference)"/>
      <xsl:if test="$save-rp0-point-on-stack">
        <xsl:call-template name="push-point">
          <xsl:with-param name="pt" select="../xgf:point"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="boolean(xgf:reference/xgf:point) or $nested">
          <xsl:variable name="local-suppress-set-rp0"
                        select="$suppress-set-rp0 or
                                ($nested and not(xgf:reference/xgf:point))"/>
          <xsl:choose>
            <xsl:when test="@distance">
              <xsl:call-template name="do-mirp">
                <xsl:with-param name="distance" select="@distance"/>
                <xsl:with-param name="round" select="$rnd"/>
                <xsl:with-param name="cut-in" select="$set-cut-in-bit"/>
                <xsl:with-param name="min-distance" select="$set-min-dist-bit"/>
                <xsl:with-param name="set-rp0" select="$set-rp0-after"/>
                <xsl:with-param name="l-color" select="$local-color"/>
                <xsl:with-param name="move-pt" select="xgf:point"/>
                <xsl:with-param name="ref-pt" select="xgf:reference/xgf:point"/>
                <xsl:with-param name="suppress-set-rp0" select="$local-suppress-set-rp0"/>
                <xsl:with-param name="mp-container" select="$mp-container"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="@pixel-distance">
              <xsl:if test="not($local-suppress-set-rp0)">
                <xsl:call-template name="push-point">
                  <xsl:with-param name="pt" select="xgf:reference/xgf:point"/>
                  <xsl:with-param name="zp" select="'0'"/>
                  <xsl:with-param name="mp-container" select="$mp-container"/>
                </xsl:call-template>
                <xsl:call-template name="simple-command">
                  <xsl:with-param name="cmd" select="'SRP0'"/>
                </xsl:call-template>
              </xsl:if>
              <xsl:call-template name="push-point">
                <xsl:with-param name="pt" select="xgf:point"/>
                <xsl:with-param name="zp" select="'1'"/>
                <xsl:with-param name="mp-container" select="$mp-container"/>
              </xsl:call-template>
              <xsl:call-template name="expression">
                <xsl:with-param name="val" select="@pixel-distance"/>
                <xsl:with-param name="cvt-mode" select="'value'"/>
                <xsl:with-param name="permitted" select="'1xfvnc'"/>
                <xsl:with-param name="mp-container" select="$mp-container"/>
                <xsl:with-param name="to-stack" select="true()"/>
              </xsl:call-template>
              <xsl:call-template name="round-stack-top">
                <xsl:with-param name="rnd" select="$rnd"/>
                <xsl:with-param name="col" select="$local-color"/>
                <xsl:with-param name="mp-container" select="$mp-container"/>
              </xsl:call-template>
              <xsl:call-template name="simple-command">
                <xsl:with-param name="cmd" select="'MSIRP'"/>
                <xsl:with-param name="modifier">
                  <xsl:call-template name="rp0-bit">
                    <xsl:with-param name="set-rp0" select="$set-rp0-after"/>
                  </xsl:call-template>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="do-mdrp">
                <xsl:with-param name="round" select="$rnd"/>
                <xsl:with-param name="min-distance" select="$set-min-dist-bit"/>
                <xsl:with-param name="set-rp0" select="$set-rp0-after"/>
                <xsl:with-param name="l-color" select="$local-color"/>
                <xsl:with-param name="move-pt" select="xgf:point"/>
                <xsl:with-param name="ref-pt" select="xgf:reference/xgf:point"/>
                <xsl:with-param name="suppress-set-rp0" select="$local-suppress-set-rp0"/>
                <xsl:with-param name="mp-container" select="$mp-container"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="@distance">
              <xsl:call-template name="do-miap">
                <xsl:with-param name="distance" select="@distance"/>
                <xsl:with-param name="round" select="$rnd"/>
                <xsl:with-param name="cut-in" select="$set-cut-in-bit"/>
                <xsl:with-param name="move-pt" select="xgf:point"/>
                <xsl:with-param name="mp-container" select="$mp-container"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="@pixel-distance">
              <xsl:call-template name="push-point">
                <xsl:with-param name="pt" select="xgf:point[1]"/>
                <xsl:with-param name="zp" select="'2'"/>
                <xsl:with-param name="mp-container" select="$mp-container"/>
              </xsl:call-template>
              <xsl:call-template name="simple-command">
                <xsl:with-param name="cmd" select="'DUP'"/>
              </xsl:call-template>
              <xsl:call-template name="simple-command">
                <xsl:with-param name="cmd" select="'SRP1'"/>
              </xsl:call-template>
              <xsl:call-template name="expression">
                <xsl:with-param name="val" select="@pixel-distance"/>
                <xsl:with-param name="cvt-mode" select="'value'"/>
                <xsl:with-param name="permitted" select="'1xfvnc'"/>
                <xsl:with-param name="mp-container" select="$mp-container"/>
                <xsl:with-param name="to-stack" select="true()"/>
              </xsl:call-template>
              <xsl:call-template name="round-stack-top">
                <xsl:with-param name="rnd" select="$rnd"/>
                <xsl:with-param name="col" select="$local-color"/>
                <xsl:with-param name="mp-container" select="$mp-container"/>
              </xsl:call-template>
              <xsl:call-template name="simple-command">
                <xsl:with-param name="cmd" select="'SCFS'"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="do-mdap">
                <xsl:with-param name="round" select="$rnd"/>
                <xsl:with-param name="move-pt" select="xgf:point"/>
                <xsl:with-param name="mp-container" select="$mp-container"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="xgf:delta[not(preceding-sibling::xgf:align) and
                                   not(preceding-sibling::xgf:interpolate) and
                                   not(preceding-sibling::xgf:shift) and
                                   not(preceding-sibling::xgf:move)]">
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="xgf:align">
        <xsl:with-param name="phantom-ref-pt" select="xgf:point"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:apply-templates>
      <!-- interpolate will only work if we can identify a reference
           point.  That's because MIRP, MDRP and MSIRP set up the
           reference points properly for interpolate, but MIAP and MDAP
           do not. -->
      <xsl:if test="xgf:interpolate and
                    ($nested or boolean(xgf:reference/xgf:point))">
        <xsl:choose>
          <xsl:when test="xgf:reference/xgf:point">
            <xsl:apply-templates select="xgf:interpolate">
              <xsl:with-param name="phantom-ref-pt-a"
                              select="xgf:reference/xgf:point"/>
              <xsl:with-param name="phantom-ref-pt-b" select="xgf:point"/>
              <xsl:with-param name="mp-container" select="$mp-container"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="xgf:interpolate">
              <xsl:with-param name="phantom-ref-pt-a"
                              select="ancestor::xgf:move/xgf:point"/>
              <xsl:with-param name="phantom-ref-pt-b" select="xgf:point"/>
              <xsl:with-param name="mp-container" select="$mp-container"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <!-- A SHP instruction should use RP2 if a reference point was
           used (MIRP or MDRP); otherwise RP1 (MIAP or MDAP). -->
      <xsl:choose>
        <xsl:when test="$nested or boolean(xgf:reference/xgf:point)">
          <xsl:apply-templates select="xgf:shift">
            <xsl:with-param name="rptr" select="2"/>
            <xsl:with-param name="phantom-ref-pt" select="xgf:point"/>
            <xsl:with-param name="mp-container" select="$mp-container"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="xgf:shift">
            <xsl:with-param name="rptr" select="1"/>
            <xsl:with-param name="phantom-ref-pt" select="xgf:point"/>
            <xsl:with-param name="mp-container" select="$mp-container"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
      <!-- A nested move element implicitly has as a reference point the
           point just moved by the parent move element (with first delta
           applied).
      -->
      <xsl:apply-templates select="xgf:move">
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="xgf:delta[preceding-sibling::xgf:align or
                                   preceding-sibling::xgf:interpolate or
                                   preceding-sibling::xgf:shift or
                                   preceding-sibling::xgf:move]">
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:apply-templates>
      <xsl:if test="$save-rp0-point-on-stack">
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'SRP0'"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="$set-min-dist-val">
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'DUP'"/>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'SMD'"/>
        </xsl:call-template>
        <xsl:call-template name="stack-top-to-storage">
          <xsl:with-param name="loc">
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-minimum-distance"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="$set-cut-in-val">
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'DUP'"/>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'SCVTCI'"/>
        </xsl:call-template>
        <xsl:call-template name="stack-top-to-storage">
          <xsl:with-param name="loc">
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-control-value-cut-in"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:diagonal-stem">
    <xsl:param name="mp-container"/>
    <xsl:variable name="local-color">
      <xsl:choose>
        <xsl:when test="@color">
          <xsl:value-of select="@color"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$color"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="set-min-dist-bit" select="not(@min-distance = 'no')"/>
    <xsl:variable name="set-min-dist-val"
                  select="$set-min-dist-bit and @min-distance != 'yes'"/>
    <xsl:if test="$set-min-dist-val">
      <xsl:call-template name="number-command">
        <xsl:with-param name="num">
          <xsl:call-template name="resolve-std-variable-loc">
            <xsl:with-param name="n" select="$var-minimum-distance"/>
          </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="cmd" select="'RS'"/>
      </xsl:call-template>
      <xsl:call-template name="set-simple-graphics-var">
        <xsl:with-param name="value" select="@min-distance"/>
        <xsl:with-param name="cmd" select="'SMD'"/>
        <xsl:with-param name="save" select="false()"/>
        <xsl:with-param name="stack-source-permitted" select="false()"/>
      </xsl:call-template>
    </xsl:if>
    <!-- Line 1 will be checked by do-set-vector. -->
    <xsl:call-template name="check-line">
      <xsl:with-param name="l" select="xgf:line[2]"/>
    </xsl:call-template>
    <xsl:variable name="rnd">
      <xsl:choose>
        <xsl:when test="@round">
          <xsl:value-of select="@round"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>yes</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="@save-vectors='yes'">
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'GPV'"/>
      </xsl:call-template>
      <xsl:if test="@freedom-vector='yes'">
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'GFV'"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
    <xsl:call-template name="do-set-vector">
      <xsl:with-param name="which-vector" select="'P'"/>
      <xsl:with-param name="line" select="xgf:line[1]"/>
      <xsl:with-param name="to-line" select="'orthogonal'"/>
      <xsl:with-param name="stack-source-permitted" select="false()"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:if test="@freedom-vector='yes'">
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'SFVTPV'"/>
      </xsl:call-template>
    </xsl:if>
    <!-- The tricky part, here and below, is to get a reference to a point out of
         a line with a ref - that is, a line element that is a reference to
         another line element. You might think it could be done via a template and
         a variable, but you end up with a useless result tree fragment. And I haven't
         (yet) managed to come up with a predicate expression that actually works. So
         here we are doing some things twice: once for a line element with a ref,
         and one for one without (i.e. with points). It's clunky, but it keeps us
         completely inside the standard and so very portable. -->
    <xsl:choose>
      <xsl:when test="xgf:line[1]/@ref">
        <xsl:call-template name="push-point">
          <!-- 4xslt sometimes fails to resolve the following XPath expression.
               I can't figure out what's wrong. No error message. Xalan, Saxon,
               libxslt work fine. -->
          <xsl:with-param name="pt"
                          select="ancestor::xgf:glyph/descendant::xgf:line[@name =
                                  current()/xgf:line[1]/@ref]/xgf:point[2]"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="push-point">
          <xsl:with-param name="pt" select="xgf:line[1]/xgf:point[2]"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SRP0'"/>
    </xsl:call-template>
    <xsl:if test="count(xgf:align) &gt;= 2">
      <xsl:apply-templates select="xgf:align[1]">
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:apply-templates>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="xgf:line[2]/@ref">
        <xsl:call-template name="do-mirp">
          <xsl:with-param name="distance" select="@distance"/>
          <xsl:with-param name="round" select="$rnd"/>
          <xsl:with-param name="cut-in"
                          select="boolean(not(@cut-in) or @cut-in = 'yes')"/>
          <xsl:with-param name="min-distance" select="$set-min-dist-bit"/>
          <xsl:with-param name="l-color" select="$local-color"/>
          <xsl:with-param name="move-pt"
                          select="ancestor::xgf:glyph/descendant::xgf:line[@name =
                                  current()/xgf:line[2]/@ref]/xgf:point[2]"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="do-mirp">
          <xsl:with-param name="distance" select="@distance"/>
          <xsl:with-param name="round" select="$rnd"/>
          <xsl:with-param name="cut-in"
                          select="boolean(not(@cut-in) or @cut-in = 'yes')"/>
          <xsl:with-param name="min-distance" select="$set-min-dist-bit"/>
          <xsl:with-param name="l-color" select="$local-color"/>
          <xsl:with-param name="move-pt" select="xgf:line[2]/xgf:point[2]"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="xgf:line[1]/@ref">
        <xsl:call-template name="push-point">
          <!-- 4xslt sometimes fails to resolve the following XPath expression.
               I can't figure out what's wrong. No error message. -->
          <xsl:with-param name="pt"
                          select="ancestor::xgf:glyph/descendant::xgf:line[@name =
                                  current()/xgf:line[1]/@ref]/xgf:point[1]"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="push-point">
          <xsl:with-param name="pt" select="xgf:line[1]/xgf:point[1]"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SRP0'"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="xgf:line[2]/@ref">
        <xsl:call-template name="do-mirp">
          <xsl:with-param name="distance" select="@distance"/>
          <xsl:with-param name="round" select="$rnd"/>
          <xsl:with-param name="cut-in"
                          select="boolean(not(@cut-in) or @cut-in = 'yes')"/>
          <xsl:with-param name="min-distance" select="$set-min-dist-bit"/>
          <xsl:with-param name="l-color" select="$local-color"/>
          <xsl:with-param name="move-pt"
                          select="ancestor::xgf:glyph/descendant::xgf:line[@name =
                                  current()/xgf:line[2]/@ref]/xgf:point[1]"/>
          <xsl:with-param name="set-rp0" select="true()"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="do-mirp">
          <xsl:with-param name="distance" select="@distance"/>
          <xsl:with-param name="round" select="$rnd"/>
          <xsl:with-param name="cut-in"
                          select="boolean(not(@cut-in) or @cut-in = 'yes')"/>
          <xsl:with-param name="min-distance" select="$set-min-dist-bit"/>
          <xsl:with-param name="l-color" select="$local-color"/>
          <xsl:with-param name="move-pt" select="xgf:line[2]/xgf:point[1]"/>
          <xsl:with-param name="set-rp0" select="true()"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="count(xgf:align) = 1">
        <xsl:apply-templates select="xgf:align">
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="count(xgf:align) &gt;= 2">
        <xsl:apply-templates select="xgf:align[2]">
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="@save-vectors='yes'">
      <xsl:if test="@freedom-vector='yes'">
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'SFVFS'"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'SPVFS'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$set-min-dist-val">
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'SMD'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

</xsl:stylesheet>
