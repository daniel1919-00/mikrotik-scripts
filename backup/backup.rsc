# Backup Script for MikroTik RouterOS
# This script creates both a binary backup and a plain-text export of the router's configuration.
# Targets RouterOS 7.21.3; revised rotation requires on-router validation.

# Total files to retain per extension, including the new backup. Set to 0 for unlimited.
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
# Parameters: $1 = Path without trailing slash, $2 = Extension, $3 = New file to protect
:local getOldest do={
    :local searchedPath $1
    :local searchedExtension $2
    :local protectedFile $3
    :local oldestFile ""
    :local oldestTime
    :local foundFiles [/file find where name~("^" . $searchedPath . "/.*\\." . $searchedExtension . "\$")]
    
    :if ([:len $foundFiles] > 0) do={
        :foreach fileId in=$foundFiles do={
            :if ([/file get $fileId name] != $protectedFile) do={
                :local lastModified [/file get $fileId last-modified]
                :local filePath [/file get $fileId name]

                :if ([:len $oldestFile] = 0) do={ :set oldestTime $lastModified; :set oldestFile $filePath } else={
                    :if ($lastModified < $oldestTime) do={ :set oldestTime $lastModified; :set oldestFile $filePath }
                }
            }
        }
    }

    :return $oldestFile
}

:log info "Backup: Starting rotation and backup process"

# Fail before writing or deleting if the configured destination is unavailable.
:if ([:len [/file find where name=$backupPath]] != 1) do={
    :error "Backup: Destination $backupPath is unavailable"
}
# Avoid overwriting an existing backup if two runs use the same timestamp.
:foreach ext in={"backup"; "rsc"} do={
    :if ([:len [/file find where name="$backupPath/$baseFileName.$ext"]] > 0) do={
        :error "Backup: Filename already exists; refusing to overwrite"
    }
}

# Export Full Binary Backup (Hardware Specific)
/system backup save name="$backupPath/$baseFileName" password=$backupPassword
:log info "Backup: Binary backup created: $baseFileName.backup"

# Export Full Plain Config (Hardware Independent)
/export file="$backupPath/$baseFileName"
:log info "Backup: Plain-text export created: $baseFileName.rsc"

# Do not rotate until both replacement files exist and contain data.
# This checks creation, not restore integrity or persistence through power loss.
:foreach ext in={"backup"; "rsc"} do={
    :local newName "$backupPath/$baseFileName.$ext"
    :local newFile [/file find where name=$newName]
    :if ([:len $newFile] != 1) do={
        :error "Backup: Missing replacement $newName; rotation skipped"
    }
    :if ([/file get $newFile size] <= 0) do={
        :error "Backup: Empty replacement $newName; rotation skipped"
    }
}

# Rotate Backups
:if ($maxOldBackups > 0) do={
    :foreach ext in={"backup"; "rsc"} do={
        :local currentFiles [/file find where name~("^" . $backupPath . "/.*\\." . $ext . "\$")]
        :local count [:len $currentFiles]
        
        :if ($count > $maxOldBackups) do={
            :local deleteAmount ($count - $maxOldBackups)
            :for i from=1 to=$deleteAmount do={
                :local protectedName ($backupPath . "/" . $baseFileName . "." . $ext)
                :local fileToDelete [$getOldest $backupPath $ext $protectedName]
                :if ([:len $fileToDelete] > 0) do={
                    :log info "Backup: Rotating out oldest $ext: $fileToDelete"
                    /file remove $fileToDelete
                }
            }
        }
    }
}

:log info "Backup: Process finished."