#!/bin/bash
# Launch headless LM Studio once the external models disk is mounted.
# Run by the com.sefk.lmstudio LaunchDaemon, which starts at boot before login,
# when /Volumes/ext1 may not be mounted yet; LM Studio would index an empty models
# dir and not rescan. Waits up to WAIT_SECS, then starts anyway so the API still
# comes up (KeepAlive restarts it if it exits).
MODELS_DIR=${LMSTUDIO_MODELS_DIR:-/Volumes/ext1/lmstudio-models}
WAIT_SECS=${LMSTUDIO_WAIT_SECS:-900}

waited=0
while [ ! -d "$MODELS_DIR" ] && [ "$waited" -lt "$WAIT_SECS" ]; do
	[ "$waited" -eq 0 ] && echo "waiting for $MODELS_DIR"
	sleep 5
	waited=$((waited + 5))
done

if [ -d "$MODELS_DIR" ]; then
	echo "$MODELS_DIR present after ${waited}s"
else
	echo "$MODELS_DIR still missing after ${waited}s; starting anyway"
fi

exec "/Applications/LM Studio.app/Contents/MacOS/LM Studio" --run-as-service
