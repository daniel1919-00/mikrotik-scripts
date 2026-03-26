# This script waits for a specified file to appear on the NAS mount, indicating that the NAS is ready.

# The file to check for on the NAS mount to confirm it's ready.
# Path must be relative to /
:local mountProbeFile "mountPoint/probeFile.txt"

# Define container names to skip during auto-start
:local exceptions {"certbot"; "temp-test-container"}

#The total wait time for the NAS to become available in seconds (minimum 10)
:local maxWaitTimeSeconds 300

# Time to wait after NAS is detected before starting containers, to allow mounts to stabilize, in seconds.
:local mountsStabilizationWaitSeconds 20
:local logPrefix "Containers:"

:local waitTime [:totime $maxWaitTimeSeconds]
:local mountsStabilizationWaitTime [:totime $mountsStabilizationWaitSeconds]
:local retryCount 0
:local maxRetries ($maxWaitTimeSeconds / 10)

:log info "$logPrefix Waiting for NAS mount (Max wait time: $waitTime)..."

:while ($retryCount < $maxRetries) do={
    :if ([:len [/file find name=$mountProbeFile]] > 0) do={
        :log info "$logPrefix NAS Mount detected."

        :log info "$logPrefix Waiting $mountsStabilizationWaitTime for mounts to stabilize..."
        :delay $mountsStabilizationWaitTime
        :log info "$logPrefix Scanning for containers..."
        
        :foreach containerId in=[/container find] do={
            :local containerName [/container get $containerId name]
            
            # Skip exceptions
            :if ([:typeof [:find $exceptions $containerName]] = "nil") do={
                :log info "$logPrefix Starting container: $containerName"
                /container start $containerId
            } else={
                :log info "$logPrefix Skipping excluded container: $containerName"
            }
        }
        
        :log info "$logPrefix All containers started successfully."

        # Force exit the loop
        :set retryCount ($maxRetries + 1)
    } else={
        :set retryCount ($retryCount + 1)
        :log warning "$logPrefix NAS not ready. Retry $retryCount of $maxRetries..."
        :delay 10s
    }
}

:if ($retryCount = $maxRetries) do={
    :log error "$logPrefix NAS failed to mount after $waitTime. Manual intervention required."
}