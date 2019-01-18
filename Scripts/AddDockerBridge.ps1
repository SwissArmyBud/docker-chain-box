param([string]$name = "default")
# Setup
$NL="`r`n"
$DOCKER_MACHINE_NAME=$name
$VBOX_EXE_PATH='C:/Program Files/Oracle/VirtualBox/'
$VBOX_BRIDGE_NUM=3

${NL}
#############################################################################################

# There "should" only be one gateway, see:
# https://support.microsoft.com/en-us/help/159168/multiple-default-gateways-can-cause-connectivity-problems
ECHO "[INFO] -> Attempting to find the current network gateway..."
Get-NetIPConfiguration | Where-Object {
        $_.IPv4DefaultGateway -ne $null -and
        $_.NetAdapter.Status -ne "Disconnected"
} | ForEach-Object {
    $WINDOWS_GATEWAY = $_.IPv4Address.IPAddress
    $WINDOWS_NETDESC = $_.InterfaceDescription
}

if($WINDOWS_GATEWAY){
    ECHO "[INFO] -> Found Gateway Candiate at: $WINDOWS_GATEWAY"
    ECHO "[INFO] -> Interface is named: $WINDOWS_NETDESC"
} else {
    ECHO "[CRIT] -> Couldn't find Gateway Candidate! Exiting..."
    exit 1
}

${NL}
#############################################################################################

# Stop VM
ECHO "[INFO] -> Stopping Docker Machine boot2docker, called: $DOCKER_MACHINE_NAME"
docker-machine stop $DOCKER_MACHINE_NAME
${NL}

# Add Bridge
ECHO "[INFO] -> Adding $WINDOWS_NETDESC to network bridge for: $DOCKER_MACHINE_NAME"
$VBOX_NIC_CAT =  "--nic$VBOX_BRIDGE_NUM bridged"
$VBOX_NIC_TYPE = "--nictype$VBOX_BRIDGE_NUM 82540EM"
$VBOX_NIC_CON = "--cableconnected$VBOX_BRIDGE_NUM on"
$VBOX_NIC_ADPT = "--bridgeadapter$VBOX_BRIDGE_NUM " + '"' + $WINDOWS_NETDESC + '"'
$VBOX_BRIDGE_OPTS = "$VBOX_NIC_CAT $VBOX_NIC_TYPE $VBOX_NIC_CON $VBOX_NIC_ADPT"
$VBOX_BRIDGE_CMD = "./vboxmanage.exe modifyvm $DOCKER_MACHINE_NAME"
$CUR_WORK_DIR = pwd
CD $VBOX_EXE_PATH
Invoke-Expression "${VBOX_BRIDGE_CMD} ${VBOX_BRIDGE_OPTS}"
CD $CUR_WORK_DIR
${NL}

# Start VM
ECHO "[INFO] -> Starting Docker Machine boot2docker, called: $DOCKER_MACHINE_NAME"
docker-machine start $DOCKER_MACHINE_NAME

${NL}
#############################################################################################

# Try and match the gateway to a windows network and then grab some META
ECHO "[INFO] -> Attempting to determine host CIDR denomination..."
$WIN_CIDR_BLOCK = ""
$LINUX_GREP_FILTER = ""
foreach ($WINDOWS_NETWORK in $(get-netipaddress)){

    $NETIP = $WINDOWS_NETWORK.IPAddress
    $NETSN = $WINDOWS_NETWORK.PrefixLength
    $NETCD = [int][math]::floor($WINDOWS_NETWORK.PrefixLength / 8)
    if($NETCD -eq 0){
        ECHO "[CRIT] -> Determined CIDR exceeds A-Block in size, cannot parse. Exiting..."
        exit 1
    }
    if($NETCD -eq 4){
        ECHO "[CRIT] -> Determined CIDR as 32-bit netmask, bad parse or error. Exiting..."
        exit 1
    }

    if($WINDOWS_NETWORK.AddressFamily -eq "IPv4"){

        $SPLIT_IP = $NETIP.Split(".")
        $SPLIT_GW = $WINDOWS_GATEWAY.Split(".")

        $GATEWAY_TEST = $TRUE
        $CIDR_BLOCK = 0
        $GREP_FILTER = ""

        foreach($TEST_IP_BLOCK in $SPLIT_IP){
            if($CIDR_BLOCK -lt $NETCD){
                if($TEST_IP_BLOCK -eq $SPLIT_GW[$CIDR_BLOCK]){
                    $GREP_FILTER = "${GREP_FILTER}${TEST_IP_BLOCK}."
                } else {
                    $GATEWAY_TEST = $FALSE
                }
            }
            $CIDR_BLOCK += 1
        }

        if($GATEWAY_TEST -eq $TRUE){
            $WIN_CIDR_BLOCK = $NETCD
            $LINUX_GREP_FILTER = $GREP_FILTER
        }

    }

}

if($WIN_CIDR_BLOCK){
    ECHO "[INFO] -> Found CIDR Block: $WIN_CIDR_BLOCK"
    ECHO "[INFO] -> Searching for $LINUX_GREP_FILTER network on boot2docker VM..."
} else {
    ECHO "[CRIT] -> Couldn't determine gateway network! Exiting..."
    exit 1
}

${NL}
#############################################################################################

# Docker networks
$DOCKER_COMMAND = 'ifconfig | grep \"inet addr\" | awk \"{print \$2}\" | awk \"BEGIN{FS=\\\":\\\"} {print \$2;}\" | grep \"' + ${LINUX_GREP_FILTER} + '\"'
$DOCKER_OUTPUT = $(docker-machine ssh $DOCKER_MACHINE_NAME $DOCKER_COMMAND)
if($DOCKER_OUTPUT){
    ECHO "[INFO] -> Your boot2docker VM is now bound to the following network address:"
    foreach($OUTPUT_NETWORK in $DOCKER_OUTPUT){
        ECHO "[INFO] -> $OUTPUT_NETWORK"
        if(Test-Connection -q $OUTPUT_NETWORK){
            ECHO "[INFO] -> Connection test passed across local network, VM ready for containers!"
        } else {
            ECHO "[CRIT] -> Connection test failed across local network, check your firewalls!"
        }
    }
} else {
    ECHO "[CRIT] -> Your boot2docker VM did not return any recognizable addresses! Try restarting the VM and re-running this script?"
}

${NL}
#############################################################################################

# Test local NAT from VirtualBox for original endpoint
$VBOX_LNAT_ADDRESS = "192.168.99.100"
if(Test-Connection -q $VBOX_LNAT_ADDRESS){
    ECHO "[INFO] -> Your boot2docker VM is also available at the following host-local NAT address:"
    ECHO "[INFO] -> $VBOX_LNAT_ADDRESS"
} else {
    ECHO "[CRIT] -> Your boot2docker VM did not respond to a ping on the host-local NAT from VirtualBox?"
}

${NL}
#############################################################################################
