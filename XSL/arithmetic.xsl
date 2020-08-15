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

  <!--

      simple-operation

      Fetches and pushes two values, performs an operation, and tries
      to find a place to put the result.
  -->
  <xsl:template name="simple-operation">
    <xsl:param name="left"/>
    <xsl:param name="right"/>
    <xsl:param name="op-cmd"/>
    <xsl:param name="dest"/>
    <xsl:param name="mp-container"/>
    <xsl:choose>
      <xsl:when test="$left">
        <xsl:call-template name="expression">
          <xsl:with-param name="val" select="$left"/>
          <xsl:with-param name="cvt-mode" select="'value'"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
          <xsl:with-param name="to-stack" select="true()"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="not(ancestor::xgf:formula)">
          <xsl:call-template name="warning">
            <xsl:with-param name="msg">
              <xsl:text>Left-hand parameter missing in call to </xsl:text>
              <xsl:value-of select="$op-cmd"/>
              <xsl:text>. Trying to use value from stack.</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="$right">
        <xsl:call-template name="expression">
          <xsl:with-param name="val" select="$right"/>
          <xsl:with-param name="cvt-mode" select="'value'"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
          <xsl:with-param name="to-stack" select="true()"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="not(ancestor::xgf:formula)">
          <xsl:call-template name="warning">
            <xsl:with-param name="msg">
              <xsl:text>Right-hand parameter missing in call to </xsl:text>
              <xsl:value-of select="$op-cmd"/>
              <xsl:text>. Trying to use value from stack.</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$left and not($right)">
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'SWAP'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="$op-cmd"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="$dest">
        <xsl:call-template name="store-value">
          <xsl:with-param name="vname" select="$dest"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="not(ancestor::xgf:formula)">
        <xsl:choose>
          <xsl:when test="$left">
            <xsl:call-template name="store-value">
              <xsl:with-param name="vname" select="$left"/>
              <xsl:with-param name="mp-container" select="$mp-container"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="warning">
              <xsl:with-param name="msg">
                <xsl:text>No destination for result of </xsl:text>
                <xsl:value-of select="$op-cmd"/>
                <xsl:text> instruction. Leaving value on the stack.</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!--

  unary-operation

  Performs an operation on a single number and either copies
  it to the location specified by "dest" or tries to copy it
  back to the location that the number came from.
  -->
  <xsl:template name="unary-operation">
    <xsl:param name="val"/>
    <xsl:param name="op-cmd"/>
    <xsl:param name="l-color"/>
    <xsl:param name="dest"/>
    <xsl:param name="mp-container"/>
    <xsl:choose>
      <xsl:when test="$val">
        <xsl:call-template name="expression">
          <xsl:with-param name="val" select="$val"/>
          <xsl:with-param name="cvt-mode" select="'value'"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
          <xsl:with-param name="to-stack" select="true()"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="not(ancestor::xgf:formula)">
          <xsl:call-template name="warning">
            <xsl:with-param name="msg">
              <xsl:text>Parameter missing in call to </xsl:text>
              <xsl:value-of select="$op-cmd"/>
              <xsl:text>. Trying to use value from stack.</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="$l-color">
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="$op-cmd"/>
          <xsl:with-param name="modifier">
            <xsl:call-template name="color-bits">
              <xsl:with-param name="l-color" select="$l-color"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="$op-cmd"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="$dest">
        <xsl:call-template name="store-value">
          <xsl:with-param name="vname" select="$dest"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="not(ancestor::xgf:formula)">
        <xsl:choose>
          <xsl:when test="$val">
            <xsl:call-template name="store-value">
              <xsl:with-param name="vname" select="$val"/>
              <xsl:with-param name="mp-container" select="$mp-container"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="warning">
              <xsl:with-param name="msg">
                <xsl:text>No destination for result of </xsl:text>
                <xsl:value-of select="$op-cmd"/>
                <xsl:text> instruction. Leaving value on the stack.</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xgf:subtract">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="simple-operation">
      <xsl:with-param name="left" select="@minuend"/>
      <xsl:with-param name="right" select="@subtrahend"/>
      <xsl:with-param name="op-cmd" select="'SUB'"/>
      <xsl:with-param name="dest" select="@result-to"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:divide">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="simple-operation">
      <xsl:with-param name="left" select="@dividend"/>
      <xsl:with-param name="right" select="@divisor"/>
      <xsl:with-param name="op-cmd" select="'DIV'"/>
      <xsl:with-param name="dest" select="@result-to"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:maximum|xgf:minimum|xgf:multiply|xgf:add">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="ln" select="local-name()"/>
    <xsl:call-template name="simple-operation">
      <xsl:with-param name="left" select="@value1"/>
      <xsl:with-param name="right" select="@value2"/>
      <xsl:with-param name="op-cmd"
                      select="document('xgfdata.xml')/*/xgfd:instruction-set/xgfd:inst[@el=$ln]/@val"/>
      <xsl:with-param name="dest" select="@result-to"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:ceiling|xgf:floor|xgf:negate|xgf:absolute">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="ln" select="local-name()"/>
    <xsl:call-template name="unary-operation">
      <xsl:with-param name="val" select="@value"/>
      <xsl:with-param name="op-cmd"
                      select="document('xgfdata.xml')/*/xgfd:instruction-set/xgfd:inst[@el=$ln]/@val"/>
      <xsl:with-param name="dest" select="@result-to"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:round">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="unary-operation">
      <xsl:with-param name="val" select="@value"/>
      <xsl:with-param name="op-cmd" select="'ROUND'"/>
      <xsl:with-param name="l-color">
        <xsl:choose>
          <xsl:when test="@color">
            <xsl:value-of select="@color"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$color"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="dest" select="@result-to"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:no-round">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="unary-operation">
      <xsl:with-param name="val" select="@value"/>
      <xsl:with-param name="op-cmd" select="'NROUND'"/>
      <xsl:with-param name="l-color">
        <xsl:choose>
          <xsl:when test="@color">
            <xsl:value-of select="@color"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$color"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="dest" select="@result-to"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:set-equal">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="expression">
      <xsl:with-param name="val" select="@source"/>
      <xsl:with-param name="cvt-mode" select="'value'"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
      <xsl:with-param name="to-stack" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="store-value">
      <xsl:with-param name="vname" select="@target"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:control-value-index">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="r" select="@result-to"/>
    <xsl:if test="not(ancestor::*/xgf:variable[@name=$r])">
      <xsl:call-template name="error-message">
        <xsl:with-param name="msg">
          <xsl:text>The "result-to" attribute in a &lt;control-value-index&gt;</xsl:text>
          <xsl:text> instruction</xsl:text>
          <xsl:value-of select="$newline"/>
          <xsl:text>must be the name of a variable.</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="expression">
      <xsl:with-param name="val" select="@value"/>
      <xsl:with-param name="permitted" select="'c'"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
      <xsl:with-param name="to-stack" select="true()"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="@result-to">
        <xsl:call-template name="store-value">
          <xsl:with-param name="vname" select="@result-to"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="not(ancestor::xgf:formula)">
          <xsl:call-template name="warning">
            <xsl:with-param name="msg">
              <xsl:text>No place to store control value index. </xsl:text>
              <xsl:text>It will be left on the stack.</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:formula">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:apply-templates>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:apply-templates>
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
            <xsl:text>Nothing to do with result of formula. </xsl:text>
            <xsl:text>The value may be left on the stack.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

</xsl:stylesheet>
