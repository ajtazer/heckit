<p align="center">
  <img src="assets/heckit-mascot.png" alt="heckit mascot" width="260">
</p>

<h1 align="center">heckit</h1>

<p align="center"><b>Your hacking buddy for AI coding agents.</b></p>

`heckit` is one agent you talk to for the whole session — a friendly offensive-security companion that has an entire pentest toolkit memorized and pulls the right tool at the right moment, so you don't have to remember any of it.

Under the hood it's **314 skills and specialist agents** (bug-bounty, red-team, web, AD, cloud, wireless, and more) plus a 7-command CVE-hunting pipeline for finding real vulnerabilities in npm/PyPI/GitHub packages. But you don't manage those. You just talk to heckit. It watches what you're doing, reminds you when there's a skill or specialist for it, deploys it, and tells you in plain, friendly language what's going on and what to do next — without wasting tokens re-loading things you already have.

Works with **Claude Code**, **OpenAI Codex CLI**, and **opencode**.

> ⚠️ **Authorized use only.** heckit is for systems you own or have **explicit written permission** to test — pentest engagements, bug-bounty scope, CTFs, your own lab. You're responsible for staying within the law and your authorization.

---

## Install

```bash
git clone https://github.com/ajtazer/heckit.git
cd heckit

./install.sh claude      # Claude Code
./install.sh opencode    # opencode
./install.sh codex       # OpenAI Codex CLI
```

Restart your agent, then just start talking to **heckit**.

Add `project` to install into the current repo instead of your home config (Claude/opencode):

```bash
./install.sh claude project
```

### Make heckit the default (optional)

Installing makes heckit *available*; this makes your agent reach for it **automatically**. Drop one line into the instruction file your tool loads at startup — in the repo where you actually do your testing (or your global config):

- **Claude Code** → `CLAUDE.md`  ·  **Codex / opencode** → `AGENTS.md`

```md
For any offensive-security, pentest, bug-bounty, red-team, or CTF work,
consult the `heckit` agent first and let it route to the right skill or specialist.
```

That line is always in context, so the main agent defers to heckit by default instead of only when summoned.

---

## How you use it

Just work like you normally would. heckit rides along and jumps in when it helps:

```
you:  poking at this /api/orders/1234 endpoint, think I can see other people's orders

┌─ heckit ─────────────────────────────────┐
│ now: testing an order endpoint for IDOR    │
│ fits: hunt-idor — bug-bounty IDOR playbook │
│ move: swap the ID, diff the response —      │
│       want me to load the full checklist?   │
└────────────────────────────────────────────┘
```

Ask it anything, anytime:

```
you:  heckit what's SSTI again?

heckit:  basically the app renders your input as a template, so you can run
         code on the server. we've got hunt-ssti + the web-ssti-* skills
         (jinja2, twig, freemarker). want me to pull the one for your stack?
```

When a job gets big, heckit brings in specialists — or spins up the full swarm to coordinate them — and reports back in plain terms.

---

## What's under the hood

You don't need to touch these directly — heckit knows them all — but they're all here, open, and browsable:

- **`agents/`** — 52 specialist agents (recon, exploitation, AD, cloud, C2, reporting…) that heckit hands focused work to, coordinated by `swarm-orchestrator` for full engagements.
- **`skills/`** — 239 on-demand playbooks, grouped by category:

  | Category | # | Category | # | Category | # |
  |---|---|---|---|---|---|
  | web | 101 | active-directory | 17 | wireless-iot | 15 |
  | exploitation | 14 | privilege-escalation | 13 | network | 11 |
  | cloud-container | 10 | methodology | 9 | evasion | 8 |
  | post-exploitation | 7 | recon | 7 | reporting | 7 |
  | supply-chain-cicd | 6 | credential-access | 4 | ai-llm | 3 |
  | crypto-blockchain | 3 | mobile | 3 | ctf | 1 |

All of it is in the open [Agent Skills](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) format (`SKILL.md`), a shared standard Claude Code, Codex, and opencode all read. The installer flattens the category folders on the way in (Claude discovers skills only one level deep), so you can grab any single skill by hand too:

```bash
cp -R skills/web/hunt-idor ~/.claude/skills/hunt-idor
```

---

## Credits

Built from public bug-bounty disclosures (HackerOne), community research, and open pentest-agent projects (including `0xSteph/pentest-ai-agents`). Per-skill `sources:` are in each file's frontmatter.

## License

MIT — see `LICENSE`. Use responsibly.
