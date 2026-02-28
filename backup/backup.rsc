# Backup Script for MikroTik RouterOS
# This script creates both a binary backup and a plain-text export of the router's configuration.
# Tested with RouterOS 7.21.3

#The maximum number of old backups to keep before rotating out the oldest one. Set to 0 for unlimited.
:local maxOldBackups 2
:local backupPassword "SomePassword"
# Path (make sure not to include a trailing slash) where backups will be stored. Ensure this path exists and has enough space.
:local backupPath "backups"

:local sysName [/system identity get name]
:local osVer [/system package update get installed-version]
:local sysDate [/system clock get date]
:local sysTime [/system clock get time]
:local timeHour [:pick $sysTime 0 2]
:local timeMin [:pick $sysTime 3 5]
:local timeSec [:pick $sysTime 6 8]
:local baseFileName "$sysName V$osVer -- $sysDate $timeHour$timeMin$timeSec"

# Function to get the oldest file with a specific extension in a given path
# Parameters: $1 = Path (e.g., "disk1/backups/"), $2 = Extension (e.g., "backup")
:local getOldest do={
    :local searchedPath $1
    :local searchedExtension $2
    :local oldestFile ""
    :local oldestTime 0
    :local foundFiles [/file find where name~("^" . $searchedPath . "/.*\\." . $searchedExtension . "\$")]
    
    :if ([:len $foundFiles] > 0) do={
        :foreach fileId in=$foundFiles do={
            :local lastModified [/file get $fileId last-modified]
            :local filePath [/file get $fileId name]

            :if ($oldestTime = 0) do={ :set oldestTime $lastModified; :set oldestFile $filePath } else={
                :if ($lastModified < $oldestTime) do={ :set oldestTime $lastModified; :set oldestFile $filePath }
            }
        }
    }

    :return $oldestFile
}

:log info "Backup: Starting rotation and backup process"

# Rotate Backups
:if ($maxOldBackups > 0) do={
    :foreach ext in={"backup"; "rsc"} do={
        :local currentFiles [/file find where name~("^" . $backupPath . "/.*\\." . $ext . "\$")]
        :local count [:len $currentFiles]
        
        :if ($count >= $maxOldBackups) do={
            :local deleteAmount ($count - $maxOldBackups + 1)
            :for i from=1 to=$deleteAmount do={
                :local fileToDelete [$getOldest $backupPath $ext]
                :if ([:len $fileToDelete] > 0) do={
                    :log info "Backup: Rotating out oldest $ext: $fileToDelete"
                    /file remove $fileToDelete
                }
            }
        }
    }
}

# Export Full Binary Backup (Hardware Specific)
/system backup save name="$backupPath/$baseFileName" password=$backupPassword
:log info "Backup: Binary backup created: $baseFileName.backup"

# Export Full Plain Config (Hardware Independent)
/export file="$backupPath/$baseFileName"
:log info "Backup: Plain-text export created: $baseFileName.rsc"

:log info "Backup: Process finished."