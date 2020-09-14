<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"
                xmlns:xgfd="http://www.engl.virginia.edu/OE/xgridfit-data"
                xmlns:excom="http://exslt.org/common"
                version="1.0"
                exclude-result-prefixes="xgf"
                extension-element-prefixes="excom">


  <!--
      This file is part of xgridfit, version 3.
      Licensed under the Apache License, Version 2.0.
      Copyright (c) 2006-20 by Peter S. Baker
  -->

  <!--
    New merge-mode needs to worry about these things:
    - Storage. Read max-storage from maxp. The number becomes
      the new storage-base. DONE BUT NOT TESTED.
    - CVT. The old Xgridfit employed a scheme whereby old cvs
      were re-used where possible. This may interfere with
      the color attribute on the cv. Find out if it does, and
      if so drop the old scheme and just add all new cvs to the
      old. NOT WORTH IT. WE PUT THE NEW CVT ON TOP OF THE OLD
    - Functions. Read the number of functions from maxp. But
      this is not reliable, since the series of functions
      indices may contain gaps. So provide an override via a
      default element. NOT YET IMPLEMENTED.
    - There are lots of params and variables. Make sure they're
      all needed: delete any that aren't.
  -->

  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:param name="cvartable">
    <xsl:value-of select="'none'"/>
  </xsl:param>

  <xsl:param name="glyph_select">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:glyph-select">
        <xsl:value-of select="/xgf:xgridfit/xgf:glyph-select"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="delete_all">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='delete-all']">
	<xsl:value-of select="/xgf:xgridfit/xgf:default[@type='delete-all']/@value"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="'no'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="combine_prep">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='combine-prep']">
	<xsl:value-of select="/xgf:xgridfit/xgf:default[@type='combine-prep']/@value"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="'yes'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="compile_globals">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='compile-globals']">
        <xsl:value-of select="/xgf:xgridfit/xgf:default[@type='compile-globals']/@value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'yes'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="init_graphics">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='init-graphics']">
        <xsl:value-of select="/xgf:xgridfit/xgf:default[@type='init-graphics']/@value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'yes'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="assume-always-y">
    <xsl:choose>
      <xsl:when
          test="/xgf:xgridfit/xgf:default[@type='assume-always-y']">
        <xsl:value-of select="/xgf:xgridfit/xgf:default[@type='assume-always-y']/@value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'no'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <!-- How many points permitted in the twilight zone. This is
       generous, I think. -->
  <xsl:param name="max_twilight_points">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='max-twilight-points']">
        <xsl:value-of select="/xgf:xgridfit/xgf:default[@type=
                              'max-twilight-points']/@value"/>
      </xsl:when>
      <xsl:otherwise>25</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <!-- How many storage spaces to allocate. These are used for variables.
       Increase the number if you use variables a lot. -->
  <xsl:param name="max_storage">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='max-storage']">
        <xsl:value-of select="/xgf:xgridfit/xgf:default[@type=
                              'max-storage']/@value"/>
      </xsl:when>
      <xsl:otherwise>64</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="max_stack">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='max-stack']">
        <xsl:value-of select="/xgf:xgridfit/xgf:default[@type=
                              'max-stack']/@value"/>
      </xsl:when>
      <xsl:otherwise>256</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="push_break">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='push-break']">
        <xsl:value-of select="/xgf:xgridfit/xgf:default[@type=
                              'push-break']/@value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="255"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="color">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='color']">
        <xsl:value-of select="/xgf:xgridfit/xgf:default[@type=
                              'color']/@value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'gray'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="function-base" select="0"/>

  <xsl:param name="storage-base" select="0"/>

  <xsl:param name="cvt-base" select="0"/>

  <xsl:variable name="merge-mode" select="$function-base &gt; 0 or
    $storage-base &gt; 0 or $cvt-base &gt; 0"/>

  <xsl:param name="infile">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:infile">
        <xsl:value-of select="/xgf:xgridfit/xgf:infile"/>
      </xsl:when>
      <xsl:otherwise>!!nofile!!</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="outfile">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:outfile">
        <xsl:value-of select="/xgf:xgridfit/xgf:outfile"/>
      </xsl:when>
      <xsl:otherwise>!!nofile!!</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="mp-containers"
             select="//xgf:call-macro[not(param-set)]|
                     //xgf:call-macro/xgf:param-set|
                     //xgf:call-glyph"/>

  <xsl:key name="cvt" match="xgf:control-value" use="@name"/>
  <xsl:key name="function-index" match="xgf:function" use="@name"/>
  <xsl:key name="macro-index" match="xgf:macro" use="@name"/>
  <xsl:key name="glyph-index" match="xgf:glyph|xgf:no-compile/xgf:glyph"
           use="@ps-name"/>
  <xsl:key name="alias-index" match="xgf:alias" use="@name"/>

  <!-- We'll do our own formatting of all TT instructions, providing all
       line breaks and spacing. So no space or line breaks kept from source
       file. -->
  <xsl:strip-space elements="*"/>

  <xsl:variable name="newline">
    <!-- <xsl:text>\n</xsl:text> -->
    <xsl:text></xsl:text>
  </xsl:variable>

  <xsl:variable name="inst-newline">
    <!-- <xsl:text>\n\
