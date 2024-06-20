packer {
  required_plugins {
    virtualbox = {
      version = "~> 1"
      source  = "github.com/hashicorp/virtualbox"
    }

    vagrant = {
      version = "~> 1"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

variable "debian_version" {}

source "virtualbox-iso" "debian" {
  guest_os_type  = "Debian_64"
  headless       = true
  cpus           = "2"
  memory         = "1024"
  disk_size      = "20000"
  iso_url        = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-${var.debian_version}-amd64-netinst.iso"
  iso_checksum   = "file:https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"
  http_directory = "unattended"
  boot_wait      = "5s"
  boot_command = [
    "<esc><wait>",
    "install <wait>",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian.cfg <wait>",
    "debian-installer=en_US <wait>",
    "debian-installer/quiet=false <wait>",
    "debian-installer/verbose=true <wait>",
    "auto <wait>",
    "locale=en_US <wait>",
    "kbd-chooser/method=us <wait>",
    "netcfg/get_hostname={{ .Name }} <wait>",
    "netcfg/get_domain=local <wait>",
    "fb=false <wait>",
    "debconf/frontend=noninteractive <wait>",
    "console-setup/ask_detect=false <wait>",
    "console-keymaps-at/keymap=fr <wait>",
    "keyboard-configuration/xkb-keymap=fr-latin9 <enter>"
  ]
  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
  ]
  ssh_username     = "vagrant"
  ssh_password     = "vagrant"
  ssh_timeout      = "20m"
  shutdown_command = "sudo shutdown --poweroff now"
}

build {
  sources = [
    "source.virtualbox-iso.debian"
  ]

  provisioner "shell" {
    inline = [
      "sudo apt install --assume-yes python3 python3-pip"
    ]
  }

  post-processor "vagrant" {
    keep_input_artifact = true
    provider_override   = "virtualbox"
  }
}
