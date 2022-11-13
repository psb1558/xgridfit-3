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

      push-num

      Pushes a single number, using the appropriate command.  If
      add-mode=true the push instruction is not output, but only a
      separator and the number; this adds the command onto a
      previously output push instruction. If add-mode=false then a
      PUSH command is output according to the size param, or if none,
      PUSHB for numbers between 0 and 255, PUSHW otherwise.
  -->
  <xsl:template name="push-num">
    <xsl:param name="num"/>
    <xsl:param name="expect" select="1"/>
    <xsl:param name="add-mode" select="false()"/>
    <xsl:param name="size"/>
    <xsl:variable name="size-s">
      <xsl:choose>
        <xsl:when test="$size">
          <xsl:value-of select="$size"/>
        </xsl:when>
        <!--
        <xsl:when test="$merge-mode">
          <xsl:text>M</xsl:text>
        </xsl:when>
        -->
        <xsl:when test="number($num) &gt;= 0 and number($num) &lt; 256">
          <xsl:text>B</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>W</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$add-mode">
        <xsl:value-of select="$push-num-separator"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="push-command">
          <xsl:with-param name="size" select="$size-s"/>
          <xsl:with-param name="count" select="$expect"/>
        </xsl:call-template>
        <xsl:value-of select="$inst-newline"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$num"/>
  </xsl:template>

  <!--

      number-command

      For commands that take a single number argument.
  -->
  <xsl:template name="number-command">
    <xsl:param name="num"/>
    <xsl:param name="cmd"/>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="$num"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="$cmd"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="xgf:glyph" mode="resolve-local-value">
    <xsl:param name="val"/>
    <xsl:param name="permitted"/>
    <xsl:param name="debug" select="false()"/>
    <xsl:call-template name="expression">
      <xsl:with-param name="val" select="$val"/>
      <xsl:with-param name="permitted" select="$permitted"/>
      <xsl:with-param name="debug" select="$debug"/>
      <xsl:with-param name="called-from"
                      select="'glyph with mode resolve-local-value'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="get-first-mp-id">
    <xsl:param name="mp-container"/>
    <xsl:choose>
      <xsl:when test="$mp-container and string-length($mp-container)">
        <xsl:choose>
          <xsl:when test="contains($mp-container, ' ')">
            <xsl:value-of select="substring-before($mp-container, ' ')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$mp-container"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-remaining-mp-id">
    <xsl:param name="mp-container"/>
    <xsl:choose>
      <xsl:when test="$mp-container and string-length($mp-container) &gt; 0">
        <xsl:choose>
          <xsl:when test="contains($mp-container, ' ')">
            <xsl:value-of select="substring-after($mp-container, ' ')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text></xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="expression-with-offset">
    <xsl:param name="val"/>
    <xsl:param name="this-glyph" select="ancestor::xgf:glyph"/>
    <xsl:param name="add-mode" select="false()"/>
    <xsl:param name="permitted" select="'12xmplrfvncg'"/>
    <xsl:param name="expect" select="1"/>
    <xsl:param name="mp-container"/>
    <xsl:param name="called-from" select="'unknown'"/>
    <xsl:param name="to-stack" select="false()"/>
    <xsl:param name="crash-on-fail" select="false()"/>
    <xsl:param name="debug" select="false()"/>
    <xsl:variable name="vn" select="normalize-space($val)"/>
    <xsl:variable name="this-id">
      <xsl:call-template name="get-first-mp-id">
        <xsl:with-param name="mp-container" select="$mp-container"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- <xsl:message><xsl:text>ID: </xsl:text><xsl:value-of
         select="$this-id"/></xsl:message> -->
    <xsl:variable name="val-passed-in"
                  select="string-length($this-id) and
                          $mp-containers and
                          $mp-containers[generate-id() = $this-id]/xgf:with-param[@name = $vn]"/>
    <xsl:choose>
      <xsl:when test="$this-glyph/xgf:param[@name='offset'] and not($val-passed-in)">
        <!--
            Look for the optimized way to put the number on the stack.
        -->
        <xsl:variable name="v">
          <xsl:call-template name="expression">
            <xsl:with-param name="val" select="$vn"/>
            <xsl:with-param name="this-glyph" select="$this-glyph"/>
            <xsl:with-param name="permitted" select="$permitted"/>
            <xsl:with-param name="called-from" select="'expression-with-offset-1'"/>
            <xsl:with-param name="mp-container" select="$mp-container"/>
            <xsl:with-param name="debug" select="$debug"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="o">
          <xsl:call-template name="expression">
            <xsl:with-param name="val" select="'offset'"/>
            <xsl:with-param name="this-glyph" select="$this-glyph"/>
            <xsl:with-param name="permitted" select="$permitted"/>
            <xsl:with-param name="called-from" select="'expression-with-offset-2'"/>
            <xsl:with-param name="mp-container" select="$mp-container"/>
            <xsl:with-param name="debug" select="$debug"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$to-stack">
            <xsl:choose>
              <xsl:when test="(number($v) or number($v) = 0) and
                              (number($o) or number($o) = 0)">
                <xsl:choose>
                  <xsl:when test="$to-stack">
                    <xsl:call-template name="push-num">
                      <xsl:with-param name="num">
                        <xsl:value-of select="number($v) + number($o)"/>
                      </xsl:with-param>
                      <xsl:with-param name="expect" select="$expect"/>
                      <xsl:with-param name="add-mode" select="$add-mode"/>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="number($v) + number($o)"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <!--
                    If optimization didn't work, make up an expression and
                    submit it for parsing. This will be slow.
                -->
                <xsl:call-template name="expression">
                  <xsl:with-param name="val"
                                  select="concat('(',$vn,') + offset')"/>
                  <xsl:with-param name="this-glyph" select="$this-glyph"/>
                  <xsl:with-param name="add-mode" select="$add-mode"/>
                  <xsl:with-param name="permitted" select="$permitted"/>
                  <xsl:with-param name="expect" select="$expect"/>
                  <xsl:with-param name="called-from" select="'expression-with-offset-3'"/>
                  <xsl:with-param name="mp-container" select="$mp-container"/>
                  <xsl:with-param name="to-stack" select="$to-stack"/>
                  <xsl:with-param name="debug" select="$debug"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise> <!-- i.e. we don't want the value on the stack -->
            <xsl:choose>
              <xsl:when test="(number($v) or number($v) = 0) and
                              (number($o) or number($o) = 0)">
                <xsl:value-of select="number($v) + number($o)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>NaN</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="expression">
          <xsl:with-param name="val" select="$vn"/>
          <xsl:with-param name="this-glyph" select="$this-glyph"/>
          <xsl:with-param name="add-mode" select="$add-mode"/>
          <xsl:with-param name="permitted" select="$permitted"/>
          <xsl:with-param name="expect" select="$expect"/>
          <xsl:with-param name="called-from" select="'expression-with-offset-4'"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
          <xsl:with-param name="to-stack" select="$to-stack"/>
          <xsl:with-param name="crash-on-fail" select="$crash-on-fail"/>
          <xsl:with-param name="debug" select="$debug"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
      "expression" is the grand unified value lookup facility. In
      former versions (before 2.0) there were two such templates: one
      for looking up values that could be resolved to numbers at
      compile time, and one for values that could be resolved only at
      run time. This does both in one go, and as a result can order
      lookups properly by scope: e.g. a locally declared variable is
      looked up before a global constant. All number lookups go
      through this template, which is nearly 1000 lines long; so we
      are looking for good ways to optimize. Here we pre-test for some
      common types of values, and of course number literals are
      discovered near the beginning of the procedure.
  -->

  <xsl:template name="expression">
    <xsl:param name="val"/>
    <xsl:param name="permitted" select="'12xmplrfvncg'"/>
    <xsl:param name="cvt-mode" select="'index'"/>
    <xsl:param name="force-to-index" select="false()"/>
    <xsl:param name="need-number-now" select="false()"/>
    <xsl:param name="getinfo-index" select="false()"/>
    <xsl:param name="this-glyph" select="ancestor-or-self::xgf:glyph"/>
    <xsl:param name="this-function" select="ancestor::xgf:function"/>
    <xsl:param name="this-prep" select="ancestor::xgf:pre-program"/>
    <xsl:param name="mp-container"/>
    <xsl:param name="all-function-params" select="$this-function/xgf:param"/>
    <xsl:param name="all-variables"
               select="$this-glyph/xgf:variable|$this-function/xgf:variable|
                       $this-prep/xgf:variable"/>
    <xsl:param name="all-global-variables" select="/xgf:xgridfit/xgf:variable"/>
    <xsl:param name="all-macro-params"
               select="ancestor::xgf:macro/xgf:param|
                       ancestor::xgf:glyph/xgf:param"/>
    <xsl:param name="all-constants" select="$this-glyph/xgf:constant"/>
    <xsl:param name="all-global-constants" select="/xgf:xgridfit/xgf:constant"/>
    <xsl:param name="all-aliases"
               select="$this-glyph/xgf:alias|ancestor::xgf:function/xgf:alias|
                       ancestor::xgf:macro/xgf:alias|
                       ancestor::xgf:pre-program/xgf:alias"/>
    <xsl:param name="all-global-aliases"
               select="/xgf:xgridfit/xgf:alias"/>
    <xsl:param name="debug" select="false()"/>
    <xsl:param name="called-from" select="'unknown'"/>
    <xsl:param name="recursion" select="0"/>
    <xsl:param name="to-stack" select="false()"/>
    <xsl:param name="add-mode" select="false()"/>
    <xsl:param name="expect" select="1"/>
    <xsl:param name="crash-on-fail" select="false()"/>

    <xsl:variable name="valn">
      <xsl:call-template name="normalize-expression">
        <xsl:with-param name="s" select="$val"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$debug">
      <xsl:message>
        <xsl:choose>
          <xsl:when test="$recursion = 0">
            <xsl:value-of select="$text-newline"/>
            <xsl:text>- - - - - - - - - - - - - - - - - - - - - -</xsl:text>
            <xsl:value-of select="$text-newline"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Recursion level </xsl:text>
            <xsl:value-of select="$recursion"/>
            <xsl:text> - - - - - -</xsl:text>
            <xsl:value-of select="$text-newline"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>"expression" called from location </xsl:text>
        <xsl:value-of select="$called-from"/>
        <xsl:value-of select="$text-newline"/>
        <xsl:text>Evaluating expression "</xsl:text>
        <xsl:value-of select="$valn"/>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="$text-newline"/>
        <xsl:text>permitted: </xsl:text>
        <xsl:value-of select="$permitted"/>
        <xsl:value-of select="$text-newline"/>
        <xsl:text>crash-on-fail: </xsl:text>
        <xsl:value-of select="number($crash-on-fail)"/>
        <xsl:value-of select="$text-newline"/>
        <xsl:text>to-stack: </xsl:text>
        <xsl:value-of select="number($to-stack)"/>
        <xsl:value-of select="$text-newline"/>
        <xsl:text>cvt-mode: </xsl:text>
        <xsl:value-of select="$cvt-mode"/>
      </xsl:message>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="$all-aliases[@name=$valn]">
        <xsl:call-template name="expression">
          <xsl:with-param name="val" select="$all-aliases[@name=$valn]/@target"/>
          <xsl:with-param name="permitted" select="$permitted"/>
          <xsl:with-param name="cvt-mode" select="$cvt-mode"/>
          <xsl:with-param name="force-to-index" select="$force-to-index"/>
          <xsl:with-param name="need-number-now" select="$need-number-now"/>
          <xsl:with-param name="getinfo-index" select="$getinfo-index"/>
          <xsl:with-param name="this-glyph" select="$this-glyph"/>
          <xsl:with-param name="this-function" select="$this-function"/>
          <xsl:with-param name="this-prep" select="$this-prep"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
          <xsl:with-param name="all-function-params" select="$all-function-params"/>
          <xsl:with-param name="all-variables" select="$all-variables"/>
          <xsl:with-param name="all-global-variables" select="$all-global-variables"/>
          <xsl:with-param name="all-macro-params" select="$all-macro-params"/>
          <xsl:with-param name="all-constants" select="$all-constants"/>
          <xsl:with-param name="all-global-constants" select="$all-global-constants"/>
          <xsl:with-param name="all-aliases" select="$all-aliases"/>
          <xsl:with-param name="all-global-aliases" select="$all-global-aliases"/>
          <xsl:with-param name="debug" select="$debug"/>
          <xsl:with-param name="called-from" select="'recurse for local alias'"/>
          <xsl:with-param name="recursion" select="$recursion + 1"/>
          <xsl:with-param name="to-stack" select="$to-stack"/>
          <xsl:with-param name="add-mode" select="$add-mode"/>
          <xsl:with-param name="expect" select="$expect"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$all-global-aliases[@name=$valn]">
        <xsl:call-template name="expression">
          <xsl:with-param name="val" select="$all-global-aliases[@name=$valn]/@target"/>
          <xsl:with-param name="permitted" select="$permitted"/>
          <xsl:with-param name="cvt-mode" select="$cvt-mode"/>
          <xsl:with-param name="force-to-index" select="$force-to-index"/>
          <xsl:with-param name="need-number-now" select="$need-number-now"/>
          <xsl:with-param name="getinfo-index" select="$getinfo-index"/>
          <xsl:with-param name="this-glyph" select="$this-glyph"/>
          <xsl:with-param name="this-function" select="$this-function"/>
          <xsl:with-param name="this-prep" select="$this-prep"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
          <xsl:with-param name="all-function-params" select="$all-function-params"/>
          <xsl:with-param name="all-variables" select="$all-variables"/>
          <xsl:with-param name="all-global-variables" select="$all-global-variables"/>
          <xsl:with-param name="all-macro-params" select="$all-macro-params"/>
          <xsl:with-param name="all-constants" select="$all-constants"/>
          <xsl:with-param name="all-global-constants" select="$all-global-constants"/>
          <xsl:with-param name="all-aliases" select="$all-aliases"/>
          <xsl:with-param name="all-global-aliases" select="$all-global-aliases"/>
          <xsl:with-param name="debug" select="$debug"/>
          <xsl:with-param name="called-from" select="'recurse for global alias'"/>
          <xsl:with-param name="recursion" select="$recursion + 1"/>
          <xsl:with-param name="to-stack" select="$to-stack"/>
          <xsl:with-param name="add-mode" select="$add-mode"/>
          <xsl:with-param name="expect" select="$expect"/>
        </xsl:call-template>
      </xsl:when>
      <!--
          If we're in a macro and this is a macro parameter, recurse
          substituting the value. I don't think this will work for a
          call-macro inside a macro. This would be a very desirable
          thing, so investigate further.
      -->
      <xsl:when test="$all-macro-params[@name=$valn]">
        <xsl:variable name="this-id">
          <xsl:call-template name="get-first-mp-id">
            <xsl:with-param name="mp-container" select="$mp-container"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <!--
              The first case is that there is a matching <with-param>
              element for this param. We transfer the context there
              with a template that will call <expression> recursively.
              $mp-container is a stack containing generated ids of
              macro with-param containers as a space-delimited
              list. We pop the current id and pass the remainder (if
              any) to the get-my-val template.
          -->
          <xsl:when test="string-length($this-id) and
                          $mp-containers and
                          $mp-containers[generate-id() = $this-id]/xgf:with-param[@name=$valn]/@value">
            <xsl:apply-templates
                select="$mp-containers[generate-id() = $this-id]/xgf:with-param[@name=$valn]"
                mode="get-my-val">
              <xsl:with-param name="cvt-mode" select="$cvt-mode"/>
              <xsl:with-param name="force-to-index" select="$force-to-index"/>
              <xsl:with-param name="permitted" select="$permitted"/>
              <xsl:with-param name="to-stack" select="$to-stack"/>
              <xsl:with-param name="add-mode" select="$add-mode"/>
              <xsl:with-param name="expect" select="$expect"/>
              <xsl:with-param name="need-number-now" select="$need-number-now"/>
              <xsl:with-param name="called-from" select="'recurse for param'"/>
              <xsl:with-param name="mp-container">
                <xsl:call-template name="get-remaining-mp-id">
                  <xsl:with-param name="mp-container" select="$mp-container"/>
                </xsl:call-template>
              </xsl:with-param>
            </xsl:apply-templates>
          </xsl:when>
          <!--
              The second case is that there is a default @value for
              this param. In that case we simply recurse as if it
              were an alias.
          -->
          <xsl:when test="$all-macro-params[@name=$valn]/@value">
          <!-- <xsl:when test="$is-macro"> -->
            <xsl:call-template name="expression">
              <xsl:with-param name="val" select="$all-macro-params[@name=$valn]/@value"/>
              <xsl:with-param name="permitted" select="$permitted"/>
              <xsl:with-param name="cvt-mode" select="$cvt-mode"/>
              <xsl:with-param name="force-to-index" select="$force-to-index"/>
              <xsl:with-param name="need-number-now" select="$need-number-now"/>
              <xsl:with-param name="getinfo-index" select="$getinfo-index"/>
              <xsl:with-param name="this-glyph" select="$this-glyph"/>
              <xsl:with-param name="this-function" select="$this-function"/>
              <xsl:with-param name="this-prep" select="$this-prep"/>
              <xsl:with-param name="mp-container">
                <xsl:call-template name="get-remaining-mp-id">
                  <xsl:with-param name="mp-container" select="$mp-container"/>
                </xsl:call-template>
              </xsl:with-param>
              <xsl:with-param name="all-function-params" select="$all-function-params"/>
              <xsl:with-param name="all-variables" select="$all-variables"/>
              <xsl:with-param name="all-global-variables" select="$all-global-variables"/>
              <xsl:with-param name="all-macro-params" select="$all-macro-params"/>
              <xsl:with-param name="all-constants" select="$all-constants"/>
              <xsl:with-param name="all-global-constants" select="$all-global-constants"/>
              <xsl:with-param name="all-aliases" select="$all-aliases"/>
              <xsl:with-param name="all-global-aliases" select="$all-global-aliases"/>
              <xsl:with-param name="debug" select="$debug"/>
              <xsl:with-param name="called-from" select="'recurse for param default val'"/>
              <xsl:with-param name="recursion" select="$recursion + 1"/>
              <xsl:with-param name="to-stack" select="$to-stack"/>
              <xsl:with-param name="add-mode" select="$add-mode"/>
              <xsl:with-param name="expect" select="$expect"/>
            </xsl:call-template>
          </xsl:when>
          <!--
              It's an error if there's no @value on either the
              <with-param> or the <param>.
          -->
          <xsl:otherwise>
            <!-- <xsl:message>
              <xsl:value-of select="$all-macro-params"/>
            </xsl:message> -->
            <xsl:call-template name="error-message">
              <xsl:with-param name="msg">
                <xsl:text>Can't find value for param "</xsl:text>
                <xsl:value-of select="$valn"/>
                <xsl:text>" in macro "</xsl:text>
                <xsl:value-of select="ancestor::xgf:macro/@name"/>
                <xsl:text>"</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!--
          The otherwise clause contains the normal cases.

          The first two variables set up testing for numbers with
          suffixes.
      -->
      <xsl:otherwise>
        <xsl:variable name="all-but-last-char">
          <xsl:choose>
            <xsl:when test="string-length($valn) &gt; 1">
              <xsl:value-of select="substring($valn,1,string-length($valn)-1)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$valn"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="last-char">
          <xsl:value-of select="substring($valn,string-length($valn))"/>
        </xsl:variable>
        <!--
            This variable optimizes a bit for programs in which
            constants declared in the glyph element are very common.
        -->
        <xsl:variable name="v-name" select="$all-constants[@name=$valn]/@value"/>

        <xsl:variable name="is-common" select="contains($valn,' + ') or
                                               contains($valn,' - ') or
                                               contains($valn,' = ') or
                                               string-length($v-name) &gt; 0"/>
        <!--
            Do all the work of resolving the val in this variable, and
            then deal with the results afterwards.
        -->
        <xsl:variable name="resolved-val">
          <xsl:choose>
            <!--
                * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                *
                * FIRST TEST FOR NUMBER LITERALS
                *
                * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
            -->
            <!-- It's a number literal with a decimal point, understood to
                 represent a distance on the raster grid (F26dot6). -->
            <xsl:when test="not($is-common) and
                            contains($permitted,'x') and contains($valn,'.') and
                            (number($valn) = 0 or number($valn))">
              <xsl:value-of select="round(number($valn) * 64)"/>
            </xsl:when>
            <!-- It's a number literal, an integer. -->
            <xsl:when test="not($is-common) and
                            contains($permitted,'1') and (number($valn) = 0 or
                            number($valn))">
              <xsl:value-of select="number($valn)"/>
            </xsl:when>
            <!-- It's a number literal with suffix p, a distance on the
                 raster grid (F26dot6). -->
            <xsl:when test="not($is-common) and
                            contains($permitted,'x') and
                            (number($all-but-last-char) or number($all-but-last-char) = 0) and
                            $last-char = 'p'">
              <xsl:value-of select="round(number($all-but-last-char) * 64)"/>
            </xsl:when>
            <!-- It's an F2dot14 number, for setting a vector. -->
            <xsl:when test="not($is-common) and
                            contains($permitted,'2') and $last-char = 'v' and
                            number($all-but-last-char) &gt;= -1 and
                            number($all-but-last-char) &lt;= 1">
              <xsl:value-of select="round(number($all-but-last-char) * 16384)"/>
            </xsl:when>
            <!--
                * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                *
                * NEXT TEST FOR RESERVED WORDS THAT RESOLVE AT COMPILE TIME
                *
                * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
            -->
            <!-- It's a round state, referenced by name. -->
            <xsl:when test="not($is-common) and
                            contains($permitted,'r') and
                            document('xgfdata.xml')/*/xgfd:round-states/xgfd:round[@name = $valn]">
              <xsl:value-of select="document('xgfdata.xml')/*/xgfd:round-states/xgfd:round[@name
                                    = $valn]/@num"/>
            </xsl:when>
            <!-- It's a selector for getinfo. -->
            <xsl:when test="not($is-common) and $getinfo-index and
                            document('xgfdata.xml')/*/xgfd:getinfo/xgfd:entry[@name = $valn]">
              <xsl:value-of select="document('xgfdata.xml')/*/xgfd:getinfo/xgfd:entry[@name =
                                    $valn]/@selector"/>
            </xsl:when>
            <!-- It's an engine version -->
            <xsl:when test="not($is-common) and
                            document('xgfdata.xml')/*/xgfd:engine-versions/xgfd:entry[@name = $valn]">
              <xsl:value-of select="document('xgfdata.xml')/*/xgfd:engine-versions/xgfd:entry[@name =
                                    $valn]/@num"/>
            </xsl:when>
            <!--
            <xsl:when test="not($is-common) and $valn = 'merge-mode'">
              <xsl:value-of select="number($merge-mode)"/>
            </xsl:when>
            -->
            <!--
                * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                *
                * TEST FOR RESERVED WORDS THAT RESOLVE AT RUN TIME
                *
                * Any value that can be resolved only at run-time MUST be left on the
                * stack. So we look for these only when $to-stack is true().
                *
                * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
            -->
            <!-- pixels-per-em -->
            <xsl:when test="not($is-common) and
                            $to-stack and contains($permitted,'m') and $valn='pixels-per-em'">
              <xsl:call-template name="simple-command">
                <xsl:with-param name="cmd" select="'MPPEM'"/>
              </xsl:call-template>
            </xsl:when>
            <!-- point-size -->
            <xsl:when test="not($is-common) and
                            $to-stack and contains($permitted,'p') and $valn='point-size'">
              <xsl:call-template name="simple-command">
                <xsl:with-param name="cmd" select="'MPS'"/>
              </xsl:call-template>
            </xsl:when>
            <!-- A request for info via GETINFO -->
            <xsl:when test="not($is-common) and
                            $to-stack and not($getinfo-index) and contains($permitted,'p') and
                            document('xgfdata.xml')/*/xgfd:getinfo/xgfd:entry[@name = $valn]">
              <xsl:call-template name="number-command">
                <xsl:with-param name="cmd" select="'GETINFO'"/>
                <xsl:with-param name="num"
                                select="document('xgfdata.xml')/*/xgfd:getinfo/xgfd:entry[@name =
                                        $valn]/@selector"/>
              </xsl:call-template>
            </xsl:when>
            <!-- It's a reserved word that references one of our reserved storage locs. -->
            <xsl:when test="not($is-common) and
                            $to-stack and contains($permitted,'l') and
                            document('xgfdata.xml')/*/xgfd:var-locations/xgfd:loc[@name =
                            $valn]">
              <xsl:call-template name="push-num">
                <xsl:with-param name="num">
                  <xsl:call-template name="resolve-std-variable-loc">
                    <xsl:with-param name="n" select="$valn"/>
                  </xsl:call-template>
                </xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="simple-command">
                <xsl:with-param name="cmd" select="'RS'"/>
              </xsl:call-template>
            </xsl:when>
            <!--
                * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                *
                * TEST FOR LOCAL CONSTANT
                *
                * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
            -->
            <!-- It's a locally declared constant. If it's an integer, just return it.
                 Otherwise, call this recursively to find out what it is. -->
            <xsl:when test="string-length($v-name) &gt; 0 and
                            contains($permitted,'n')">
              <xsl:choose>
                <xsl:when test="(number($v-name) or number($v-name) = 0) and
                                not(contains($v-name,'.'))">
                  <xsl:value-of select="number($v-name)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="expression">
                    <xsl:with-param name="val" select="$v-name"/>
                    <xsl:with-param name="cvt-mode" select="$cvt-mode"/>
                    <xsl:with-param name="this-glyph" select="$this-glyph"/>
                    <xsl:with-param name="getinfo-index" select="$getinfo-index"/>
                    <xsl:with-param name="permitted" select="$permitted"/>
                    <xsl:with-param name="need-number-now" select="$need-number-now"/>
                    <xsl:with-param name="mp-container" select="$mp-container"/>
                    <xsl:with-param name="debug" select="$debug"/>
                    <xsl:with-param name="called-from" select="'exp: recursing to resolve constant'"/>
                    <xsl:with-param name="recursion" select="$recursion + 1"/>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <!--
                * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                *
                * TEST FOR LOCAL VARIABLES AND FUNCTION PARAMS
                *
                * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
            -->
            <!-- It's a local variable. -->
            <xsl:when test="not($is-common) and
                            $to-stack and contains($permitted,'v') and $all-variables[@name=$valn]">
              <xsl:call-template name="push-variable">
                <xsl:with-param name="val" select="$all-variables[@name=$valn]"/>
                <xsl:with-param name="add-mode" select="$add-mode"/>
                <xsl:with-param name="index-only" select="$force-to-index"/>
              </xsl:call-template>
            </xsl:when>
            <!-- It's a function parameter. -->
            <xsl:when test="not($is-common) and
                            $to-stack and contains($permitted,'f') and
                            $all-function-params[@name=$valn]">
              <xsl:call-template name="push-function-parameter">
                <xsl:with-param name="val" select="$valn"/>
                <xsl:with-param name="this-function" select="$this-function"/>
              </xsl:call-template>
            </xsl:when>
            <!--
                * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                *
                * TEST FOR GLOBAL VALUES
                *
                * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
            -->
            <!-- It's the index of a control-value -->
            <xsl:when test="not($is-common) and
                            contains($permitted,'c') and
                            ($cvt-mode = 'index' or $force-to-index) and
                            key('cvt',$valn)">
              <xsl:call-template name="get-cvt-index">
                <xsl:with-param name="need-number-now" select="$need-number-now"/>
                <xsl:with-param name="name" select="$valn"/>
              </xsl:call-template>
            </xsl:when>
            <!-- It's a control-value index, and we want the value itself. -->
            <xsl:when test="not($is-common) and
                            $to-stack and contains($permitted,'c') and
                            $cvt-mode = 'value' and key('cvt',$valn)">
              <xsl:call-template name="push-num">
                <xsl:with-param name="num">
                  <xsl:call-template name="get-cvt-index">
                    <xsl:with-param name="name" select="$valn"/>
                  </xsl:call-template>
                </xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="simple-command">
                <xsl:with-param name="cmd" select="'RCVT'"/>
              </xsl:call-template>
            </xsl:when>
            <!-- It's a global constant. -->
            <xsl:when test="not($is-common) and
                            contains($permitted,'n') and
                            $all-global-constants[@name=$valn]">
              <xsl:variable name="nn" select="$all-global-constants[@name = $valn]/@value"/>
              <xsl:choose>
                <xsl:when test="(number($nn) or number($nn) = 0) and
                                not(contains($nn,'.'))">
                  <xsl:value-of select="number($nn)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="expression">
                    <xsl:with-param name="val" select="$nn"/>
                    <xsl:with-param name="cvt-mode" select="$cvt-mode"/>
                    <xsl:with-param name="this-glyph" select="$this-glyph"/>
                    <xsl:with-param name="permitted" select="$permitted"/>
                    <xsl:with-param name="getinfo-index" select="$getinfo-index"/>
                    <xsl:with-param name="mp-container" select="$mp-container"/>
                    <xsl:with-param name="debug" select="$debug"/>
                    <xsl:with-param name="need-number-now" select="$need-number-now"/>
                    <xsl:with-param name="called-from"
                                    select="'exp: recursing to resolve global constant'"/>
                    <xsl:with-param name="recursion" select="$recursion + 1"/>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <!-- It's the name of a function, and we want the index -->
            <xsl:when test="not($is-common) and
                            $to-stack and key('function-index',$valn)">
              <xsl:call-template name="get-function-number">
                <xsl:with-param name="function-name" select="$valn"/>
              </xsl:call-template>
            </xsl:when>
            <!--
                * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                *
                * TEST FOR GLOBAL VARIABLES
                *
                * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
            -->
            <!-- It's a global variable. -->
            <xsl:when test="not($is-common) and
                            $to-stack and
                            contains($permitted,'v') and
                            $all-global-variables[@name=$valn]">
              <xsl:call-template name="push-global-variable">
                <xsl:with-param name="val" select="$all-global-variables[@name=$valn]"/>
                <xsl:with-param name="index-only" select="$force-to-index"/>
              </xsl:call-template>
            </xsl:when>
            <!--
                * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                *
                * THE SPECIAL CASE OF THE GLYPH/CONSTANT CONSTRUCTION
                *
                * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
            -->
            <xsl:when test="not($is-common) and
                            contains($permitted,'n') and contains($valn,'/') and
                            not(contains($valn,' ')) and not(contains($valn,'('))">
              <xsl:variable name="gname" select="normalize-space(substring-before($valn,'/'))"/>
              <xsl:if test="not(key('glyph-index', $gname))">
                <xsl:call-template name="error-message">
                  <xsl:with-param name="msg">
                    <xsl:text>There is no glyph to match "</xsl:text>
                    <xsl:value-of select="$valn"/>
                    <xsl:text>"</xsl:text>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:if>
              <!-- It's a number in glyph/constant format, i.e. most likely a reference
                   to a point in another glyph. Recurse to resolve the reference. -->
              <xsl:apply-templates select="key('glyph-index',$gname)[1]"
                                   mode="resolve-local-value">
                <xsl:with-param name="val"
                                select="normalize-space(substring-after($valn,'/'))"/>
                <xsl:with-param name="permitted" select="$permitted"/>
                <xsl:with-param name="debug" select="$debug"/>
              </xsl:apply-templates>
            </xsl:when>
            <!--
                * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                *
                * IF NONE OF THOSE HAVE WORKED, MAYBE IT'S AN EXPRESSION
                *
                * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
            -->
            <xsl:otherwise>
              <xsl:variable name="op">
                <xsl:call-template name="find-operator">
                  <xsl:with-param name="s" select="$valn"/>
                </xsl:call-template>
              </xsl:variable>
              <xsl:choose>
                <xsl:when test="$op != 'NaN'">
                  <!--
                      * * * * * * * * * * * * * * * * * * *
                      *
                      * First initialize some variables.
                      *
                      * * * * * * * * * * * * * * * * * * *
                  -->
                  <!-- Length of the first token (from beginning of string to operator) -->
                  <xsl:variable name="tok-one-len"
                                select="string-length($valn) - number($op)"/>
                  <!-- The first token (everything before the operator) -->
                  <xsl:variable name="first-tok">
                    <xsl:choose>
                      <xsl:when test="$tok-one-len &gt; 0">
                        <xsl:value-of
                            select="normalize-space(substring($valn,1,$tok-one-len))"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="''"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <!-- An intermediate string containing the operator and the rest
                       of the expression (if any). -->
                  <xsl:variable name="ts">
                    <xsl:choose>
                      <xsl:when test="$tok-one-len &gt; 0">
                        <xsl:value-of select="substring($valn,$tok-one-len + 1)"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="$valn"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <!-- The operator itself -->
                  <xsl:variable name="operator">
                    <xsl:call-template name="get-first-token">
                      <xsl:with-param name="s" select="$ts"/>
                    </xsl:call-template>
                  </xsl:variable>
                  <!-- A convenience variable, true if the operator is 'index' -->
                  <xsl:variable name="index-only"
                                select="boolean($operator = 'index')"/>
                  <!-- Operator direction indicator (left, right, both) -->
                  <xsl:variable
                      name="op-dir"
                      select="document('xgfdata.xml')/*/xgfd:operators/xgfd:operator[@symbol =
                              $operator]/@dir"/>
                  <!-- Last token (everything after the operator) -->
                  <xsl:variable name="last-tok">
                    <xsl:call-template name="get-remaining-tokens">
                      <xsl:with-param name="s" select="$ts"/>
                    </xsl:call-template>
                  </xsl:variable>
                  <!--
                      * * * * * * * * * * * * * * * * * * * * * * * * * * *
                      *
                      * Evaluate the expression
                      *
                      * * * * * * * * * * * * * * * * * * * * * * * * * * *
                  -->
                  <!--
                      Here we evaluate the arguments on the right and
                      left of the operator. We should end up with one
                      of three things: 1.) a number literal, in which
                      case we can sometimes optimize compilation of
                      the expression; 2.) a stretch of code, which we
                      can just plug in; 3.) NaN, in which case we'll
                      end up crashing if we really needed a number.
                  -->
                  <xsl:variable name="first-num">
                    <xsl:choose>
                      <xsl:when test="$op-dir = 'b'">
                        <xsl:call-template name="expression">
                          <xsl:with-param name="this-glyph"
                                          select="$this-glyph"/>
                          <xsl:with-param name="val"
                                          select="normalize-space($first-tok)"/>
                          <xsl:with-param name="getinfo-index" select="$getinfo-index"/>
                          <xsl:with-param name="mp-container" select="$mp-container"/>
                          <xsl:with-param name="debug" select="$debug"/>
                          <xsl:with-param name="called-from"
                                          select="'exp: pre-scan left'"/>
                          <xsl:with-param name="recursion" select="$recursion + 1"/>
                          <xsl:with-param name="need-number-now" select="$need-number-now"/>
                        </xsl:call-template>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:text>NaN</xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <xsl:variable name="last-num">
                    <xsl:choose>
                      <xsl:when test="$operator='and' and number($first-num)=0">
                        <!--
                            If the operator is 'and' and first-num was
                            false, we skip evaluation of the
                            expression on the other side of the
                            'and'. This is a kludge, but it works.
                        -->
                        <xsl:text>0</xsl:text>
                      </xsl:when>
                      <xsl:when test="$operator='point'">
                        <xsl:call-template name="expression-with-offset">
                          <xsl:with-param name="val" select="normalize-space($last-tok)"/>
                          <xsl:with-param name="this-glyph" select="$this-glyph"/>
                          <xsl:with-param name="permitted">
                            <xsl:choose>
                              <xsl:when test="$index-only">
                                <xsl:value-of select="'c'"/>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:value-of select="'12xrnc'"/>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:with-param>
                          <xsl:with-param name="called-from"
                                          select="'exp: pre-scan right with offset'"/>
                          <xsl:with-param name="mp-container" select="$mp-container"/>
                        </xsl:call-template>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:call-template name="expression">
                          <xsl:with-param name="this-glyph" select="$this-glyph"/>
                          <xsl:with-param name="val" select="normalize-space($last-tok)"/>
                          <xsl:with-param name="force-to-index" select="$index-only"/>
                          <xsl:with-param name="need-number-now" select="$need-number-now"/>
                          <xsl:with-param name="getinfo-index" select="$getinfo-index"/>
                          <xsl:with-param name="permitted">
                            <xsl:choose>
                              <xsl:when test="$index-only">
                                <xsl:value-of select="'c'"/>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:value-of select="'12xrnc'"/>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:with-param>
                          <xsl:with-param name="mp-container" select="$mp-container"/>
                          <xsl:with-param name="debug" select="$debug"/>
                          <xsl:with-param name="called-from"
                                          select="'exp: pre-scan right without offset'"/>
                          <xsl:with-param name="recursion" select="$recursion + 1"/>
                        </xsl:call-template>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <!--
                      $compile-time-numbers is true if everything we
                      need has now been resolved to a number
                      literal. In that case the compiler can perform
                      certain calculations rather than generating
                      TrueType code to do them.
                  -->
                  <xsl:variable name="compile-time-numbers"
                                select="boolean((number($last-num) or (number($last-num) = 0)) and
                                        ($op-dir = 'r' or
                                        (number($first-num) or (number($first-num) = 0))))"/>
                  <xsl:variable name="compilable-op"
                                select="boolean(document('xgfdata.xml')/*/xgfd:operators/xgfd:operator[@symbol =
                                        $operator]/@at-compile = 'y')"/>
                  <xsl:variable name="compile-now"
                                select="$compile-time-numbers and $compilable-op or $operator = 'nan'"/>
                  <!--
                      If we can't compile now, we move the numbers we
                      need onto the stack.
                  -->
                  <xsl:if test="not($compile-now)">
                    <xsl:if test="$op-dir = 'b'">
                      <xsl:call-template name="expression">
                        <xsl:with-param name="val" select="$first-tok"/>
                        <xsl:with-param name="this-glyph" select="$this-glyph"/>
                        <xsl:with-param name="this-function" select="$this-function"/>
                        <xsl:with-param name="this-prep" select="$this-prep"/>
                        <xsl:with-param name="getinfo-index" select="$getinfo-index"/>
                        <xsl:with-param name="debug" select="$debug"/>
                        <xsl:with-param name="called-from"
                                        select="'exp: put left on stack'"/>
                        <xsl:with-param name="recursion" select="$recursion + 1"/>
                        <xsl:with-param name="mp-container" select="$mp-container"/>
                        <xsl:with-param name="to-stack" select="true()"/>
                        <xsl:with-param name="need-number-now" select="$need-number-now"/>
                      </xsl:call-template>
                    </xsl:if>
                    <xsl:choose>
                      <xsl:when test="$operator='point'">
                        <xsl:call-template name="expression-with-offset">
                          <xsl:with-param name="val" select="$last-tok"/>
                          <xsl:with-param name="this-glyph" select="$this-glyph"/>
                          <xsl:with-param name="permitted">
                            <xsl:choose>
                              <xsl:when test="$index-only">
                                <xsl:value-of select="'vc'"/>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:value-of select="'12xmplrfvncg'"/>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:with-param>
                          <xsl:with-param name="mp-container" select="$mp-container"/>
                          <xsl:with-param name="to-stack" select="true()"/>
                          <xsl:with-param name="called-from"
                                          select="'exp: put right on stack with offset'"/>
                        </xsl:call-template>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:call-template name="expression">
                          <xsl:with-param name="val" select="$last-tok"/>
                          <xsl:with-param name="this-glyph" select="$this-glyph"/>
                          <xsl:with-param name="this-function" select="$this-function"/>
                          <xsl:with-param name="this-prep" select="$this-prep"/>
                          <xsl:with-param name="force-to-index" select="$index-only"/>
                          <xsl:with-param name="getinfo-index" select="$getinfo-index"/>
                          <xsl:with-param name="permitted">
                            <xsl:choose>
                              <xsl:when test="$index-only">
                                <xsl:value-of select="'vc'"/>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:value-of select="'12xmplrfvncg'"/>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:with-param>
                          <xsl:with-param name="debug" select="$debug"/>
                          <xsl:with-param name="recursion" select="$recursion + 1"/>
                          <xsl:with-param name="mp-container" select="$mp-container"/>
                          <xsl:with-param name="to-stack" select="true()"/>
                          <xsl:with-param name="need-number-now" select="$need-number-now"/>
                          <xsl:with-param name="called-from"
                                          select="'exp: put right on stack without offset'"/>
                        </xsl:call-template>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:if>
                  <!--
                      Now start the evaluation itself.
                  -->
                  <xsl:choose>
                    <!--
                        The nan operator is a special case, since it
                        must always be evaluated at compile time.
                    -->
                    <xsl:when test="$operator = 'nan'">
                      <xsl:value-of select="number(not($compile-time-numbers))"/>
                    </xsl:when>
                    <!--
                        $compile-now is true if the compiler can
                        evaluate this expression and reliably come up
                        with the same result as the TrueType
                        engine. We do the arithmetic now rather than
                        defer it till run time.
                    -->
                    <xsl:when test="$compile-now">
                      <xsl:choose>
                        <xsl:when test="$operator = 'index' or $operator = 'point'">
                          <xsl:value-of select="number($last-num)"/>
                        </xsl:when>
                        <xsl:when test="$operator = 'not'">
                          <xsl:value-of select="number(not(number($last-num)))"/>
                        </xsl:when>
                        <xsl:when test="$operator = '+'">
                          <xsl:value-of select="number($first-num) + number($last-num)"/>
                        </xsl:when>
                        <xsl:when test="$operator = '-'">
                          <xsl:value-of select="number($first-num) - number($last-num)"/>
                        </xsl:when>
                        <xsl:when test="$operator = '='">
                          <xsl:value-of select="number(number($first-num) = number($last-num))"/>
                        </xsl:when>
                        <xsl:when test="$operator = '!='">
                          <xsl:value-of select="number(number($first-num) != number($last-num))"/>
                        </xsl:when>
                        <xsl:when test="$operator = '&lt;'">
                          <xsl:value-of select="number(number($first-num) &lt; number($last-num))"/>
                        </xsl:when>
                        <xsl:when test="$operator = '&gt;'">
                          <xsl:value-of select="number(number($first-num) &gt; number($last-num))"/>
                        </xsl:when>
                        <xsl:when test="$operator = '&lt;='">
                          <xsl:value-of select="number(number($first-num) &lt;= number($last-num))"/>
                        </xsl:when>
                        <xsl:when test="$operator = '&gt;='">
                          <xsl:value-of select="number(number($first-num) &gt;= number($last-num))"/>
                        </xsl:when>
                        <xsl:when test="$operator = 'and'">
                          <xsl:value-of select="number(number($first-num) and number($last-num))"/>
                        </xsl:when>
                        <xsl:when test="$operator = 'or'">
                          <xsl:value-of select="number(number($first-num) or number($last-num))"/>
                        </xsl:when>
                      </xsl:choose>
                    </xsl:when> <!-- end of $compile-now option -->
                    <!--
                        The following sections assume that arguments
                        have been placed on the stack. First special
                        cases whose handling has got to be hard-wired.
                    -->
                    <!-- special handling for point and index operators? -->
                    <xsl:when test="$operator = 'point'"></xsl:when>
                    <xsl:when test="$operator = 'round'">
                      <xsl:call-template name="simple-command">
                        <xsl:with-param name="cmd" select="'ROUND'"/>
                        <xsl:with-param name="modifier">
                          <xsl:call-template name="color-bits">
                            <xsl:with-param name="l-color" select="$color"/>
                          </xsl:call-template>
                        </xsl:with-param>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$operator = 'round-gray'">
                      <xsl:call-template name="simple-command">
                        <xsl:with-param name="cmd" select="'ROUND'"/>
                        <xsl:with-param name="modifier">
                          <xsl:call-template name="color-bits">
                            <xsl:with-param name="l-color" select="'gray'"/>
                          </xsl:call-template>
                        </xsl:with-param>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$operator = 'round-black'">
                      <xsl:call-template name="simple-command">
                        <xsl:with-param name="cmd" select="'ROUND'"/>
                        <xsl:with-param name="modifier">
                          <xsl:call-template name="color-bits">
                            <xsl:with-param name="l-color" select="'black'"/>
                          </xsl:call-template>
                        </xsl:with-param>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$operator = 'round-white'">
                      <xsl:call-template name="simple-command">
                        <xsl:with-param name="cmd" select="'ROUND'"/>
                        <xsl:with-param name="modifier">
                          <xsl:call-template name="color-bits">
                            <xsl:with-param name="l-color" select="'white'"/>
                          </xsl:call-template>
                        </xsl:with-param>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$operator = 'coord'">
                      <xsl:call-template name="simple-command">
                        <xsl:with-param name="cmd" select="'GC'"/>
                        <xsl:with-param name="modifier">
                          <xsl:call-template name="grid-fitted-bit">
                            <xsl:with-param name="grid-fitted" select="true()"/>
                          </xsl:call-template>
                        </xsl:with-param>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$operator = 'initial-coord'">
                      <xsl:call-template name="simple-command">
                        <xsl:with-param name="cmd" select="'GC'"/>
                        <xsl:with-param name="modifier">
                          <xsl:call-template name="grid-fitted-bit">
                            <xsl:with-param name="grid-fitted" select="false()"/>
                          </xsl:call-template>
                        </xsl:with-param>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$operator = 'x-coord'">
                      <xsl:call-template name="get-coord-with-save">
                        <xsl:with-param name="c" select="'x'"/>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$operator = 'y-coord'">
                      <xsl:call-template name="get-coord-with-save">
                        <xsl:with-param name="c" select="'y'"/>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$operator = 'initial-x-coord'">
                      <xsl:call-template name="get-coord-with-save">
                        <xsl:with-param name="c" select="'x'"/>
                        <xsl:with-param name="gf" select="false()"/>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$operator = 'initial-y-coord'">
                      <xsl:call-template name="get-coord-with-save">
                        <xsl:with-param name="c" select="'y'"/>
                        <xsl:with-param name="gf" select="false()"/>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$operator = '--'">
                      <xsl:call-template name="simple-command">
                        <xsl:with-param name="cmd" select="'SWAP'"/>
                      </xsl:call-template>
                      <xsl:call-template name="simple-command">
                        <xsl:with-param name="cmd" select="'MD'"/>
                        <xsl:with-param name="modifier">
                          <xsl:call-template name="grid-fitted-bit">
                            <xsl:with-param name="grid-fitted" select="true()"/>
                          </xsl:call-template>
                        </xsl:with-param>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$operator = '---'">
                      <xsl:call-template name="simple-command">
                        <xsl:with-param name="cmd" select="'SWAP'"/>
                      </xsl:call-template>
                      <xsl:call-template name="simple-command">
                        <xsl:with-param name="cmd" select="'MD'"/>
                        <xsl:with-param name="modifier">
                          <xsl:call-template name="grid-fitted-bit">
                            <xsl:with-param name="grid-fitted" select="false()"/>
                          </xsl:call-template>
                        </xsl:with-param>
                      </xsl:call-template>
                    </xsl:when>
                    <!--
                        And a number of operations can be done by
                        getting the data from xgfdata.xml.
                    -->
                    <xsl:when test="$operator != 'index'">
                      <xsl:call-template name="simple-command">
                        <xsl:with-param
                            name="cmd"
                            select="document('xgfdata.xml')/*/xgfd:operators/xgfd:operator[@symbol =
                                    $operator]"/>
                      </xsl:call-template>
                    </xsl:when>
                  </xsl:choose>
                </xsl:when>
                <!--
                    The expression contained no operator. We're out of
                    ideas for evaluating it.
                -->
                <xsl:otherwise>
                  <xsl:text>NaN</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise> <!-- end looking for expression -->
          </xsl:choose>
        </xsl:variable> <!-- end of resolved-val -->
        <xsl:choose>
          <xsl:when test="$resolved-val = 'NaN' and ($crash-on-fail or $to-stack)">
            <xsl:call-template name="error-message">
              <xsl:with-param name="msg">
                <xsl:text>Cannot resolve value </xsl:text>
                <xsl:value-of select="$valn"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="$resolved-val = 'NaN'">
            <xsl:value-of select="$resolved-val"/>
          </xsl:when>
          <xsl:when test="number($resolved-val) or number($resolved-val) = 0">
            <xsl:choose>
              <xsl:when test="$to-stack">
                <xsl:call-template name="push-num">
                  <xsl:with-param name="num" select="$resolved-val"/>
                  <xsl:with-param name="expect" select="$expect"/>
                  <xsl:with-param name="add-mode" select="$add-mode"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$resolved-val"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$to-stack">
            <!--
                This is for generated code, not for plain numbers, yet
                merge-mode numbers get caught here. We can't make the
                decision here whether to push a number, so code will
                have to be generated above, e.g. for
                control-values. Do this by writing a template that
                decides (on the basis of $to-stack) whether a number
                needs to be pushed and either emits the number of
                emits code for pushing it.
            -->
            <xsl:choose>
              <xsl:when test="starts-with($resolved-val,$inst-newline)">
                <xsl:value-of select="$resolved-val"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="push-num">
                  <xsl:with-param name="num" select="$resolved-val"/>
                  <xsl:with-param name="expect" select="$expect"/>
                  <xsl:with-param name="add-mode" select="$add-mode"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="starts-with($resolved-val,$inst-newline)">
                <xsl:text>NaN</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$resolved-val"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xgf:with-param" mode="push-me">
    <xsl:param name="force-to-index"/>
    <xsl:param name="add-mode"/>
    <xsl:param name="permitted"/>
    <xsl:param name="expect"/>
    <xsl:param name="mp-container"/>
    <xsl:call-template name="expression">
      <xsl:with-param name="val" select="@value"/>
      <xsl:with-param name="force-to-index" select="$force-to-index"/>
      <xsl:with-param name="add-mode" select="$add-mode"/>
      <xsl:with-param name="permitted" select="$permitted"/>
      <xsl:with-param name="expect" select="$expect"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
      <xsl:with-param name="to-stack" select="true()"/>
      <xsl:with-param name="called-from" select="'with-param push-me'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="xgf:with-param" mode="get-my-val">
    <xsl:param name="cvt-mode"/>
    <xsl:param name="force-to-index"/>
    <xsl:param name="permitted"/>
    <xsl:param name="to-stack"/>
    <xsl:param name="mp-container"/>
    <xsl:param name="debug" select="false()"/>
    <xsl:param name="add-mode"/>
    <xsl:param name="expect"/>
    <xsl:param name="need-number-now" select="false()"/>
    <xsl:call-template name="expression">
      <xsl:with-param name="val" select="@value"/>
      <xsl:with-param name="cvt-mode" select="$cvt-mode"/>
      <xsl:with-param name="force-to-index" select="$force-to-index"/>
      <xsl:with-param name="permitted" select="$permitted"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
      <xsl:with-param name="to-stack" select="$to-stack"/>
      <xsl:with-param name="add-mode" select="$add-mode"/>
      <xsl:with-param name="expect" select="$expect"/>
      <xsl:with-param name="called-from" select="'with-param get-my-val'"/>
      <xsl:with-param name="need-number-now"
                      select="$need-number-now"/>

      <xsl:with-param name="debug" select="$debug"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="xgf:with-param" mode="store-me">
    <xsl:call-template name="store-value">
      <xsl:with-param name="vname" select="@value"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="get-coord-with-save">
    <xsl:param name="c"/>
    <xsl:param name="gf" select="true()"/>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'GPV'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'ROLL'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SPVTCA'"/>
      <xsl:with-param name="modifier">
        <xsl:call-template name="axis-bit">
          <xsl:with-param name="axis" select="$c"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'GC'"/>
      <xsl:with-param name="modifier">
        <xsl:call-template name="grid-fitted-bit">
          <xsl:with-param name="grid-fitted" select="$gf"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'ROLL'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'ROLL'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SPVFS'"/>
    </xsl:call-template>
  </xsl:template>


  <!--

      store-value

      Values can be stored either in variables (= the Storage Area) or
      in the CVT table. Variables include not only those that the
      program declares, but also those that store that graphics state,
      of which several can be written to: minimum-distance,
      control-value-cut-in, single-width, single-width-cut-in,
      delta-base, delta-shift. Two others, round-state and
      custom-round-state, can be read, but can be written to only via
      <set-round-state> and <with-round-state>.

      This template finds a value on top of the stack and stores it in
      the specified location. If it fails, it issues a warning and
      leaves the value on the stack.
  -->
  <xsl:template name="store-value">
    <xsl:param name="vname"/>
    <xsl:param name="this-glyph" select="ancestor::xgf:glyph"/>
    <xsl:param name="mp-container"/>
    <xsl:param name="all-macro-params"
               select="ancestor::xgf:macro/xgf:param|
                       ancestor::xgf:glyph/xgf:param"/>
    <xsl:param name="all-variables"
               select="ancestor::xgf:glyph/xgf:variable|
                       ancestor::xgf:function/xgf:variable|
                       ancestor::xgf:pre-program/xgf:variable"/>
    <xsl:param name="all-global-variables" select="/xgf:xgridfit/xgf:variable"/>
    <xsl:param name="all-aliases"
               select="$this-glyph/xgf:alias|ancestor::xgf:function/xgf:alias|
                       ancestor::xgf:macro/xgf:alias|
                       ancestor::xgf:pre-program/xgf:alias"/>
    <xsl:param name="all-global-aliases"
               select="/xgf:xgridfit/xgf:alias"/>
    <xsl:choose>
      <xsl:when test="$all-aliases[@name=$vname]">
        <xsl:call-template name="store-value">
          <xsl:with-param name="vname" select="$all-aliases[@name=$vname]/@target"/>
          <xsl:with-param name="this-glyph" select="$this-glyph"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
          <xsl:with-param name="all-variables" select="$all-variables"/>
          <xsl:with-param name="all-global-variables" select="$all-global-variables"/>
          <xsl:with-param name="all-aliases" select="$all-aliases"/>
          <xsl:with-param name="all-global-aliases" select="$all-global-aliases"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$all-global-aliases[@name=$vname]">
        <xsl:call-template name="store-value">
          <xsl:with-param name="vname" select="$all-global-aliases[@name=$vname]/@target"/>
          <xsl:with-param name="this-glyph" select="$this-glyph"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
          <xsl:with-param name="all-variables" select="$all-variables"/>
          <xsl:with-param name="all-global-variables" select="$all-global-variables"/>
          <xsl:with-param name="all-aliases" select="$all-aliases"/>
          <xsl:with-param name="all-global-aliases" select="$all-global-aliases"/>
        </xsl:call-template>
      </xsl:when>
