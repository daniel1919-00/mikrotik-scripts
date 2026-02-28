# MikroTik Scripts

A collection of scripts for MikroTik RouterOS 7.x.

## Repository Structure

Each solution is organized into its own directory containing the script source (`.rsc`) and a specific `README.md` with installation and configuration instructions.

| Script | Description |
| :--- | :--- |
| [**Backup & Rotation**](./backup/README.md) | A simple backup solution for MikroTik devices running **RouterOS 7.x** to automate system backups and configuration exports with a basic retention policy. |
| [**Mounted FS Dependency Wait**](./container-mount-wait/README.md) | This script starts the specified containers after the network mount (or any mount really) is reachable (using a very rudimentary check method). |

## How to Use This Repository

1. **Browse**: Navigate to the folder of the script you need.
2. **Read**: Review the local `README.md` for specific configuration variables (e.g., paths, passwords, or limits).
3. **Deploy**: 
    * Copy the source code into **System -> Scripts** in Winbox.
    * Or upload the `.rsc` file to the router and run `/import file-name.rsc`.

## Logging Configuration

To ensure you can see the output of these scripts in the Winbox Log window, verify your logging settings:

1. Navigate to **System -> Logging**.
2. Under the **Rules** tab, ensure there is a rule for the `script` topic (as well as `warning` and `error` but I think these are there by default).
3. If missing, you can add rules by clicking the **New** button then:
    * **Topics**: `script`
    * **Action**: `memory` (or `echo` / `disk` depending on your preference).