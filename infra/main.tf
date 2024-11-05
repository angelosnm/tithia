locals {
  vm_names = ["tithia-spark-master", "tithia-spark-worker-1", "tithia-spark-worker-2"]
}

resource "proxmox_vm_qemu" "spark" {
  count       = 3
  vmid        = 110 + count.index
  name        = local.vm_names[count.index]
  target_node = "marco"
  clone       = "ubuntu22-cloud-init"
  full_clone  = true
  agent       = 1 # QEMU agent
  cores       = 2
  sockets     = 1
  memory      = 4096

  scsihw   = "virtio-scsi-single"
  bootdisk = "scsi0"

  serial {
    id   = 0
    type = "socket"
  }

  disks {
    scsi { # VM disk
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = 32
        }
      }
    }
    ide { # Cloud-init drive mounted as CD-ROM
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  os_type    = "cloud-init"
  ipconfig0  = "ip=192.168.18.${110 + count.index}/24,gw=192.168.0.1"
  nameserver = "1.1.1.1,9.9.9.9"
  ciuser     = "tithia"
  sshkeys    = <<EOF
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1SY0yAJ/A+ruh+HuT1mzmw1r9ldM8IfNvLK24lIFvFx4Q3WnhQ3MPHBPL3Bl1+Z0V6xjVESntznGJXHOs+7CciU+HqNn+2p34Fh6jr+rHASAVG8OIIx8JhuadxkyMkJjiN9iIc97EUwc7AVmrWG1WKLSqZQIEfAhwg4lVZgwEPyf8v14r77MQJp9s5mI1pb0gwBeN7Ri3p03bbek8lTr4sQ9hKhmYIJg+WHZxkh326tgMNoqBNiuEDI4713A2pdfJGwqx9+CAwlB3e6vMDBHhKH/ls31vYPSfJAD3+8lK97tang7nGncUVbjeD7rPiCsyzj8JsEKasEZJy72TJhDHqfCPMyS/GullT7A/Vxvkb9roT5VU2YTZh7x2IdnEs8Z0gHoLyIIsvK5VIpKs1327ChOvQWYj5De0ddGvlNQ3d2IK2wezzwkYyoLFvxRCvJNWekgldXOsvTAqz1zYl6ixn+fffKGlLsuLpimsMiKSCY7sGzZ1kY2xOBMV950Y6Yk= agelosnm@PC
  EOF
}