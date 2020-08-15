<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"
                xmlns:xgfd="http://www.engl.virginia.edu/OE/xgridfit-data"
                xmlns:excom="http://exslt.org/common"
                version="1.0"
                exclude-result-prefixes="xgf xgfd excom"
                extension-element-prefixes="excom">

  <!--
      This file is part of xgridfit, version 3.
      Licensed under the Apache License, Version 2.0.
      Copyright (c) 2006-20 by Peter S. Baker
  -->

  <!--
      Generate a list of TupleVariations that can be assigned
      to a cvar.variations property.
  -->

  <xsl:output method="text"/>

  <xsl:key name="cvt" match="xgf:control-value" use="@name"/>

  <xsl:variable name="newline"><xsl:text>
</xsl:text></xsl:variable>

  <xsl:template match="@*|node()">
    <xsl:apply-templates select="@*|node()"/>
  </xsl:template>

  <xsl:template match="xgf:cvar">
    <xsl:text>CVAR_VARIATIONS = [</xsl:text>
    <xsl:value-of select="$newline"/>
    <xsl:apply-templates select="xgf:region"/>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="xgf:region">
    <xsl:text>    TupleVariation({'</xsl:text>
    <xsl:value-of select="@tag"/>
    <xsl:text>': (</xsl:text>
    <xsl:value-of select="@bot"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="@peak"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="@top"/>
    <xsl:text>)}, [</xsl:text>
    <xsl:variable name="cvvs" select="*"/>
    <xsl:for-each select="/xgf:xgridfit/xgf:control-value">
      <xsl:variable name="cvname" select="@name"/>
      <xsl:choose>
        <xsl:when test="$cvvs[@name = $cvname]">
          <xsl:variable name="defcv" select="number(@value)"/>
          <xsl:variable name="varcv" select="number($cvvs[@name
                                             = $cvname]/@value)"/>
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
