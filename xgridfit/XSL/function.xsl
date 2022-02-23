<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"
                version="1.0">

  <!--
      This file is part of xgridfit, version 3.
      Licensed under the Apache License, Version 2.0.
      Copyright (c) 2006-20 by Peter S. Baker
  -->

  <xsl:template name="get-highest-function-number">
    <xsl:param name="current-function"/>
    <xsl:param name="current-max" select="0"/>
    <xsl:variable name="new-max">
      <xsl:choose>
        <xsl:when test="number($current-max) &gt;
                        number($current-function/@num)">
          <xsl:value-of select="$current-max"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$current-function/@num"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$current-function/following-sibling::xgf:function[@num]">
        <xsl:call-template name="get-highest-function-number">
          <xsl:with-param name="current-function"
            select="$current-function/following-sibling::xgf:function[@num][1]"/>
          <xsl:with-param name="current-max" select="$new-max"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$new-max"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-macro-param-value">
    <xsl:param name="i"/> <!-- generated id of the with-param container -->
    <xsl:param name="n"/> <!-- name of the param -->
    <xsl:message>
      <xsl:text>generated id: </xsl:text>
      <xsl:value-of select="$i"/>
    </xsl:message>
    <xsl:choose>
      <xsl:when test="//call-macro[generate-id() = $i]/with-param[@name=$n]/@value">
        <xsl:value-of select="//call-macro[generate-id() = $i]/with-param[@name=$n]/@value"/>
      </xsl:when>
      <xsl:when test="//call-glyph[generate-id() = $i]/with-param[@name=$n]/@value">
        <xsl:value-of select="//call-glyph[generate-id() = $i]/with-param[@name=$n]/@value"/>
      </xsl:when>
      <xsl:when test="//param-set[generate-id() = $i]/with-param[@name=$n]/@value">
        <xsl:value-of
            select="//call-macro/param-set[generate-id() = $i]/with-param[@name=$n]/@value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>$$no-value$$</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="gfn-helper">
    <xsl:param name="f"/>
    <xsl:choose>
      <xsl:when test="$f[not(xgf:variant)]">
        <xsl:value-of select="number($function-base) +
                              number($predefined-functions) +
                              count($f/preceding-sibling::xgf:function[not(@num) and
                              not(xgf:variant)])"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="number($function-base) +
                              number($predefined-functions) +
                              count(/xgf:xgridfit/xgf:function[not(@num) and
                              not(xgf:variant)]) +
                              count($f/preceding-sibling::xgf:function[xgf:variant])"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-function-number">
    <xsl:param name="function-name"/>
    <xsl:if test="not(key('function-index',$function-name))">
      <xsl:call-template name="error-message">
        <xsl:with-param name="msg">
          <xsl:text>Function "</xsl:text>
          <xsl:value-of select="$function-name"/>
          <xsl:text>" not found</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="gfn-helper">
      <xsl:with-param name="f" select="key('function-index',$function-name)"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="get-function-param-names">
    <xsl:param name="f"/>
    <xsl:param name="all-params" select="key('function-index',$f)/xgf:param"/>
    <xsl:variable name="v">
      <xsl:for-each select="$all-params">
        <xsl:sort select="position()" order="descending"/>
        <xsl:text> </xsl:text>
        <xsl:choose>
          <xsl:when test="@name">
            <xsl:value-of select="@name"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="error-message">
              <xsl:with-param name="msg">
                <xsl:text>&lt;param&gt; in function "</xsl:text>
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

  <xsl:template name="make-param-string">
    <!--
        We assume that the current context element contains
        <with-param> children. Build a string descriptor containing a
        list of param values to pass to push-list.
    -->
    <xsl:param name="f"/>
    <xsl:param name="all-params" select="key('function-index',$f)/xgf:param"/>
    <xsl:param name="param-names"/>
    <xsl:param name="count" select="0"/>
    <xsl:variable name="current-name">
      <xsl:choose>
        <xsl:when test="contains($param-names,' ')">
          <xsl:value-of select="substring-before($param-names,' ')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$param-names"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="other-names">
      <xsl:choose>
        <xsl:when test="contains($param-names,' ')">
          <xsl:value-of select="substring-after($param-names,' ')"/>
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
      <xsl:when test="xgf:with-param[@name=$current-name]/@value">
        <xsl:value-of select="xgf:with-param[@name=$current-name]/@value"/>
      </xsl:when>
      <xsl:when test="$all-params[@name=$current-name]/@value">
        <xsl:value-of select="$all-params[@name=$current-name]/@value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="error-message">
          <xsl:with-param name="msg">
            <xsl:text>Cannot find a value for &lt;param&gt; "</xsl:text>
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
      <xsl:call-template name="make-param-string">
        <xsl:with-param name="f" select="$f"/>
        <xsl:with-param name="all-params" select="$all-params"/>
        <xsl:with-param name="param-names" select="$other-names"/>
        <xsl:with-param name="count" select="$count + 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!--
      Gets the function parameters onto the stack.
  -->
  <xsl:template match="xgf:param-set|xgf:call-function" mode="function">
    <xsl:param name="mp-container"/>
    <xsl:param name="f" select="ancestor-or-self::xgf:call-function/@name"/>
    <xsl:param name="all-params" select="key('function-index',$f)/xgf:param"/>
    <xsl:if test="local-name() = 'param-set'">
      <xsl:call-template name="debug-start"/>
    </xsl:if>
    <xsl:variable name="param-list">
      <xsl:call-template name="get-function-param-names">
        <xsl:with-param name="f" select="$f"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="param-value-list">
      <xsl:call-template name="make-param-string">
        <xsl:with-param name="f" select="$f"/>
        <xsl:with-param name="param-names" select="$param-list"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- Check the with-param elements for validity, since the schema does little -->
    <xsl:variable name="p">
      <xsl:choose>
        <xsl:when test="ancestor::xgf:function">
          <xsl:text>1xmpfvnc</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>1xmpvnc</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="push-list">
      <xsl:with-param name="list" select="$param-value-list"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:if test="local-name() = 'param-set'">
      <xsl:call-template name="debug-end"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xgf:call-function">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="fid">
      <xsl:choose>
        <xsl:when test="@name">
          <xsl:value-of select="@name"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="error-message">
            <xsl:with-param name="msg">
              <xsl:text>Encountered &lt;call-function&gt; element without name.</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="function-has-variables"
                  select="key('function-index',$fid)/xgf:variable"/>
    <!-- If we're calling this from a function, we need to preserve
         the variable $var-function-stack-count and restore it after
         we're done. -->
    <xsl:if test="ancestor::xgf:function">
      <xsl:call-template name="number-command">
        <xsl:with-param name="num">
          <xsl:call-template name="resolve-std-variable-loc">
            <xsl:with-param name="n" select="$var-function-stack-count"/>
          </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="cmd" select="'RS'"/>
      </xsl:call-template>
    </xsl:if>
    <!--
        If the function we're calling uses variables, we need to save
        the current variable frame.
    -->
    <xsl:if test="$function-has-variables">
      <xsl:call-template name="number-command">
        <xsl:with-param name="num">
          <xsl:call-template name="resolve-std-variable-loc">
            <xsl:with-param name="n" select="$var-frame-bottom"/>
          </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="cmd" select="'RS'"/>
      </xsl:call-template>
    </xsl:if>
    <!-- push the parameters onto the stack. -->
    <xsl:choose>
      <xsl:when test="xgf:param-set">
        <xsl:apply-templates select="xgf:param-set" mode="function">
          <xsl:with-param name="mp-container"
                          select="$mp-container"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="function">
          <xsl:with-param name="mp-container"
                          select="$mp-container"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
    <!-- continue saving variable frame. -->
    <xsl:if test="$function-has-variables">
      <xsl:call-template name="push-list">
        <xsl:with-param name="list">
          <xsl:call-template name="resolve-std-variable-loc">
            <xsl:with-param name="n" select="$var-frame-bottom"/>
          </xsl:call-template>
          <xsl:value-of select="$semicolon"/>
          <xsl:call-template name="resolve-std-variable-loc">
            <xsl:with-param name="n" select="$var-frame-top"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'RS'"/>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'WS'"/>
      </xsl:call-template>
    </xsl:if>
    <!-- Push the index of this function. This always matches the number that
         was used to define the function when the fgpm table was set up. -->
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
        <xsl:call-template name="get-function-number">
          <xsl:with-param name="function-name" select="$fid"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <!-- Call via CALL or LOOPCALL, depending on whether we have two sets of
         parameters, or more, or fewer. -->
    <xsl:choose>
      <xsl:when test="count(xgf:param-set) &gt; 1">
        <xsl:call-template name="push-num">
          <xsl:with-param name="num" select="count(xgf:param-set)"/>
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
    <!-- Now restore variable frame. Copy var-frame-bottom to var-frame-top
         and then copy the number we saved to the stack before the call into
         var-frame-bottom. -->
    <xsl:if test="$function-has-variables">
      <xsl:call-template name="push-list">
        <xsl:with-param name="list">
          <xsl:call-template name="resolve-std-variable-loc">
            <xsl:with-param name="n" select="$var-frame-top"/>
          </xsl:call-template>
          <xsl:value-of select="$semicolon"/>
          <xsl:call-template name="resolve-std-variable-loc">
            <xsl:with-param name="n" select="$var-frame-bottom"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'RS'"/>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'WS'"/>
      </xsl:call-template>
      <xsl:call-template name="stack-top-to-storage">
        <xsl:with-param name="loc">
          <xsl:call-template name="resolve-std-variable-loc">
            <xsl:with-param name="n" select="$var-frame-bottom"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <!-- If we're calling this from a function, we need to restore
         the previous value of $var-function-stack-count (it's supposed
         to be on top of the stack after the function returns). -->
    <xsl:if test="ancestor::xgf:function">
      <xsl:call-template name="stack-top-to-storage">
        <xsl:with-param name="loc">
          <xsl:call-template name="resolve-std-variable-loc">
            <xsl:with-param name="n" select="$var-function-stack-count"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <!-- If the function we are calling has the attribute return="yes" then
         we collect the return value from var-return-value. We'd like to
         store it in a variable (or whatever) referenced by "result-to", but
         if that attribute is missing we issue a warning and leave the value
         on the stack. -->
    <xsl:choose>
      <xsl:when test="key('function-index',$fid)/@return = 'yes'">
        <xsl:choose>
          <xsl:when test="@result-to">
            <xsl:call-template name="number-command">
              <xsl:with-param name="num">
                <xsl:call-template name="resolve-std-variable-loc">
                  <xsl:with-param name="n" select="$var-return-value"/>
                </xsl:call-template>
              </xsl:with-param>
              <xsl:with-param name="cmd" select="'RS'"/>
            </xsl:call-template>
            <xsl:call-template name="store-value">
              <xsl:with-param name="vname" select="@result-to"/>
              <xsl:with-param name="mp-container" select="$mp-container"/>
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
              <xsl:text>The return value of a function cannot be read </xsl:text>
              <xsl:text>unless the</xsl:text>
              <xsl:value-of select="$newline"/>
              <xsl:text>attribute return="yes" is present. </xsl:text>
              <xsl:text>I am ignoring the "result-to"</xsl:text>
              <xsl:value-of select="$newline"/>
              <xsl:text>attribute of this call to function </xsl:text>
              <xsl:value-of select="$fid"/>
              <xsl:text>.</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:function">
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

  <xsl:template match="xgf:function|xgf:variant" mode="compile">
    <xsl:param name="all-params"
               select="xgf:param | parent::xgf:function/xgf:param"/>
    <xsl:param name="all-vars"
               select="xgf:variable | parent::xgf:function/xgf:variable"/>
    <xsl:param name="v-plural" select="false()"/>
    <!--
      If attribute primitive='yes' is present, skip all the setup and don't
      pop parameters off the stack. We assume that the programmer is handling
      the stack responsibly.
    -->
    <xsl:variable name="is-primitive" select="@primitive = 'yes'"/>
    <xsl:if test="local-name() = 'variant' and (@name or xgf:param or xgf:variable)">
      <xsl:call-template name="error-message">
        <xsl:with-param name="msg">
          <xsl:text>A function variant may not have a name attribute and may not
