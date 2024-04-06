# com.grovf.doxygen2dita

## Inspiration
Project inspired by https://github.com/dita-community/doxygen2dita

## Project status
Incompleted. 
Review and help welcome.

## Using

Correct integration to DITA-OT with plugin.xml doesn't work yet.

So I use this transformation pack directly with SaxonJ transformer from DITA-OT https://www.dita-ot.org/.

Don't remember to set required classpath before(make syntax):
```
CLASSPATH := $(CLASSPATH):$(DITA_OT_PATH)/lib/xml-resolver-1.2.jar
CLASSPATH := $(CLASSPATH):$(DITA_OT_PATH)/lib/xmlresolver-5.2.3-data.jar
CLASSPATH := $(CLASSPATH):$(DITA_OT_PATH)/lib/xmlresolver-5.2.3.jar
CLASSPATH := $(CLASSPATH):$(DITA_OT_PATH)/lib/Saxon-HE-12.4.jar
export CLASSPATH:=$(CLASSPATH)
```

```
java net.sf.saxon.Transform -s:YOUR_INDEX_XML -xsl:doxygen2dita.xsl -o:dita_out  mapTitle='My Awesome Doc' 
```

