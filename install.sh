#!/bin/bash

# ========================================
# Script Banner and Intro
# ========================================
clear
echo "
 +-+-+-+-+-+-+-+-+-+-+-+-+-+ 
 |j|u|s|t|a|g|u|y|l|i|n|u|x| 
 +-+-+-+-+-+-+-+-+-+-+-+-+-+ 
 |a|w|e|s|o|m|e|w|m| |s|e|t|u|p|  
 +-+-+-+-+-+-+-+-+-+-+-+-+-+                                                                             
"

CLONED_DIR="$HOME/awesomewm-setup"
CONFIG_DIR="$HOME/.config/awesome"
INSTALL_DIR="$HOME/installation"
GTK_THEME="https://github.com/vinceliuice/Orchis-theme.git"
ICON_THEME="https://github.com/vinceliuice/Colloid-icon-theme.git"

# ========================================
# User Confirmation Before Proceeding
# ========================================
echo "This script will install and configure AwesomeWM on your Debian system."
read -p "Do you want to continue? (y/n) " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Installation aborted."
    exit 1
fi

sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get clean

# ========================================
# Initialization
# ========================================
mkdir -p "$INSTALL_DIR" || { echo "Failed to create installation directory."; exit 1; }

cleanup() {
    rm -rf "$INSTALL_DIR"
    echo "Installation directory removed."
}
trap cleanup EXIT

# ========================================
# Check for Existing AwesomeWM Configuration
# ========================================
check_awesome() {
    if [ -d "$CONFIG_DIR" ]; then
        echo "An existing ~/.config/awesome directory was found."
        read -p "Would you like to back it up before proceeding? (y/n) " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
            backup_dir="$HOME/.config/awesome_backup_$timestamp"
            mv "$CONFIG_DIR" "$backup_dir"
            echo "Backup created at $backup_dir"
        else
            echo "Skipping backup. Your existing config will be overwritten."
        fi
    fi
}

# ========================================
# Move Config Files to ~/.config/awesome
# ========================================
setup_awesome_config() {
    echo "Setting up AwesomeWM configuration directory..."
    
    # Create the config directory if it doesn't exist
    mkdir -p "$CONFIG_DIR"
    
    # Check if the cloned repository directory exists
    if [ -d "$CLONED_DIR" ]; then
        # Check if the config directory in the cloned repository exists
        if [ -d "$CLONED_DIR/config" ]; then
            # Copy all contents from the cloned repo's config directory to ~/.config/awesome
            cp -a "$CLONED_DIR/config/." "$CONFIG_DIR/" || { 
                echo "Error: Failed to copy AwesomeWM config contents from $CLONED_DIR/config/."
                exit 1
            }
            echo "AwesomeWM configuration files copied successfully from $CLONED_DIR/config/."
        # Alternative path - check if there's an awesome directory directly in the cloned repo
        elif [ -d "$CLONED_DIR/awesome" ]; then
            # Copy all contents from the cloned repo's awesome directory to ~/.config/awesome
            cp -a "$CLONED_DIR/awesome/." "$CONFIG_DIR/" || {
                echo "Error: Failed to copy AwesomeWM config contents from $CLONED_DIR/awesome/."
                exit 1
            }
            echo "AwesomeWM configuration files copied successfully from $CLONED_DIR/awesome/."
        # If no config directories are found, check if the repo itself contains the config files
        elif [ -f "$CLONED_DIR/rc.lua" ]; then
            # Copy all contents from the cloned repo directly to ~/.config/awesome
            cp -a "$CLONED_DIR/." "$CONFIG_DIR/" || {
                echo "Error: Failed to copy AwesomeWM config contents from $CLONED_DIR/."
                exit 1
            }
            echo "AwesomeWM configuration files copied successfully from $CLONED_DIR/."
        else
            echo "Error: Could not find AwesomeWM configuration files in the cloned repository."
            echo "Please check the structure of your repository and ensure it contains the necessary configuration files."
            exit 1
        fi
    else
        echo "Error: Cloned repository directory ($CLONED_DIR) not found."
        echo "Please make sure you have cloned the repository to $CLONED_DIR before running this script."
        exit 1
    fi
}

# ========================================
# Install Packages
# ========================================
install_packages() {
    echo "Installing required packages..."
    sudo apt-get install -y awesome awesome-extra awesome-doc xorg xorg-dev xbacklight xbindkeys xvkbd xinput build-essential network-manager-gnome pamixer thunar thunar-archive-plugin thunar-volman lxappearance dialog mtools avahi-daemon acpi acpid gvfs-backends xfce4-power-manager pavucontrol pulsemixer tilix feh fonts-recommended fonts-font-awesome fonts-terminus exa suckless-tools redshift flameshot qimgv rofi libnotify-bin xdotool unzip libnotify-dev firefox-esr geany geany-plugin-addons geany-plugin-git-changebar geany-plugin-spellcheck geany-plugin-treebrowser geany-plugin-markdown geany-plugin-insertnum geany-plugin-lineoperations geany-plugin-automark pipewire-audio nala micro xdg-user-dirs-gtk lightdm lua-check || echo "Warning: Package installation failed."
    echo "Package installation completed."
}

enable_services() {
    echo "Enabling required services..."
    sudo systemctl enable avahi-daemon || echo "Warning: Failed to enable avahi-daemon."
    sudo systemctl enable acpid || echo "Warning: Failed to enable acpid."
    echo "Services enabled."
}

