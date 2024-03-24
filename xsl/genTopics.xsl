<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:service="user:service-functions"
  exclude-result-prefixes="xsl xs service"
  version="2.0"
  >

  <xsl:template match="doxygenindex" mode="generateTopics">
     <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="compound" mode="generateTopics">
    <xsl:variable name="inputFilePath" as="xs:string"
      select="replace(base-uri(.), 'index.xml', concat(@refid, '.xml'))"/>
    
    <xsl:choose>
      <xsl:when test="doc-available($inputFilePath)">

        <xsl:variable name="inputXMLDoc" select="document($inputFilePath)" as="document-node()?"/>
        <xsl:apply-templates select="$inputXMLDoc" mode="generateTopics"/>          

      </xsl:when>
      <xsl:otherwise>
        <xsl:message> [WARN] Source not found <xsl:value-of select="$inputFilePath"/> Document: <xsl:value-of select="base-uri()"/> 
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/" mode="generateTopics">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="doxygen" mode="generateTopics">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="compounddef" mode="generateTopics">
    <xsl:text>&#10;</xsl:text>
    <topic id="{@id}">
      <xsl:call-template name="generateCompounddefTitle"/>
      <xsl:text>&#10;</xsl:text>
      
      <body>
        <xsl:call-template name="generateCompounddefDescription"/> 
        <xsl:call-template name="generateCompounddefIncludes"/>
        <xsl:call-template name="generateCompoundTypeSpecifier"/>
        <xsl:call-template name="generateCompounddefInners"/>
        
        <xsl:for-each select="sectiondef">
          <xsl:apply-templates select="."/>
        </xsl:for-each>    
   
      </body>
    </topic>
  </xsl:template>

  <xsl:template name="generateCompounddefTitle">
    <xsl:variable name="actualTitle">
      <xsl:choose>
        <xsl:when test="service:isNotEmptyElements(title)">
          <xsl:value-of select="title"/>
        </xsl:when>
        <xsl:when test="service:isNotEmptyElements(compoundname)">
          <xsl:value-of select="compoundname"/>
        </xsl:when>
        <xsl:otherwise>!!!Unknown</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <title>
      <xsl:value-of select="$actualTitle"/>
    </title>
  </xsl:template>

  <xsl:template name="generateCompounddefDescription">
    <xsl:variable name="topicDescrElems" as="element()*"
      select="briefdescription, detaileddescription, inbodydescription"/>
    <xsl:if test="service:isNotEmptyElements($topicDescrElems)">
      <xsl:text>&#10;</xsl:text>
      <section>
        <title>Description</title>
        <xsl:apply-templates select="$topicDescrElems"/>
      </section>
    </xsl:if>
  </xsl:template>

  <xsl:template name="generateCompounddefIncludes">
    <xsl:if test="service:isNotEmptyElements(includes)">
      <xsl:text>&#10;</xsl:text>
      <section outputclass="includes">
        <codeblock>
          <xsl:for-each select="includes">
            <xsl:apply-templates mode="incType" select="." />
            <xsl:if test="count(following-sibling::includes)"> 
              <xsl:text>&#10;</xsl:text>
            </xsl:if>
          </xsl:for-each>
        </codeblock>
      </section>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="generateCompoundTypeSpecifier">
    <xsl:variable name="needSpecifier" as="xs:boolean" select="@kind = ('class', 'struct', 'union')"/>
    <xsl:if test="$needSpecifier">
      <xsl:text>&#10;</xsl:text>
      <section>
        <title>Declaration</title>
        <codeblock outputclass="type-declaration {@kind}">
          <xsl:if test="service:isNotEmptyElements(templateparamlist)">
            <xsl:apply-templates select="templateparamlist"/>
            <xsl:text>&#10;</xsl:text>
          </xsl:if>
          <xsl:apply-templates select="@kind" mode="handleTypeAtrribute"/>
          <varname><xsl:value-of select="compoundname"/></varname>
          <xsl:text> </xsl:text>
          <xsl:apply-templates select="@final" mode="handleTypeAtrribute"/>
          <xsl:for-each select="basecompoundref">
            <xsl:if test="count(preceding-sibling::basecompoundref)=0">
              <xsl:text>: </xsl:text>        
            </xsl:if>
            <xsl:apply-templates mode="compoundRefType" select="."/>           
            <xsl:if test="count(following-sibling::basecompoundref)>0">
              <xsl:text>, </xsl:text>        
            </xsl:if>            
          </xsl:for-each>
          <xsl:text>;</xsl:text>
        </codeblock>
      </section>
    </xsl:if>
  </xsl:template>

  <xsl:template name="generateCompounddefInners">
    <xsl:variable name="context" select="." as="element()"/>

    <xsl:variable name="innerNames" as="xs:string*">
      <xsl:for-each select="element()[matches(name(),'^inner.*$')]">
        <xsl:value-of select="name(.)"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="uniqInnerNames" as="xs:string*" select="distinct-values($innerNames)"/>
    
    <xsl:for-each select="$uniqInnerNames">
      <xsl:text>&#10;</xsl:text>
      <section outputclass="{service:getLabelForInner(.,'outputclass')}">
        <title><xsl:value-of select="service:getLabelForInner(.,'title')"/></title>
        <xsl:apply-templates select="$context/*[name() = current()]"/>       
      </section>
    </xsl:for-each>    
  </xsl:template>
  
  <xsl:template match="element()[matches(name(.),'^inner.*$')]">
    <xsl:text>&#10;</xsl:text>
    <sectiondiv outputclass="refType {@prot}">

     <xsl:value-of select="@prot"/><xsl:text> </xsl:text>
     <xsl:apply-templates select="." mode="refType"/><xsl:text>;</xsl:text>
    
     <xsl:call-template name="service:insertOtherDocNode">
      <xsl:with-param name="refid"  select="@refid"/> 
      <xsl:with-param name="targetNodePath" select="'/doxygen/compounddef/briefdescription'"/> 
     </xsl:call-template>
    </sectiondiv>
  </xsl:template>  
  
  <!--sectiondefType in compound.xsd-->
  <xsl:template match="sectiondef">
    <xsl:text>&#10;</xsl:text>
    <section outputclass="sectiondef {@kind}">
      <title><xsl:value-of select="service:getLabelForSectiondef(@kind, true())"/></title>
      <xsl:apply-templates select="memberdef" mode="reusePart"/>
    </section>
  </xsl:template>  

  <xsl:template match="memberdef" mode="reusePart">
    <xsl:text>&#10;</xsl:text>
    <div id="{@id}">
      <xsl:apply-templates select="." mode="specificPart"/>
      <xsl:apply-templates select="*[contains(name(.),'description')]"/>
      <xsl:apply-templates select="." mode="generateReferences"/>
      <xsl:apply-templates select="." mode="generateReferencedBy"/>
    </div>    
  </xsl:template>  

  <xsl:template match="memberdef[@kind='define']" mode="specificPart">
    <codeblock outputclass="type-declaration {@kind}">
      <xsl:text>#define </xsl:text>
      <parmname><xsl:value-of select="name"/></parmname>
      <xsl:if test="param">
        <xsl:text>(</xsl:text>
          <xsl:apply-templates select="." mode="generateParamList"/>
        <xsl:text>)</xsl:text>   
      </xsl:if>     
      <xsl:if test="service:isNotEmptyElements(initializer)">
        <xsl:text> </xsl:text>
        <xsl:if test="count(tokenize(initializer))>1">
          <xsl:text>\&#10;</xsl:text>
        </xsl:if>
        <xsl:apply-templates select="initializer" mode="linkedTextType"/>
      </xsl:if>
    </codeblock>
  </xsl:template>
  

  <xsl:template match="memberdef[@kind='variable']" mode="specificPart">
    <codeblock outputclass="type-declaration {@kind}">
      <xsl:apply-templates select="@* except (@kind, @id, @prot)" mode="handleTypeAtrribute"/>
      <xsl:apply-templates mode="linkedTextType" select="type"/><xsl:text> </xsl:text>
      <varname><xsl:value-of select="name"/></varname>
      <xsl:value-of select="argsstring"/><xsl:text> </xsl:text>
      <xsl:apply-templates mode="linkedTextType" select="initializer"/>
      <xsl:text>;</xsl:text>
    </codeblock>
  </xsl:template>

  <xsl:template match="memberdef[@kind='typedef']" mode="specificPart">
    <codeblock outputclass="type-declaration {@kind}">
      <xsl:if test="service:isNotEmptyElements(templateparamlist)">
        <xsl:apply-templates select="templateparamlist"/>          
        <xsl:text>&#10;</xsl:text>
      </xsl:if>
      <!--<xsl:apply-templates select="@kind" mode="handleTypeAtrribute"/>-->
      <xsl:choose>
        <xsl:when test="definition and tokenize(normalize-space(definition))[1]='using'">
          <xsl:text>using </xsl:text>
          <varname><xsl:value-of select="name"/></varname><xsl:text> = </xsl:text> 
          <xsl:value-of select="type"/><xsl:text>; </xsl:text>          
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>typedef </xsl:text>
          <xsl:value-of select="type"/><xsl:text> </xsl:text>        
          <varname><xsl:value-of select="name"/></varname><xsl:text>; </xsl:text> 
        </xsl:otherwise>
      </xsl:choose>    
    </codeblock>
  </xsl:template>

  <xsl:template match="memberdef[@kind='enum']" mode="specificPart">
    <!--enum name (optional) : type { enumerator = constant-expression , enumerator = constant-expression , ... } -->    
      <codeblock outputclass="type-declaration {@kind}">
        <xsl:apply-templates select="@kind" mode="handleTypeAtrribute"/>
        <xsl:if test="name and not(starts-with(name,'@'))"> <!-- For unnamed enum doxygen sets names in format @<number> -->
          <varname><xsl:value-of select="name"/></varname><xsl:text> </xsl:text>
        </xsl:if>
        <xsl:apply-templates select="@strong" mode="handleTypeAtrribute"/>
        <xsl:if test="service:isNotEmptyElements(type)">
          <xsl:text> : </xsl:text><xsl:apply-templates select="type" mode="refTextType"/><xsl:text> </xsl:text>        
        </xsl:if>
        <xsl:if test="service:isNotEmptyElements(enumvalue)">
          <xsl:text>{&#10;</xsl:text>
          <xsl:for-each select="enumvalue">
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="." mode="noDescription"/> 
            <xsl:text>;&#10;</xsl:text>
          </xsl:for-each>
          <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:text>; </xsl:text>        
      </codeblock>
      <xsl:apply-templates select="." mode="enumValuesDescr"/>
  </xsl:template>

  <xsl:template match="memberdef[@kind='function']" mode="specificPart">
    <codeblock outputclass="type-declaration {@kind}">
      <xsl:if test="service:isNotEmptyElements(templateparamlist)">
        <xsl:apply-templates select="templateparamlist"/>          
        <xsl:text>&#10;</xsl:text>
      </xsl:if>
      <xsl:apply-templates select="@* except(@kind,@id,@prot)" mode="handleTypeAtrribute"/> 
      <xsl:apply-templates select="type" mode="linkedTextType"/><xsl:text> </xsl:text>
      <varname><xsl:value-of select="name"/></varname><xsl:text>(</xsl:text>
      <xsl:apply-templates select="." mode="generateParamList"/>
      <xsl:text>);</xsl:text>
    </codeblock>
  </xsl:template>

  <!--enumvalueType in compound.xsd-->
  <xsl:template match="enumvalue" mode="noDescription">
    <varname id="{@id}"><xsl:value-of select="name"/></varname><xsl:text> </xsl:text>
    <xsl:apply-templates select="initializer" mode="linkedTextType"/> 
  </xsl:template>
  
  <xsl:template mode="enumValuesDescr" match="element()">
    <xsl:if test="enumvalue[service:isNotEmptyElements(briefdescription)]">  
      <table frame="none">
        <tgroup cols="2">
          <tbody>
           <xsl:for-each select="enumvalue">
             <row>
               <entry outputclass="enumvalue name"><xsl:value-of select="name"/></entry>
              <entry>
                 <xsl:apply-templates select="briefdescription"/>
               </entry>
             </row>
          </xsl:for-each>
         </tbody>
        </tgroup>
      </table>      
    </xsl:if>
  </xsl:template>   
 
  <!--descriptionType in compound.xsd-->
  <xsl:template match="*[contains(name(.),'description')]">
    
    <xsl:param name="wrapTag" as="xs:string" select="'div'" tunnel="yes"/>
    <xsl:if test="service:isNotEmptyElements(.)">
      <xsl:element name="{$wrapTag}">
        <xsl:attribute name="outputclass" select="concat($wrapTag,' ',name(.))"/>
        <xsl:if test="@id">
          <xsl:attribute name="id">
            <xsl:value-of select="@id"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="name(.) = 'internal'">
          <xsl:attribute name="audience">
            <xsl:value-of select="$internalAudience"/>
          </xsl:attribute>
        </xsl:if>
        
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:if>
    
  </xsl:template>
    
  <!--templateparamlistType in compound.xsd-->
  <xsl:template match="templateparamlist"> 
    <xsl:text>template&lt;</xsl:text>
    <xsl:apply-templates select="." mode="generateParamList"/>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>
 
  <xsl:template mode="generateParamList" match="element()">
    <xsl:for-each select="param"> 
      <xsl:if test="count(../param)>1 and not(../@kind='define')">
        <xsl:text>&#10; </xsl:text>
      </xsl:if> 
      <xsl:apply-templates select="."/>
      
      <xsl:if test="count(following-sibling::param)>0">
        <xsl:text>, </xsl:text>        
      </xsl:if>
      
      <xsl:if test="service:isNotEmptyElements(briefdescription)">
        <ph outputclass="param description">
          <xsl:text> /*** </xsl:text> <xsl:apply-templates select="briefdescription"/><xsl:text> */</xsl:text>
        </ph>
      </xsl:if>
      
      <xsl:if test="count(following-sibling::param)=0 and count(../param)>1 and not(../@kind='define')">
        <xsl:text>&#10;</xsl:text>
      </xsl:if> 
    </xsl:for-each>
  </xsl:template>
  

  <!--paramType in compound.xsd-->
  <xsl:template match="param"> 
    <xsl:if test="service:isNotEmptyElements(type)">
      <ph outputclass="type">
        <xsl:apply-templates mode="linkedTextType" select="type"/>
      </ph>
    </xsl:if>
    <xsl:if test="service:isNotEmptyElements(declname)">
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="declname" mode="linkedTextType"/>      
    </xsl:if>
    <xsl:if test="service:isNotEmptyElements(defname)">
      <xsl:apply-templates select="defname" mode="linkedTextType"/>      
    </xsl:if>
    <xsl:if test="service:isNotEmptyElements(defval)">
      <xsl:text> = </xsl:text>
      <ph outputclass="defval">
        <xsl:apply-templates mode="linkedTextType" select="defval"/>
      </ph>      
    </xsl:if>
  </xsl:template>
  
  <!--special description for param, as it in the codeblock-->
  <xsl:template match="param/briefdescription" priority="10"> 
    <xsl:value-of select="normalize-space(.)"/> 
  </xsl:template>
  
  <!--linkedTextType in compound.xsd-->
  <xsl:template mode="linkedTextType" match="element()">
    <ph outputclass="linkedTextType">
      <xsl:apply-templates mode="refTextType" select="element() | text()"/>
    </ph>
  </xsl:template>

  <!--compoundRefType in compound.xsd-->
  <xsl:template mode="compoundRefType" match="element()">
    <ph outputclass="compoundRefType">
      <xsl:if test="@virt='virtual'">
        <xsl:text>virtual </xsl:text>
      </xsl:if>
      <xsl:value-of select="@prot"/><xsl:text> </xsl:text>
      <xsl:apply-templates select="." mode="refTextType"/>      
    </ph>
  </xsl:template>
  
  <!--refTextType in compound.xsd.--> 
  <xsl:template mode="refTextType" match="element() | text()">
    <xsl:apply-templates select="." mode="refType"/>
  </xsl:template>

  <!--refType in compound.xsd.--> 
  <xsl:template mode="refType" match="element()">
    <xsl:choose>
      <xsl:when test="@refid">
        <xref href="{@refid}">
          <xsl:apply-templates/>
        </xref>       
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>        
  </xsl:template>

  <xsl:template mode="refType" match="text()">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <!--incType in compound.xsd-->
  <xsl:template mode="incType" match="element()"> 
    <ph outputclass="include">
      <xsl:text>#include </xsl:text> 
      <xsl:choose>
        <xsl:when test="@local='yes'">&quot;</xsl:when> <xsl:otherwise>&lt;</xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="." mode="refType"/>        
      <xsl:choose>
        <xsl:when test="@local='yes'">&quot;</xsl:when> <xsl:otherwise>&gt;;</xsl:otherwise>
      </xsl:choose>
    </ph>
  </xsl:template>


  
  <!--  Kinds vlues (got from compound.xsd): 
        see return author authors version since date <note> <warning> 
        pre post copyright invariant <remark>  <attention> <par> rcs  -->      
  <xsl:template match="simplesect">
    <div outputclass="simplesect {@kind}">
      <xsl:if test="service:isNotEmptyElements(title)"><lines outputclass="title"><xsl:apply-templates select="title"/></lines></xsl:if>
      <xsl:choose>
        <xsl:when test="@kind='par'">
          <xsl:apply-templates select="para"/>          
        </xsl:when>
        <xsl:when test="@kind='note'">
          <note type="note"> <xsl:apply-templates select="para"/></note>
        </xsl:when>        
        <xsl:when test="@kind='remark'">
          <note type="notice"> <xsl:apply-templates select="para"/></note>
        </xsl:when>        
        <xsl:when test="@kind='attention'">
          <note type="caution"> <xsl:apply-templates select="para"/></note>
        </xsl:when>        
        <xsl:when test="@kind='warning'">
          <note type="warning"><xsl:apply-templates select="para"/></note>
        </xsl:when> 
        <xsl:otherwise>
          <note type="other" outputclass="note other {@kind}">
            <ph outputclass="kind">[<xsl:value-of select="service:convFstInUpCase(@kind)"/>]</ph>
            <xsl:apply-templates select="para"/>
          </note>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>
   
  <xsl:template match="parblock">
    <p><xsl:apply-templates/></p>
  </xsl:template>
  
  <xsl:template match="para">
    <div><xsl:apply-templates/></div>
  </xsl:template>

  <!--docParamListType in compound.xsd-->
  <xsl:template match="parameterlist">
    <xsl:text>&#10;</xsl:text>
    <table frame="none">
      <tgroup cols="2">
        <colspec colname="c0" colwidth="auto"/>
        <colspec colname="c1" colwidth="auto"/>
        <tbody>
          <xsl:apply-templates select="parameteritem"/>     
        </tbody>
      </tgroup>
    </table>   
  </xsl:template>

  <!--docParamListItem in compound.xsd-->
  <xsl:template match="parameteritem">
    <row>
      <xsl:apply-templates select="parameternamelist | parameterdescription"/>
    </row>
  </xsl:template>

  <!--docParamNameList in compound.xsd-->
  <xsl:template match="parameternamelist">
    <entry>
      <xsl:if test="service:isNotEmptyElements(parametertype)">
        <xsl:apply-templates select="parametertype"/>
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="parametername"/>
    </entry>
  </xsl:template>

  <!--docParamType in compound.xsd-->
  <xsl:template match="parametertype">
    <xsl:apply-templates select="." mode="refTextType"/>
  </xsl:template>
    
  <!--docParamName in compound.xsd--> 
  <xsl:template match="parametername">
    <xsl:if test="@direction">
      <xsl:text>[</xsl:text><ph outputclass="parametername dir"><xsl:value-of select="@direction"/></ph><xsl:text>] </xsl:text>
    </xsl:if>
    <ph outputclass="parametername name"><xsl:apply-templates select="." mode="refTextType"/></ph> 
  </xsl:template>
  
  <!--wrap descriptionType in <pd> tags -->
  <xsl:template match="parameterdescription" priority="10"> 
    <entry>
      <xsl:apply-templates/>
    </entry>
  </xsl:template>
  
  <xsl:template match="orderedlist | variablelist"> 
    <ol><xsl:apply-templates/></ol>
  </xsl:template>  
  
  <xsl:template match="itemizedlist">
    <ul><xsl:apply-templates/></ul>
  </xsl:template>  
  
  <xsl:template match="listitem | varlistentry">
    <li><xsl:apply-templates/></li>
  </xsl:template>

  <xsl:template match="*[matches(name(.), '^sect[1-4]$')]">
    <div outputclass="{name()}" id="{@id}">
      <lines outputclass="title"><xsl:value-of select="title"/></lines>
      <xsl:apply-templates select="node() except(title)"/>
    </div>    
  </xsl:template>
  
  <xsl:template match="@*" mode="handleTypeAtrribute">
      <xsl:choose>
        <xsl:when test="name()='strong' and .='yes'">
          <ph outputclass="attribute {name()}">class</ph>
          <xsl:text> </xsl:text>
        </xsl:when>          
        <xsl:when test=".='no'"/> <!--do nothing-->        
        <xsl:when test=".='yes'">
          <ph outputclass="attribute {name()}"><xsl:value-of select="name()"/></ph>
          <xsl:text> </xsl:text>
        </xsl:when>
        <xsl:when test="name()='virt'">
          <xsl:if test=".='virtual'">
            <ph outputclass="attribute {name()}"><xsl:value-of select="."/></ph>
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <ph outputclass="attribute {name()}"><xsl:value-of select="."/></ph>
          <xsl:text> </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
  
  <!--referenceType in compound.xsd--> 

  <xsl:template match="memberdef" mode="generateReferencedBy">
    <xsl:if test="referencedby">
      <div>
        <lines outputclass="keyword referencedby">Referenced by:</lines>
        <xsl:apply-templates select="referencedby"/>
      </div>     
    </xsl:if>
  </xsl:template>
    
  <xsl:template match="memberdef" mode="generateReferences">
    <xsl:if test="references">
      <div>
        <lines outputclass="keyword references">References:</lines>
        <xsl:apply-templates select="references"/>
      </div>    
    </xsl:if>
  </xsl:template>
      
  <xsl:template match="references | referencedby">
    <!--convert to element of refType--> 
    <xsl:variable name="refTypeElem">
      <xsl:element name="refTypeElem">
        <xsl:attribute name="refid" select="@refid"/>
        <xsl:value-of select="text()"/>
        <xsl:value-of select="@compoundref"/>        
        <xsl:value-of select="@startline"/>
        <xsl:value-of select="@endline"/>           
      </xsl:element>
    </xsl:variable>
    <xsl:apply-templates select="$refTypeElem" mode="refType"/>
  </xsl:template>
  

  <xsl:template match="msc | tableofcontents">
    <xsl:message>[WARN] XSLT conversion rules doesn't support tag[<xsl:value-of select="name()"/>] yet. Document: <xsl:value-of select="base-uri()"/> </xsl:message>
  </xsl:template>
  
  <xsl:template match="linebreak">
    <lines/>
  </xsl:template>

  <xsl:template match="ref">
    <xsl:apply-templates mode="refType" select="."/>
  </xsl:template>  
  
  <xsl:template match="emphasis">
    <i><xsl:apply-templates/></i>
  </xsl:template>  
  
  <xsl:template match="bold">
    <b><xsl:apply-templates/></b>
  </xsl:template>
  
  <xsl:template match="computeroutput">
    <tt><xsl:apply-templates/></tt>
  </xsl:template>
  
  <xsl:template match="anchor">
    <ph id="{@id}"/>  
  </xsl:template>
  
  <xsl:template match="strike | s | del">
    <line-through><xsl:apply-templates/></line-through>
  </xsl:template>
  
  <xsl:template match="underline | ins">
    <u><xsl:apply-templates/></u>
  </xsl:template>
  
  <xsl:template match="verbatim">
    <codeblock xml:space="preserve"><xsl:apply-templates/></codeblock>
  </xsl:template>
  
  <xsl:template match="element()">
    <xsl:apply-templates/>    
  </xsl:template>
  
  <xsl:template match="text()">
    <xsl:value-of select="."/>
  </xsl:template>
  
</xsl:stylesheet>
