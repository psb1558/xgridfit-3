<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"
		version="1.0">

  <!--
      This file is part of xgridfit, version 3.
      Licensed under the Apache License, Version 2.0.
      Copyright (c) 2006-20 by Peter S. Baker
  -->
  
  <xsl:template match="xgf:mirp">
    <xsl:param name="mp-container"/>
    <xsl:variable name="local-color">
      <xsl:choose>
	<xsl:when test="@color">
	  <xsl:value-of select="@color"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$color"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="check-for-move-points"/>
    <xsl:call-template name="do-mirp">
      <xsl:with-param name="distance" select="@di"/>
      <xsl:with-param name="round" select="@round"/>
      <xsl:with-param name="cut-in" select="boolean(not(@cut-in) or @cut-in = 'yes')"/>
      <xsl:with-param name="min-distance"
                      select="boolean(not(@min-distance) or @min-distance = 'yes')"/>
      <xsl:with-param name="set-rp0" select="boolean(@set-rp0 = 'yes')"/>
      <xsl:with-param name="l-color" select="$local-color"/>
      <xsl:with-param name="move-pt" select="xgf:pt"/>
      <xsl:with-param name="ref-pt" select="xgf:ref/xgf:pt"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>
  
  <xsl:template match="xgf:miap">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="check-for-move-points"/>
    <xsl:call-template name="do-miap">
      <xsl:with-param name="distance" select="@di"/>
      <xsl:with-param name="round" select="@round"/>
      <xsl:with-param name="cut-in" select="boolean(not(@cut-in) or @cut-in = 'yes')"/>
      <xsl:with-param name="move-pt" select="xgf:pt[1]"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>
  
  <xsl:template match="xgf:mdrp">
    <xsl:param name="mp-container"/>
    <xsl:variable name="local-color">
      <xsl:choose>
	<xsl:when test="@color">
	  <xsl:value-of select="@color"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$color"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="check-for-move-points"/>
    <xsl:call-template name="do-mdrp">
      <xsl:with-param name="round" select="@round"/>
      <xsl:with-param name="min-distance"
                      select="boolean(not(@min-distance) or @min-distance = 'yes')"/>
      <xsl:with-param name="set-rp0" select="boolean(@set-rp0 = 'yes')"/>
      <xsl:with-param name="l-color" select="$local-color"/>
      <xsl:with-param name="move-pt" select="xgf:pt"/>
      <xsl:with-param name="ref-pt" select="xgf:ref/xgf:pt"/>
      <xsl:with-param name="mp-container"
		      select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>
  
  <xsl:template match="xgf:mdap">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="check-for-move-points"/>
    <xsl:call-template name="do-mdap">
      <xsl:with-param name="round" select="@round"/>
      <xsl:with-param name="move-point" select="xgf:pt[1]"/>
      <xsl:with-param name="mp-container"
		      select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>
  
  <xsl:template match="xgf:al">
    <xsl:param name="phantom-ref-pt"/>
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="comp-if">
      <xsl:call-template name="compile-if-test">
	<xsl:with-param name="test" select="@compile-if"/>
	<xsl:with-param name="mp-container"
			select="$mp-container"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="number($comp-if)">
      <xsl:call-template name="check-for-move-points"/>
      <xsl:call-template name="do-alignrp">
	<xsl:with-param name="move-points" select="xgf:pt"/>
	<xsl:with-param name="ref-pt" select="xgf:ref/xgf:pt"/>
	<xsl:with-param name="phantom-ref-pt" select="$phantom-ref-pt"/>
	<xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
      <xsl:apply-templates select="xgf:range|xgf:set" mode="push-me">
	<xsl:with-param name="with-cmd" select="'ALIGNRP'"/>
	<xsl:with-param name="rp-a-o">
	  <xsl:if test="xgf:ref/xgf:pt">
	    <xsl:value-of select="xgf:ref/xgf:pt/@n"/>
	  </xsl:if>
	</xsl:with-param>
	<xsl:with-param name="rp-a">
	  <xsl:if test="$phantom-ref-pt">
	    <xsl:value-of select="$phantom-ref-pt/@n"/>
	  </xsl:if>
	</xsl:with-param>
	<xsl:with-param name="zp" select="'1'"/>
	<xsl:with-param name="mp-container"
			select="$mp-container"/>
      </xsl:apply-templates>
    </xsl:if>
    <xsl:call-template name="debug-end"/>
  </xsl:template>
  
  <xsl:template match="xgf:sh">
    <xsl:param name="rptr"/>
    <xsl:param name="phantom-ref-pt"/>
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="comp-if">
      <xsl:call-template name="compile-if-test">
	<xsl:with-param name="test" select="@compile-if"/>
	<xsl:with-param name="mp-container"
			select="$mp-container"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="number($comp-if)">
      <!-- First establish which ref pointer to use: the default
	   is 1. -->
      <xsl:variable name="ref-ptr">
	<xsl:choose>
	  <xsl:when test="$rptr">
	    <xsl:value-of select="$rptr"/>
	  </xsl:when>
	  <xsl:when test="@ref-ptr">
	    <xsl:value-of select="@ref-ptr"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="1"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <xsl:if test="not($ref-ptr='1' or $ref-ptr='2')">
	<xsl:call-template name="error-message">
	  <xsl:with-param name="msg">
	    <xsl:text>Illegal ref-ptr attribute in sh element: </xsl:text>
	    <xsl:value-of select="$ref-ptr"/>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:if>
      <!-- If there is a ref pt, set the ref pointer
	   and, if applicable, the appropriate zone pointer. -->
      <xsl:if test="xgf:ref/xgf:pt">
	<xsl:call-template name="push-pt">
	  <xsl:with-param name="pt" select="xgf:ref/xgf:pt"/>
	  <xsl:with-param name="zp" select="string(number($ref-ptr)-1)"/>
	  <xsl:with-param name="mp-container"
			  select="$mp-container"/>
	</xsl:call-template>
	<xsl:call-template name="simple-command">
	  <xsl:with-param name="cmd" select="concat('SRP', $ref-ptr)"/>
	</xsl:call-template>
      </xsl:if>
      <!-- If points are present, execute SHP once for all of them. -->
      <xsl:if test="xgf:pt">
	<xsl:call-template name="push-points">
	  <xsl:with-param name="pts" select="xgf:pt"/>
	  <xsl:with-param name="zp" select="'2'"/>
	  <xsl:with-param name="mp-container" select="$mp-container"/>
	</xsl:call-template>
	<xsl:if test="count(xgf:pt) &gt; 1">
	  <xsl:call-template name="number-command">
	    <xsl:with-param name="num" select="count(xgf:pt)"/>
	    <xsl:with-param name="cmd" select="'SLOOP'"/>
	  </xsl:call-template>
	</xsl:if>
	<xsl:call-template name="simple-command">
	  <xsl:with-param name="cmd" select="'SHP'"/>
	  <xsl:with-param name="modifier">
	    <xsl:call-template name="ref-ptr-bit">
	      <xsl:with-param name="ref-ptr" select="$ref-ptr"/>
	    </xsl:call-template>
	  </xsl:with-param>
	</xsl:call-template>
	<xsl:if test="xgf:pt[1]/@zone">
	  <xsl:call-template name="set-zone-pointer">
	    <xsl:with-param name="z" select="'gl'"/>
	    <xsl:with-param name="zp" select="'2'"/>
	  </xsl:call-template>
	</xsl:if>
      </xsl:if>
      <!-- If any ranges or sets are present, execute SHP for each of them. -->
      <xsl:apply-templates select="xgf:range|xgf:set" mode="push-me">
	<xsl:with-param name="with-cmd" select="'SHP'"/>
	<xsl:with-param name="ref-ptr" select="$ref-ptr"/>
	<xsl:with-param name="zp" select="'2'"/>
	<xsl:with-param name="rp-a-o">
	  <xsl:if test="xgf:ref/xgf:pt">
	    <xsl:value-of select="xgf:ref/xgf:pt/@n"/>
	  </xsl:if>
	</xsl:with-param>
	<xsl:with-param name="rp-a">
	  <xsl:if test="$phantom-ref-pt">
	    <xsl:value-of select="$phantom-ref-pt/@n"/>
	  </xsl:if>
	</xsl:with-param>
	<xsl:with-param name="mp-container"
			select="$mp-container"/>
      </xsl:apply-templates>
      <!-- If any contours are present, execute SHC for each of
	   them. -->
      <xsl:for-each select="xgf:contour">
	<!--
	    There is no programmatic difference between pushing a
	    pt and pushing a contour; so we'll just use the
	    "push-pt" template to do this.
	-->
	<xsl:call-template name="push-pt">
	  <xsl:with-param name="pt" select="."/>
	  <xsl:with-param name="zp" select="'2'"/>
	  <xsl:with-param name="mp-container"
			  select="$mp-container"/>
	</xsl:call-template>
	<xsl:call-template name="simple-command">
	  <xsl:with-param name="cmd" select="'SHC'"/>
	  <xsl:with-param name="modifier">
	    <xsl:call-template name="ref-ptr-bit">
	      <xsl:with-param name="ref-ptr" select="$ref-ptr"/>
	    </xsl:call-template>
	  </xsl:with-param>
	</xsl:call-template>
	<xsl:if test="./@zone">
	  <xsl:call-template name="set-zone-pointer">
	    <xsl:with-param name="z" select="'gl'"/>
	    <xsl:with-param name="zp" select="'2'"/>
	  </xsl:call-template>
	</xsl:if>
      </xsl:for-each>
      <!-- And finally sh any zones. -->
      <xsl:for-each select="xgf:zone">
	<xsl:choose>
	  <xsl:when test="./@zone='gl'">
	    <xsl:call-template name="push-num">
	      <xsl:with-param name="num" select="'1'"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:when test="./@zone='twilight'">
	    <xsl:call-template name="push-num">
	      <xsl:with-param name="num" select="'0'"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:call-template name="error-message">
	      <xsl:with-param name="msg">
		<xsl:text>Zone must be either "gl" or "twilight."</xsl:text>
	      </xsl:with-param>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
	<xsl:call-template name="simple-command">
	  <xsl:with-param name="cmd" select="'SHZ'"/>
	  <xsl:with-param name="modifier">
	    <xsl:call-template name="ref-ptr-bit">
	      <xsl:with-param name="ref-ptr" select="$ref-ptr"/>
	    </xsl:call-template>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:for-each>
      <xsl:if test="xgf:pt and @round != 'no'">
	<xsl:call-template name="round-points-with-scfs">
	  <xsl:with-param name="pts" select="xgf:pt"/>
	  <xsl:with-param name="round" select="@round"/>
	  <xsl:with-param name="mp-container"
			  select="$mp-container"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:call-template name="set-zone-pointers-to-gl"/>
    </xsl:if>
    <xsl:call-template name="debug-end"/>
  </xsl:template>
  
  <xsl:template match="xgf:ip">
    <xsl:param name="phantom-ref-pt-a"/>
    <xsl:param name="phantom-ref-pt-b"/>
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="comp-if">
      <xsl:call-template name="compile-if-test">
	<xsl:with-param name="test" select="@compile-if"/>
	<xsl:with-param name="mp-container"
			select="$mp-container"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="number($comp-if)">
      <xsl:call-template name="check-for-move-points"/>
      <xsl:if test="count(xgf:ref/xgf:pt) = 1">
	<xsl:call-template name="error-message">
	  <xsl:with-param name="msg">
	    <xsl:text>There must be two "relative-to" points, if any, in an</xsl:text>
	    <xsl:text>ip instruction.</xsl:text>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:if>
      <xsl:if test="count(xgf:ref/xgf:pt) &gt;= 2">
	<xsl:call-template name="push-pt">
	  <xsl:with-param name="pt" select="xgf:ref/xgf:pt[1]"/>
	  <xsl:with-param name="zp" select="'0'"/>
	  <xsl:with-param name="mp-container"
			  select="$mp-container"/>
	</xsl:call-template>
	<xsl:call-template name="simple-command">
	  <xsl:with-param name="cmd" select="'SRP1'"/>
	</xsl:call-template>
	<xsl:call-template name="push-pt">
	  <xsl:with-param name="pt" select="xgf:ref/xgf:pt[2]"/>
	  <xsl:with-param name="zp" select="'1'"/>
	  <xsl:with-param name="mp-container"
			  select="$mp-container"/>
	</xsl:call-template>
	<xsl:call-template name="simple-command">
	  <xsl:with-param name="cmd" select="'SRP2'"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:if test="xgf:pt">
	<xsl:call-template name="push-points">
	  <xsl:with-param name="pts" select="xgf:pt"/>
	  <xsl:with-param name="zp" select="'2'"/>
	  <xsl:with-param name="mp-container" select="$mp-container"/>
	</xsl:call-template>
	<xsl:if test="count(xgf:pt) &gt; 1">
	  <xsl:call-template name="number-command">
	    <xsl:with-param name="num" select="count(xgf:pt)"/>
	    <xsl:with-param name="cmd" select="'SLOOP'"/>
	  </xsl:call-template>
	</xsl:if>
	<xsl:call-template name="simple-command">
	  <xsl:with-param name="cmd" select="'IP'"/>
	</xsl:call-template>
	<xsl:if test="xgf:pt[1]/@zone">
	  <xsl:call-template name="set-zone-pointer">
	    <xsl:with-param name="z" select="'gl'"/>
	    <xsl:with-param name="zp" select="'2'"/>
	  </xsl:call-template>
	</xsl:if>
      </xsl:if>
      <xsl:apply-templates select="xgf:range|xgf:set" mode="push-me">
	<xsl:with-param name="with-cmd" select="'IP'"/>
	<xsl:with-param name="rp-a-o">
	  <xsl:if test="xgf:ref/xgf:pt[1]">
	    <xsl:value-of select="xgf:ref/xgf:pt[1]/@n"/>
	  </xsl:if>
	</xsl:with-param>
	<xsl:with-param name="rp-a">
	  <xsl:if test="$phantom-ref-pt-a">
	    <xsl:value-of select="$phantom-ref-pt-a/@n"/>
	  </xsl:if>
	</xsl:with-param>
	<xsl:with-param name="rp-b-o">
	  <xsl:if test="xgf:ref/xgf:pt[2]">
	    <xsl:value-of select="xgf:ref/xgf:pt[2]/@n"/>
	  </xsl:if>
	</xsl:with-param>
	<xsl:with-param name="rp-b">
	  <xsl:if test="$phantom-ref-pt-b">
	    <xsl:value-of select="$phantom-ref-pt-b/@n"/>
	  </xsl:if>
	</xsl:with-param>
	<xsl:with-param name="zp" select="'2'"/>
	<xsl:with-param name="mp-container"
			select="$mp-container"/>
      </xsl:apply-templates>
      <xsl:if test="xgf:pt and @round != 'no'">
	<xsl:call-template name="round-points-with-scfs">
	  <xsl:with-param name="pts" select="xgf:pt"/>
	  <xsl:with-param name="round" select="@round"/>
	  <xsl:with-param name="mp-container"
			  select="$mp-container"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:call-template name="set-zone-pointers-to-gl"/>
    </xsl:if>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:flip-on | xgf:flip-off">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:choose>
      <xsl:when test="xgf:range">
	<xsl:apply-templates select="xgf:range" mode="push-me">
	  <xsl:with-param name="with-cmd">
	    <xsl:choose>
	      <xsl:when test="local-name() = 'flip-on'">
		<xsl:value-of select="'FLIPRGON'"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="'FLIPRGOFF'"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:with-param>
	  <xsl:with-param name="zp" select="'0'"/>
	  <xsl:with-param name="mp-container"
			  select="$mp-container"/>
	</xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
    <xsl:call-template name="debug-end"/>
  </xsl:template>
  
  <xsl:template match="xgf:iup">
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="do-iup">
      <xsl:with-param name="axis" select="@axis"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>
  
  <xsl:template match="xgf:move-point-to-intersection">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="check-for-move-points"/>
    <xsl:call-template name="do-isect">
      <xsl:with-param name="move-point" select="xgf:pt"/>
      <xsl:with-param name="line-a" select="xgf:line[1]"/>
      <xsl:with-param name="line-b" select="xgf:line[2]"/>
      <xsl:with-param name="mp-container"
		      select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>
  
  <xsl:template match="xgf:sh-absolute">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="check-for-move-points"/>
    <xsl:call-template name="do-shpix">
      <xsl:with-param name="pts" select="xgf:pt"/>
      <xsl:with-param name="val" select="@pixel-distance"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:apply-templates select="xgf:range|xgf:set" mode="push-me">
      <xsl:with-param name="with-cmd" select="'SHPIX'"/>
      <xsl:with-param name="zp" select="'2'"/>
      <xsl:with-param name="mp-container"
		      select="$mp-container"/>
    </xsl:apply-templates>
    <xsl:call-template name="set-zone-pointers-to-gl"/>
    <xsl:call-template name="debug-end"/>
  </xsl:template>
  
  <xsl:template match="xgf:toggle-points">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="check-for-move-points"/>
    <xsl:call-template name="do-flippt">
      <xsl:with-param name="pts" select="xgf:pt"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:apply-templates select="xgf:range|xgf:set" mode="push-me">
      <xsl:with-param name="with-cmd" select="'FLIPPT'"/>
      <xsl:with-param name="zp" select="'0'"/>
      <xsl:with-param name="mp-container"
		      select="$mp-container"/>
    </xsl:apply-templates>
    <xsl:call-template name="set-zone-pointers-to-gl"/>
    <xsl:call-template name="debug-end"/>
  </xsl:template>
  
  <xsl:template match="xgf:al-midway">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="check-for-move-points"/>
    <xsl:call-template name="do-alignpts">
      <xsl:with-param name="pt-one" select="xgf:pt[1]"/>
      <xsl:with-param name="pt-two" select="xgf:pt[2]"/>
      <xsl:with-param name="mp-container"
		      select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>
  
  <xsl:template match="xgf:set-coordinate">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="check-for-move-points"/>
    <xsl:call-template name="do-set-coordinate">
      <xsl:with-param name="pt" select="xgf:pt[1]"/>
      <xsl:with-param name="coord" select="@coordinate"/>
      <xsl:with-param name="mp-container"
		      select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>
  
  <xsl:template match="xgf:untouch">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="check-for-move-points"/>
    <xsl:call-template name="push-pt">
      <xsl:with-param name="pt" select="xgf:pt[1]"/>
      <xsl:with-param name="zp" select="'0'"/>
      <xsl:with-param name="mp-container"
		      select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'UTP'"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:mv">
    <xsl:param name="mp-container"/>
    <xsl:variable name="local-color">
      <xsl:choose>
	<xsl:when test="@color">
	  <xsl:value-of select="@color"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$color"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- A little optimization: because a "mv" instruction always
         sets RP0 to the "mv" pt after the mv, we check to see
          1. if the preceding instruction was a "mv" instruction;
          2. if the "mv" pt in that instruction was the same as
              the "ref" pt in this one.
         If both of these conditions are true, we can suppress setting
         the RP0 before the mv in MIRP and MDRP instructions. -->
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="comp-if">
      <xsl:call-template name="compile-if-test">
	<xsl:with-param name="test" select="@compile-if"/>
	<xsl:with-param name="mp-container"
			select="$mp-container"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="number($comp-if)">
      <xsl:variable name="set-min-dist-bit" select="not(@min-distance = 'no')"/>
      <xsl:variable name="set-min-dist-val"
		    select="$set-min-dist-bit and @min-distance != 'yes'"/>
      <xsl:variable name="set-cut-in-bit" select="not(@cut-in = 'no')"/>
      <xsl:variable name="set-cut-in-val" select="$set-cut-in-bit and @cut-in != 'yes'"/>
      <xsl:if test="$set-cut-in-val">
	<xsl:call-template name="number-command">
	  <xsl:with-param name="num">
	    <xsl:call-template name="resolve-std-var-loc">
	      <xsl:with-param name="n" select="$var-cv-cut-in"/>
	    </xsl:call-template>
	  </xsl:with-param>
	  <xsl:with-param name="cmd" select="'RS'"/>
	</xsl:call-template>
	<xsl:call-template name="set-simple-graphics-var">
	  <xsl:with-param name="value" select="@cut-in"/>
	  <xsl:with-param name="loc">
	    <xsl:call-template name="resolve-std-var-loc">
	      <xsl:with-param name="n" select="$var-cv-cut-in"/>
	    </xsl:call-template>
	  </xsl:with-param>
	  <xsl:with-param name="cmd" select="'SCVTCI'"/>
	  <xsl:with-param name="may-record-default" select="false()"/>
	  <xsl:with-param name="stack-source-permitted" select="false()"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:if test="$set-min-dist-val">
	<xsl:call-template name="number-command">
	  <xsl:with-param name="num">
	    <xsl:call-template name="resolve-std-var-loc">
	      <xsl:with-param name="n" select="$var-minimum-distance"/>
	    </xsl:call-template>
	  </xsl:with-param>
	  <xsl:with-param name="cmd" select="'RS'"/>
	</xsl:call-template>
	<xsl:call-template name="set-simple-graphics-var">
	  <xsl:with-param name="value" select="@min-distance"/>
	  <xsl:with-param name="loc">
	    <xsl:call-template name="resolve-std-var-loc">
	      <xsl:with-param name="n" select="$var-minimum-distance"/>
	    </xsl:call-template>
	  </xsl:with-param>
	  <xsl:with-param name="cmd" select="'SMD'"/>
	  <xsl:with-param name="may-record-default" select="false()"/>
	  <xsl:with-param name="stack-source-permitted" select="false()"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:variable name="rnd">
	<xsl:choose>
	  <xsl:when test="@round">
	    <xsl:value-of select="@round"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>yes</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <xsl:variable name="prev-el-pt">
	<xsl:choose>
	  <xsl:when test="local-name(preceding-sibling::*[1]) =
			  'mv'">
	    <xsl:call-template name="expression-with-offset">
	      <xsl:with-param name="val"
			      select="preceding-sibling::xgf:mv[1]/xgf:pt/@n"/>
	      <xsl:with-param name="permitted" select="'1nf'"/>
	      <xsl:with-param name="mp-container" select="$mp-container"/>
	      <xsl:with-param name="called-from" select="'mv-1'"/>
	      <xsl:with-param name="to-stack" select="false()"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>NaN</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <xsl:variable name="this-el-pt">
	<xsl:choose>
	  <xsl:when test="xgf:ref/xgf:pt">
	    <xsl:call-template name="expression-with-offset">
	      <xsl:with-param name="val" select="xgf:ref/xgf:pt/@n"/>
	      <xsl:with-param name="permitted" select="'1nf'"/>
	      <xsl:with-param name="mp-container" select="$mp-container"/>
	      <xsl:with-param name="called-from" select="'mv-2'"/>
	      <xsl:with-param name="to-stack" select="false()"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>NaN</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <xsl:variable name="nested" select="boolean(ancestor::xgf:mv
					  or ancestor::xgf:mv)"/>
      <xsl:variable name="suppress-set-rp0"
		    select="boolean($prev-el-pt != 'NaN' and
			    number($prev-el-pt) = number($this-el-pt))"/>
      <xsl:variable name="set-rp0-after"
		    select="not($nested) or boolean(xgf:mv) or
			    boolean(xgf:al)"/>
      <xsl:call-template name="check-for-move-points"/>
      <!--
	  If this is a nested mv and it's going to do anything to
	  change RP0, then we've got to save the pt of the parent
	  mv on the stack so that we can restore it to RP0
	  afterwards.
      -->
      <xsl:variable name="save-rp0-pt-on-stack"
		    select="$nested and ($set-rp0-after or xgf:ref)"/>
      <xsl:if test="$save-rp0-pt-on-stack">
	<xsl:call-template name="push-pt">
	  <xsl:with-param name="pt" select="../xgf:pt"/>
	  <xsl:with-param name="mp-container"
			  select="$mp-container"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:choose>
	<xsl:when test="boolean(xgf:ref/xgf:pt) or $nested">
	  <xsl:variable name="local-suppress-set-rp0"
			select="$suppress-set-rp0 or
				($nested and not(xgf:ref/xgf:pt))"/>
	  <xsl:choose>
	    <xsl:when test="@di">
	      <xsl:call-template name="do-mirp">
		<xsl:with-param name="distance" select="@di"/>
		<xsl:with-param name="round" select="$rnd"/>
		<xsl:with-param name="cut-in" select="$set-cut-in-bit"/>
		<xsl:with-param name="min-distance" select="$set-min-dist-bit"/>
		<xsl:with-param name="set-rp0" select="$set-rp0-after"/>
		<xsl:with-param name="l-color" select="$local-color"/>
		<xsl:with-param name="move-point" select="xgf:pt"/>
		<xsl:with-param name="ref-pt" select="xgf:ref/xgf:pt"/>
		<xsl:with-param name="suppress-set-rp0" select="$local-suppress-set-rp0"/>
		<xsl:with-param name="mp-container" select="$mp-container"/>
	      </xsl:call-template>
	    </xsl:when>
	    <xsl:when test="@pixel-distance">
	      <xsl:if test="not($local-suppress-set-rp0)">
		<xsl:call-template name="push-pt">
		  <xsl:with-param name="pt" select="xgf:ref/xgf:pt"/>
		  <xsl:with-param name="zp" select="'0'"/>
		  <xsl:with-param name="mp-container"
				  select="$mp-container"/>
		</xsl:call-template>
		<xsl:call-template name="simple-command">
		  <xsl:with-param name="cmd" select="'SRP0'"/>
		</xsl:call-template>
	      </xsl:if>
	      <xsl:call-template name="push-pt">
		<xsl:with-param name="pt" select="xgf:pt"/>
		<xsl:with-param name="zp" select="'1'"/>
		<xsl:with-param name="mp-container"
				select="$mp-container"/>
	      </xsl:call-template>
	      <xsl:call-template name="expression">
		<xsl:with-param name="val" select="@pixel-distance"/>
		<xsl:with-param name="cvt-mode" select="'value'"/>
		<xsl:with-param name="permitted" select="'1xfvnc'"/>
		<xsl:with-param name="mp-container"
				select="$mp-container"/>
		<xsl:with-param name="to-stack" select="true()"/>
	      </xsl:call-template>
	      <xsl:call-template name="round-stack-top">
		<xsl:with-param name="rnd" select="$rnd"/>
		<xsl:with-param name="col" select="$local-color"/>
		<xsl:with-param name="mp-container"
				select="$mp-container"/>
	      </xsl:call-template>
	      <xsl:call-template name="simple-command">
		<xsl:with-param name="cmd" select="'MSIRP'"/>
		<xsl:with-param name="modifier">
		  <xsl:call-template name="rp0-bit">
		    <xsl:with-param name="set-rp0" select="$set-rp0-after"/>
		  </xsl:call-template>
		</xsl:with-param>
	      </xsl:call-template>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:call-template name="do-mdrp">
		<xsl:with-param name="round" select="$rnd"/>
		<xsl:with-param name="min-distance" select="$set-min-dist-bit"/>
		<xsl:with-param name="set-rp0" select="$set-rp0-after"/>
		<xsl:with-param name="l-color" select="$local-color"/>
		<xsl:with-param name="move-point" select="xgf:pt"/>
		<xsl:with-param name="ref-pt" select="xgf:ref/xgf:pt"/>
		<xsl:with-param name="suppress-set-rp0" select="$local-suppress-set-rp0"/>
		<xsl:with-param name="mp-container"
				select="$mp-container"/>
	      </xsl:call-template>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:choose>
	    <xsl:when test="@di">
	      <xsl:call-template name="do-miap">
		<xsl:with-param name="distance" select="@di"/>
		<xsl:with-param name="round" select="$rnd"/>
		<xsl:with-param name="cut-in" select="$set-cut-in-bit"/>
		<xsl:with-param name="move-point" select="xgf:pt"/>
		<xsl:with-param name="mp-container" select="$mp-container"/>
	      </xsl:call-template>
	    </xsl:when>
	    <xsl:when test="@pixel-distance">
	      <xsl:call-template name="push-pt">
		<xsl:with-param name="pt" select="xgf:pt[1]"/>
		<xsl:with-param name="zp" select="'2'"/>
		<xsl:with-param name="mp-container"
				select="$mp-container"/>
	      </xsl:call-template>
	      <xsl:call-template name="simple-command">
		<xsl:with-param name="cmd" select="'DUP'"/>
	      </xsl:call-template>
	      <xsl:call-template name="simple-command">
		<xsl:with-param name="cmd" select="'SRP1'"/>
	      </xsl:call-template>
	      <xsl:call-template name="expression">
		<xsl:with-param name="val" select="@pixel-distance"/>
		<xsl:with-param name="cvt-mode" select="'value'"/>
		<xsl:with-param name="permitted" select="'1xfvnc'"/>
		<xsl:with-param name="mp-container"
				select="$mp-container"/>
		<xsl:with-param name="to-stack" select="true()"/>
	      </xsl:call-template>
	      <xsl:call-template name="round-stack-top">
		<xsl:with-param name="rnd" select="$rnd"/>
		<xsl:with-param name="col" select="$local-color"/>
		<xsl:with-param name="mp-container"
				select="$mp-container"/>
	      </xsl:call-template>
	      <xsl:call-template name="simple-command">
		<xsl:with-param name="cmd" select="'SCFS'"/>
	      </xsl:call-template>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:call-template name="do-mdap">
		<xsl:with-param name="round" select="$rnd"/>
		<xsl:with-param name="move-point" select="xgf:pt"/>
		<xsl:with-param name="mp-container"
				select="$mp-container"/>
	      </xsl:call-template>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="xgf:delta[not(preceding-sibling::xgf:al) and
				   not(preceding-sibling::xgf:ip) and
				   not(preceding-sibling::xgf:sh) and
				   not(preceding-sibling::xgf:mv)]">
	<xsl:with-param name="mp-container"
			select="$mp-container"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="xgf:al">
	<xsl:with-param name="phantom-ref-pt" select="xgf:pt"/>
	<xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:apply-templates>
      <!-- ip will only work if we can identify a ref
	   pt.  That's because MIRP, MDRP and MSIRP set up the
	   ref points properly for ip, but MIAP and MDAP
	   do not. -->
      <xsl:if test="xgf:ip and
		    ($nested or boolean(xgf:ref/xgf:pt))">
	<xsl:choose>
	  <xsl:when test="xgf:ref/xgf:pt">
	    <xsl:apply-templates select="xgf:ip">
	      <xsl:with-param name="phantom-ref-pt-a"
			      select="xgf:ref/xgf:pt"/>
	      <xsl:with-param name="phantom-ref-pt-b"
			      select="xgf:pt"/>
	      <xsl:with-param name="mp-container" select="$mp-container"/>
	    </xsl:apply-templates>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:apply-templates select="xgf:ip">
	      <xsl:with-param name="phantom-ref-pt-a"
			      select="ancestor::xgf:mv/xgf:pt"/>
	      <xsl:with-param name="phantom-ref-pt-b"
			      select="xgf:pt"/>
	      <xsl:with-param name="mp-container" select="$mp-container"/>
	    </xsl:apply-templates>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:if>
      <!-- A SHP instruction should use RP2 if a ref pt was
	   used (MIRP or MDRP); otherwise RP1 (MIAP or MDAP). -->
      <xsl:choose>
	<xsl:when test="$nested or boolean(xgf:ref/xgf:pt)">
	  <xsl:apply-templates select="xgf:sh">
	    <xsl:with-param name="rptr" select="2"/>
	    <xsl:with-param name="phantom-ref-pt" select="xgf:pt"/>
	    <xsl:with-param name="mp-container" select="$mp-container"/>
	  </xsl:apply-templates>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates select="xgf:sh">
	    <xsl:with-param name="rptr" select="1"/>
	    <xsl:with-param name="phantom-ref-pt" select="xgf:pt"/>
	    <xsl:with-param name="mp-container" select="$mp-container"/>
	  </xsl:apply-templates>
	</xsl:otherwise>
      </xsl:choose>
      <!-- A nested mv element implicitly has as a ref pt the
	   pt just moved by the parent mv element (with first delta
	   applied).
      -->
      <xsl:apply-templates select="xgf:mv">
	<xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="xgf:delta[preceding-sibling::xgf:al or
				   preceding-sibling::xgf:ip or
				   preceding-sibling::xgf:sh or
				   preceding-sibling::xgf:mv]">
	<xsl:with-param name="mp-container"
			select="$mp-container"/>
      </xsl:apply-templates>
      <xsl:if test="$save-rp0-pt-on-stack">
	<xsl:call-template name="simple-command">
	  <xsl:with-param name="cmd" select="'SRP0'"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:if test="$set-min-dist-val">
	<xsl:call-template name="simple-command">
	  <xsl:with-param name="cmd" select="'DUP'"/>
	</xsl:call-template>
	<xsl:call-template name="simple-command">
	  <xsl:with-param name="cmd" select="'SMD'"/>
	</xsl:call-template>
	<xsl:call-template name="stack-top-to-storage">
	  <xsl:with-param name="loc">
	    <xsl:call-template name="resolve-std-var-loc">
	      <xsl:with-param name="n" select="$var-minimum-distance"/>
	    </xsl:call-template>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:if>
      <xsl:if test="$set-cut-in-val">
	<xsl:call-template name="simple-command">
	  <xsl:with-param name="cmd" select="'DUP'"/>
	</xsl:call-template>
	<xsl:call-template name="simple-command">
	  <xsl:with-param name="cmd" select="'SCVTCI'"/>
	</xsl:call-template>
	<xsl:call-template name="stack-top-to-storage">
	  <xsl:with-param name="loc">
	    <xsl:call-template name="resolve-std-var-loc">
	      <xsl:with-param name="n" select="$var-cv-cut-in"/>
	    </xsl:call-template>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:if>
    </xsl:if>
    <xsl:call-template name="debug-end"/>
  </xsl:template>
  
  <xsl:template match="xgf:diagonal-stem">
    <xsl:param name="mp-container"/>
    <xsl:variable name="local-color">
      <xsl:choose>
	<xsl:when test="@color">
	  <xsl:value-of select="@color"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$color"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="set-min-dist-bit" select="not(@min-distance = 'no')"/>
    <xsl:variable name="set-min-dist-val"
		  select="$set-min-dist-bit and @min-distance != 'yes'"/>
    <xsl:if test="$set-min-dist-val">
      <xsl:call-template name="number-command">
	<xsl:with-param name="num">
	  <xsl:call-template name="resolve-std-var-loc">
	    <xsl:with-param name="n" select="$var-minimum-distance"/>
	  </xsl:call-template>
	</xsl:with-param>
	<xsl:with-param name="cmd" select="'RS'"/>
      </xsl:call-template>
      <xsl:call-template name="set-simple-graphics-var">
	<xsl:with-param name="value" select="@min-distance"/>
	<xsl:with-param name="cmd" select="'SMD'"/>
	<xsl:with-param name="save" select="false()"/>
	<xsl:with-param name="stack-source-permitted" select="false()"/>
      </xsl:call-template>
    </xsl:if>
    <!-- Line 1 will be checked by do-set-vector. -->
    <xsl:call-template name="check-line">
      <xsl:with-param name="l" select="xgf:line[2]"/>
    </xsl:call-template>
    <xsl:variable name="rnd">
      <xsl:choose>
        <xsl:when test="@round">
          <xsl:value-of select="@round"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>yes</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="@save-vectors='yes'">
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'GPV'"/>
      </xsl:call-template>
      <xsl:if test="@freedom-vector='yes'">
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'GFV'"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
    <xsl:call-template name="do-set-vector">
      <xsl:with-param name="which-vector" select="'P'"/>
      <xsl:with-param name="line" select="xgf:line[1]"/>
      <xsl:with-param name="to-line" select="'orthogonal'"/>
      <xsl:with-param name="stack-source-permitted" select="false()"/>
      <xsl:with-param name="mp-container"
		      select="$mp-container"/>
    </xsl:call-template>
    <xsl:if test="@freedom-vector='yes'">
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'SFVTPV'"/>
      </xsl:call-template>
    </xsl:if>
    <!-- The tricky part, here and below, is to get a ref to a pt out of
         a line with a ref - that is, a line element that is a ref to
         another line element. You might think it could be done via a template and
         a var, but you end up with a useless result tree fragment. And I haven't
         (yet) managed to come up with a predicate expression that actually works. So
         here we are doing some things twice: once for a line element with a ref,
         and one for one without (i.e. with points). It's clunky, but it keeps us
         completely inside the standard and so very portable. -->
    <xsl:choose>
      <xsl:when test="xgf:line[1]/@ref">
        <xsl:call-template name="push-pt">
          <!-- 4xslt sometimes fails to resolve the following XPath expression.
               I can't figure out what's wrong. No error message. Xalan, Saxon,
               libxslt work fine. -->
          <xsl:with-param name="pt"
                          select="ancestor::xgf:gl/descendant::xgf:line[@nm =
                                  current()/xgf:line[1]/@ref]/xgf:pt[2]"/>
	  <xsl:with-param name="mp-container"
			  select="$mp-container"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="push-pt">
          <xsl:with-param name="pt" select="xgf:line[1]/xgf:pt[2]"/>
	  <xsl:with-param name="mp-container"
			  select="$mp-container"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SRP0'"/>
    </xsl:call-template>
    <xsl:if test="count(xgf:al) &gt;= 2">
      <xsl:apply-templates select="xgf:al[1]">
	<xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:apply-templates>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="xgf:line[2]/@ref">
        <xsl:call-template name="do-mirp">
          <xsl:with-param name="distance" select="@di"/>
          <xsl:with-param name="round" select="$rnd"/>
          <xsl:with-param name="cut-in"
                          select="boolean(not(@cut-in) or @cut-in = 'yes')"/>
	  <xsl:with-param name="min-distance" select="$set-min-dist-bit"/>
          <xsl:with-param name="l-color" select="$local-color"/>
          <xsl:with-param name="move-point"
                          select="ancestor::xgf:gl/descendant::xgf:line[@nm =
                                  current()/xgf:line[2]/@ref]/xgf:pt[2]"/>
	  <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="do-mirp">
          <xsl:with-param name="distance" select="@di"/>
          <xsl:with-param name="round" select="$rnd"/>
          <xsl:with-param name="cut-in"
                          select="boolean(not(@cut-in) or @cut-in = 'yes')"/>
	  <xsl:with-param name="min-distance" select="$set-min-dist-bit"/>
          <xsl:with-param name="l-color" select="$local-color"/>
          <xsl:with-param name="move-point" select="xgf:line[2]/xgf:pt[2]"/>
	<xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="xgf:line[1]/@ref">
        <xsl:call-template name="push-pt">
          <!-- 4xslt sometimes fails to resolve the following XPath expression.
               I can't figure out what's wrong. No error message. -->
          <xsl:with-param name="pt"
                          select="ancestor::xgf:gl/descendant::xgf:line[@nm =
                                  current()/xgf:line[1]/@ref]/xgf:pt[1]"/>
	  <xsl:with-param name="mp-container"
			  select="$mp-container"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="push-pt">
          <xsl:with-param name="pt" select="xgf:line[1]/xgf:pt[1]"/>
	  <xsl:with-param name="mp-container"
			  select="$mp-container"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SRP0'"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="xgf:line[2]/@ref">
        <xsl:call-template name="do-mirp">
          <xsl:with-param name="distance" select="@di"/>
          <xsl:with-param name="round" select="$rnd"/>
          <xsl:with-param name="cut-in"
                          select="boolean(not(@cut-in) or @cut-in = 'yes')"/>
	  <xsl:with-param name="min-distance" select="$set-min-dist-bit"/>
          <xsl:with-param name="l-color" select="$local-color"/>
          <xsl:with-param name="move-point"
                          select="ancestor::xgf:gl/descendant::xgf:line[@nm =
                                  current()/xgf:line[2]/@ref]/xgf:pt[1]"/>
          <xsl:with-param name="set-rp0" select="true()"/>
	  <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="do-mirp">
          <xsl:with-param name="distance" select="@di"/>
          <xsl:with-param name="round" select="$rnd"/>
          <xsl:with-param name="cut-in"
                          select="boolean(not(@cut-in) or @cut-in = 'yes')"/>
	  <xsl:with-param name="min-distance" select="$set-min-dist-bit"/>
          <xsl:with-param name="l-color" select="$local-color"/>
          <xsl:with-param name="move-point" select="xgf:line[2]/xgf:pt[1]"/>
          <xsl:with-param name="set-rp0" select="true()"/>
	  <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="count(xgf:al) = 1">
        <xsl:apply-templates select="xgf:al">
	  <xsl:with-param name="mp-container" select="$mp-container"/>
	</xsl:apply-templates>
      </xsl:when>
      <xsl:when test="count(xgf:al) &gt;= 2">
        <xsl:apply-templates select="xgf:al[2]">
	  <xsl:with-param name="mp-container" select="$mp-container"/>
	</xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="@save-vectors='yes'">
      <xsl:if test="@freedom-vector='yes'">
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'SFVFS'"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'SPVFS'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$set-min-dist-val">
      <xsl:call-template name="simple-command">
	<xsl:with-param name="cmd" select="'SMD'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

</xsl:stylesheet>
