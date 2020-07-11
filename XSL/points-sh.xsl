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
      Contains routines for pushing points, lines and ranges.
  -->

  <!--

      push-points

      Push all the pt-numbers specified by the node-set
      "pts" onto the stack. If the first pt in the
      set has a "zone" attribute, set the zone. Also the
      second, if $zp-b has been specified. A "zone"
      attribute in any of the following points is ignored.

      If all of the points passed to this template can be
      resolved to simple, byte-sized numbers, they are all
      pushed onto the stack with a single command.
  -->
  <xsl:template name="push-points">
    <xsl:param name="pts"/>
    <xsl:param name="zp"/>
    <xsl:param name="zp-b"/>
    <xsl:param name="mp-container"/>
    <xsl:if test="$zp and $pts[1]/@zone">
      <xsl:call-template name="set-zone-pointer">
        <xsl:with-param name="z" select="$pts[1]/@zone"/>
        <xsl:with-param name="zp" select="$zp"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$zp-b and $pts[2]/@zone">
      <xsl:call-template name="set-zone-pointer">
        <xsl:with-param name="z" select="$pts[2]/@zone"/>
        <xsl:with-param name="zp" select="$zp-b"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="push-list">
      <xsl:with-param name="list">
	<xsl:for-each select="$pts">
	  <xsl:if test="position() &gt; 1">
	    <xsl:value-of select="';'"/>
	  </xsl:if>
	  <xsl:value-of select="./@n"/>
	</xsl:for-each>
      </xsl:with-param>
      <xsl:with-param name="is-pt-list" select="true()"/>
      <xsl:with-param name="permitted" select="'1fvn'"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
  </xsl:template>

  <!--

      push-pt

      Push a pt and, optionally, set a zone pointer to match its
      "zone" attribute
  -->
  <xsl:template name="push-pt">
    <xsl:param name="pt"/>
    <xsl:param name="zp"/>
    <xsl:param name="expect" select="1"/>
    <xsl:param name="mp-container"/>
    <xsl:if test="$zp and $pt/@zone">
      <xsl:call-template name="set-zone-pointer">
        <xsl:with-param name="z" select="$pt/@zone"/>
        <xsl:with-param name="zp" select="$zp"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="expression-with-offset">
      <xsl:with-param name="val" select="$pt/@n"/>
      <xsl:with-param name="permitted" select="'1fvn'"/>
      <xsl:with-param name="expect" select="$expect"/>
      <xsl:with-param name="called-from" select="'push-pt-1'"/>
      <xsl:with-param name="mp-container"
		      select="$mp-container"/>
      <xsl:with-param name="to-stack" select="true()"/>
