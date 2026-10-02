# Pre-Built Search Queries

## npm Searches

### Parsing Libraries
```
npm search xml parser
npm search csv parse
npm search yaml parser
npm search markdown parser
npm search xlsx excel
npm search pdf parse
npm search html parser
npm search json schema
npm search toml parser
npm search ini parser
```

### Validation Libraries
```
npm search validate
npm search schema validator
npm search sanitize
npm search form validator
npm search input validation
npm search data validation
```

### Template Engines
```
npm search template engine
npm search handlebars
npm search mustache
npm search nunjucks
npm search ejs
npm search pug
```

### File Handling
```
npm search file upload
npm search archive extract
npm search zip extract
npm search tar extract
npm search decompress
npm search image resize
npm search image process
```

### Serialization
```
npm search serialize
npm search stringify
npm search deep clone
npm search deep merge
npm search object assign deep
```

### HTTP/Networking
```
npm search http client
npm search request
npm search fetch
npm search url parse
npm search cookie parser
```

## GitHub Code Search (gh search repos)

### By Vulnerability Class

```bash
# Code injection targets
gh search repos "new Function" --language javascript --stars 500..15000

# Entity expansion targets
gh search repos "xml parser" --language javascript --stars 500..15000

# Path traversal targets
gh search repos "archive extract" --language javascript --stars 500..10000

# Sandbox escape targets
gh search repos "vm sandbox eval" --language javascript --stars 500..10000

# ReDoS targets
gh search repos "regex validator" --language javascript --stars 500..10000
```

## grep.app Regex Patterns

Search across all public repos for vulnerable patterns:

```
# new Function with template literal
https://grep.app/search?q=new+Function%28%60&regexp=false&filter[lang][0]=JavaScript

# eval with string concatenation
https://grep.app/search?q=eval%28.*%2B&regexp=true&filter[lang][0]=JavaScript

# exec without array args
https://grep.app/search?q=child_process.*exec%28&regexp=true&filter[lang][0]=JavaScript

# yaml.load without safe
https://grep.app/search?q=yaml.load%28&regexp=false&filter[lang][0]=Python
```

## PyPI Searches

```
pip search xml parser  # Note: pip search is disabled, use pypi.org
# Search on pypi.org for:
# xml parser, yaml parser, csv parser, template engine,
# schema validator, file upload, archive, image processing
```
