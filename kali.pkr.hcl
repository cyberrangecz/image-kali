packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = "~> 1"
    }
  }
}

variable "boot_wait" {
  type    = string
  default = "10s"
}

variable "cpus" {
  type    = number
  default = 4
}

variable "disk_size" {
  type    = number
  default = 16384
}

variable "guest_os_type" {
  type    = string
  default = "Debian_64"
}

variable "headless" {
  type    = string
  default = "true"
}

variable "http_directory" {
  type    = string
  default = "http"
}

variable "http_port_max" {
  type    = number
  default = 10089
}

variable "http_port_min" {
  type    = number
  default = 10082
}

variable "iso_checksum" {
  type    = string
  default = "5eb9dc96cccbdfe7610d3cbced1bd6ee89b5acdfc83ffee1f06e6d02b058390c"
}

variable "iso_url" {
  type    = string
  default = "https://cdimage.kali.org/kali-2024.2/kali-linux-2024.2-installer-amd64.iso"
}

variable "memory_size" {
  type    = number
  default = 4096
}

variable "shutdown_command" {
  type    = string
  default = "shutdown -P now"
}

variable "ssh_password" {
  type    = string
  default = "toor"
}

variable "ssh_port" {
  type    = number
  default = 22
}

variable "ssh_username" {
  type    = string
  default = "root"
}

variable "ssh_wait_timeout" {
  type    = string
  default = "90m"
}

variable "vm_name" {
  type    = string
  default = "kali"
}

variable "vnc_vrdp_bind_address" {
  type    = string
  default = "127.0.0.1"
}

variable "vnc_vrdp_port" {
  type    = number
  default = 5900
}

variable "boot_command" {
  type = list(string)
  default = ["<esc><wait>", "install ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "debian-installer=en_US.UTF-8 ", "auto ", "locale=en_US.UTF-8 ",
    "kbd-chooser/method=us ", "keyboard-configuration/xkb-keymap=us ",
    "netcfg/get_hostname=kali ", "netcfg/get_domain=kali ", "fb=false ",
    "debconf/frontend=noninteractive ", "console-setup/ask_detect=false ",
    "console-keymaps-at/keymap=us ", "grub-installer/bootdev=/dev/sda",
    "<enter><wait>"
  ]
}

source "qemu" "qemu" {
  boot_command      = var.boot_command
  boot_key_interval = "10ms"
  boot_wait         = var.boot_wait
  disk_interface    = "virtio-scsi"
  disk_size         = var.disk_size
  format            = "raw"
  headless          = var.headless
  http_directory    = var.http_directory
  http_port_max     = var.http_port_max
  http_port_min     = var.http_port_min
  iso_checksum      = var.iso_checksum
  iso_url           = var.iso_url
  net_device        = "virtio-net"
  output_directory  = "target-qemu"
  qemuargs = [
    ["-m", "${var.memory_size}m"],
    ["-smp", "cpus=${var.cpus},maxcpus=16,cores=4"]
  ]
  shutdown_command    = var.shutdown_command
  ssh_password        = var.ssh_password
  ssh_port            = var.ssh_port
  ssh_username        = var.ssh_username
  ssh_wait_timeout    = var.ssh_wait_timeout
  use_default_display = var.headless
  vm_name             = var.vm_name
  vnc_bind_address    = var.vnc_vrdp_bind_address
  vnc_port_max        = var.vnc_vrdp_port
  vnc_port_min        = var.vnc_vrdp_port
}

source "virtualbox-iso" "vbox" {
  boot_command     = var.boot_command
  boot_wait        = var.boot_wait
  disk_size        = var.disk_size
  guest_os_type    = var.guest_os_type
  headless         = var.headless
  http_directory   = var.http_directory
  http_port_max    = var.http_port_max
  http_port_min    = var.http_port_min
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  shutdown_command = "echo 'vagrant' | ${var.shutdown_command}"
  ssh_password     = var.ssh_password
  ssh_port         = var.ssh_port
  ssh_username     = var.ssh_username
  ssh_wait_timeout = var.ssh_wait_timeout
  vboxmanage = [
    ["modifyvm", "{{ .Name }}", "--memory", var.memory_size],
    ["modifyvm", "{{ .Name }}", "--cpus", var.cpus]
  ]
  vm_name           = var.vm_name
  vrdp_bind_address = var.vnc_vrdp_bind_address
  vrdp_port_max     = 5910
  vrdp_port_min     = var.vnc_vrdp_port
}

build {
  sources = [
    "source.qemu.qemu",
    "source.virtualbox-iso.vbox"
  ]

  provisioner "file" {
    destination = "/tmp/cloud.cfg"
    source      = "cloud.cfg"
  }

  provisioner "shell" {
    only = ["qemu.qemu"]
    scripts = [
      "scripts/packages.sh",
      "scripts/fixesQEMU.sh"
    ]
  }

  provisioner "shell" {
    only = ["virtualbox-iso.vbox"]
    scripts = [
      "scripts/addVagrantUser.sh",
      "scripts/guestAdditions.sh",
      "scripts/fixesVBox.sh"
    ]
  }

  provisioner "shell" {
    scripts = [
      "scripts/addKaliUser.sh",
      "scripts/fixes.sh",
      "scripts/vnc.sh",
      "scripts/cleanup.sh"
    ]
  }

  post-processor "vagrant" {
    only                 = ["virtualbox-iso.vbox"]
    output               = "target-vbox/kali.box"
    vagrantfile_template = "Vagrantfile-template"
  }
}
