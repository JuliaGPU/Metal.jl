; ModuleID = 'inline_matmul.metal'
source_filename = "inline_matmul.metal"
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v16:16:16-v24:32:32-v32:32:32-v48:64:64-v64:64:64-v96:128:128-v128:128:128-v192:256:256-v256:256:256-v512:512:512-v1024:1024:1024-n8:16:32"
target triple = "air64_v28-apple-macosx26.0.0"

%"struct.mpp::tensor_ops::matmul2d_descriptor" = type { i32, i32, i32, i8, i8, i8, i32 }
%"struct.metal::array" = type { [2 x i32] }
%struct._tensor_t = type opaque

@_ZTAXtlN3mpp10tensor_ops19matmul2d_descriptorELi64ELi32ELin1EEE = linkonce_odr local_unnamed_addr constant %"struct.mpp::tensor_ops::matmul2d_descriptor" { i32 64, i32 32, i32 -1, i8 0, i8 0, i8 0, i32 0 }

; Function Attrs: convergent nounwind
define void @inline_matmul(half addrspace(1)* noundef "air-buffer-no-alias" %0, half addrspace(1)* noundef "air-buffer-no-alias" %1, float addrspace(1)* noundef "air-buffer-no-alias" %2, i32 addrspace(2)* nocapture noundef readonly align 4 dereferenceable(4) "air-buffer-no-alias" %3, i32 addrspace(2)* nocapture noundef readonly align 4 dereferenceable(4) "air-buffer-no-alias" %4, i32 addrspace(2)* nocapture noundef readonly align 4 dereferenceable(4) "air-buffer-no-alias" %5, <2 x i32> noundef %6) local_unnamed_addr #0 {
  %8 = alloca %"struct.mpp::tensor_ops::matmul2d_descriptor", align 4
  %9 = alloca %"struct.metal::array", align 4
  %10 = alloca %"struct.metal::array", align 4
  %11 = alloca %"struct.metal::array", align 4
  %12 = alloca %"struct.metal::array", align 4
  %13 = alloca %"struct.metal::array", align 4
  %14 = alloca %"struct.metal::array", align 4
  %15 = alloca %"struct.metal::array", align 4
  %16 = alloca %"struct.metal::array", align 4
  %17 = alloca %"struct.metal::array", align 4
  %18 = alloca %"struct.metal::array", align 4
  %19 = alloca %"struct.metal::array", align 4
  %20 = alloca %"struct.metal::array", align 4
  %21 = tail call i64 @_ZN5metal6tensorIU9MTLdeviceDhNS_7extentsIiJLm18446744073709551615ELm18446744073709551615EEEENS_13tensor_inlineEJEEE.MTL_SIZEAS() #7
  %22 = alloca i8, i64 %21, align 8
  %23 = alloca i8, i64 %21, align 8
  %24 = tail call i64 @_ZN5metal6tensorIU9MTLdevicefNS_7extentsIiJLm18446744073709551615ELm18446744073709551615EEEENS_13tensor_inlineEJEEE.MTL_SIZEAS() #7
  %25 = alloca i8, i64 %24, align 8
  %26 = alloca i8, i64 %21, align 8
  %27 = alloca i8, i64 %21, align 8
  %28 = alloca i8, i64 %24, align 8
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %22)
  %29 = load i32, i32 addrspace(2)* %5, align 4, !tbaa !26, !alias.scope !30, !noalias !33
  %30 = load i32, i32 addrspace(2)* %3, align 4, !tbaa !26, !alias.scope !39, !noalias !40
  %31 = bitcast i8* %22 to %struct._tensor_t*
  %32 = bitcast half addrspace(1)* %0 to i8 addrspace(1)*
  %33 = bitcast %"struct.metal::array"* %13 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %33) #7
  %34 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %13, i64 0, i32 0, i64 0
  store i32 %29, i32* %34, align 4, !tbaa !26
  %35 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %13, i64 0, i32 0, i64 1
  store i32 %30, i32* %35, align 4, !tbaa !26
  %36 = bitcast %"struct.metal::array"* %14 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %36) #7
  %37 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %14, i64 0, i32 0, i64 0
  store i32 1, i32* %37, align 4, !tbaa !26
  %38 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %14, i64 0, i32 0, i64 1
  store i32 %29, i32* %38, align 4, !tbaa !26
  call void @air.init_strided_private_tensor.i32.global(%struct._tensor_t* nocapture nonnull writeonly %31, i16 2, i8 addrspace(1)* readnone %32, i8* nocapture nonnull readonly %33, i8* nocapture nonnull readonly %36, i8 1) #8
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %36) #7
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %33) #7
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %23)
  %39 = load i32, i32 addrspace(2)* %4, align 4, !tbaa !26, !alias.scope !41, !noalias !42
  %40 = bitcast i8* %23 to %struct._tensor_t*
  %41 = bitcast half addrspace(1)* %1 to i8 addrspace(1)*
  %42 = bitcast %"struct.metal::array"* %11 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %42) #7
  %43 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %11, i64 0, i32 0, i64 0
  store i32 %39, i32* %43, align 4, !tbaa !26
  %44 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %11, i64 0, i32 0, i64 1
  store i32 %29, i32* %44, align 4, !tbaa !26
  %45 = bitcast %"struct.metal::array"* %12 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %45) #7
  %46 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %12, i64 0, i32 0, i64 0
  store i32 1, i32* %46, align 4, !tbaa !26
  %47 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %12, i64 0, i32 0, i64 1
  store i32 %39, i32* %47, align 4, !tbaa !26
  call void @air.init_strided_private_tensor.i32.global(%struct._tensor_t* nocapture nonnull writeonly %40, i16 2, i8 addrspace(1)* readnone %41, i8* nocapture nonnull readonly %42, i8* nocapture nonnull readonly %45, i8 1) #8
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %45) #7
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %42) #7
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %25)
  %48 = bitcast i8* %25 to %struct._tensor_t*
  %49 = bitcast float addrspace(1)* %2 to i8 addrspace(1)*
  %50 = bitcast %"struct.metal::array"* %9 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %50) #7
  %51 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %9, i64 0, i32 0, i64 0
  store i32 %39, i32* %51, align 4, !tbaa !26
  %52 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %9, i64 0, i32 0, i64 1
  store i32 %30, i32* %52, align 4, !tbaa !26
  %53 = bitcast %"struct.metal::array"* %10 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %53) #7
  %54 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %10, i64 0, i32 0, i64 0
  store i32 1, i32* %54, align 4, !tbaa !26
  %55 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %10, i64 0, i32 0, i64 1
  store i32 %39, i32* %55, align 4, !tbaa !26
  call void @air.init_strided_private_tensor.i32.global(%struct._tensor_t* nocapture nonnull writeonly %48, i16 2, i8 addrspace(1)* readnone %49, i8* nocapture nonnull readonly %50, i8* nocapture nonnull readonly %53, i8 0) #8
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %53) #7
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %50) #7
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %26)
  %56 = extractelement <2 x i32> %6, i64 1
  %57 = shl i32 %56, 6
  %58 = bitcast %"struct.metal::array"* %20 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %58) #7, !noalias !43
  %59 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %20, i64 0, i32 0, i64 0
  store i32 0, i32* %59, align 4, !tbaa !26, !noalias !43
  %60 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %20, i64 0, i32 0, i64 1
  store i32 %57, i32* %60, align 4, !tbaa !26, !noalias !43
  %61 = bitcast %"struct.metal::array"* %16 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %61) #7
  %62 = call i32 @air.get_extent_private_tensor.i32(%struct._tensor_t* nocapture nonnull readonly %31, i16 2, i16 0) #8
  %63 = call i32 @air.get_extent_private_tensor.i32(%struct._tensor_t* nocapture nonnull readonly %31, i16 2, i16 1) #8
  %64 = sub i32 %63, %57
  %65 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %16, i64 0, i32 0, i64 0
  store i32 %62, i32* %65, align 4
  %66 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %16, i64 0, i32 0, i64 1
  store i32 %64, i32* %66, align 4
  %67 = bitcast i8* %26 to %struct._tensor_t*
  call void @air.slice_private_tensor_private_tensor.s.i32(%struct._tensor_t* nocapture nonnull writeonly %67, %struct._tensor_t* nocapture nonnull readonly %31, i16 2, i8* nocapture nonnull readonly %58, i8* nocapture nonnull readonly %61) #8
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %61) #7
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %58) #7, !noalias !43
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %27)
  %68 = extractelement <2 x i32> %6, i64 0
  %69 = shl i32 %68, 5
  %70 = bitcast %"struct.metal::array"* %19 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %70) #7, !noalias !46
  %71 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %19, i64 0, i32 0, i64 0
  store i32 %69, i32* %71, align 4, !tbaa !26, !noalias !46
  %72 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %19, i64 0, i32 0, i64 1
  store i32 0, i32* %72, align 4, !tbaa !26, !noalias !46
  %73 = bitcast %"struct.metal::array"* %17 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %73) #7
  %74 = call i32 @air.get_extent_private_tensor.i32(%struct._tensor_t* nocapture nonnull readonly %40, i16 2, i16 0) #8
  %75 = call i32 @air.get_extent_private_tensor.i32(%struct._tensor_t* nocapture nonnull readonly %40, i16 2, i16 1) #8
  %76 = sub i32 %74, %69
  %77 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %17, i64 0, i32 0, i64 0
  store i32 %76, i32* %77, align 4
  %78 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %17, i64 0, i32 0, i64 1
  store i32 %75, i32* %78, align 4
  %79 = bitcast i8* %27 to %struct._tensor_t*
  call void @air.slice_private_tensor_private_tensor.s.i32(%struct._tensor_t* nocapture nonnull writeonly %79, %struct._tensor_t* nocapture nonnull readonly %40, i16 2, i8* nocapture nonnull readonly %70, i8* nocapture nonnull readonly %73) #8
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %73) #7
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %70) #7, !noalias !46
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %28)
  %80 = bitcast %"struct.metal::array"* %18 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %80) #7, !noalias !49
  %81 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %18, i64 0, i32 0, i64 0
  store i32 %69, i32* %81, align 4, !tbaa !26, !noalias !49
  %82 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %18, i64 0, i32 0, i64 1
  store i32 %57, i32* %82, align 4, !tbaa !26, !noalias !49
  %83 = bitcast %"struct.metal::array"* %15 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %83) #7
  %84 = call i32 @air.get_extent_private_tensor.i32(%struct._tensor_t* nocapture nonnull readonly %48, i16 2, i16 0) #8
  %85 = call i32 @air.get_extent_private_tensor.i32(%struct._tensor_t* nocapture nonnull readonly %48, i16 2, i16 1) #8
  %86 = sub i32 %84, %69
  %87 = sub i32 %85, %57
  %88 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %15, i64 0, i32 0, i64 0
  store i32 %86, i32* %88, align 4
  %89 = getelementptr inbounds %"struct.metal::array", %"struct.metal::array"* %15, i64 0, i32 0, i64 1
  store i32 %87, i32* %89, align 4
  %90 = bitcast i8* %28 to %struct._tensor_t*
  call void @air.slice_private_tensor_private_tensor.s.i32(%struct._tensor_t* nocapture nonnull writeonly %90, %struct._tensor_t* nocapture nonnull readonly %48, i16 2, i8* nocapture nonnull readonly %80, i8* nocapture nonnull readonly %83) #8
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %83) #7
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %80) #7, !noalias !49
  %91 = tail call i32 @air.get_simdgroup_size.i32() #9
  %92 = shl i32 %91, 2
  %93 = bitcast %"struct.mpp::tensor_ops::matmul2d_descriptor"* %8 to i8*
  call void @llvm.lifetime.start.p0i8(i64 20, i8* nonnull %93) #7
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* noundef nonnull align 4 dereferenceable(20) %93, i8* noundef nonnull align 4 dereferenceable(20) bitcast (%"struct.mpp::tensor_ops::matmul2d_descriptor"* @_ZTAXtlN3mpp10tensor_ops19matmul2d_descriptorELi64ELi32ELin1EEE to i8*), i64 20, i1 false) #7, !tbaa.struct !52
  call void @__tensorops_impl_matmul2d_op_run_dv_f16_dv_f16_dv_f32(%"struct.mpp::tensor_ops::matmul2d_descriptor"* noundef nonnull align 4 dereferenceable(20) %8, i8* noundef nonnull %26, i32 noundef 2, i8* noundef nonnull %27, i32 noundef 2, i8* noundef nonnull %28, i32 noundef 2, i32 noundef %92) #10
  call void @llvm.lifetime.end.p0i8(i64 20, i8* nonnull %93) #7
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %28) #7
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %27) #7
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %26) #7
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %25) #7
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %23) #7
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %22) #7
  ret void
}

