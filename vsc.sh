#!/usr/bin/env bash
# vsc.sh - Manage LSF jobs for VS Code Remote-SSH compute nodes.
#
# Usage:
#   vsc.sh submit              Submit a new job (vsc-cpu.lsf)
#   vsc.sh ls                  List all jrocker jobs
#   vsc.sh ssh                 Show SSH config for all running jobs
#   vsc.sh ssh <JOBID>         Show SSH config for a specific job
#   vsc.sh cancel <JOBID>      Cancel a specific job
#   vsc.sh cancel all          Cancel all jrocker jobs
#   vsc.sh clean               Remove stale log/err/conf files (jobs no longer active)
#   vsc.sh clean <JOBID>       Remove log/err/conf files for a specific job
#   vsc.sh conf                Export SSH config file(s) to ~/tmp for all running jobs
#   vsc.sh conf <JOBID>        Export SSH config file for a specific job
#   vsc.sh help                Show this help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
LSF_SCRIPT="${SCRIPT_DIR}/vsc-cpu.lsf"
JOB_NAME="jrocker"
USER=$(whoami)

LOG_DIR="/home/cliu68/tmp/errout/jrocker"
LOG_PREFIX="vsc-tunnel-cpu"
CONF_DIR="${HOME}/tmp"

usage() {
    sed -n '3,15p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'
}

# --- helpers ---

JOB_FMT="jobid stat exec_host nreq_slot run_time time_left start_time"
JOB_DELIM="^"

get_running_jobs() {
    bjobs -o "${JOB_FMT} delimiter='${JOB_DELIM}'" -noheader -J "$JOB_NAME" 2>/dev/null || true
}

get_job_info() {
    local jobid="$1"
    bjobs -o "${JOB_FMT} delimiter='${JOB_DELIM}'" -noheader "$jobid" 2>/dev/null || true
}

parse_job_line() {
    # Parse a caret-delimited job line into variables
    local line="$1"
    IFS='^' read -r P_JOBID P_STAT P_HOST P_CPUS P_RUNTIME P_TIMELEFT P_START <<< "$line"
    # Extract per-slot rusage mem from bjobs -l
    P_SLOT_MEM=$(bjobs -l "$P_JOBID" 2>/dev/null | grep -o 'rusage\[mem=[0-9.]*\]' | head -1 | grep -o '[0-9.]*')
    P_SLOT_MEM="${P_SLOT_MEM%%.*}"  # strip decimal
}

extract_host() {
    # "20*noderome113" -> "noderome113"
    local raw="$1"
    echo "${raw#*\*}"
}

print_ssh_config() {
    local jobid="$1"
    local host="$2"
    echo "Host ${host}"
    echo "    HostName ${host}"
    echo "    User ${USER}"
    echo "    ProxyJump stjude"
}

print_ssh_block() {
    # Uses P_JOBID P_STAT P_HOST P_CPUS P_MEM P_RUNTIME P_TIMELEFT P_START

    if [[ -z "$P_HOST" || "$P_HOST" == "-" ]]; then
        echo "# Job $P_JOBID — pending (no host yet)"
        echo ""
        return
    fi

    local host
    host=$(extract_host "$P_HOST")

    echo "# --- Job $P_JOBID | started $P_START ---"
    # Calculate total memory: per-slot rusage × CPUs
    local total_mem="${P_SLOT_MEM:-?} MB/slot"
    if [[ "${P_SLOT_MEM:-}" =~ ^[0-9]+$ && "$P_CPUS" =~ ^[0-9]+$ ]]; then
        local total_gb=$(( P_SLOT_MEM * P_CPUS / 1000 ))
        total_mem="${total_gb} GB (${P_SLOT_MEM} MB/slot × ${P_CPUS})"
    fi
    # Convert running time from "NNN second(s)" to HH:MM
    local runtime_fmt="$P_RUNTIME"
    if [[ "$P_RUNTIME" =~ ^([0-9]+)\ second ]]; then
        local secs="${BASH_REMATCH[1]}"
        runtime_fmt="$(( secs / 3600 )):$(printf '%02d' $(( (secs % 3600) / 60 )))"
    fi
    echo "# CPUs: $P_CPUS | Mem: ${total_mem} | Running: $runtime_fmt | Left: $P_TIMELEFT"
    print_ssh_config "$P_JOBID" "$host"
    echo "# code --remote ssh-remote+${host} /home/${USER}"
    echo ""
}

# --- commands ---

cmd_submit() {
    if [[ ! -f "$LSF_SCRIPT" ]]; then
        echo "Error: $LSF_SCRIPT not found." >&2
        exit 1
    fi
    bsub < "$LSF_SCRIPT"
    echo ""
    echo "Run 'vsc-lsf.sh ssh' after the job starts to get SSH config."
}

cmd_ls() {
    local jobs
    jobs=$(bjobs -o "jobid stat exec_host queue start_time run_time" -J "$JOB_NAME" 2>/dev/null || true)
    if [[ -z "$jobs" ]]; then
        echo "No jrocker jobs found."
        return
    fi
    echo "$jobs"
}

