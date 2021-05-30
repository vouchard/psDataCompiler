Remove-Variable * -ErrorAction SilentlyContinue

$log_path = "M:\4003\One Pass Rate\Logs\FCT_logs_2\"
$path_final = -join($env:USERPROFILE,"\Desktop\Compiled_fct_data.txt")

$all_dt = @()
$ttl_logs = Get-ChildItem $log_path
Write-Host ">compilation begins.." -ForegroundColor Cyan
    foreach($aa in $ttl_logs){
        $nm = $aa.FullName
        Write-Host ("...Compiling $nm") -ForegroundColor Cyan
        $bn = $aa.BaseName
        $aa_log = Import-Csv $aa.FullName|Where-Object{$_.ID -ne ""}
        $aa_log|Add-Member -MemberType NoteProperty -Value $bn -Name "Shift_Sched"
        $all_dt +=$aa_log
       

    }
    
Write-Host "Adding members to inital Data Set" -ForegroundColor Magenta

$all_dt|Add-Member -MemberType ScriptProperty -Name "yy" -Value {-join("20",-join($this.ID[0..1]))}
$all_dt|Add-Member -MemberType ScriptProperty -Name "mm" -Value {-join($this.ID[2..3])}
$all_dt|Add-Member -MemberType ScriptProperty -Name "dd" -Value {-join($this.ID[4..5])}
$all_dt|Add-Member -MemberType ScriptProperty -Name "hh" -Value {-join($this.ID[6..7])}
$all_dt|Add-Member -MemberType ScriptProperty -Name "nn" -Value {-join($this.ID[8..9])}
$all_dt|Add-Member -MemberType ScriptProperty -Name "ss" -Value {-join($this.ID[10..11])}
$all_dt|Add-Member -MemberType ScriptProperty -Name "Test_Date" -Value {Get-Date -Year $this.yy -Month $this.mm -Day $this.dd -hour $this.hh -Minute $this.nn -Second $this.ss}
$all_dt|Add-Member -MemberType NoteProperty -Name Test_length -Value "TBD"

$all_dt|Export-Csv -Path $path_final -NoTypeInformation


$by_machine = $all_dt|Group-Object -Property fct_machine

$final_data = @()
foreach($line in $by_machine){
    $machine_name  =  $line.Name
    Write-Host "> Sorting $machine_name" -ForegroundColor Green
    $sorted = $line.Group|Sort-Object -Property Test_date -Descending

    $counter = 0
    $last_date = 0

    Write-Host " ...Calculating Test_length" -ForegroundColor Green

    foreach($ln in $sorted){
         $ln.Test_length = ((Get-Date($last_date)) - (Get-Date($ln.Test_Date))).totalSeconds
         if($ln.Test_length -gt 300){$ln.Test_length = 100}
         if($ln.Test_length -lt 0){$ln.Test_length = 100}
         $ln.Test_length = [int]$ln.Test_length

         $last_date = $ln.Test_date

        }    
    

    $final_data += $sorted

}
Write-Host "EXPORTING DATA PLEASE WAIT" -ForegroundColor White
$final_data|Export-Csv -Path $path_final -NoTypeInformation
Write-Host "Compilation Done" -ForegroundColor Green
Read-Host "PRESS ANY KEY TO EXIT"