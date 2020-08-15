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

  <xsl:template name="make-push-list">
    <xsl:param name="s"/>
    <xsl:param name="built-string" select="''"/>
    <xsl:variable name="current">
      <xsl:if test="string-length($built-string) &gt; 0">
        <xsl:value-of select="';'"/>
      </xsl:if>
      <xsl:call-template name="get-first-token">
        <xsl:with-param  name="s" select="$s"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="remaining">
      <xsl:call-template name="get-remaining-tokens">
        <xsl:with-param  name="s" select="$s"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string-length($remaining) &gt; 0">
        <xsl:call-template name="make-push-list">
          <xsl:with-param name="s" select="$remaining"/>
          <xsl:with-param name="built-string" select="concat($built-string,$current)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($built-string,$current)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xgf:to-stack">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:call-template name="expression">
      <xsl:with-param name="val" select="."/>
      <xsl:with-param name="mp-container"
                      select="$mp-container"/>
      <xsl:with-param name="to-stack" select="true()"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:push">
    <xsl:param name="mp-container"/>
    <xsl:call-template name="debug-start"/>
    <xsl:variable name="push-vals" select="normalize-space(string(.))"/>
    <xsl:if test="string-length($push-vals) = 0">
      <xsl:call-template name="error-message">
        <xsl:with-param name="msg">
          <xsl:text>Empty push or to-stack element is not permitted.</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="push-list">
      <xsl:with-param name="list">
        <xsl:call-template name="make-push-list">
          <xsl:with-param name="s" select="$push-vals"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="mp-container" select="$mp-container"/>
    </xsl:call-template>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

  <xsl:template match="xgf:command">
    <xsl:call-template name="debug-start"/>
    <!-- Test whether this is a valid instruction. -->
    <xsl:if test="not(document('xgfdata.xml')/*/xgfd:instruction-set/xgfd:inst[@val
                  = current()/@name])">
      <xsl:call-template name="error-message">
        <xsl:with-param name="msg">
          <xsl:text>Unrecognized instruction </xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text> in &lt;command&gt; element.</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:choose>
      <!-- This instruction requires a modifier. -->
      <xsl:when test="document('xgfdata.xml')/*/xgfd:instruction-set/xgfd:inst[@val
                      = current()/@name]/@mod = 'yes'">
        <xsl:choose>
          <!-- We have a modifier provided via the modifier attribute, and there is
               no <modifier> element. We just copy the modifier with no checking. -->
          <xsl:when test="@modifier and not(xgf:modifier)">
            <xsl:call-template name="simple-command">
              <xsl:with-param name="cmd" select="@name"/>
              <xsl:with-param name="modifier" select="@modifier"/>
            </xsl:call-template>
          </xsl:when>
          <!-- Otherwise we either have (a) modifier element(s) or we use (a) default(s). -->
          <xsl:otherwise>
            <xsl:call-template name="simple-command">
              <xsl:with-param name="cmd" select="@name"/>
              <xsl:with-param name="modifier">
                <xsl:choose>
                  <xsl:when test="@name='MIRP' or @name='MDRP'">
                    <!--
                        defaults are:
                        set-rp0: true
                        min-distance: true
                        round (and cut-in for MIRP): true
                        color: gray
                    -->
                    <xsl:call-template name="mirp-mdrp-bits">
                      <xsl:with-param name="set-rp0"
                        select="boolean(not(xgf:modifier[@type='set-rp0']) or
                                xgf:modifier[@type='set-rp0']/@value = 'yes')"/>
                      <xsl:with-param name="min-distance"
                        select="boolean(not(xgf:modifier[@type='minimum-distance']) or
                                xgf:modifier[@type='minimum-distance']/@value = 'yes')"/>
                      <xsl:with-param name="round-cut-in"
                        select="boolean(not(xgf:modifier[@type='round']) or
                                xgf:modifier[@type='round']/@value = 'yes')"/>
                      <xsl:with-param name="l-color">
                        <xsl:choose>
                          <xsl:when test="xgf:modifier[@type='color']">
                            <xsl:value-of select="xgf:modifier[@type='color']/@value"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of select="$color"/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:when test="@name='ROUND' or @name='NROUND'">
                    <!-- default is gray -->
                    <xsl:call-template name="color-bits">
                      <xsl:with-param name="l-color">
                        <xsl:choose>
                          <xsl:when test="xgf:modifier[@type='color']">
                            <xsl:value-of select="xgf:modifier[@type='color']/@value"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:text>gray</xsl:text>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:when test="@name='SDPVTL' or @name='SPVTL' or @name='SFVTL'">
                    <!-- default is parallel -->
                    <xsl:call-template name="to-line-bit">
                      <xsl:with-param name="tlb">
                        <xsl:choose>
                          <xsl:when test="xgf:modifier[@type='to-line']">
                            <xsl:value-of select="xgf:modifier[@type='to-line']/@value"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:text>parallel</xsl:text>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:when test="@name='SVTCA' or @name='SPVTCA'
                    or @name='SFVTCA' or @name='IUP'">
                    <!-- default is x axis -->
                    <xsl:call-template name="axis-bit">
                      <xsl:with-param name="axis">
                        <xsl:choose>
                          <xsl:when test="xgf:modifier[@type='axis']">
                            <xsl:value-of select="xgf:modifier[@type='axis']/@value"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:text>x</xsl:text>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:when test="@name='MIAP' or @name='MDAP'">
                    <!-- default is yes -->
                    <xsl:call-template name="round-and-cut-in-bit">
                      <xsl:with-param name="b"
                                      select="boolean(not(xgf:modifier[@type='round']) or
                                              xgf:modifier[@type='round']/@value='yes')"/>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:when test="@name='MSIRP'">
                    <!-- default is yes -->
                    <xsl:call-template name="rp0-bit">
                      <xsl:with-param name="set-rp0"
                                      select="boolean(not(xgf:modifier[@type='set-rp0']) or
                                              xgf:modifier[@type='set-rp0']/@value='yes')"/>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:when test="@name='SHP' or @name='SHC' or @name='SHZ'">
                    <!-- default is 1 -->
                    <xsl:call-template name="ref-ptr-bit">
                      <xsl:with-param name="ref-ptr">
                        <xsl:choose>
                          <xsl:when test="xgf:modifier[@type='ref-ptr']">
                            <xsl:value-of select="xgf:modifier[@type='ref-ptr']/@value"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:text>1</xsl:text>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:when test="@name='GC' or @name='MD'">
                    <!-- default is grid-fitted -->
                    <xsl:call-template name="grid-fitted-bit">
                      <xsl:with-param name="grid-fitted"
                        select="boolean(not(xgf:modifier[@type='grid-fitted']) or
                                xgf:modifier[@type='grid-fitted']/@value='yes')"/>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:call-template name="error-message">
                      <xsl:with-param name="msg">
                        <xsl:text>Nothing to do in &lt;command&gt; with &lt;modifier&gt;. </xsl:text>
                        <xsl:text>This should not happen!</xsl:text>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- This instruction does not take a modifier. If one is present, it
           will be ignored. -->
      <xsl:otherwise>
        <xsl:call-template name="simple-command">
          <xsl:with-param name="cmd" select="@name"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="debug-end"/>
  </xsl:template>

</xsl:stylesheet>
