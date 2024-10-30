/*
Copyright 2021 Upbound Inc.
*/
package main

import (
	"os"

	"github.com/crossplane/upjet/pkg/pipeline"
	"github.com/joekky/provider-proxmox-crossplane/config"
)

func main() {
	if len(os.Args) < 2 {
		panic("root directory is required to be given as argument")
	}
	rootDir := os.Args[1]
	pipeline.Run(config.GetProvider(), rootDir)
}