setup_user_dirs() {
    echo "Updating user directories..."
    xdg-user-dirs-update || echo "Warning: Failed to update user directories."
    mkdir -p ~/Screenshots/ || echo "Warning: Failed to create Screenshots directory."
    echo "User directories updated."
}

command_exists() {
    command -v "$1" &>/dev/null
}

install_reqs() {
    echo "Installing required dev packages..."
    sudo apt-get install -y cmake meson ninja-build curl pkg-config || { echo "Package installation failed."; exit 1; }
}

install_ftlabs_picom() {
    if command_exists picom; then
        echo "Picom is already installed. Skipping."
        return
    fi
    sudo apt-get install -y libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-dpms0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev libxext-dev meson ninja-build uthash-dev
    git clone https://github.com/FT-Labs/picom "$INSTALL_DIR/picom" || return
    cd "$INSTALL_DIR/picom"
    meson setup --buildtype=release build
    ninja -C build
    sudo ninja -C build install
}

install_fastfetch() {
    if command_exists fastfetch; then
        echo "Fastfetch is already installed. Skipping."
    else
        echo "Installing Fastfetch..."
        git clone https://github.com/fastfetch-cli/fastfetch "$INSTALL_DIR/fastfetch" || return
        cd "$INSTALL_DIR/fastfetch"
        cmake -S . -B build && cmake --build build && sudo mv build/fastfetch /usr/local/bin/
    fi

    echo "Setting up Fastfetch config..."
    mkdir -p "$HOME/.config/fastfetch"
    wget -O "$HOME/.config/fastfetch/config.jsonc" "https://raw.githubusercontent.com/drewgrif/jag_dots/main/.config/fastfetch/config.jsonc" || echo "Warning: Failed to download config.jsonc"
}

install_wezterm() {
    if command_exists wezterm; then
        echo "Wezterm is already installed. Skipping."
        return
    fi
    WEZTERM_URL="https://github.com/wezterm/wezterm/releases/download/20240203-110809-5046fc22/wezterm-20240203-110809-5046fc22.Debian12.deb"
    TMP_DEB="/tmp/wezterm.deb"
    wget -O "$TMP_DEB" "$WEZTERM_URL" && sudo apt install -y "$TMP_DEB" && rm -f "$TMP_DEB"
    mkdir -p "$HOME/.config/wezterm"
    wget -O "$HOME/.config/wezterm/wezterm.lua" "https://raw.githubusercontent.com/drewgrif/jag_dots/main/.config/wezterm/wezterm.lua" || die "Failed to download wezterm config."
}

install_fonts() {
    echo "Installing fonts..."
    mkdir -p ~/.local/share/fonts
    fonts=("FiraCode" "Hack" "JetBrainsMono" "RobotoMono" "SourceCodePro" "UbuntuMono")
    for font in "${fonts[@]}"; do
        if ! ls ~/.local/share/fonts/$font/*.ttf &>/dev/null; then
            wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/$font.zip" -P /tmp && unzip -q /tmp/$font.zip -d ~/.local/share/fonts/$font/ && rm /tmp/$font.zip
        fi
    done
    fc-cache -f
    echo "Fonts installed."
}

install_theming() {
    GTK_THEME_NAME="Orchis-Grey-Dark"
    ICON_THEME_NAME="Colloid-Grey-Dracula-Dark"
    if [ ! -d "$HOME/.themes/$GTK_THEME_NAME" ]; then
        git clone "$GTK_THEME" "$INSTALL_DIR/Orchis-theme"
        cd "$INSTALL_DIR/Orchis-theme"
        yes | ./install.sh -c dark -t teal grey default --tweaks black
    fi
    if [ ! -d "$HOME/.icons/$ICON_THEME_NAME" ]; then
        git clone "$ICON_THEME" "$INSTALL_DIR/Colloid-icon-theme"
        cd "$INSTALL_DIR/Colloid-icon-theme"
        ./install.sh -t teal orange grey -s default gruvbox dracula
    fi
}

change_theming() {
    mkdir -p ~/.config/gtk-3.0
    cat << EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Orchis-Grey-Dark
gtk-icon-theme-name=Colloid-Grey-Dracula-Dark
gtk-font-name=Sans 10
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=0
EOF
    cat << EOF > ~/.gtkrc-2.0
gtk-theme-name="Orchis-Grey-Dark"
gtk-icon-theme-name="Colloid-Grey-Dracula-Dark"
gtk-font-name="Sans 10"
gtk-cursor-theme-name="Adwaita"
gtk-cursor-theme-size=0
EOF
    echo "GTK theming applied."
}

replace_bashrc() {
    echo "Replace your .bashrc with justaguylinux version? (y/n)"
    read response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        [ -f ~/.bashrc ] && mv ~/.bashrc ~/.bashrc.bak
        wget -O ~/.bashrc https://raw.githubusercontent.com/drewgrif/jag_dots/main/.bashrc && source ~/.bashrc
    fi
}


# ========================================
# Main Script Execution
# ========================================
echo "Starting AwesomeWM setup..."
check_awesome
install_packages
enable_services
setup_user_dirs
install_reqs
install_ftlabs_picom
install_fastfetch
install_wezterm
install_fonts
install_theming
setup_awesome_config
change_theming
replace_bashrc
echo "All installations completed successfully!"
echo "Log out and select AwesomeWM from your display manager to start using it."
