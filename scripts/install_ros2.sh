#!/bin/bash

# Function to get the Ubuntu version codename
get_ubuntu_version() {
    # Get Ubuntu version codename
    VERSION_CODENAME=$(lsb_release -c | awk '{print $2}')
    echo $VERSION_CODENAME
}

# Function to check if the current OS version is supported for Jazzy
check_os_version() {
    VERSION=$(get_ubuntu_version)

    # Jazzy supports only Ubuntu 24.04 (Noble)
    if [[ "$VERSION" == "noble" ]]; then
        ROS_DISTRO="jazzy"
        echo "Supported OS: Ubuntu 24.04 (Noble). Proceeding with ROS 2 Jazzy installation."
    # Humble and Iron support only Ubuntu 22.04 (Jammy)
    elif [[ "$VERSION" == "jammy" ]]; then
        ROS_DISTRO="humble or iron"
        echo "Supported OS: Ubuntu 22.04 (Jammy). Proceeding with ROS 2 Humble or Iron installation."
    else
        echo "Unsupported OS version. This script supports only Ubuntu 22.04 (Jammy) or Ubuntu 24.04 (Noble)."
        exit 1
    fi
}

# Call the function to check the OS version
check_os_version

# If the OS is valid, proceed with the installation

# Make sure your system is up-to-date
echo "Updating your system..."
sudo apt update && sudo apt upgrade -y

# Install required dependencies
echo "Installing dependencies..."
sudo apt install curl software-properties-common locales -y

# Generate locales if needed
echo "Setting up locales..."
sudo locale-gen en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# Add the ROS 2 repository depending on the version
if [[ "$ROS_DISTRO" == "jazzy" ]]; then
    # Adding ROS 2 Jazzy repository
    echo "Adding ROS 2 Jazzy repository..."
    sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
elif [[ "$ROS_DISTRO" == "humble or iron" ]]; then
    # Adding ROS 2 Humble/Iron repository
    echo "Adding ROS 2 Humble/Iron repository..."
    sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
fi

# Update the system after adding the ROS repository
echo "Updating package lists..."
sudo apt update

# Install the relevant ROS 2 packages
if [[ "$ROS_DISTRO" == "jazzy" ]]; then
    echo "Installing ROS 2 Jazzy packages..."
    sudo apt install ros-jazzy-desktop -y
elif [[ "$ROS_DISTRO" == "humble or iron" ]]; then
    echo "Installing ROS 2 Humble/Iron packages..."
    sudo apt install ros-humble-desktop -y
    # Alternatively, use `ros-iron-desktop` if you want Iron instead of Humble
fi

# Set up the ROS 2 environment
echo "Setting up ROS 2 environment..."
source /opt/ros/${ROS_DISTRO}/setup.bash

echo "ROS 2 installation complete! You can now try some examples."

