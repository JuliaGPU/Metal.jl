; ModuleID = 'simple_matmul.metal'
source_filename = "simple_matmul.metal"
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v16:16:16-v24:32:32-v32:32:32-v48:64:64-v64:64:64-v96:128:128-v128:128:128-v192:256:256-v256:256:256-v512:512:512-v1024:1024:1024-n8:16:32"
target triple = "air64_v28-apple-macosx26.0.0"

%"struct.mpp::tensor_ops::matmul2d_descriptor" = type { i32, i32, i32, i8, i8, i8, i32 }
%struct._tensor_t = type opaque
%"struct.metal::tensor.3" = type { %"struct.metal::__tensor_base.4", %struct._tensor_t addrspace(1)* }
%"struct.metal::__tensor_base.4" = type { %"struct.metal::__tensor_offsets.5" }
%"struct.metal::__tensor_offsets.5" = type { %"struct.metal::array" }
%"struct.metal::array" = type { [2 x i32] }
%"struct.metal::tensor.6" = type { %"struct.metal::__tensor_base.7", %struct._tensor_t addrspace(1)* }
%"struct.metal::__tensor_base.7" = type { %"struct.metal::__tensor_offsets.8" }
%"struct.metal::__tensor_offsets.8" = type { %"struct.metal::array" }

@_ZTAXtlN3mpp10tensor_ops19matmul2d_descriptorELi64ELi32ELin1EEE = linkonce_odr local_unnamed_addr constant %"struct.mpp::tensor_ops::matmul2d_descriptor" { i32 64, i32 32, i32 -1, i8 0, i8 0, i8 0, i32 0 }

; Function Attrs: convergent nounwind
define void @simple_matmul(%struct._tensor_t addrspace(1)* %0, %struct._tensor_t addrspace(1)* %1, %struct._tensor_t addrspace(1)* %2, <2 x i32> noundef %3) local_unnamed_addr #0 {
  %5 = alloca %"struct.mpp::tensor_ops::matmul2d_descriptor", align 4
  %6 = alloca %"struct.metal::tensor.3", align 8
  %7 = alloca %"struct.metal::tensor.3", align 8
  %8 = alloca %"struct.metal::tensor.6", align 8
  %9 = bitcast %"struct.metal::tensor.3"* %6 to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %9) #5
  %10 = extractelement <2 x i32> %3, i64 1
  %11 = shl i32 %10, 6
  %12 = getelementptr inbounds %"struct.metal::tensor.3", %"struct.metal::tensor.3"* %6, i64 0, i32 0, i32 0, i32 0, i32 0, i64 0
  store i32 0, i32* %12, align 8
  %13 = getelementptr inbounds %"struct.metal::tensor.3", %"struct.metal::tensor.3"* %6, i64 0, i32 0, i32 0, i32 0, i32 0, i64 1
  store i32 %11, i32* %13, align 4
  %14 = getelementptr inbounds %"struct.metal::tensor.3", %"struct.metal::tensor.3"* %6, i64 0, i32 1
  store %struct._tensor_t addrspace(1)* %0, %struct._tensor_t addrspace(1)** %14, align 8
  %15 = bitcast %"struct.metal::tensor.3"* %7 to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %15) #5
  %16 = extractelement <2 x i32> %3, i64 0
  %17 = shl i32 %16, 5
  %18 = getelementptr inbounds %"struct.metal::tensor.3", %"struct.metal::tensor.3"* %7, i64 0, i32 0, i32 0, i32 0, i32 0, i64 0
  store i32 %17, i32* %18, align 8
  %19 = getelementptr inbounds %"struct.metal::tensor.3", %"struct.metal::tensor.3"* %7, i64 0, i32 0, i32 0, i32 0, i32 0, i64 1
  store i32 0, i32* %19, align 4
  %20 = getelementptr inbounds %"struct.metal::tensor.3", %"struct.metal::tensor.3"* %7, i64 0, i32 1
  store %struct._tensor_t addrspace(1)* %1, %struct._tensor_t addrspace(1)** %20, align 8
  %21 = bitcast %"struct.metal::tensor.6"* %8 to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %21) #5
  %22 = getelementptr inbounds %"struct.metal::tensor.6", %"struct.metal::tensor.6"* %8, i64 0, i32 0, i32 0, i32 0, i32 0, i64 0
  store i32 %17, i32* %22, align 8
  %23 = getelementptr inbounds %"struct.metal::tensor.6", %"struct.metal::tensor.6"* %8, i64 0, i32 0, i32 0, i32 0, i32 0, i64 1
  store i32 %11, i32* %23, align 4
  %24 = getelementptr inbounds %"struct.metal::tensor.6", %"struct.metal::tensor.6"* %8, i64 0, i32 1
  store %struct._tensor_t addrspace(1)* %2, %struct._tensor_t addrspace(1)** %24, align 8
  %25 = tail call i32 @air.get_simdgroup_size.i32() #6
  %26 = shl i32 %25, 2
  %27 = bitcast %"struct.mpp::tensor_ops::matmul2d_descriptor"* %5 to i8*
  call void @llvm.lifetime.start.p0i8(i64 20, i8* nonnull %27) #5
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* noundef nonnull align 4 dereferenceable(20) %27, i8* noundef nonnull align 4 dereferenceable(20) bitcast (%"struct.mpp::tensor_ops::matmul2d_descriptor"* @_ZTAXtlN3mpp10tensor_ops19matmul2d_descriptorELi64ELi32ELin1EEE to i8*), i64 20, i1 false) #5, !tbaa.struct !23
  call void @__tensorops_impl_matmul2d_op_run_dv_f16_dv_f16_dv_f32(%"struct.mpp::tensor_ops::matmul2d_descriptor"* noundef nonnull align 4 dereferenceable(20) %5, i8* noundef nonnull %9, i32 noundef 1, i8* noundef nonnull %15, i32 noundef 1, i8* noundef nonnull %21, i32 noundef 1, i32 noundef %26) #7
  call void @llvm.lifetime.end.p0i8(i64 20, i8* nonnull %27) #5
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %21) #5
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %15) #5
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %9) #5
  ret void
}

