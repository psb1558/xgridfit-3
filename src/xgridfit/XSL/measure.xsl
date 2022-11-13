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
      Measure the distance between two points and leave the result
      on the stack.
  -->
  <xsl:template name="do-measure-distance">
    <xsl:param name="pt1"/>
    <xsl:param name="pt2"/>
    <xsl:param name="gf" select="true()"/>
    <xsl:param name="mp-container"/>
    <xsl:call-template name="push-point">
      <xsl:with-param name="pt" select="$pt2"/>
      <xsl:with-param name="zp" select="'0'"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="push-point">
      <xsl:with-param name="pt" select="$pt1"/>
      <xsl:with-param name="zp" select="'1'"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'MD'"/>
      <xsl:with-param name="modifier">
        <xsl:call-template name="grid-fitted-bit">
          <xsl:with-param name="grid-fitted" select="$gf"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="set-zone-pointers-to-glyph"/>
  </xsl:template>

  <xsl:template match="xgf:measure-distance">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="do-measure-distance">
      <xsl:with-param name="pt1" select="xgf:point[1]"/>
      <xsl:with-param name="pt2" select="xgf:point[2]"/>
      <xsl:with-param name="gf"
        select="boolean(not(@grid-fitted) or @grid-fitted = 'yes')"/>
      <xsl:with-param name="mp-container"
          select="$mp-container"/>
    </xsl:call-template>
    <xsl:if test="@result-to">
      <xsl:call-template name="store-value">
        <xsl:with-param name="vname" select="@result-to"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:get-coordinate">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="push-point">
      <xsl:with-param name="pt" select="xgf:point[1]"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'GC'"/>
      <xsl:with-param name="modifier">
        <xsl:call-template name="grid-fitted-bit">
          <xsl:with-param name="grid-fitted" select="boolean(@grid-fitted='yes')"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:if test="@result-to">
      <xsl:call-template name="store-value">
        <xsl:with-param name="vname" select="@result-to"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

</xsl:stylesheet>
