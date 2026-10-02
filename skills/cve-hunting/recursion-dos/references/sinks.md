# Recursive Operation Patterns

## Parsers
| Library/Pattern | Function | Depth Limit? |
|-----------------|----------|-------------|
| JSON.parse (native) | Built-in | Platform-dependent (usually safe) |
| Custom JSON parsers | parse() | CHECK |
| XML recursive descent | parseElement() | CHECK |
| HTML tree builders | buildTree() | CHECK |
| Markdown parsers | parseBlock/parseInline | CHECK |
| YAML parsers | processNode() | CHECK -- alias expansion is separate |
| CSV nested parsers | parseCell() | RARE issue |

## Serializers
| Library/Pattern | Function | Depth Limit? |
|-----------------|----------|-------------|
| JSON.stringify (native) | Built-in | Throws on circular refs |
| Custom serializers | serialize/stringify | CHECK |
| HTML serializers | renderNode() | CHECK |
| XML serializers | xmlify/toXML | CHECK |

## Clone/Merge
| Library/Pattern | Function | Depth Limit? |
|-----------------|----------|-------------|
| lodash.cloneDeep | _.cloneDeep() | Has circular ref detection |
| rfdc | rfdc()(obj) | CHECK version |
| structuredClone (native) | Built-in | Handles circular refs |
| Custom deep clone | deepClone() | CHECK |
| Custom deep merge | deepMerge() | CHECK |

## Tree Walkers
| Pattern | Function | Depth Limit? |
|---------|----------|-------------|
| AST walkers | walk/visit/traverse | CHECK |
| DOM traversal | walkDOM() | CHECK |
| File system walkers | walkDir/readDir recursive | CHECK |
| Object flatteners | flatten() | CHECK |
