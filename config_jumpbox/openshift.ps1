# Create the directory for OpenShift CLI tool
New-Item -ItemType Directory c:\OC

# Change to that directory
cd c:\OC

# Download the latest openshift windows cli
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-windows.zip -OutFile C:\OC\oc.zip

# Set the path permanently
$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
$newpath = "$oldpath;c:\OC"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath

# Extract the archive
Expand-Archive -Force -Path c:\OC\oc.zip -DestinationPath c:\OC

# Download and Install Azure CLI
$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi

# Install Chocolately
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Chocolately packages
choco install firefox -y
choco install vscode -y
choco install git -y
choco install kubernetes-helm -y
choco install 7zip -y
choco install jq -y