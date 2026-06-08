# Purpose: Minimize a specified process
# change the target process variable to the name of the process you are wanting to minimize
# Using task schduler on windows, you can set up a time delay/trigger event for when this us run
# set task's action to open powershell then set the optional attribute to the file path of this script

$TargetProcessName = "chrome" 

#Define the C# translator to talk to Windows API, the ability to minimize a window is in user32.dll 
$signature = @"
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
"@
$Type = Add-Type -MemberDefinition $signature -Name "Win32ShowWindow" -Namespace "Win32" -PassThru

# We filter out processes with MainWindowHandle = 0 (background/hidden tasks)
# We also filter out $PID so if you target "powershell", it won't minimize itself
# Reasoning for the filter is 1. to not close the powershell window we are in 2. Most if not all web browsers
# run multiple background processes all under the same name. Only 1 of these is the visual window
# thus, we need to search for the correct process to minimize

$process = Get-Process -Name $TargetProcessName -ErrorAction SilentlyContinue | 
    Where-Object { $_.Id -ne $PID -and $_.MainWindowHandle -ne 0 } | 
    Select-Object -First 1

if ($process) {
    $MINIMIZE = 6
    $Type::ShowWindow($process.MainWindowHandle, $MINIMIZE)
    Write-Host "Successfully minimized '$TargetProcessName' (Process ID: $($process.Id))." -ForegroundColor Green
} else {
    Write-Warning "Could not find an active window for a process named '$TargetProcessName'."
}