<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"
                version="1.0">

  <!--
      This file is part of xgridfit, version 3.
      Licensed under the Apache License, Version 2.0.
      Copyright (c) 2006-20 by Peter S. Baker
  -->

  <xsl:template name="initialize-graphics-var">
    <xsl:param name="var-name"/>
    <xsl:param name="loc"/>
    <xsl:param name="default-loc"/>
    <xsl:param name="tt-default-val"/>
    <xsl:param name="cmd"/>
    <xsl:param name="may-set-default"/>
    <xsl:param name="all-defaults" select="/xgf:xgridfit/xgf:default"/>
    <xsl:choose>
      <xsl:when test="$all-defaults[@type=$var-name] and
                      $may-set-default">
        <xsl:call-template name="set-simple-graphics-var">
          <xsl:with-param name="value"
                          select="$all-defaults[@type=$var-name]/@value"/>
          <xsl:with-param name="loc" select="$loc"/>
          <xsl:with-param name="default-loc" select="$default-loc"/>
          <xsl:with-param name="cmd" select="$cmd"/>
          <xsl:with-param name="stack-source-permitted" select="false()"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="push-list">
          <xsl:with-param name="list">
            <xsl:value-of select="$default-loc"/>
            <xsl:value-of select="$semicolon"/>
            <xsl:value-of select="$tt-default-val"/>
            <xsl:value-of select="$semicolon"/>
            <xsl:value-of select="$loc"/>
            <xsl:value-of select="$semicolon"/>
            <xsl:value-of select="$tt-default-val"/>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'WS'"/>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'WS'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="pre-program-instructions">
    <xsl:param name="all-defaults" select="/xgf:xgridfit/xgf:default"/>
    <xsl:variable name="use-tt-defaults"
                  select="boolean($all-defaults[@type =
                         'use-truetype-defaults']/@value = 'yes')"/>
    <xsl:variable name="cleartype"
                  select="boolean($all-defaults[@type =
                         'cleartype']/@value = 'yes')"/>
    <xsl:if test="$cleartype">
      <xsl:call-template name="push-list">
        <xsl:with-param name="list">
          <xsl:text>4;3</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'INSTCTRL'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$use-tt-defaults">
      <xsl:call-template name="push-list">
        <xsl:with-param name="list">
          <xsl:text>1;2</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'INSTCTRL'"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:if test="xgf:variable or descendant::xgf:call-function">
      <xsl:call-template name="set-up-variable-frame"/>
      <xsl:apply-templates select="xgf:variable" mode="initialize"/>
    </xsl:if>

    <!-- INITIALIZE THE GRAPHICS STATE -->
    <!-- Set up some defaults. Either a default has been specified in the
         xgridfit file, in which case it is automatically recorded as a
         default because we're calling from the pre-program, or we just
         record that we are using the TrueType default. -->

    <!-- Set up the round state. -->
    <xsl:choose>
      <xsl:when test="$all-defaults[@type='round-state']">
        <xsl:call-template name="do-set-round">
          <xsl:with-param name="round-state"
            select="$all-defaults[@type='round-state']/@value"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="push-list">
          <xsl:with-param name="list">
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-round-state-default"/>
            </xsl:call-template>
            <xsl:value-of select="$semicolon"/>
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-round-state"/>
            </xsl:call-template>
            <xsl:value-of select="$semicolon"/>
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-sround-info-default"/>
            </xsl:call-template>
            <xsl:value-of select="$semicolon"/>
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-sround-info"/>
            </xsl:call-template>
            <xsl:value-of select="$semicolon"/>
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-round-state"/>
            </xsl:call-template>
            <xsl:value-of select="$semicolon"/>
            <xsl:value-of select="0"/>
            <xsl:value-of select="$semicolon"/>
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-sround-info"/>
            </xsl:call-template>
            <xsl:value-of select="$semicolon"/>
            <xsl:value-of select="0"/>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'WS'"/>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'WS'"/>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'RS'"/>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'WS'"/>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'RS'"/>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'WS'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

    <!-- Set up the minimum distance. -->
    <xsl:call-template name="initialize-graphics-var">
      <xsl:with-param name="var-name" select="'minimum-distance'"/>
      <xsl:with-param name="loc">
        <xsl:call-template name="resolve-std-variable-loc">
          <xsl:with-param name="n" select="$var-minimum-distance"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="default-loc">
        <xsl:call-template name="resolve-std-variable-loc">
          <xsl:with-param name="n" select="$var-minimum-distance-default"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="cmd" select="'SMD'"/>
      <xsl:with-param name="tt-default-val" select="64"/>
      <xsl:with-param name="may-set-default" select="not($use-tt-defaults)"/>
      <xsl:with-param name="all-defaults" select="$all-defaults"/>
    </xsl:call-template>
    <!-- Set up the control value cut-in. -->
    <xsl:call-template name="initialize-graphics-var">
      <xsl:with-param name="var-name" select="'control-value-cut-in'"/>
      <xsl:with-param name="loc">
        <xsl:call-template name="resolve-std-variable-loc">
          <xsl:with-param name="n" select="$var-control-value-cut-in"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="default-loc">
        <xsl:call-template name="resolve-std-variable-loc">
          <xsl:with-param name="n" select="$var-control-value-cut-in-default"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="cmd" select="'SCVTCI'"/>
      <xsl:with-param name="tt-default-val" select="68"/>
      <xsl:with-param name="may-set-default" select="not($use-tt-defaults)"/>
      <xsl:with-param name="all-defaults" select="$all-defaults"/>
    </xsl:call-template>
    <!-- Set up the single width cut-in. -->
    <xsl:call-template name="initialize-graphics-var">
      <xsl:with-param name="var-name" select="'single-width-cut-in'"/>
      <xsl:with-param name="loc">
        <xsl:call-template name="resolve-std-variable-loc">
          <xsl:with-param name="n" select="$var-single-width-cut-in"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="default-loc">
        <xsl:call-template name="resolve-std-variable-loc">
          <xsl:with-param name="n" select="$var-single-width-cut-in-default"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="cmd" select="'SSWCI'"/>
      <xsl:with-param name="tt-default-val" select="0"/>
      <xsl:with-param name="may-set-default" select="not($use-tt-defaults)"/>
      <xsl:with-param name="all-defaults" select="$all-defaults"/>
    </xsl:call-template>
    <!-- Set up the single width. -->
    <xsl:call-template name="initialize-graphics-var">
      <xsl:with-param name="var-name" select="'single-width'"/>
      <xsl:with-param name="loc">
        <xsl:call-template name="resolve-std-variable-loc">
          <xsl:with-param name="n" select="$var-single-width"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="default-loc">
        <xsl:call-template name="resolve-std-variable-loc">
          <xsl:with-param name="n" select="$var-single-width-default"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="cmd" select="'SSW'"/>
      <xsl:with-param name="tt-default-val" select="0"/>
      <xsl:with-param name="may-set-default" select="not($use-tt-defaults)"/>
      <xsl:with-param name="all-defaults" select="$all-defaults"/>
    </xsl:call-template>
    <!-- Set up the delta base. -->
    <xsl:call-template name="initialize-graphics-var">
      <xsl:with-param name="var-name" select="'delta-base'"/>
      <xsl:with-param name="loc">
        <xsl:call-template name="resolve-std-variable-loc">
          <xsl:with-param name="n" select="$var-delta-base"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="default-loc">
        <xsl:call-template name="resolve-std-variable-loc">
          <xsl:with-param name="n" select="$var-delta-base-default"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="cmd" select="'SDB'"/>
      <xsl:with-param name="tt-default-val" select="9"/>
      <xsl:with-param name="may-set-default" select="not($use-tt-defaults)"/>
      <xsl:with-param name="all-defaults" select="$all-defaults"/>
    </xsl:call-template>
    <!-- Set up the delta shift. -->
    <xsl:choose>
      <xsl:when test="$all-defaults[@type =
                      'delta-shift'] and not($use-tt-defaults)">
        <xsl:variable name="n">
          <xsl:call-template name="resolve-delta-shift-value">
            <xsl:with-param name="v"
                            select="$all-defaults[@type =
                                    'delta-shift']/@value"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="set-simple-graphics-var">
          <xsl:with-param name="value" select="$n"/>
          <xsl:with-param name="loc">
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-delta-shift"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="default-loc">
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-delta-shift-default"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="cmd" select="'SDS'"/>
          <xsl:with-param name="stack-source-permitted" select="false()"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="push-list">
          <xsl:with-param name="list">
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-delta-shift-default"/>
            </xsl:call-template>
            <xsl:value-of select="$semicolon"/>
            <xsl:value-of select="3"/>
            <xsl:value-of select="$semicolon"/>
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-delta-shift"/>
            </xsl:call-template>
            <xsl:value-of select="$semicolon"/>
            <xsl:value-of select="3"/>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'WS'"/>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'WS'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <!-- DONE WITH GRAPHICS STATE.
        Now process other instructions in the pre-program. -->
    <xsl:apply-templates/>
    <!-- Any functions to define in prep? -->
    <xsl:apply-templates select="/xgf:xgridfit/xgf:function[xgf:variant]"/>
  </xsl:template>
</xsl:stylesheet>
