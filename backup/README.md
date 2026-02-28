# MikroTik Backup
A simple backup solution to automate system backups and configuration exports with a basic retention policy.

## Features

* **Full Backup**: Generates both a hardware-specific `.backup` file and a hardware-independent `.rsc` (plain-text) export.
* **Backup retention**: Automatically identifies and removes the oldest files based on the `last-modified` file property to maintain a user-defined limit.

## Configuration

The script can be configured to match your needs with the following local variables:

| Variable | Description |
| :--- | :--- |
| `maxOldBackups` | The maximum number of files to keep for each backup type. Set to 0 for unlimited |
| `backupPassword` | The password used to encrypt the `.backup` binary file. |
| `backupPath` | The directory on your storage (e.g., `storage/backups`) where files are saved. |

## Installation

1.  Open **Winbox**
2.  Navigate to **System -> Scripts**
3.  Create a new script (e.g., `automated-backup`)
4.  Paste the script code into the **Source** box
5.  Ensure the script has the following **Policies**:
    * `read`
    * `write`
    * `policy`
    * `test`
    * `password`

## Automation (Scheduler)

To run this script automatically every 24 hours:

1.  Navigate to **System -> Scheduler**.
2.  Click the **New** button.
3.  **Name**: `run-daily-backup`.
4.  **Start Time**: Set to your preferred time (e.g., `03:00:00`).
5.  **Interval**: Set to `1d 00:00:00`.
6.  **On Event**: Type exactly `automated-backup` (the name you gave to the backup script).
7.  **Policies**: Ensure they match the script's policies (at minimum `read`, `write`, `policy`, `test`, `password`).
8.  Click **OK**.