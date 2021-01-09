source "virtualbox-iso" "kubernetes-focal" {
    vm_name = "${var.vm_name}"
    guest_os_type = "Ubuntu_64"
    iso_url = "http://releases.ubuntu.com/focal/ubuntu-20.04.1-live-server-amd64.iso"
    iso_checksum = "443511f6bf12402c12503733059269a2e10dec602916c0a75263e5d990f6bb93"
    ssh_username = "${var.ssh_username}"
    ssh_password = "${var.ssh_password}"
    shutdown_command = "echo ${var.ssh_password} | sudo -S shutdown -P now"
    disk_size = "${var.disk_size}"
    cpus = "${var.cpu}"
    memory = "${var.memory}"
    boot_wait = "50s"
    boot_command = [
        "<enter><wait><enter><wait><enter><wait><enter><wait><enter><wait><enter><wait>",
        "<tab><wait><tab><wait><tab><wait><tab><wait><tab><wait><enter><wait>",
        "<enter><wait><down><wait><enter><wait>",
        "${var.ssh_username}<tab><wait>${var.ssh_username}<tab><wait>${var.ssh_username}<tab><wait>${var.ssh_password}<tab><wait>${var.ssh_password}<tab><wait><enter><wait>",
        "<spacebar><wait><tab><wait><tab><wait><enter><wait>",
        "<tab><wait><enter><wait>",
        "<wait10m><enter><wait><enter>"
    ]
}

source "vagrant" "kubernetes-focal" {
    communicator = "ssh"
    source_path = "ubuntu/focal64"
    provider = "virtualbox"
    add_force = true
    output_dir = "./output-vagrant/"
}

build {
    sources = ["sources.vagrant.kubernetes-focal"]
    provisioner "shell" {
        script = "scripts/bootstrap.sh"
        environment_vars = [
            "USER=${var.ssh_username}",
            "PASS=${var.ssh_password}"
        ]
    }
}