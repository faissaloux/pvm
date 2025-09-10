

function Uninstall-PHP {
    param ($version)

    try {
        
        $phpPath = Get-PHP-Path-By-Version -version $version

        if (-not $phpPath) {
            $installedVersions = Get-Matching-PHP-Versions -version $version
            $pathVersionObject = Get-UserSelected-PHP-Version -installedVersions $installedVersions
        } else {
            $pathVersionObject = @{ code = 0; version = $version; path = $phpPath }
        }

        if (-not $pathVersionObject) {
            return @{ code = -1; message = "PHP version $version was not found!"; color = "DarkYellow"}
        }
        
        if ($pathVersionObject.code -ne 0) {
            return $pathVersionObject
        }
        
        if (-not $pathVersionObject.path) {
            return @{ code = -1; message = "PHP version $($pathVersionObject.version) was not found!"; color = "DarkYellow"}
        }
        
        $currentVersion = Get-Current-PHP-Version
        if ($currentVersion -and ($($pathVersionObject.version) -eq $currentVersion.version)) {
            $response = Read-Host "`nYou are trying to uninstall the currently active PHP version ($($pathVersionObject.version)). Are you sure? (y/n)"
            $response = $response.Trim()
            if ($response -ne "y" -and $response -ne "Y") {
                return @{ code = -1; message = "Uninstallation cancelled"}
            }
        }

        Remove-Item -Path ($pathVersionObject.path) -Recurse -Force
        
        return @{ code = 0; message = "PHP version $($pathVersionObject.version) has been uninstalled successfully"; color = "DarkGreen" }
    } catch {
        $logged = Log-Data -data @{
            header = "$($MyInvocation.MyCommand.Name) - Failed to uninstall PHP version '$version'"
            exception = $_
        }
        return @{ code = -1; message = "Failed to uninstall PHP version '$version'"; color = "DarkYellow" }
    }
}
