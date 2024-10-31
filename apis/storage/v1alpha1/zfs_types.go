package v1alpha1

import (
	xpv1 "github.com/crossplane/crossplane-runtime/apis/common/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// ZFSStorageParameters defines the desired state of ZFSStorage
type ZFSStorageParameters struct {
	// Name of the ZFS storage pool
	// +kubebuilder:validation:Required
	Name string `json:"name"`

	// ZFS pool name
	// +kubebuilder:validation:Required
	Pool string `json:"pool"`

	// Node name where the storage is located
	// +kubebuilder:validation:Required
	Node string `json:"node"`

	// Thin provisioning
	// +optional
	Thin *bool `json:"thin,omitempty"`

	// Compression algorithm (lz4, gzip, zle)
	// +optional
	Compression string `json:"compression,omitempty"`

	// ZFS ARC cache policy
	// +optional
	CacheMode string `json:"cacheMode,omitempty"`
}

// ZFSStorageSpec defines the desired state of ZFSStorage
type ZFSStorageSpec struct {
	xpv1.ResourceSpec `json:",inline"`
	ForProvider       ZFSStorageParameters `json:"forProvider"`
}

// ZFSStorageStatus defines the observed state of ZFSStorage
type ZFSStorageStatus struct {
	xpv1.ResourceStatus `json:",inline"`
}

// +kubebuilder:object:root=true
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="READY",type="string",JSONPath=".status.conditions[?(@.type=='Ready')].status"
// +kubebuilder:printcolumn:name="SYNCED",type="string",JSONPath=".status.conditions[?(@.type=='Synced')].status"
// +kubebuilder:resource:scope=Cluster,categories={crossplane,managed,proxmox}

// ZFSStorage is the Schema for the ZFSStorage API
type ZFSStorage struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`
	Spec              ZFSStorageSpec   `json:"spec"`
	Status            ZFSStorageStatus `json:"status,omitempty"`
}
