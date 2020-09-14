<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"
                xmlns:xgfd="http://www.engl.virginia.edu/OE/xgridfit-data" version="1.0">

  <!--
      This file is part of xgridfit, version 3.
      Licensed under the Apache License, Version 2.0.
      Copyright (c) 2006-20 by Peter S. Baker
  -->

  <!--
      Generate a list of TupleVariations that can be assigned
      to a cvar.variations property.
  -->

  <xsl:template name="getRegionTag">
    <xsl:text>get-region-tag called</xsl:text>
    <xsl:param name="index"/>
    <xsl:value-of select="/xgf:xgridfit/xgf:cvar/xgf:region[$index]/@tag"/>
  </xsl:template>

  <xsl:template name="get-region-values">
    <xsl:param name="idx"/>
    <xsl:value-of select="$idx"/>
<!--    <xsl:value-of select="count(/xgf:xgridfit/xgf:cvar/xgf:region[$index]"/> -->
    <xsl:text>(</xsl:text>
    <xsl:value-of select="/xgf:xgridfit/xgf:cvar/xgf:region[$idx]/@bot"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="/xgf:xgridfit/xgf:cvar/xgf:region[$idx]/@peak"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="/xgf:xgridfit/xgf:cvar/xgf:region[$idx]/@top"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template name="get-region-coordinates">
    <xsl:param name="index"/>
    <xsl:variable name="cvvs"
      select="/xgf:xgridfit/xgf:cvar/xgf:region[$index]/xgf:cvv"/>
    <xsl:for-each select="/xgf:xgridfit/xgf:control-value">
      <xsl:variable name="cvname" select="@name"/>
      <xsl:choose>
        <xsl:when test="$cvvs[@name = $cvname]">
          <xsl:variable name="defcv" select="number(@value)"/>
          <xsl:variable name="varcv"
            select="number($cvvs[@name = $cvname]/@value)"/>
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
          <xsl:value-of select="0"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="position() != last()">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
