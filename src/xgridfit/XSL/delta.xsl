<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"
                xmlns:xgfd="http://www.engl.virginia.edu/OE/xgridfit-data"
                version="1.0">

  <!--
      This file is part of xgridfit, version 3.
      Licensed under the Apache License, Version 2.0.
      Copyright (c) 2006-20 by Peter S. Baker
  -->

  <!-- Push values and execute delta instruction -->
  <xsl:template name="exec-delta">
    <xsl:param name="sets"/>
    <xsl:param name="size-sub"/>
    <xsl:param name="cmd-suffix"/>
    <xsl:param name="caller-is" select="'pt-delta'"/>
    <xsl:param name="mp-container"/>
    <xsl:variable name="delta-list">
      <xsl:for-each select="$sets">
        <xsl:sort select="@size" data-type="number" order="ascending"/>
        <xsl:if test="position() &gt; 1">
          <xsl:text>;</xsl:text>
        </xsl:if>
        <xsl:value-of select="number(((number(@size) -
                              number($size-sub)) * 16) +
                              number(document('xgfdata.xml')/*/xgfd:deltavals/xgfd:deltaval[@step =
                              current()/@distance]/@code))"/>
        <xsl:text>;</xsl:text>
        <xsl:choose>
          <xsl:when test="$caller-is='pt-delta'">
            <xsl:text>point(</xsl:text>
            <xsl:choose>
              <xsl:when test="./xgf:point">
                <xsl:value-of select="./xgf:point/@num"/>
              </xsl:when>
              <xsl:when test="parent::xgf:delta/xgf:point">
                <xsl:value-of select="parent::xgf:delta/xgf:point/@num"/>
              </xsl:when>
              <xsl:when test="ancestor::xgf:move">
                <xsl:value-of select="ancestor::xgf:move[1]/xgf:point/@num"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="error-message">
                  <xsl:with-param name="msg">
                    Cannot find a point for &lt;delta-set&gt;.
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text>)</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@cv"/>
        </xsl:otherwise>
      </xsl:choose>
      </xsl:for-each>
      <xsl:text>;</xsl:text>
      <xsl:value-of select="count($sets)"/>
    </xsl:variable>
    <xsl:call-template name="push-list">
      <xsl:with-param name="list" select="$delta-list"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="$caller-is='pt-delta'">
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="concat('DELTAP',$cmd-suffix)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="concat('DELTAC',$cmd-suffix)"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Accepts a collection of delta-set nodes and goes through them three times,
    looking for delta-set nodes for the DELTAP1, DELTAP2 and DELTAP3 instructions.
    That is to say, the user doesn't have to be concerned with which instruction
    to use.
  -->
  <xsl:template name="do-delta">
    <xsl:param name="sets"/>
    <xsl:param name="caller-is" select="'pt-delta'"/> <!-- Alternative is cv-delta -->
    <xsl:param name="mp-container"/>
    <xsl:if test="$sets[number(@size) &gt;= 0 and number(@size) &lt;= 15]">
      <xsl:call-template name="exec-delta">
        <xsl:with-param name="sets" select="$sets[number(@size) &gt;= 0 and
                                            number(@size) &lt;= 15]"/>
        <xsl:with-param name="size-sub" select="0"/>
        <xsl:with-param name="cmd-suffix" select="'1'"/>
        <xsl:with-param name="caller-is" select="$caller-is"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$sets[number(@size) &gt;= 16 and number(@size) &lt;= 31]">
      <xsl:call-template name="exec-delta">
        <xsl:with-param name="sets" select="$sets[number(@size) &gt;= 16 and
          number(@size) &lt;= 31]"/>
        <xsl:with-param name="size-sub" select="16"/>
        <xsl:with-param name="cmd-suffix" select="'2'"/>
        <xsl:with-param name="caller-is" select="$caller-is"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$sets[number(@size) &gt;= 32 and number(@size) &lt;= 47]">
      <xsl:call-template name="exec-delta">
        <xsl:with-param name="sets" select="$sets[number(@size) &gt;= 32 and
          number(@size) &lt;= 47]"/>
        <xsl:with-param name="size-sub" select="32"/>
        <xsl:with-param name="cmd-suffix" select="'3'"/>
        <xsl:with-param name="caller-is" select="$caller-is"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xgf:delta">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="comp-if">
      <xsl:call-template name="compile-if-test">
        <xsl:with-param name="test" select="@compile-if"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="number($comp-if)">
      <xsl:call-template name="do-delta">
        <xsl:with-param name="sets" select="xgf:delta-set"/>
        <xsl:with-param name="caller-is" select="'pt-delta'"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:control-value-delta">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="do-delta">
      <xsl:with-param name="sets" select="xgf:delta-set"/>
      <xsl:with-param name="caller-is" select="'control-value-delta'"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

</xsl:stylesheet>
