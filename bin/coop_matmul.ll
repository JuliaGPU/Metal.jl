; ModuleID = 'coop_matmul.metal'
source_filename = "coop_matmul.metal"
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v16:16:16-v24:32:32-v32:32:32-v48:64:64-v64:64:64-v96:128:128-v128:128:128-v192:256:256-v256:256:256-v512:512:512-v1024:1024:1024-n8:16:32"
target triple = "air64_v28-apple-macosx26.0.0"

%"struct.mpp::tensor_ops::matmul2d_descriptor" = type { i32, i32, i32, i8, i8, i8, i32 }
%struct._tensor_t = type opaque
%"struct.metal::tensor.6" = type { %"struct.metal::__tensor_base.7", %struct._tensor_t addrspace(1)* }
%"struct.metal::__tensor_base.7" = type { %"struct.metal::__tensor_offsets.8" }
%"struct.metal::__tensor_offsets.8" = type { %"struct.metal::array" }
%"struct.metal::array" = type { [2 x i32] }
%"struct.metal::tensor.3" = type { %"struct.metal::__tensor_base.4", %struct._tensor_t addrspace(1)* }
%"struct.metal::__tensor_base.4" = type { %"struct.metal::__tensor_offsets.5" }
%"struct.metal::__tensor_offsets.5" = type { %"struct.metal::array" }

@_ZTAXtlN3mpp10tensor_ops19matmul2d_descriptorELi64ELi32ELin1EEE = linkonce_odr local_unnamed_addr constant %"struct.mpp::tensor_ops::matmul2d_descriptor" { i32 64, i32 32, i32 -1, i8 0, i8 0, i8 0, i32 0 }

; Function Attrs: convergent nounwind
define void @coop_matmul(%struct._tensor_t addrspace(1)* %0, %struct._tensor_t addrspace(1)* %1, %struct._tensor_t addrspace(1)* %2, <2 x i32> noundef %3) local_unnamed_addr #0 {
  %5 = alloca %"struct.mpp::tensor_ops::matmul2d_descriptor", align 4
  %6 = alloca %"struct.metal::tensor.6", align 8
  %7 = alloca %"struct.metal::tensor.3", align 8
  %8 = alloca %"struct.metal::tensor.3", align 8
  %9 = tail call i64 @_ZN5metal18cooperative_tensorIfNS_7extentsIiJLm18446744073709551615ELm18446744073709551615EEEEN3mpp10tensor_ops17__mutmul2d_detail16__operand_layoutIXtlNS4_19matmul2d_descriptorELi64ELi32ELin1EEELNS5_36__matmul2d_cooperative_operand_indexE2ENS_20execution_simdgroupsILm4EEEDhDhfiJEEEEE.MTL_SIZEAS() #7
  %10 = alloca i8, i64 %9, align 4
  %11 = bitcast %"struct.metal::tensor.3"* %7 to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %11) #7
  %12 = extractelement <2 x i32> %3, i64 1
  %13 = shl i32 %12, 6
  %14 = getelementptr inbounds %"struct.metal::tensor.3", %"struct.metal::tensor.3"* %7, i64 0, i32 0, i32 0, i32 0, i32 0, i64 0
  store i32 0, i32* %14, align 8
  %15 = getelementptr inbounds %"struct.metal::tensor.3", %"struct.metal::tensor.3"* %7, i64 0, i32 0, i32 0, i32 0, i32 0, i64 1
  store i32 %13, i32* %15, align 4
  %16 = getelementptr inbounds %"struct.metal::tensor.3", %"struct.metal::tensor.3"* %7, i64 0, i32 1
  store %struct._tensor_t addrspace(1)* %0, %struct._tensor_t addrspace(1)** %16, align 8
  %17 = bitcast %"struct.metal::tensor.3"* %8 to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %17) #7
  %18 = extractelement <2 x i32> %3, i64 0
  %19 = shl i32 %18, 5
  %20 = getelementptr inbounds %"struct.metal::tensor.3", %"struct.metal::tensor.3"* %8, i64 0, i32 0, i32 0, i32 0, i32 0, i64 0
  store i32 %19, i32* %20, align 8
  %21 = getelementptr inbounds %"struct.metal::tensor.3", %"struct.metal::tensor.3"* %8, i64 0, i32 0, i32 0, i32 0, i32 0, i64 1
  store i32 0, i32* %21, align 4
  %22 = getelementptr inbounds %"struct.metal::tensor.3", %"struct.metal::tensor.3"* %8, i64 0, i32 1
  store %struct._tensor_t addrspace(1)* %1, %struct._tensor_t addrspace(1)** %22, align 8
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %10)
  %23 = tail call i32 @air.get_simdgroup_size.i32() #8
  %24 = shl i32 %23, 2
  call void @__tensorops_impl_matmul2d_op_cooperative_tensor_init(i32 noundef 2, i32 64, i32 32, i32 -1, i8 0, i8 0, i8 0, i32 0, i8* noundef nonnull %10, i32 noundef 268435472, i32 noundef 268435472, i32 noundef 268435488, i32 noundef %24) #9
  br label %25

