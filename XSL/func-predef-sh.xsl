<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!--
      This file is part of xgridfit, version 3.
      Licensed under the Apache License, Version 2.0.
      Copyright (c) 2006-20 by Peter S. Baker
  -->

  <!-- Function 0 restores a saved round state. Tested and corrected 4
       Mar. 2004.  Translated into portable xgridfit template calls 10
       May 2005.  For the meanings of the round state number, see
       <xgfd:round-state> in xgfdata.xml. For the meanings of the
       sround data, see <xgfd:period>, <xgfd:phase> and
       <xgfd:threshold>. -->
  <xsl:template name="fn-zero">
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="$fn-round-restore"/>
    </xsl:call-template>
<!--
    <xsl:choose>
      <xsl:when test="$merge-mode">
	<xsl:call-template name="push-num">
	  <xsl:with-param name="num" select="'#fn#'"/>
	  <xsl:with-param name="size" select="'B'"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="push-num">
	  <xsl:with-param name="num" select="$fn-round-restore"/>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
-->
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'FDEF'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="expect" select="2"/>
      <xsl:with-param name="num" select="0"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="add-mode" select="true()"/>
      <xsl:with-param name="num">
        <xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-round-state"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'EQ'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="5"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SWAP'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'JROF'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RTG'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="77"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'JMPR'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="1"/>
      <xsl:with-param name="expect" select="2"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-round-state"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'EQ'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="5"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SWAP'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'JROF'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RTHG'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="64"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'JMPR'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="2"/>
      <xsl:with-param name="expect" select="2"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
        <xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-round-state"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'EQ'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="5"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SWAP'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'JROF'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RTDG'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="51"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'JMPR'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="3"/>
      <xsl:with-param name="expect" select="2"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
        <xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-round-state"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'EQ'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="5"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SWAP'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'JROF'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RDTG'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="38"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'JMPR'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="4"/>
      <xsl:with-param name="expect" select="2"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
        <xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-round-state"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'EQ'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="5"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SWAP'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'JROF'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RUTG'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="25"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'JMPR'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="5"/>
      <xsl:with-param name="expect" select="2"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
        <xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-round-state"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'EQ'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="5"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SWAP'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'JROF'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'ROFF'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="12"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'JMPR'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="6"/>
      <xsl:with-param name="expect" select="2"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
        <xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-round-state"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'EQ'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'IF'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-sround-info"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SROUND'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'EIF'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'ENDF'"/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- The fn defined here is for initializing the variables that track
       the graphics state. It copies values from locations where this font's
       defaults are stored to the locations used for tracking. It is called
       at the beginning of each gl program. -->
  <xsl:template name="fn-one">
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="$fn-gl-prolog"/>
    </xsl:call-template>
<!--
    <xsl:choose>
      <xsl:when test="$merge-mode">
	<xsl:call-template name="push-num">
	  <xsl:with-param name="num" select="'#fn#'"/>
	  <xsl:with-param name="size" select="'B'"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="push-num">
	  <xsl:with-param name="num" select="$fn-gl-prolog"/>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
-->
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'FDEF'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
        <xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-round-state"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="expect" select="16"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
        <xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-round-state-default"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-sround-info"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-sround-info-default"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-minimum-distance"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-minimum-distance-default"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-cv-cut-in"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-cv-cut-in-default"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-single-width-cut-in"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-single-width-cut-in-default"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-single-width"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-single-width-default"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-delta-base"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-delta-base-default"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-delta-sh"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-delta-sh-default"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'WS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'WS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'WS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'WS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'WS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'WS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'WS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'WS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'ENDF'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Function two does the run-time work of getting a range of points
       onto the stack given just the endpoints and (up to) two points
       to exclude. -->
  <xsl:template name="fn-two">
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="$fn-push-range"/>
    </xsl:call-template>
<!--
    <xsl:choose>
      <xsl:when test="$merge-mode">
	<xsl:call-template name="push-num">
	  <xsl:with-param name="num" select="'#fn#'"/>
	  <xsl:with-param name="size" select="'B'"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="push-num">
	  <xsl:with-param name="num" select="$fn-push-range"/>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
-->
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'FDEF'"/>
    </xsl:call-template>
    <!--
	When this is called, the two values on top of the stack should
	be the two ref pointers (can use a value -1 to take one
	or both out of play). The next two values should be the two
	end-points of the range we are pushing.
    -->
    <xsl:call-template name="stack-top-to-storage">
      <xsl:with-param name="loc">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg3"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="stack-top-to-storage">
      <xsl:with-param name="loc">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg2"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="stack-top-to-storage">
      <xsl:with-param name="loc">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg1"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="stack-top-to-storage">
      <xsl:with-param name="loc">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg0"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <!-- Initialize the return value (which is also our counter) -->
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-return-value"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="expect" select="2"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="0"/>
      <xsl:with-param name="add-mode" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'WS'"/>
    </xsl:call-template>
    <!-- reg0 has got to be the lower of the two endpoints. If it is not,
    swap them. -->
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg0"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg1"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'GT'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'IF'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg0"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg1"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="stack-top-to-storage">
      <xsl:with-param name="loc">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg0"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>    
    <xsl:call-template name="stack-top-to-storage">
      <xsl:with-param name="loc">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg1"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>    
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'EIF'"/>
    </xsl:call-template>
    <!-- Get reg0 (the lower pt) onto the stack -->
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg0"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <!-- The loop begins here. If current != reg2 and current != reg3 . . . -->
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'DUP'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'DUP'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg2"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'NEQ'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SWAP'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg3"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'NEQ'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'AND'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'IF'"/>
    </xsl:call-template>
    <!-- One copy is pushed, the other kept for the next iteration of the loop. -->
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'DUP'"/>
    </xsl:call-template>
    <!-- Increment the count we're keeping of points pushed. -->
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-return-value"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="1"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'ADD'"/>
    </xsl:call-template>
    <xsl:call-template name="stack-top-to-storage">
      <xsl:with-param name="loc">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$var-return-value"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'EIF'"/>
    </xsl:call-template>
    <!-- We've got the current value on the stack once if we are discarding,
    twice if we're keeping. Increment it, get an extra copy and compare
    it with reg1, the upper pt. If GT, stop the loop. -->
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="1"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'ADD'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'DUP'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg1"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'GT'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="-37"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SWAP'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'JROF'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'POP'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'ENDF'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Function three takes the top two numbers from the stack and
       makes sure they are arranged with the higher one on top. -->
  <xsl:template name="fn-three">
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="$fn-order-range"/>
    </xsl:call-template>
<!--
    <xsl:choose>
      <xsl:when test="$merge-mode">
	<xsl:call-template name="push-num">
	  <xsl:with-param name="num" select="'#fn#'"/>
	  <xsl:with-param name="size" select="'B'"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="push-num">
	  <xsl:with-param name="num" select="$fn-order-range"/>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
-->
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'FDEF'"/>
    </xsl:call-template>
    <xsl:call-template name="stack-top-to-storage">
      <xsl:with-param name="loc">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg0"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="stack-top-to-storage">
      <xsl:with-param name="loc">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg1"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <!-- reg0 has got to be the higher of the two endpoints. If it is not,
    swap them. -->
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg0"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg1"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'GT'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'IF'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg1"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg0"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'ELSE'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg0"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
	<xsl:call-template name="resolve-std-var-loc">
	  <xsl:with-param name="n" select="$reg1"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'EIF'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'ENDF'"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
