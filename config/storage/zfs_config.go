package storage

import (
	"github.com/crossplane/upjet/pkg/config"
)

// ConfigureZFS configures the ZFS storage resource
func ConfigureZFS(p *config.Provider) {
	p.AddResourceConfigurator("proxmox_virtual_environment_storage_zfs", func(r *config.Resource) {
		r.ExternalName = config.IdentifierFromProvider

		// Configure required fields
		r.TerraformResource.Schema["name"].Required = true
		r.TerraformResource.Schema["pool"].Required = true

		// Configure defaults
		r.ShortGroup = "storage"
		r.Kind = "ZFSStorage"

		// Add references
		r.References["node"] = config.Reference{
			Type: "github.com/crossplane-contrib/provider-proxmox/apis/compute/v1alpha1.Node",
		}
	})
}
