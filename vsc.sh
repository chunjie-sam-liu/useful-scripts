#!/usr/bin/env bash
# vsc-lsf.sh - Manage LSF jobs for VS Code Remote-SSH compute nodes.
#
# Usage:
#   vsc-lsf.sh submit              Submit a new job (vsc-tunnel-cpu.lsf)
#   vsc-lsf.sh ls                  List all jrocker jobs
#   vsc-lsf.sh ssh                 Show SSH config for all running jobs
#   vsc-lsf.sh ssh <JOBID>         Show SSH config for a specific job
#   vsc-lsf.sh cancel <JOBID>      Cancel a specific job
#   vsc-lsf.sh cancel all          Cancel all jrocker jobs
#   vsc-lsf.sh clean               Remove all log/err files
#   vsc-lsf.sh clean <JOBID>       Remove log/err files for a specific job
#   vsc-lsf.sh help                Show this help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LSF_SCRIPT="${SCRIPT_DIR}/vsc-tunnel-cpu.lsf"
JOB_NAME="jrocker"
USER=$(whoami)

LOG_DIR="/home/cliu68/tmp/errout/jrocker"
LOG_PREFIX="vsc-tunnel-cpu"

usage() {
    sed -n '3,13p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'
}

# --- helpers ---

get_running_jobs() {
    bjobs -o "jobid stat exec_host start_time" -noheader -J "$JOB_NAME" 2>/dev/null || true
}

get_job_info() {
    local jobid="$1"
    bjobs -o "jobid stat exec_host start_time" -noheader "$jobid" 2>/dev/null || true
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
    local jobid="$1"
    local raw_host="$2"
    local start_time="$3"

    if [[ -z "$raw_host" || "$raw_host" == "-" ]]; then
        echo "# Job $jobid — pending (no host yet)"
        echo ""
        return
    fi

    local host
    host=$(extract_host "$raw_host")

    echo "# --- Job $jobid | started $start_time ---"
    print_ssh_config "$jobid" "$host"
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
        local jobid stat raw_host start_time
        read -r jobid stat raw_host start_time <<< "$info"
        if [[ "$stat" != "RUN" ]]; then
            echo "# Job $jobid is $stat (not running yet)"
            return
        fi
        print_ssh_block "$jobid" "$raw_host" "$start_time"
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
        local jobid stat raw_host start_time
        read -r jobid stat raw_host start_time <<< "$line"
        if [[ "$stat" == "RUN" ]]; then
            print_ssh_block "$jobid" "$raw_host" "$start_time"
            ((count++))
        fi
    done <<< "$jobs"

    if [[ $count -eq 0 ]]; then
        echo "No running jrocker jobs found (all pending?)."
    fi
}

cmd_cancel() {
    local target="${1:-}"
    if [[ -z "$target" ]]; then
        echo "Usage: vsc-lsf.sh cancel <JOBID|all>" >&2
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
        if [[ $found -eq 0 ]]; then
            echo "No log files found for job $target"
        fi
    else
        local files
        files=$(find "$LOG_DIR" -name "${LOG_PREFIX}.out.*" -o -name "${LOG_PREFIX}.err.*" 2>/dev/null || true)
        if [[ -z "$files" ]]; then
            echo "No log files found in $LOG_DIR"
            return
        fi
        local count
        count=$(echo "$files" | wc -l)
        echo "Removing $count log file(s) from $LOG_DIR"
        echo "$files" | while IFS= read -r f; do
            rm "$f"
            echo "  Removed $(basename "$f")"
        done
    fi
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
    help|-h|--help) usage ;;
    *)
        echo "Unknown command: $cmd" >&2
        usage >&2
        exit 1
        ;;
esac
