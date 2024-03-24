<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:service="user:service-functions"

  exclude-result-prefixes="xs xd service"
  version="2.0">
  
  <!--DoxygenType in index.xsd-->
  <xsl:template mode="generateRefs" match="doxygenindex">
    <xsl:variable name="context" as="element()" select="."/>
    
    <xsl:for-each select="$compoundKindsToUse">
      <xsl:variable name="kind" as="xs:string" select="."/>      
      <xsl:variable name="kindsToMatch" as="xs:string+"
        select="if ($kind = 'struct') 
                   then ($kind, 'union') 
                   else ($kind)"
      />
      <xsl:variable name="topicURI" as="xs:string" select="concat('topics/', $kind, '.dita')"/>
      <xsl:variable name="resultURI" as="xs:string"
        select="concat($outdir, $topicURI)"
      />
      
      <xsl:variable name="kindExisted" as="xs:boolean"
        select="if (count($context/compound[@kind = $kind])>0) then true() else false()"
      />
      
      <xsl:if test="$doDebug">          
        <xsl:message> + [DEBUG] generateTopicrefs kind:         <xsl:value-of select="$kind"/>          </xsl:message>
        <xsl:message> + [DEBUG] generateTopicrefs kindsToMatch: <xsl:value-of select="$kindsToMatch"/>  </xsl:message>
        <xsl:message> + [DEBUG] generateTopicrefs topicURI:     <xsl:value-of select="$topicURI"/>      </xsl:message>        
        <xsl:message> + [DEBUG] generateTopicrefs outdir:       <xsl:value-of select="$outdir"/>      </xsl:message>        
        <xsl:message> + [DEBUG] generateTopicrefs resultURI:    <xsl:value-of select="$resultURI"/>     </xsl:message>
      </xsl:if>      
      
        <xsl:choose>
          <xsl:when test="$kindExisted=false() and $doDebug">
            <xsl:message> [INFO] generateTopicrefs kind:  <xsl:value-of select="$kind"/> not existed in presented XML files. Skip it  </xsl:message>
          </xsl:when>          
          <xsl:when test="$kind = 'page'">
            <xsl:apply-templates mode="#current" select="$context/compound[@kind = $kind]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:result-document href="{$resultURI}" format="topic">
              <topic id="{$kind}">
                <title>
                  <xsl:value-of select="service:getLabelForKind($kind)"/>
                </title>
                <body>
                  <p><xsl:sequence select="service:getIntroTextForKind($kind)"/></p>
                </body>
              </topic>
            </xsl:result-document>
            <topicref href="{$topicURI}" outputclass="compoundset {.}">
              <xsl:apply-templates mode="#current" select="$context/compound[@kind = $kindsToMatch]"/>
            </topicref>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    
    
  </xsl:template>

  <!--CompoundType in index.xsd-->
  <xsl:template mode="generateRefs" match="compound">
    <topicref href="{service:genDitaTopicRelPath(@refid)}"/>
  </xsl:template>
 
 
</xsl:stylesheet>