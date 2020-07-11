<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"
		version="1.0">
  
  <!--
      This file is part of xgridfit, version 3.
      Licensed under the Apache License, Version 2.0.
      Copyright (c) 2006-20 by Peter S. Baker
  -->
  
  <xsl:template name="get-highest-fn-number">
    <xsl:param name="current-fn"/>
    <xsl:param name="current-max" select="0"/>
    <xsl:variable name="new-max">
      <xsl:choose>
        <xsl:when test="number($current-max) &gt;
			number($current-fn/@n)">
          <xsl:value-of select="$current-max"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$current-fn/@n"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$current-fn/following-sibling::xgf:fn[@n]">
        <xsl:call-template name="get-highest-fn-number">
          <xsl:with-param name="current-fn"
            select="$current-fn/following-sibling::xgf:fn[@n][1]"/>
          <xsl:with-param name="current-max" select="$new-max"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$new-max"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-mo-pm-value">
    <xsl:param name="i"/> <!-- generated id of the with-param container -->
    <xsl:param name="n"/> <!-- name of the pm -->
    <xsl:message>
      <xsl:text>generated id: </xsl:text>
      <xsl:value-of select="$i"/>
    </xsl:message>
    <xsl:choose>
      <xsl:when test="//callm[generate-id() = $i]/wpm[@nm=$n]/@val">
	<xsl:value-of select="//callm[generate-id() = $i]/wpm[@nm=$n]/@val"/>
      </xsl:when>
      <xsl:when test="//callg[generate-id() = $i]/wpm[@nm=$n]/@val">
	<xsl:value-of select="//callg[generate-id() = $i]/wpm[@nm=$n]/@val"/>
      </xsl:when>
      <xsl:when test="//pmset[generate-id() = $i]/wpm[@nm=$n]/@val">
	<xsl:value-of
	    select="//callm/pmset[generate-id() = $i]/wpm[@nm=$n]/@val"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>$$no-value$$</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="gfn-helper">
    <xsl:param name="f"/>
    <xsl:choose>
      <xsl:when test="$f/@n">
	<xsl:value-of select="$f/@n"/>
      </xsl:when>
      <xsl:when test="$f[not(xgf:variant)]">
	<xsl:value-of select="number($auto-fn-base) +
			      number($predefined-functions) +
			      count($f/preceding-sibling::xgf:fn[not(@n) and
			      not(xgf:variant)])"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="number($auto-fn-base) +
			      number($predefined-functions) +
			      count(/xgf:xgridfit/xgf:fn[not(@n) and
			      not(xgf:variant)]) +
			      count($f/preceding-sibling::xgf:fn[xgf:variant])"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="get-fn-number">
    <xsl:param name="fn-name"/>
    <xsl:if test="not(key('fn-index',$fn-name))">
      <xsl:call-template name="error-message">
	<xsl:with-param name="msg">
	  <xsl:text>Function "</xsl:text>
	  <xsl:value-of select="$fn-name"/>
	  <xsl:text>" not found</xsl:text>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="$merge-mode">
	<xsl:value-of select="concat('%',$fn-name,'%')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="gfn-helper">
	  <xsl:with-param name="f" select="key('fn-index',$fn-name)"/>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-fn-pm-names">
    <xsl:param name="f"/>
    <xsl:param name="all-params" select="key('fn-index',$f)/xgf:pm"/>
    <xsl:variable name="v">
      <xsl:for-each select="$all-params">
	<xsl:sort select="position()" order="descending"/>
	<xsl:text> </xsl:text>
	<xsl:choose>
	  <xsl:when test="@nm">
	    <xsl:value-of select="@nm"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:call-template name="error-message">
	      <xsl:with-param name="msg">
		<xsl:text>&lt;pm&gt; in fn "</xsl:text>
		<xsl:value-of select="$f"/>
		<xsl:text>" lacks a name.</xsl:text>
	      </xsl:with-param>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="normalize-space($v)"/>
  </xsl:template>

  <xsl:template name="make-pm-string">
    <!--
	We assume that the current context element contains
	<wpm> children. Build a string descriptor containing a
	list of pm values to pass to push-list.
    -->
    <xsl:param name="f"/>
    <xsl:param name="all-params" select="key('fn-index',$f)/xgf:pm"/>
    <xsl:param name="pm-names"/>
    <xsl:param name="count" select="0"/>
    <xsl:variable name="current-name">
      <xsl:choose>
	<xsl:when test="contains($pm-names,' ')">
	  <xsl:value-of select="substring-before($pm-names,' ')"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$pm-names"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="other-names">
      <xsl:choose>
	<xsl:when test="contains($pm-names,' ')">
	  <xsl:value-of select="substring-after($pm-names,' ')"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="''"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$count &gt; 0">
      <xsl:value-of select="';'"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="xgf:wpm[@nm=$current-name]/@val">
	<xsl:value-of select="xgf:wpm[@nm=$current-name]/@val"/>
      </xsl:when>
      <xsl:when test="$all-params[@nm=$current-name]/@val">
	<xsl:value-of select="$all-params[@nm=$current-name]/@val"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="error-message">
	  <xsl:with-param name="msg">
	    <xsl:text>Cannot find a value for &lt;pm&gt; "</xsl:text>
	    <xsl:value-of select="$current-name"/>
	    <xsl:text>".</xsl:text>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <!--
	Recurse if there are more params to survey.
    -->
    <xsl:if test="string-length($other-names)">
      <xsl:call-template name="make-pm-string">
	<xsl:with-param name="f" select="$f"/>
	<xsl:with-param name="all-params" select="$all-params"/>
	<xsl:with-param name="pm-names" select="$other-names"/>
	<xsl:with-param name="count" select="$count + 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!--
      Gets the fn parameters onto the stack.
  -->
  <xsl:template match="xgf:pmset|xgf:callf" mode="fn">
    <xsl:param name="mp-container"/>
    <xsl:param name="f" select="ancestor-or-self::xgf:callf/@nm"/>
    <xsl:param name="all-params" select="key('fn-index',$f)/xgf:pm"/>
    <xsl:if test="local-name() = 'pmset'">
      <xsl:call-template name="debug-start"/>
    </xsl:if>
    <xsl:variable name="pm-list">
      <xsl:call-template name="get-fn-pm-names">
	<xsl:with-param name="f" select="$f"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="pm-value-list">
      <xsl:call-template name="make-pm-string">
	<xsl:with-param name="f" select="$f"/>
	<xsl:with-param name="pm-names" select="$pm-list"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- Check the wpm elements for validity, since the schema does little -->
    <xsl:variable name="p">
      <xsl:choose>
        <xsl:when test="ancestor::xgf:fn">
          <xsl:text>1xmpfvnc</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>1xmpvnc</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="push-list">
      <xsl:with-param name="list" select="$pm-value-list"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:if test="local-name() = 'pmset'">
      <xsl:call-template name="debug-end"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xgf:callf">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="fid">
      <xsl:choose>
	<xsl:when test="@nm">
	  <xsl:value-of select="@nm"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name="error-message">
	    <xsl:with-param name="msg">
	      <xsl:text>Encountered &lt;callf&gt; element without name.</xsl:text>
	    </xsl:with-param>
	  </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="fn-has-variables"
		  select="key('fn-index',$fid)/xgf:var"/>
    <!-- If we're calling this from a fn, we need to preserve
         the var $var-fn-stack-count and restore it after
         we're done. -->
    <xsl:if test="ancestor::xgf:fn">
      <xsl:call-template name="number-command">
	<xsl:with-param name="num">
	  <xsl:call-template name="resolve-std-var-loc">
	    <xsl:with-param name="n" select="$var-fn-stack-count"/>
	  </xsl:call-template>
	</xsl:with-param>
        <xsl:with-param name="cmd" select="'RS'"/>
      </xsl:call-template>
    </xsl:if>
    <!--
	If the fn we're calling uses variables, we need to save
	the current var frame.
    -->
    <xsl:if test="$fn-has-variables">
      <xsl:call-template name="number-command">
	<xsl:with-param name="num">
	  <xsl:call-template name="resolve-std-var-loc">
	    <xsl:with-param name="n" select="$var-frame-bottom"/>
	  </xsl:call-template>
	</xsl:with-param>
	<xsl:with-param name="cmd" select="'RS'"/>
      </xsl:call-template>
    </xsl:if>
    <!-- push the parameters onto the stack. -->
    <xsl:choose>
      <xsl:when test="xgf:pmset">
	<xsl:apply-templates select="xgf:pmset" mode="fn">
	  <xsl:with-param name="mp-container"
			  select="$mp-container"/>
	</xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="." mode="fn">
	  <xsl:with-param name="mp-container"
			  select="$mp-container"/>
	</xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
    <!-- continue saving var frame. -->
    <xsl:if test="$fn-has-variables">
      <xsl:call-template name="push-num">
	<xsl:with-param name="num">
	  <xsl:call-template name="resolve-std-var-loc">
	    <xsl:with-param name="n" select="$var-frame-bottom"/>
	  </xsl:call-template>
	</xsl:with-param>
	<xsl:with-param name="expect" select="2"/>
      </xsl:call-template>
      <xsl:call-template name="push-num">
	<xsl:with-param name="num">
	  <xsl:call-template name="resolve-std-var-loc">
	    <xsl:with-param name="n" select="$var-frame-top"/>
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
    </xsl:if>
    <!-- Push the index of this fn. This always matches the number that
         was used to define the fn when the fgpm table was set up. -->
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
        <xsl:call-template name="get-fn-number">
          <xsl:with-param name="fn-name" select="$fid"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <!-- Call via CALL or LOOPCALL, depending on whether we have two sets of
         parameters, or more, or fewer. -->
    <xsl:choose>
      <xsl:when test="count(xgf:pmset) &gt; 1">
        <xsl:call-template name="push-num">
          <xsl:with-param name="num" select="count(xgf:pmset)"/>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'SWAP'"/>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'LOOPCALL'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'CALL'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <!-- Now restore var frame. Copy var-frame-bottom to var-frame-top
         and then copy the number we saved to the stack before the call into
         var-frame-bottom. -->
    <xsl:if test="$fn-has-variables">
      <xsl:call-template name="push-num">
	<xsl:with-param name="num">
	  <xsl:call-template name="resolve-std-var-loc">
	    <xsl:with-param name="n" select="$var-frame-top"/>
	  </xsl:call-template>
	</xsl:with-param>
	<xsl:with-param name="expect" select="2"/>
      </xsl:call-template>
      <xsl:call-template name="push-num">
	<xsl:with-param name="num">
	  <xsl:call-template name="resolve-std-var-loc">
	    <xsl:with-param name="n" select="$var-frame-bottom"/>
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
      <xsl:call-template name="stack-top-to-storage">
	<xsl:with-param name="loc">
	  <xsl:call-template name="resolve-std-var-loc">
	    <xsl:with-param name="n" select="$var-frame-bottom"/>
	  </xsl:call-template>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <!-- If we're calling this from a fn, we need to restore
         the previous value of $var-fn-stack-count (it's supposed
         to be on top of the stack after the fn returns). -->
    <xsl:if test="ancestor::xgf:fn">
      <xsl:call-template name="stack-top-to-storage">
	<xsl:with-param name="loc">
	  <xsl:call-template name="resolve-std-var-loc">
	    <xsl:with-param name="n" select="$var-fn-stack-count"/>
	  </xsl:call-template>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <!-- If the fn we are calling has the attribute return="yes" then
         we collect the return value from var-return-value. We'd like to
         store it in a var (or whatever) referenced by "result-to", but
         if that attribute is missing we issue a warning and leave the value
         on the stack. -->
    <xsl:choose>
      <xsl:when test="key('fn-index',$fid)/@return = 'yes'">
        <xsl:choose>
          <xsl:when test="@result-to">
            <xsl:call-template name="number-command">
	      <xsl:with-param name="num">
		<xsl:call-template name="resolve-std-var-loc">
		  <xsl:with-param name="n" select="$var-return-value"/>
		</xsl:call-template>
	      </xsl:with-param>
              <xsl:with-param name="cmd" select="'RS'"/>
            </xsl:call-template>
            <xsl:call-template name="store-value">
              <xsl:with-param name="vname" select="@result-to"/>
	      <xsl:with-param name="mp-container"
			      select="$mp-container"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="warning">
              <xsl:with-param name="msg">
                <xsl:text>Function </xsl:text>
                <xsl:value-of select="$fid"/>
                <xsl:text> returns a value, but I can</xsl:text>
                <xsl:value-of select="$newline"/>
                <xsl:text>find no place to put it (no "result-to" attribute).</xsl:text>
                <xsl:value-of select="$newline"/>
                <xsl:text>It is being left on the stack.</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="@result-to">
          <xsl:call-template name="warning">
            <xsl:with-param name="msg">
              <xsl:text>The return value of a fn cannot be read </xsl:text>
              <xsl:text>unless the</xsl:text>
              <xsl:value-of select="$newline"/>
              <xsl:text>attribute return="yes" is present. </xsl:text>
              <xsl:text>I am ignoring the "result-to"</xsl:text>
              <xsl:value-of select="$newline"/>
              <xsl:text>attribute of this call to fn </xsl:text>
              <xsl:value-of select="$fid"/>
              <xsl:text>.</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:fn">
    <xsl:call-template name="debug-start"/>
    <xsl:if test="xgf:variant">
      <xsl:variable name="variant-count" select="count(xgf:variant)"/>
      <xsl:call-template name="expression">
	<xsl:with-param name="val">
	  <xsl:for-each select="xgf:variant">
	    <xsl:variable name="current-test" select="normalize-space(./@test)"/>
	    <xsl:if test="position() &gt; 1">
	      <xsl:text> or </xsl:text>
	    </xsl:if>
	    <xsl:choose>
	      <xsl:when test="$variant-count &gt; 1 and contains($current-test,' ')">
		<xsl:value-of select="concat('(',$current-test,')')"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="$current-test"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:for-each>
	</xsl:with-param>
	<xsl:with-param name="to-stack" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
	<xsl:with-param name="cmd" select="'IF'"/>
      </xsl:call-template>
      <xsl:apply-templates select="xgf:variant" mode="compile">
	<xsl:with-param name="v-plural" select="$variant-count &gt; 1"/>
      </xsl:apply-templates>
      <xsl:call-template name="simple-command">
	<xsl:with-param name="cmd" select="'ELSE'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="." mode="compile"/>
    <xsl:if test="xgf:variant">
      <xsl:call-template name="simple-command">
	<xsl:with-param name="cmd" select="'EIF'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:fn|xgf:variant" mode="compile">
    <xsl:param name="all-params"
	       select="xgf:pm | parent::xgf:fn/xgf:pm"/>
    <xsl:param name="all-vars"
	       select="xgf:var | parent::xgf:fn/xgf:var"/>
    <xsl:param name="v-plural" select="false()"/>
    <xsl:if test="local-name() = 'variant' and (@nm or xgf:pm or xgf:var)">
      <xsl:call-template name="error-message">
	<xsl:with-param name="msg">
	  <xsl:text>A fn variant may not have a name attribute and may not
