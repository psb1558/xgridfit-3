<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xgfd="http://www.engl.virginia.edu/OE/xgridfit-data" version="1.0">

  <!--
      This file is part of xgridfit, version 3.
      Licensed under the Apache License, Version 2.0.
      Copyright (c) 2006-20 by Peter S. Baker
  -->

  <!--
    Several templates for tokenizing strings. A "token"
    for us is either of two things: 1. a sequence
    containing no whitespace, or 2. a sequence enclosed
    in parentheses.

    The first template is for finding the closing
    parenthesis that matches the opening parenthesis
    that begins the string $s. Normally the opening
    paren will be the first character in the string,
    but that is not necessary. -->
  <xsl:template name="find-closing-paren">
    <xsl:param name="paren-nest-depth" select="0"/>
    <xsl:param name="current-position" select="1"/>
    <xsl:param name="s"/>
    <xsl:variable name="new-depth">
      <xsl:choose>
        <xsl:when test="starts-with($s,'(')">
          <xsl:value-of select="number($paren-nest-depth) + 1"/>
        </xsl:when>
        <xsl:when test="starts-with($s,')')">
          <xsl:value-of select="number($paren-nest-depth) - 1"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$paren-nest-depth"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="number($new-depth) &lt; 0">
      <xsl:call-template name="error-message">
        <xsl:with-param name="msg">
          <xsl:text>Closing parenthesis without opening parenthesis.</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="starts-with($s,')') and number($new-depth) = 0">
        <xsl:value-of select="$current-position"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="find-closing-paren">
          <xsl:with-param name="paren-nest-depth" select="$new-depth"/>
          <xsl:with-param name="current-position"
            select="number($current-position) + 1"/>
          <xsl:with-param name="s" select="substring($s,2)"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
    Spacing is normalized. If the expression is enclosed in
    parens they are removed. If the expression within the
    parens was padded with spaces they are removed. -->
  <xsl:template name="normalize-expression">
    <xsl:param name="s"/>
    <xsl:variable name="use-s" select="normalize-space($s)"/>
    <xsl:choose>
      <xsl:when test="starts-with($use-s,'(')">
        <xsl:variable name="n">
          <xsl:call-template name="find-closing-paren">
            <xsl:with-param name="s" select="$use-s"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="number($n) = string-length($use-s)">
            <xsl:value-of
              select="normalize-space(substring($use-s,2,string-length($use-s) - 2))"
            />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$use-s"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$use-s"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
    Return the first token in a string.
    If parentheses present, they are stripped off.
    Here are the tests, in order:
    - if the current string begins with open-paren,
      search forward for the matching close-paren
      (nesting of parens is allowed)
    - if the current string contains an open-paren,
      see if that is preceded anywhere by a space.
      If so, the token ends before the space. If
      not, the token ends before the paren.
    - if the current string contains a space, the
      current token ends before the space.
    - if the current string does not contain a
      space but has length, the whole string is the
      token.
    - the current string contains no token. It is
      empty.
    -->
  <xsl:template name="get-first-token">
    <xsl:param name="s"/>
    <xsl:param name="left-paren-sep" select="'('"/>
    <xsl:variable name="use-s">
      <xsl:value-of select="normalize-space($s)"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="starts-with($use-s,'(')">
        <xsl:variable name="n">
          <xsl:call-template name="find-closing-paren">
            <xsl:with-param name="s" select="$use-s"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of
          select="normalize-space(substring($use-s,1,number($n)))"/>
      </xsl:when>
      <xsl:when test="contains($use-s,$left-paren-sep)">
        <xsl:variable name="st" select="substring-before($use-s,'(')"/>
        <xsl:choose>
          <xsl:when test="contains($st,' ')">
            <xsl:value-of select="substring-before($st,' ')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$st"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="contains($use-s,' ')">
        <xsl:value-of select="substring-before($use-s, ' ')"/>
      </xsl:when>
      <xsl:when test="string-length($use-s) &gt; 0">
        <xsl:value-of select="$use-s"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
    Discard the first token and return the rest of the string.
    If the first token is also the last, return an empty string.
    -->
  <xsl:template name="get-remaining-tokens">
    <xsl:param name="s"/>
    <xsl:variable name="use-s">
      <xsl:value-of select="normalize-space($s)"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="starts-with($use-s,'(')">
        <xsl:variable name="n">
          <xsl:call-template name="find-closing-paren">
            <xsl:with-param name="s" select="$use-s"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="number($n) &lt; string-length($use-s)">
            <xsl:value-of select="substring($use-s,number($n)+1)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="first-tok">
          <xsl:call-template name="get-first-token">
            <xsl:with-param name="s" select="$use-s"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when
            test="string-length($use-s) &gt; string-length($first-tok)">
            <xsl:value-of
              select="normalize-space(substring-after($use-s,$first-tok))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
    Tries to find the highest priority operator in a string.
    This may mean making as many as four passes through the
    string, tokenizing each time. Obviously, this is not the
    world's most efficient operation. Returns 'NaN' if the
    operator is not found. If it is found, returns the
    distance of the first character in the operator from the
    end of the normalized string. -->
  <xsl:template name="find-operator">
    <xsl:param name="s"/>
    <xsl:param name="current-s"/>
    <xsl:param name="current-priority" select="1"/>
    <xsl:variable name="use-s">
      <xsl:choose>
        <xsl:when test="$current-s">
          <xsl:value-of select="normalize-space($current-s)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space($s)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="current-tok">
      <xsl:call-template name="get-first-token">
        <xsl:with-param name="s" select="$use-s"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="remaining-tok">
      <xsl:call-template name="get-remaining-tokens">
        <xsl:with-param name="s" select="$use-s"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when
        test="document('xgfdata.xml')/*/xgfd:operators/xgfd:operator[@priority =
              $current-priority and @symbol = $current-tok]">
        <!-- 1. The current token is an operator at the current priority level. -->
        <xsl:value-of select="string-length($use-s)"/>
      </xsl:when>
      <xsl:when test="string-length($remaining-tok) &gt; 0">
        <!-- 2. The current token is not an operator at the current priority
                level, but we still have more of the expression to examine. -->
        <xsl:call-template name="find-operator">
          <xsl:with-param name="s" select="$s"/>
          <xsl:with-param name="current-priority" select="$current-priority"/>
          <xsl:with-param name="current-s" select="$remaining-tok"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="number($current-priority) &lt; 5">
            <!-- 3. The current token is not an operator at the current priority
                    level, but we still have other priority levels to go through. -->
            <xsl:call-template name="find-operator">
              <xsl:with-param name="s" select="$s"/>
              <xsl:with-param name="current-priority"
                select="number($current-priority) + 1"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <!-- 4. The current token is not an operator at the current priority
                    level. This is the last token in the expression and the last
                    priority level. In short, we've failed to find an operator. -->
            <xsl:text>NaN</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
