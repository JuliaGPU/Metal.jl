export simdgroup_load, simdgroup_store, simdgroup_multiply, simdgroup_multiply_accumulate;

using Core: LLVMPtr

for (jltype, llvmtype, suffix) in ((Float16, "half", "f16"),
                                   (Float32, "float", "f32"))
    @eval begin
        # TODO: expose the version which loads from threadgroup memory
        @device_function simdgroup_load(
            data::MtlDeviceArray{$jltype, <:Any, AS.Device},
            elements_per_row::Int64 = 8,
            matrix_origin::NTuple{2, VecElement{Int64}} = (VecElement(0), VecElement(0)),
        ) = Base.llvmcall($("""
            define <64 x $llvmtype> @entry(i8 addrspace(1)*, i64, <2 x i64>) #0 {
                %typed_ptr = bitcast i8 addrspace(1)* %0 to $llvmtype addrspace(1)*
                %r = tail call <64 x $llvmtype> @air.simdgroup_matrix_8x8_load.v64$suffix.p1$suffix($llvmtype addrspace(1)* %typed_ptr, i64 %1, <2 x i64> %2, i1 true)
                ret <64 x $llvmtype> %r
            }

            declare <64 x $llvmtype> @air.simdgroup_matrix_8x8_load.v64$suffix.p1$suffix($llvmtype addrspace(1)* nocapture readonly, i64, <2 x i64>, i1) local_unnamed_addr #1

            attributes #0 = { convergent nounwind }
            attributes #1 = { convergent nounwind readonly }
            """, "entry"), NTuple{64, VecElement{$jltype}},
            Tuple{LLVMPtr{$jltype, AS.Device}, Int64, NTuple{2, VecElement{Int64}}},
            data.ptr, elements_per_row, matrix_origin)

        # TODO: expose the version which stores to threadgroup memory
        @device_function simdgroup_store(
            src::NTuple{64, VecElement{$jltype}},
            dest::MtlDeviceArray{$jltype, <:Any, AS.Device},
            elements_per_row::Int64 = 8,
            matrix_origin::NTuple{2, VecElement{Int64}} = (VecElement(0), VecElement(0)),
        ) = Base.llvmcall($("""
            define void @entry(<64 x $llvmtype>, i8 addrspace(1)*, i64, <2 x i64>) #0 {
                %typed_ptr = bitcast i8 addrspace(1)* %1 to $llvmtype addrspace(1)*
                tail call void @air.simdgroup_matrix_8x8_store.v64$suffix.p1$suffix(<64 x $llvmtype> %0, $llvmtype addrspace(1)* %typed_ptr, i64 %2, <2 x i64> %3, i1 true)
                ret void
            }

            declare void @air.simdgroup_matrix_8x8_store.v64$suffix.p1$suffix(<64 x $llvmtype>, $llvmtype addrspace(1)* nocapture writeonly, i64, <2 x i64>, i1) local_unnamed_addr #1

            attributes #0 = { convergent nounwind }
            attributes #1 = { convergent nounwind writeonly }
            """, "entry"), Cvoid,
            Tuple{NTuple{64, VecElement{$jltype}}, LLVMPtr{$jltype, AS.Device}, Int64, NTuple{2, VecElement{Int64}}},
            src, dest.ptr, elements_per_row, matrix_origin)

        @device_function simdgroup_multiply(
            a::NTuple{64, VecElement{$jltype}},
            b::NTuple{64, VecElement{$jltype}},
        ) = Base.llvmcall($("""
            define <64 x $llvmtype> @entry(<64 x $llvmtype>, <64 x $llvmtype>) #0 {
                %r = tail call <64 x $llvmtype> @air.simdgroup_matrix_8x8_multiply_accumulate.v64$suffix.v64$suffix.v64$suffix.v64$suffix(<64 x $llvmtype> %0, <64 x $llvmtype> %1, <64 x $llvmtype> zeroinitializer)
                ret <64 x $llvmtype> %r
            }

            declare <64 x $llvmtype> @air.simdgroup_matrix_8x8_multiply_accumulate.v64$suffix.v64$suffix.v64$suffix.v64$suffix(<64 x $llvmtype>, <64 x $llvmtype>, <64 x $llvmtype>) local_unnamed_addr #1

            attributes #0 = { convergent nounwind }
            attributes #1 = { convergent nounwind }
            """, "entry"), NTuple{64, VecElement{$jltype}},
            Tuple{NTuple{64, VecElement{$jltype}}, NTuple{64, VecElement{$jltype}}},
            a, b)

        @device_function simdgroup_multiply_accumulate(
            a::NTuple{64, VecElement{$jltype}},
            b::NTuple{64, VecElement{$jltype}},
            c::NTuple{64, VecElement{$jltype}},
        ) = Base.llvmcall($("""
            define <64 x $llvmtype> @entry(<64 x $llvmtype>, <64 x $llvmtype>, <64 x $llvmtype>) #0 {
                %r = tail call <64 x $llvmtype> @air.simdgroup_matrix_8x8_multiply_accumulate.v64$suffix.v64$suffix.v64$suffix.v64$suffix(<64 x $llvmtype> %0, <64 x $llvmtype> %1, <64 x $llvmtype> %2)
                ret <64 x $llvmtype> %r
            }

            declare <64 x $llvmtype> @air.simdgroup_matrix_8x8_multiply_accumulate.v64$suffix.v64$suffix.v64$suffix.v64$suffix(<64 x $llvmtype>, <64 x $llvmtype>, <64 x $llvmtype>) local_unnamed_addr #1

            attributes #0 = { convergent nounwind }
            attributes #1 = { convergent nounwind }
            """, "entry"), NTuple{64, VecElement{$jltype}},
            Tuple{NTuple{64, VecElement{$jltype}}, NTuple{64, VecElement{$jltype}}, NTuple{64, VecElement{$jltype}}},
            a, b, c)
    end
end

## Documentation

@doc """
    simdgroup_load(data::MtlDeviceArray, elements_per_row=8, matrix_origin=(0, 0))

Loads data from device memory into an 8x8 SIMD-group matrix and returns it.

# Arguments
- `elements_per_row::Int64=8`: the number of elements in the source memory layout.
- `matrix_origin::NTuple{2, Int64}=(0, 0)`: origin in the source memory to load from.
""" simdgroup_load

@doc """
    simdgroup_store(src, dest::MtlDeviceArray, elements_per_row=8, matrix_origin=(0, 0))

Stores data from an 8x8 SIMD-group matrix into device memory.

# Arguments
- `elements_per_row::Int64=8`: the number of elements in the destination memory layout.
- `matrix_origin::NTuple{2, Int64}=(0, 0)`: origin in the destination memory to store to.
""" simdgroup_store

@doc """
    simdgroup_multiply(a, b)

Returns `a * b`.
""" simdgroup_multiply

@doc """
    simdgroup_multiply_accumulate(a, b, c)

Returns `a * b + c`.
""" simdgroup_multiply_accumulate
