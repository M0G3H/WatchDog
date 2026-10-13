# WatchDog


WATCHDOG is a lightweight Bash-based reconnaissance utility that monitors changes in web directories and subdomains over time. It uses [ffuf](https://github.com/ffuf/ffuf) to discover accessible paths and subdomains, compares the latest scan results against previously saved baselines, and records newly discovered and disappeared entries in change logs.

Designed for security researchers, penetration testers, and reconnaissance workflows, WATCHDOG helps identify changes in a target's external attack surface without manually comparing scan results.

## Features

- **Directory monitoring** — Discover web paths and directories using `ffuf`.
- **Subdomain monitoring** — Identify subdomains through wordlist-based fuzzing.
- **Baseline management** — Save initial scan results and reuse them for future comparisons.
- **Change detection** — Identify newly discovered and disappeared entries.
- **Separate change logs** — Keep directory and subdomain changes in separate files.
- **Duplicate removal** — Sort and deduplicate discovered entries.
- **Lightweight implementation** — Built with Bash and standard command-line utilities.
- **Simple command-line interface** — Run directory or subdomain checks independently.

## Requirements

- Linux or another Unix-like environment with Bash.
- [ffuf](https://github.com/ffuf/ffuf)
- Standard utilities: `sort`, `cut`, `tail`, `cmp`, `comm`, `sed`, and `date`.
- Wordlists at the following default locations:

```text
~/Desktop/source/dictionary/
├── sample_directory.txt
└── sample_subs.txt
```

Make sure these files exist and are readable before running WATCHDOG.

## Installation

### 1. Clone the repository


```bash
git clone https://github.com/M0G3H/WATCHDOG.git
cd WATCHDOG
chmod +x watchdog install.sh
./install.sh
```

The installer creates the output directory at:

```text
~/Desktop/watchdog/
```

## Usage

WATCHDOG accepts a scan mode and a target domain.

```bash
./watchdog -dir/-sub example.com
```


### Help

```bash
./watchdog -h
```

## Understanding Change Logs

WATCHDOG records detected changes using the following markers:

```text
[date] 2026-10-13 12:00:00
[add] /api
[add] /dashboard
[delete] /old-panel
```

## Configuration

WATCHDOG uses variables defined near the beginning of the Bash script to configure its output paths and wordlists.

| Variable | Description |
|---|---|
| `DIRECTORY_DICTIONARY` | Wordlist used for directory discovery |
| `SUBDOMAIN_DICTIONARY` | Wordlist used for subdomain discovery |
| `OLD_DIR` / `OLD_SUB` | Saved baselines |
| `CHANGE_DIR` / `CHANGE_SUB` | Change history files |
| `NEW_DIR` / `NEW_SUB` | Latest scan results |

Update the relevant paths if your wordlists or output directory are stored elsewhere.

## Contributing

Contributions, bug reports, and suggestions are welcome. When reporting a problem, include the command used, relevant error output, and your operating environment. Avoid sharing sensitive target data.


---

**WATCHDOG — Monitor your attack surface. Detect what changes.**