contain pm or var elements.</xsl:text>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:variable name="apply-test"
		  select="$v-plural and local-name() = 'variant' and @test"/>
    <xsl:if test="$apply-test">
      <xsl:call-template name="expression">
	<xsl:with-param name="val" select="@test"/>
	<xsl:with-param name="to-stack" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
	<xsl:with-param name="cmd" select="'IF'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="number-command">
      <xsl:with-param name="num">
        <xsl:call-template name="get-fn-number">
          <xsl:with-param name="fn-name">
	    <xsl:choose>
	      <xsl:when test="@nm">
		<xsl:value-of select="@nm"/>
	      </xsl:when>
	      <xsl:when test="parent::xgf:fn/@nm">
		<xsl:value-of select="parent::xgf:fn/@nm"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:call-template name="error-message">
		  <xsl:with-param name="msg">
		    <xsl:text>Encountered &lt;fn&lt; lacking name attribute.</xsl:text>
		  </xsl:with-param>
		</xsl:call-template>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="cmd" select="'FDEF'"/>
    </xsl:call-template>
    <!-- First save the current depth of the stack in the Storage Location
         var-fn-stack-count. This will help us find
         parameters when we need them, even if stuff has been pushed onto the
         stack in the meantime. -->
    <xsl:if test="$all-params">
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'DEPTH'"/>
      </xsl:call-template>
      <xsl:call-template name="stack-top-to-storage">
	<xsl:with-param name="loc">
	  <xsl:call-template name="resolve-std-var-loc">
	    <xsl:with-param name="n" select="$var-fn-stack-count"/>
	  </xsl:call-template>
	</xsl:with-param>
      </xsl:call-template>        
    </xsl:if>
    <!-- If we have declared variables, place the new top of the var
         frame in var-frame-top. -->
    <xsl:if test="$all-vars">
      <xsl:call-template name="push-num">
	<xsl:with-param name="num">
	  <xsl:call-template name="resolve-std-var-loc">
	    <xsl:with-param name="n" select="$var-frame-top"/>
	  </xsl:call-template>
	</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="number-command">
	<xsl:with-param name="num">
	  <xsl:call-template name="resolve-std-var-loc">
	    <xsl:with-param name="n" select="$var-frame-bottom"/>
	  </xsl:call-template>
	</xsl:with-param>
        <xsl:with-param name="cmd" select="'RS'"/>
      </xsl:call-template>
      <xsl:call-template name="number-command">
        <xsl:with-param name="num" select="count($all-vars)"/>
        <xsl:with-param name="cmd" select="'ADD'"/>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'WS'"/>
      </xsl:call-template>
      <!-- Also, initialize any that want initializing. -->
      <xsl:apply-templates select="$all-vars" mode="initialize"/>
    </xsl:if>
    <!-- If the fn is declared as expecting a return value, initialize
         var-return-value to zero. This is a safety measure, since it is
         impractical (right now at least) to check that the fn contains
         an instruction that writes to that location. -->
    <xsl:if test="@return = 'yes'">
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
    </xsl:if>
    <!-- Now execute instructions. -->
    <xsl:apply-templates/>
    <!-- Pop all the parameters off the stack, and we're done. -->
    <xsl:for-each select="$all-params">
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'POP'"/>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'ENDF'"/>
    </xsl:call-template>
    <xsl:if test="$apply-test">
      <xsl:call-template name="simple-command">
	<xsl:with-param name="cmd" select="'EIF'"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xgf:variant"></xsl:template>

  <xsl:template match="xgf:legacy-functions">
    <xsl:call-template name="debug-start"/>
    <xsl:apply-templates/>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:mo">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:apply-templates>
      <xsl:with-param name="mp-container"
		      select="$mp-container"/>
    </xsl:apply-templates>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:pmset" mode="mo">
    <xsl:param name="mid"/>
    <xsl:param name="mp-container"/>
    <xsl:apply-templates select="key('mo-index',$mid)">
      <xsl:with-param name="mp-container">
	<xsl:choose>
	  <xsl:when test="$mp-container and string-length($mp-container) &gt; 0">
	    <xsl:value-of select="concat(generate-id(), ' ', $mp-container)"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="generate-id()"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:with-param>
    </xsl:apply-templates>
