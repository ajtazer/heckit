# XML/YAML Parser Sinks by Language

## JavaScript / TypeScript

| Parser | Function | Entity Support | Default Limit | Verdict |
|--------|----------|---------------|---------------|---------|
| fast-xml-parser | `XMLParser.parse()` | Yes, via `processEntities` option (default true) | None | UNSAFE |
| xml2js | `parseString()`, `Parser.parseString()` | Yes | None | UNSAFE |
| xmldom | `DOMParser.parseFromString()` | Yes | None | UNSAFE |
| sax | `sax.parser()`, `sax.createStream()` | No entity expansion | N/A | SAFE |
| htmlparser2 | `parseDocument()` | No DTD support | N/A | SAFE |
| cheerio | `cheerio.load()` | Uses htmlparser2, no DTD | N/A | SAFE |
| libxmljs | `parseXml()`, `parseHtml()` | Yes | Configurable | CHECK CONFIG |
| xml-js / xml2json | `xml2json()`, `xml2js()` | Via underlying parser | Varies | CHECK |
| js-yaml | `yaml.load()` | Aliases yes, no limit pre-4.x | v4+ has alias limit | CHECK VERSION |
| yaml (npm) | `YAML.parse()` | Aliases yes | Configurable maxAliasCount | CHECK CONFIG |

### How to Check fast-xml-parser

```js
// VULNERABLE — default config
const parser = new XMLParser();
parser.parse(xml); // processes entities with no limit

// SAFE — entities disabled
const parser = new XMLParser({ processEntities: false });

// SAFE — with expansion limit (if supported in version)
const parser = new XMLParser({ maxEntities: 100 });
```

## Python

| Parser | Function | Entity Support | Default Limit | Verdict |
|--------|----------|---------------|---------------|---------|
| xml.etree.ElementTree | `ET.parse()`, `ET.fromstring()` | Yes | None | UNSAFE |
| xml.sax | `xml.sax.parse()` | Yes | None | UNSAFE |
| xml.dom.minidom | `minidom.parse()` | Yes | None | UNSAFE |
| lxml | `etree.parse()`, `etree.fromstring()` | DTD off by default | Configurable | SAFE (default) |
| defusedxml | All standard parsers wrapped | All dangerous features off | N/A | SAFE |
| PyYAML | `yaml.load()` | Aliases yes | None | UNSAFE |
| PyYAML | `yaml.safe_load()` | Aliases yes | None | UNSAFE (aliases) |
| ruamel.yaml | `YAML().load()` | Aliases yes | None | UNSAFE (aliases) |

### How to Check Python XML

```python
# VULNERABLE
import xml.etree.ElementTree as ET
ET.fromstring(user_xml)  # No entity protection

# SAFE
import defusedxml.ElementTree as ET
ET.fromstring(user_xml)  # Entity expansion blocked
```

## Go

| Parser | Function | Entity Support | Default Limit | Verdict |
|--------|----------|---------------|---------------|---------|
| encoding/xml | `xml.Decoder.Decode()` | No custom entities | N/A | SAFE |
| go-yaml v3 | `yaml.Unmarshal()` | Aliases yes | 1000 aliases default | CHECK |
| go-yaml (goccy) | `yaml.Unmarshal()` | Aliases yes | CHECK | CHECK |
| etree | `etree.ReadFrom()` | Minimal entity support | N/A | MOSTLY SAFE |

## Ruby

| Parser | Function | Entity Support | Default Limit | Verdict |
|--------|----------|---------------|---------------|---------|
| Nokogiri | `Nokogiri::XML()` | DTD off by default | Configurable | SAFE (default) |
| REXML | `REXML::Document.new()` | Yes | 10000 default | CHECK LIMIT |
| Ox | `Ox.parse()` | Configurable | N/A | CHECK CONFIG |

## PHP

| Parser | Function | Entity Support | Default Limit | Verdict |
|--------|----------|---------------|---------------|---------|
| simplexml_load_string | Direct call | Yes (libxml) | libxml2 defaults | UNSAFE pre-PHP 8 |
| DOMDocument | `loadXML()` | Yes (libxml) | libxml2 defaults | UNSAFE pre-PHP 8 |
| XMLReader | `open()` | Yes (libxml) | libxml2 defaults | UNSAFE pre-PHP 8 |

**Note**: PHP 8.0+ sets `LIBXML_NOENT` to false by default and disables entity substitution. Check PHP version.
