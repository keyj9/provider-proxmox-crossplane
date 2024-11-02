provider_installation {
  filesystem_mirror {
    path = "/terraform/provider-mirror"
  }
  direct {
    exclude = ["github.com/joekky/proxmox"]
  }
}