<!--
    <xsl:choose>
      <xsl:when test="$mp-container and string-length($mp-container) &gt; 0">
	<xsl:apply-templates select="key('mo-index',$mid)">
	  <xsl:with-param name="mp-container" select="concat(generate-id(), ' ', $mp-container)"/>
	</xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="key('mo-index',$mid)">
	  <xsl:with-param name="mp-container" select="generate-id()"/>
	</xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
-->
  </xsl:template>

  <xsl:template match="xgf:callm">
    <xsl:param name="mp-container"/>
        <xsl:message><xsl:text>callm template called</xsl:text></xsl:message>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="mid">
      <xsl:choose>
	<xsl:when test="@nm">
	  <xsl:value-of select="@nm"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name="error-message">
	    <xsl:with-param name="msg">
	      <xsl:text>Encountered a &lt;callm&gt; without name.</xsl:text>
	    </xsl:with-param>
	  </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:message><xsl:text>Macro: </xsl:text><xsl:value-of select="$mid"/></xsl:message>
    <xsl:if test="not(key('mo-index',$mid))">
      <xsl:call-template name="error-message">
	<xsl:with-param name="msg">
	  <xsl:text>Can't find macro </xsl:text>
	  <xsl:value-of select="$mid"/>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="xgf:pmset">
	<xsl:apply-templates select="xgf:pmset" mode="mo">
	  <xsl:with-param name="mid" select="$mid"/>
	</xsl:apply-templates>
      </xsl:when>
      <xsl:when test="xgf:wpm">
	<xsl:message><xsl:text>Still running</xsl:text></xsl:message>
	<xsl:apply-templates select="key('mo-index',$mid)">
	  <xsl:with-param name="mp-container">
	    <xsl:choose>
	      <xsl:when test="$mp-container and string-length($mp-container) &gt; 0">
		<xsl:value-of select="concat(generate-id(), ' ', $mp-container)"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="generate-id()"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:with-param>
	</xsl:apply-templates>