<!-- *** params here *** -->
      <xsl:when test="$all-macro-params[@name=$vname]">
        <xsl:variable name="this-id">
          <xsl:call-template name="get-first-mp-id">
            <xsl:with-param name="mp-container" select="$mp-container"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="string-length($this-id) and
                          $mp-containers and
                          $mp-containers[generate-id() = $this-id]/xgf:with-param[@name=$vname]/@value">
            <xsl:apply-templates
                select="$mp-containers[generate-id() = $this-id]/xgf:with-param[@name=$vname]"
                mode="store-me"/>
          </xsl:when>
          <xsl:when test="$all-macro-params[@name=$vname]/@value">
            <xsl:call-template name="store-value">
              <xsl:with-param name="vname" select="$all-macro-params[@name=$vname]/@value"/>
              <xsl:with-param name="this-glyph" select="$this-glyph"/>
              <xsl:with-param name="mp-container" select="$mp-container"/>
              <xsl:with-param name="all-macro-params" select="$all-macro-params"/>
              <xsl:with-param name="all-variables" select="$all-variables"/>
              <xsl:with-param name="all-global-variables" select="$all-global-variables"/>
              <xsl:with-param name="all-aliases" select="$all-aliases"/>
              <xsl:with-param name="all-global-aliases" select="$all-global-aliases"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="error-message">
              <xsl:with-param name="msg">
                <xsl:text>Can't find value for param "</xsl:text>
                <xsl:value-of select="$vname"/>
                <xsl:text>" in macro "</xsl:text>
                <xsl:value-of select="ancestor::xgf:macro/@name"/>
                <xsl:text>"</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
