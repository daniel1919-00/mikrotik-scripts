# MikroTik Scripts

A collection of scripts for MikroTik RouterOS 7.x.

## Repository Structure

Each solution is organized into its own directory containing the script source (`.rsc`) and a specific `README.md` with installation and configuration instructions.

| Script | Category | Status | Documentation |
| :--- | :--- | :--- | :--- |
| **Backup & Rotation** | Maintenance | Stable | [View Guide](./backup/README.md) |

## How to Use This Repository

1. **Browse**: Navigate to the folder of the script you need.
2. **Read**: Review the local `README.md` for specific configuration variables (e.g., paths, passwords, or limits).
3. **Deploy**: 
    * Copy the source code into **System -> Scripts** in Winbox.
    * Or upload the `.rsc` file to the router and run `/import file-name.rsc`.