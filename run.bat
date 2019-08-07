start "" /MIN "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --window-position=0,0 --window-size=1,1
SET ROPTS=--no-save --no-environ --no-init-file --no-restore --no-Rconsole
R-Portable\App\R-Portable\bin\Rscript.exe %ROPTS% runShinyApp.R 1> ShinyApp.log 2>&1