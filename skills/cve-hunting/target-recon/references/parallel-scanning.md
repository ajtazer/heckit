# Parallel Target Scanning

## Batch Evaluation Methodology

When evaluating multiple targets, parallelize the process:

### Phase 1: Discovery (Parallel)

Run multiple search queries simultaneously:
```bash
# Run these in parallel
gh search repos "xml parser" --language javascript --stars 500..15000 --json name,stargazersCount,updatedAt
gh search repos "csv parse" --language javascript --stars 500..15000 --json name,stargazersCount,updatedAt
gh search repos "yaml" --language python --stars 500..10000 --json name,stargazersCount,updatedAt
```

### Phase 2: Dedup (Sequential)

Check each result against REGISTRY.md. Skip already-investigated packages.

### Phase 3: Quick Assessment (Parallel)

For each remaining candidate, quickly assess:
1. Last commit date (skip if > 6 months old)
2. Existing CVE count (skip if > 10)
3. SECURITY.md presence (bonus)
4. Download count (skip if < 100K weekly for npm)

### Phase 4: Deep Evaluation (Sequential)

For the top 5-10 candidates:
1. Clone repo
2. Count lines of code
3. Identify attack surface
4. Match to vulnerability skills
5. Write brief
6. Propose to Director

## Rate Limiting

- GitHub API: 30 search requests per minute (authenticated)
- npm API: generous limits for search
- grep.app: be reasonable, no rate limit documented

## Subagent Parallelization

When using Claude Code, spawn subagents for parallel evaluation:
- Each subagent evaluates one target
- Main agent collects results and deduplicates
- Final ranking by estimated CVE potential
