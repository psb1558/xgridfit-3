<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"
                version="1.0"
                exclude-result-prefixes="xgf">

  <!--
      This file is part of xgridfit, version 3.
      Licensed under the Apache License, Version 2.0.
      Copyright (c) 2006-20 by Peter S. Baker
  -->

  <xsl:variable name="xgf-version" select="'3.0'"/>
  <!--
      First in the Storage Area is a block of locations used by legacy
      code (defined as the "legacy-storage" default). Next come some
      reserved locations used by Xgridfit to track state
      information. Next is the global variable area and finally a
      growable variable frame area.
  -->
  <xsl:variable name="var-round-state" select="0"/>
  <xsl:variable name="var-sround-info" select="1"/>
  <xsl:variable name="var-round-state-default" select="2"/>
  <xsl:variable name="var-sround-info-default" select="3"/>
  <xsl:variable name="var-return-value" select="4"/>
  <xsl:variable name="var-minimum-distance" select="5"/>
  <xsl:variable name="var-minimum-distance-default" select="6"/>
  <xsl:variable name="var-control-value-cut-in" select="7"/>
  <xsl:variable name="var-control-value-cut-in-default" select="8"/>
  <xsl:variable name="var-single-width" select="9"/>
  <xsl:variable name="var-single-width-cut-in" select="10"/>
  <xsl:variable name="var-single-width-default" select="11"/>
  <xsl:variable name="var-single-width-cut-in-default" select="12"/>
  <xsl:variable name="var-delta-base" select="13"/>
  <xsl:variable name="var-delta-base-default" select="14"/>
  <xsl:variable name="var-delta-shift" select="15"/>
  <xsl:variable name="var-delta-shift-default" select="16"/>
  <xsl:variable name="var-function-stack-count" select="17"/>
  <xsl:variable name="var-frame-bottom" select="18"/>
  <xsl:variable name="var-frame-top" select="19"/>
  <xsl:variable name="reg0" select="20"/>
  <xsl:variable name="reg1" select="21"/>
  <xsl:variable name="reg2" select="22"/>
  <xsl:variable name="reg3" select="23"/>

  <!-- This number + 1 is the lowest address of a global variable. -->
  <xsl:variable name="global-variable-base" select="23"/>
  <!-- This number + 1 is the lowest address of a variable
       in a glyph program or function. -->
  <xsl:variable name="variable-frame-base"
                select="$global-variable-base +
			count(/xgf:xgridfit/xgf:variable)"/>

  <xsl:variable name="no-namespace-error">
    <xsl:text>Either the xgridfit element is missing or it lacks the required</xsl:text>
    <xsl:value-of select="$text-newline"/>
    <xsl:text>namespace declaration. Run xgfupdate on this file to correct.</xsl:text>
    <xsl:value-of select="$text-newline"/>
  </xsl:variable>

  <xsl:variable name="py-start-message">
    <xsl:value-of select="$text-newline"/>
    <xsl:text># Program generated by Xgridfit, version </xsl:text>
    <xsl:value-of select="$xgf-version"/>
    <xsl:value-of select="$text-newline"/>
    <xsl:text># Don't edit this file unless you are very sure of what you're doing.</xsl:text>
    <xsl:value-of select="$text-newline"/>
  </xsl:variable>

</xsl:stylesheet>
