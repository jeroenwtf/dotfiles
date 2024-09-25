#!/usr/bin/env sh

if sudo -v; then
  # Keep sudo session alive in the background while the script runs
  while true; do sudo -v; sleep 60; done &

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PINK='\033[0;35m'
GREY='\033[1;30m'
NC='\033[0m' # No Color

spinner() {
  local pid=$1
  local package_name=$2
  local delay=0.5
  local spinstr='|/-\'
  local i=0

  # Clear the line before writing the spinner message
  while [ "$(ps a | awk '{print $1}' | grep "$pid")" ]; do
    i=$(( (i+1) %4 ))
    printf "${GREY}[%c] Working on %s...${NC}" "${spinstr:$i:1}" "$package_name"
    sleep $delay
    printf "\r"  # Return to the start of the line
  done
  printf "\r"  # Clear the spinner after the process is done
}

install_pacman_package() {
  if pacman -Q "$1" > /dev/null 2>&1; then
    echo -e "${GREEN}Installed (or already present): $1${NC}"
  else
    sudo pacman -S --needed --noconfirm "$1" > /dev/null 2>&1 &
    pid=$!
    spinner "$pid" "$1"

    if pacman -Q "$1" > /dev/null 2>&1; then
      echo -e "${GREEN}Installed (or already present): $1${NC}"
    else
      echo -e "${RED}Not installed or the installation failed: $1${NC}"
    fi
  fi
}

install_aur_package() {
  if pacman -Q "$1" > /dev/null 2>&1; then
    echo -e "${GREEN}Installed (or already present): $1${NC}"
  else
    yay -S --needed --noconfirm "$1" > /dev/null 2>&1 &
    pid=$!
    spinner "$pid" "$1"

    if pacman -Q "$1" > /dev/null 2>&1; then
      echo -e "${GREEN}Installed (or already present): $1${NC}"
    else
      echo -e "${RED}Failed to install: $1${NC}"
    fi
  fi
}

install_snap_package() {
  sudo snap install "$1" > /dev/null 2>&1 &
  pid=$!
  spinner "$pid" "$1"

  if snap list | grep -q "^$1\s"; then
    echo -e "${GREEN}Installed (or already present): $1${NC}"
  else
    echo -e "${RED}Not installed or the installation failed: $1${NC}"
  fi
}

install_npm_package() {
  if npm list -g --depth=0 | grep -q "$1@"; then
    echo -e "${GREEN}Installed (or already present): $1${NC}"
  else
    npm install -g "$1" > /dev/null 2>&1 &
    pid=$!
    spinner "$pid" "$1"

    if npm list -g --depth=0 | grep -q "$1@"; then
      echo -e "${GREEN}Installed (or already present): $1${NC}"
    else
      echo -e "${RED}Not installed or the installation failed: $1${NC}"
    fi
  fi
}

install_gext_extension() {
  extension_dir="$HOME/.local/share/gnome-shell/extensions/$1"

  if [ -d "$extension_dir" ]; then
    echo -e "${GREEN}Installed (or already present): $1${NC}"
  else
    gext install "$1" > /dev/null 2>&1 &
    pid=$!
    spinner "$pid" "$1"

    if [ -d "$extension_dir" ]; then
      echo -e "${GREEN}Installed (or already present): $1${NC}"
    else
      echo -e "${RED}Not installed or the installation failed: $1${NC}"
    fi
  fi
}

create_symlink() {
  local source="$1"
  local target="$2"

  echo -e "${GREY}Creating symlink...${NC}"
  echo -e "${target} -> ${source}"

  # Check if the symlink already exists
  if [ -L "$target" ]; then
    # Check if it points to the correct source
    if [ "$(readlink "$target")" == "$source" ]; then
      echo -e "${GREEN}Symlink already exists.${NC}"
      return
    else
      echo -e "${YELLOW}Symlink exists but points to a different location: $(readlink "$target")${NC}"
      read -p "Do you want to update the symlink to point to: ${source}? (y/N): " confirm

      if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo -e "${GREY}Skipping update...${NC}"
        return
      fi

      rm "$target"
      echo -e "${GREY}Updating symlink...${NC}"
    fi
  fi

  # Create the symlink silently
  if ln -sf "$source" "$target" > /dev/null 2>&1; then
    echo -e "${GREEN}Symlink created successfully.${NC}"
  else
    echo -e "${RED}Failed to create symlink. Exiting.${NC}"
    exit 1
  fi
}

check_service() {
  local service="$1"

  if systemctl is-enabled "$service" > /dev/null 2>&1; then
    echo -e "${GREEN}Service $service is enabled.${NC}"
  else
    echo -e "${RED}Service $service is not enabled.${NC}"
  fi

  if systemctl is-active "$service" > /dev/null 2>&1; then
    echo -e "${GREEN}Service $service is running.${NC}"
  else
    echo -e "${YELLOW}Service $service is not running.${NC}"
  fi
}


