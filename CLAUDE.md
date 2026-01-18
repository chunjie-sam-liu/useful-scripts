# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a collection of standalone bioinformatics and system utility scripts used in HPC/cluster environments. Scripts are primarily written in Bash, Python, R, Perl, and AppleScript. There is no centralized build system or test framework - each script operates independently.

## Common Commands

### Verification Commands (Per-Script)

Since there's no unified build/test system, verify individual scripts:

**Bash scripts:**
```bash
bash -n path/to/script.sh  # Syntax check
```

**Python scripts:**
```bash
python -m py_compile path/to/script.py  # Syntax check
```

**R scripts:**
```bash
Rscript -e "parse('path/to/script.R')"  # Parse check
```

**Perl scripts:**
```bash
perl -c path/to/script.pl  # Syntax check
```

### Key Utility Commands

**Parallel execution (local):**
```bash
generalParallel commands.txt [num_threads]
# Runs shell commands in parallel from a file (default: 20 threads)
# Uses FIFO-based semaphore pattern for job control
```

**Parallel execution (SLURM cluster):**
```bash
generalParallelSlurm script.sh [ntasks] [nodes] [ntasks_per_node]
# Submits parallel jobs to SLURM (defaults: 10 tasks, 2 nodes, 5 tasks/node)
```

**Kill parallel processes:**
```bash
killparallel
# Terminates parallel processes spawned by generalParallel
```

**Docker RStudio management:**
```bash
jrocker up [port]        # Start RStudio container (default port: 8686)
jrocker dn [port]        # Stop/remove container(s)
jrocker ss               # Show running containers
jrocker ex [port]        # Execute shell in container
```

**Docker Jupyter management:**
```bash
jukeras up|dn|ss|ex [port]  # Similar interface to jrocker
```

## Architecture and Patterns

### Parallel Execution Pattern

The `generalParallel` script implements a FIFO-based semaphore pattern for parallel job control:
- Creates a named pipe (FIFO) in `~/tmp/`
- Pre-populates with "slot" tokens (one per thread)
- Each job consumes a slot, runs in background, releases slot on completion
- Supports job tracking with timestamps and status indicators

This pattern is reused across multiple scripts and is central to batch processing workflows.

### SLURM Integration

Many scripts are designed for SLURM clusters:
- **SLURM job templates**: `*.slurm` files define job parameters (#SBATCH directives)
- **vsc-tunnel-*.slrm**: VSCode tunnel scripts for remote development on compute nodes
- **slurm-submit-jobs/**: Contains utilities for batch job submission and monitoring
  - `02-check-notrun.sh`: Identifies failed/incomplete jobs
  - `03-create-split-slurm.sh`: Generates SLURM scripts for split data
- **slurm-parallel/**: Example SLURM scripts using parallel execution within jobs

Key SLURM patterns:
- Use `srun --exclusive` for parallel task distribution within a job
- Common resource allocation: `--mem-per-cpu=5G`, `--time=120:00:00`
- Output typically goes to `${HOME}/tmp/errout/`

### Docker Environment Pattern

Both `jrocker` and `jukeras` follow a similar container management pattern:
- Create user-specific config directories in `~/.{USER}-rstudio/` or `~/.{USER}-jupyter/`
- Mount multiple host directories (workspace, project, data, R, scripts, tools, github, tmp)
- Use environment variables for user/group ID mapping
- Support multiple concurrent containers via port differentiation
- Container names follow pattern: `{USER}-{service}-{port}`

### Bioinformatics Utilities

Several Python scripts interact with biological databases:
- **miRNA utilities**: `find-gene-miRNA-by-symbol.py`, `find-miRNA-target.py`, `get-sequence-by-mir-name.py`
  - Often reference `mature.fa` (miRNA sequence database)
- **Download utilities**: `download-gsm.py`, `download-sra.sh`, `download-ebi.sh`
  - Used for retrieving data from public repositories (GEO, SRA, EBI, GATK)
- **ID mapping**: `getEnsFromEntrezID.py`, `mapFileUUID2submitterID.py`
  - Convert between biological identifier systems

### Script Organization

- **Top-level**: General-purpose utilities and commonly-used scripts
- **ncbi-script/**: NCBI-specific Perl utilities (gene summaries, GO annotations, taxonomy)
- **slurm-submit-jobs/**: SLURM job management and monitoring utilities
- **slurm-parallel/**: Example SLURM scripts demonstrating parallel patterns
- **Standalone scripts**: Most scripts are self-contained with their own usage/help functions

## Development Context

### Environment Assumptions

Scripts assume a typical bioinformatics HPC environment:
- SLURM workload manager
- Anaconda/conda for Python environments
- Docker for containerized services
- Linux-style tools (`find`, `awk`, `sed`, `lftp`, `nohup`, `zgrep`)
- Shared filesystems mounted at `/workspace/`, `/project/`, `/data/`

### File Paths and Conventions

- Temporary files: `${HOME}/tmp/` or `/scr1/users/${USER}/tmp/`
- Error/output logs: `${HOME}/tmp/errout/`
- Container configs: `~/.{USER}-{service}/`
- Scripts often use absolute paths and assume specific directory structures

### Code Style Notes

**Bash:**
- Most scripts use `#!/bin/bash` or `#!/usr/bin/env bash`
- Usage functions are common (show help/examples)
- Variable quoting is inconsistent - be careful when modifying
- Functions typically use lowercase names

**Python:**
- CLI-oriented scripts using `sys.argv` for argument parsing
- Import styles vary (sometimes multiple imports per line)
- Often use BioPython (`Bio.*`) for bioinformatics tasks

**R:**
- Use `<-` for assignment
- Explicit namespace calls (`biomaRt::useMart`)
- Function naming uses `fn_*` prefix

## Modification Guidelines

1. **Preserve standalone nature**: Each script should remain self-contained
2. **Match existing style**: Follow the conventions within the file you're modifying
3. **Test carefully**: No automated tests exist - verify manually after changes
4. **Consider environment**: Many scripts assume specific HPC cluster configurations
5. **Don't break interfaces**: Preserve command-line flags and output formats
6. **Respect upstream code**: Some scripts (especially Perl) are from NCBI/vendors - minimize changes
