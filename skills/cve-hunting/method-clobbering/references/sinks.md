# Parser Patterns Creating Objects From Untrusted Keys

## CSV Parsers
| Library | Creates Plain Objects? | Key Source |
|---------|----------------------|------------|
| csv-parse | Yes (columns: true) | First row headers |
| papaparse | Yes (header: true) | First row headers |
| fast-csv | Yes (headers: true) | First row headers |
| csv-parser | Yes (default) | First row headers |
| csvtojson | Yes (default) | First row headers |

## Form/Query Parsers
| Library | Creates Plain Objects? | Key Source |
|---------|----------------------|------------|
| qs | Yes | Query string keys |
| querystring | Yes | Query string keys |
| body-parser (urlencoded) | Yes | Form field names |
| formidable | Yes | Form field names |
| busboy | Streams fields | Field names |
| multiparty | Yes | Form field names |

## Configuration Parsers
| Library | Creates Plain Objects? | Key Source |
|---------|----------------------|------------|
| dotenv | Yes | .env file keys |
| ini | Yes | INI section/key names |
| toml | Yes | TOML keys |
| yaml | Yes | YAML keys |

## Safe Patterns

- `Object.create(null)` -- no prototype, no methods to clobber
- `new Map()` -- Map objects have own methods, not inherited
- Key allowlist/blocklist -- explicitly filtering dangerous keys
- `Object.freeze()` on prototype -- prevents modification (but does not prevent clobbering on instances)
