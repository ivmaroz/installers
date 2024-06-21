#!/bin/bash

set -e

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$ROOT_DIR"

PYTHON=""
APP_DIR="$HOME/bin/fake-webcam"
VIDEO_NR=2
CONFIG_DIR="$HOME/.config/fake-webcam"

# https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash
function compare_version() {
  if [[ "$1" == "$2" ]]; then
    return 0
  fi
  local IFS=.
  local i ver1=($1) ver2=($2)
  # fill empty fields in ver1 with zeros
  for ((i = ${#ver1[@]}; i < ${#ver2[@]}; i++)); do
    ver1[i]=0
  done
  for ((i = 0; i < ${#ver1[@]}; i++)); do
    if [[ -z ${ver2[i]} ]]; then
      # fill empty fields in ver2 with zeros
      ver2[i]=0
    fi
    if ((10#${ver1[i]} > 10#${ver2[i]})); then
      return 1
    fi
    if ((10#${ver1[i]} < 10#${ver2[i]})); then
      return 2
    fi
  done
  return 0
}

# Установка необходимых приложений
function install_required() {
  sudo apt update
  sudo apt install -y python3-pip python3-full v4l-utils v4l2loopback-dkms ffmpeg
}

# Установка необходимой версии Python
function install_python() {
  sudo apt install -y software-properties-common
  sudo add-apt-repository ppa:deadsnakes/ppa
  sudo apt install -y python3.11-full
}

# Проверка и установка необходимой версии Python
function check_python_version() {
  while read -r PYTHON; do
    PYTHON_VERSION=$("$PYTHON" --version | awk '{ print $2 }')

    set +e

    compare_version "$PYTHON_VERSION" "3.8.0"
    case $? in
    1) # > - Проверка верхней границы версии
      compare_version "$PYTHON_VERSION" "3.11.99999"
      case $? in
      1) # >
        PYTHON=""
        ;;
      2) ;; # < - Подходящая версия python
      esac
      ;;
    2) # <
      PYTHON=""
      ;;
    esac

    set -e

    if [ -n "$PYTHON" ]; then
      return 0
    fi

  done < <(apt list --installed | grep -Po "python3[0-9.]*/" | sed -E 's/\///' | sort | uniq)

}

function clone_repository() {
  # Клонируем если директории не существует
  if [ ! -d "$APP_DIR" ]; then
    mkdir -p "$APP_DIR"
    git clone https://github.com/fangfufu/Linux-Fake-Background-Webcam "$APP_DIR"
  fi
}

function install_app() {
  cd "$APP_DIR"
  "$PYTHON" -m venv resources
  source resources/bin/activate

  "$PYTHON" -m pip install --upgrade pip
  "$PYTHON" -m pip install --upgrade .
}

function v4l2loopback_install() {
  LOAD_FILE="/etc/modules-load.d/v4l2loopback.conf"
  OPT_FILE="/etc/modprobe.d/linux-fake-background.conf"

  # Try to infer new video device number automatically
  LASTDEV=$(v4l2-ctl --list-devices | grep -Po "(?<=/dev/video).*$" | sort | tail -n 1 | tr -d '\n')
  VIDEO_NR=$(echo "$LASTDEV+1" | bc)

  echo "Creating fake video device with nr. $VIDEO_NR"

  # create load file
  if [ -f $LOAD_FILE ]; then
    echo "File exists: ${LOAD_FILE}"
  else
    echo "v4l2loopback" | sudo tee $LOAD_FILE >/dev/null
    echo "created: ${LOAD_FILE}"
  fi

  # create options file and load the changes
  if [ -f $OPT_FILE ]; then
    echo "file exists: ${OPT_FILE}, no changes have been made"

    VIDEO_NR=$(grep -Po "video_nr=[0-9]+" "$OPT_FILE" | sed 's/video_nr=//')
  else
    echo "options v4l2loopback devices=1 exclusive_caps=1 video_nr=${VIDEO_NR} card_label=\"fake-cam\"" | sudo tee "$OPT_FILE" >/dev/null
    echo "created: ${OPT_FILE}"
    echo "reloading kernel modules..."
    sudo systemctl restart systemd-modules-load.service
    echo "..done"
  fi
}

function create_config() {
  mkdir -p "$CONFIG_DIR"

  if [ ! -f "$CONFIG_DIR/fake-webcam-background.jpg" ]; then
    cp "$ROOT_DIR/fake-webcam/fake-webcam-background.jpg" "$CONFIG_DIR/fake-webcam-background.jpg"
  fi

  cat >"$CONFIG_DIR/config.ini" <<EOL
# Set real webcam width (default: 1280)
width = 640

# Set real webcam height (default: 720)
height = 480

# Set real webcam FPS (default: 30)
#fps = 30

# Set real webcam codec (default: MJPG)
#codec = MJPG

# Set real webcam path (default: /dev/video0)
#webcam-path = /dev/video0

# V4l2loopback device path (default: /dev/video2) ---
#v4l2loopback-path = /dev/video${VIDEO_NR}

# Disable background image and blur the real background
#no-background = no

# Background image path, animated background is supported. (default: background.jpg)
background-image = $CONFIG_DIR/fake-webcam-background.jpg

#Tile the background image (default: False)
#tile-background = no

# The gaussian bluring kernel size in pixels (default: 21)
#background-blur = 21

# The fraction of the kernel size to use for the sigma value (ie. sigma = k / frac) (default: 3)
# background-blur-sigma-frac = 3

# Crop background if needed to maintain aspect ratio (default: False)
#background-keep-aspect = no

# Disable foreground image (default: False)
no-foreground = yes

# Foreground image path (default: foreground.jpg)
#foreground-image = foreground.jpg

# Foreground mask image path (default: foreground-mask.png)
#foreground-mask-image = foreground-mask.png

# Add a hologram effect (default: False)
#hologram = no

# Continue processing when there is no application using the virtual webcam (default: False)
#no-ondemand = no

# The running average percentage for background mask updates (default: 50)
#background-mask-update-speed = 50

# Force the mask to follow a sigmoid distribution (default: False)
#use-sigmoid = no

# The minimum percentage threshold for accepting a pixel as foreground (default: 75)
#threshold = 75

# Disable postprocessing (masking dilation and blurring) (default: True)
#no-postprocess = yes

# Select the model for MediaPipe. For more information, please refer to https://github.com/fangfufu/Linux-Fake-Background-Webcam/issues/135#issuecomment-883361294 (default: 1)
#select-model = 1

# Apply colour map to the person using cmapy. For examples, please refer to https://gitlab.com/cvejarano-oss/cmapy/blob/master/docs/colorize_all_examples.md (default: None)
#cmap-person = none

# Apply colour map to background using cmapy (default: None)
#cmap-bg = none
EOL
}

function create_service() {
  mkdir -p "$HOME/.config/systemd/user"

  cat >"$HOME/.config/systemd/user/fakecam.service" <<EOL
# systemd user unit file for Linux-Fake-Background-Webcam
# place this file into a location suitable for user-defined systemd units
# (e.g $HOME/.config/systemd/user)
#
# To enable and run the fakecam service, run
# systemctl --user enable fakecam.service
# systemctl --user start fakecam.service

[Unit]
Description=Fake camera
After=network.target

[Service]
Type=simple
WorkingDirectory=%h/bin/fake-webcam
ExecStart=%h/bin/fake-webcam/resources/bin/lfbw -c %h/.config/fake-webcam/config.ini
# LFBW exits when pressing Ctrl + \ which corresponds to SIGQUIT
# so we need to specify this kill signal instead of SIGINT
KillSignal=SIGQUIT

[Install]
WantedBy=default.target
EOL

  systemctl --user enable fakecam.service
  systemctl --user start fakecam.service

}

########################################################################################################################

install_required

check_python_version
if [ -z "$PYTHON" ]; then
  install_python
  check_python_version
  if [ -z "$PYTHON" ]; then
    echo "Python not found"
    exit 1
  fi

fi

clone_repository
install_app

v4l2loopback_install
create_config
create_service