25:                                               ; preds = %37, %4
  %26 = phi i16 [ 0, %4 ], [ %38, %37 ]
  %27 = call zeroext i16 @__tensorops_impl_matmul2d_op_cooperative_tensor_num_elements(i32 noundef 2, i32 64, i32 32, i32 -1, i8 0, i8 0, i8 0, i32 0, i8* noundef nonnull %10, i32 noundef 268435472, i32 noundef 268435472, i32 noundef %24) #9
  %28 = icmp ult i16 %26, %27
  br i1 %28, label %32, label %29

29:                                               ; preds = %25
  %30 = bitcast %"struct.mpp::tensor_ops::matmul2d_descriptor"* %5 to i8*
  call void @llvm.lifetime.start.p0i8(i64 20, i8* nonnull %30) #7
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* noundef nonnull align 4 dereferenceable(20) %30, i8* noundef nonnull align 4 dereferenceable(20) bitcast (%"struct.mpp::tensor_ops::matmul2d_descriptor"* @_ZTAXtlN3mpp10tensor_ops19matmul2d_descriptorELi64ELi32ELin1EEE to i8*), i64 20, i1 false) #7, !tbaa.struct !23
  %31 = call i8* @__tensorops_impl_matmul2d_op_cooperative_tensor_get_element_pointer(i32 noundef 2, i32 64, i32 32, i32 -1, i8 0, i8 0, i8 0, i32 0, i8* noundef nonnull %10, i16 noundef zeroext -1, i32 noundef 268435472, i32 noundef 268435472, i32 noundef 268435488) #9
  call void @__tensorops_impl_matmul2d_op_run_cooperative_dv_f16_dv_f16_f32(%"struct.mpp::tensor_ops::matmul2d_descriptor"* noundef nonnull align 4 dereferenceable(20) %5, i8* noundef nonnull %11, i32 noundef 1, i8* noundef nonnull %17, i32 noundef 1, i8* noundef %31, i32 noundef %24) #9
  call void @llvm.lifetime.end.p0i8(i64 20, i8* nonnull %30) #7
  br label %39

32:                                               ; preds = %25
  %33 = call zeroext i1 @__tensorops_impl_matmul2d_op_cooperative_tensor_is_valid_element(i32 noundef 2, i32 64, i32 32, i32 -1, i8 0, i8 0, i8 0, i32 0, i8* noundef nonnull %10, i16 noundef zeroext %26, i32 noundef 268435472, i32 noundef 268435472, i32 noundef 268435488, i32 noundef %24) #9
  br i1 %33, label %34, label %37

34:                                               ; preds = %32
  %35 = call i8* @__tensorops_impl_matmul2d_op_cooperative_tensor_get_element_pointer(i32 noundef 2, i32 64, i32 32, i32 -1, i8 0, i8 0, i8 0, i32 0, i8* noundef nonnull %10, i16 noundef zeroext %26, i32 noundef 268435472, i32 noundef 268435472, i32 noundef 268435488) #9
  %36 = bitcast i8* %35 to float*
  store float 0.000000e+00, float* %36, align 4, !tbaa !32
  br label %37