</xsl:text> -->
    <xsl:text>
</xsl:text>
  </xsl:variable>

  <xsl:variable name="push-num-separator" select="$inst-newline"/>

  <xsl:variable name="text-newline">
    <xsl:text>
</xsl:text>
  </xsl:variable>

  <xsl:variable name="leading-newline" select="$inst-newline"/>

  <xsl:variable name="cv-num-in-compile-if" select="'yes'"/>

  <xsl:variable name="file-extension" select="'.py'"/>

  <!-- These will be found in func-predef.xsl. -->
  <xsl:variable name="predefined-functions" select="4"/>

  <xsl:variable name="auto-function-base">
    <xsl:value-of select="$function-base"/>
  </xsl:variable>

  <xsl:variable name="var-legacy-storage">
    <xsl:value-of select="$storage-base"/>
  </xsl:variable>

  <xsl:variable name="function-round-restore"
                select="$auto-function-base"/>

  <xsl:variable name="function-glyph-prolog"
                select="number($auto-function-base) + 1"/>

  <xsl:variable name="function-push-range"
                select="number($auto-function-base) + 2"/>

  <xsl:variable name="function-order-range"
                select="number($auto-function-base) + 3"/>

  <xsl:include href="std-vars.xsl"/>
  <xsl:include href="numbers.xsl"/>
  <xsl:include href="expressions.xsl"/>
  <xsl:include href="arithmetic.xsl"/>
  <xsl:include href="points.xsl"/>
  <xsl:include href="flow.xsl"/>
  <xsl:include href="function.xsl"/>
  <xsl:include href="func-predef.xsl"/>
  <xsl:include href="prep.xsl"/>
  <xsl:include href="graphics.xsl"/>
  <xsl:include href="measure.xsl"/>
  <xsl:include href="primitives.xsl"/>
  <xsl:include href="delta.xsl"/>
  <xsl:include href="move-lib.xsl"/>
  <xsl:include href="move-els.xsl"/>
  <xsl:include href="messages.xsl"/>
  <xsl:include href="misc.xsl"/>

  <!--

       simple-command

       A very simple, one-line command, with optional modifier.
  -->
  <xsl:template name="simple-command">
    <xsl:param name="cmd"/>
    <xsl:param name="modifier" select="' '"/>
    <xsl:value-of select="$leading-newline"/>
    <xsl:value-of select="$cmd"/>
    <xsl:if test="$modifier">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="$modifier"/>
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>

  <!--

       push-command

       Generates the command for a PUSH instruction.
  -->
  <xsl:template name="push-command">
    <xsl:param name="size" select="'B'"/>
    <xsl:param name="count" select="1"/>
    <xsl:if test="number($count) &gt; 255">
      <xsl:call-template name="error-message">
        <xsl:with-param name="msg">
          <xsl:text>You may not push more than 255 numbers at one time.</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:variable name="cmd">
      <xsl:choose>
        <xsl:when test="number($count) &lt;= 8">
          <xsl:value-of select="concat('PUSH',$size)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('NPUSH',$size)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="$cmd"/>
    </xsl:call-template>
  </xsl:template>

  <!-- The following templates are for the bit-flags that accompany
       certain instructions. -->

  <xsl:template name="color-bits">
    <xsl:param name="l-color"/>
    <xsl:choose>
      <xsl:when test="$l-color='black'">
        <xsl:text>01</xsl:text>
      </xsl:when>
      <xsl:when test="$l-color='white'">
        <xsl:text>10</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>00</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="to-line-bit">
    <xsl:param name="tlb"/>
    <xsl:choose>
      <xsl:when test="$tlb='orthogonal'">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="axis-bit">
    <xsl:param name="axis"/>
    <xsl:choose>
      <xsl:when test="$axis='x'">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:when test="$axis='y'">
        <xsl:text>0</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="error-message">
          <xsl:with-param name="msg">
            <xsl:text>When setting a vector, the "axis" </xsl:text>
            <xsl:text>attribute must be either "x" or "y."</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="round-and-cut-in-bit">
    <xsl:param name="b" select="true()"/>
    <xsl:choose>
      <xsl:when test="$b">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="rp0-bit">
    <xsl:param name="set-rp0"/>
    <xsl:choose>
      <xsl:when test="$set-rp0">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mirp-mdrp-bits">
    <xsl:param name="set-rp0"/>
    <xsl:param name="min-distance"/>
    <xsl:param name="round-cut-in"/>
    <xsl:param name="l-color"/>
    <xsl:call-template name="rp0-bit">
      <xsl:with-param name="set-rp0" select="$set-rp0"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="$min-distance">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="round-and-cut-in-bit">
      <xsl:with-param name="b" select="$round-cut-in"/>
    </xsl:call-template>
    <xsl:call-template name="color-bits">
      <xsl:with-param name="l-color" select="$l-color"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="ref-ptr-bit">
    <xsl:param name="ref-ptr"/>
    <xsl:choose>
      <xsl:when test="$ref-ptr='1'">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="grid-fitted-bit">
    <xsl:param name="grid-fitted"/>
    <xsl:choose>
      <xsl:when test="$grid-fitted">
        <xsl:text>0</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="resolve-std-variable-loc">
    <xsl:param name="n"/>
    <xsl:param name="add" select="0"/>
    <xsl:choose>
      <xsl:when test="number($n) or number($n) = 0">
        <xsl:value-of select="number($n) + number($var-legacy-storage) + $add"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="number(document('xgfdata.xml')/*/xgfd:var-locations/xgfd:loc[@name=$n]/@val) +
                              number($var-legacy-storage) + $add"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-cvt-index">
    <xsl:param name="name"/>
    <xsl:param name="need-number-now"/>
    <xsl:value-of select="count(key('cvt',$name)/preceding-sibling::xgf:control-value) +
      number($cvt-base)"/>
  </xsl:template>

  <xsl:template name="debug-start"></xsl:template>

  <xsl:template name="debug-end"></xsl:template>

