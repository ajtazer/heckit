# Package Family Mapping by Vulnerability Class

## Code Injection Families

### Template Engines (SSTI/Code Injection)
ejs, nunjucks, pug, handlebars, mustache, doT, eta, art-template, velocityjs, hogan.js, swig, marko, dust

### Expression Evaluators (Code Injection)
expr-eval, simpleeval, filtrex, mathjs, hot-formula-parser, jexl, jsonata, angular-expressions

### Schema Validators with Code Gen
fastest-validator, djv, ajv (custom keywords), joi (custom validators)

### Serializers with Code Gen
flatted, devalue, superjson, serialize-javascript

## Entity Expansion Families

### XML Parsers
fast-xml-parser, xml2js, xmldom, xml-js, cheerio (safe), sax (safe), htmlparser2 (safe)

### YAML Parsers
js-yaml, yaml (npm), PyYAML, ruamel.yaml, go-yaml, yaml-cpp

### SVG Processors
svgo, sharp (SVG input), cairosvg, librsvg, svgr

## Path Traversal Families

### Archive Extractors
adm-zip, yauzl, unzipper, decompress, fflate, JSZip, tar, archiver, node-7z, node-tar, extract-zip

### File Servers
serve-static, sirv, st, ecstatic, http-server, live-server

### File Upload Handlers
express-fileupload, formidable, multer, busboy, multiparty

## Prototype Pollution Families

### Deep Merge/Clone
deepmerge, lodash.merge, extend, deep-extend, merge-deep, rfdc, klona, fast-copy, clone-deep

### Query String Parsers
qs, querystring, query-string, fast-querystring

### Config Mergers
rc, cosmiconfig, conf, nconf

## Recursion DoS Families

### JSON Alternatives
flatted, devalue, superjson, json5, hjson

### Deep Clone
rfdc, klona, lodash.cloneDeep, fast-copy, clone-deep

### Serializers
serialize-javascript, msgpackr, cbor, avsc

### HTML/Markdown Processors
parse5, turndown, showdown, marked, unified

## ReDoS Families

### Input Validators
validator.js, is-my-json-valid, schema-inspector, superstruct

### URL Parsers
url-parse, normalize-url, valid-url, is-url

### Email Validators
email-validator, isemail, email-check

### Date Parsers
chrono-node, dateparser, moment (format parsing)

## Decompression Bomb Families

### Compression Libraries
pako, fflate, lz-string, snappy, brotli, zstd

### Archive Libraries
adm-zip, yauzl, decompress, node-tar, archiver

### File Type Detection (with decompression)
file-type, mmmagic, detect-file-type
