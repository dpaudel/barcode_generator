# barcode_generator
Shiny app to generate _Code 128_ type barcodes for labels

#### Install the following in the directory where the shiny folder is located
1. Install [GoogleChromePortable](https://portableapps.com/apps/internet/google_chrome_portable)
2. Install [R-Portable](https://sourceforge.net/projects/rportable/)

#### The folder structure should look like this:
+ **GoogleChromePortable**
+ **R-Portable**
+ **shiny**
    - server.R
    - ui.R
+ run.bat
+ runShinyApp.R

#### Customization required:
- Update run.bat with the location of _chrome.exe_ file on local computer.
- Install _shiny_ and _baRcodeR_ packages inside R-portable.

#### To run:
Double click run.bat
