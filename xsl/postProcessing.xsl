<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:service="user:service-functions"
  exclude-result-prefixes="xs service"
  version="2.0">

  <xsl:template match="element()" mode="collectTopicIds">
    <xsl:param name="upperNodeHref" select="''" as="xs:string"/>
    
    <xsl:choose>
      <xsl:when test="name()='topic'"> <!--Upper topic level-->
        <xsl:variable name="nodeHref" select="concat(@id,'.dita#',@id)"/>        
        <entry key="{@id}" value="{$nodeHref}"/>
        <xsl:apply-templates mode="#current">
          <xsl:with-param name="upperNodeHref" select="$nodeHref"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@id">
        <xsl:variable name="nodeHref" select="concat($upperNodeHref,'/',@id)"/>        
        <entry key="{@id}" value="{$nodeHref}"/>
        <xsl:apply-templates mode="#current">
          <xsl:with-param name="upperNodeHref" select="$upperNodeHref"/><!--Inseide the topic There is not requirement to use  the full hierarhical path. Only path to topic -->
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="#current">
          <xsl:with-param name="upperNodeHref" select="$upperNodeHref"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>  


  <xsl:template match="@*|node()" mode="substIncompleteHrefs">
    <xsl:param name="idHrefMap" tunnel="yes" as="element()+"/>
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@*|node()">
        <xsl:with-param name="idHrefMap" tunnel="yes" select="$idHrefMap"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="service:findAppropriateHref" as="xs:string">
    <xsl:param name="fullHrefList" as="element()"/>
    <xsl:param name="xref"         as="element()"/>
    
    <xsl:variable name="topicId"  select="$xref/ancestor::topic/@id" as="xs:string"/>
    <xsl:variable name="sameIdNum" select="count($fullHrefList/entry)" as="xs:integer"/>
    
    <xsl:choose>
      
      <xsl:when test="$sameIdNum=1">
        <xsl:sequence><xsl:value-of select="$fullHrefList/entry[1]/@value"/></xsl:sequence>
      </xsl:when>
      
      <xsl:when test="$sameIdNum=0">
        <xsl:message> [WARN] for id[<xsl:value-of select="$xref/@href"/>] topic[<xsl:value-of select="$topicId"/>]
there is not a href
        </xsl:message>
        <xsl:sequence><xsl:value-of select="concat($unknown_ref,$xref/@href)"/></xsl:sequence>
      </xsl:when>      
      
      <xsl:otherwise>
        <xsl:variable name="entryInsideSameTopic" as="element()*" 
          select="$fullHrefList/entry[matches(@value,concat('^',$topicId,'.dita.*$'))]"/>
        <xsl:choose>
          <xsl:when test="count($entryInsideSameTopic)=1">
            <xsl:sequence><xsl:value-of select="$entryInsideSameTopic[1]/@value"/></xsl:sequence>
          </xsl:when>
          <xsl:when test="count($entryInsideSameTopic)>1">
            <xsl:message> [WARN] for id[<xsl:value-of select="$xref/@href"/>] topic[<xsl:value-of select="$topicId"/>]
 there is a few declaration in the same topics. Got first entry. See below  </xsl:message>
            <xsl:message> <xsl:copy-of select="$entryInsideSameTopic"/>  </xsl:message>  
            <xsl:sequence><xsl:value-of select="$entryInsideSameTopic[1]/@value"/></xsl:sequence>
          </xsl:when>
          <xsl:when test="count($entryInsideSameTopic)=0">
            <xsl:message> [INFO] for id[<xsl:value-of select="$xref/@href"/>] topic[<xsl:value-of select="$topicId"/>]
 there is a few declaration in the different topics. See below. Got first entry. </xsl:message>            
            <xsl:message> <xsl:copy-of select="$fullHrefList"/>  </xsl:message>  
            <xsl:sequence><xsl:value-of select="$fullHrefList/entry[1]/@value"/></xsl:sequence>
          </xsl:when>          
        </xsl:choose>                
      </xsl:otherwise>     
      
    </xsl:choose>   
 
  </xsl:function>
  
  <xsl:template match="xref" mode="substIncompleteHrefs">
    <xsl:param name="idHrefMap" as="element()+"   tunnel="yes"/>
    <xsl:variable name="fullHrefs" as="element()" >
      <fullHrefs>
        <xsl:copy-of select="$idHrefMap/entry[@key=(current()/@href)]"/>
      </fullHrefs>
    </xsl:variable>
         
    <xsl:element name="xref">
      <xsl:attribute name="href" select="service:findAppropriateHref($fullHrefs,.)"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:element>
    
  </xsl:template>
  
  <xsl:template match="text()" mode="collectTopicIds"/>

  
</xsl:stylesheet>