package container

import (
	"github.com/crossplane/upjet/pkg/config"
)

// Configure configures the proxmox container group
func Configure(p *config.Provider) {
	p.AddResourceConfigurator("proxmox_virtual_environment_container", func(r *config.Resource) {
		r.ExternalName = config.IdentifierFromProvider

		// Configure required fields
		r.References["node_name"] = config.Reference{
			Type: "Node",
		}

		r.TerraformResource.Schema["node_name"].Required = true

		// Configure vm_id as identifier
		r.ExternalName = config.ParameterAsIdentifier("vm_id")

		// Configure defaults and short names
		r.ShortGroup = "container"
		r.Kind = "Container"
	})
}
