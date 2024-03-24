<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:service="user:service-functions"
  exclude-result-prefixes="xs xd service"
  version="2.0">
  
  <!-- Append underscore if refId starts with a digit -->
  <xsl:function name="service:updateCompoundId" as="xs:string">
    <xsl:param name="origRefId" as="xs:string"/>
    <xsl:variable name="refId" as="xs:string" select="
      if(matches($origRefId, '^[0-9].*$')) 
        then concat('_',$origRefId) 
      else $origRefId
    "/>    
    <xsl:sequence select="$refId"/>
  </xsl:function>
    
  <xsl:function name="service:getLabelForKind" as="xs:string">
    <xsl:param name="kind" as="xs:string"/>
    <xsl:sequence select="service:getLabelForKind($kind, true())"/>
  </xsl:function>
  
  <xsl:function name="service:getLabelForKind" as="xs:string">
    <xsl:param name="kind" as="xs:string"/>
    <xsl:param name="plural" as="xs:boolean"/>
    
    <xsl:variable name="kinds" as="xs:string+"
      select="(
       'class', 
       'struct', 
       'namespace', 
       'file', 
       'dir',
       'protected-attrib',
       'public-attrib',
       'public-func',
       'protected-func',
       'variable',
       'function',
       'union',
       'enum',
       'function',
       'interface',
       'typedef',
       'define',
       'protocol',
       'example',
       'category',
       'exception',
       'group',
       'xxx'
      )"
    />
    <xsl:variable name="labelsPlural" as="xs:string+"
      select="(
       'Classes', 
       'Data Structures', 
       'Namespaces', 
       'Files', 
       'Directories',
       'Protected Attributes',
       'Public Attributes',
       'Public Functions',
       'Protected Functions',
       'Properties',
       'Functions',
       'Unions',
       'Enumeration Types',
       'Functions',
       'Interfaces',
       'Typedefs',
       'Macro Definitions',
       'Protocols',
       'Examples',
       'Categories',
       'Exceptions',
       'Groups',
       'XXXs'
      )"
    />
    <xsl:variable name="labelsSingular" as="xs:string+"
      select="(
        'Class', 
        'Data Structure', 
        'Namespace', 
        'File', 
        'Directory',
        'Protected Attribute',
        'Protected Attribute',
        'Public Function',
        'Protected Function',
        'Property',
        'Function',
        'Union',
        'Enumeration Type',
        'Function',
        'Interface',
        'Typedef',
        'Macro Definition',
        'Protocol',
        'Example',
        'Category',
        'Exception',
        'Group',
        'XXX'
      )"
    />
    <xsl:variable name="p" as="xs:integer*"
      select="index-of($kinds, $kind)"
    />
    <xsl:variable name="label" as="xs:string?"
      select="if ($p) 
                 then 
                   if ($plural) then $labelsPlural[$p] else $labelsSingular[$p]
                 else ()"
    />
    <xsl:variable name="result"
      select="if ($label)
                 then $label
                 else concat('No label for kind ', $kind)"
    />
    <xsl:sequence select="$result"/>
  </xsl:function>
  
  <xsl:function name="service:getLabelForSectiondef" as="xs:string">
    <xsl:param name="kind" as="xs:string"/>
    <xsl:param name="plural" as="xs:boolean"/>
    
    <xsl:variable name="kinds" as="xs:string+"
      select="(
        'user-defined',
        'public-type', 
        'public-func',
        'public-attrib',
        'signal',
        'property',
        'event',
        'public-static-func',
        'public-static-attrib',
        'protected-type',
        'protected-func',
        'protected-attrib',
        'protected-slot',
        'protected-static-func',
        'protected-static-attrib',
        'private-type',
        'private-func',
        'private-attrib',
        'private-slot',
        'private-static-func',
        'private-static-attrib',
        'friend',
        'define',
        'typedef',
        'enum',
        'func',
        'var'
      )"
    />
    <xsl:variable name="labelsPlural" as="xs:string+"
      select="(
        'User-defined',
        'Public types', 
        'Public functions',
        'Public attributes',
        'Signals',
        'Properties',
        'Events',
        'Public-static functions',
        'Public-static attributes',
        'Protected types',
        'Protected functions',
        'Protected attributes',
        'Protected slots',
        'Protected-static functions',
        'Protected-static attributes',
        'Private types',
        'Private functions',
        'Private attributes',
        'Private slots',
        'Private-static functions',
        'Private-static attributes',
        'Friends',
        'Macros',
        'Typedefs',
        'Enums',
        'Functions',
        'Variables'
      )"
    />
    <xsl:variable name="labelsSingular" as="xs:string+"
      select="(
        'User-defined',
        'Public type', 
        'Public function',
        'Public attribute',
        'Signal',
        'Property',
        'Event',
        'Public-static function',
        'Public-static attribute',
        'Protected type',
        'Protected function',
        'Protected attribute',
        'Protected slot',
        'Protected-static function',
        'Protected-static attribute',
        'Private type',
        'Private function',
        'Private attribute',
        'Private slot',
        'Private-static function',
        'Private-static attribute',
        'Friend',
        'Macro',
        'Typedef',
        'Enum',
        'Function',
        'Variable'
      )"
    />
    <xsl:variable name="p" as="xs:integer*"
      select="index-of($kinds, $kind)"
    />
    <xsl:variable name="label" as="xs:string?"
      select="if ($p) 
      then 
      if ($plural) then $labelsPlural[$p] else $labelsSingular[$p]
      else ()"
    />
    <xsl:variable name="result"
      select="if ($label)
      then $label
      else concat('No label for kind ', $kind)"
    />
    <xsl:sequence select="$result"/>
  </xsl:function>
  
  <xsl:function name="service:getLabelForInner" as="xs:string+">
    <xsl:param name="innerName" as="xs:string"/>
    <xsl:param name="labelType" as="xs:string"/>
    
    <xsl:variable name="kinds"    as="xs:string+" select="('innerdir', 'innerfile', 'innerclass', 'innernamespace', 'innerpage', 'innergroup')"/>
    
    <xsl:variable name="default"  as="xs:string" select="concat('No label for kind  ', $innerName)"/>
    
    <xsl:variable name="labelMap" as="element()+">
      <labelMap>    
        <variable key="outputclass"> <xsl:value-of select="string-join($kinds,', ')"/>  </variable>
        <variable key="title"> Inner directories, Inner files, Inner classes, Inner namespaces, Inner pages, Inner groups </variable>
      </labelMap>
    </xsl:variable>
    
    <xsl:variable name="mapHandleResult" as="xs:string*" select="tokenize($labelMap/variable[@key=$labelType],', ')[index-of($kinds,$innerName)]"/>
    
    <xsl:sequence select=" if(empty($mapHandleResult)) then $default else $mapHandleResult"/> 

  </xsl:function>
  
  <xsl:function name="service:convFstInUpCase" as="xs:string">
    <xsl:param name="in" as="xs:string"/>
    <xsl:sequence select="concat(upper-case(substring($in,1,1)),substring($in,2))"/>
  </xsl:function>
  
  <xsl:function name="service:getIntroTextForKind" as="node()*">
    <xsl:param name="kind" as="xs:string"/>
    <xsl:variable name="kinds" as="xs:string+"
      select="('class', 
               'struct', 
               'namespace', 
               'file', 
               'dir',
               'protected-attrib',
               'public-func',
               'protected-func',
               'variable',
               'function'
               )"
    />
    <xsl:variable name="descriptors" as="xs:string+"
      select="('classes', 
               'data structures', 
               'namespaces', 
               'files', 
               'directories',
               'protected attributes',
               'public member functions',
               'protected functions',
               'properties',
               'functions'
               )"
    />
    <xsl:variable name="p" as="xs:integer*"
      select="index-of($kinds, $kind)"
    />
    <xsl:variable name="descriptor" as="xs:string?"
      select="if ($p) 
                 then $descriptors[$p]
                 else $kind"
    />
    <xsl:variable name="result" as="node()*"
    >
      <xsl:text>Here is a list of all </xsl:text>
      <xsl:value-of select="$descriptor"/>
      <xsl:text> with brief descriptions.</xsl:text>
    </xsl:variable>
    <xsl:sequence select="$result"/>
  </xsl:function>
  
  <xsl:function name="service:getMemberTypeForSectionType" as="xs:string?">
    <xsl:param name="kind" as="xs:string"/>
    <xsl:variable name="sectionKinds" as="xs:string+" 
      select="('enum', 'define', 'typedef', 'func', 'public-func', 'user-defined')"
    />
    <xsl:variable name="memberKinds" as="xs:string+"
      select="('enum', 'define', 'typedef', 'function', 'function', 'unknown')"
    />
    <xsl:variable name="p" as="xs:integer*"
      select="index-of($sectionKinds, $kind)"
    />
    <xsl:variable name="result" as="xs:string?"
      select="$memberKinds[position() = $p]"
    />
    <xsl:sequence select="if ($result) then $result else 'unknown'"/>
  </xsl:function>
  
  <xsl:function name="service:isNotEmptyElements" as="xs:boolean">
    <xsl:param name="elems" as="element()*"/>
    <xsl:variable name="result" as="xs:boolean" select="some $elem in $elems satisfies normalize-space($elem) or $elem/*"/>
    <xsl:sequence select="$result"/>
  </xsl:function>
  
  <!-- That and next one templates make inserting of element() content from another (not current) XML file -->
  <xsl:template name="service:insertOtherDocNode">
    <xsl:param name="refid" as="xs:string"/>
    <xsl:param name="targetNodePath" as="xs:string"/>
    
    <xsl:variable name="base" as="xs:string" select="base-uri(.)"/>
    
    <xsl:variable name="anotherDocPath" as="xs:string"
      select="replace(base-uri(.), '[/\\][a-zA-Z0-9_\-]*.xml$', concat('/',@refid, '.xml'))"/>
    
    <xsl:variable name="anotherDoc" as="document-node()?"
      select="document($anotherDocPath)"/>
    
    <xsl:apply-templates select="$anotherDoc" mode="service:recursiveFinder">
      <xsl:with-param name="targetNodePath" select="$targetNodePath" tunnel="yes"/>
    </xsl:apply-templates>    
    
  </xsl:template>  

  <xsl:template mode="service:recursiveFinder" match="element()">
    <xsl:param name="targetNodePath"  as="xs:string"  tunnel="yes"/>
    <xsl:param name="currentNodePath" as="xs:string"  select="concat('/',name())"/>
    
    <xsl:variable name="remainNodePath" as="xs:string" select="replace($targetNodePath, concat('^',$currentNodePath), '')"/>
    <xsl:variable name="nextNodePath"   as="xs:string" select="tokenize($remainNodePath,'/')[2]"/>
    
    <xsl:choose>
      <xsl:when test="$remainNodePath=concat('/',$nextNodePath)"> 
        <xsl:apply-templates select="*[name()=$nextNodePath]"/>    
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[name()=$nextNodePath]" mode="service:recursiveFinder">
          <xsl:with-param name="currentNodePath" select="concat($currentNodePath, '/' , $nextNodePath)"/>
        </xsl:apply-templates>        
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>
  
  <xsl:function name="service:genDitaTopicRelPath" as="xs:string">
    <xsl:param name="refid" as="xs:string"/>
    <xsl:sequence select="concat('./topics/', $refid, '.dita')"/>
  </xsl:function>

</xsl:stylesheet>