37:                                               ; preds = %32, %34
  %38 = add nuw i16 %26, 1
  br label %25, !llvm.loop !34

39:                                               ; preds = %55, %29
  %40 = phi i16 [ 0, %29 ], [ %56, %55 ]
  %41 = call zeroext i16 @__tensorops_impl_matmul2d_op_cooperative_tensor_num_elements(i32 noundef 2, i32 64, i32 32, i32 -1, i8 0, i8 0, i8 0, i32 0, i8* noundef nonnull %10, i32 noundef 268435472, i32 noundef 268435472, i32 noundef %24) #9
  %42 = icmp ult i16 %40, %41
  br i1 %42, label %48, label %43

43:                                               ; preds = %39
  %44 = bitcast %"struct.metal::tensor.6"* %6 to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %44)
  %45 = getelementptr inbounds %"struct.metal::tensor.6", %"struct.metal::tensor.6"* %6, i64 0, i32 0, i32 0, i32 0, i32 0, i64 0
  store i32 %19, i32* %45, align 8
  %46 = getelementptr inbounds %"struct.metal::tensor.6", %"struct.metal::tensor.6"* %6, i64 0, i32 0, i32 0, i32 0, i32 0, i64 1
  store i32 %13, i32* %46, align 4
  %47 = getelementptr inbounds %"struct.metal::tensor.6", %"struct.metal::tensor.6"* %6, i64 0, i32 1
  store %struct._tensor_t addrspace(1)* %2, %struct._tensor_t addrspace(1)** %47, align 8
  call void @__tensorops_impl_matmul2d_op_cooperative_tensor_store_dv_f32(i32 noundef 2, i32 64, i32 32, i32 -1, i8 0, i8 0, i8 0, i32 0, i8* noundef nonnull %10, i8* noundef nonnull %44, i32 noundef 1, i32 noundef 268435472, i32 noundef 268435472, i32 noundef 268435488, i32 noundef %24) #9
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %44)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %10) #7
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %17) #7
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %11) #7
  ret void

48:                                               ; preds = %39
  %49 = call zeroext i1 @__tensorops_impl_matmul2d_op_cooperative_tensor_is_valid_element(i32 noundef 2, i32 64, i32 32, i32 -1, i8 0, i8 0, i8 0, i32 0, i8* noundef nonnull %10, i16 noundef zeroext %40, i32 noundef 268435472, i32 noundef 268435472, i32 noundef 268435488, i32 noundef %24) #9
  br i1 %49, label %50, label %55

50:                                               ; preds = %48
  %51 = call i8* @__tensorops_impl_matmul2d_op_cooperative_tensor_get_element_pointer(i32 noundef 2, i32 64, i32 32, i32 -1, i8 0, i8 0, i8 0, i32 0, i8* noundef nonnull %10, i16 noundef zeroext %40, i32 noundef 268435472, i32 noundef 268435472, i32 noundef 268435488) #9
  %52 = bitcast i8* %51 to float*
  %53 = load float, float* %52, align 4, !tbaa !32
  %54 = fmul fast float %53, 2.000000e+00
  store float %54, float* %52, align 4, !tbaa !32
  br label %55

55:                                               ; preds = %48, %50
  %56 = add nuw i16 %40, 1
  br label %39, !llvm.loop !36
}

; Function Attrs: argmemonly mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: mustprogress nofree nosync readnone speculatable willreturn
define linkonce_odr hidden i64 @_ZN5metal18cooperative_tensorIfNS_7extentsIiJLm18446744073709551615ELm18446744073709551615EEEEN3mpp10tensor_ops17__mutmul2d_detail16__operand_layoutIXtlNS4_19matmul2d_descriptorELi64ELi32ELin1EEELNS5_36__matmul2d_cooperative_operand_indexE2ENS_20execution_simdgroupsILm4EEEDhDhfiJEEEEE.MTL_SIZEAS() local_unnamed_addr #2 {
  %1 = tail call i64 @_ZN3mpp10tensor_ops17__mutmul2d_detail16__operand_layoutIXtlNS0_19matmul2d_descriptorELi64ELi32ELin1EEELNS1_36__matmul2d_cooperative_operand_indexE2EN5metal20execution_simdgroupsILm4EEEDhDhfiJEE19thread_storage_sizeEv() #10
  ret i64 %1
}