contain param or variable elements.</xsl:text>
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
        <xsl:call-template name="get-function-number">
          <xsl:with-param name="function-name">
            <xsl:choose>
              <xsl:when test="@name">
                <xsl:value-of select="@name"/>
              </xsl:when>
              <xsl:when test="parent::xgf:function/@name">
                <xsl:value-of select="parent::xgf:function/@name"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="error-message">
                  <xsl:with-param name="msg">
                    <xsl:text>Encountered &lt;function&lt; lacking name attribute.</xsl:text>
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
         var-function-stack-count. This will help us find
         parameters when we need them, even if stuff has been pushed onto the
         stack in the meantime. -->
    <xsl:if test="not($is-primitive)">
      <xsl:if test="$all-params">
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'DEPTH'"/>
        </xsl:call-template>
        <xsl:call-template name="stack-top-to-storage">
          <xsl:with-param name="loc">
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-function-stack-count"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    <!-- If we have declared variables, place the new top of the variable
         frame in var-frame-top. -->
      <xsl:if test="$all-vars">
        <xsl:call-template name="push-num">
          <xsl:with-param name="num">
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-frame-top"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="number-command">
          <xsl:with-param name="num">
            <xsl:call-template name="resolve-std-variable-loc">
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
      <!-- If the function is declared as expecting a return value, initialize
           var-return-value to zero. This is a safety measure, since it is
           impractical (right now at least) to check that the function contains
           an instruction that writes to that location. -->
      <xsl:if test="@return = 'yes'">
        <xsl:call-template name="push-list">
          <xsl:with-param name="list">
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-return-value"/>
            </xsl:call-template>
            <xsl:value-of select="$semicolon"/>
            <xsl:value-of select="0"/>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'WS'"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
    <!-- Now execute instructions. -->
    <xsl:apply-templates/>
    <!-- Pop all the parameters off the stack, and we're done. -->
    <xsl:if test="not($is-primitive)">
      <xsl:for-each select="$all-params">
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'POP'"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:if>
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

  <xsl:template match="xgf:macro">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:apply-templates>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:apply-templates>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:param-set" mode="macro">
    <xsl:param name="mid"/>
    <xsl:param name="mp-container"/>
    <xsl:apply-templates select="key('macro-index',$mid)">
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
        <xsl:apply-templates select="key('macro-index',$mid)">
          <xsl:with-param name="mp-container" select="concat(generate-id(), ' ', $mp-container)"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="key('macro-index',$mid)">
          <xsl:with-param name="mp-container" select="generate-id()"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
