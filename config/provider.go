package config

import (
	_ "embed"

	"github.com/crossplane/upjet/pkg/config"
)

//go:embed schema.json
var providerSchema string

const (
	modulePath = "github.com/joekky/provider-proxmox-crossplane"
)

func GetProvider() *config.Provider {
	pc := config.NewProvider(
		[]byte(providerSchema),
		"proxmox",
		modulePath,
		[]byte(""),
		config.WithRootGroup("proxmox.crossplane.io"),
		config.WithIncludeList([]string{
			"proxmox_.*",
		}),
	)

	// Configure VM resource
	pc.AddResourceConfigurator("proxmox_vm_qemu", func(r *config.Resource) {
		r.ShortGroup = "compute"
		r.Kind = "VirtualMachine"
		r.UseAsync = true
	})

	// Configure LXC Container resource
	pc.AddResourceConfigurator("proxmox_lxc", func(r *config.Resource) {
		r.ShortGroup = "compute"
		r.Kind = "Container"
		r.UseAsync = true
	})

	// Configure Storage resource
	pc.AddResourceConfigurator("proxmox_storage", func(r *config.Resource) {
		r.ShortGroup = "storage"
		r.Kind = "Storage"
	})

	// Configure Pool resource
	pc.AddResourceConfigurator("proxmox_pool", func(r *config.Resource) {
		r.ShortGroup = "compute"
		r.Kind = "Pool"
	})

	// Configure default settings for all resources
	pc.AddResourceConfigurator(".*", func(r *config.Resource) {
		r.Version = "v1alpha1"
		r.ExternalName = config.IdentifierFromProvider
	})

	return pc
}
