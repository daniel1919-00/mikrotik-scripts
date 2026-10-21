# MikroTik Backup
A simple backup solution to automate system backups and configuration exports with a basic retention policy.

## Features

* **Full Backup**: Generates both a hardware-specific `.backup` file and a hardware-independent `.rsc` (plain-text) export.
* **Safe rotation**: Creates both replacement files and checks that they are nonempty before deleting old backups. A failed creation/check leaves existing backups untouched. The new files are excluded from deletion even if the router clock moves backwards.
* **Backup retention**: Automatically identifies and removes the oldest files based on the `last-modified` file property to maintain a user-defined limit.

## Configuration

The script can be configured to match your needs with the following local variables:

| Variable | Description |
| :--- | :--- |
| `maxOldBackups` | The total number of files to keep for each backup type, including the new file. Set to 0 for unlimited |
| `backupPassword` | The password used to encrypt the `.backup` binary file. |
| `backupPath` | The directory on your storage (e.g., `storage/backups`) where files are saved. |

## Storage and failure behavior

Set the backup path to the actual, existing backup directory (for example, nas/backups). The script checks that the path exists; it does not discover USB disks or prove that a path belongs to a particular SSD. A changing USB mount name must be resolved in the storage configuration. Keep this directory dedicated to backups: rotation matches files by extension.

Allow room for one additional file of each type before rotation. If either creation or verification fails, old backups remain and a partially created new pair may remain for inspection. Nonempty-file checks do not validate restorability or guarantee that cached writes have reached disk. Avoid overlapping scheduled/manual runs.

## Validation

This revision requires validation on RouterOS before deployment; local review is not a router execution test. In a disposable backup directory, check retention at 0, 1, and 2, and confirm a missing/unwritable destination preserves existing files.

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