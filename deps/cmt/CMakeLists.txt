cmake_minimum_required(VERSION 3.9)

project(cmt VERSION 1.0.1 DESCRIPTION "C Metal Wrapper"
            LANGUAGES C OBJC)

find_library(FOUNDATION_LIBRARY Foundation)
find_library(METAL_LIBRARY Metal)
find_library(MPS_LIBRARY MetalPerformanceShaders)

# with debug builds, invoke dsymutil to generate separate debug info.
# this needs to be done when object files are available
# to extract the debug info from.
if ((CMAKE_BUILD_TYPE MATCHES Debug) OR (CMAKE_BUILD_TYPE MATCHES RelWithDebInfo))
    find_program(DSYMUTIL_PROGRAM dsymutil)
    if (DSYMUTIL_PROGRAM)
        foreach(lang C CXX OBJC)
            foreach(var LINK_EXECUTABLE CREATE_SHARED_LIBRARY)
                set(CMAKE_${lang}_${var} "${CMAKE_${lang}_${var}}" "${DSYMUTIL_PROGRAM} <TARGET>")
            endforeach()
        endforeach()
    endif()
endif()

set(SOURCES
    src/reflection/argument.m
    src/reflection/pointer_type.m
    src/reflection/descriptor.m
    src/compute/compute-pipeline.m
    src/kernels/attribute.m
    src/kernels/attribute_vertex.m
    src/kernels/constant_values.m
    src/kernels/compile-opts.m
    src/kernels/function.m
    src/kernels/library.m
    src/kernels/binary_archive.m
    src/memory/buffer.m
    src/memory/heap-descriptor.m
    src/memory/heap.m
    src/memory/vertex.m
    src/rendering/depthstencil.m
    src/rendering/rpass.m
    src/rendering/rpip.m
    src/utils/conversion.m
    src/argument_descriptor.m
    src/argument_encoder.m
    src/cmt.m
    src/command_buf.m
    src/command_buf_indirect.m
    src/command_queue.m
    src/command_enc.m
    src/command_enc_render.m
    src/command_enc_compute.m
    src/command_enc_blit.m
    src/device.m
    src/error.m
    src/event.m
    src/resource.m
    src/capture/capture_descriptor.m
    src/capture/capture_manager.m
    src/capture/capture_scope.m
    src/performance_shaders/device.m
    src/performance_shaders/matrix.m)

add_library(cmt SHARED ${SOURCES})

target_include_directories(cmt PRIVATE .)
target_include_directories(cmt PRIVATE include/)
target_include_directories(cmt INTERFACE include/)

set_target_properties(cmt PROPERTIES
                      VERSION ${PROJECT_VERSION}
                      SOVERSION 1
                      PUBLIC_HEADER include/cmt/cmt.h)

target_link_libraries(cmt ${FOUNDATION_LIBRARY} ${METAL_LIBRARY} ${MPS_LIBRARY})

# libcmt uses Manual-Retain-Release and not ARC
target_compile_options(cmt PRIVATE -fno-objc-arc)

install(TARGETS cmt
        LIBRARY DESTINATION lib
        PUBLIC_HEADER DESTINATION include)

# XXX: can we add the dSYM to the target instead of copying it to the prefix ourselve?
if ((CMAKE_BUILD_TYPE MATCHES Debug) OR (CMAKE_BUILD_TYPE MATCHES RelWithDebInfo))
    install(DIRECTORY ${CMAKE_BINARY_DIR}/libcmt.dylib.dSYM
            DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)
endif()
