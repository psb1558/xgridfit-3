<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"
    xmlns:saxon="http://icl.com/saxon"
    xmlns:saxnine="http://saxon.sf.net/"
    xmlns:xalan="http://xml.apache.org/xalan/java/org.apache.xalan.lib.NodeInfo"
    version="1.0">

  <!--
      This file is part of xgridfit, version 3.
      Licensed under the Apache License, Version 2.0.
      Copyright (c) 2006-20 by Peter S. Baker
  -->

  <!-- Set this to true() to suppress running messages (not error messages
  or warnings). On my machine, running xsltproc, this cuts processing
  time approximately in half. -->
  <xsl:param name="silent_mode" select="'no'"/>

  <xsl:template name="display-line-number">
    <xsl:choose>
      <xsl:when test="function-available('saxon:line-number')">
        <xsl:text>Line </xsl:text>
        <xsl:value-of select="saxon:line-number()"/>
        <xsl:text>. </xsl:text>
      </xsl:when>
      <xsl:when test="function-available('saxnine:line-number')">
        <xsl:text>Line </xsl:text>
        <xsl:value-of select="saxnine:line-number()"/>
        <xsl:text>. </xsl:text>
      </xsl:when>
      <xsl:when test="function-available('xalan:lineNumber')">
        <xsl:text>Line </xsl:text>
        <xsl:value-of select="xalan:lineNumber()"/>
        <xsl:text>. </xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="display-message">
    <xsl:param name="msg"/>
    <xsl:if test="$silent_mode != 'yes'">
      <xsl:message>
        <xsl:value-of select="$msg"/>
      </xsl:message>
    </xsl:if>
  </xsl:template>

  <xsl:template name="error-message">
    <xsl:param name="msg"/>
    <xsl:param name="type" select="'normal'"/>
    <xsl:message terminate="yes">
      <xsl:value-of select="$text-newline"/>
      <xsl:call-template name="display-line-number"/>
      <xsl:choose>
        <xsl:when test="$type = 'internal'">
          <xsl:text>Internal error: </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Error: </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="$msg"/>
      <xsl:if test="$type = 'internal'">
        <xsl:value-of select="$text-newline"/>
        <xsl:text>Please report this error on xgridfit-users@lists.sourceforge.net.</xsl:text>
      </xsl:if>
    </xsl:message>
  </xsl:template>

  <xsl:template name="warning">
    <xsl:param name="msg"/>
    <xsl:param name="with-pop" select="false()"/>
    <xsl:if test="not(ancestor::xgf:no-warning)">
      <xsl:message>
        <xsl:value-of select="$text-newline"/>
        <xsl:call-template name="display-line-number"/>
        <xsl:text>Warning: </xsl:text>
        <xsl:value-of select="$msg"/>
        <xsl:value-of select="$text-newline"/>
      </xsl:message>
    </xsl:if>
    <xsl:if test="$with-pop">
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'POP'"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xgf:no-warning">
    <xsl:param name="mp-container"/>
    <xsl:apply-templates>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:apply-templates>
  </xsl:template>

</xsl:stylesheet>