<!--      <xsl:with-param name="debug" select="true()"/> -->
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="xgf:range" mode="push-me">
    <xsl:param name="with-cmd"/>
    <xsl:param name="zp"/>
    <xsl:param name="ref-ptr"/>
    <xsl:param name="use-sloop" select="true()"/>
    <xsl:param name="rp-a-o"/>
    <xsl:param name="rp-a"/>
    <xsl:param name="rp-b-o"/>
    <xsl:param name="rp-b"/>
    <xsl:param name="mp-container"/>
    <xsl:param name="all-mo-params"
	       select="ancestor::xgf:mo/xgf:pm|
		       ancestor::xgf:gl/xgf:pm"/>
    <xsl:param name="this-id">
      <xsl:call-template name="get-first-mp-id">
	<xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
    </xsl:param>
    <xsl:param name="mpcs" select="$mp-containers[generate-id()=$this-id]"/>
    <xsl:choose>
      <!-- A. There are points in this range. -->
      <xsl:when test="count(xgf:pt) = 2">
        <xsl:if test="$zp and @zone">
          <xsl:call-template name="set-zone-pointer">
            <xsl:with-param name="z" select="@zone"/>
            <xsl:with-param name="zp" select="$zp"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="push-points">
          <xsl:with-param name="pts" select="xgf:pt"/>
	  <xsl:with-param name="mp-container"
			  select="$mp-container"/>
        </xsl:call-template>
	<xsl:if test="$with-cmd != 'FLIPRGON' and $with-cmd != 'FLIPRGOFF'">
	  <xsl:choose>
	    <xsl:when test="string-length($rp-a-o)">
	      <xsl:call-template name="expression">
		<xsl:with-param name="val" select="$rp-a-o"/>
		<xsl:with-param name="mp-container"
				select="$mp-container"/>
		<xsl:with-param name="to-stack" select="true()"/>
	      </xsl:call-template>
	    </xsl:when>
	    <xsl:when test="string-length($rp-a)">
	      <xsl:call-template name="expression">
		<xsl:with-param name="val" select="$rp-a"/>
		<xsl:with-param name="mp-container"
				select="$mp-container"/>
		<xsl:with-param name="to-stack" select="true()"/>
	      </xsl:call-template>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:call-template name="push-num">
		<xsl:with-param name="num" select="-1"/>
	      </xsl:call-template>
	    </xsl:otherwise>
	  </xsl:choose>
	  <xsl:choose>
	    <xsl:when test="string-length($rp-b-o)">
	      <xsl:call-template name="expression">
		<xsl:with-param name="val" select="$rp-b-o"/>
		<xsl:with-param name="mp-container"
				select="$mp-container"/>
		<xsl:with-param name="to-stack" select="true()"/>
	      </xsl:call-template>
	    </xsl:when>
	    <xsl:when test="string-length($rp-b)">
	      <xsl:call-template name="expression">
		<xsl:with-param name="val" select="$rp-b"/>
		<xsl:with-param name="mp-container"
				select="$mp-container"/>
		<xsl:with-param name="to-stack" select="true()"/>
	      </xsl:call-template>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:call-template name="push-num">
		<xsl:with-param name="num" select="-1"/>
	      </xsl:call-template>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:if>
	<xsl:choose>
	  <xsl:when test="$with-cmd = 'FLIPRGON' or $with-cmd = 'FLIPRGOFF'">
	    <xsl:call-template name="number-command">
	      <xsl:with-param name="num" select="$fn-order-range"/>
	      <xsl:with-param name="cmd" select="'CALL'"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:call-template name="number-command">
	      <xsl:with-param name="num" select="$fn-push-range"/>
	      <xsl:with-param name="cmd" select="'CALL'"/>
	    </xsl:call-template>
	    <xsl:if test="$use-sloop">
	      <xsl:call-template name="number-command">
		<xsl:with-param name="num">
		  <xsl:call-template name="resolve-std-var-loc">
		    <xsl:with-param name="n" select="$var-return-value"/>
		  </xsl:call-template>
		</xsl:with-param>
		<xsl:with-param name="cmd" select="'RS'"/>
	      </xsl:call-template>
	      <xsl:call-template name="push-num">
		<xsl:with-param name="num" select="1"/>
	      </xsl:call-template>
	      <xsl:call-template name="simple-command">
		<xsl:with-param name="cmd" select="'GT'"/>
	      </xsl:call-template>
	      <xsl:call-template name="simple-command">
		<xsl:with-param name="cmd" select="'IF'"/>
	      </xsl:call-template>
	      <xsl:call-template name="number-command">
		<xsl:with-param name="num">
		  <xsl:call-template name="resolve-std-var-loc">
		    <xsl:with-param name="n" select="$var-return-value"/>
		  </xsl:call-template>
		</xsl:with-param>
		<xsl:with-param name="cmd" select="'RS'"/>
	      </xsl:call-template>
	      <xsl:call-template name="simple-command">
		<xsl:with-param name="cmd" select="'SLOOP'"/>
	      </xsl:call-template>
	      <xsl:call-template name="simple-command">
		<xsl:with-param name="cmd" select="'EIF'"/>
	      </xsl:call-template>
	    </xsl:if>
	  </xsl:otherwise>
	</xsl:choose>
	<xsl:if test="$with-cmd">
	  <xsl:choose>
	    <xsl:when test="$with-cmd = 'SHP'">
	      <xsl:call-template name="simple-command">
		<xsl:with-param name="cmd" select="$with-cmd"/>
		<xsl:with-param name="modifier">
		  <xsl:call-template name="ref-ptr-bit">
		    <xsl:with-param name="ref-ptr" select="$ref-ptr"/>
		  </xsl:call-template>
		</xsl:with-param>
	      </xsl:call-template>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:call-template name="simple-command">
		<xsl:with-param name="cmd" select="$with-cmd"/>
	      </xsl:call-template>
	    </xsl:otherwise>
	  </xsl:choose>
	  <xsl:if test="@zone">
	    <xsl:call-template name="set-zone-pointer">
	      <xsl:with-param name="z" select="'gl'"/>
	      <xsl:with-param name="zp" select="$zp"/>
	    </xsl:call-template>
	  </xsl:if>
	</xsl:if>
      </xsl:when>
      <!-- B. There is a ref attribute -->
      <xsl:when test="@ref">
	<xsl:variable name="this-ref" select="@ref"/>
	<xsl:choose>
	  <!-- 1. We're in a mo -->
	  <xsl:when test="$all-mo-params[@nm = current()/@ref]">
	    <xsl:variable name="new-ref">
	      <xsl:call-template name="resolve-mo-pm">
		<xsl:with-param name="val" select="@ref"/>
		<xsl:with-param name="mp-container" select="$mp-container"/>
		<xsl:with-param name="all-mo-params" select="$all-mo-params"/>
		<xsl:with-param name="crash-on-fail" select="false()"/>
	      </xsl:call-template>
	    </xsl:variable>
	    <xsl:variable name="rp-a-o-res">
	      <xsl:if test="string-length($rp-a-o)">
		<xsl:call-template name="resolve-mo-pm-default">
		  <xsl:with-param name="val" select="$rp-a-o"/>
		  <xsl:with-param name="mp-container" select="$mp-container"/>
		  <xsl:with-param name="all-mo-params" select="$all-mo-params"/>
		</xsl:call-template>
	      </xsl:if>
	    </xsl:variable>
	    <xsl:variable name="rp-a-res">
	      <xsl:if test="string-length($rp-a)">
		<xsl:call-template name="resolve-mo-pm-default">
		  <xsl:with-param name="val" select="$rp-a"/>
		  <xsl:with-param name="mp-container" select="$mp-container"/>
		  <xsl:with-param name="all-mo-params" select="$all-mo-params"/>
		</xsl:call-template>
	      </xsl:if>
	    </xsl:variable>
	    <xsl:variable name="rp-b-o-res">
	      <xsl:if test="string-length($rp-b-o)">
		<xsl:call-template name="resolve-mo-pm-default">
		  <xsl:with-param name="val" select="$rp-b-o"/>
		  <xsl:with-param name="mp-container" select="$mp-container"/>
		  <xsl:with-param name="all-mo-params" select="$all-mo-params"/>
		</xsl:call-template>
	      </xsl:if>
	    </xsl:variable>
	    <xsl:variable name="rp-b-res">
	      <xsl:if test="string-length($rp-b)">
		<xsl:call-template name="resolve-mo-pm-default">
		  <xsl:with-param name="val" select="$rp-b"/>
		  <xsl:with-param name="mp-container" select="$mp-container"/>
		  <xsl:with-param name="all-mo-params" select="$all-mo-params"/>
		</xsl:call-template>
	      </xsl:if>
	    </xsl:variable>
	    <xsl:message>
	      <xsl:text>rp-a-o-res: </xsl:text>
	      <xsl:value-of select="$rp-a-o-res"/>
	      <xsl:value-of select="$text-newline"/>
	      <xsl:text>rp-a-res: </xsl:text>
	      <xsl:value-of select="$rp-a-res"/>
	      <xsl:value-of select="$text-newline"/>
	      <xsl:text>rp-b-o-res: </xsl:text>
	      <xsl:value-of select="$rp-b-o-res"/>
	      <xsl:value-of select="$text-newline"/>
	      <xsl:text>rp-b-res: </xsl:text>
	      <xsl:value-of select="$rp-b-res"/>
	      <xsl:value-of select="$text-newline"/>
	    </xsl:message>
	    <xsl:variable name="remaining-id">
	      <xsl:call-template name="get-remaining-mp-id">
		<xsl:with-param name="mp-container" select="$mp-container"/>
	      </xsl:call-template>
	    </xsl:variable>
	    <xsl:choose>
	      <xsl:when test="$mpcs/xgf:wpm[@nm=current()/@ref]/xgf:range">
		<xsl:apply-templates select="$mpcs/xgf:wpm[@nm=current()/@ref]/xgf:range"
				     mode="push-me">
		  <xsl:with-param name="with-cmd" select="$with-cmd"/>
		  <xsl:with-param name="zp" select="$zp"/>
		  <xsl:with-param name="ref-ptr" select="$ref-ptr"/>
		  <xsl:with-param name="use-sloop" select="$use-sloop"/>
		  <xsl:with-param name="rp-a-o" select="$rp-a-o-res"/>
		  <xsl:with-param name="rp-a" select="$rp-a-res"/>
		  <xsl:with-param name="rp-b-o" select="$rp-b-o-res"/>
		  <xsl:with-param name="rp-b" select="$rp-b-res"/>
		  <xsl:with-param name="mp-container" select="$remaining-id"/>
		</xsl:apply-templates>
	      </xsl:when>
	      <xsl:when test="$mpcs/ancestor::xgf:gl/descendant::xgf:range[@nm = $new-ref] |
			      $mpcs/ancestor::xgf:fn/descendant::xgf:range[@nm = $new-ref] |
			      $mpcs/ancestor::xgf:mo/descendant::xgf:range[@nm = $new-ref] |
			      $mpcs/ancestor::xgf:prep/descendant::xgf:range[@nm = $new-ref]">
		<xsl:apply-templates
		    select="$mpcs/ancestor::xgf:gl/descendant::xgf:range[@nm = $new-ref] |
			    $mpcs/ancestor::xgf:fn/descendant::xgf:range[@nm = $new-ref] |
			    $mpcs/ancestor::xgf:mo/descendant::xgf:range[@nm = $new-ref] |
			    $mpcs/ancestor::xgf:prep/descendant::xgf:range[@nm = $new-ref]"
		    mode="push-me">
		  <xsl:with-param name="with-cmd" select="$with-cmd"/>
		  <xsl:with-param name="zp" select="$zp"/>
		  <xsl:with-param name="ref-ptr" select="$ref-ptr"/>
		  <xsl:with-param name="use-sloop" select="$use-sloop"/>
		  <xsl:with-param name="rp-a-o" select="$rp-a-o-res"/>
		  <xsl:with-param name="rp-a" select="$rp-a-res"/>
		  <xsl:with-param name="rp-b-o" select="$rp-b-o-res"/>
		  <xsl:with-param name="rp-b" select="$rp-b-res"/>
		  <xsl:with-param name="mp-container" select="$remaining-id"/>
		</xsl:apply-templates>
	      </xsl:when>
	      <xsl:when test="$all-mo-params[@nm = current()/@ref]/xgf:line">
		<xsl:apply-templates select="$all-mo-params[@nm = current()/@ref]/xgf:line"
				     mode="push-me">
		  <xsl:with-param name="with-cmd" select="$with-cmd"/>
		  <xsl:with-param name="zp" select="$zp"/>
		  <xsl:with-param name="ref-ptr" select="$ref-ptr"/>
		  <xsl:with-param name="use-sloop" select="$use-sloop"/>
		  <xsl:with-param name="rp-a-o" select="$rp-a-o-res"/>
		  <xsl:with-param name="rp-a" select="$rp-a-res"/>
		  <xsl:with-param name="rp-b-o" select="$rp-b-o-res"/>
		  <xsl:with-param name="rp-b" select="$rp-b-res"/>
		  <xsl:with-param name="mp-container" select="$remaining-id"/>
		</xsl:apply-templates>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:call-template name="error-message">
		  <xsl:with-param name="msg">
		    <xsl:text>Can't resolve range with ref "</xsl:text>
		    <xsl:value-of select="@ref"/>
		    <xsl:text>"</xsl:text>
		  </xsl:with-param>
		</xsl:call-template>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:when>
	  <!-- 2. We're in a gl, fn or prep -->
	  <xsl:when test="ancestor::xgf:gl/descendant::xgf:range[@nm= $this-ref] or
			  ancestor::xgf:fn/descendant::xgf:range[@nm = $this-ref] or
			  ancestor::xgf:mo/descendant::xgf:range[@nm = $this-ref] or
			  ancestor::xgf:prep/descendant::xgf:range[@nm = $this-ref]">
	    <xsl:apply-templates select="ancestor::xgf:gl/descendant::xgf:range[@nm= $this-ref] |
					 ancestor::xgf:fn/descendant::xgf:range[@nm = $this-ref] |
					 ancestor::xgf:mo/descendant::xgf:range[@nm = $this-ref] |
					 ancestor::xgf:prep/descendant::xgf:range[@nm = $this-ref]"
				 mode="push-me">
	      <xsl:with-param name="with-cmd" select="$with-cmd"/>
	      <xsl:with-param name="ref-ptr" select="$ref-ptr"/>
	      <xsl:with-param name="zp" select="$zp"/>
	      <xsl:with-param name="use-sloop" select="$use-sloop"/>
	      <xsl:with-param name="rp-a-o" select="$rp-a-o"/>
	      <xsl:with-param name="rp-a" select="$rp-a"/>
	      <xsl:with-param name="rp-b-o" select="$rp-b-o"/>
	      <xsl:with-param name="rp-b" select="$rp-b"/>
	      <xsl:with-param name="mp-container"
			      select="$mp-container"/>
	    </xsl:apply-templates>
	  </xsl:when>
	  <!-- 3. Can't resolve the ref -->
	  <xsl:otherwise>
	    <xsl:call-template name="error-message">
	      <xsl:with-param name="msg">
		<xsl:text>"Ref" attribute in range points nowhere.</xsl:text>
	      </xsl:with-param>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <!-- C. The range element is ill formed -->
      <xsl:otherwise>
        <xsl:call-template name="error-message">
          <xsl:with-param name="msg">
            <xsl:text>Range must contain either two points or </xsl:text>
            <xsl:text>a "ref" attribute.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build-set-string">
    <xsl:param name="pts"/>
    <xsl:param name="s" select="''"/>
    <xsl:param name="pos" select="1"/>
    <xsl:param name="exclusion1"/>
    <xsl:param name="exclusion2"/>
    <xsl:param name="mp-container"/>
    <xsl:variable name="p">
      <xsl:call-template name="expression">
	<xsl:with-param name="val" select="$pts[$pos]/@n"/>
	<xsl:with-param name="permitted" select="'1n'"/>
	<xsl:with-param name="mp-container"
			select="$mp-container"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$p = 'NaN'">
      <xsl:call-template name="error-message">
	<xsl:with-param name="msg">
	  <xsl:text>All num attributes on points in a set must resolve to