<!--
	<xsl:choose>
	  <xsl:when test="$mp-container and string-length($mp-container) &gt; 0">
	    <xsl:apply-templates select="key('mo-index',$mid)">
	      <xsl:with-param name="mp-container" select="concat(generate-id(), ' ', $mp-container)"/>
	    </xsl:apply-templates>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:apply-templates select="key('mo-index',$mid)">
	      <xsl:with-param name="mp-container" select="generate-id()"/>
	    </xsl:apply-templates>
	  </xsl:otherwise>
	</xsl:choose>
-->
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="key('mo-index',$mid)"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:callg">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="n" select="@pnm"/>
    <xsl:if test="not(key('gl-index',$n))">
      <xsl:call-template name="error-message">
	<xsl:with-param name="msg">
	  <xsl:text>Cannot find gl program with psname="</xsl:text>
	  <xsl:value-of select="@pnm"/>
	  <xsl:text>"</xsl:text>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:variable name="save-var-frame"
		  select="key('gl-index',$n)/xgf:var"/>
    <!-- Save the var frame -->
    <xsl:if test="$save-var-frame">
      <xsl:call-template name="push-num">
	<xsl:with-param name="num">
	  <xsl:call-template name="resolve-std-var-loc">
	    <xsl:with-param name="n" select="$var-frame-bottom"/>
	  </xsl:call-template>
	</xsl:with-param>
	<xsl:with-param name="expect" select="2"/>
      </xsl:call-template>
      <xsl:call-template name="push-num">
	<xsl:with-param name="num">
	  <xsl:call-template name="resolve-std-var-loc">
	    <xsl:with-param name="n" select="$var-frame-bottom"/>
	  </xsl:call-template>
	</xsl:with-param>
	<xsl:with-param name="add-mode" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
	<xsl:with-param name="cmd" select="'RS'"/>
      </xsl:call-template>
      <xsl:call-template name="number-command">
	<xsl:with-param name="num">
	  <xsl:call-template name="resolve-std-var-loc">
	    <xsl:with-param name="n" select="$var-frame-top"/>
	  </xsl:call-template>
	</xsl:with-param>
	<xsl:with-param name="cmd" select="'RS'"/>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
	<xsl:with-param name="cmd" select="'WS'"/>
      </xsl:call-template>
    </xsl:if>
    <!-- Call the gl program, passing in any parameters -->
    <xsl:apply-templates select="key('gl-index',$n)" mode="called">
      <xsl:with-param name="mp-container">
	<xsl:choose>
	  <xsl:when test="$mp-container and string-length($mp-container) &gt; 0">
	    <xsl:value-of select="concat(generate-id(), ' ', $mp-container)"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="generate-id()"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:with-param>
    </xsl:apply-templates>