-->
  </xsl:template>

  <xsl:template match="xgf:call-macro">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="mid">
      <xsl:choose>
        <xsl:when test="@name">
          <xsl:value-of select="@name"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="error-message">
            <xsl:with-param name="msg">
              <xsl:text>Encountered a &lt;call-macro&gt; without name.</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="not(key('macro-index',$mid))">
      <xsl:call-template name="error-message">
        <xsl:with-param name="msg">
          <xsl:text>Can't find macro </xsl:text>
          <xsl:value-of select="$mid"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="xgf:param-set">
        <xsl:apply-templates select="xgf:param-set" mode="macro">
          <xsl:with-param name="mid" select="$mid"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="xgf:with-param">
        <xsl:apply-templates select="key('macro-index',$mid)">
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
            <xsl:apply-templates select="key('macro-index',$mid)">
              <xsl:with-param name="mp-container" select="concat(generate-id(), ' ', $mp-container)"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="key('macro-index',$mid)">
              <xsl:with-param name="mp-container" select="generate-id()"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
-->
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="key('macro-index',$mid)"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:call-glyph">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="n" select="@ps-name"/>
    <xsl:if test="not(key('glyph-index',$n))">
      <xsl:call-template name="error-message">
        <xsl:with-param name="msg">
          <xsl:text>Cannot find glyph program with psname="</xsl:text>
          <xsl:value-of select="@ps-name"/>
          <xsl:text>"</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:variable name="save-variable-frame"
                  select="key('glyph-index',$n)/xgf:variable"/>
    <!-- Save the variable frame -->
    <xsl:if test="$save-variable-frame">
      <xsl:call-template name="push-list">
        <xsl:with-param name="list">
          <xsl:call-template name="resolve-std-variable-loc">
            <xsl:with-param name="n" select="$var-frame-bottom"/>
          </xsl:call-template>
          <xsl:value-of select="$semicolon"/>
          <xsl:call-template name="resolve-std-variable-loc">
            <xsl:with-param name="n" select="$var-frame-bottom"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'RS'"/>
      </xsl:call-template>
      <xsl:call-template name="number-command">
        <xsl:with-param name="num">
          <xsl:call-template name="resolve-std-variable-loc">
            <xsl:with-param name="n" select="$var-frame-top"/>
          </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="cmd" select="'RS'"/>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'WS'"/>
      </xsl:call-template>
    </xsl:if>
    <!-- Call the glyph program, passing in any parameters -->
    <xsl:apply-templates select="key('glyph-index',$n)" mode="called">
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
        <xsl:apply-templates select="key('glyph-index',$n)" mode="called">
          <xsl:with-param name="mp-container" select="concat(generate-id(), ' ', $mp-container)"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="key('glyph-index',$n)" mode="called">
          <xsl:with-param name="mp-container" select="generate-id()"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
