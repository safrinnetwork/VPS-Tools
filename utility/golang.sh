#!/bin/bash

# 1. Cek apakah wget dan tar sudah terinstal, dan instal jika tidak ada
echo "Checking if wget and tar are installed..."
missing_packages=()

if ! command -v wget &> /dev/null; then
    echo "wget is not installed."
    missing_packages+=("wget")
fi

if ! command -v tar &> /dev/null; then
    echo "tar is not installed."
    missing_packages+=("tar")
fi

if [ ${#missing_packages[@]} -gt 0 ]; then
    echo "Installing missing packages: ${missing_packages[@]}"

    # Cek distribusi dan gunakan package manager yang sesuai
    if [ -f /etc/debian_version ]; then
        echo "Detected Debian/Ubuntu-based distribution."
        sudo apt update
        sudo apt install -y "${missing_packages[@]}"
    elif [ -f /etc/redhat-release ]; then
        echo "Detected RedHat-based distribution."
        sudo yum install -y "${missing_packages[@]}"
    elif [ -f /etc/fedora-release ]; then
        echo "Detected Fedora-based distribution."
        sudo dnf install -y "${missing_packages[@]}"
    else
        echo "Unsupported distribution. Please install wget and tar manually."
        exit 1
    fi
else
    echo "wget and tar are already installed."
fi

# 2. Download Go 1.23.2
echo "Downloading Go 1.23.2..."
wget https://go.dev/dl/go1.23.2.linux-amd64.tar.gz -O go.tar.gz
if [ $? -ne 0 ]; then
    echo "Error: Failed to download Go."
    exit 1
fi

# 3. Remove existing Go installation if it exists
if [ -d "/usr/local/go" ]; then
    echo "Removing existing Go installation..."
    sudo rm -rf /usr/local/go
fi

# 4. Extract Go to /usr/local
echo "Extracting Go to /usr/local..."
sudo tar -xzvf go.tar.gz -C /usr/local
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract Go."
    exit 1
fi

# 4.1 Clean up by removing the downloaded tar.gz file
echo "Cleaning up..."
rm go.tar.gz

# 5. Backup existing .bashrc
echo "Backing up current .bashrc to .bashrc.bak..."
cp ~/.bashrc ~/.bashrc.bak

# 6. Append Go paths to .bashrc if not already present
if ! grep -q "/usr/local/go/bin" ~/.bashrc; then
    echo "Adding Go paths to .bashrc..."
    echo -e "\n# Golang Path\nexport PATH=\$PATH:/usr/local/go/bin\nexport GOPATH=\$HOME/go\nexport PATH=\$PATH:\$HOME/go/bin" >> ~/.bashrc
else
    echo "Go paths already exist in .bashrc."
fi

# 7. Apply changes to the current session and check for errors
echo "Applying changes..."
source ~/.bashrc

if ! command -v go &> /dev/null; then
    echo "Error: PATH update failed. Please check ~/.bashrc for correctness."
    exit 1
fi

# 8. Check Go version
echo "Checking Go version..."
go version
if [ $? -ne 0 ]; then
    echo "Error: Go installation failed or PATH is not set correctly."
    exit 1
fi

echo "Go installation and configuration completed successfully!"