; Function Attrs: convergent nounwind
define linkonce_odr i64 @_ZN3mpp10tensor_ops17__mutmul2d_detail16__operand_layoutIXtlNS0_19matmul2d_descriptorELi64ELi32ELin1EEELNS1_36__matmul2d_cooperative_operand_indexE2EN5metal20execution_simdgroupsILm4EEEDhDhfiJEE19thread_storage_sizeEv() local_unnamed_addr #3 align 2 {
  %1 = tail call i32 @air.get_simdgroup_size.i32() #8
  %2 = shl i32 %1, 2
  %3 = tail call i64 @__tensorops_impl_matmul2d_op_cooperative_tensor_data_size(i32 noundef 2, i32 64, i32 32, i32 -1, i8 0, i8 0, i8 0, i32 0, i32 noundef 268435472, i32 noundef 268435472, i32 noundef 268435488, i32 noundef %2) #9
  ret i64 %3
}

; Function Attrs: argmemonly mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly mustprogress nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #4

; Function Attrs: convergent
declare void @__tensorops_impl_matmul2d_op_cooperative_tensor_init(i32 noundef, i32, i32, i32, i8, i8, i8, i32, i8* noundef, i32 noundef, i32 noundef, i32 noundef, i32 noundef) local_unnamed_addr #5 section "air.externally_defined"

; Function Attrs: mustprogress nofree nosync nounwind readnone willreturn
declare i32 @air.get_simdgroup_size.i32() local_unnamed_addr #6

; Function Attrs: convergent
declare i64 @__tensorops_impl_matmul2d_op_cooperative_tensor_data_size(i32 noundef, i32, i32, i32, i8, i8, i8, i32, i32 noundef, i32 noundef, i32 noundef, i32 noundef) local_unnamed_addr #5 section "air.externally_defined"

; Function Attrs: convergent
declare zeroext i16 @__tensorops_impl_matmul2d_op_cooperative_tensor_num_elements(i32 noundef, i32, i32, i32, i8, i8, i8, i32, i8* noundef, i32 noundef, i32 noundef, i32 noundef) local_unnamed_addr #5 section "air.externally_defined"

; Function Attrs: convergent
declare zeroext i1 @__tensorops_impl_matmul2d_op_cooperative_tensor_is_valid_element(i32 noundef, i32, i32, i32, i8, i8, i8, i32, i8* noundef, i16 noundef zeroext, i32 noundef, i32 noundef, i32 noundef, i32 noundef) local_unnamed_addr #5 section "air.externally_defined"

; Function Attrs: convergent
declare i8* @__tensorops_impl_matmul2d_op_cooperative_tensor_get_element_pointer(i32 noundef, i32, i32, i32, i8, i8, i8, i32, i8* noundef, i16 noundef zeroext, i32 noundef, i32 noundef, i32 noundef) local_unnamed_addr #5 section "air.externally_defined"

; Function Attrs: convergent
declare void @__tensorops_impl_matmul2d_op_run_cooperative_dv_f16_dv_f16_f32(%"struct.mpp::tensor_ops::matmul2d_descriptor"* noundef nonnull align 4 dereferenceable(20), i8* noundef, i32 noundef, i8* noundef, i32 noundef, i8* noundef, i32 noundef) local_unnamed_addr #5 section "air.externally_defined"

; Function Attrs: convergent
declare void @__tensorops_impl_matmul2d_op_cooperative_tensor_store_dv_f32(i32 noundef, i32, i32, i32, i8, i8, i8, i32, i8* noundef, i8* noundef, i32 noundef, i32 noundef, i32 noundef, i32 noundef, i32 noundef) local_unnamed_addr #5 section "air.externally_defined"

