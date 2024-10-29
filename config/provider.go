package config

import (
	"github.com/crossplane/upjet/pkg/config"
	"github.com/joekky/provider-proxmox-crossplane/config/container"
	"github.com/joekky/provider-proxmox-crossplane/config/virtualmachine"
)

const (
	modulePath = "github.com/joekky/provider-proxmox-crossplane"
)

// GetProvider returns provider configuration
func GetProvider() *config.Provider {
	pc := config.NewProvider([]config.ExternalName{
		config.NameAsIdentifier,
	})

	for _, configure := range []func(provider *config.Provider){
		// Configure resource groups
		virtualmachine.Configure,
		container.Configure,
	} {
		configure(pc)
	}

	pc.ConfigureResources()
	return pc
}
