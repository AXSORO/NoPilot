## hello, i hate copilot and windows 11 is full of some garbage that it seemingly doesn't want you to remove.
## if you don't need genAI in your face all the time while being held hostage within the windows ecosystem, this is for you :3
# I highly recommend just using Win11 IoT LTSC, but reinstalling is a pain in the ass.

<#
    NoPilot.ps1
    Removal of Microsoft's forced AI slop.

    Outline
    - step 0: set environment variables
    - step 1: show current status
    - step 2: show quick help / undo note
    - step 3: confirm to proceed
    - step 4: disable Copilot/search bits (optional telemetry kill switch)
    - step 5: stop related services/tasks
    - step 6: show status again
    - step 7: prompt to reboot

    Caveats:
    - Needs admin for HKLM policy toggles; will warn if you forgot elevation.
    - Some settings are per-user (taskbar button) and some are per-machine (policy).
    - Explorer/taskbar might need a restart, but a reboot is the cleanest bet.
    - Future Windows updates could re-flip these; rerun after big updates.
#>

###########################################################################
# step 0: set environment variables / script metadata
###########################################################################
$env:NoPilotVersion = "0.0.1"
$env:NoPilotAuthor = "leo"

$Colors = @{
    Title   = "Cyan"
    Info    = "Gray"
    Warn    = "Yellow"
    Error   = "Red"
    Success = "Green"
    Muted   = "DarkGray"
    Accent  = "DarkCyan"
}

$NoPilotArt = @"
                    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⠴⠒⠒⠒⠒⠢⠤⢄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                    ⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⣠⠞⠁⠀⠚⠋⢀⣠⡤⠤⠤⢤⣟⠲⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀
                    ⠀⠀⠀⠀⢀⡞⢩⡖⠛⡾⠁⠀⠀⠀⡠⠊⠁⠀⠀⢰⣶⣶⡄⠙⢮⡙⢗⡄⠀⠀⠀⠀⠀⠀
                    ⠀⠀⠀⠀⢸⡅⢻⡀⡼⠁⠀⠀⠀⡜⠀⠀⠀⠀⠀⠀⠈⠉⠀⠀⠀⠻⡈⡇⠀⠀⠀⠀⠀⠀
                    ⠀⠀⠀⠀⠀⠳⣄⠉⠁⠀⠀⠀⢸⠁⠀⣀⠤⠖⠊⠉⠉⠉⠉⠒⢦⡀⠃⢸⡀⠀⠀⠀⠀⠀
                    ⠀⠀⠀⠀⠀⠀⢸⡏⠀⠀⠀⠀⢸⡴⠋⠀⠀⢀⠀⠀⠀⠀⡀⠀⠀⠙⢿⡀⢣⠀⠀⠀⠀⠀
                    ⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⢀⡼⠁⠀⢠⡇⠀⣿⠛⢿⡄⠀⣇⣆⠀⡆⠀⢹⣼⡄⠀⠀⠀⠀
                    ⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⣸⠃⢢⣷⣸⡇⣀⢿⠀⢸⣇⡀⣹⣼⡀⠰⠀⢘⣿⡇⠀⠀⠀⠀
                    ⠀⠀⠀⠀⠀⠀⢸⡇⠀⢀⡏⢀⠾⠴⢟⡛⣟⠛⠀⣸⠙⠈⣷⡟⠺⢿⣾⠾⣿⠁⠀⠀⠀⠀
                    ⠀⠀⠀⠀⠀⠀⢸⠃⠀⢸⢳⢾⡀⠰⣹⣿⠏⠀⠀⠀⠀⠀⢻⣿⣷⢬⣿⣴⠿⠀⠀⠀⠀⠀
                    ⠀⠀⠀⠀⠀⠀⡜⠀⠀⡞⠻⡇⠀⠀⠉⠉⠀⠀⠀⠀⠀⠀⠀⠈⠉⣼⠏⠙⡄⠀⠀⠀⠀⠀
                    ⠀⠀⠀⠀⠀⢰⠃⢀⣼⣆⠀⣙⣦⠀⠀⠀⠀⠀⠀⠤⠀⠀⠀⠀⣰⢻⠀⠀⣿⠀⠀⠀⠀⠀
                    ⠀⠀⠀⠀⢀⡇⢀⠎⠘⠀⠑⠏⠋⠙⢤⡀⠀⠀⠠⠦⠀⢀⡤⢾⠃⢸⠀⠀⠰⣇⠀⠀⠀⠀
                    ⠀⠀⠀⠀⠘⣇⡇⠀⠀⠀⠀⠀⠀⠀⠀⠈⠑⢶⣶⣶⠚⠉⠀⢸⠀⢠⠀⠀⠀⠙⣆⠀⠀⠀
                    ⠀⠀⠀⢀⡾⠛⡇⠀⠀⠀⠀⠀⠀⠀⣠⠔⠊⢁⣿⣿⠓⠠⣄⡈⡀⢸⠀⠀⠀⠀⢸⠀⠀⠀
                    ⠀⠀⢀⡞⠁⠀⠘⠢⡀⠀⠀⣠⡔⠋⠀⡠⠀⢸⠉⠁⠀⠠⠀⠉⠃⢸⠀⠀⢀⣴⡁⠀⠀⠀
                    ⠀⠀⡼⠀⠀⠀⠀⠘⠈⠁⠉⠉⠀⠀⠀⠀⠀⠀⡆⠀⠀⠀⠐⠄⡇⢸⠉⠉⠁⠀⢱⡄⠀⠀
                    ⠀⣼⠁⠀⠀⠀⠀⠀⠘⠀⠀⠀⠀⠀⠀⠀⠀⠀⣧⢠⢦⠀⠀⠀⣧⠃⠀⠀⠀⠇⠀⢳⠀⠀
                    ⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⠘⠛⠀⠀⠀⠀⠀⠀⠀⠀⢸⡀⢸⡇⠀
                    ⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠈⡇⠀
                    ⢸⠀⠀⠀⠀⢠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢳⠀
                    ⠈⡆⠀⠀⠀⠀⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣴⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⡇

