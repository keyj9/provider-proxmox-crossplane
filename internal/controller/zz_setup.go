// SPDX-FileCopyrightText: 2024 The Crossplane Authors <https://crossplane.io>
//
// SPDX-License-Identifier: Apache-2.0

package controller

import (
	ctrl "sigs.k8s.io/controller-runtime"

	"github.com/crossplane/upjet/pkg/controller"

	initdisk "github.com/joekky/provider-proxmox-crossplane/internal/controller/cloud/initdisk"
	disk "github.com/joekky/provider-proxmox-crossplane/internal/controller/lxc/disk"
	providerconfig "github.com/joekky/provider-proxmox-crossplane/internal/controller/providerconfig"
	lxc "github.com/joekky/provider-proxmox-crossplane/internal/controller/proxmox/lxc"
	pool "github.com/joekky/provider-proxmox-crossplane/internal/controller/proxmox/pool"
	iso "github.com/joekky/provider-proxmox-crossplane/internal/controller/storage/iso"
	qemu "github.com/joekky/provider-proxmox-crossplane/internal/controller/vm/qemu"
)

// Setup creates all controllers with the supplied logger and adds them to
// the supplied manager.
func Setup(mgr ctrl.Manager, o controller.Options) error {
	for _, setup := range []func(ctrl.Manager, controller.Options) error{
		initdisk.Setup,
		disk.Setup,
		providerconfig.Setup,
		lxc.Setup,
		pool.Setup,
		iso.Setup,
		qemu.Setup,
	} {
		if err := setup(mgr, o); err != nil {
			return err
		}
	}
	return nil
}
