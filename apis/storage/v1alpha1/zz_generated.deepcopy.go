//go:build !ignore_autogenerated

// SPDX-FileCopyrightText: 2024 The Crossplane Authors <https://crossplane.io>
//
// SPDX-License-Identifier: Apache-2.0

// Code generated by controller-gen. DO NOT EDIT.

package v1alpha1

import (
	runtime "k8s.io/apimachinery/pkg/runtime"
)

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Iso) DeepCopyInto(out *Iso) {
	*out = *in
	out.TypeMeta = in.TypeMeta
	in.ObjectMeta.DeepCopyInto(&out.ObjectMeta)
	in.Spec.DeepCopyInto(&out.Spec)
	in.Status.DeepCopyInto(&out.Status)
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Iso.
func (in *Iso) DeepCopy() *Iso {
	if in == nil {
		return nil
	}
	out := new(Iso)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyObject is an autogenerated deepcopy function, copying the receiver, creating a new runtime.Object.
func (in *Iso) DeepCopyObject() runtime.Object {
	if c := in.DeepCopy(); c != nil {
		return c
	}
	return nil
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *IsoInitParameters) DeepCopyInto(out *IsoInitParameters) {
	*out = *in
	if in.Checksum != nil {
		in, out := &in.Checksum, &out.Checksum
		*out = new(string)
		**out = **in
	}
	if in.ChecksumAlgorithm != nil {
		in, out := &in.ChecksumAlgorithm, &out.ChecksumAlgorithm
		*out = new(string)
		**out = **in
	}
	if in.Filename != nil {
		in, out := &in.Filename, &out.Filename
		*out = new(string)
		**out = **in
	}
	if in.PveNode != nil {
		in, out := &in.PveNode, &out.PveNode
		*out = new(string)
		**out = **in
	}
	if in.Storage != nil {
		in, out := &in.Storage, &out.Storage
		*out = new(string)
		**out = **in
	}
	if in.URL != nil {
		in, out := &in.URL, &out.URL
		*out = new(string)
		**out = **in
	}
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new IsoInitParameters.
func (in *IsoInitParameters) DeepCopy() *IsoInitParameters {
	if in == nil {
		return nil
	}
	out := new(IsoInitParameters)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *IsoList) DeepCopyInto(out *IsoList) {
	*out = *in
	out.TypeMeta = in.TypeMeta
	in.ListMeta.DeepCopyInto(&out.ListMeta)
	if in.Items != nil {
		in, out := &in.Items, &out.Items
		*out = make([]Iso, len(*in))
		for i := range *in {
			(*in)[i].DeepCopyInto(&(*out)[i])
		}
	}
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new IsoList.
func (in *IsoList) DeepCopy() *IsoList {
	if in == nil {
		return nil
	}
	out := new(IsoList)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyObject is an autogenerated deepcopy function, copying the receiver, creating a new runtime.Object.
func (in *IsoList) DeepCopyObject() runtime.Object {
	if c := in.DeepCopy(); c != nil {
		return c
	}
	return nil
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *IsoObservation) DeepCopyInto(out *IsoObservation) {
	*out = *in
	if in.Checksum != nil {
		in, out := &in.Checksum, &out.Checksum
		*out = new(string)
		**out = **in
	}
	if in.ChecksumAlgorithm != nil {
		in, out := &in.ChecksumAlgorithm, &out.ChecksumAlgorithm
		*out = new(string)
		**out = **in
	}
	if in.Filename != nil {
		in, out := &in.Filename, &out.Filename
		*out = new(string)
		**out = **in
	}
	if in.ID != nil {
		in, out := &in.ID, &out.ID
		*out = new(string)
		**out = **in
	}
	if in.PveNode != nil {
		in, out := &in.PveNode, &out.PveNode
		*out = new(string)
		**out = **in
	}
	if in.Storage != nil {
		in, out := &in.Storage, &out.Storage
		*out = new(string)
		**out = **in
	}
	if in.URL != nil {
		in, out := &in.URL, &out.URL
		*out = new(string)
		**out = **in
	}
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new IsoObservation.
func (in *IsoObservation) DeepCopy() *IsoObservation {
	if in == nil {
		return nil
	}
	out := new(IsoObservation)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *IsoParameters) DeepCopyInto(out *IsoParameters) {
	*out = *in
	if in.Checksum != nil {
		in, out := &in.Checksum, &out.Checksum
		*out = new(string)
		**out = **in
	}
	if in.ChecksumAlgorithm != nil {
		in, out := &in.ChecksumAlgorithm, &out.ChecksumAlgorithm
		*out = new(string)
		**out = **in
	}
	if in.Filename != nil {
		in, out := &in.Filename, &out.Filename
		*out = new(string)
		**out = **in
	}
	if in.PveNode != nil {
		in, out := &in.PveNode, &out.PveNode
		*out = new(string)
		**out = **in
	}
	if in.Storage != nil {
		in, out := &in.Storage, &out.Storage
		*out = new(string)
		**out = **in
	}
	if in.URL != nil {
		in, out := &in.URL, &out.URL
		*out = new(string)
		**out = **in
	}
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new IsoParameters.
func (in *IsoParameters) DeepCopy() *IsoParameters {
	if in == nil {
		return nil
	}
	out := new(IsoParameters)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *IsoSpec) DeepCopyInto(out *IsoSpec) {
	*out = *in
	in.ResourceSpec.DeepCopyInto(&out.ResourceSpec)
	in.ForProvider.DeepCopyInto(&out.ForProvider)
	in.InitProvider.DeepCopyInto(&out.InitProvider)
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new IsoSpec.
func (in *IsoSpec) DeepCopy() *IsoSpec {
	if in == nil {
		return nil
	}
	out := new(IsoSpec)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *IsoStatus) DeepCopyInto(out *IsoStatus) {
	*out = *in
	in.ResourceStatus.DeepCopyInto(&out.ResourceStatus)
	in.AtProvider.DeepCopyInto(&out.AtProvider)
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new IsoStatus.
func (in *IsoStatus) DeepCopy() *IsoStatus {
	if in == nil {
		return nil
	}
	out := new(IsoStatus)
	in.DeepCopyInto(out)
	return out
}