; Function Attrs: argmemonly mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly mustprogress nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #2

; Function Attrs: convergent
declare void @__tensorops_impl_matmul2d_op_run_dv_f16_dv_f16_dv_f32(%"struct.mpp::tensor_ops::matmul2d_descriptor"* noundef nonnull align 4 dereferenceable(20), i8* noundef, i32 noundef, i8* noundef, i32 noundef, i8* noundef, i32 noundef, i32 noundef) local_unnamed_addr #3 section "air.externally_defined"

; Function Attrs: mustprogress nofree nosync nounwind readnone willreturn
declare i32 @air.get_simdgroup_size.i32() local_unnamed_addr #4

attributes #0 = { convergent nounwind "approx-func-fp-math"="true" "frame-pointer"="all" "min-legal-vector-width"="64" "no-builtins" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="true" }
attributes #1 = { argmemonly mustprogress nocallback nofree nosync nounwind willreturn }
attributes #2 = { argmemonly mustprogress nofree nounwind willreturn }
attributes #3 = { convergent "approx-func-fp-math"="true" "frame-pointer"="all" "no-builtins" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="true" }
attributes #4 = { mustprogress nofree nosync nounwind readnone willreturn }
attributes #5 = { nounwind }
attributes #6 = { nounwind readnone willreturn }
attributes #7 = { convergent nobuiltin nounwind "no-builtins" }

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
!9 = !{void (%struct._tensor_t addrspace(1)*, %struct._tensor_t addrspace(1)*, %struct._tensor_t addrspace(1)*, <2 x i32>)* @simple_matmul, !10, !11}
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
!22 = !{!"/private/tmp/metaltest/simple_matmul.metal"}
!23 = !{i64 0, i64 4, !24, i64 4, i64 4, !24, i64 8, i64 4, !24, i64 12, i64 1, !28, i64 13, i64 1, !28, i64 14, i64 1, !28, i64 16, i64 4, !30}
!24 = !{!25, !25, i64 0}
!25 = !{!"int", !26, i64 0}
!26 = !{!"omnipotent char", !27, i64 0}
!27 = !{!"Simple C++ TBAA"}
!28 = !{!29, !29, i64 0}
!29 = !{!"bool", !26, i64 0}
!30 = !{!31, !31, i64 0}
!31 = !{!"_ZTSN3mpp10tensor_ops19matmul2d_descriptor4modeE", !26, i64 0}