# Gather data
# -----------------------------------------------------------------------------

echo "Hello there!"
echo "We are going to install the dotfiles and set them up."
echo ""
echo -e "${YELLOW}This is not an unattended script.${NC}"
echo "You will be asked for a couple of things and your password at some point."
echo ""
read -p "Press any key to continue..."

echo ""

read -p "Enter your git name [Jeroen van Meerendonk]: " git_name
git_name=${git_name:-"Jeroen van Meerendonk"}

read -p "Enter your git email [hola@jeroen.wtf]: " git_email
git_email=${git_email:-"hola@jeroen.wtf"}

read -p "Enter your GitHub username [jeroenwtf]: " github_username
github_username=${github_username:-"jeroenwtf"}

echo ""


# Install git
# -----------------------------------------------------------------------------

echo -e "${GREY}Installing Git...${NC}"
install_pacman_package git

echo ""


# Clone the dotfiles repository
# -----------------------------------------------------------------------------

echo -e "${GREY}Cloning the dotfiles repo...${NC}"

# Check if the dotfiles folder exists already
if [ -d ~/.dotfiles_test ]; then
  echo -e "${RED}The ~/.dotfiles folder already exists. Exiting.${NC}"
  exit 1
fi

tput civis  # Hide the cursor
git clone -q https://github.com/"$github_username"/dotfiles ~/.dotfiles_test > /dev/null 2>&1 &
pid=$!
spinner "$pid" "that"
tput cnorm  # Show the cursor again

# Ensure the repository was cloned successfully
if [ ! -d ~/.dotfiles_test ]; then
  echo -e "${RED}Dotfiles repo cloning failed. Exiting.${NC}"
  exit 1
else
  echo -e "${GREEN}Dotfiles repo cloned successfully.${NC}"
fi


# Create the symlinks
# -----------------------------------------------------------------------------

declare -A symlinks=(
  ["$HOME/.gitconfig"]="$HOME/.dotfiles/git/.gitconfig"
  ["$HOME/.config/kitty"]="$HOME/.dotfiles/kitty"
  ["$HOME/.config/fish"]="$HOME/.dotfiles/fish"
  ["$HOME/.config/nvim"]="$HOME/.dotfiles/nvim"
)

for target in "${!symlinks[@]}"; do
  source="${symlinks[$target]}"
  echo ""
  create_symlink "${source}" "${target}"
done

echo ""


# Create local gitconfig
# -----------------------------------------------------------------------------

echo -e "${GREY}Updating local .gitconfig...${NC}"

gitconfig_local="$HOME/.gitconfig.local"

cat <<EOL > "$gitconfig_local"
[user]
  name = $git_name
  email = $git_email
EOL

# Check if the file was created successfully
if [ -f "$gitconfig_local" ]; then
  echo -e "${GREEN}Created .gitconfig.local successfully.${NC}"
else
  echo -e "${RED}Failed to create .gitconfig.local. Exiting.${NC}"
  exit 1
fi

echo ""


# Install other packages
# -----------------------------------------------------------------------------

echo -e "${GREY}Installing pacman packages...${NC}"

pacman_pkg_file="$HOME/.dotfiles/pacman.pkgs"

if [ ! -f "$pacman_pkg_file" ]; then
  echo "${RED}Package list file not found ($pacman_pkg_file). Exiting.${NC}"
  exit 1
fi

