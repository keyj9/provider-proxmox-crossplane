//go:build generate
// +build generate

/*
Copyright 2021 Upbound Inc.
*/

// NOTE: All generation steps are commented out as we're using pre-generated files

// Remove existing CRDs
// //go:generate rm -rf ../package/crds

// Remove generated files
// //go:generate bash -c "find . -iname 'zz_*' ! -iname 'zz_generated.managed*.go' -delete"
// //go:generate bash -c "find . -type d -empty -delete"
// //go:generate bash -c "find ../internal/controller -iname 'zz_*' -delete"
// //go:generate bash -c "find ../internal/controller -type d -empty -delete"
// //go:generate rm -rf ../examples-generated

// Temporarily disabled scraper
// //go:generate go run github.com/crossplane/upjet/cmd/scraper -n ${TERRAFORM_PROVIDER_SOURCE} -r ../.work/${TERRAFORM_PROVIDER_SOURCE}/${TERRAFORM_DOCS_PATH} -o ../config/provider-metadata.yaml

// Run Upjet generator
// //go:generate go run ../cmd/generator/main.go ..

package apis

import (
	_ "sigs.k8s.io/controller-tools/cmd/controller-gen" //nolint:typecheck

	_ "github.com/crossplane/crossplane-tools/cmd/angryjet" //nolint:typecheck
)
