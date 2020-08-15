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

      do-mirp

      If "round" is "yes," we just go with the cut-in value. The cut-in
        actually determines how we set bit 3, because having the cut-in
        off implies that rounding MUST be off, while the round state can
        be anything (including "no") if the cut-in is "yes."
      If "round" is anything but "yes," we explicitly set the round state,
        calling the template that changes round state (but we do not store).
        Then, at the end, we call the template that restores the stored
        round state (it will be the previous one). Thus the round state that
        is specified for this instruction applies only to this instruction.
      If "ref-pt" is specified, we set RP0 before we do the MIRP or MDRP.
  -->
  <xsl:template name="do-mirp">
    <xsl:param name="distance"/>
    <xsl:param name="round" select="'yes'"/>
    <xsl:param name="cut-in" select="true()"/>
    <xsl:param name="min-distance" select="true()"/>
    <xsl:param name="set-rp0" select="false()"/>
    <xsl:param name="l-color" select="'gray'"/>
    <xsl:param name="move-pt"/>
    <xsl:param name="ref-pt"/>
    <xsl:param name="suppress-set-rp0" select="false()"/>
    <xsl:param name="mp-container"/>
    <xsl:variable name="need-set-round"
      select="boolean($round != 'yes' and ($round != 'no' or $cut-in))"/>
    <xsl:if test="$round != 'no' and not($cut-in)">
      <xsl:call-template name="warning">
        <xsl:with-param name="msg">
          <xsl:text>In the MIRP instruction round state cannot be "on" </xsl:text>
          <xsl:text>and CVT cut-in "off." Rounding will not be used.</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$need-set-round">
      <!-- Set round state without saving it, so we can restore the
           previous one when done. -->
      <xsl:call-template name="do-set-round">
        <xsl:with-param name="round-state" select="$round"/>
        <xsl:with-param name="push-current" select="true()"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="not($suppress-set-rp0) and $ref-pt">
      <!-- Set RP0 if a reference point has been specified. ZP0 for this point. -->
      <xsl:call-template name="push-point">
        <xsl:with-param name="pt" select="$ref-pt"/>
        <xsl:with-param name="zp" select="'0'"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'SRP0'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="push-point-and-distance">
      <xsl:with-param name="pt" select="$move-pt"/>
      <xsl:with-param name="ds" select="$distance"/>
      <xsl:with-param name="zp" select="'1'"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <!-- Do the move. -->
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'MIRP'"/>
      <xsl:with-param name="modifier">
        <xsl:call-template name="mirp-mdrp-bits">
          <xsl:with-param name="set-rp0" select="$set-rp0"/>
          <xsl:with-param name="min-distance" select="$min-distance"/>
          <xsl:with-param name="round-cut-in" select="$cut-in"/>
          <xsl:with-param name="l-color" select="$l-color"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:if test="$need-set-round">
      <xsl:call-template name="restore-round-state">
        <xsl:with-param name="from-stack" select="true()"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="set-zone-pointers-to-glyph"/>
  </xsl:template>

  <!--

       do-miap

       Similar to "do-mirp" but there's no reference point, no minimum distance,
       no color, and no choice about whether to set RP0. We do the same thing
       to sort out the relationship between rounding and the CVT cut-in.
  -->
  <xsl:template name="do-miap">
    <xsl:param name="distance"/>
    <xsl:param name="round" select="'yes'"/>
    <xsl:param name="cut-in" select="true()"/>
    <xsl:param name="move-pt"/>
    <xsl:param name="mp-container"/>
    <xsl:variable name="need-set-round"
      select="boolean($round != 'yes' and ($round != 'no' or $cut-in))"/>
    <xsl:if test="$round != 'no' and not($cut-in)">
      <xsl:call-template name="warning">
        <xsl:with-param name="msg">
          <xsl:text>In the MIAP instruction round state cannot be "on" </xsl:text>
          <xsl:text>and CVT cut-in "off." Rounding will not be used.</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$need-set-round">
      <!-- We don't save this round state; so what we have stored is the
           previous one. -->
      <xsl:call-template name="do-set-round">
        <xsl:with-param name="round-state" select="$round"/>
        <xsl:with-param name="push-current" select="true()"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="push-point-and-distance">
      <xsl:with-param name="pt" select="$move-pt"/>
      <xsl:with-param name="ds" select="$distance"/>
      <xsl:with-param name="zp" select="'0'"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <!-- Do the move -->
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'MIAP'"/>
      <xsl:with-param name="modifier">
        <xsl:call-template name="round-and-cut-in-bit">
          <xsl:with-param name="b" select="$cut-in"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:if test="$need-set-round">
      <xsl:call-template name="restore-round-state">
        <xsl:with-param name="from-stack" select="true()"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="set-zone-pointers-to-glyph"/>
  </xsl:template>


  <!--

      do-mdrp

      Similar to do-mirp, but there's no distance and no cut-in, so no
      confusion about the relationship between rounding and the cut-in.
  -->
  <xsl:template name="do-mdrp">
    <xsl:param name="round" select="'yes'"/>
    <xsl:param name="min-distance" select="true()"/>
    <xsl:param name="set-rp0" select="false()"/>
    <xsl:param name="l-color" select="'gray'"/>
    <xsl:param name="move-pt"/>
    <xsl:param name="ref-pt"/>
    <xsl:param name="suppress-set-rp0" select="false()"/>
    <xsl:param name="mp-container"/>
    <xsl:variable name="rnotno" select="boolean($round != 'no')"/>
    <xsl:variable name="rnot" select="boolean($rnotno and $round != 'yes')"/>
    <xsl:if test="$rnot">
      <!-- We don't save this round state; so what we have stored is the
           previous one. -->
      <xsl:call-template name="do-set-round">
        <xsl:with-param name="round-state" select="$round"/>
        <xsl:with-param name="push-current" select="true()"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="not($suppress-set-rp0) and $ref-pt">
      <!-- Set RP0 if a reference point has been specified. -->
      <xsl:call-template name="push-point">
        <xsl:with-param name="pt" select="$ref-pt"/>
        <xsl:with-param name="zp" select="'0'"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'SRP0'"/>
      </xsl:call-template>
    </xsl:if>
    <!-- Push the point we're going to move. -->
    <xsl:call-template name="push-point">
      <xsl:with-param name="pt" select="$move-pt"/>
      <xsl:with-param name="zp" select="'1'"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <!-- Do the move. -->
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'MDRP'"/>
      <xsl:with-param name="modifier">
        <xsl:call-template name="mirp-mdrp-bits">
          <xsl:with-param name="set-rp0" select="$set-rp0"/>
          <xsl:with-param name="min-distance" select="$min-distance"/>
          <xsl:with-param name="round-cut-in" select="$rnotno"/>
          <xsl:with-param name="l-color" select="$l-color"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:if test="$rnot">
      <xsl:call-template name="restore-round-state">
        <xsl:with-param name="from-stack" select="true()"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="set-zone-pointers-to-glyph"/>
  </xsl:template>

  <!--

      do-mdap

  -->
  <xsl:template name="do-mdap">
    <xsl:param name="round" select="'yes'"/>
    <xsl:param name="move-pt"/>
    <xsl:param name="mp-container"/>
    <xsl:variable name="rnotno" select="boolean($round != 'no')"/>
    <xsl:variable name="rnot" select="boolean($rnotno and $round != 'yes')"/>
    <xsl:if test="$rnot">
      <!-- We don't save this round state; so what we have stored is the
           previous one. -->
      <xsl:call-template name="do-set-round">
        <xsl:with-param name="round-state" select="$round"/>
        <xsl:with-param name="push-current" select="true()"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
    </xsl:if>
    <!-- Push the point we're going to move. ZP0 for this point. -->
    <xsl:call-template name="push-point">
      <xsl:with-param name="pt" select="$move-pt"/>
      <xsl:with-param name="zp" select="'0'"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <!-- Do the move. -->
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'MDAP'"/>
      <xsl:with-param name="modifier">
        <xsl:call-template name="round-and-cut-in-bit">
          <xsl:with-param name="b" select="$rnotno"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <!-- Restore round state if we changed it. -->
    <xsl:if test="$rnot">
      <xsl:call-template name="restore-round-state">
        <xsl:with-param name="from-stack" select="true()"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="set-zone-pointers-to-glyph"/>
  </xsl:template>

  <xsl:template name="do-alignrp">
    <xsl:param name="move-pts"/>
    <xsl:param name="ref-pt"/>
    <xsl:param name="phantom-ref-pt"/>
    <xsl:param name="mp-container"/>
    <xsl:if test="$ref-pt">
      <xsl:call-template name="push-point">
        <xsl:with-param name="pt" select="$ref-pt"/>
        <xsl:with-param name="zp" select="'0'"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'SRP0'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$move-pts">
      <xsl:call-template name="push-points">
        <xsl:with-param name="pts" select="$move-pts"/>
        <xsl:with-param name="zp" select="'1'"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
      <xsl:if test="count($move-pts) &gt; 1">
        <xsl:call-template name="number-command">
          <xsl:with-param name="num" select="count($move-pts)"/>
          <xsl:with-param name="cmd" select="'SLOOP'"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'ALIGNRP'"/>
      </xsl:call-template>
      <xsl:if test="$move-pts[1]/@zone">
        <xsl:call-template name="set-zone-pointer">
          <xsl:with-param name="z" select="'glyph'"/>
          <xsl:with-param name="zp" select="'1'"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
    <xsl:call-template name="set-zone-pointers-to-glyph"/>
  </xsl:template>

  <xsl:template name="do-iup">
    <xsl:param name="axis"/>
    <xsl:choose>
      <xsl:when test="$axis">
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'IUP'"/>
          <xsl:with-param name="modifier">
            <xsl:call-template name="axis-bit">
              <xsl:with-param name="axis" select="$axis"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'IUP'"/>
          <xsl:with-param name="modifier">
            <xsl:call-template name="axis-bit">
              <xsl:with-param name="axis" select="'x'"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'IUP'"/>
          <xsl:with-param name="modifier">
            <xsl:call-template name="axis-bit">
              <xsl:with-param name="axis" select="'y'"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="do-isect">
    <xsl:param name="move-pt"/>
    <xsl:param name="line-a"/>
    <xsl:param name="line-b"/>
    <xsl:param name="mp-container"/>
    <xsl:call-template name="push-point">
      <xsl:with-param name="pt" select="$move-pt"/>
      <xsl:with-param name="zp" select="'2'"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:apply-templates mode="push-it" select="$line-a">
      <xsl:with-param name="zp" select="'0'"/>
      <xsl:with-param name="zones" select="1"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:apply-templates>
    <xsl:apply-templates mode="push-it" select="$line-b">
      <xsl:with-param name="zp" select="'0'"/>
      <xsl:with-param name="zones" select="1"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:apply-templates>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'ISECT'"/>
    </xsl:call-template>
    <xsl:call-template name="set-zone-pointers-to-glyph"/>
  </xsl:template>

  <xsl:template name="do-shpix">
    <xsl:param name="pts"/>
    <xsl:param name="val"/>
    <xsl:param name="mp-container"/>
    <xsl:if test="$pts">
      <xsl:call-template name="push-points">
        <xsl:with-param name="pts" select="$pts"/>
        <xsl:with-param name="zp" select="'2'"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
      <xsl:call-template name="expression">
        <xsl:with-param name="val" select="$val"/>
        <xsl:with-param name="permitted" select="'1xfvnc'"/>
        <xsl:with-param name="cvt-mode" select="'value'"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
        <xsl:with-param name="to-stack" select="true()"/>
      </xsl:call-template>
      <xsl:if test="count($pts) &gt; 1">
        <xsl:call-template name="number-command">
          <xsl:with-param name="num" select="count($pts)"/>
          <xsl:with-param name="cmd" select="'SLOOP'"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'SHPIX'"/>
      </xsl:call-template>
      <xsl:if test="$pts[1]/@zone">
        <xsl:call-template name="set-zone-pointer">
          <xsl:with-param name="z" select="'glyph'"/>
          <xsl:with-param name="zp" select="'2'"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="do-flippt">
    <xsl:param name="pts"/>
    <xsl:param name="mp-container"/>
    <xsl:if test="$pts">
      <xsl:call-template name="push-points">
        <xsl:with-param name="pts" select="$pts"/>
        <xsl:with-param name="zp" select="'0'"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
      <xsl:if test="count($pts) &gt; 1">
        <xsl:call-template name="number-command">
          <xsl:with-param name="num" select="count($pts)"/>
          <xsl:with-param name="cmd" select="'SLOOP'"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'FLIPPT'"/>
      </xsl:call-template>
      <xsl:if test="$pts[1]/@zone">
        <xsl:call-template name="set-zone-pointer">
          <xsl:with-param name="z" select="'glyph'"/>
          <xsl:with-param name="zp" select="'0'"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="do-alignpts">
    <xsl:param name="pt-one"/>
    <xsl:param name="pt-two"/>
    <xsl:param name="mp-container"/>
    <xsl:call-template name="push-point">
      <xsl:with-param name="pt" select="$pt-one"/>
      <xsl:with-param name="zp" select="'1'"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="push-point">
      <xsl:with-param name="pt" select="$pt-two"/>
      <xsl:with-param name="zp" select="'0'"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'ALIGNPTS'"/>
    </xsl:call-template>
    <xsl:call-template name="set-zone-pointers-to-glyph"/>
  </xsl:template>

  <xsl:template name="do-set-coordinate">
    <xsl:param name="pt"/>
    <xsl:param name="coord"/>
    <xsl:param name="mp-container"/>
    <xsl:call-template name="push-point">
      <xsl:with-param name="pt" select="$pt"/>
      <xsl:with-param name="zp" select="'2'"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="expression">
      <xsl:with-param name="val" select="$coord"/>
      <xsl:with-param name="cvt-mode" select="'value'"/>
      <xsl:with-param name="permitted" select="'1xfvnc'"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
      <xsl:with-param name="to-stack" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SCFS'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="round-always-y">
    <xsl:param name="pts"/>
    <xsl:param name="mp-container"/>
    <xsl:call-template name="push-points">
      <xsl:with-param name="pts" select="$pts"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:for-each select="$pts">
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'MDAP'"/>
        <xsl:with-param name="modifier" select="'1'"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="round-points-with-scfs">
    <xsl:param name="pts"/>
    <xsl:param name="round"/>
    <xsl:param name="mp-container"/>
    <xsl:if test="$round != 'no'">
      <xsl:variable name="must-set-round" select="$round != 'yes'"/>
      <xsl:if test="$must-set-round">
        <xsl:call-template name="do-set-round">
          <xsl:with-param name="round-state" select="$round"/>
          <xsl:with-param name="push-current" select="true()"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:for-each select="$pts">
        <xsl:call-template name="push-point">
          <xsl:with-param name="pt" select="."/>
          <xsl:with-param name="zp" select="'2'"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'DUP'"/>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'GC'"/>
          <xsl:with-param name="modifier">
            <xsl:call-template name="grid-fitted-bit">
              <xsl:with-param name="grid-fitted" select="true()"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'ROUND'"/>
          <xsl:with-param name="modifier">
            <xsl:call-template name="color-bits">
              <xsl:with-param name="l-color" select="$color"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'SCFS'"/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:if test="$must-set-round">
        <xsl:call-template name="restore-round-state">
          <xsl:with-param name="from-stack" select="true()"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- Helper for move with pixel-distance -->
  <xsl:template name="round-stack-top">
    <xsl:param name="rnd"/>
    <xsl:param name="col"/>
    <xsl:param name="mp-container"/>
    <xsl:variable name="rnd-not-yes" select="boolean($rnd != 'yes')"/>
    <xsl:if test="$rnd != 'no'">
      <xsl:if test="$rnd-not-yes">
        <xsl:call-template name="do-set-round">
          <xsl:with-param name="round-state" select="$rnd"/>
          <xsl:with-param name="save" select="false()"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'ROUND'"/>
        <xsl:with-param name="modifier">
          <xsl:call-template name="color-bits">
            <xsl:with-param name="l-color" select="$col"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:if test="$rnd-not-yes">
        <xsl:call-template name="restore-round-state"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
