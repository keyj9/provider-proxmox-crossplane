package virtualmachine

import (
	"github.com/crossplane/upjet/pkg/config"
)

// Configure configures the proxmox VM group
func Configure(p *config.Provider) {
	p.AddResourceConfigurator("proxmox_virtual_environment_vm", func(r *config.Resource) {
		r.ExternalName = config.IdentifierFromProvider

		// Configure required fields based on your schema
		r.References["node_name"] = config.Reference{
			Type: "Node",
		}

		// Set required fields
		r.TerraformResource.Schema["node_name"].Required = true

		// Configure vm_id as identifier
		r.ExternalName = config.ParameterAsIdentifier("vm_id")

		// Configure defaults and short names
		r.ShortGroup = "virtualmachine"
		r.Kind = "VirtualMachine"
	})
}
