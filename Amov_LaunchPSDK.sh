#!/bin/bash

psdk=$(pwd)
arch=$(uname -m)

eth1=$(ifconfig | grep -E "^(eth|en)" | awk -F':' '{print $1}' | head -n 1)

sudo apt update
sudo apt install libopencv-dev python3-opencv -y


if [ "$(whoami)" != "root" ]; then
    echo "当前不是 root 用户，请以 root 权限重新执行脚本..."
    exit $?  # 退出脚本
fi


run_PSDK() {
 


 echo ""  >> /etc/netplan/01-network-manager-all.yaml


 cd $psdk/build/bin
 sudo ./dji_sdk_demo_linux_cxx

}

Compiler_the_PSDK() {
	
if [ "$arch" == "aarch64" ]; then
    serial_port="/dev/ttyUSB0"

elif [ "$arch" == "x86_64" ]; then
    serial_port="/dev/ttyUSB1"
fi
	sed -i "s|#define LINUX_UART_DEV1    \"/dev/ttyUSB[0-9]\"|#define LINUX_UART_DEV1    \"$serial_port\"|" "$user_path./samples/sample_c++/platform/linux/manifold2/hal/hal_uart.h"
	sed -i "s|#define LINUX_NETWORK_DEV.*|#define LINUX_NETWORK_DEV \"$eth1\"|" ./samples/sample_c++/platform/linux/manifold2/hal/hal_network.h
	sed  "s/eno2/${eth1}/g" ./01-network-manager-all.yaml.back > ./01-network-manager-all.yaml
	sudo cp ./01-network-manager-all.yaml /etc/netplan/01-network-manager-all.yaml

	sudo netplan apply
	cd $psdk
	mkdir build
	cd build
	cmake ..
	make
}
clean_PSDK() {

	cd $psdk
	rm -r build/

}

main(){
	while true; do
		echo "1 run PSDK"
		echo "2 compiler the PSDK"
		echo "3 clean PSDK"
		echo "4 exit"
		read choice
		case $choice in

	    	1) run_PSDK ;;

	    	2) Compiler_the_PSDK ;;

		3) clean_PSDK ;;

		4) exit ;;

	   	*) echo "无效的选择" ;;
		
		esac
	
	done
}

main