-->
    <!-- Restore the variable frame -->
    <xsl:if test="$save-variable-frame">
      <xsl:call-template name="push-list">
        <xsl:with-param name="list">
          <xsl:call-template name="resolve-std-variable-loc">
            <xsl:with-param name="n" select="$var-frame-top"/>
          </xsl:call-template>
          <xsl:value-of select="$semicolon"/>
          <xsl:call-template name="resolve-std-variable-loc">
            <xsl:with-param name="n" select="$var-frame-bottom"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'RS'"/>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'WS'"/>
      </xsl:call-template>
      <xsl:call-template name="stack-top-to-storage">
        <xsl:with-param name="loc">
          <xsl:call-template name="resolve-std-variable-loc">
            <xsl:with-param name="n" select="$var-frame-bottom"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:glyph" mode="called">
    <xsl:param name="mp-container"/>
    <xsl:if test="xgf:variable">
      <xsl:call-template name="push-list">
        <xsl:with-param name="list">
          <xsl:call-template name="resolve-std-variable-loc">
            <xsl:with-param name="n" select="$var-frame-top"/>
          </xsl:call-template>
          <xsl:value-of select="$semicolon"/>
          <xsl:call-template name="resolve-std-variable-loc">
            <xsl:with-param name="n" select="$var-frame-bottom"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'RS'"/>
      </xsl:call-template>
      <xsl:call-template name="number-command">
        <xsl:with-param name="num" select="count(xgf:variable)"/>
        <xsl:with-param name="cmd" select="'ADD'"/>
      </xsl:call-template>
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'WS'"/>
      </xsl:call-template>
      <!-- Also, initialize any that want initializing. -->
      <xsl:apply-templates select="xgf:variable" mode="initialize"/>
    </xsl:if>
    <xsl:apply-templates>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="xgf:glyph|xgf:function|xgf:macro" mode="survey-vars">
    <xsl:choose>
      <xsl:when test="xgf:variable">
        <xsl:text>v</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="xgf:call-function|xgf:call-glyph|xgf:call-macro"
                             mode="survey-vars"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xgf:call-glyph|xgf:call-function|xgf:call-macro"
                mode="survey-vars">
    <xsl:variable name="l" select="local-name()"/>
    <xsl:choose>
      <xsl:when test="$l = 'call-glyph'">
        <xsl:text>g</xsl:text>
        <xsl:apply-templates select="key('glyph-index',@ps-name)" mode="survey-vars"/>
      </xsl:when>
      <xsl:when test="$l = 'call-function'">
        <xsl:text>f</xsl:text>
        <xsl:apply-templates select="key('function-index',@name)" mode="survey-vars"/>
      </xsl:when>
      <xsl:when test="$l = 'call-macro'">
        <xsl:text>m</xsl:text>
        <xsl:apply-templates select="key('macro-index',@name)" mode="survey-vars"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xgf:param"></xsl:template>

  <xsl:template match="xgf:param" mode="run-me">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:apply-templates>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:apply-templates>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:call-param">
    <xsl:param name="mp-container"/>
    <xsl:param name="all-params"
               select="ancestor::xgf:macro/xgf:param|ancestor::xgf:glyph/xgf:param"/>
    <xsl:variable name="n" select="@name"/>
    <xsl:choose>
      <xsl:when test="$all-params[@name=$n]">
        <xsl:variable name="this-id">
          <xsl:call-template name="get-first-mp-id">
            <xsl:with-param name="mp-container" select="$mp-container"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="string-length($this-id) and $mp-containers and
                          $mp-containers[generate-id() = $this-id]/xgf:with-param[@name=$n]/*">
            <xsl:apply-templates
                select="$mp-containers[generate-id() = $this-id]/xgf:with-param[@name=$n]/*">
              <xsl:with-param name="mp-container">
                <xsl:call-template name="get-remaining-mp-id">
                  <xsl:with-param name="mp-container" select="$mp-container"/>
                </xsl:call-template>
              </xsl:with-param>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="$all-params[@name=$n]/*">
            <xsl:apply-templates select="$all-params[@name=$n]" mode="run-me">
              <xsl:with-param name="mp-container" select="$mp-container"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="warning">
              <xsl:with-param name="msg">
                <xsl:text>No code to execute for param </xsl:text>
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
            <xsl:text>Cannot find param </xsl:text>
            <xsl:value-of select="$n"/>
            <xsl:text> to call</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
