# This script waits for a specified file to appear on the NAS mount, indicating that the NAS is ready.

# The file to check for on the NAS mount to confirm it's ready.
# Path must be relative to /
:local mountProbeFile "mountPoint/probeFile.txt"

# Define containers that MUST start first (in order)
:local priority {"priority_container1"; "priority_container2"}

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

        :log info "$logPrefix Starting priority stack..."
        :foreach priorityContainerName in=$priority do={
            :local pId [/container find name=$priorityContainerName]
            :if ([:len $pId] > 0) do={
                :log info "$logPrefix Starting priority container: $priorityContainerName"
                /container start $pId
                # Brief delay to allow container to initialize
                :delay 10s
            }
        }

        :log info "$logPrefix Scanning for containers..."
        :foreach containerId in=[/container find] do={
            :local containerName [/container get $containerId name]
            :local isException [:find $exceptions $containerName]
            :local isPriority [:find $priority $containerName]
            
            # Skip exceptions
            :if (([:typeof $isException] = "nil") && ([:typeof $isPriority] = "nil")) do={
                :log info "$logPrefix Starting container: $containerName"
                /container start $containerId
                :delay 1s
            } else={
                :if ([:typeof $isException] != "nil") do={
                    :log info "$logPrefix Skipping excluded container: $containerName"
                }
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