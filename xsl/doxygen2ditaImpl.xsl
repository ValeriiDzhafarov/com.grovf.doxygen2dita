<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:service="user:service-functions"
  exclude-result-prefixes="xs xd service"
  version="2.0">
  
  <xsl:import href="genRefs.xsl"/>
  <xsl:import href="postProcessing.xsl"/>
  <xsl:import href="genTopics.xsl"/>
  <xsl:import href="serviceFunctions.xsl"/>

  <xsl:output 
    doctype-public="-//OASIS//DTD DITA Map//EN" 
    doctype-system="map.dtd"
    indent="yes"
  />
  
  <xsl:output name="map"
    doctype-public="-//OASIS//DTD DITA Map//EN" 
    doctype-system="map.dtd"
    indent="yes"
  />
  
  <xsl:output name="refTopic"
    doctype-public="-//OASIS//DTD DITA Reference//EN" 
    doctype-system="reference.dtd"
    indent="no"
  />
  
  <xsl:output name="topic"
    doctype-public="-//OASIS//DTD DITA Topic//EN" 
    doctype-system="topic.dtd"
    indent="no"
    
  />
  
  <xsl:variable name="compoundKinds" as="xs:string+"
    select="('page', 
             'file', 
             'dir', 
             'class', 
             'struct', 
             'union', 
             'interface',
             'protocol',
             'category',
             'exception',
             'group',
             'example',
             'namespace')"
  />
  
  <xsl:variable name="compoundKindsToUse" as="xs:string+"
    select="(
      'page', 
      'file', 
      'dir', 
      'class', 
      'struct', 
      'union', 
      'interface',
      'protocol',
      'category',
      'exception',
      'group',
      'example',
      'namespace'
    )"
  />

  <xsl:template match="/">
    <xsl:if test="$doDebug">
      <xsl:message> + [INFO] Doxygen XML-to-DITA tranform...</xsl:message>
      <xsl:message> + [INFO] Output directory=<xsl:value-of select="$outdir"/> <xsl:value-of select="namespace-uri()" /> </xsl:message>
    </xsl:if>
    
    <xsl:apply-templates/>
    
  </xsl:template>
  
  
  
  <xsl:template match="doxygenindex">


    <!--Generate topics with incomplete Hrefs. incomplete_href = id from original XML file -->
    <xsl:variable name="ditaTopics"  as="element()+">  
      <ditaTopics>
        <xsl:apply-templates mode="generateTopics" select="."/>
      </ditaTopics>
    </xsl:variable> 
    
    <xsl:if test="$doDebug">
      <xsl:message> ditaTopics = <xsl:copy-of select="$ditaTopics"/> </xsl:message>
    </xsl:if>

    <!-- Collect id and their full href pathes -->
    <xsl:variable name="idHrefMap" as="element()+">     
      <idHrefMap>
        <xsl:apply-templates mode="collectTopicIds" select="$ditaTopics"/>     
      </idHrefMap>
    </xsl:variable>     

    <xsl:if test="$doDebug">  
      <xsl:message> idHrefMap = <xsl:copy-of select="$idHrefMap"/> </xsl:message>
    </xsl:if>
    
    <!-- Substitude incomplect href  in dita docs with full href pathes-->
    <xsl:variable name="ditaTopicsOut" as="element()+"> 
      <xsl:apply-templates mode="substIncompleteHrefs" select="$ditaTopics">
        <xsl:with-param name="idHrefMap" select="$idHrefMap" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable> 
    
    <xsl:if test="$doDebug">  
      <xsl:message> ditaTopicsOut = <xsl:copy-of select="$ditaTopicsOut"/> </xsl:message>
    </xsl:if>
    
    
    <!-- Print out Dita Topics-->
    <xsl:for-each select="$ditaTopicsOut/topic">
      <xsl:result-document href="{service:genDitaTopicRelPath(@id)}" format="topic">
        <xsl:copy-of select="."/>
      </xsl:result-document>
    </xsl:for-each>
        
    <map>
      <title><xsl:value-of select="$mapTitle"/></title>
      <topicgroup outputclass="pubbody" > 
        <xsl:apply-templates mode="generateRefs" select="."/>
      </topicgroup>   
    </map>
   
  </xsl:template>
  
</xsl:stylesheet>