#!/bin/bash
# shellcheck source=helper_functions.sh
source "${SCRIPTSDIR}/helper_functions.sh"

if [[ ${RCON_ENABLED} = 1 ]]; then
  LogWarn "Unable to reboot. RCON is required."
  exit 1
fi

countdown_message "${AUTO_REBOOT_WARN_MINUTES}" "Server will reboot"
countdown_exit_code=$?
case "${countdown_exit_code}" in
0)
  LogAction "Rebooting the server."
  exit 0
  ;;
1)
  LogError "Unable to auto reboot, AUTO_REBOOT_WARN_MINUTES is empty"
  exit 1
  ;;
2)
  LogError "Unable to auto reboot, AUTO_REBOOT_WARN_MINUTES is not an integer: ${AUTO_REBOOT_WARN_MINUTES}"
  exit 1
  ;;
esac