; Function Attrs: mustprogress nofree nosync readnone speculatable willreturn
define linkonce_odr hidden i64 @_ZN5metal6tensorIU9MTLdeviceDhNS_7extentsIiJLm18446744073709551615ELm18446744073709551615EEEENS_13tensor_inlineEJEEE.MTL_SIZEAS() local_unnamed_addr #1 {
  %1 = tail call i16 @air.get_descriptor_size_tensor(i16 2, i16 4) #9
  %2 = zext i16 %1 to i64
  ret i64 %2
}

; Function Attrs: mustprogress nofree nosync nounwind readnone willreturn
declare i16 @air.get_descriptor_size_tensor(i16, i16) local_unnamed_addr #2

; Function Attrs: argmemonly mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #3

; Function Attrs: argmemonly mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #3

; Function Attrs: mustprogress nofree nosync readnone speculatable willreturn
define linkonce_odr hidden i64 @_ZN5metal6tensorIU9MTLdevicefNS_7extentsIiJLm18446744073709551615ELm18446744073709551615EEEENS_13tensor_inlineEJEEE.MTL_SIZEAS() local_unnamed_addr #1 {
  %1 = tail call i16 @air.get_descriptor_size_tensor(i16 2, i16 4) #9
  %2 = zext i16 %1 to i64
  ret i64 %2
}

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare void @air.init_strided_private_tensor.i32.global(%struct._tensor_t* nocapture writeonly, i16, i8 addrspace(1)* readnone, i8* nocapture readonly, i8* nocapture readonly, i8) local_unnamed_addr #4

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare i32 @air.get_extent_private_tensor.i32(%struct._tensor_t* nocapture readonly, i16, i16) local_unnamed_addr #4

