<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:service="user:service-functions"
  xmlns:svg="http://www.w3.org/2000/svg"
  
  exclude-result-prefixes="xs xd service svg"
  version="2.0">
  
  <xsl:param name="msc-quantum" as="xs:float" select="8"/>
  <xsl:param name="msc-max-w"   as="xs:float" select="180"/>
  <xsl:param name="msc-max-h"   as="xs:float" select="250"/>
  
  <xsl:param name="msc-font-size" as="xs:float" select="0.5"/>
  <xsl:param name="msc-w-rect"    as="xs:float" select="14"/>
  <xsl:param name="msc-w-space"   as="xs:float" select="1"/>
  <xsl:param name="msc-h-rect"    as="xs:float" select="1"/>
  <xsl:param name="msc-h-space"   as="xs:float" select="0.5"/>
   
  <xsl:variable name="w_rect"  as="xs:float" select="$msc-quantum * $msc-w-rect"/>
  <xsl:variable name="w_space" as="xs:float" select="$msc-quantum * $msc-w-space"/>
  <xsl:variable name="font-size"    as="xs:float" select="$msc-quantum * $msc-font-size"/>
  <xsl:variable name="h_rect"  as="xs:float" select="$msc-quantum * $msc-h-rect"/>
  <xsl:variable name="h_space" as="xs:float" select="$msc-quantum * $msc-h-space"/>
  
 
  <xsl:function name="service:change_symb_in_quads" as="xs:string*">
    <xsl:param name="in" as="xs:string*"/>
    <xsl:param name="open_symb" as="xs:string"/>
    <xsl:param name="close_symb" as="xs:string"/>
    <xsl:param name="symb4replace" as="xs:string"/>
    <xsl:param name="replacing_symb" as="xs:string"/>
    
    <xsl:variable name="out" as="xs:string*">
      <xsl:for-each select="$in">
        <xsl:value-of select="service:recursive_change_symb_in_quads(.,false(),$open_symb,$close_symb,$symb4replace,$replacing_symb)"/>     
      </xsl:for-each>    
    </xsl:variable>
        
    <xsl:sequence><xsl:copy-of select="$out"/></xsl:sequence>

  </xsl:function>

  <xsl:function name="service:recursive_change_symb_in_quads" as="xs:string*">
    <xsl:param name="in"        as="xs:string" />    
    <xsl:param name="opened"    as="xs:boolean"/>
    <xsl:param name="open_symb" as="xs:string"/>
    <xsl:param name="close_symb" as="xs:string"/>
    <xsl:param name="symb4replace" as="xs:string"/>
    <xsl:param name="replacing_symb" as="xs:string"/>
    
    <xsl:choose>
      <xsl:when test="not(contains($in,$open_symb) or contains($in,$close_symb) )">
        <xsl:sequence><xsl:value-of select="$in"/></xsl:sequence>
      </xsl:when>
      <xsl:when test="$opened">
        <xsl:variable name="string_before_close" select="substring-before($in,$close_symb)" as="xs:string*"/>
        <xsl:variable name="string_after_close"  select="substring-after($in,$close_symb)" as="xs:string*"/>
        
        <xsl:sequence>
          <xsl:value-of select="concat(
            replace($string_before_close,$symb4replace,$replacing_symb),
            $close_symb,
            service:recursive_change_symb_in_quads($string_after_close,false(),$open_symb,$close_symb,$symb4replace,$replacing_symb)
            )"/>
        </xsl:sequence>      
      </xsl:when>
      <xsl:when test="not($opened)">
        <xsl:variable name="string_before_open" select="substring-before($in,$open_symb)" as="xs:string*"/>
        <xsl:variable name="string_after_open"  select="substring-after($in,$open_symb)" as="xs:string*"/>
        <xsl:sequence>
          <xsl:value-of select="concat(
            $string_before_open,
            $open_symb,
            service:recursive_change_symb_in_quads($string_after_open,true(),$open_symb,$close_symb,$symb4replace,$replacing_symb)
            )"/> 
        </xsl:sequence>
      </xsl:when>      
    </xsl:choose>
   
  </xsl:function>
    
    
  <xsl:template match="msc" >
    
   <!--Delete comments and empty strings-->
    <xsl:variable name="raw_line_no_comm" as="xs:string*" 
      select="string-join(for $r in tokenize(.,'\n')[not(matches(.,'^\s*#.*$'))] 
      return normalize-space($r))"
    />
    
    <xsl:variable name="chart_rows" as="xs:string*" 
      select="tokenize($raw_line_no_comm, ';')[not(matches(.,'^\s*$'))]"
    />
    
    <xsl:variable name="options_is_exist" as="xs:boolean"
      select="contains($chart_rows[1],'hscale') or 
              contains($chart_rows[1],'arcgradient') or
              contains($chart_rows[1],'width') or
              contains($chart_rows[1],'wordwraparcs')"/>

    <xsl:variable name="options"  as="xs:string*" select="$chart_rows[xs:integer($options_is_exist)]"/>
    <xsl:variable name="entities" as="xs:string"  select="$chart_rows[xs:integer($options_is_exist)+1]"/>
    <xsl:variable name="arcsets" as="xs:string*" select="$chart_rows[(xs:integer($options_is_exist)+1) &lt; position()]"/>
    
    
    <!--Replace ',' into '""' with '#sc' for easier parsing-->   
    <xsl:variable name="entities_ch0" as="xs:string"  select="service:change_symb_in_quads($entities,'&quot;','&quot;',',','#sc')" />
    <xsl:variable name="arcsets_ch0"  as="xs:string*" select="service:change_symb_in_quads($arcsets,'&quot;','&quot;',',','#sc')" />
 
    <!--Replace ',' into "[]" with ';' for easier parsing-->   
    <xsl:variable name="entities_ch" as="xs:string"  select="service:change_symb_in_quads($entities_ch0,'[',']',',',';')" />
    <xsl:variable name="arcsets_ch"  as="xs:string*" select="service:change_symb_in_quads($arcsets_ch0,'[',']',',',';')" />
    
    
    <!--generate msc in XML format-->
    <xsl:variable name="xml-msc" as="element()">
      <xsl:element name="xml-msc">
        <xsl:if test="$options_is_exist">
          <xsl:attribute name="options" select="$options"/>
        </xsl:if>
        <entities>
          <xsl:for-each select="tokenize($entities_ch,',')">
            <xsl:element name="entity">
              <xsl:analyze-string select="." regex="^(.*?)\s*(\[\s*(.+?)\s*\])?\s*$">
                <xsl:matching-substring>   
                    <xsl:attribute name="ent_name">
                      <xsl:value-of select="normalize-space(regex-group(1))"/>
                    </xsl:attribute>
                    <xsl:if test="regex-group(3)">
                      <xsl:for-each select="tokenize(regex-group(3),';')">
                        <xsl:analyze-string select="normalize-space(.)" regex="^(\w+)\s*=\s*&quot;(.*?)&quot;$">
                          <xsl:matching-substring>
                            <xsl:attribute name="{normalize-space(regex-group(1))}">
                              <xsl:value-of select="replace(normalize-space(regex-group(2)),'#sc',',')"/>
                            </xsl:attribute>                    
                          </xsl:matching-substring>
                        </xsl:analyze-string>                      
                      </xsl:for-each>
                    </xsl:if>
                </xsl:matching-substring>
              </xsl:analyze-string>
            </xsl:element>
          </xsl:for-each>
        </entities>
        <arcsets>
          <xsl:for-each select="$arcsets_ch">
            <xsl:element name="arcset">
              <xsl:for-each select="tokenize(.,',')">
                <xsl:element name="arc">
                  <xsl:analyze-string select="." regex="^(.*?)\s*(\[\s*(.+?)\s*\])?\s*$">
                    <xsl:matching-substring>
                      <xsl:analyze-string select="normalize-space(regex-group(1))"
 regex="^(.*?)\s*(->|=>|>>|=>>|:>|->\*|-x|&lt;-|&lt;=|&lt;&lt;|&lt;&lt;=|&lt;:|\*&lt;-|x-|\.\.\.|---|\|\|\||abox|note|rbox|box)\s*(.*?)$">
                        <xsl:matching-substring>                          
                          <xsl:attribute name="left_p">
                            <xsl:value-of select="normalize-space(regex-group(1))"/>
                          </xsl:attribute>                    
                          <xsl:attribute name="right_p">
                            <xsl:value-of select="normalize-space(regex-group(3))"/>
                          </xsl:attribute>                                              
                          <xsl:attribute name="connect">
                            <xsl:value-of select="normalize-space(regex-group(2))"/>
                          </xsl:attribute>
                        </xsl:matching-substring>
                      </xsl:analyze-string>
                      <xsl:if test="regex-group(3)">
                        <xsl:for-each select="tokenize(regex-group(3),';')">
                          <xsl:analyze-string select="normalize-space(.)" regex="^(\w+)\s*=\s*&quot;(.*?)&quot;$">
                            <xsl:matching-substring>
                              <xsl:attribute name="{normalize-space(regex-group(1))}">
                                <xsl:value-of select="replace(normalize-space(regex-group(2)),'#sc',',')"/>
                              </xsl:attribute>                    
                            </xsl:matching-substring>
                          </xsl:analyze-string>                      
                        </xsl:for-each>
                      </xsl:if>
                    </xsl:matching-substring>
                  </xsl:analyze-string>
                </xsl:element>
              </xsl:for-each>
            </xsl:element>
          </xsl:for-each>
        </arcsets>
      </xsl:element>
    </xsl:variable>    
        
    <xsl:apply-templates select="$xml-msc" mode="draw"/>
  </xsl:template>
    
  <xsl:template match="xml-msc" mode="draw">
    
    <xsl:variable name="font-family"  as="xs:string"  select="'Roboto Mono Thin'"/>
    
    <xsl:variable name="field"   select="$msc-quantum div 10"/>
    
    <xsl:variable name="entity_num" as="xs:integer" select="count(./entities/entity)"/>
    <xsl:variable name="arcset_num" as="xs:integer" select="count(./arcsets/arcset)"/>
    
    <xsl:variable name="w" select="$w_rect*$entity_num + $w_space*($entity_num -1) + 2*$field"/>
    <xsl:variable name="h" select="$h_rect*($arcset_num +1) + $h_space*$arcset_num + 2*$field"/>
    
    <xsl:variable name="k_w" select="if($w>$msc-max-w)then $msc-max-w div $w else 1"/>
    <xsl:variable name="k_h" select="if($h>$msc-max-h)then $msc-max-h div $h else 1"/>
    <xsl:variable name="k"   select="if($k_w>$k_h)then $k_h else $k_w"/>
    
    <fig><svg-container>
      <svg:svg width="{$w*$k}mm" height="{$h*$k}mm" viewBox="0 0 {$w} {$h}" stroke="black"> 
        <svg:style type="text/css">
          .textStyle, text  {
            stroke-width: 0;
            text-anchor: middle;
            font-family: '<xsl:value-of select="$font-family"/>', 'Roboto Mono',  'SF Mono', 'Consolas', monospace;
            font-size: <xsl:value-of select="$font-size"/>;
          }
          .shapeStyle, circle, rect, path, polygon, line, polyline {
            stroke-width: <xsl:value-of select="$msc-quantum div 20"/>;
            fill: none;
          }
        </svg:style>
        
        <svg:g transform="translate({$field},{$field})">
          <xsl:apply-templates mode="#current"/>
        </svg:g>
      </svg:svg>
    </svg-container></fig>
  </xsl:template>
  
  <xsl:template match="entities" mode="draw">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="entity" mode="draw">
    
    <xsl:variable name="x_shift" as="xs:float" select="count(preceding-sibling::entity)*($w_rect + $w_space)"/>
    
    <svg:g transform="translate({$x_shift},0)">
      
      <xsl:apply-templates select="." mode="write_label">
        <xsl:with-param name="x" select="$w_rect div 2"/>
        <xsl:with-param name="y" select="$h_rect div 2"/>
      </xsl:apply-templates>  
      
      <xsl:variable name="x_line"  select="$w_rect div 2"/>   
      <xsl:variable name="main_line_len" as="xs:float" select="count(ancestor::xml-msc/arcsets/arcset)*($h_rect+$h_space)"/>
     
      <svg:line
        x1="{$x_line}" y1="{$msc-quantum}" 
        x2="{$x_line}" y2="{$msc-quantum + $main_line_len}" 
      >
        <xsl:if test="@linecolor"> 
          <xsl:attribute name="style"><xsl:value-of select="concat('stroke:',@linecolor,';')"/></xsl:attribute>
        </xsl:if>
        
      </svg:line>
    </svg:g>
  </xsl:template>
   
  <xsl:template match="arcsets" mode="draw">
      <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="arcset" mode="draw">    
    <xsl:variable name="y_shift" as="xs:float" 
      select="(count(preceding-sibling::arcset)+count(ancestor::xml-msc/entities))*($h_space+$h_rect)"/>
    <svg:g transform="translate(0, {$y_shift})" >
      <xsl:apply-templates mode="#current"/>
    </svg:g>
  </xsl:template>

  <xsl:template match="arc" mode="draw">
        <xsl:variable name="ent_num_from" as="xs:integer" select="count(ancestor::xml-msc/entities/entity[@ent_name=current()/@left_p][1]/preceding-sibling::entity)"/>
    <xsl:variable name="ent_num_to" as="xs:integer" select="count(ancestor::xml-msc/entities/entity[@ent_name=current()/@right_p][1]/preceding-sibling::entity)"/>
    
    <xsl:variable name="x_from"  as="xs:float" select="$ent_num_from*($w_rect+$w_space)"/>
    <xsl:variable name="x_to"    as="xs:float" select="$ent_num_to  *($w_rect+$w_space)"/>
    <xsl:variable name="x_len"   as="xs:float" select="$x_to -$x_from"/>
    
    <xsl:variable name="box_arrow_xshift" as="xs:float" select="if($x_from>$x_to)then $x_to else $x_from"/>

    <xsl:variable name="shape_xshift" as="xs:float" select="
      if(matches(@connect,'\.\.\.|---|\|\|\|')) then 
        0
      else 
        $box_arrow_xshift
     "/>
    
    <svg:g transform="translate({$shape_xshift},0) ">
      <xsl:if test="@linecolor"> 
        <xsl:attribute name="style"><xsl:value-of select="concat('stroke:',@linecolor,';')"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="." mode="draw_arc">
        <xsl:with-param name="x_len" select="$x_len" tunnel="yes"/>
      </xsl:apply-templates>
   </svg:g>    
  </xsl:template>

  <xsl:template match="arc[matches(@connect,'\.\.\.|---|\|\|\|')]" mode="draw_arc">
    
    <xsl:variable name="n_entities" as="xs:integer" select="count(ancestor::xml-msc/entities/entity)"/>
    <xsl:variable name="w_line" as="xs:float" select="$w_rect*$n_entities + $w_space*($n_entities -1)"/>

    <xsl:choose>
      <xsl:when test="@connect='---'">
        <svg:line x1="0" y1="{$h_rect div 2}" x2="{$w_line}" y2="{$h_rect div 2}" 
          style="stroke-dasharray:{concat($msc-quantum div 10,',',$msc-quantum div 10)}" />
      </xsl:when>
      <xsl:when test="@connect='...'">
        <xsl:for-each select="ancestor::xml-msc/entities/entity">
          <xsl:variable name="x_shift" select="$w_rect div 2 + ($w_rect +$w_space)*(position()-1)"/>
          <svg:line x1="{$x_shift}" y1="0"
                    x2="{$x_shift}" y2="{$msc-quantum}"
                    style="stroke-width:{$msc-quantum div 5};stroke:white;stroke-dasharray:{concat($msc-quantum div 10,',',$msc-quantum div 10)}"/>
        </xsl:for-each>          
      </xsl:when>        
    </xsl:choose>
   
    <xsl:apply-templates select="." mode="write_label">
      <xsl:with-param name="x" select="$w_line div 2"/>
      <xsl:with-param name="y" select="$h_rect div 2 - $font-size div 3"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="." mode="write_label">
    <xsl:param name="x" as="xs:float"/>
    <xsl:param name="y" as="xs:float"/>
    
    <xsl:if test="@label or @ent_name">
      <svg:text x="{$x}" y="{$y}">    
        <xsl:if test="@textcolor">
          <xsl:attribute name="style" select="concat('fill:',@textcolor,';')"/>
        </xsl:if>
        <xsl:value-of select="if(@label) then @label else @ent_name"/>
        <xsl:if test="@ID">
          <svg:tspan font-size="{$font-size - 2}" dy="{-$font-size div 2}"><xsl:value-of select="@ID"/></svg:tspan>     
        </xsl:if>
      </svg:text>
    </xsl:if>
  
  </xsl:template>
  
  <xsl:template match="arc[matches(@connect,'rbox|box|note|abox')]" mode="draw_arc">
    <xsl:param name="x_len" as="xs:float"   tunnel="yes"/>
    
    <xsl:variable name="w_box" as="xs:float" select="abs($x_len)+$w_rect"/>    
    
    <xsl:variable name="color" as="xs:string" select="if(@textbgcolor)then @textbgcolor else 'white'"/>

    <xsl:choose>
      <xsl:when test="@connect='box'">
        <svg:rect x="0" y="0" width="{$w_box}" height="{$h_rect}" style="fill:{$color};" />          
      </xsl:when>
      <xsl:when test="@connect='rbox'">
        <svg:rect x="0" y="0" rx="{$h_rect div 5}" ry="{$h_rect div 5}" width="{$w_box}" height="{$h_rect}" style="fill:{$color};"  />                              
      </xsl:when>
      <xsl:when test="@connect='note'">
        <svg:polygon points="0,0 0,{$h_rect} {$w_box},{$h_rect} {$w_box},{$h_rect div 3} {$w_box -($h_rect div 3)},0" style="fill:{$color};"  />          
      </xsl:when>        
      <xsl:when test="@connect='abox'">
        <svg:polygon points="
          {$msc-quantum div 5},0  0,{$h_rect div 2}  {$h_rect div 5},{$h_rect}  
          {$w_box -$h_rect div 5},{$h_rect} {$w_box},{$h_rect div 2}  {$w_box - $h_rect div 5},0 "
          style="fill:{$color};"/>
      </xsl:when>                
    </xsl:choose>
        
    <xsl:apply-templates select="." mode="write_label">
      <xsl:with-param name="x" select="$w_box div 2"/>
      <xsl:with-param name="y" select="$h_rect div 2 + $font-size div 3"/>
    </xsl:apply-templates>
   
  </xsl:template>
  
  <xsl:template match="arc[matches(@connect,'&gt;|&lt;|-x|x-')]" mode="draw_arc">
    <xsl:param name="x_len"   as="xs:float" tunnel="yes"/>    
    
    <svg:g>
      <xsl:attribute name="transform">
        <xsl:variable name="dir_r" as="xs:boolean" select="matches(@connect,'>|-x')"/>
        <xsl:variable name="not_rotate" as="xs:boolean" select="$x_len&gt;0 and $dir_r or not($x_len&gt;0) and not($dir_r)"/>
        <xsl:value-of select="concat(' translate(', $w_rect div 2, ',0)')"/>
        <xsl:if test="$x_len">
          <xsl:value-of select="concat(' translate(0,', $h_rect div 2,')')" />
          <xsl:if test="not($not_rotate)">     
            <xsl:value-of select="concat(' rotate(180,',abs($x_len) div 2,',0)')"/>
          </xsl:if>
        </xsl:if>
      </xsl:attribute>
      
      <xsl:call-template name="draw_arrow"/>
    </svg:g>
 
    <xsl:apply-templates select="." mode="write_label">
      <xsl:with-param name="x" select="abs($x_len) div 2 + $w_rect div 2"/>
      <xsl:with-param name="y" select="if($x_len) then ($h_rect div 2 - $font-size div 3) else ($h_rect div 2 + $font-size div 3)"/>      
    </xsl:apply-templates>   
       
  </xsl:template>
  
  <xsl:template name="draw_arrow">
    <xsl:param name="x_len"   as="xs:float" tunnel="yes"/>
    
    <xsl:variable name="self-pointed" as="xs:boolean" select="$x_len=0"/>
    <xsl:variable name="tcmp" as="xs:string" select="concat(',',@connect,',')"/>
    
    <svg:g>
      <xsl:if test="contains(',>>,&lt;&lt;,', $tcmp)"> 
        <xsl:attribute name="stroke-dasharray" select="concat($msc-quantum div 10,',',$msc-quantum div 10)"/>
      </xsl:if>
      
      <xsl:if test="not($x_len = 0)">
        <xsl:choose>
          <xsl:when test="contains(',:>,&lt;:,', $tcmp)">
            <xsl:variable name="y_line1" select="$h_rect div 10"/>
            <xsl:variable name="y_line2" select="+($h_rect div 10)"/>
            <svg:path d="M 0,{$y_line1} H {abs($x_len)} M 0,{$y_line2} H {abs($x_len)}" />
          </xsl:when>
          <xsl:when test="contains(',-x,x-,', $tcmp)">
            <svg:path d="M 0,0 H {abs($x_len) -$w_rect div 3}" />
          </xsl:when>
          <xsl:otherwise>
            <svg:path d="M 0,0 H {abs($x_len)}" />
          </xsl:otherwise>
        </xsl:choose>        
      </xsl:if>
      
      <xsl:if test="$x_len=0">
        <xsl:choose>
          <xsl:when test="contains(',-x,x-,', $tcmp)">
            <svg:path d="M 0,0 H {-($w_rect div 2)} V {$h_rect} H {-($w_rect div 2) +$w_rect div 3}" />
          </xsl:when>
          <xsl:otherwise>
            <svg:path d="M 0,0 H {-($w_rect div 2)} V {$h_rect} H 0 " >
              
            </svg:path>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="contains(',:>,&lt;:,', $tcmp)">
          <svg:path d="M 0,{$h_rect div 10} H {-($w_rect div 2) +$h_rect div 10} V {$h_rect -$h_rect div 10} H 0" />            
        </xsl:if>  
      </xsl:if>
      
    </svg:g>
  
    <svg:path>
      <xsl:attribute name="transform">
        <xsl:if test="$x_len">
          <xsl:value-of select="concat(' translate(',abs($x_len) ,',0)')" />
          <xsl:if test="contains(',-x,x-,',$tcmp)">
            <xsl:value-of select="concat(' translate(', -($h_rect div 2),',0)')"/>
          </xsl:if>                        
        </xsl:if>   
        <xsl:if test="not($x_len)">
          <xsl:value-of select="concat(' translate(0,', $h_rect ,')')" />
        </xsl:if> 
      </xsl:attribute> 
      
      <xsl:choose>
        <xsl:when test="contains(',->,&lt;-,',$tcmp)">
          <xsl:attribute name="d" select="concat(
            'M 0,0 L ', -($msc-quantum div 3),',',($msc-quantum div 3)
          )"/>
        </xsl:when>
        <xsl:when test="contains(',-x,x-,',$tcmp)">
          <xsl:attribute name="d" select="concat(
           ' M ', - $msc-quantum -($msc-quantum div 6),',', - ($msc-quantum div 6), 
           ' L ', - $msc-quantum +($msc-quantum div 6),',', + ($msc-quantum div 6),
           ' M ', - $msc-quantum -($msc-quantum div 6),',', + ($msc-quantum div 6), 
           ' L ', - $msc-quantum +($msc-quantum div 6),',', - ($msc-quantum div 6)     
          )"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="d" select="concat(
            ' M ', -($msc-quantum div 3),',', -($msc-quantum div 3),
            ' L 0,0 L ',
            -($msc-quantum div 3),',', +($msc-quantum div 3)
          )"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="contains(',=>,:>,>>,&lt;=,&lt;:,&lt;&lt;,',$tcmp)">
        <xsl:attribute name="fill" select="'black'"/>
      </xsl:if>
    </svg:path>

  </xsl:template>

</xsl:stylesheet>