numbers at compile time.</xsl:text>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:variable name="want-pt" select="number($p) != number($exclusion1) and
					 number($p) != number($exclusion2)"/>
    <xsl:variable name="new-s">
      <xsl:choose>
	<xsl:when test="string-length($s)">
	  <xsl:choose>
	    <xsl:when test="$want-pt">
	      <xsl:value-of select="concat($s, ';', $p)"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="$s"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:choose>
	    <xsl:when test="$want-pt">
	      <xsl:value-of select="$p"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="''"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$pts[$pos + 1]">
	<xsl:call-template name="build-set-string">
	  <xsl:with-param name="pts" select="$pts"/>
	  <xsl:with-param name="s" select="$new-s"/>
	  <xsl:with-param name="pos" select="$pos + 1"/>
	  <xsl:with-param name="exclusion1" select="$exclusion1"/>
	  <xsl:with-param name="exclusion2" select="$exclusion2"/>
	  <xsl:with-param name="mp-container"
			  select="$mp-container"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$new-s"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="resolve-mo-pm-default">
    <xsl:param name="all-mo-params"
	       select="ancestor::xgf:mo/xgf:pm|ancestor::xgf:gl/xgf:pm"/>
    <xsl:param name="val"/>
    <xsl:param name="mp-container"/>
    <xsl:choose>
      <xsl:when test="$all-mo-params[@nm = $val]">
	<xsl:call-template name="resolve-mo-pm">
	  <xsl:with-param name="val" select="$val"/>
	  <xsl:with-param name="mp-container" select="$mp-container"/>
	  <xsl:with-param name="all-mo-params" select="$all-mo-params"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$val"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="resolve-mo-pm">
    <xsl:param name="val"/>
    <xsl:param name="mp-container"/>
    <xsl:param name="all-mo-params"
	       select="ancestor::xgf:mo/xgf:pm|ancestor::xgf:gl/xgf:pm"/>
    <xsl:param name="crash-on-fail" select="true()"/>
    <xsl:variable name="this-id">
      <xsl:call-template name="get-first-mp-id">
	<xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <!-- a.) We can get the value we want from the caller. *** -->
      <xsl:when test="$mp-containers and string-length($this-id) and
		      $mp-containers[generate-id()=$this-id]/xgf:wpm[@nm=$val]">
	<xsl:value-of select="$mp-containers[generate-id()=$this-id]/xgf:wpm[@nm=$val]/@val"/>
      </xsl:when>
      <!-- b.) We must get the value from a pm in the mo definition. -->
      <xsl:when test="$all-mo-params[@nm=$val]/@val">
	<xsl:value-of select="$all-mo-params[@nm=$val]/@val"/>
      </xsl:when>
      <!-- c.) We can't get a value: we're in trouble. -->
      <xsl:otherwise>
	<xsl:if test="$crash-on-fail">
	  <xsl:call-template name="error-message">
	    <xsl:with-param name="msg">
	      <xsl:text>Can't resolve mo pm </xsl:text>
	      <xsl:value-of select="$all-mo-params[@nm=current()/@ref]"/>
	    </xsl:with-param>
	  </xsl:call-template>
	</xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="set-string-count">
    <xsl:param name="s"/>
    <xsl:param name="count" select="1"/>
    <xsl:choose>
      <xsl:when test="contains($s,';')">
	<xsl:call-template name="set-string-count">
	  <xsl:with-param name="s" select="substring-after($s,';')"/>
	  <xsl:with-param name="count" select="$count + 1"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$count"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
      set : push-me

      A set is an arbitrary collection of points.
  -->
  <xsl:template match="xgf:set" mode="push-me">
    <xsl:param name="with-cmd"/>
    <xsl:param name="ref-ptr"/>
    <xsl:param name="use-sloop" select="true()"/>
    <xsl:param name="rp-a-o"/>
    <xsl:param name="rp-a"/>
    <xsl:param name="rp-b-o"/>
    <xsl:param name="rp-b"/>
    <xsl:param name="zp"/>
    <xsl:param name="mp-container"/>
    <xsl:param name="all-mo-params"
	       select="ancestor::xgf:mo/xgf:pm|ancestor::xgf:gl/xgf:pm"/>
    <xsl:choose>
      <!-- A. There's a ref attribute. -->
      <xsl:when test="@ref">
	<xsl:choose>
	  <!--
	      1. We're in a mo and the @ref matches one of the
	      mo params.
	  -->
	  <xsl:when test="$all-mo-params[@nm = current()/@ref]">
	    <xsl:variable name="new-ref">
	      <xsl:call-template name="resolve-mo-pm">
		<xsl:with-param name="val" select="@ref"/>
		<xsl:with-param name="mp-container" select="$mp-container"/>
		<xsl:with-param name="all-mo-params" select="$all-mo-params"/>
		<xsl:with-param name="crash-on-fail" select="false()"/>
	      </xsl:call-template>
	    </xsl:variable>
	    <xsl:variable name="rp-a-o-res">
	      <xsl:if test="string-length($rp-a-o)">
		<xsl:call-template name="resolve-mo-pm-default">
		  <xsl:with-param name="val" select="$rp-a-o"/>
		  <xsl:with-param name="mp-container" select="$mp-container"/>
		  <xsl:with-param name="all-mo-params" select="$all-mo-params"/>
		</xsl:call-template>
	      </xsl:if>
	    </xsl:variable>
	    <xsl:variable name="rp-a-res">
	      <xsl:if test="string-length($rp-a)">
		<xsl:call-template name="resolve-mo-pm-default">
		  <xsl:with-param name="val" select="$rp-a"/>
		  <xsl:with-param name="mp-container" select="$mp-container"/>
		  <xsl:with-param name="all-mo-params" select="$all-mo-params"/>
		</xsl:call-template>
	      </xsl:if>
	    </xsl:variable>
	    <xsl:variable name="rp-b-o-res">
	      <xsl:if test="string-length($rp-b-o)">
		<xsl:call-template name="resolve-mo-pm-default">
		  <xsl:with-param name="val" select="$rp-b-o"/>
		  <xsl:with-param name="mp-container" select="$mp-container"/>
		  <xsl:with-param name="all-mo-params" select="$all-mo-params"/>
		</xsl:call-template>
	      </xsl:if>
	    </xsl:variable>
	    <xsl:variable name="rp-b-res">
	      <xsl:if test="string-length($rp-b)">
		<xsl:call-template name="resolve-mo-pm-default">
		  <xsl:with-param name="val" select="$rp-b"/>
		  <xsl:with-param name="mp-container" select="$mp-container"/>
		  <xsl:with-param name="all-mo-params" select="$all-mo-params"/>
		</xsl:call-template>
	      </xsl:if>
	    </xsl:variable>
	    <xsl:variable name="this-id">
	      <xsl:call-template name="get-first-mp-id">
		<xsl:with-param name="mp-container" select="$mp-container"/>
	      </xsl:call-template>
	    </xsl:variable>
	    <xsl:variable name="remaining-mp-id">
	      <xsl:call-template name="get-remaining-mp-id">
		<xsl:with-param name="mp-container" select="$mp-container"/>
	      </xsl:call-template>
	    </xsl:variable>
	    <xsl:choose>
	      <!-- A. The set is a child of a wpm element in the caller. -->
	      <xsl:when test="$mp-containers[generate-id()=$this-id]/xgf:wpm[@nm = current()/@ref]/xgf:set">
		<xsl:apply-templates
		    select="$mp-containers[generate-id()=$this-id]/xgf:wpm[@nm = current()/@ref]/xgf:set"
		    mode="push-me">
		  <xsl:with-param name="with-cmd" select="$with-cmd"/>
		  <xsl:with-param name="ref-ptr" select="$ref-ptr"/>
		  <xsl:with-param name="use-sloop" select="$use-sloop"/>
		  <xsl:with-param name="rp-a-o" select="$rp-a-o-res"/>
		  <xsl:with-param name="rp-a" select="$rp-a-res"/>
		  <xsl:with-param name="rp-b-o" select="$rp-b-o-res"/>
		  <xsl:with-param name="rp-b" select="$rp-b-res"/>
		  <xsl:with-param name="zp" select="$zp"/>
		  <xsl:with-param name="mp-container" select="$remaining-mp-id"/>
		</xsl:apply-templates>
	      </xsl:when>
	      <!-- B. The resolved value of the pm is a ref to a
	           named set in the gl program or mo from which
	           this gl or mo has been called. -->
	      <xsl:when test="$mp-containers[generate-id()=$this-id]/ancestor::xgf:gl/descendant::xgf:set[@nm=$new-ref]|
			      $mp-containers[generate-id()=$this-id]/ancestor::xgf:mo/descendant::xgf:set[@nm=$new-ref]">
		<xsl:apply-templates
		    select="$mp-containers[generate-id()=$this-id]/ancestor::xgf:gl/descendant::xgf:set[@nm=$new-ref]|
			    $mp-containers[generate-id()=$this-id]/ancestor::xgf:mo/descendant::xgf:set[@nm=$new-ref]"
		    mode="push-me">
		  <xsl:with-param name="with-cmd" select="$with-cmd"/>
		  <xsl:with-param name="ref-ptr" select="$ref-ptr"/>
		  <xsl:with-param name="use-sloop" select="$use-sloop"/>
		  <xsl:with-param name="rp-a-o" select="$rp-a-o-res"/>
		  <xsl:with-param name="rp-a" select="$rp-a-res"/>
		  <xsl:with-param name="rp-b-o" select="$rp-b-o-res"/>
		  <xsl:with-param name="rp-b" select="$rp-b-res"/>
		  <xsl:with-param name="zp" select="$zp"/>
		  <xsl:with-param name="mp-container" select="$remaining-mp-id"/>
		</xsl:apply-templates>
	      </xsl:when>
	      <!-- C. The set is a child of the pm element (a default set) -->
	      <xsl:when test="$all-mo-params[@nm = current()/@ref]/xgf:set">
		<xsl:apply-templates select="$all-mo-params[@nm = current()/@ref]/xgf:set"
				     mode="push-me">
		  <xsl:with-param name="with-cmd" select="$with-cmd"/>
		  <xsl:with-param name="ref-ptr" select="$ref-ptr"/>
		  <xsl:with-param name="use-sloop" select="$use-sloop"/>
		  <xsl:with-param name="rp-a-o" select="$rp-a-o-res"/>
		  <xsl:with-param name="rp-a" select="$rp-a-res"/>
		  <xsl:with-param name="rp-b-o" select="$rp-b-o-res"/>
		  <xsl:with-param name="rp-b" select="$rp-b-res"/>
		  <xsl:with-param name="zp" select="$zp"/>
		  <xsl:with-param name="mp-container" select="$remaining-mp-id"/>
		</xsl:apply-templates>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:call-template name="error-message">
		  <xsl:with-param name="msg">
		    <xsl:text>Cannot resolve ref "</xsl:text>
		    <xsl:value-of select="@ref"/>
		    <xsl:text>" in set</xsl:text>
		  </xsl:with-param>
		</xsl:call-template>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:when>
	  <!--
	      2. We're in a gl program and the @ref matches a
	      declared set.
	  -->
	  <xsl:when test="ancestor::xgf:gl/descendant::xgf:set[@nm = current()/@ref]">
	    <xsl:apply-templates select="ancestor::xgf:gl/descendant::xgf:set[@nm
					 = current()/@ref]" mode="push-me">
	      <xsl:with-param name="with-cmd" select="$with-cmd"/>
	      <xsl:with-param name="ref-ptr" select="$ref-ptr"/>
	      <xsl:with-param name="use-sloop" select="$use-sloop"/>
	      <xsl:with-param name="rp-a-o" select="$rp-a-o"/>
	      <xsl:with-param name="rp-a" select="$rp-a"/>
	      <xsl:with-param name="rp-b-o" select="$rp-b-o"/>
	      <xsl:with-param name="rp-b" select="$rp-b"/>
	      <xsl:with-param name="zp" select="$zp"/>
	      <xsl:with-param name="mp-container"
			      select="$mp-container"/>
	    </xsl:apply-templates>
	  </xsl:when>
	  <!--
	      3. Same in a mo
	  -->
	  <xsl:when test="ancestor::xgf:mo/descendant::xgf:set[@nm = current()/@ref]">
	    <xsl:apply-templates select="ancestor::xgf:mo/descendant::xgf:set[@nm
					 = current()/@ref]" mode="push-me">
	      <xsl:with-param name="with-cmd" select="$with-cmd"/>
	      <xsl:with-param name="ref-ptr" select="$ref-ptr"/>
	      <xsl:with-param name="use-sloop" select="$use-sloop"/>
	      <xsl:with-param name="rp-a-o" select="$rp-a-o"/>
	      <xsl:with-param name="rp-a" select="$rp-a"/>
	      <xsl:with-param name="rp-b-o" select="$rp-b-o"/>
	      <xsl:with-param name="rp-b" select="$rp-b"/>
	      <xsl:with-param name="zp" select="$zp"/>
	      <xsl:with-param name="mp-container"
			      select="$mp-container"/>
	    </xsl:apply-templates>
	  </xsl:when>
	  <!--
	      4. We're in trouble.
	  -->
	  <xsl:otherwise>
	    <xsl:call-template name="error-message">
	      <xsl:with-param name="msg">
		<xsl:text>Cannot resolve ref "</xsl:text>
		<xsl:value-of select="@ref"/>
		<xsl:text>" in set</xsl:text>
	      </xsl:with-param>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <!-- This set contains points -->
      <xsl:when test="xgf:pt">
	<xsl:if test="$zp and @zone">
	  <xsl:call-template name="set-zone-pointer">
	    <xsl:with-param name="z" select="@zone"/>
	    <xsl:with-param name="zp" select="$zp"/>
	  </xsl:call-template>
	</xsl:if>
	<xsl:variable name="exclusion1">
	  <xsl:call-template name="expression">
	    <xsl:with-param name="val">
	      <xsl:choose>
		<xsl:when test="string-length($rp-a-o)">
		  <xsl:value-of select="$rp-a-o"/>
		</xsl:when>
		<xsl:when test="string-length($rp-a)">
		  <xsl:value-of select="$rp-a"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="-1"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:with-param>
	    <xsl:with-param name="mp-container"
			    select="$mp-container"/>
	  </xsl:call-template>
	</xsl:variable>
	<xsl:variable name="exclusion2">
	  <xsl:call-template name="expression">
	    <xsl:with-param name="val">
	      <xsl:choose>
		<xsl:when test="$with-cmd = 'IP' and string-length($rp-b-o)">
		  <xsl:value-of select="$rp-b-o"/>
		</xsl:when>
		<xsl:when test="$with-cmd = 'IP' and string-length($rp-b)">
		  <xsl:value-of select="$rp-b"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="-1"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:with-param>
	    <xsl:with-param name="mp-container"
			    select="$mp-container"/>
	  </xsl:call-template>
	</xsl:variable>
	<xsl:variable name="set-string">
	  <xsl:call-template name="build-set-string">
	    <xsl:with-param name="pts" select="xgf:pt"/>
	    <xsl:with-param name="exclusion1" select="$exclusion1"/>
	    <xsl:with-param name="exclusion2" select="$exclusion2"/>
	    <xsl:with-param name="mp-container"
			    select="$mp-container"/>
	  </xsl:call-template>
	</xsl:variable>
	<xsl:call-template name="push-list">
	  <xsl:with-param name="list" select="$set-string"/>
	  <xsl:with-param name="is-pt-list" select="true()"/>
	  <xsl:with-param name="is-pre-resolved" select="true()"/>
	  <xsl:with-param name="mp-container" select="$mp-container"/>
	</xsl:call-template>
	<!--
	    figure out how many numbers to push (not necessarily the
	    same as the number of points).
	-->
	<xsl:variable name="num-count">
	  <xsl:call-template name="set-string-count">
	    <xsl:with-param name="s" select="$set-string"/>
	  </xsl:call-template>
	</xsl:variable>
	<!-- do SLOOP if necessary -->
	<xsl:if test="$use-sloop and number($num-count) &gt;= 2">
	  <xsl:call-template name="number-command">
	    <xsl:with-param name="num" select="$num-count"/>
	    <xsl:with-param name="cmd" select="'SLOOP'"/>
	  </xsl:call-template>
	</xsl:if>
	<!-- output the cmd -->
	<xsl:if test="$with-cmd">
	  <xsl:choose>
	    <xsl:when test="$with-cmd = 'SHP'">
	      <xsl:call-template name="simple-command">
		<xsl:with-param name="cmd" select="'SHP'"/>
		<xsl:with-param name="modifier">
		  <xsl:call-template name="ref-ptr-bit">
		    <xsl:with-param name="ref-ptr" select="$ref-ptr"/>
		  </xsl:call-template>
		</xsl:with-param>
	      </xsl:call-template>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:call-template name="simple-command">
		<xsl:with-param name="cmd" select="$with-cmd"/>
	      </xsl:call-template>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:if>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="error-message">
	  <xsl:with-param name="msg">
	    <xsl:text>A &lt;set&gt; must either have a ref attribute or contain
