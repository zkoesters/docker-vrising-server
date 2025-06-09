#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "${SCRIPTSDIR}/helper_functions.sh"

DiscordMessage "Shutdown" "${DISCORD_PRE_SHUTDOWN_MESSAGE}" "in-progress" "${DISCORD_PRE_SHUTDOWN_MESSAGE_ENABLED}" "${DISCORD_PRE_SHUTDOWN_MESSAGE_URL}"

# Why are we still using this over RCON?
# Because the min wait time for the RCON shutdown command is 1 min
# I dont think waiting 1 min in all shutdown cases is smart (Like host shutdown)

# First we get the hexdec value of the Win PID 
WinHexPID=$(winedbg --command "info proc" | grep -Po '^\s*\K.{8}(?=.*VRisingServer\.exe)')

# Now we convert the hexdec to decimal 
# and use it to send an taskkill via CMD
wine cmd.exe /C "taskkill /pid $(( 0x$WinHexPID ))"

# Wineserver should exit after the gameserver is shutdown,
# so we wait for it
wineserver -w

DiscordMessage "Stop" "${DISCORD_POST_SHUTDOWN_MESSAGE}" "failure" "${DISCORD_POST_SHUTDOWN_MESSAGE_ENABLED}" "${DISCORD_POST_SHUTDOWN_MESSAGE_URL}"
exit 0
# Yeepii, we gracefully shutdown the gameserver! \'-'/