<!-- End of params -->
      <xsl:when test="$vname = 'return' and ancestor::xgf:function[@return = 'yes']">
        <xsl:call-template name="stack-top-to-storage">
          <xsl:with-param name="loc">
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$var-return-value"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$all-variables[@name=$vname]">
        <xsl:call-template name="store-variable">
          <xsl:with-param name="val"
            select="$all-variables[@name=$vname]"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="key('cvt',$vname)">
        <xsl:call-template name="store-control-value">
          <xsl:with-param name="cvtname" select="$vname"/>
          <xsl:with-param name="mp-container" select="$mp-container"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$vname = 'custom-round-state'">
        <xsl:call-template name="warning">
          <xsl:with-param name="msg">
            <xsl:text>custom-round-state can be written to only via </xsl:text>
            <xsl:text>&lt;set-round-state&gt;</xsl:text>
            <xsl:value-of select="$newline"/>
            <xsl:text>and &lt;with-round-state&gt;. </xsl:text>
            <xsl:text>The value this program has attempted</xsl:text>
            <xsl:value-of select="$newline"/>
            <xsl:text>to write to it is being discarded.</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="with-pop" select="true()"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$vname = 'round-state'">
        <xsl:call-template name="warning">
          <xsl:with-param name="msg">
            <xsl:text>round-state can be written to only via </xsl:text>
            <xsl:text>&lt;set-round-state&gt;</xsl:text>
            <xsl:value-of select="$newline"/>
            <xsl:text>and &lt;with-round-state&gt;. </xsl:text>
            <xsl:text>The value this program has attempted</xsl:text>
            <xsl:value-of select="$newline"/>
            <xsl:text>to write to it is being discarded.</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="with-pop" select="true()"/>
        </xsl:call-template>
      </xsl:when>
      <!-- Any graphics variable except for round-state and custom-round-state can be
           written to, and the graphics state is automatically changed. -->
      <xsl:when test="document('xgfdata.xml')/*/xgfd:var-locations/xgfd:loc[@name = $vname]">
        <xsl:choose>
          <xsl:when test="contains($vname,'default')">
            <xsl:choose>
              <xsl:when test="ancestor::xgf:pre-program">
                <xsl:call-template name="set-simple-graphics-var">
                  <xsl:with-param name="loc">
                    <xsl:call-template name="resolve-std-variable-loc">
                      <xsl:with-param name="n"
                                      select="document('xgfdata.xml')/*/xgfd:var-locations/xgfd:loc[@name =
                                              $vname]/@vice"/>
                    </xsl:call-template>
                  </xsl:with-param>
                  <xsl:with-param name="default-loc">
                    <xsl:call-template name="resolve-std-variable-loc">
                      <xsl:with-param name="n"
                                      select="document('xgfdata.xml')/*/xgfd:var-locations/xgfd:loc[@name =
                                              $vname]/@val"/>
                    </xsl:call-template>
                  </xsl:with-param>
                  <xsl:with-param name="cmd"
                    select="document('xgfdata.xml')/*/xgfd:var-locations/xgfd:loc[@name =
                    $vname]"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="warning">
                  <xsl:with-param name="msg">
                    <xsl:text>It is not permitted to write to the </xsl:text>
                    <xsl:text>default graphics variable </xsl:text>
                    <xsl:value-of select="$vname"/>
                    <xsl:value-of select="$newline"/>
                    <xsl:text>except in the &lt;pre-program&gt;. </xsl:text>
                    <xsl:text>The value this program has attempted</xsl:text>
                    <xsl:value-of select="$newline"/>
                    <xsl:text>to write to it is being discarded.</xsl:text>
                  </xsl:with-param>
                  <xsl:with-param name="with-pop" select="true()"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="set-simple-graphics-var">
              <xsl:with-param name="loc">
                <xsl:call-template name="resolve-std-variable-loc">
                  <xsl:with-param name="n"
                                  select="document('xgfdata.xml')/*/xgfd:var-locations/xgfd:loc[@name =
                                          $vname]/@val"/>
                </xsl:call-template>
              </xsl:with-param>
              <xsl:with-param name="default-loc">
                <xsl:call-template name="resolve-std-variable-loc">
                  <xsl:with-param name="n"
                                  select="document('xgfdata.xml')/*/xgfd:var-locations/xgfd:loc[@name =
                                          $vname]/@vice"/>
                </xsl:call-template>
              </xsl:with-param>
              <xsl:with-param name="cmd"
                select="document('xgfdata.xml')/*/xgfd:var-locations/xgfd:loc[@name =
                $vname]"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$all-global-variables[@name=$vname]">
        <xsl:call-template name="store-global-variable">
          <xsl:with-param name="val"
            select="$all-global-variables[@name=$vname]"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="warning">
          <xsl:with-param name="msg">
            <xsl:text>Could not store value </xsl:text>
            <xsl:value-of select="$vname"/>
            <xsl:text>. It will be left on the stack.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- 2. Handling function parameters -->

  <!--

      push-function-parameter

      This is always called from inside a function; it is the way
      functions read the parameters that have been passed to them.

      Start with a name; look up corresponding index; use that index
      to copy the proper value from wherever it is in the stack to the
      top of the stack.

      The complication is that something may have been put on top of
      the stack since parameters were pushed on.  To take care of
      that, we started the function by recording the stack depth, and
      now a little arithmetic will get us to where the parameters are
      stored.
  -->
  <xsl:template name="push-function-parameter">
    <xsl:param name="val"/>
    <xsl:param name="this-function" select="ancestor::xgf:function"/>
    <xsl:param name="all-params" select="$this-function/xgf:param"/>
    <!-- We recorded the depth of the stack after we pushed parameters on.
         Now get the present depth for comparison. -->
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'DEPTH'"/>
    </xsl:call-template>
    <!-- The depth of the stack when the function started is stored in
         var-function-stack-count. -->
    <xsl:call-template name="number-command">
      <xsl:with-param name="num">
        <xsl:call-template name="resolve-std-variable-loc">
          <xsl:with-param name="n" select="$var-function-stack-count"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <!-- Subtract that from the current stack depth. -->
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SUB'"/>
    </xsl:call-template>
    <!-- Get the position of the relevant param element and add it to the
         number we just calculated. -->
    <xsl:call-template name="push-num">
      <xsl:with-param name="num"
        select="count($all-params[@name = $val]/preceding-sibling::xgf:param) + 1"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'ADD'"/>
    </xsl:call-template>
    <!-- Now we know the location on the stack of the parameter we want.
         Copy it to the top. -->
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'CINDEX'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- 3. Variables (Storage Locations) -->

  <!-- "Variables" are really locations in the TT Storage Area. We
       adopt a more familiar term. Several locations at the bottom of
       the Storage Area are reserved by xgridfit for legacy storage
       and for tracking state info; above that is a block of global
       variables; above that is a "variable frame" (defined by
       var-frame-bottom and var-frame-top), which moves up and down as
       the scope changes. Result is that every glyph program and every
       function (also the pre-program) gets its own private space in
       the Storage Area. If you call a function recursively, each
       iteration gets its own set of variables. -->

  <!-- Call at the beginning of each glyph program and the pre-program
       to set up the variable frame. Code is inserted only if the
       program contains variables or calls a function (we don't try to
       predict whether the function will contain variables). -->
  <xsl:template name="set-up-variable-frame">
    <xsl:call-template name="push-list">
      <xsl:with-param name="list">
        <xsl:call-template name="resolve-std-variable-loc">
          <xsl:with-param name="n" select="$var-frame-bottom"/>
        </xsl:call-template>
        <xsl:value-of select="$semicolon"/>
        <xsl:call-template name="resolve-std-variable-loc">
          <xsl:with-param name="n" select="$variable-frame-base"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'WS'"/>
    </xsl:call-template>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
        <xsl:call-template name="resolve-std-variable-loc">
          <xsl:with-param name="n" select="$var-frame-top"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="xgf:variable">
        <xsl:call-template name="push-num">
          <xsl:with-param name="num">
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$variable-frame-base"/>
              <xsl:with-param name="add" select="count(xgf:variable)"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="push-num">
          <xsl:with-param name="num">
            <xsl:call-template name="resolve-std-variable-loc">
              <xsl:with-param name="n" select="$variable-frame-base"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'WS'"/>
    </xsl:call-template>
  </xsl:template>

  <!--

      push-variable

      Start with a variable element; get its position in the variables
      list; add reserved-storage to that index to get the location to
      read from in Storage.  Read from Storage and push the number to
      the top of the stack.
  -->
  <xsl:template name="push-variable">
    <xsl:param name="val"/>
    <xsl:param name="index-only" select="false()"/>
    <xsl:call-template name="number-command">
      <xsl:with-param name="num">
        <xsl:call-template name="resolve-std-variable-loc">
          <xsl:with-param name="n" select="$var-frame-bottom"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="number-command">
      <xsl:with-param name="num" select="count($val/preceding-sibling::xgf:variable) + 1"/>
      <xsl:with-param name="cmd" select="'ADD'"/>
    </xsl:call-template>
    <xsl:if test="not($index-only)">
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'RS'"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="push-global-variable">
    <xsl:param name="val"/>
    <xsl:param name="index-only" select="false()"/>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
        <xsl:call-template name="resolve-std-variable-loc">
          <xsl:with-param name="n" select="$global-variable-base"/>
          <xsl:with-param name="add" select="count($val/preceding-sibling::xgf:variable) + 1"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:if test="not($index-only)">
      <xsl:call-template name="simple-command">
        <xsl:with-param name="cmd" select="'RS'"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <!--

      store-variable

      The value to be stored has got to be on top of the stack.
  -->
  <xsl:template name="store-variable">
    <xsl:param name="val"/>
    <xsl:call-template name="number-command">
      <xsl:with-param name="num">
        <xsl:call-template name="resolve-std-variable-loc">
          <xsl:with-param name="n" select="$var-frame-bottom"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="number-command">
      <xsl:with-param name="num" select="count($val/preceding-sibling::xgf:variable) + 1"/>
      <xsl:with-param name="cmd" select="'ADD'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SWAP'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'WS'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="store-global-variable">
    <xsl:param name="val"/>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num">
        <xsl:call-template name="resolve-std-variable-loc">
          <xsl:with-param name="n" select="$global-variable-base"/>
          <xsl:with-param name="add"
                          select="count($val/preceding-sibling::xgf:variable) + 1"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SWAP'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'WS'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="xgf:variable" mode="initialize">
    <xsl:call-template name="debug-start"/>
    <xsl:if test="@value">
      <xsl:call-template name="expression">
        <xsl:with-param name="val" select="@value"/>
        <xsl:with-param name="to-stack" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="store-value">
        <xsl:with-param name="vname" select="@name"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <!--

      stack-top-to-storage

      Pops a number off the stack and puts it in the specified
      location in the Storage Area. $loc must be a number.
  -->
  <xsl:template name="stack-top-to-storage">
    <xsl:param name="loc"/>
    <xsl:call-template name="push-num">
      <xsl:with-param name="num" select="$loc"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SWAP'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'WS'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Copies a value from one storage location to another.
       Numbers only: no constants, vars. Location indexes must
       be less than 256. For internal use only. -->
  <xsl:template name="storage-to-storage">
    <xsl:param name="src"/>
    <xsl:param name="dest"/>
    <xsl:call-template name="push-list">
      <xsl:with-param name="list">
        <xsl:value-of select="$dest"/>
        <xsl:value-of select="$semicolon"/>
        <xsl:value-of select="$src"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'RS'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'WS'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- 4. Control Values (the CVT table) -->

  <!--

      store-control-value

      We can put anything at all into the CVT. Up to the user to make
      sure it makes sense. This version works only with pixel units.
      I'll have to think of some method of working with FUnits, though
      I'm not sure why one would want to write FUnits to the CVT.
  -->
  <xsl:template name="store-control-value">
    <xsl:param name="cvtname"/>
    <xsl:param name="mp-container"/>
    <xsl:call-template name="expression">
      <xsl:with-param name="val" select="$cvtname"/>
      <xsl:with-param name="permitted" select="'c'"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
      <xsl:with-param name="to-stack" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'SWAP'"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'WCVTP'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="x-store-control-value">
    <xsl:param name="cvtname"/>
    <xsl:param name="unit"/>
    <xsl:param name="val"/>
    <xsl:param name="mp-container"/>
