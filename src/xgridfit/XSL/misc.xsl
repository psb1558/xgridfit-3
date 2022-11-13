<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"
                version="1.0">

  <!--
      This file is part of xgridfit, version 3.
      Licensed under the Apache License, Version 2.0.
      Copyright (c) 2006-20 by Peter S. Baker
  -->

  <xsl:template name="do-instctrl">
    <xsl:param name="selector"/>
    <xsl:param name="val"/>
    <xsl:param name="caller"/>
    <xsl:choose>
      <xsl:when test="ancestor::xgf:pre-program">
        <xsl:call-template name="push-list">
          <xsl:with-param name="list">
            <xsl:value-of select="$val"/>
            <xsl:value-of select="$semicolon"/>
            <xsl:value-of select="$selector"/>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'INSTCTRL'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="warning">
          <xsl:with-param name="msg">
            <xsl:text>&lt;</xsl:text>
            <xsl:value-of select="$caller"/>
            <xsl:text>&gt; can be used only in the</xsl:text>
            <xsl:value-of select="$newline"/>
            <xsl:text>&lt;pre-program&gt;. It is being ignored.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xgf:getinfo">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="s" select="normalize-space(@selector)"/>
    <xsl:call-template name="expression">
      <xsl:with-param name="val" select="$s"/>
      <xsl:with-param name="getinfo-index" select="true()"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
      <xsl:with-param name="to-stack" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'GETINFO'"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="@result-to">
        <xsl:call-template name="store-value">
          <xsl:with-param name="vname" select="@result-to"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="warning">
          <xsl:with-param name="msg">
            <xsl:text>No place to store result of GETINFO. </xsl:text>
            <xsl:text>It will be left on the stack.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:message">
    <xsl:message terminate="no">
      <xsl:value-of select="."/>
    </xsl:message>
  </xsl:template>

</xsl:stylesheet>