cmd_ssh() {
    local target_jobid="${1:-}"

    if [[ -n "$target_jobid" ]]; then
        local info
        info=$(get_job_info "$target_jobid")
        if [[ -z "$info" ]]; then
            echo "Error: Job $target_jobid not found." >&2
            exit 1
        fi
        parse_job_line "$info"
        if [[ "$P_STAT" != "RUN" ]]; then
            echo "# Job $P_JOBID is $P_STAT (not running yet)"
            return
        fi
        print_ssh_block
        return
    fi

    # All running jobs
    local jobs
    jobs=$(get_running_jobs)
    if [[ -z "$jobs" ]]; then
        echo "No running jrocker jobs found."
        return
    fi

    local count=0
    while IFS= read -r line; do
        parse_job_line "$line"
        if [[ "$P_STAT" == "RUN" ]]; then
            print_ssh_block
            (( ++count ))
        fi
    done <<< "$jobs"

    if [[ $count -eq 0 ]]; then
        echo "No running jrocker jobs found (all pending?)."
    fi
}

cmd_cancel() {
    local target="${1:-}"
    if [[ -z "$target" ]]; then
        echo "Usage: vsc.sh cancel <JOBID|all>" >&2
        exit 1
    fi

    if [[ "$target" == "all" ]]; then
        local jobids
        jobids=$(bjobs -o "jobid" -noheader -J "$JOB_NAME" 2>/dev/null | tr -d ' ')
        if [[ -z "$jobids" ]]; then
            echo "No jrocker jobs to cancel."
            return
        fi
        echo "Cancelling all jrocker jobs:"
        while IFS= read -r jid; do
            echo "  bkill $jid"
            bkill "$jid"
        done <<< "$jobids"
    else
        echo "  bkill $target"
        bkill "$target"
    fi
}

cmd_clean() {
    local target="${1:-}"

    if [[ -n "$target" ]]; then
        local out="${LOG_DIR}/${LOG_PREFIX}.out.${target}"
        local err="${LOG_DIR}/${LOG_PREFIX}.err.${target}"
        local found=0
        for f in "$out" "$err"; do
            if [[ -f "$f" ]]; then
                rm "$f"
                echo "Removed $f"
                found=1
            fi
        done
        local conf_file
        conf_file=$(find "$CONF_DIR" -maxdepth 1 -name "*-${target}.conf" 2>/dev/null | head -1 || true)
        if [[ -n "$conf_file" ]]; then
            rm "$conf_file"
            echo "Removed $conf_file"
            found=1
        fi
        if [[ $found -eq 0 ]]; then
            echo "No files found for job $target"
        fi
    else
        # Get all active job IDs (PEND + RUN)
        local active_jobids
        active_jobids=$(bjobs -o "jobid" -noheader -J "$JOB_NAME" 2>/dev/null | tr -d ' ' || true)

        local removed=0

        # Remove log/err files for jobs no longer active
        while IFS= read -r f; do
            local jobid="${f##*.}"
            if ! grep -qx "$jobid" <<< "$active_jobids" 2>/dev/null; then
                rm "$f"
                echo "Removed $(basename "$f")"
                removed=$(( removed + 1 ))
            fi
        done < <(find "$LOG_DIR" -maxdepth 1 \( -name "${LOG_PREFIX}.out.*" -o -name "${LOG_PREFIX}.err.*" \) 2>/dev/null)

        # Remove conf files for jobs no longer active
        while IFS= read -r f; do
            local fname
            fname=$(basename "$f" .conf)
            local jobid="${fname##*-}"
            if ! grep -qx "$jobid" <<< "$active_jobids" 2>/dev/null; then
                rm "$f"
                echo "Removed $f"
                removed=$(( removed + 1 ))
            fi
        done < <(find "$CONF_DIR" -maxdepth 1 -name "*-*.conf" 2>/dev/null)

        if [[ $removed -eq 0 ]]; then
            echo "No stale files found."
        fi
    fi
}

write_ssh_conf() {
    # Writes SSH config (same as ssh command output) to a file
    if [[ -z "$P_HOST" || "$P_HOST" == "-" ]]; then
        echo "# Job $P_JOBID — pending (no host yet), skipped"
        return
    fi

    local host
    host=$(extract_host "$P_HOST")
    local conf_file="${CONF_DIR}/${host}-${P_JOBID}.conf"

    print_ssh_block > "$conf_file"

    echo "$conf_file"
}

cmd_conf() {
    mkdir -p "$CONF_DIR"
    local target_jobid="${1:-}"

    if [[ -n "$target_jobid" ]]; then
        local info
        info=$(get_job_info "$target_jobid")
        if [[ -z "$info" ]]; then
            echo "Error: Job $target_jobid not found." >&2
            exit 1
        fi
        parse_job_line "$info"
        if [[ "$P_STAT" != "RUN" ]]; then
            echo "# Job $P_JOBID is $P_STAT (not running yet)"
            return
        fi
        write_ssh_conf
        return
    fi

    # All running jobs
    local jobs
    jobs=$(get_running_jobs)
    if [[ -z "$jobs" ]]; then
        echo "No running jrocker jobs found."
        return
    fi

    while IFS= read -r line; do
        parse_job_line "$line"
        if [[ "$P_STAT" == "RUN" ]]; then
            write_ssh_conf
        fi
    done <<< "$jobs"
}

# --- main ---

cmd="${1:-help}"
shift || true

case "$cmd" in
    submit)     cmd_submit "$@" ;;
    ls|list)    cmd_ls "$@" ;;
    ssh)        cmd_ssh "$@" ;;
    cancel|kill) cmd_cancel "$@" ;;
    clean)      cmd_clean "$@" ;;
    conf)       cmd_conf "$@" ;;
    help|-h|--help) usage ;;
    *)
        echo "Unknown command: $cmd" >&2
        usage >&2
        exit 1
        ;;
esac