<!--
    I don't see how this test is particularly useful, since push-list
    will crash with an intelligible error if it can't resolve the cv
    name.

    <xsl:variable name="cvt-index">
      <xsl:call-template name="expression">
        <xsl:with-param name="val" select="$cvtname"/>
        <xsl:with-param name="cvt-mode" select="'index'"/>
        <xsl:with-param name="permitted" select="'c'"/>
        <xsl:with-param name="mp-container"
                      select="$mp-container"/>
        <xsl:with-param name="called-from" select="'x-store-control-value 1'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$cvt-index = 'NaN'">
      <xsl:call-template name="error-message">
        <xsl:with-param name="msg">
          <xsl:text>Can't resolve control-value "</xsl:text>
          <xsl:value-of select="@cvtname"/>
          <xsl:text>"</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
-->
    <xsl:call-template name="push-list">
      <!-- <xsl:with-param name="list" select="concat($cvt-index,';',$val)"/> -->
      <xsl:with-param name="list" select="concat($cvtname,';',$val)"/>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd">
        <xsl:choose>
          <xsl:when test="$unit = 'font'">
            <xsl:text>WCVTF</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>WCVTP</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="push-homogeneous-list">
    <xsl:param name="list"/>
    <xsl:param name="count"/>
    <xsl:param name="type"/>
    <xsl:param name="is-point-list"/>
    <xsl:param name="permitted"/>
    <xsl:param name="mp-container"/>
    <xsl:param name="running-count" select="0"/>
    <xsl:param name="debug" select="false()"/>
    <!--
        If true, we will not recurse.
    -->
    <xsl:variable name="is-last-iteration" select="not(contains($list,';'))"/>
    <!--
        What we will push now.
    -->
    <xsl:variable name="current">
      <xsl:choose>
        <xsl:when test="contains($list,';')">
          <xsl:value-of select="substring-before($list,';')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$list"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!--
        What (if anything) we will pass to the next iteration of this
        template.
    -->
    <xsl:variable name="new-list">
      <xsl:choose>
        <xsl:when test="$is-last-iteration">
          <xsl:value-of select="''"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring-after($list,';')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!--
        Now push a value. If $type is V, we do what we have to do. If
        B or W, we should have a number all ready to push with the
        simplest template we've got for the purpose.
    -->
    <xsl:choose>
      <xsl:when test="$type = 'V'">
        <xsl:choose>
          <xsl:when test="$is-point-list">
            <xsl:call-template name="expression-with-offset">
              <xsl:with-param name="val" select="$current"/>
              <xsl:with-param name="permitted" select="$permitted"/>
              <xsl:with-param name="mp-container" select="$mp-container"/>
              <xsl:with-param name="to-stack" select="true()"/>
              <xsl:with-param name="called-from" select="'push-homogeneous-list-1'"/>
              <xsl:with-param name="debug" select="$debug"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="expression">
              <xsl:with-param name="val" select="$current"/>
              <xsl:with-param name="permitted" select="$permitted"/>
              <xsl:with-param name="mp-container" select="$mp-container"/>
              <xsl:with-param name="to-stack" select="true()"/>
              <xsl:with-param name="called-from" select="'push-homogeneous-list-2'"/>
              <xsl:with-param name="debug" select="$debug"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="push-num">
          <xsl:with-param name="num" select="$current"/>
          <xsl:with-param name="expect" select="$count"/>
          <xsl:with-param name="add-mode" select="boolean($running-count &gt; 0)"/>
          <xsl:with-param name="size" select="$type"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <!--
        If we're not yet at the end of the list, then recurse.
    -->
    <xsl:if test="not($is-last-iteration)">
      <xsl:call-template name="push-homogeneous-list">
        <xsl:with-param name="list" select="$new-list"/>
        <xsl:with-param name="count" select="$count"/>
        <xsl:with-param name="type" select="$type"/>
        <xsl:with-param name="is-point-list" select="$is-point-list"/>
        <xsl:with-param name="permitted" select="$permitted"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
        <xsl:with-param name="running-count" select="$running-count + 1"/>
        <xsl:with-param name="debug" select="$debug"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="push-list">
    <!--
        The brief of this template is to parse a semicolon-delimited
        list of values and get them onto the stack. When this can be
        done with PUSH instructions, that's fine; but if more complex
        operations are needed, that's fine too. This should gracefully
        handle heterogeneous lists, grouping PUSHB and PUSHW
        operations.
    -->
    <xsl:param name="list"/>
    <xsl:param name="queue" select="''"/>
    <xsl:param name="queue-type" select="'A'"/>
    <xsl:param name="queue-count" select="0"/>
    <xsl:param name="is-point-list" select="false()"/>
    <xsl:param name="is-pre-resolved" select="false()"/>
    <xsl:param name="permitted" select="'12xmplrfvncg'"/>
    <xsl:param name="mp-container"/>
    <xsl:param name="debug" select="false()"/>
    <xsl:if test="$debug">
      <xsl:message terminate="no">
        <xsl:text>list: </xsl:text>
        <xsl:value-of select="$list"/>
      </xsl:message>
    </xsl:if>
    <xsl:if test="not(string-length($list)) and not(string-length($queue))">
      <xsl:call-template name="error-message">
        <xsl:with-param name="type" select="'internal'"/>
        <xsl:with-param name="msg">
          <xsl:text>push-list has nothing to do!</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:variable name="is-initial-iteration" select="$queue-type = 'A'"/>
    <!--
        $current is the value which this iteration extracts from the
        $list and adds to the $queue. We take it in steps.
    -->
    <!--
        $current-raw is what we extract from the list.
    -->
    <xsl:variable name="current-raw">
      <xsl:choose>
        <xsl:when test="contains($list,';')">
          <xsl:value-of select="substring-before($list,';')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$list"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!--
        $current-intermediate is either a.) a pre-tested value (member
        of a set of points) or b.) the result of a test, NaN if the
        value needs to be resolved at run time. We want this because
        we need to know it in merge-mode, where we don't always emerge
        from the test with a number literal, and yet the identifier
        can be put on the stack.
    -->
    <xsl:variable name="current-intermediate">
      <xsl:choose>
        <xsl:when test="$is-pre-resolved">
          <xsl:value-of select="$current-raw"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$is-point-list">
              <xsl:call-template name="expression-with-offset">
                <xsl:with-param name="val" select="$current-raw"/>
                <xsl:with-param name="permitted" select="$permitted"/>
                <xsl:with-param name="called-from" select="'push-list-1'"/>
                <xsl:with-param name="crash-on-fail" select="false()"/>
                <xsl:with-param name="mp-container" select="$mp-container"/>
                <xsl:with-param name="debug" select="$debug"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="expression">
                <xsl:with-param name="val" select="$current-raw"/>
                <xsl:with-param name="permitted" select="$permitted"/>
                <xsl:with-param name="called-from" select="'push-list-2'"/>
                <xsl:with-param name="crash-on-fail" select="false()"/>
                <xsl:with-param name="mp-container" select="$mp-container"/>
                <xsl:with-param name="debug" select="$debug"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!--
        And finally $current is what we're going to pass on to the
        next stage of processing.
    -->
    <xsl:variable name="current">
      <xsl:choose>
        <xsl:when test="$current-intermediate != 'NaN'">
          <xsl:value-of select="$current-intermediate"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$current-raw"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!--
        $current-type is the type of $current. If it must be resolved
        to a number at run time, it is V. If it is an empty string, it
        is Z. Otherwise it is B (a byte), W (a word) or M (a number
        for merge-mode).
    -->
    <xsl:variable name="current-type">
      <xsl:choose>
        <xsl:when test="string-length($current) = 0">
          <xsl:text>Z</xsl:text>
        </xsl:when>
        <!--
        <xsl:when test="$merge-mode and $current-intermediate != 'NaN'">
          <xsl:value-of select="'M'"/>
        </xsl:when>
        -->
        <xsl:when test="number($current) &gt;= 0 and number($current) &lt; 256">
          <xsl:text>B</xsl:text>
        </xsl:when>
        <xsl:when test="number($current)">
          <xsl:text>W</xsl:text>
        </xsl:when>
        <xsl:when test="string-length($current)">
          <xsl:value-of select="'V'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="error-message">
            <xsl:with-param name="msg">
              <xsl:text>Can't identify type of list-component "</xsl:text>
              <xsl:value-of select="$current"/>
              <xsl:text>"</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="type" select="'internal'"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="is-final-iteration" select="$current-type = 'Z'"/>
    <!--
        $new-list is what remains of the $list after $current has been
        extracted.
    -->
    <xsl:variable name="new-list">
      <xsl:choose>
        <xsl:when test="contains($list,';')">
          <xsl:value-of select="substring-after($list,';')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="invoke-push-break"
                  select="$queue-count &gt;= number($push_break)"/>
    <!--
        True if $current-type is different from $queue-type (so we
        have to push now to be able to push with a single PUSHB or
        PUSHW instruction) or $current is empty (so $queue will grow
        no more).
    -->
    <xsl:variable name="must-push-queue"
                  select="($queue-type != $current-type or $invoke-push-break)
                          and not($is-initial-iteration)"/>
    <!--
        Now actually push the queue, if necessary.
    -->
    <xsl:if test="$must-push-queue">
      <xsl:call-template name="push-homogeneous-list">
        <xsl:with-param name="list" select="$queue"/>
        <xsl:with-param name="count" select="$queue-count"/>
        <xsl:with-param name="type" select="$queue-type"/>
        <xsl:with-param name="is-point-list" select="$is-point-list"/>
        <xsl:with-param name="permitted" select="$permitted"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
        <xsl:with-param name="debug" select="$debug"/>
      </xsl:call-template>
    </xsl:if>
    <!--
        $current-type is Z if there is nothing more to do. Otherwise,
        recurse.
    -->
    <xsl:if test="not($is-final-iteration)">
      <xsl:call-template name="push-list">
        <xsl:with-param name="list" select="$new-list"/>
        <xsl:with-param name="queue">
          <xsl:choose>
            <xsl:when test="$must-push-queue or $is-initial-iteration">
              <xsl:value-of select="$current"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat($queue,';',$current)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="queue-type" select="$current-type"/>
        <xsl:with-param name="queue-count">
          <xsl:choose>
            <xsl:when test="$must-push-queue">
              <xsl:value-of select="1"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$queue-count + 1"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="is-point-list" select="$is-point-list"/>
        <xsl:with-param name="permitted" select="$permitted"/>
        <xsl:with-param name="mp-container" select="$mp-container"/>
        <xsl:with-param name="debug" select="$debug"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