attributes #0 = { convergent nounwind "approx-func-fp-math"="true" "frame-pointer"="all" "min-legal-vector-width"="64" "no-builtins" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="true" }
attributes #1 = { argmemonly mustprogress nocallback nofree nosync nounwind willreturn }
attributes #2 = { mustprogress nofree nosync readnone speculatable willreturn "deferred-static-alloca-size" }
attributes #3 = { convergent nounwind "approx-func-fp-math"="true" "frame-pointer"="all" "min-legal-vector-width"="0" "no-builtins" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="true" }
attributes #4 = { argmemonly mustprogress nofree nounwind willreturn }
attributes #5 = { convergent "approx-func-fp-math"="true" "frame-pointer"="all" "no-builtins" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="true" }
attributes #6 = { mustprogress nofree nosync nounwind readnone willreturn }
attributes #7 = { nounwind }
attributes #8 = { nounwind readnone willreturn }
attributes #9 = { convergent nobuiltin nounwind "no-builtins" }
attributes #10 = { convergent nobuiltin "no-builtins" }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6, !7, !8}
!air.kernel = !{!9}
!air.compile_options = !{!16, !17, !18}
!llvm.ident = !{!19}
!air.version = !{!20}
!air.language_version = !{!21}
!air.source_file_name = !{!22}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 2]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 7, !"frame-pointer", i32 2}
!3 = !{i32 7, !"air.max_device_buffers", i32 31}
!4 = !{i32 7, !"air.max_constant_buffers", i32 31}
!5 = !{i32 7, !"air.max_threadgroup_buffers", i32 31}
!6 = !{i32 7, !"air.max_textures", i32 128}
!7 = !{i32 7, !"air.max_read_write_textures", i32 8}
!8 = !{i32 7, !"air.max_samplers", i32 16}
!9 = !{void (%struct._tensor_t addrspace(1)*, %struct._tensor_t addrspace(1)*, %struct._tensor_t addrspace(1)*, <2 x i32>)* @coop_matmul, !10, !11}
!10 = !{}
!11 = !{!12, !13, !14, !15}
!12 = !{i32 0, !"air.tensor", !"air.location_index", i32 0, i32 1, !"air.read_write", !"air.address_space", i32 1, !"air.arg_type_name", !"tensor<half, dextents<int, 2>>", !"air.arg_name", !"A"}
!13 = !{i32 1, !"air.tensor", !"air.location_index", i32 1, i32 1, !"air.read_write", !"air.address_space", i32 1, !"air.arg_type_name", !"tensor<half, dextents<int, 2>>", !"air.arg_name", !"B"}
!14 = !{i32 2, !"air.tensor", !"air.location_index", i32 2, i32 1, !"air.read_write", !"air.address_space", i32 1, !"air.arg_type_name", !"tensor<float, dextents<int, 2>>", !"air.arg_name", !"C"}
!15 = !{i32 3, !"air.threadgroup_position_in_grid", !"air.arg_type_name", !"uint2", !"air.arg_name", !"tgid"}
!16 = !{!"air.compile.denorms_disable"}
!17 = !{!"air.compile.fast_math_enable"}
!18 = !{!"air.compile.framebuffer_fetch_enable"}
!19 = !{!"Apple metal version 32023.864 (metalfe-32023.864)"}
!20 = !{i32 2, i32 8, i32 0}
!21 = !{!"Metal", i32 4, i32 0, i32 0}
!22 = !{!"/private/tmp/metaltest/coop_matmul.metal"}
!23 = !{i64 0, i64 4, !24, i64 4, i64 4, !24, i64 8, i64 4, !24, i64 12, i64 1, !28, i64 13, i64 1, !28, i64 14, i64 1, !28, i64 16, i64 4, !30}
!24 = !{!25, !25, i64 0}
!25 = !{!"int", !26, i64 0}
!26 = !{!"omnipotent char", !27, i64 0}
!27 = !{!"Simple C++ TBAA"}
!28 = !{!29, !29, i64 0}
!29 = !{!"bool", !26, i64 0}
!30 = !{!31, !31, i64 0}
!31 = !{!"_ZTSN3mpp10tensor_ops19matmul2d_descriptor4modeE", !26, i64 0}
!32 = !{!33, !33, i64 0}
!33 = !{!"float", !26, i64 0}
!34 = distinct !{!34, !35}
!35 = !{!"llvm.loop.mustprogress"}
!36 = distinct !{!36, !35}