tput civis  # Hide the cursor
while IFS= read -r pkg; do
  # Skip empty lines and comments (lines starting with #)
  [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue

  install_pacman_package "$pkg"
done < "$pacman_pkg_file"
tput cnorm  # Show the cursor again

echo ""

# ----------

echo -e "${GREY}Installing AUR packages...${NC}"

aur_pkg_file="$HOME/.dotfiles/aur.pkgs"

if [ ! -f "$aur_pkg_file" ]; then
  echo "${RED}Package list file not found ($aur_pkg_file). Exiting.${NC}"
  exit 1
fi

tput civis  # Hide the cursor
while IFS= read -r pkg; do
  # Skip empty lines and comments (lines starting with #)
  [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue

  install_aur_package "$pkg"
done < "$aur_pkg_file"
tput cnorm  # Show the cursor again

echo ""

# ----------

echo -e "${GREY}Enabling snap services...${NC}"

# Enable snap services
sudo systemctl enable --now snapd.socket
sudo systemctl enable --now snapd.apparmor.service

check_service "snapd.socket"
check_service "snapd.apparmor.service"
echo ""

# Avoid reboot by manually starting snap services
sudo mount -t tmpfs tmpfs /var/lib/snapd/snap
create_symlink /var/lib/snapd/snap /snap
echo ""

# ----------

echo -e "${GREY}Installing snap packages...${NC}"

snap_pkg_file="$HOME/.dotfiles/snap.pkgs"

if [ ! -f "$snap_pkg_file" ]; then
  echo "${RED}Package list file not found ($snap_pkg_file). Exiting.${NC}"
  exit 1
fi

tput civis  # Hide the cursor
while IFS= read -r pkg; do
  # Skip empty lines and comments (lines starting with #)
  [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue

  install_snap_package "$pkg"
done < "$snap_pkg_file"
tput cnorm  # Show the cursor again

sudo snap set core experimental.refresh-app-awareness=true

echo ""

# ---------

echo -e "${GREY}Installing node, npm and gnome-extensions-cli...${NC}"

mise use -g node > /dev/null 2>&1
pipx install gnome-extensions-cli --system-site-packages > /dev/null 2>&1

mise use -g node > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Node and npm installed successfully.${NC}"
else
  echo -e "${RED}Failed to install node and npm. Exiting.${NC}"
  exit 1
fi

pipx install gnome-extensions-cli --system-site-packages > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo -e "${GREEN}gnome-extensions-cli installed successfully.${NC}"
else
  echo -e "${RED}Failed to install gnome-extensions-cli. Exiting.${NC}"
  exit 1
fi

echo ""

# ----------

echo -e "${GREY}Installing NPM packages...${NC}"

npm_pkg_file="$HOME/.dotfiles/npm.pkgs"

if [ ! -f "$npm_pkg_file" ]; then
  echo "${RED}Package list file not found ($npm_pkg_file). Exiting.${NC}"
  exit 1
fi

tput civis  # Hide the cursor
while IFS= read -r pkg; do
  # Skip empty lines and comments (lines starting with #)
  [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue

  install_npm_package "$pkg"
done < "$npm_pkg_file"
tput cnorm  # Show the cursor again

echo ""

# ----------

echo -e "${GREY}Installing GNOME extensions...${NC}"

gnome_pkg_file="$HOME/.dotfiles/gnome.pkgs"

if [ ! -f "$gnome_pkg_file" ]; then
  echo "${RED}Package list file not found ($gnome_pkg_file). Exiting.${NC}"
  exit 1
fi

tput civis  # Hide the cursor
while IFS= read -r pkg; do
  # Skip empty lines and comments (lines starting with #)
  [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue

  install_gext_extension "$pkg"
done < "$gnome_pkg_file"
tput cnorm  # Show the cursor again

echo ""


# Set up fish
# -----------------------------------------------------------------------------

echo -e "${GREY}Setting up fish shell...${NC}"

echo -n "Password: "

if chsh -s /usr/bin/fish > /dev/null 2>&1; then
  echo -ne "\r\033[K"
  echo -e "${GREEN}Set default shell as fish successfully.${NC}"
else
  echo -ne "\r\033[K"
  echo "${RED}Setting default shell as fish failed. Exiting.${NC}"
  exit 1
fi

curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish > ~/.config/fish/functions/fisher.fish

if [ -f ~/.config/fish/functions/fisher.fish ]; then
  echo -e "${GREEN}Fisher installed successfully.${NC}"
else
  echo -e "${RED}Failed to install Fisher. Exiting.${NC}"
  exit 1
fi

echo ""
echo -e "${GREY}Installing fish plugins...${NC}"

fish_plugins_file="$HOME/.dotfiles/fish/fish_plugins"

if [ ! -f "$fish_plugins_file" ]; then
  echo "${RED}Package list file not found ($fish_plugins_file). Exiting.${NC}"
  exit 1
fi

fish -c "fisher update" > /dev/null 2>&1

while IFS= read -r plugin; do
  if fish -c "fisher list" | grep -qE "$plugin"; then
    echo -e "${GREEN}Installed (or already present): $plugin${NC}"
  else
    echo -e "${RED}Not installed or the installation failed: $plugin${NC}"
  fi
done < "$fish_plugins_file"

echo ""
echo -e "${GREY}Enabling remaining services...${NC}"

sudo systemctl enable --now docker.service
sudo systemctl enable --now postgresql.service
sudo systemctl enable --now redis.service

check_service "docker"
check_service "postgresql"
check_service "redis"

echo ""


# Set up fish
# -----------------------------------------------------------------------------

# Cast screenshots into the fire
create_symlink /dev/null ~/Pictures/Screenshots

echo ""


# Done!
# -----------------------------------------------------------------------------

echo -e "${PINK}( ੭ ･ᴗ･ )੭ ☆ﾟ.*･｡ﾟ"
echo -e "Setup completed! Don't forget to reboot.${NC}"

else
    echo "You must have sudo privileges to run this script."
    exit 1
fi
