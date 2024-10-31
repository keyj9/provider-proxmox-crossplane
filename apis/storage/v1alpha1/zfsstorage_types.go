package v1alpha1

import (
	xpv1 "github.com/crossplane/crossplane-runtime/apis/common/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// ZFSStorageParameters defines ZFS-specific parameters
type ZFSStorageParameters struct {
	// Node name
	// +kubebuilder:validation:Required
	Node string `json:"node"`

	// Pool name
	// +kubebuilder:validation:Required
	Pool string `json:"pool"`

	// Compression algorithm
	// +kubebuilder:validation:Enum=on;off;lz4;gzip;zle
	// +optional
	Compression *string `json:"compression,omitempty"`

	// ARC cache mode
	// +kubebuilder:validation:Enum=none;metadata;data;all
	// +optional
	ARC *string `json:"arc,omitempty"`

	// Enable thin provisioning
	// +optional
	Thin *bool `json:"thin,omitempty"`
}

// ZFSStorageSpec defines the desired state of ZFSStorage
type ZFSStorageSpec struct {
	xpv1.ResourceSpec `json:",inline"`
	ForProvider       ZFSStorageParameters `json:"forProvider"`
}

// +kubebuilder:object:root=true

// ZFSStorage is the Schema for ZFS storage
type ZFSStorage struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`
	Spec              ZFSStorageSpec      `json:"spec"`
	Status            xpv1.ResourceStatus `json:"status,omitempty"`
}
