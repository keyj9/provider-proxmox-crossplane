package config

import (
	"github.com/crossplane/upjet/pkg/config"
)

// ExternalNameConfigs contains all external name configurations for this provider.
var ExternalNameConfigs = map[string]config.ExternalName{
	"proxmox_virtual_environment_vm":        config.ParameterAsIdentifier("vm_id"),
	"proxmox_virtual_environment_container": config.ParameterAsIdentifier("vm_id"),
}
