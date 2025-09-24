<# 
Post-Autopilot window: non-closable, determinate progress bar, reboot prompt (always-on-top).
#>

if ([System.Threading.Thread]::CurrentThread.ApartmentState -ne 'STA') {
    $exe = (Get-Process -Id $PID).Path
    $args = @("-NoProfile","-ExecutionPolicy","Bypass","-STA","-File","`"$PSCommandPath`"")
    Start-Process -FilePath $exe -ArgumentList $args
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Win32 helper to bring window to foreground
Add-Type -Namespace Native -Name User32 -MemberDefinition @"
using System;
using System.Runtime.InteropServices;
public static class User32 {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@

# --- Configurable bits ---
$LogoUrl     = 'https://github.com/thisisevilevil/IntunePublic/blob/main/Just%20stuff/ACME_Corporation.png?raw=true'
$WaitMinutes = 10
$Message     = "We are currently finishing the installation of required apps and policies. Please wait a few minutes. When we are finished we will prompt you to reboot the device."
$WindowTitle = "Setting up your device"
# -------------------------

# Download logo (best-effort)
$logoImage = $null
$tempLogo = Join-Path $env:TEMP ("autopilot_logo_{0}.tmp" -f ([System.Guid]::NewGuid()))
try {
    $wc = New-Object System.Net.WebClient
    $wc.Headers.Add('User-Agent','Mozilla/5.0')
    $wc.DownloadFile($LogoUrl, $tempLogo)
    if (Test-Path $tempLogo) {
        $fs = [System.IO.File]::OpenRead($tempLogo)
        try   { $logoImage = [System.Drawing.Image]::FromStream($fs) }
        finally { $fs.Dispose() }
    }
} catch { } finally { if ($wc) { $wc.Dispose() } }

# Build form (non-closable, TopMost)
$form = New-Object System.Windows.Forms.Form -Property @{
    Text            = $WindowTitle
    Size            = New-Object System.Drawing.Size(640, 360)
    StartPosition   = 'CenterScreen'
    FormBorderStyle = 'FixedDialog'
    MaximizeBox     = $false
    MinimizeBox     = $false
    ControlBox      = $false
    TopMost         = $true
    ShowInTaskbar   = $true
    KeyPreview      = $true
}

# Block Alt+F4
$form.Add_KeyDown({
    if ($_.Alt -and $_.KeyCode -eq [System.Windows.Forms.Keys]::F4) {
        $_.Handled = $true
        $_.SuppressKeyPress = $true
    }
})

# Prevent closing unless we explicitly allow it
$allowClose = $false
$form.Add_FormClosing({ if (-not $allowClose) { $_.Cancel = $true } })

# Layout
$panel = New-Object System.Windows.Forms.Panel
$panel.Dock = 'Fill'
$panel.Padding = New-Object System.Windows.Forms.Padding(20)
$form.Controls.Add($panel)

$table = New-Object System.Windows.Forms.TableLayoutPanel
$table.Dock = 'Fill'
$table.ColumnCount = 2
$table.RowCount = 3
$table.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 140)))
$table.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100)))
$table.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize)))
$table.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100)))
$table.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize)))
$panel.Controls.Add($table)

# Logo
$picture = New-Object System.Windows.Forms.PictureBox
$picture.SizeMode = 'Zoom'
$picture.Size = New-Object System.Drawing.Size(120,120)
$picture.Margin = '0,0,20,0'
if ($logoImage) { $picture.Image = $logoImage }
$table.Controls.Add($picture, 0, 0)
$table.SetRowSpan($picture, 3)

# Title (ASCII only)
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Finishing setup..."
$titleLabel.Font = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]::Bold)
$titleLabel.AutoSize = $true
$titleLabel.Dock = 'Top'
$table.Controls.Add($titleLabel, 1, 0)

# Message
$msgLabel = New-Object System.Windows.Forms.Label
$msgLabel.Text = $Message
$msgLabel.Font = New-Object System.Drawing.Font('Segoe UI', 11)
$msgLabel.AutoSize = $false
$msgLabel.Dock = 'Fill'
$msgLabel.Padding = '0,8,0,0'
$msgLabel.UseCompatibleTextRendering = $true
$table.Controls.Add($msgLabel, 1, 1)

# Progress area
$progressPanel = New-Object System.Windows.Forms.Panel
$progressPanel.Dock = 'Bottom'
$progressPanel.Height = 56
$table.Controls.Add($progressPanel, 1, 2)

$progressLabel = New-Object System.Windows.Forms.Label
$progressLabel.Text = "Preparing..."
$progressLabel.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$progressLabel.Dock = 'Top'
$progressLabel.AutoSize = $true
$progressPanel.Controls.Add($progressLabel)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Style = 'Blocks'
$progressBar.Dock = 'Bottom'
$progressBar.Height = 22
$progressPanel.Controls.Add($progressBar)

# Timer & countdown
$totalSeconds = [int]([TimeSpan]::FromMinutes($WaitMinutes).TotalSeconds)
if ($totalSeconds -lt 1) { $totalSeconds = 1 }
$progressBar.Minimum = 0
$progressBar.Maximum = $totalSeconds
$progressBar.Value   = 0

$script:elapsed = 0
$script:secTimer = New-Object System.Windows.Forms.Timer
$script:secTimer.Interval = 1000
$script:secTimer.Add_Tick({
    $script:elapsed++
    if ($script:elapsed -gt $totalSeconds) { $script:elapsed = $totalSeconds }
    $progressBar.Value = $script:elapsed

    $remaining = $totalSeconds - $script:elapsed
    $mm = [int]([math]::Floor($remaining / 60))
    $ss = $remaining % 60
    if ($remaining -gt 0) {
        $progressLabel.Text = ("Installing required apps and policies... {0}:{1:D2} remaining" -f $mm, $ss)
    } else {
        $script:secTimer.Stop()
        $progressLabel.Text = "Finalizing..."

        # --- Make the reboot prompt truly frontmost ---
        $form.TopMost = $true
        $form.Activate()
        $form.BringToFront() | Out-Null
        [Native.User32]::SetForegroundWindow($form.Handle) | Out-Null

        $result = [System.Windows.Forms.MessageBox]::Show(
            $form,  # owner keeps it above other windows
            "Required apps and policies have finished installing.`r`n`r`nWould you like to reboot now?",
            "Reboot required",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )
        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            try {
                Start-Process -FilePath "shutdown.exe" -ArgumentList "/r","/t","0" -WindowStyle Hidden
            } catch {
                Restart-Computer -Force -ErrorAction SilentlyContinue
            }
        } else {
            $titleLabel.Text = "Reboot deferred"
            $msgLabel.Text   = "You can reboot later from the Start menu to complete setup."
            $progressLabel.Text = "You may close this window."
            $allowClose = $true
            $closer = New-Object System.Windows.Forms.Timer
            $closer.Interval = 4000
            $closer.Add_Tick({ $closer.Stop(); $form.Close() })
            $closer.Start()
        }
    }
})
$script:secTimer.Start()

# Cleanup temp logo on close
$form.Add_FormClosed({
    if (Test-Path $tempLogo) { Remove-Item $tempLogo -Force -ErrorAction SilentlyContinue }
    if ($logoImage) { $logoImage.Dispose() }
})

[void]$form.ShowDialog()
