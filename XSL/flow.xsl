<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"
		version="1.0">

  <!--
      This file is part of xgridfit, version 3.
      Licensed under the Apache License, Version 2.0.
      Copyright (c) 2006-20 by Peter S. Baker
  -->

  <xsl:template name="glyph-list" xmlns:excom="http://exslt.org/common">
    <xsl:param name="separator" select="' '"/>
    <xsl:param name="list"/>
    <xsl:variable name="s" select="normalize-space($list)"/>
    <xsl:variable name="this-glyph">
      <xsl:choose>
	<xsl:when test="contains($s,$separator)">
	  <xsl:value-of select="substring-before($s,$separator)"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$s"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$outfile_base = '!!nofile!!'">
	<xsl:apply-templates select="key('glyph-index',$this-glyph)"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:variable name="new-filename"
		      select="concat($outfile_base,'_',$this-glyph,$file-extension)"/>
	<xsl:choose>
	  <xsl:when test="element-available('excom:document')">
	    <xsl:call-template name="display-message">
	      <xsl:with-param name="msg">
		<xsl:text>Saving to file </xsl:text>
		<xsl:value-of select="$new-filename"/>
	      </xsl:with-param>
	    </xsl:call-template>
<!--
	    <excom:document excom:href="{$new-filename}" excom:method="text">
-->
	    <excom:document href="{$new-filename}" method="text">
	      <xsl:apply-templates select="key('glyph-index',$this-glyph)"/>
	    </excom:document>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:call-template name="error-message">
	      <xsl:with-param name="msg">
		<xsl:text>Your XSLT engine does not support -S (outfile_base)</xsl:text>
	      </xsl:with-param>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="contains($s,$separator)">
      <xsl:if test="$merge-mode">
	<xsl:text>, \</xsl:text>
	<xsl:value-of select="$text-newline"/>
      </xsl:if>
      <xsl:call-template name="glyph-list">
	<xsl:with-param name="separator" select="$separator"/>
	<xsl:with-param name="list" select="substring-after($s,$separator)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <xsl:template match="xgf:if">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="expression">
      <xsl:with-param name="val" select="@test"/>
      <xsl:with-param name="mp-container"
		      select="$mp-container"/>
      <xsl:with-param name="to-stack" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'IF'"/>
    </xsl:call-template>
    <xsl:apply-templates>
      <xsl:with-param name="mp-container"
		      select="$mp-container"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="xgf:else" mode="if">
      <xsl:with-param name="mp-container"
		      select="$mp-container"/>
    </xsl:apply-templates>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'EIF'"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:else"></xsl:template>

  <xsl:template match="xgf:else" mode="if">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="'ELSE'"/>
    </xsl:call-template>
    <xsl:apply-templates>
      <xsl:with-param name="mp-container"
		      select="$mp-container"/>
    </xsl:apply-templates>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:else" mode="compile-if">
    <xsl:param name="mp-container"/>
    <xsl:apply-templates>
      <xsl:with-param name="mp-container"
		      select="$mp-container"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template name="compile-if-test">
    <xsl:param name="test"/>
    <xsl:param name="mp-container"/>
    <xsl:choose>
      <xsl:when test="not($test)">
	<xsl:value-of select="1"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:variable name="v">
	  <xsl:call-template name="expression">
	    <xsl:with-param name="val" select="$test"/>
	    <xsl:with-param name="need-number-now" select="$cv-num-in-compile-if = 'yes'"/>
	    <xsl:with-param name="mp-container"
			    select="$mp-container"/>
	    <xsl:with-param name="called-from" select="'compile-if-test'"/>
	  </xsl:call-template>
	</xsl:variable>
	<xsl:choose>
	  <xsl:when test="number($v)">
	    <xsl:value-of select="1"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="0"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xgf:compile-if">
    <xsl:param name="mp-container"/>
    <xsl:variable name="text-num">
      <xsl:call-template name="expression">
	<xsl:with-param name="val" select="@test"/>
	<xsl:with-param name="need-number-now" select="$cv-num-in-compile-if = 'yes'"/>
	<xsl:with-param name="mp-container"
			select="$mp-container"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="not(number($text-num)) and number($text-num) != 0">
      <xsl:call-template name="error-message">
	<xsl:with-param name="msg">
	  <xsl:text>Cannot resolve attribute test="</xsl:text>
	  <xsl:value-of select="@test"/>
	  <xsl:text>" in &lt;compile-if&gt;</xsl:text>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="number($text-num)">
	<xsl:apply-templates>
	  <xsl:with-param name="mp-container"
			  select="$mp-container"/>
	</xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="xgf:else" mode="compile-if">
	  <xsl:with-param name="mp-container"
			  select="$mp-container"/>
	</xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