<!-- ========================================================================= -->
<!-- ============== TOP-LEVEL ELEMENTS OF THE INSTRUCTION FILE =============== -->
<!-- ========================================================================= -->

<!--
  Instead of one big template, we break the process up into chunks which
  can be called individually via the following params.
-->
  <xsl:param name="singleGlyphId" select="'A'"/>
  <xsl:param name="prep-only" select="'no'"/>
  <xsl:param name="fpgm-only" select="'no'"/>
  <xsl:param name="function-count" select="'no'"/>
  <xsl:param name="stack-safe-list" select="'no'"/>
  <xsl:param name="get-cvt-list" select="'no'"/>
  <xsl:param name="get-glyph-list" select="'no'"/>
  <xsl:param name="get-cvar" select="'no'"/>
  <xsl:param name="another-test" select="'no'"/>

  <xsl:template match="/">
    <xsl:if test="not(xgf:xgridfit)">
      <xsl:call-template name="error-message">
        <xsl:with-param name="msg" select="$no-namespace-error"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="xgf:xgridfit">
    <xsl:choose>
      <xsl:when test="$prep-only='yes'">
        <xsl:apply-templates select="xgf:pre-program"/>
      </xsl:when>
      <xsl:when test="$fpgm-only='yes'">
        <xsl:call-template name="make-new-functions"/>
      </xsl:when>
      <xsl:when test="$function-count='yes'">
        <xsl:value-of select="count(/xgf:xgridfit/xgf:function)"/>
      </xsl:when>
      <xsl:when test="$stack-safe-list='yes'">
        <xsl:call-template name="make-stack-safe-list"/>
      </xsl:when>
      <xsl:when test="$get-cvt-list='yes'">
        <xsl:call-template name="make-cvt-list"/>
      </xsl:when>
      <xsl:when test="$get-glyph-list='yes'">
        <xsl:call-template name="make-glyph-list"/>
      </xsl:when>
      <xsl:when test="$get-cvar='yes'">
        <xsl:call-template name="get-cvar-tuples"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="no">
          <xsl:text>In otherwise clause. ID is </xsl:text>
          <xsl:value-of select="$singleGlyphId"/>
        </xsl:message>
        <xsl:apply-templates select="xgf:glyph[@ps-name=$singleGlyphId]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-cvar-tuples">
    <xsl:message>
      <xsl:text>Generating cvar tuples</xsl:text>
    </xsl:message>
    <xsl:text>[</xsl:text>
    <xsl:for-each select="/xgf:xgridfit/xgf:cvar/xgf:region">
      <xsl:text>[{"</xsl:text>
      <xsl:value-of select="@tag"/>
      <xsl:text>": (</xsl:text>
      <xsl:value-of select="@bot"/>
      <xsl:text>, </xsl:text>
      <xsl:value-of select="@peak"/>
      <xsl:text>, </xsl:text>
      <xsl:value-of select="@top"/>
      <xsl:text>)}, </xsl:text>
      <xsl:call-template name="get-region-coordinates">
        <xsl:with-param name="region" select="."/>
      </xsl:call-template>
      <xsl:text>]</xsl:text>
      <xsl:if test="position() != last()">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template name="get-region-coordinates">
    <xsl:param name="region"/>
    <xsl:variable name="cvvs" select="$region/xgf:cvv"/>
    <xsl:text>[</xsl:text>
    <xsl:for-each select="/xgf:xgridfit/xgf:control-value">
      <xsl:variable name="cvname" select="@name"/>
      <xsl:choose>
        <xsl:when test="$cvvs[@name = $cvname]">
          <xsl:variable name="defcv" select="number(@value)"/>
          <xsl:variable name="varcv"
            select="number($cvvs[@name = $cvname]/@value)"/>
          <xsl:variable name="r" select="$varcv - $defcv"/>
          <xsl:choose>
            <xsl:when test="$r = 0">
              <xsl:text>None</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$r"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="0"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="position() != last()">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>]</xsl:text>
  </xsl:template>


  <xsl:template name="make-cvt-list">
    <xsl:for-each select="/xgf:xgridfit/xgf:control-value">
      <xsl:value-of select="@value"/>
      <xsl:if test="position() != last()">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="make-glyph-list">
    <xsl:for-each select="/xgf:xgridfit/xgf:glyph">
      <xsl:value-of select="@ps-name"/>
      <xsl:if test="position() != last()">
        <xsl:text> </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="make-stack-safe-list">
    <xsl:text>{1: 1</xsl:text>
    <xsl:for-each select="/xgf:xgridfit/xgf:function">
      <xsl:if test="@stack-safe = 'yes'">
      <xsl:text>, </xsl:text>
      <xsl:call-template name="get-function-number">
        <xsl:with-param name="function-name" select="./@name"/>
      </xsl:call-template>
      <xsl:text>: </xsl:text>
      <xsl:value-of select="count(./xgf:param) + 1"/>
    </xsl:if>
    </xsl:for-each>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template name="make-new-functions">
    <xsl:param name="all-functions" select="/xgf:xgridfit/xgf:function"/>
    <xsl:variable name="new-fpgm">
      <xsl:call-template name="function-zero"/>
      <xsl:call-template name="function-one"/>
      <xsl:call-template name="function-two"/>
      <xsl:call-template name="function-three"/>
      <xsl:apply-templates select="$all-functions[not(@num) and
                                   not(xgf:variant)]"/>
    </xsl:variable>
    <xsl:value-of select="$new-fpgm"/>
  </xsl:template>

  <xsl:template name="make-flags-tuple">
    <xsl:param name="f"/>
    <xsl:param name="count" select="0"/>
    <xsl:variable name="current-flag">
      <xsl:choose>
        <xsl:when test="contains($f,' ')">
          <xsl:value-of select="substring-before($f,' ')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$f"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="remaining-flags">
      <xsl:choose>
        <xsl:when test="contains($f,' ')">
          <xsl:value-of select="substring-after($f,' ')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$count = 0">
        <xsl:text>(</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>, </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>'</xsl:text>
    <xsl:value-of select="$current-flag"/>
    <xsl:text>'</xsl:text>
    <xsl:choose>
      <xsl:when test="string-length($remaining-flags) = 0">
        <xsl:if test="$count = 0">
          <xsl:text>,</xsl:text>
        </xsl:if>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="make-flags-tuple">
          <xsl:with-param name="f" select="$remaining-flags"/>
          <xsl:with-param name="count" select="$count + 1"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xgf:pre-program">
    <xsl:variable name="all-defaults" select="/xgf:xgridfit/xgf:default"/>
    <xsl:variable name="use-tt-defaults"
                  select="boolean($all-defaults[@type =
                          'use-truetype-defaults']/@value = 'yes')"/>
    <xsl:variable name="current-inst">
      <xsl:call-template name="pre-program-instructions"/>
      </xsl:variable>
    <xsl:value-of select="substring-after($current-inst,$leading-newline)"/>
    <xsl:apply-templates/>
  </xsl:template>

  <!--
      N.B. template "glyph" with mode "called" will be in
      function.xsl.  There will be nothing non-portable in it, and we
      don't want to write it twice.
  -->
  <xsl:template match="xgf:glyph">
    <xsl:variable name="var-string">
      <xsl:text>x</xsl:text>
      <xsl:apply-templates select="." mode="survey-vars"/>
    </xsl:variable>
    <xsl:variable name="need-variable-frame"
                  select="contains($var-string,'v')"/>
    <xsl:variable name="assume-y">
      <xsl:choose>
        <xsl:when test="@assume-y">
          <xsl:value-of select="@assume-y"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$assume-always-y"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="init-g">
      <xsl:choose>
        <xsl:when test="@init-graphics">
          <xsl:value-of select="@init-graphics"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$init_graphics"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="current-inst">
      <xsl:if test="$need-variable-frame">
        <xsl:call-template name="set-up-variable-frame"/>
        <xsl:apply-templates select="xgf:variable" mode="initialize"/>
      </xsl:if>
      <xsl:if test="$init-g = 'yes'">
        <xsl:call-template name="number-command">
          <xsl:with-param name="num" select="$function-glyph-prolog"/>
          <xsl:with-param name="cmd" select="'CALL'"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="$assume-y = 'yes' and (not(xgf:set-vectors) and
                    not(xgf:with-vectors))">
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'SVTCA'"/>
          <xsl:with-param name="modifier" select="'0'"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:apply-templates/>
      <xsl:if test="$assume-y = 'yes' and not(xgf:interpolate-untouched-points)">
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="'IUP'"/>
          <xsl:with-param name="modifier" select="'0'"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:value-of select="substring-after($current-inst,$leading-newline)"/>
  </xsl:template>

  <!-- The following elements are declarations, read only
       by this script and never converted to code. -->

  <xsl:template match="xgf:no-compile"></xsl:template>

</xsl:stylesheet>