<!--
    <xsl:choose>
      <xsl:when test="$mp-container and string-length($mp-container) &gt; 0">
	<xsl:apply-templates select="key('gl-index',$n)" mode="called">
	  <xsl:with-param name="mp-container" select="concat(generate-id(), ' ', $mp-container)"/>
	</xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="key('gl-index',$n)" mode="called">
	  <xsl:with-param name="mp-container" select="generate-id()"/>
	</xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
-->
    <!-- Restore the var frame -->
    <xsl:if test="$save-var-frame">
      <xsl:call-template name="push-num">
	<xsl:with-param name="num">
	  <xsl:call-template name="resolve-std-var-loc">
	    <xsl:with-param name="n" select="$var-frame-top"/>
	  </xsl:call-template>
	</xsl:with-param>
	<xsl:with-param name="expect" select="2"/>
      </xsl:call-template>
      <xsl:call-template name="push-num">
	<xsl:with-param name="num">
	  <xsl:call-template name="resolve-std-var-loc">
	    <xsl:with-param name="n" select="$var-frame-bottom"/>
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
      <xsl:call-template name="stack-top-to-storage">
	<xsl:with-param name="loc">
	  <xsl:call-template name="resolve-std-var-loc">
	    <xsl:with-param name="n" select="$var-frame-bottom"/>
	  </xsl:call-template>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:gl" mode="called">
    <xsl:param name="mp-container"/>
    <xsl:if test="xgf:var">
      <xsl:call-template name="push-num">
	<xsl:with-param name="num">
	  <xsl:call-template name="resolve-std-var-loc">
	    <xsl:with-param name="n" select="$var-frame-top"/>
	  </xsl:call-template>
	</xsl:with-param>
	<xsl:with-param name="expect" select="2"/>
      </xsl:call-template>
      <xsl:call-template name="push-num">
	<xsl:with-param name="num">
	  <xsl:call-template name="resolve-std-var-loc">
	    <xsl:with-param name="n" select="$var-frame-bottom"/>
	  </xsl:call-template>
	</xsl:with-param>
	<xsl:with-param name="add-mode" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'RS'"/>
      </xsl:call-template>
      <xsl:call-template name="number-command">
        <xsl:with-param name="num" select="count(xgf:var)"/>
        <xsl:with-param name="cmd" select="'ADD'"/>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'WS'"/>
      </xsl:call-template>
      <!-- Also, initialize any that want initializing. -->
      <xsl:apply-templates select="xgf:var" mode="initialize"/>
    </xsl:if>
    <xsl:apply-templates>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="xgf:gl|xgf:fn|xgf:mo" mode="survey-vars">
    <xsl:choose>
      <xsl:when test="xgf:var">
	<xsl:text>v</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="xgf:callf|xgf:callg|xgf:callm"
			     mode="survey-vars"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xgf:callg|xgf:callf|xgf:callm"
		mode="survey-vars">
    <xsl:variable name="l" select="local-name()"/>
    <xsl:choose>
      <xsl:when test="$l = 'callg'">
	<xsl:text>g</xsl:text>
	<xsl:apply-templates select="key('gl-index',@pnm)" mode="survey-vars"/>
      </xsl:when>
      <xsl:when test="$l = 'callf'">
	<xsl:text>f</xsl:text>
	<xsl:apply-templates select="key('fn-index',@nm)" mode="survey-vars"/>
      </xsl:when>
      <xsl:when test="$l = 'callm'">
	<xsl:text>m</xsl:text>
	<xsl:apply-templates select="key('mo-index',@nm)" mode="survey-vars"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xgf:pm"></xsl:template>

  <xsl:template match="xgf:pm" mode="run-me">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:apply-templates>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:apply-templates>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:callp">
    <xsl:param name="mp-container"/>
    <xsl:param name="all-params"
	       select="ancestor::xgf:mo/xgf:pm|ancestor::xgf:gl/xgf:pm"/>
    <xsl:variable name="n" select="@nm"/>
    <xsl:choose>
      <xsl:when test="$all-params[@nm=$n]">
	<xsl:variable name="this-id">
	  <xsl:call-template name="get-first-mp-id">
	    <xsl:with-param name="mp-container" select="$mp-container"/>
	  </xsl:call-template>
	</xsl:variable>
	<xsl:choose>
	  <xsl:when test="string-length($this-id) and $mp-containers and
			  $mp-containers[generate-id() = $this-id]/xgf:wpm[@nm=$n]/*">
	    <xsl:apply-templates
		select="$mp-containers[generate-id() = $this-id]/xgf:wpm[@nm=$n]/*">
	      <xsl:with-param name="mp-container">
		<xsl:call-template name="get-remaining-mp-id">
		  <xsl:with-param name="mp-container" select="$mp-container"/>
		</xsl:call-template>
	      </xsl:with-param>
	    </xsl:apply-templates>
	  </xsl:when>
	  <xsl:when test="$all-params[@nm=$n]/*">
	    <xsl:apply-templates select="$all-params[@nm=$n]" mode="run-me">
	      <xsl:with-param name="mp-container"
			      select="$mp-container"/>
	    </xsl:apply-templates>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:call-template name="warning">
	      <xsl:with-param name="msg">
		<xsl:text>No code to execute for pm </xsl:text>
		<xsl:value-of select="$n"/>
		<xsl:text>: doing nothing</xsl:text>
	      </xsl:with-param>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="error-message">
	  <xsl:with-param name="msg">
	    <xsl:text>Cannot find pm </xsl:text>
	    <xsl:value-of select="$n"/>
	    <xsl:text> to call</xsl:text>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
