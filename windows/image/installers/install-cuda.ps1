Param(
    [Parameter(Mandatory=$false)]
    [string]
    $cudaVersion="latest"
)

$cudaUri = @{
    # Why did the names change???
    "11.0.2" = "11.0.2/network_installers/cuda_11.0.2_win10_network.exe"
    "11.0.3" = "11.0.3/network_installers/cuda_11.0.3_win10_network.exe"
    "11.0"   = "11.0.3/network_installers/cuda_11.0.3_win10_network.exe"
    "11.1.0" = "11.1.0/network_installers/cuda_11.1.0_win10_network.exe"
    "11.1.1" = "11.1.1/network_installers/cuda_11.1.1_win10_network.exe"
    "11.1"   = "11.1.1/network_installers/cuda_11.1.1_win10_network.exe"
    "12.0.0" = "12.0.0/network_installers/cuda_12.0.0_windows_network.exe"
    "12.0.1" = "12.0.1/network_installers/cuda_12.0.1_windows_network.exe"
    "12.0"   = "12.0.1/network_installers/cuda_12.0.1_windows_network.exe"
    "12.1.0" = "12.1.0/network_installers/cuda_12.1.0_windows_network.exe"
    "12.1.1" = "12.1.1/network_installers/cuda_12.1.1_windows_network.exe"
    "12.1"   = "12.1.1/network_installers/cuda_12.1.1_windows_network.exe"
    "12.2"   = "12.2.0/network_installers/cuda_12.2.0_windows_network.exe"
    "12.2.0" = "12.2.0/network_installers/cuda_12.2.0_windows_network.exe"
    "12.3"   = "12.3.0/network_installers/cuda_12.3.0_windows_network.exe"
    "12.3.0" = "12.3.0/network_installers/cuda_12.3.0_windows_network.exe"
    "12.4"   = "12.4.0/network_installers/cuda_12.4.0_windows_network.exe"
    "12.4.0" = "12.4.0/network_installers/cuda_12.4.0_windows_network.exe"
    "latest" = "12.4.0/network_installers/cuda_12.4.0_windows_network.exe"
}[$cudaVersion]

# The component tags don't include patch, so we need to map input to major.minor
$componentTag = @{
    "11.0.2" = "11.0"
    "11.0.3" = "11.0"
    "11.0"   = "11.0"
    "11.1.0" = "11.1"
    "11.1.1" = "11.1"
    "11.1"   = "11.1"
    "12.0.0" = "12.0"
    "12.0.1" = "12.0"
    "12.0"   = "12.0"
    "12.1.0" = "12.1"
    "12.1.1" = "12.1"
    "12.1"   = "12.1"
    "12.2"   = "12.2"
    "12.2.0" = "12.2"
    "12.3"   = "12.3"
    "12.3.0" = "12.3"
    "12.4"   = "12.4"
    "12.4.0" = "12.4"
    "latest" = "12.4"
}[$cudaVersion]

$cudaVersionUrl = "https://developer.download.nvidia.com/compute/cuda/$cudaUri"
$cudaComponents = 
    "nvcc_$componentTag",
    "curand_$componentTag",
    "curand_dev_$componentTag",
    "cudart_$componentTag",
    "cupti_$componentTag",
    "nvrtc_$componentTag",
    "nvrtc_dev_$componentTag",
    "nvml_dev_$componentTag",
    "nvtx_$componentTag"
    
Invoke-WebRequest -Uri "$cudaVersionUrl" -OutFile "./cuda_network.exe" -UseBasicParsing
Start-Process -Wait -PassThru -FilePath .\cuda_network.exe -ArgumentList "-s $cudaComponents"

$ENV:PATH="$ENV:PATH;C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v$componentTag\bin"
$ENV:CUDA_PATH="C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v$componentTag"

Remove-Item .\cuda_network.exe
