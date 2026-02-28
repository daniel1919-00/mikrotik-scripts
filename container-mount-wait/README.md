# MikroTik mount Dependency Wait & Container Start

This script starts the specified containers after the network mount (or any mount really) is reachable (using a very rudimentary check method).

## Configuration

The script can be configured to match your needs with the following local variables:

| Variable | Description |
| :--- | :--- |
| `mountProbeFile` | The relative path to a file that exists on the mounted fs. |
| `containers` | An array of container names to be started. |
| `maxWaitTimeSeconds` | The total time to poll for the NAS before the script times out. |
| `mountsStabilizationWaitSeconds` | A delay after the file is found to let the filesystem stabilize. |
| `logPrefix` | The string used to identify these events in the system log. |

## Installation

1. Open **Winbox**.
2. Navigate to **System -> Scripts**.
3. Create a new script (e.g., `wait-for-nas-mount`).
4. Paste the script code into the **Source** box.
5. Ensure the script has the following **Policies**:
    * `read`
    * `write`
    * `policy`
    * `test`

## Automation (Scheduler)

To run this script automatically on every system boot:

1. Navigate to **System -> Scheduler**.
2. Click the **New** button.
3. **Name**: `run-containers-on-boot`.
4. **Start Time**: Set to `startup`.
5. **Interval**: Set to `00:00:00` (to ensure it only runs once per boot).
6. **On Event**: Type exactly `wait-for-nas-mount` (the name you gave to the script).
7. **Policies**: Ensure they match the script's policies.
8. Click **OK**.