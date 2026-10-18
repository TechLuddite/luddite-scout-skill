# Luddite Scout skill

An agent skill for Claude Code and the Claude apps that runs [Luddite Scout](https://github.com/TechLuddite/Luddite-Scout) on a public GitHub repository and gives the agent a summary with no text from that repository.

**Status:** experimental, under active development.

The skill packages `bin/scout` from Luddite Scout and runs it as `scout --agent owner/repo`. That mode prints only rule IDs, fixed descriptions, severities, statuses, counts, the repository name and the commit hash. How it works, and what it does not protect against, is in [docs/agent-skill.md](https://github.com/TechLuddite/Luddite-Scout/blob/main/docs/agent-skill.md) in the Luddite Scout repository.

## Install

Download `luddite-scout.skill` from the [latest release](https://github.com/TechLuddite/luddite-scout-skill/releases/latest). Before installing, check that the file came from this repository's CI:

```sh
gh attestation verify luddite-scout.skill --repo TechLuddite/luddite-scout-skill
```

Claude Code:

```sh
unzip luddite-scout.skill -d ~/.claude/skills/
```

Claude apps: upload the file under Customize, Skills. This has not been tested yet. The script needs HTTPS access to `api.github.com`, `raw.githubusercontent.com`, `api.osv.dev` and `api.securityscorecards.dev`, and code execution in the Claude apps may not allow them.

To remove it from Claude Code:

```sh
rm -r ~/.claude/skills/luddite-scout
```

## Build

```sh
./build.sh
```

It writes `dist/luddite-scout.skill`. `bin/scout` is downloaded from Luddite Scout at the commit named in `scout.lock`, and the build stops if its SHA-256 does not match the one recorded there. The same commit of this repository always gives the same file. To build from a local copy of `bin/scout`, set `SCOUT=/path/to/scout`. The hash check still applies.

CI builds every push and pull request. When `SKILL.md`, `scout.lock`, `build.sh` or `LICENSE` changes on `main`, it publishes a release with a build provenance attestation.

To move to a newer `bin/scout`, update `commit` and `sha256` in `scout.lock` together.

Releases up to `skill-v0.3.1-cbeb849` were published from the Luddite Scout repository and verify with `--repo TechLuddite/Luddite-Scout`.

## Licence

[MIT](LICENSE).
