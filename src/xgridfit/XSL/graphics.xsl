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

      set-simple-graphics-var

      Most graphics variables can be set quite simply by pushing a
      number and then executing a command. This is a general template
      for doing that. It also generates the code that allows the TT
      program to track the graphics state.
  -->
  <xsl:template name="set-simple-graphics-var">
    <xsl:param name="value"/>
    <xsl:param name="loc"/>
    <xsl:param name="default-loc"/>
    <xsl:param name="cmd"/>
    <xsl:param name="permitted" select="'1xfvnc'"/>
    <xsl:param name="save" select="true()"/>
    <xsl:param name="may-record-default" select="true()"/>
    <xsl:param name="stack-source-permitted" select="true()"/>
    <xsl:param name="mp-container"/>
    <xsl:param name="all-defaults" select="/xgf:xgridfit/xgf:default"/>
    <!-- Execute this template only if we have a value or are permitted
         to take a value from the stack. -->
    <xsl:if test="$value or number($value) = 0 or $stack-source-permitted">
      <xsl:if test="$save">
        <xsl:call-template name="push-num">
          <xsl:with-param name="num" select="$loc"/>
        </xsl:call-template>
      </xsl:if>
      <!-- If there is a value parameter we use that. If not,
           we expect to find the value we want on top of the
           stack. In that case, we just need to swap the
           top two elements for things to be set up right. -->
      <xsl:choose>
        <xsl:when test="$value or number($value) = 0">
          <xsl:call-template name="expression">
            <xsl:with-param name="val" select="$value"/>
            <xsl:with-param name="permitted" select="$permitted"/>
            <xsl:with-param name="cvt-mode" select="'value'"/>
            <xsl:with-param name="mp-container" select="$mp-container"/>
            <xsl:with-param name="to-stack" select="true()"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="$save">
            <xsl:call-template name="simple-command">
              <xsl:with-param name="cmd" select="'SWAP'"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$save">
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'DUP'"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="$cmd"/>
      </xsl:call-template>
      <xsl:if test="$save">
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'WS'"/>
        </xsl:call-template>
        <xsl:if test="$default-loc and
                      ancestor-or-self::xgf:pre-program and
                      $may-record-default and
                      not($all-defaults[@type='use-truetype-defaults']/@value = 'yes')">
          <xsl:call-template name="storage-to-storage">
            <xsl:with-param name="dest" select="$default-loc"/>
            <xsl:with-param name="src" select="$loc"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!--

      do-with-block

      Like set-simple-graphics-var, but the graphics state set
      here applies only to the instructions contained within
      this element.
  -->
  <xsl:template name="do-with-block">
    <xsl:param name="value"/>
    <xsl:param name="loc"/>
    <xsl:param name="default-loc"/>
    <xsl:param name="cmd"/>
    <xsl:param name="permitted" select="'1xfvnc'"/>
    <xsl:param name="mp-container"/>
    <xsl:call-template name="number-command">
      <xsl:with-param name="num" select="$loc"/>
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="set-simple-graphics-var">
      <xsl:with-param name="value" select="$value"/>
      <xsl:with-param name="cmd" select="$cmd"/>
      <xsl:with-param name="loc" select="$loc"/>
      <xsl:with-param name="default-loc" select="$default-loc"/>
      <xsl:with-param name="permitted" select="$permitted"/>
      <xsl:with-param name="may-record-default" select="false()"/>
      <xsl:with-param name="stack-source-permitted" select="false()"/>
      <xsl:with-param name="mp-container"
        select="$mp-container"/>
    </xsl:call-template>
    <xsl:apply-templates>
      <xsl:with-param name="mp-container"
        select="$mp-container"/>
    </xsl:apply-templates>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'DUP'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="$cmd"/>
    </xsl:call-template>
    <xsl:call-template name="stack-top-to-storage">
      <xsl:with-param name="loc" select="$loc"/>
    </xsl:call-template>
  </xsl:template>

  <!--

      set-zone-pointer

      Set a zone pointer. Parameter "z" must be either "twilight" or
      "glyph"; it specifies the zone to which we are setting the
      pointer. Parameter "zp" must be 0, 1 or 2; it specifies which
      pointer we are setting.
  -->
  <xsl:template name="set-zone-pointer">
    <xsl:param name="z"/>
    <xsl:param name="zp"/>
    <xsl:choose>
      <xsl:when test="$z='twilight'">
        <xsl:call-template name="push-num">
          <xsl:with-param name="num" select="'0'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$z='glyph'">
        <xsl:call-template name="push-num">
          <xsl:with-param name="num" select="'1'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="error-message">
          <xsl:with-param name="msg">
            <xsl:text>Illegal zone specifier </xsl:text>
            <xsl:value-of select="$z"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="concat('SZP', $zp)"/>
    </xsl:call-template>
  </xsl:template>

  <!--

      set-zone-pointers-to-glyph

      A convenience: we set all zone pointers to the glyph
      zone at the end of any procedure that might have
      changed one or more of them.
  -->
  <xsl:template name="set-zone-pointers-to-glyph">
    <xsl:if test="descendant::*/@zone">
      <xsl:call-template name="number-command">
        <xsl:with-param name="num" select="'1'"/>
        <xsl:with-param name="cmd" select="'SZPS'"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!--

      do-set-vector

      Will set either the Projection Vector or the Freedom Vector using
      an axis attribute, a line or "x" and "y" components. If none of
      these things specified, assumes that x and y components are
      available on the stack.
  -->
  <xsl:template name="do-set-vector">
    <xsl:param name="which-vector" select="'P'"/>
    <xsl:param name="line"/>
    <xsl:param name="to-line" select="'parallel'"/>
    <xsl:param name="axis"/>
    <xsl:param name="x-component"/>
    <xsl:param name="y-component"/>
    <xsl:param name="stack-source-permitted" select="true()"/>
    <xsl:param name="mp-container"/>
    <xsl:choose>
      <xsl:when test="$axis">
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd">
            <xsl:text>S</xsl:text>
            <xsl:value-of select="$which-vector"/>
            <xsl:text>VTCA</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="modifier">
            <xsl:call-template name="axis-bit">
              <xsl:with-param name="axis" select="$axis"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$line">
        <xsl:call-template name="check-line">
          <xsl:with-param name="l" select="$line"/>
        </xsl:call-template>
        <xsl:apply-templates mode="push-it" select="$line">
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:apply-templates>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd">
            <xsl:text>S</xsl:text>
            <xsl:value-of select="$which-vector"/>
            <xsl:text>VTL</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="modifier">
            <xsl:call-template name="to-line-bit">
              <xsl:with-param name="tlb" select="$to-line"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$x-component and $y-component">
        <xsl:call-template name="expression">
          <xsl:with-param name="val" select="$x-component"/>
          <xsl:with-param name="permitted" select="'12fvn'"/>
    <xsl:with-param name="mp-container"
    select="$mp-container"/>
    <xsl:with-param name="to-stack" select="true()"/>
        </xsl:call-template>
        <xsl:call-template name="expression">
          <xsl:with-param name="val" select="$y-component"/>
          <xsl:with-param name="permitted" select="'12fvn'"/>
    <xsl:with-param name="mp-container"
    select="$mp-container"/>
    <xsl:with-param name="to-stack" select="true()"/>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="concat('S', $which-vector, 'VFS')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$stack-source-permitted">
        <xsl:call-template name="warning">
          <xsl:with-param name="msg">
            <xsl:text>No input for vector-setting command. </xsl:text>
            <xsl:text>I'm assuming that the needed</xsl:text>
            <xsl:value-of select="$newline"/>
            <xsl:text>values are available on the stack.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="concat('S', $which-vector, 'VFS')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="warning">
          <xsl:with-param name="msg">
            <xsl:text>No input for vector-setting command. Doing nothing.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--

      do-set-vectors

      Set both vectors with an axis attribute, a line, or x and y
      components. If none of these specified, take x and y
      components from the stack.
  -->
  <xsl:template name="do-set-vectors">
    <xsl:param name="line"/>
    <xsl:param name="axis"/>
    <xsl:param name="to-line"/>
    <xsl:param name="x-component"/>
    <xsl:param name="y-component"/>
    <xsl:param name="stack-source-permitted" select="true()"/>
    <xsl:param name="mp-container"/>
    <xsl:choose>
      <xsl:when test="$axis">
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'SVTCA'"/>
          <xsl:with-param name="modifier">
            <xsl:call-template name="axis-bit">
              <xsl:with-param name="axis" select="$axis"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="do-set-vector">
          <xsl:with-param name="which-vector" select="'P'"/>
          <xsl:with-param name="line" select="$line"/>
          <xsl:with-param name="to-line" select="$to-line"/>
          <xsl:with-param name="x-component" select="$x-component"/>
          <xsl:with-param name="y-component" select="$y-component"/>
          <xsl:with-param name="stack-source-permitted"
                          select="$stack-source-permitted"/>
    <xsl:with-param name="mp-container"
    select="$mp-container"/>
        </xsl:call-template>
        <xsl:if test="$line or ($x-component and $y-component) or
                      $stack-source-permitted">
          <xsl:call-template name="simple-command">
            <xsl:with-param name="cmd" select="'SFVTPV'"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--

      do-store-vector

      Copy the x and y components of the projection (P)
      vector or the freedom (F) vector to variables. If
      these variables are not specified, the values are
      left on the stack.
  -->
  <xsl:template name="do-store-vector">
    <xsl:param name="which-vector" select="'P'"/>
    <xsl:param name="x-component"/>
    <xsl:param name="y-component"/>
    <xsl:param name="mp-container"/>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="concat('G', $which-vector, 'V')"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="$x-component and $y-component">
        <xsl:call-template name="store-value">
          <xsl:with-param name="vname" select="$y-component"/>
    <xsl:with-param name="mp-container"
    select="$mp-container"/>
        </xsl:call-template>
        <xsl:call-template name="store-value">
          <xsl:with-param name="vname" select="$x-component"/>
    <xsl:with-param name="mp-container"
    select="$mp-container"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="warning">
          <xsl:with-param name="msg">
            <xsl:text>Warning: nowhere to store vector. </xsl:text>
            <xsl:text>I'm leaving the values on the stack.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="resolve-delta-shift-value">
    <xsl:param name="v"/>
    <xsl:choose>
      <xsl:when test="document('xgfdata.xml')/*/xgfd:deltashifts/xgfd:deltashift[@name
                      = $v]">
        <xsl:value-of
          select="document('xgfdata.xml')/*/xgfd:deltashifts/xgfd:deltashift[@name
                  = $v]/@value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="error-message">
          <xsl:with-param name="msg">
            <xsl:text>Attempting to set delta shift: illegal value "</xsl:text>
            <xsl:value-of select="$v"/>
            <xsl:text>"</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--

      do-set-round

      Sets the round state and also places a record of the new state in
      $var-round-state.
  -->
  <xsl:template name="do-set-round">
    <xsl:param name="round-state"/>
    <xsl:param name="save" select="true()"/>
    <xsl:param name="may-record-default" select="true()"/>
    <xsl:param name="push-current" select="false()"/>
    <xsl:param name="mp-container"/>
    <xsl:param name="all-round-states" select="/xgf:xgridfit/xgf:round-state"/>
    <xsl:param name="all-defaults" select="/xgf:xgridfit/xgf:default"/>
    <xsl:if test="$push-current">
      <xsl:call-template name="number-command">
  <xsl:with-param name="num">
    <xsl:call-template name="resolve-std-variable-loc">
      <xsl:with-param name="n" select="$var-sround-info"/>
    </xsl:call-template>
  </xsl:with-param>
  <xsl:with-param name="cmd" select="'RS'"/>
      </xsl:call-template>
      <xsl:call-template name="number-command">
  <xsl:with-param name="num">
    <xsl:call-template name="resolve-std-variable-loc">
      <xsl:with-param name="n" select="$var-round-state"/>
    </xsl:call-template>
  </xsl:with-param>
  <xsl:with-param name="cmd" select="'RS'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:choose>
      <!-- A value of 'yes' just accepts the current setting,
           even if that is 'off'. -->
      <xsl:when test="$round-state='yes'"></xsl:when>
      <xsl:when test="$all-round-states[@name=$round-state]">
        <xsl:call-template name="do-super-round">
          <xsl:with-param name="period"
                          select="$all-round-states[@name
                                  = $round-state]/@period"/>
          <xsl:with-param name="phase"
                          select="$all-round-states[@name =
                                  $round-state]/@phase"/>
          <xsl:with-param name="threshold"
                          select="$all-round-states[@name =
                                  $round-state]/@threshold"/>
          <xsl:with-param name="save" select="$save"/>
          <xsl:with-param name="may-record-default" select="$may-record-default"/>
    <xsl:with-param name="mp-container"
    select="$mp-container"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="document('xgfdata.xml')/*/xgfd:round-states/xgfd:round[@name =
                      $round-state]">
        <xsl:if test="$save">
    <!--
        Always save two numbers: in $var-round-state,a number
        that identifies the current round state (this is
        specific to xgridfit and does not correspond to the
        number used by the TrueType engine); in
        $var-sround-info, a zero since it is not in use.
    -->
          <xsl:call-template name="push-list">
            <xsl:with-param name="list">
              <xsl:call-template name="resolve-std-variable-loc">
                <xsl:with-param name="n" select="$var-round-state"/>
              </xsl:call-template>
              <xsl:value-of select="$semicolon"/>
              <xsl:value-of select="document('xgfdata.xml')/*/xgfd:round-states/xgfd:round[@name =
                                             $round-state]/@num"/>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name="simple-command">
            <xsl:with-param name="cmd" select="'WS'"/>
          </xsl:call-template>
        <xsl:call-template name="push-list">
          <xsl:with-param name="list">
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
          <xsl:if test="ancestor-or-self::xgf:pre-program and $may-record-default and
                        not($all-defaults[@type='use-truetype-defaults']/@value = 'yes')">
      <!--
  If a default is being set, copy the same info to the
  locations that record the default round state.
      -->
            <xsl:call-template name="storage-to-storage">
        <xsl:with-param name="src">
  <xsl:call-template name="resolve-std-variable-loc">
    <xsl:with-param name="n" select="$var-round-state"/>
  </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="dest">
  <xsl:call-template name="resolve-std-variable-loc">
    <xsl:with-param name="n" select="$var-round-state-default"/>
  </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
            <xsl:call-template name="storage-to-storage">
        <xsl:with-param name="src">
  <xsl:call-template name="resolve-std-variable-loc">
    <xsl:with-param name="n" select="$var-sround-info"/>
  </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="dest">
  <xsl:call-template name="resolve-std-variable-loc">
    <xsl:with-param name="n" select="$var-sround-info-default"/>
  </xsl:call-template>
        </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
        </xsl:if>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd"
            select="document('xgfdata.xml')/*/xgfd:round-states/xgfd:round[@name =
                    $round-state]"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="do-super-round">
          <xsl:with-param name="raw-num" select="$round-state"/>
          <xsl:with-param name="save" select="$save"/>
          <xsl:with-param name="may-record-default" select="$may-record-default"/>
    <xsl:with-param name="mp-container"
    select="$mp-container"/>
    <xsl:with-param name="all-defaults" select="$all-defaults"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!--

      do-super-round

      The SROUND command. Fine control over the round state.
  -->
  <xsl:template name="do-super-round">
    <xsl:param name="raw-num"/>
    <xsl:param name="period"/>
    <xsl:param name="phase"/>
    <xsl:param name="threshold"/>
    <xsl:param name="save" select="true()"/>
    <xsl:param name="may-record-default" select="true()"/>
    <xsl:param name="mp-container"/>
    <xsl:param name="all-defaults" select="/xgf:xgridfit/xgf:default"/>
    <xsl:choose>
      <xsl:when test="$raw-num">
        <xsl:call-template name="expression">
          <xsl:with-param name="val" select="$raw-num"/>
          <xsl:with-param name="permitted" select="'1fvn'"/>
    <xsl:with-param name="mp-container"
    select="$mp-container"/>
    <xsl:with-param name="to-stack" select="true()"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <!-- Test period, phase and threshold for legality. -->
        <xsl:if test="not(document('xgfdata.xml')/*/xgfd:periods/xgfd:period[@name
                      = $period])">
          <xsl:call-template name="error-message">
            <xsl:with-param name="msg">
              <xsl:text>Unknown "period" attribute </xsl:text>
              <xsl:value-of select="$period"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="not(document('xgfdata.xml')/*/xgfd:phases/xgfd:phase[@name
                      = $phase])">
          <xsl:call-template name="error-message">
            <xsl:with-param name="msg">
              <xsl:text>Unknown "phase" attribute </xsl:text>
              <xsl:value-of select="$phase"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="not(document('xgfdata.xml')/*/xgfd:thresholds/xgfd:threshold[@name
                      = $threshold])">
          <xsl:call-template name="error-message">
            <xsl:with-param name="msg">
              <xsl:text>Unknown "threshold" attribute </xsl:text>
              <xsl:value-of select="$threshold"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="push-num">
          <xsl:with-param name="num"
            select="number(document('xgfdata.xml')/*/xgfd:periods/xgfd:period[@name =
                    $period]) +
                    number(document('xgfdata.xml')/*/xgfd:phases/xgfd:phase[@name =
                    $phase]) +
                    number(document('xgfdata.xml')/*/xgfd:thresholds/xgfd:threshold[@name
                    = $threshold])"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$save">
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'DUP'"/>
      </xsl:call-template>
      <xsl:call-template name="push-num">
        <xsl:with-param name="num" select="1"/>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'SWAP'"/>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'WS'"/>
      </xsl:call-template>
      <xsl:call-template name="push-list">
        <xsl:with-param name="list">
          <xsl:text>0;6</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'WS'"/>
      </xsl:call-template>
      <xsl:if test="ancestor-or-self::xgf:pre-program and $may-record-default and
                    not($all-defaults[@type='use-truetype-defaults']/@value = 'yes')">
        <xsl:call-template name="storage-to-storage">
    <xsl:with-param name="src">
      <xsl:call-template name="resolve-std-variable-loc">
        <xsl:with-param name="n" select="$var-round-state"/>
      </xsl:call-template>
    </xsl:with-param>
    <xsl:with-param name="dest">
      <xsl:call-template name="resolve-std-variable-loc">
        <xsl:with-param name="n" select="$var-round-state-default"/>
      </xsl:call-template>
    </xsl:with-param>
  </xsl:call-template>
        <xsl:call-template name="storage-to-storage">
    <xsl:with-param name="src">
      <xsl:call-template name="resolve-std-variable-loc">
        <xsl:with-param name="n" select="$var-sround-info"/>
      </xsl:call-template>
    </xsl:with-param>
    <xsl:with-param name="dest">
      <xsl:call-template name="resolve-std-variable-loc">
        <xsl:with-param name="n" select="$var-sround-info-default"/>
      </xsl:call-template>
    </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SROUND'"/>
    </xsl:call-template>
  </xsl:template>


  <!--

      restore-round-state

      Restores the round state by reading stored value(s) from the Storage Area.
      It works by calling function 0.
  -->
  <xsl:template name="restore-round-state">
    <xsl:param name="from-stack" select="false()"/>
    <xsl:if test="$from-stack">
      <xsl:call-template name="stack-top-to-storage">
  <xsl:with-param name="loc">
    <xsl:call-template name="resolve-std-variable-loc">
      <xsl:with-param name="n" select="$var-round-state"/>
    </xsl:call-template>
  </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="stack-top-to-storage">
  <xsl:with-param name="loc">
    <xsl:call-template name="resolve-std-variable-loc">
      <xsl:with-param name="n" select="$var-sround-info"/>
    </xsl:call-template>
  </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="number-command">
      <xsl:with-param name="num" select="$function-round-restore"/>
      <xsl:with-param name="cmd" select="'CALL'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="xgf:srp">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="push-point">
      <xsl:with-param name="pt" select="xgf:point"/>
      <xsl:with-param name="mp-container"
        select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="concat('SRP', @whichpointer)"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:szp">
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="set-zone-pointer">
      <xsl:with-param name="z" select="@zone"/>
      <xsl:with-param name="zp" select="@whichpointer"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:set-round-state">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="do-set-round">
      <xsl:with-param name="round-state" select="@round"/>
      <xsl:with-param name="mp-container"
        select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:with-round-state">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="do-set-round">
      <xsl:with-param name="round-state" select="@round"/>
      <xsl:with-param name="may-record-default" select="false()"/>
      <xsl:with-param name="push-current" select="true()"/>
      <xsl:with-param name="mp-container"
        select="$mp-container"/>
    </xsl:call-template>
    <xsl:apply-templates>
      <xsl:with-param name="mp-container"
        select="$mp-container"/>
    </xsl:apply-templates>
    <xsl:call-template name="restore-round-state">
      <xsl:with-param name="from-stack" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:set-vectors">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="do-set-vectors">
      <xsl:with-param name="line" select="xgf:line[1]"/>
      <xsl:with-param name="axis" select="@axis"/>
      <xsl:with-param name="to-line" select="@to-line"/>
      <xsl:with-param name="x-component" select="@x-component"/>
      <xsl:with-param name="y-component" select="@y-component"/>
      <xsl:with-param name="mp-container"
        select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:with-vectors">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'GPV'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'GFV'"/>
    </xsl:call-template>
    <xsl:call-template name="do-set-vectors">
      <xsl:with-param name="line" select="xgf:line[1]"/>
      <xsl:with-param name="axis" select="@axis"/>
      <xsl:with-param name="to-line" select="@to-line"/>
      <xsl:with-param name="x-component" select="@x-component"/>
      <xsl:with-param name="y-component" select="@y-component"/>
      <xsl:with-param name="stack-source-permitted" select="false()"/>
      <xsl:with-param name="mp-container"
        select="$mp-container"/>
    </xsl:call-template>
    <xsl:apply-templates>
      <xsl:with-param name="mp-container"
        select="$mp-container"/>
    </xsl:apply-templates>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SFVFS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SPVFS'"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template name="get-vector-letter">
    <xsl:param name="local-name"/>
    <xsl:choose>
      <xsl:when test="contains($local-name, 'projection')">
  <xsl:value-of select="'P'"/>
      </xsl:when>
      <xsl:when test="contains($local-name, 'freedom')">
  <xsl:value-of select="'F'"/>
      </xsl:when>
      <xsl:otherwise>
  <xsl:call-template name="error-message">
    <xsl:with-param name="type" select="'internal'"/>
    <xsl:with-param name="msg">
      <xsl:text>bad parameter for get-vector-letter: </xsl:text>
      <xsl:value-of select="$local-name"/>
    </xsl:with-param>
  </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-graph-location">
    <xsl:param name="s"/>
    <xsl:choose>
      <xsl:when test="$s = 'minimum-distance'">
  <xsl:call-template name="resolve-std-variable-loc">
    <xsl:with-param name="n" select="$var-minimum-distance"/>
  </xsl:call-template>
      </xsl:when>
      <xsl:when test="$s = 'control-value-cut-in'">
  <xsl:call-template name="resolve-std-variable-loc">
    <xsl:with-param name="n" select="$var-minimum-distance"/>
  </xsl:call-template>
      </xsl:when>
      <xsl:when test="$s = 'single-width-cut-in'">
  <xsl:call-template name="resolve-std-variable-loc">
    <xsl:with-param name="n" select="$var-single-width-cut-in"/>
  </xsl:call-template>
      </xsl:when>
      <xsl:when test="$s = 'single-width'">
  <xsl:call-template name="resolve-std-variable-loc">
    <xsl:with-param name="n" select="$var-single-width"/>
  </xsl:call-template>
      </xsl:when>
      <xsl:when test="$s = 'delta-base'">
  <xsl:call-template name="resolve-std-variable-loc">
    <xsl:with-param name="n" select="$var-delta-base"/>
  </xsl:call-template>
      </xsl:when>
      <xsl:when test="$s = 'delta-shift'">
  <xsl:call-template name="resolve-std-variable-loc">
    <xsl:with-param name="n" select="$var-delta-shift"/>
  </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-graph-default-location">
    <xsl:param name="s"/>
    <xsl:choose>
      <xsl:when test="$s = 'minimum-distance'">
  <xsl:call-template name="resolve-std-variable-loc">
    <xsl:with-param name="n" select="$var-minimum-distance-default"/>
  </xsl:call-template>
      </xsl:when>
      <xsl:when test="$s = 'control-value-cut-in'">
  <xsl:call-template name="resolve-std-variable-loc">
    <xsl:with-param name="n" select="$var-control-value-cut-in-default"/>
  </xsl:call-template>
      </xsl:when>
      <xsl:when test="$s = 'single-width-cut-in'">
  <xsl:call-template name="resolve-std-variable-loc">
    <xsl:with-param name="n" select="$var-single-width-cut-in-default"/>
  </xsl:call-template>
      </xsl:when>
      <xsl:when test="$s = 'single-width'">
  <xsl:call-template name="resolve-std-variable-loc">
    <xsl:with-param name="n" select="$var-single-width-default"/>
  </xsl:call-template>
      </xsl:when>
      <xsl:when test="$s = 'delta-base'">
  <xsl:call-template name="resolve-std-variable-loc">
    <xsl:with-param name="n" select="$var-delta-base-default"/>
  </xsl:call-template>
      </xsl:when>
      <xsl:when test="$s = 'delta-shift'">
  <xsl:call-template name="resolve-std-variable-loc">
    <xsl:with-param name="n" select="$var-delta-shift-default"/>
  </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xgf:set-projection-vector|xgf:set-freedom-vector">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="wv">
      <xsl:call-template name="get-vector-letter">
  <xsl:with-param name="local-name" select="local-name()"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="do-set-vector">
      <xsl:with-param name="which-vector" select="$wv"/>
      <xsl:with-param name="line" select="xgf:line"/>
      <xsl:with-param name="to-line" select="@to-line"/>
      <xsl:with-param name="axis" select="@axis"/>
      <xsl:with-param name="x-component" select="@x-component"/>
      <xsl:with-param name="y-component" select="@y-component"/>
      <xsl:with-param name="mp-container"
        select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:with-projection-vector|xgf:with-freedom-vector">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="wv">
      <xsl:call-template name="get-vector-letter">
  <xsl:with-param name="local-name" select="local-name()"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="concat('G', $wv, 'V')"/>
    </xsl:call-template>
    <xsl:call-template name="do-set-vector">
      <xsl:with-param name="which-vector" select="$wv"/>
      <xsl:with-param name="line" select="xgf:line[1]"/>
      <xsl:with-param name="to-line" select="@to-line"/>
      <xsl:with-param name="axis" select="@axis"/>
      <xsl:with-param name="x-component" select="@x-component"/>
      <xsl:with-param name="y-component" select="@y-component"/>
      <xsl:with-param name="stack-source-permitted" select="false()"/>
      <xsl:with-param name="mp-container"
        select="$mp-container"/>
    </xsl:call-template>
    <xsl:apply-templates>
      <xsl:with-param name="mp-container"
        select="$mp-container"/>
    </xsl:apply-templates>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="concat('S', $wv, 'VFS')"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:set-dual-projection-vector">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="check-line">
      <xsl:with-param name="l" select="xgf:line"/>
    </xsl:call-template>
    <xsl:apply-templates mode="push-it" select="xgf:line">
      <xsl:with-param name="mp-container"
        select="$mp-container"/>
    </xsl:apply-templates>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SDPVTL'"/>
      <xsl:with-param name="modifier">
        <xsl:call-template name="to-line-bit">
          <xsl:with-param name="tlb" select="@to-line"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:store-projection-vector|xgf:store-freedom-vector">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="wv">
      <xsl:call-template name="get-vector-letter">
  <xsl:with-param name="local-name" select="local-name()"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="do-store-vector">
      <xsl:with-param name="which-vector" select="$wv"/>
      <xsl:with-param name="x-component" select="@x-component"/>
      <xsl:with-param name="y-component" select="@y-component"/>
      <xsl:with-param name="mp-container"
        select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:set-control-value">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="x-store-control-value">
      <xsl:with-param name="cvtname" select="@name"/>
      <xsl:with-param name="unit">
  <xsl:choose>
    <xsl:when test="@unit = 'pixel'">
      <xsl:text>pixel</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>font</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="val" select="@value"/>
      <xsl:with-param name="mp-container"
        select="$mp-container"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="xgf:with-control-value">
    <xsl:param name="mp-container"/>
    <xsl:variable name="cvt-index">
      <xsl:call-template name="expression">
  <xsl:with-param name="val" select="@name"/>
  <xsl:with-param name="cvt-mode" select="'index'"/>
  <xsl:with-param name="permitted" select="'c'"/>
  <xsl:with-param name="mp-container"
  select="$mp-container"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$cvt-index = 'NaN'">
      <xsl:call-template name="error-message">
  <xsl:with-param name="msg">
    <xsl:text>Can't resolve control-value "</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>"</xsl:text>
  </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="$cvt-index"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'DUP'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RCVT'"/>
    </xsl:call-template>
    <xsl:call-template name="x-store-control-value">
      <xsl:with-param name="cvtname" select="@name"/>
      <xsl:with-param name="unit">
  <xsl:choose>
    <xsl:when test="@unit = 'pixel'">
      <xsl:text>pixel</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>font</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="val" select="@value"/>
      <xsl:with-param name="mp-container"
        select="$mp-container"/>
    </xsl:call-template>
    <xsl:apply-templates>
      <xsl:with-param name="mp-container"
        select="$mp-container"/>
    </xsl:apply-templates>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'WCVTP'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="xgf:set-minimum-distance | xgf:set-control-value-cut-in |
         xgf:set-single-width-cut-in | xgf:set-single-width |
         xgf:set-delta-base | xgf:set-delta-shift">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="ln" select="substring(local-name(),5)"/>
    <xsl:variable name="v">
      <xsl:choose>
  <xsl:when test="$ln = 'delta-shift'">
    <xsl:call-template name="resolve-delta-shift-value">
      <xsl:with-param name="v" select="@units-per-pixel"/>
    </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
    <xsl:value-of select="@value"/>
  </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="set-simple-graphics-var">
      <xsl:with-param name="value" select="$v"/>
      <xsl:with-param name="cmd"
        select="document('xgfdata.xml')/*/xgfd:instruction-set/xgfd:inst[@el=$ln]/@val"/>
      <xsl:with-param name="loc">
  <xsl:call-template name="get-graph-location">
    <xsl:with-param name="s" select="$ln"/>
  </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="default-loc">
  <xsl:call-template name="get-graph-default-location">
    <xsl:with-param name="s" select="$ln"/>
  </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="mp-container"
        select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:with-minimum-distance | xgf:with-control-value-cut-in |
         xgf:with-single-width-cut-in | xgf:with-single-width |
         xgf:with-delta-base | xgf:with-delta-shift">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="ln" select="substring(local-name(),6)"/>
    <xsl:variable name="v">
      <xsl:choose>
        <xsl:when test="$ln = 'delta-shift'">
          <xsl:call-template name="resolve-delta-shift-value">
            <xsl:with-param name="v" select="@units-per-pixel"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@value"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="do-with-block">
      <xsl:with-param name="value" select="$v"/>
      <xsl:with-param name="cmd"
        select="document('xgfdata.xml')/*/xgfd:instruction-set/xgfd:inst[@el=$ln]/@val"/>
      <xsl:with-param name="loc">
        <xsl:call-template name="get-graph-location">
          <xsl:with-param name="s" select="$ln"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="default-loc">
        <xsl:call-template name="get-graph-default-location">
          <xsl:with-param name="s" select="$ln"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="mp-container"
        select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:disable-instructions|xgf:enable-instructions">
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="ln" select="local-name()"/>
    <xsl:variable name="v">
      <xsl:choose>
  <xsl:when test="contains($ln, 'disable')">
    <xsl:value-of select="1"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:value-of select="0"/>
  </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="do-instctrl">
      <xsl:with-param name="selector" select="1"/>
      <xsl:with-param name="val" select="$v"/>
      <xsl:with-param name="caller" select="$ln"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:set-dropout-type">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="expression">
      <xsl:with-param name="val" select="@value"/>
      <xsl:with-param name="permitted" select="'1'"/>
      <xsl:with-param name="mp-container"
        select="$mp-container"/>
      <xsl:with-param name="to-stack" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SCANTYPE'"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:set-dropout-control">
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="number-command">
      <xsl:with-param name="num"
        select="number(@threshold) + (256 * number(@flags))"/>
      <xsl:with-param name="cmd" select="'SCANCTRL'"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:set-auto-flip">
    <xsl:call-template name="debug-start"/>
    <xsl:choose>
      <xsl:when test="@value='on'">
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'FLIPON'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'FLIPOFF'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template name="restdef">
    <xsl:param name="entry"/>
    <xsl:choose>
      <xsl:when test="$entry/@name = 'round-state'">
        <xsl:call-template name="storage-to-storage">
          <xsl:with-param name="src">
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-round-state-default"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="dest">
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-round-state"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="storage-to-storage">
          <xsl:with-param name="src">
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-sround-info-default"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="dest">
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-sround-info"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="restore-round-state"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="push-list">
          <xsl:with-param name="list">
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$entry/@loc"/>
            </xsl:call-template>
            <xsl:value-of select="$semicolon"/>
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$entry/@def"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'RS'"/>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'DUP'"/>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="$entry/@inst"/>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'WS'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xgf:restore-default">
    <xsl:variable name="n" select="@name"/>
    <xsl:choose>
      <xsl:when test="$n = 'all'">
  <xsl:for-each select="document('xgfdata.xml')/*/xgfd:defaults/xgfd:entry">
    <xsl:call-template name="restdef">
      <xsl:with-param name="entry" select="."/>
    </xsl:call-template>
  </xsl:for-each>
  <!-- These are graphics variables that Xgridfit doesn't
       track. We'll just use the TrueType defaults. -->
  <xsl:call-template name="simple-command">
    <xsl:with-param name="cmd" select="'SVTCA'"/>
    <xsl:with-param name="modifier">
      <xsl:call-template name="axis-bit">
        <xsl:with-param name="axis" select="'x'"/>
      </xsl:call-template>
    </xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="simple-command">
    <xsl:with-param name="cmd" select="'FLIPON'"/>
  </xsl:call-template>
  <xsl:call-template name="set-zone-pointers-to-glyph"/>
      </xsl:when>
      <xsl:when test="document('xgfdata.xml')/*/xgfd:defaults/xgfd:entry[@name=$n]">
  <xsl:call-template name="restdef">
    <xsl:with-param name="entry"
    select="document('xgfdata.xml')/*/xgfd:defaults/xgfd:entry[@name=$n]"/>
  </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
  <xsl:call-template name="error-message">
    <xsl:with-param name="msg">
      <xsl:text>Unknown attribute value name="</xsl:text>
      <xsl:value-of select="$n"/>
      <xsl:text>" in &lt;restore-default&gt;</xsl:text>
    </xsl:with-param>
  </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
