<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="xs xd"
  version="2.0">
  
  <xsl:import href="doxygen2ditaImpl.xsl"/>

  <!-- Output directory to write result files to. -->
  <xsl:param name="outdir" as="xs:string" select="'./'"/> 
  <xsl:param name="mapTitle" as="xs:string" select="'API Documentation'"/>
  <xsl:param name="doDebug" as="xs:boolean" select="true()"/>
  
  <xsl:param name="internalAudience" as="xs:string" select="'internal'"/>
  <xsl:param name="unknown_ref" as="xs:string" select="'__unknown_ref__'"/>
  
</xsl:stylesheet>