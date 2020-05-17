#!/usr/bin/env bash
if [ -z ${1+-1} ]; then
	echo "First argument must be a valid PID"
	exit 1
fi

# sudo -k sysctl kernel.yama.ptrace_scope=0 >/dev/null
# # waits for sudo prompt to finish, then restricts ptrace again
# (while pgrep -x sudo; do
# 	sleep 1;
# done;
# sudo sysctl kernel.yama.ptrace_scope=1 >/dev/null) &

# https://askubuntu.com/questions/146160/what-is-the-ptrace-scope-workaround-for-wine-programs-and-are-there-any-risks
# This can be gotten around by granting reptyr cap_sys_ptrace:
#   `sudo setcap cap_sys_ptrace=eip /usr/bin/reptyr`
# rather than requiring sudo and sysctl every run (and the janky-ass subshell
# that attempts to provide some semblance of security while this check is disabled).

reptyr $1