; Function Attrs: argmemonly mustprogress nounwind willreturn
declare void @air.slice_private_tensor_private_tensor.s.i32(%struct._tensor_t* nocapture writeonly, %struct._tensor_t* nocapture readonly, i16, i8* nocapture readonly, i8* nocapture readonly) local_unnamed_addr #4

; Function Attrs: argmemonly mustprogress nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #5

; Function Attrs: convergent
declare void @__tensorops_impl_matmul2d_op_run_dv_f16_dv_f16_dv_f32(%"struct.mpp::tensor_ops::matmul2d_descriptor"* noundef nonnull align 4 dereferenceable(20), i8* noundef, i32 noundef, i8* noundef, i32 noundef, i8* noundef, i32 noundef, i32 noundef) local_unnamed_addr #6 section "air.externally_defined"

; Function Attrs: mustprogress nofree nosync nounwind readnone willreturn
declare i32 @air.get_simdgroup_size.i32() local_unnamed_addr #2

attributes #0 = { convergent nounwind "approx-func-fp-math"="true" "frame-pointer"="all" "min-legal-vector-width"="64" "no-builtins" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="true" }
attributes #1 = { mustprogress nofree nosync readnone speculatable willreturn "deferred-static-alloca-size" }
attributes #2 = { mustprogress nofree nosync nounwind readnone willreturn }
attributes #3 = { argmemonly mustprogress nocallback nofree nosync nounwind willreturn }
attributes #4 = { argmemonly mustprogress nounwind willreturn }
attributes #5 = { argmemonly mustprogress nofree nounwind willreturn }
attributes #6 = { convergent "approx-func-fp-math"="true" "frame-pointer"="all" "no-builtins" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="true" }
attributes #7 = { nounwind }
attributes #8 = { argmemonly nounwind willreturn }
attributes #9 = { nounwind readnone willreturn }
attributes #10 = { convergent nobuiltin nounwind "no-builtins" }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6, !7, !8}
!air.kernel = !{!9}
!air.compile_options = !{!19, !20, !21}
!llvm.ident = !{!22}
!air.version = !{!23}
!air.language_version = !{!24}
!air.source_file_name = !{!25}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 2]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 7, !"frame-pointer", i32 2}
!3 = !{i32 7, !"air.max_device_buffers", i32 31}
!4 = !{i32 7, !"air.max_constant_buffers", i32 31}
!5 = !{i32 7, !"air.max_threadgroup_buffers", i32 31}
!6 = !{i32 7, !"air.max_textures", i32 128}
!7 = !{i32 7, !"air.max_read_write_textures", i32 8}
!8 = !{i32 7, !"air.max_samplers", i32 16}
!9 = !{void (half addrspace(1)*, half addrspace(1)*, float addrspace(1)*, i32 addrspace(2)*, i32 addrspace(2)*, i32 addrspace(2)*, <2 x i32>)* @inline_matmul, !10, !11}
!10 = !{}
!11 = !{!12, !13, !14, !15, !16, !17, !18}
!12 = !{i32 0, !"air.buffer", !"air.location_index", i32 0, i32 1, !"air.read_write", !"air.address_space", i32 1, !"air.arg_type_size", i32 2, !"air.arg_type_align_size", i32 2, !"air.arg_type_name", !"half", !"air.arg_name", !"Abuf"}
!13 = !{i32 1, !"air.buffer", !"air.location_index", i32 1, i32 1, !"air.read_write", !"air.address_space", i32 1, !"air.arg_type_size", i32 2, !"air.arg_type_align_size", i32 2, !"air.arg_type_name", !"half", !"air.arg_name", !"Bbuf"}
!14 = !{i32 2, !"air.buffer", !"air.location_index", i32 2, i32 1, !"air.read_write", !"air.address_space", i32 1, !"air.arg_type_size", i32 4, !"air.arg_type_align_size", i32 4, !"air.arg_type_name", !"float", !"air.arg_name", !"Cbuf"}
!15 = !{i32 3, !"air.buffer", !"air.buffer_size", i32 4, !"air.location_index", i32 3, i32 1, !"air.read", !"air.address_space", i32 2, !"air.arg_type_size", i32 4, !"air.arg_type_align_size", i32 4, !"air.arg_type_name", !"uint", !"air.arg_name", !"M"}
!16 = !{i32 4, !"air.buffer", !"air.buffer_size", i32 4, !"air.location_index", i32 4, i32 1, !"air.read", !"air.address_space", i32 2, !"air.arg_type_size", i32 4, !"air.arg_type_align_size", i32 4, !"air.arg_type_name", !"uint", !"air.arg_name", !"N"}
!17 = !{i32 5, !"air.buffer", !"air.buffer_size", i32 4, !"air.location_index", i32 5, i32 1, !"air.read", !"air.address_space", i32 2, !"air.arg_type_size", i32 4, !"air.arg_type_align_size", i32 4, !"air.arg_type_name", !"uint", !"air.arg_name", !"K"}
!18 = !{i32 6, !"air.threadgroup_position_in_grid", !"air.arg_type_name", !"uint2", !"air.arg_name", !"tgid"}
!19 = !{!"air.compile.denorms_disable"}
!20 = !{!"air.compile.fast_math_enable"}
!21 = !{!"air.compile.framebuffer_fetch_enable"}
!22 = !{!"Apple metal version 32023.864 (metalfe-32023.864)"}
!23 = !{i32 2, i32 8, i32 0}
!24 = !{!"Metal", i32 4, i32 0, i32 0}
!25 = !{!"/private/tmp/metaltest/inline_matmul.metal"}
!26 = !{!27, !27, i64 0}
!27 = !{!"int", !28, i64 0}
!28 = !{!"omnipotent char", !29, i64 0}
!29 = !{!"Simple C++ TBAA"}
!30 = !{!31}
!31 = distinct !{!31, !32, !"air-alias-scope-arg(5)"}
!32 = distinct !{!32, !"air-alias-scopes(inline_matmul)"}
!33 = !{!34, !35, !36, !37, !38}
!34 = distinct !{!34, !32, !"air-alias-scope-arg(0)"}
!35 = distinct !{!35, !32, !"air-alias-scope-arg(1)"}
!36 = distinct !{!36, !32, !"air-alias-scope-arg(2)"}
!37 = distinct !{!37, !32, !"air-alias-scope-arg(3)"}
!38 = distinct !{!38, !32, !"air-alias-scope-arg(4)"}
!39 = !{!37}
!40 = !{!34, !35, !36, !38, !31}
!41 = !{!38}
!42 = !{!34, !35, !36, !37, !31}
!43 = !{!44}
!44 = distinct !{!44, !45, !"_ZNK5metal6tensorIU9MTLdeviceDhNS_7extentsIiJLm18446744073709551615ELm18446744073709551615EEEENS_13tensor_inlineEJEE5sliceIJijEEENS_9enable_ifIXaafraa16is_convertible_vIT_iEeqsZT_clL_ZNS5_8get_rankEvEEES5_E4typeEDpS8_: argument 0"}
!45 = distinct !{!45, !"_ZNK5metal6tensorIU9MTLdeviceDhNS_7extentsIiJLm18446744073709551615ELm18446744073709551615EEEENS_13tensor_inlineEJEE5sliceIJijEEENS_9enable_ifIXaafraa16is_convertible_vIT_iEeqsZT_clL_ZNS5_8get_rankEvEEES5_E4typeEDpS8_"}
!46 = !{!47}
!47 = distinct !{!47, !48, !"_ZNK5metal6tensorIU9MTLdeviceDhNS_7extentsIiJLm18446744073709551615ELm18446744073709551615EEEENS_13tensor_inlineEJEE5sliceIJjiEEENS_9enable_ifIXaafraa16is_convertible_vIT_iEeqsZT_clL_ZNS5_8get_rankEvEEES5_E4typeEDpS8_: argument 0"}
!48 = distinct !{!48, !"_ZNK5metal6tensorIU9MTLdeviceDhNS_7extentsIiJLm18446744073709551615ELm18446744073709551615EEEENS_13tensor_inlineEJEE5sliceIJjiEEENS_9enable_ifIXaafraa16is_convertible_vIT_iEeqsZT_clL_ZNS5_8get_rankEvEEES5_E4typeEDpS8_"}
!49 = !{!50}
!50 = distinct !{!50, !51, !"_ZNK5metal6tensorIU9MTLdevicefNS_7extentsIiJLm18446744073709551615ELm18446744073709551615EEEENS_13tensor_inlineEJEE5sliceIJjjEEENS_9enable_ifIXaafraa16is_convertible_vIT_iEeqsZT_clL_ZNS5_8get_rankEvEEES5_E4typeEDpS8_: argument 0"}
!51 = distinct !{!51, !"_ZNK5metal6tensorIU9MTLdevicefNS_7extentsIiJLm18446744073709551615ELm18446744073709551615EEEENS_13tensor_inlineEJEE5sliceIJjjEEENS_9enable_ifIXaafraa16is_convertible_vIT_iEeqsZT_clL_ZNS5_8get_rankEvEEES5_E4typeEDpS8_"}
!52 = !{i64 0, i64 4, !26, i64 4, i64 4, !26, i64 8, i64 4, !26, i64 12, i64 1, !53, i64 13, i64 1, !53, i64 14, i64 1, !53, i64 16, i64 4, !55}
!53 = !{!54, !54, i64 0}
!54 = !{!"bool", !28, i64 0}
!55 = !{!56, !56, i64 0}
!56 = !{!"_ZTSN3mpp10tensor_ops19matmul2d_descriptor4modeE", !28, i64 0}