one or more points.</xsl:text>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--

      push-line

      At a simple level, this just causes two points to be pushed onto the
      stack: the first one first, the second one second (so it's the second
      one that ends up on top of the stack). The treatment of zones adds a
      hint of excitement. The set-vector instructions take a line in which
      one pt can be in one zone, the other in the other. The ISECT
      instruction, on the other hand, must have a line contained entirely
      within one zone. So this template has two ways to treat zones. When
      the "zones" parameter is "1" only the line element may have a "zone"
      attribute: that's for ISECT. When it is "2" (the default), each (or
      either) pt may have a "zone" attribute, if the two points are in
      different zones, or the line element may have a "zone" attribute,
      which is the same as having the same "zone" attribute for both points.
  -->
  <xsl:template name="push-line">
    <xsl:param name="l"/>
    <xsl:param name="zp"/>
    <xsl:param name="zones" select="2"/>
    <xsl:param name="mp-container"/>
    <xsl:choose>
      <xsl:when test="$zones = 1">
        <xsl:if test="$zp and $l/@zone">
          <xsl:call-template name="set-zone-pointer">
            <xsl:with-param name="z" select="$l/@zone"/>
            <xsl:with-param name="zp" select="$zp"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$l/@zone">
            <xsl:call-template name="set-zone-pointer">
              <xsl:with-param name="z" select="$l/@zone"/>
              <xsl:with-param name="zp" select="'1'"/>
            </xsl:call-template>
            <xsl:call-template name="set-zone-pointer">
              <xsl:with-param name="z" select="$l/@zone"/>
              <xsl:with-param name="zp" select="'2'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="$l/xgf:pt[1]/@zone">
              <xsl:call-template name="set-zone-pointer">
                <xsl:with-param name="z" select="$l/xgf:pt[1]/@zone"/>
                <xsl:with-param name="zp" select="'1'"/>
              </xsl:call-template>
            </xsl:if>
            <xsl:if test="$l/xgf:pt[2]/@zone">
              <xsl:call-template name="set-zone-pointer">
                <xsl:with-param name="z" select="$l/xgf:pt[2]/@zone"/>
                <xsl:with-param name="zp" select="'2'"/>
              </xsl:call-template>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="push-points">
      <xsl:with-param name="pts" select="$l/xgf:pt"/>
      <xsl:with-param name="mp-container"
		      select="$mp-container"/>
    </xsl:call-template>
  </xsl:template>

  <!--

      line : push-it

      Push the two points in a line element. If the line contains
      a ref attribute (pointing to another line) instead of
      points, we call recursively until we've found a line with
      points that can be pushed.
  -->
  <xsl:template match="xgf:line" mode="push-it">
    <xsl:param name="zp"/>
    <xsl:param name="zones" select="2"/>
    <xsl:param name="mp-container"/>
    <xsl:param name="all-mo-params"
	       select="ancestor::xgf:mo/xgf:pm|ancestor::xgf:gl/xgf:pm"/>
    <xsl:param name="this-id">
      <xsl:call-template name="get-first-mp-id">
	<xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
    </xsl:param>
    <xsl:param name="mpcs" select="$mp-containers[generate-id()=$this-id]"/>
    <xsl:choose>
      <!-- A. This line contains points: we'll use them. -->
      <xsl:when test="count(xgf:pt) &gt;= 2">
        <xsl:call-template name="push-line">
          <xsl:with-param name="l" select="."/>
          <xsl:with-param name="zp" select="$zp"/>
          <xsl:with-param name="zones" select="$zones"/>
	  <xsl:with-param name="mp-container"
			  select="$mp-container"/>
        </xsl:call-template>
      </xsl:when>
      <!-- B. This line has a ref. We'll use that to find one with points. -->
      <xsl:when test="@ref">
	<xsl:choose>
	  <!-- 1. We're in a mo and the ref matches a pm. -->
	  <xsl:when test="$all-mo-params[@nm = current()/@ref]">
	    <xsl:variable name="new-ref">
	      <xsl:call-template name="resolve-mo-pm">
		<xsl:with-param name="val" select="@ref"/>
		<xsl:with-param name="mp-container" select="$mp-container"/>
		<xsl:with-param name="all-mo-params" select="$all-mo-params"/>
		<xsl:with-param name="crash-on-fail" select="false()"/>
	      </xsl:call-template>
	    </xsl:variable>
	    <!-- look for matching line *** -->
	    <xsl:choose>
	      <xsl:when test="$mpcs/xgf:wpm[@nm = current()/@ref]/xgf:line">
		<xsl:apply-templates
		    select="$mpcs/xgf:wpm[@nm = current()/@ref]/xgf:line"
		    mode="push-it">
		  <xsl:with-param name="zones" select="$zones"/>
		  <xsl:with-param name="zp" select="$zp"/>
		  <xsl:with-param name="mp-container">
		    <xsl:call-template name="get-remaining-mp-id">
		      <xsl:with-param name="mp-container" select="$mp-container"/>
		    </xsl:call-template>
		  </xsl:with-param>
	    </xsl:apply-templates>
	      </xsl:when>
	      <xsl:when test="$mpcs/ancestor::xgf:gl/descendant::xgf:line[@nm=$new-ref] |
			      $mpcs/ancestor::xgf:fn/descendant::xgf:line[@nm=$new-ref] |
			      $mpcs/ancestor::xgf:mo/descendant::xgf:line[@nm=$new-ref] |
			      $mpcs/ancestor::xgf:prep/descendant::xgf:line[@nm=$new-ref]">
		<xsl:apply-templates
		    select="$mpcs/ancestor::xgf:gl/descendant::xgf:line[@nm=$new-ref] |
			    $mpcs/ancestor::xgf:fn/descendant::xgf:line[@nm=$new-ref] |
			    $mpcs/ancestor::xgf:mo/descendant::xgf:line[@nm=$new-ref] |
			    $mpcs/ancestor::xgf:prep/descendant::xgf:line[@nm=$new-ref]"
		    mode="push-it">
		  <xsl:with-param name="zones" select="$zones"/>
		  <xsl:with-param name="zp" select="$zp"/>
		  <xsl:with-param name="mp-container">
		    <xsl:call-template name="get-remaining-mp-id">
		      <xsl:with-param name="mp-container" select="$mp-container"/>
		    </xsl:call-template>
		  </xsl:with-param>
		</xsl:apply-templates>
	      </xsl:when>
	      <xsl:when test="$all-mo-params[@nm = current()/@ref]/xgf:line">
		<xsl:apply-templates select="$all-mo-params[@nm = current()/@ref]/xgf:line"
				     mode="push-it">
		  <xsl:with-param name="zones" select="$zones"/>
		  <xsl:with-param name="zp" select="$zp"/>
		  <xsl:with-param name="mp-container">
		    <xsl:call-template name="get-remaining-mp-id">
		      <xsl:with-param name="mp-container" select="$mp-container"/>
		    </xsl:call-template>
		  </xsl:with-param>
		</xsl:apply-templates>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:call-template name="error-message">
		  <xsl:with-param name="msg">
		    <xsl:text>Can't resolve line with ref "</xsl:text>
		    <xsl:value-of select="@ref"/>
		  </xsl:with-param>
		</xsl:call-template>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:when>
	  <!-- 2. We're in a gl, fn or prep and the ref matches a line declared there. -->
	  <xsl:when test="ancestor::xgf:gl/descendant::xgf:line[@nm = current()/@ref] or
			  ancestor::xgf:fn/descendant::xgf:line[@nm = current()/@ref] or
			  ancestor::xgf:mo/descendant::xgf:line[@nm = current()/@ref] or
                          ancestor::xgf:prep/descendant::xgf:line[@nm = current()/@ref]">
	    <xsl:apply-templates select="ancestor::xgf:gl/descendant::xgf:line[@nm =
					 current()/@ref] |
					 ancestor::xgf:fn/descendant::xgf:line[@nm
                                         = current()/@ref] |
					 ancestor::xgf:mo/descendant::xgf:line[@nm
                                         = current()/@ref] |
					 ancestor::xgf:prep/descendant::xgf:line[@nm =
					 current()/@ref]"
                                 mode="push-it">
              <xsl:with-param name="zp" select="$zp"/>
              <xsl:with-param name="zones" select="$zones"/>
	      <xsl:with-param name="mp-container"
			      select="$mp-container"/>
            </xsl:apply-templates>
	  </xsl:when>
	  <!-- 3. We've tried everything we know, and have not found it. Time to give up. -->
	  <xsl:otherwise>
	    <xsl:call-template name="error-message">
              <xsl:with-param name="msg">
                <xsl:text>Cannot resolve line with ref </xsl:text>
                <xsl:value-of select="@ref"/>
              </xsl:with-param>
            </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <!-- C. There was something wrong with this line element. -->
      <xsl:otherwise>
        <xsl:call-template name="error-message">
          <xsl:with-param name="msg">
            <xsl:text>A line element must contain either two </xsl:text>
            <xsl:text>points or a ref attribute.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!--

      check-line

      Determines whether a line is valid.
  -->
  <xsl:template name="check-line">
    <xsl:param name="l"/>
    <xsl:if test="not($l/@ref) and not(count($l/xgf:pt) &gt;= 2)">
      <xsl:call-template name="error-message">
        <xsl:with-param name="msg">
          <xsl:text>Invalid line</xsl:text>
          <xsl:if test="$l/@ref">
            <xsl:text> ref=</xsl:text>
            <xsl:value-of select="$l/@ref"/>
          </xsl:if>
          <xsl:if test="$l/@nm">
            <xsl:text> name=</xsl:text>
            <xsl:value-of select="$l/@nm"/>
          </xsl:if>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!--

      check-for-move-points

      Checks to make sure there are actually points that
      can be moved in the current element. Terminates
      the script with an error message if there are none.
  -->
  <xsl:template name="check-for-move-points">
    <xsl:if test="not(xgf:pt) and not(xgf:range) and not(xgf:set)">
      <xsl:call-template name="error-message">
        <xsl:with-param name="msg">
          <xsl:text>Can't find a pt to move or alter in &lt;</xsl:text>
          <xsl:value-of select="local-name()"/>
          <xsl:text>&gt; instruction.</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!--

      push-pt-and-distance

      As parameters to MIRP or MIAP.

      Parameters:
      pt = the pt.
      ds = this distance.
      zp = the zone pointer to set if zone of pt is specified.

      But the real pt of doing this in a template is the optimization:
      if both the pt and distance will resolve to numbers between 0
      and 255 at compile time, then we can push both with a single PUSHB
      command. This is a little complicated, and we don't want this code
      to appear twice in the program.
  -->
  <xsl:template name="push-pt-and-distance">
    <xsl:param name="pt"/>
    <xsl:param name="ds"/>
    <xsl:param name="zp"/>
    <xsl:param name="mp-container"/>
    <xsl:variable name="p">
      <xsl:call-template name="expression-with-offset">
        <xsl:with-param name="val" select="$pt/@n"/>
        <xsl:with-param name="permitted" select="'1n'"/>
	<xsl:with-param name="called-from" select="'push-pt-and-distance-1'"/>
	<xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="c">
      <xsl:call-template name="expression">
        <xsl:with-param name="val" select="$ds"/>
        <xsl:with-param name="permitted" select="'1nc'"/>
	<xsl:with-param name="called-from" select="'push-pt-and-distance-2'"/>
	<xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="am"
                  select="boolean(number($p) &gt;= 0 and
                          number($p) &lt; 256 and
                          number($c) &gt;= 0 and
                          number($c) &lt; 256)"/>
    <!-- Push the pt we're going to move. ZP1 for this pt. -->
    <xsl:call-template name="push-pt">
      <xsl:with-param name="pt" select="$pt"/>
      <xsl:with-param name="zp" select="$zp"/>
      <xsl:with-param name="expect">
        <xsl:choose>
          <xsl:when test="$am">
            <xsl:value-of select="2"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="1"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="mp-container"
		      select="$mp-container"/>
    </xsl:call-template>
    <!-- Push the distance. -->
    <xsl:call-template name="expression">
      <xsl:with-param name="val" select="$ds"/>
      <xsl:with-param name="add-mode" select="$am"/>
      <xsl:with-param name="permitted" select="'cf'"/>
	<xsl:with-param name="called-from" select="'push-pt-and-distance-3'"/>
      <xsl:with-param name="mp-container"
		      select="$mp-container"/>
      <xsl:with-param name="to-stack" select="true()"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