░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓███████▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓██████▓▒░▒▓████████▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░     
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░     
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░░▒▓█▓▒░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░     
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░     
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░     
░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓█▓▒░      ░▒▓█▓▒░▒▓████████▓▒░▒▓██████▓▒░  ░▒▓█▓▒░   





"@
###########################################################################
# helpers and targets
###########################################################################

function Test-IsAdmin {
    $current = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($current)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# registry settings check
$Script:NoPilotTargets = @(
    @{
        Name = "Taskbar Copilot button (HKCU)"
        Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        ValueName = "ShowCopilotButton"
        DisableValue = 0
        EnableValue = 1
        Type = "DWord"
        NeedsAdmin = $false
    },
    @{
        Name = "Search web/Bing in start (HKCU)"
        Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
        ValueName = "BingSearchEnabled"
        DisableValue = 0
        EnableValue = 1
        Type = "DWord"
        NeedsAdmin = $false
    },
    @{
        Name = "Search cloud suggestions (HKCU)"
        Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
        ValueName = "CortanaConsent"
        DisableValue = 0
        EnableValue = 1
        Type = "DWord"
        NeedsAdmin = $false
    },
    @{
        Name = "Search suggestions/web (policy HKLM)"
        Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
        ValueName = "DisableSearchBoxSuggestions"
        DisableValue = 1
        EnableValue = 0
        Type = "DWord"
        NeedsAdmin = $true
    },
    @{
        Name = "Search web integration (policy HKLM)"
        Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
        ValueName = "DisableWebSearch"
        DisableValue = 1
        EnableValue = 0
        Type = "DWord"
        NeedsAdmin = $true
    },
    @{
        Name = "Copilot availability flag (HKCU)"
        Path = "HKCU:\Software\Microsoft\Windows\Shell\Copilot"
        ValueName = "IsCopilotAvailable"
        DisableValue = 0
        EnableValue = 1
        Type = "DWord"
        NeedsAdmin = $false
    },
    @{
        Name = "Windows Copilot policy kill switch (HKLM)"
        Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
        ValueName = "TurnOffWindowsCopilot"
        DisableValue = 1
        EnableValue = 0
        Type = "DWord"
        NeedsAdmin = $true
    }
)

function Get-RegistryValue {
    param(
        [hashtable]$Target
    )

    try {
        return Get-ItemPropertyValue -Path $Target.Path -Name $Target.ValueName -ErrorAction Stop
    } catch {
        return $null
    }
}

function Set-RegistryValue {
    param(
        [hashtable]$Target,
        [Parameter(Mandatory = $true)]$Value
    )

    if (-not (Test-Path $Target.Path)) {
        New-Item -Path $Target.Path -Force | Out-Null
    }

    New-ItemProperty -Path $Target.Path -Name $Target.ValueName -Value $Value -PropertyType $Target.Type -Force | Out-Null
}

function Get-CopilotServices {
    try {
        return Get-Service -Name "*copilot*" -ErrorAction Stop
    } catch {
        return @()
    }
}

function Get-CopilotTasks {
    try {
        return Get-ScheduledTask | Where-Object { $_.TaskName -match "copilot" -or $_.TaskPath -match "copilot" }
    } catch {
        return @()
    }
}

$Script:TelemetryTargets = @(
    @{
        Name = "Telemetry (policy)"
        Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
        ValueName = "AllowTelemetry"
        DisableValue = 0
        EnableValue = 1
        Type = "DWord"
        NeedsAdmin = $true
    },
    @{
        Name = "Commercial data opt-in (policy)"
        Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
        ValueName = "CommercialDataOptIn"
        DisableValue = 0
        EnableValue = 1
        Type = "DWord"
        NeedsAdmin = $true
    },
    @{
        Name = "Customer Experience Improvement Program"
        Path = "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows"
        ValueName = "CEIPEnable"
        DisableValue = 0
        EnableValue = 1
        Type = "DWord"
        NeedsAdmin = $true
    }
)

function Get-CopilotAppxPackages {
    try {
        return Get-AppxPackage -AllUsers | Where-Object {
            $_.Name -in $Script:CopilotAppxTargets -or
            $_.Name -match $Script:CopilotAppxMatcher -or
            $_.PackageFullName -match $Script:CopilotAppxMatcher
        }
    } catch {
        return @()
    }
}

# Telemetry services/tasks we consider safe to disable.
$Script:TelemetryServices = @(
    "DiagTrack",                    # Connected User Experiences and Telemetry
    "dmwappushservice",             # WAP push
    "dmwappushsvc",                 # alt name on some builds
    "diagnosticshub.standardcollector.service" # aggressive; generally safe to stop
)

$Script:TelemetryTasks = @(
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
)

$Script:CopilotAppxMatcher = "Copilot"
$Script:CopilotAppxTargets = @(
    "MicrosoftWindows.Client.CoreAI",
    "MicrosoftWindows.Client.WebExperience"
)

function Confirm-YesNo {
    param(
        [string]$Prompt = "Continue? (y/N)"
    )

    $answer = Read-Host $Prompt
    return ($answer -match "^[Yy]")
}

function Write-LineSplit {
    param(
        $label,
        $value,
        $detail = "",
        $labelColor = $Colors.Info,
        $valueColor = $Colors.Success,
        $detailColor = $Colors.Muted
    )

    Write-Host (" - {0}: " -f $label) -NoNewline -ForegroundColor $labelColor
    Write-Host $value -NoNewline -ForegroundColor $valueColor
    if ($detail) {
        Write-Host (" {0}" -f $detail) -NoNewline -ForegroundColor $detailColor
    }
    Write-Host ""
}

function Pause-Beat {
    param([int]$Milliseconds = 250)
    Start-Sleep -Milliseconds $Milliseconds
}

###########################################################################
# step 1: show current Copilot status
###########################################################################
function Show-CopilotStatus {
    Write-Host "`n[Status] Current Copilot Settings:" -ForegroundColor $Colors.Title

    foreach ($target in $Script:NoPilotTargets) {
        $current = Get-RegistryValue -Target $target
        $state =
            if ($null -eq $current) { "not set (Windows default)" }
            elseif ($current -eq $target.DisableValue) { "OFF" }
            elseif ($current -eq $target.EnableValue) { "ON" }
            else { "Unknown Value(?): $current" }

        $detail = if ($null -eq $current) { "" } else { " (raw: $current at $($target.Path)\$($target.ValueName))" }
        $valueColor = switch -regex ($state) {
            'OFF' { $Colors.Success }
            'not set' { $Colors.Error }
            'ON' { $Colors.Error }
            default { $Colors.Warn }
        }
        Write-LineSplit $target.Name $state $detail $Colors.Info $valueColor $Colors.Muted
    }

    $services = Get-CopilotServices
    if ($services.Count -gt 0) {
        Write-Host " - Services:" -ForegroundColor $Colors.Accent
        $services | ForEach-Object {
            Write-Host "   * " -NoNewline -ForegroundColor $Colors.Info
            Write-Host $_.Name -NoNewline -ForegroundColor $Colors.Accent
            Write-Host ": " -NoNewline -ForegroundColor $Colors.Info
            $svcColor = switch ($_.Status) {
                "Running" { $Colors.Error }
                "Stopped" { $Colors.Success }
                default { $Colors.Warn }
            }
            Write-Host $_.Status -ForegroundColor $svcColor
        }
    } else {
        Write-Host " - Services: No Copilot Services found." -ForegroundColor $Colors.Muted
    }

    $tasks = Get-CopilotTasks
    if ($tasks.Count -gt 0) {
        Write-Host " - Scheduled Tasks:" -ForegroundColor $Colors.Accent
        $tasks | ForEach-Object {
            Write-Host "   * " -NoNewline -ForegroundColor $Colors.Info
            Write-Host ("{0}{1}" -f $_.TaskPath, $_.TaskName) -NoNewline -ForegroundColor $Colors.Accent
            Write-Host " : " -NoNewline -ForegroundColor $Colors.Info
            $taskColor = switch ($_.State) {
                "Disabled" { $Colors.Success }
                "Ready" { $Colors.Error }
                default { $Colors.Warn }
            }
            Write-Host $_.State -ForegroundColor $taskColor
        }
    } else {
        Write-Host " - Scheduled Tasks: No Copilot Tasks found." -ForegroundColor $Colors.Muted
    }
}

###########################################################################
# step 2: quick help / undo note
###########################################################################
function Show-QuickHelp {
    Write-Host "`n[What does this do?]" -ForegroundColor $Colors.Title
    Write-Host " - Hides the Copilot button and turns off Copilot policies." -ForegroundColor $Colors.Info
    Write-Host " - Turns off Bing/cloud search suggestions." -ForegroundColor $Colors.Info
    Write-Host " - Stops Copilot services/tasks; optional: stops telemetry services/tasks + policies." -ForegroundColor $Colors.Info
    Write-Host " - Undo: run NoPilot_reset.bat (restores Copilot/search bits; telemetry stays off)." -ForegroundColor $Colors.Warn
    Write-Host " - Run as administrator for full effect." -ForegroundColor $Colors.Warn
}

###########################################################################
# step 3: disable Copilot 
###########################################################################
function Disable-Copilot {
    Write-Host "`n[Action] Setting HKCU/HKLM keys..." -ForegroundColor $Colors.Title

    $isAdmin = Test-IsAdmin
    if (-not $isAdmin) {
        Write-Host " - Not elevated. HKLM writes may fail; run as admin for full effect." -ForegroundColor $Colors.Warn
    }

    foreach ($target in $Script:NoPilotTargets) {
        if ($target.NeedsAdmin -and -not $isAdmin) {
            Write-LineSplit $target.Name "skipped (needs admin)" "" $Colors.Warn $Colors.Warn $Colors.Warn
            continue
        }

        try {
            Set-RegistryValue -Target $target -Value $target.DisableValue
            Write-Host " - " -NoNewline -ForegroundColor $Colors.Info
            Write-Host $target.Name -NoNewline -ForegroundColor $Colors.Accent
            Write-Host " -> " -NoNewline -ForegroundColor $Colors.Info
            Write-Host ("set {0}\{1} = {2}" -f $target.Path, $target.ValueName, $target.DisableValue) -ForegroundColor $Colors.Success
        } catch {
            Write-Host " - " -NoNewline -ForegroundColor $Colors.Info
            Write-Host $target.Name -NoNewline -ForegroundColor $Colors.Accent
            Write-Host " -> failed: " -NoNewline -ForegroundColor $Colors.Info
            Write-Host $_.Exception.Message -ForegroundColor $Colors.Error
        }
    }
}

function Disable-Telemetry {
    Write-Host "`n[Action] Disabling telemetry-related policies..." -ForegroundColor $Colors.Title

    $isAdmin = Test-IsAdmin
    if (-not $isAdmin) {
        Write-Host " - Not elevated. Telemetry policy writes need admin; run as admin for full effect." -ForegroundColor $Colors.Warn
    }

    foreach ($target in $Script:TelemetryTargets) {
        if ($target.NeedsAdmin -and -not $isAdmin) {
            Write-LineSplit $target.Name "skipped (needs admin)" "" $Colors.Warn $Colors.Warn $Colors.Warn
            continue
        }

        try {
            Set-RegistryValue -Target $target -Value $target.DisableValue
            Write-Host " - " -NoNewline -ForegroundColor $Colors.Info
            Write-Host $target.Name -NoNewline -ForegroundColor $Colors.Accent
            Write-Host " -> " -NoNewline -ForegroundColor $Colors.Info
            Write-Host ("set {0}\{1} = {2}" -f $target.Path, $target.ValueName, $target.DisableValue) -ForegroundColor $Colors.Success
        } catch {
            Write-Host " - " -NoNewline -ForegroundColor $Colors.Info
            Write-Host $target.Name -NoNewline -ForegroundColor $Colors.Accent
            Write-Host " -> failed: " -NoNewline -ForegroundColor $Colors.Info
            Write-Host $_.Exception.Message -ForegroundColor $Colors.Error
        }
    }
}

function Disable-CopilotServicesAndTasks {
    Write-Host "`n[Action] Stopping Copilot related Services and Scheduled Tasks..." -ForegroundColor $Colors.Title

    $isAdmin = Test-IsAdmin
    if (-not $isAdmin) {
        Write-Host " - Not elevated. Service disables may fail; run as admin for full effect." -ForegroundColor $Colors.Warn
    }

    $services = Get-CopilotServices
    if ($services.Count -eq 0) {
        Write-Host " - No services matched." -ForegroundColor $Colors.Muted
    } else {
        foreach ($svc in $services) {
            try {
                if ($svc.Status -ne 'Stopped') {
                    Stop-Service -Name $svc.Name -Force -ErrorAction Stop
                }
                Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction Stop
                Write-Host (" - Service {0}: stopped + disabled" -f $svc.Name) -ForegroundColor $Colors.Success
            } catch {
                Write-Host (" - Service {0}: failed -> {1}" -f $svc.Name, $_.Exception.Message) -ForegroundColor $Colors.Error
            }
        }
    }

    $tasks = Get-CopilotTasks
    if ($tasks.Count -eq 0) {
        Write-Host " - No scheduled tasks matched." -ForegroundColor $Colors.Muted
    } else {
        foreach ($task in $tasks) {
            try {
                Disable-ScheduledTask -TaskPath $task.TaskPath -TaskName $task.TaskName -ErrorAction Stop | Out-Null
                Write-Host (" - Task {0}{1}: disabled" -f $task.TaskPath, $task.TaskName) -ForegroundColor $Colors.Success
            } catch {
                Write-Host (" - Task {0}{1}: failed -> {2}" -f $task.TaskPath, $task.TaskName, $_.Exception.Message) -ForegroundColor $Colors.Error
            }
        }
    }
}

function Disable-TelemetryServicesAndTasks {
    Write-Host "`n[Action] Stopping telemetry-related Services and Scheduled Tasks..." -ForegroundColor $Colors.Title

    $isAdmin = Test-IsAdmin
    if (-not $isAdmin) {
        Write-Host " - Not elevated. Service/task disables may fail; run as admin for full effect." -ForegroundColor $Colors.Warn
    }

    foreach ($svcName in $Script:TelemetryServices) {
        try {
            $svc = Get-Service -Name $svcName -ErrorAction Stop
            if ($svc.Status -ne 'Stopped') {
                Stop-Service -Name $svc.Name -Force -ErrorAction Stop
            }
            Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction Stop
            Write-Host (" - Service {0}: stopped + disabled" -f $svc.Name) -ForegroundColor $Colors.Success
        } catch {
            Write-Host (" - Service {0}: not found or failed -> {1}" -f $svcName, $_.Exception.Message) -ForegroundColor $Colors.Muted
        }
    }

    foreach ($taskPath in $Script:TelemetryTasks) {
        try {
            $parts = $taskPath.Split('\')
            $taskName = $parts[-1]
            $taskFolder = ($taskPath -replace [regex]::Escape($taskName) + '$','')
            Disable-ScheduledTask -TaskPath $taskFolder -TaskName $taskName -ErrorAction Stop | Out-Null
            Write-Host (" - Task {0}: disabled" -f $taskPath) -ForegroundColor $Colors.Success
        } catch {
            Write-Host (" - Task {0}: not found or failed -> {1}" -f $taskPath, $_.Exception.Message) -ForegroundColor $Colors.Muted
        }
    }
}

function Remove-CopilotAppx {
    Write-Host "`n[Action] Looking for Copilot app packages (CoreAI/WebExperience)..." -ForegroundColor $Colors.Title

    $isAdmin = Test-IsAdmin
    if (-not $isAdmin) {
        Write-Host " - Not elevated. App removal may fail; run as admin for full effect." -ForegroundColor $Colors.Warn
    }

    $packages = Get-CopilotAppxPackages
    if ($packages.Count -eq 0) {
        Write-Host " - No targeted AppX packages were found." -ForegroundColor $Colors.Muted
        return
    }

    foreach ($pkg in $packages) {
        Write-Host (" - Found {0} ({1})" -f $pkg.Name, $pkg.PackageFullName) -ForegroundColor $Colors.Info
        try {
            Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction Stop
            Write-Host "   removed for all users." -ForegroundColor $Colors.Success
        } catch {
            Write-Host ("   removal failed -> {0}" -f $_.Exception.Message) -ForegroundColor $Colors.Error
        }

        try {
            Remove-AppxProvisionedPackage -Online -PackageName $pkg.PackageFamilyName -ErrorAction Stop | Out-Null
            Write-Host "   removed from provisioning." -ForegroundColor $Colors.Success
        } catch {
            Write-Host ("   provisioning removal failed -> {0}" -f $_.Exception.Message) -ForegroundColor $Colors.Muted
        }
    }
}

###########################################################################
# step 4: show status again
###########################################################################
# (we'll just call Show-CopilotStatus again later)

###########################################################################
# step 5: prompt reboot
###########################################################################
function Prompt-Reboot {
    $answer = Read-Host "`nReboot now? You have to at some point. (y/N)"
    if ($answer -match "^[Yy]") {
        Write-Host "Rebooting in 5 seconds. Save your stuff." -ForegroundColor $Colors.Info
        shutdown.exe /r /t 5 | Out-Null
    } else {
        Write-Host "Fine, but expect to restart Explorer or reboot later for full effect." -ForegroundColor $Colors.Warn
    }
}

###########################################################################
# main flow
###########################################################################
Write-Host "=== NoPilot v$($env:NoPilotVersion) :: Copilot Removal Tool ===" -ForegroundColor $Colors.Title
Write-Host $NoPilotArt -ForegroundColor $Colors.Info
Write-Host "[Heads-up]  If you're insane and want CoPilot back, run NoPilot_reset.bat." -ForegroundColor $Colors.Info
if (-not (Test-IsAdmin)) {
    Write-Host "[Error] Run this script in PowerShell as Administrator for changes to apply. Exiting." -ForegroundColor $Colors.Error
    return
}
Show-CopilotStatus
Show-QuickHelp

if (-not (Confirm-YesNo "[Confirm] Proceed with disabling Copilot/search bits? (y/N)")) {
    Write-Host "No changes made. Exiting." -ForegroundColor $Colors.Warn
    return
}
Pause-Beat 300

Disable-Copilot
Pause-Beat 300
if (Confirm-YesNo "[Optional] Also disable telemetry-related policies? (y/N)") {
    Disable-Telemetry
    Disable-TelemetryServicesAndTasks
} else {
    Write-Host "Telemetry left as-is." -ForegroundColor $Colors.Info
}
if (Confirm-YesNo "[Optional] Try removing Copilot app packages (CoreAI/WebExperience) if present? (y/N)") {
    Remove-CopilotAppx
} else {
    Write-Host "Copilot appx left as-is." -ForegroundColor $Colors.Info
}
Pause-Beat 300
Disable-CopilotServicesAndTasks
Pause-Beat 300
Show-CopilotStatus
Prompt-Reboot

Write-Host "`nbye bye!" -ForegroundColor $Colors.Title
