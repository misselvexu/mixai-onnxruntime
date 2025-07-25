# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.


  if (onnxruntime_CUDA_MINIMAL)
    file(GLOB onnxruntime_providers_cuda_cc_srcs CONFIGURE_DEPENDS
        "${ONNXRUNTIME_ROOT}/core/providers/cuda/*.h"
        "${ONNXRUNTIME_ROOT}/core/providers/cuda/*.cc"
        "${ONNXRUNTIME_ROOT}/core/providers/cuda/tunable/*.h"
        "${ONNXRUNTIME_ROOT}/core/providers/cuda/tunable/*.cc"
    )
    # Remove pch files
    list(REMOVE_ITEM onnxruntime_providers_cuda_cc_srcs
      "${ONNXRUNTIME_ROOT}/core/providers/cuda/integer_gemm.cc"
      "${ONNXRUNTIME_ROOT}/core/providers/cuda/triton_kernel.h"
    )
  else()
    file(GLOB_RECURSE onnxruntime_providers_cuda_cc_srcs CONFIGURE_DEPENDS
      "${ONNXRUNTIME_ROOT}/core/providers/cuda/*.h"
      "${ONNXRUNTIME_ROOT}/core/providers/cuda/*.cc"
    )
  endif()
  # Remove pch files
  list(REMOVE_ITEM onnxruntime_providers_cuda_cc_srcs
    "${ONNXRUNTIME_ROOT}/core/providers/cuda/cuda_pch.h"
    "${ONNXRUNTIME_ROOT}/core/providers/cuda/cuda_pch.cc"
  )

  # The shared_library files are in a separate list since they use precompiled headers, and the above files have them disabled.
  file(GLOB_RECURSE onnxruntime_providers_cuda_shared_srcs CONFIGURE_DEPENDS
    "${ONNXRUNTIME_ROOT}/core/providers/shared_library/*.h"
    "${ONNXRUNTIME_ROOT}/core/providers/shared_library/*.cc"
  )


  if (NOT onnxruntime_CUDA_MINIMAL)
    file(GLOB_RECURSE onnxruntime_providers_cuda_cu_srcs CONFIGURE_DEPENDS
      "${ONNXRUNTIME_ROOT}/core/providers/cuda/*.cu"
      "${ONNXRUNTIME_ROOT}/core/providers/cuda/*.cuh"
    )
  else()
    set(onnxruntime_providers_cuda_cu_srcs
        "${ONNXRUNTIME_ROOT}/core/providers/cuda/math/unary_elementwise_ops_impl.cu"
        )
  endif()
  source_group(TREE ${ONNXRUNTIME_ROOT}/core FILES ${onnxruntime_providers_cuda_cc_srcs} ${onnxruntime_providers_cuda_shared_srcs} ${onnxruntime_providers_cuda_cu_srcs})
  set(onnxruntime_providers_cuda_src ${onnxruntime_providers_cuda_cc_srcs} ${onnxruntime_providers_cuda_shared_srcs} ${onnxruntime_providers_cuda_cu_srcs})

  # disable contrib ops conditionally
  if(NOT onnxruntime_DISABLE_CONTRIB_OPS AND NOT onnxruntime_CUDA_MINIMAL)
    if (NOT onnxruntime_ENABLE_ATEN)
      list(REMOVE_ITEM onnxruntime_cuda_contrib_ops_cc_srcs
        "${ONNXRUNTIME_ROOT}/contrib_ops/cuda/aten_ops/aten_op.cc"
      )
    endif()
    if (NOT onnxruntime_USE_NCCL)
      list(REMOVE_ITEM onnxruntime_cuda_contrib_ops_cc_srcs
        "${ONNXRUNTIME_ROOT}/contrib_ops/cuda/collective/nccl_kernels.cc"
        "${ONNXRUNTIME_ROOT}/contrib_ops/cuda/collective/sharded_moe.h"
        "${ONNXRUNTIME_ROOT}/contrib_ops/cuda/collective/sharded_moe.cc"
        "${ONNXRUNTIME_ROOT}/contrib_ops/cuda/collective/sharding_spec.cc"
        "${ONNXRUNTIME_ROOT}/contrib_ops/cuda/collective/sharding.cc"
        "${ONNXRUNTIME_ROOT}/contrib_ops/cuda/collective/distributed_matmul.cc"
        "${ONNXRUNTIME_ROOT}/contrib_ops/cuda/collective/distributed_slice.cc"
        "${ONNXRUNTIME_ROOT}/contrib_ops/cuda/collective/distributed_reshape.cc"
        "${ONNXRUNTIME_ROOT}/contrib_ops/cuda/collective/distributed_expand.cc"
        "${ONNXRUNTIME_ROOT}/contrib_ops/cuda/collective/distributed_reduce.cc"
        "${ONNXRUNTIME_ROOT}/contrib_ops/cuda/collective/distributed_unsqueeze.cc"
        "${ONNXRUNTIME_ROOT}/contrib_ops/cuda/collective/distributed_squeeze.cc"
      )
    endif()
    # add using ONNXRUNTIME_ROOT so they show up under the 'contrib_ops' folder in Visual Studio
    source_group(TREE ${ONNXRUNTIME_ROOT} FILES ${onnxruntime_cuda_contrib_ops_cc_srcs} ${onnxruntime_cuda_contrib_ops_cu_srcs})
    list(APPEND onnxruntime_providers_cuda_src ${onnxruntime_cuda_contrib_ops_cc_srcs} ${onnxruntime_cuda_contrib_ops_cu_srcs})
  endif()

  if (onnxruntime_ENABLE_TRAINING_OPS)
    file(GLOB_RECURSE onnxruntime_cuda_training_ops_cc_srcs CONFIGURE_DEPENDS
      "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/*.h"
      "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/*.cc"
    )

    file(GLOB_RECURSE onnxruntime_cuda_training_ops_cu_srcs CONFIGURE_DEPENDS
      "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/*.cu"
      "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/*.cuh"
    )

    source_group(TREE ${ORTTRAINING_ROOT} FILES ${onnxruntime_cuda_training_ops_cc_srcs} ${onnxruntime_cuda_training_ops_cu_srcs})
    list(APPEND onnxruntime_providers_cuda_src ${onnxruntime_cuda_training_ops_cc_srcs} ${onnxruntime_cuda_training_ops_cu_srcs})

    if(NOT onnxruntime_ENABLE_TRAINING)
      file(GLOB_RECURSE onnxruntime_cuda_full_training_only_srcs
        "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/collective/*.cc"
        "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/collective/*.h"
        "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/communication/*.cc"
        "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/communication/*.h"
        "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/controlflow/record.cc"
        "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/controlflow/record.h"
        "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/controlflow/wait.cc"
        "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/controlflow/wait.h"
        "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/controlflow/yield.cc"
        "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/gist/*.cc"
        "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/gist/*.h"
        "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/gist/*.cu"
        "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/torch/*.cc"
        "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/torch/*.h"
        "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/triton/triton_op.cc"
      )

      list(REMOVE_ITEM onnxruntime_providers_cuda_src ${onnxruntime_cuda_full_training_only_srcs})
    elseif(WIN32 OR NOT onnxruntime_USE_NCCL)
      # NCCL is not support in Windows build
      file(GLOB_RECURSE onnxruntime_cuda_nccl_op_srcs
        "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/collective/nccl_common.cc"
        "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/collective/nccl_kernels.cc"
        "${ORTTRAINING_SOURCE_DIR}/training_ops/cuda/collective/megatron.cc"
      )
      list(REMOVE_ITEM onnxruntime_providers_cuda_src ${onnxruntime_cuda_nccl_op_srcs})
    endif()
  endif()

  if (onnxruntime_REDUCED_OPS_BUILD)
    substitute_op_reduction_srcs(onnxruntime_providers_cuda_src)
  endif()

  if(onnxruntime_ENABLE_CUDA_EP_INTERNAL_TESTS)
    # cuda_provider_interface.cc is removed from the object target: onnxruntime_providers_cuda_obj and
    # added to the lib onnxruntime_providers_cuda separately.
    # onnxruntime_providers_cuda_ut can share all the object files with onnxruntime_providers_cuda except cuda_provider_interface.cc.
    set(cuda_provider_interface_src ${ONNXRUNTIME_ROOT}/core/providers/cuda/cuda_provider_interface.cc)
    list(REMOVE_ITEM onnxruntime_providers_cuda_src ${cuda_provider_interface_src})
    onnxruntime_add_object_library(onnxruntime_providers_cuda_obj ${onnxruntime_providers_cuda_src})

    set(onnxruntime_providers_cuda_all_srcs ${cuda_provider_interface_src})
    if(WIN32)
      # Sets the DLL version info on Windows: https://learn.microsoft.com/en-us/windows/win32/menurc/versioninfo-resource
      list(APPEND onnxruntime_providers_cuda_all_srcs "${ONNXRUNTIME_ROOT}/core/providers/cuda/onnxruntime_providers_cuda.rc")
    endif()

    onnxruntime_add_shared_library_module(onnxruntime_providers_cuda ${onnxruntime_providers_cuda_all_srcs}
                                                                     $<TARGET_OBJECTS:onnxruntime_providers_cuda_obj>)
  else()
    set(onnxruntime_providers_cuda_all_srcs ${onnxruntime_providers_cuda_src})
    if(WIN32)
      # Sets the DLL version info on Windows: https://learn.microsoft.com/en-us/windows/win32/menurc/versioninfo-resource
      list(APPEND onnxruntime_providers_cuda_all_srcs "${ONNXRUNTIME_ROOT}/core/providers/cuda/onnxruntime_providers_cuda.rc")
    endif()

    onnxruntime_add_shared_library_module(onnxruntime_providers_cuda ${onnxruntime_providers_cuda_all_srcs})
  endif()

  if(WIN32)
    # FILE_NAME preprocessor definition is used in onnxruntime_providers_cuda.rc
    target_compile_definitions(onnxruntime_providers_cuda PRIVATE FILE_NAME=\"onnxruntime_providers_cuda.dll\")
  endif()

  # config_cuda_provider_shared_module can be used to config onnxruntime_providers_cuda_obj, onnxruntime_providers_cuda & onnxruntime_providers_cuda_ut.
  # This function guarantees that all 3 targets have the same configurations.
  function(config_cuda_provider_shared_module target)
    if (onnxruntime_REDUCED_OPS_BUILD)
      add_op_reduction_include_dirs(${target})
    endif()

    if (HAS_GUARD_CF)
      target_compile_options(${target} PRIVATE "$<$<COMPILE_LANGUAGE:CUDA>:SHELL:-Xcompiler /guard:cf>")
    endif()

    if (HAS_QSPECTRE)
      target_compile_options(${target} PRIVATE "$<$<COMPILE_LANGUAGE:CUDA>:SHELL:-Xcompiler /Qspectre>")
    endif()

    foreach(ORT_FLAG ${ORT_WARNING_FLAGS})
        target_compile_options(${target} PRIVATE "$<$<COMPILE_LANGUAGE:CUDA>:SHELL:-Xcompiler \"${ORT_FLAG}\">")
    endforeach()

    # CUDA 11.3+ supports parallel compilation
    # https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html#options-for-guiding-compiler-driver-threads
    if (CMAKE_CUDA_COMPILER_VERSION VERSION_GREATER_EQUAL 11.3)
      set(onnxruntime_NVCC_THREADS "1" CACHE STRING "Number of threads that NVCC can use for compilation.")
      target_compile_options(${target} PRIVATE "$<$<COMPILE_LANGUAGE:CUDA>:SHELL:--threads \"${onnxruntime_NVCC_THREADS}\">")
    endif()

    # Since CUDA 12.8, compiling diagnostics become stricter
    if (CMAKE_CUDA_COMPILER_VERSION VERSION_GREATER_EQUAL 12.8)
      target_compile_options(${target} PRIVATE "$<$<COMPILE_LANGUAGE:CUDA>:--relocatable-device-code=true>")
      set_target_properties(${target} PROPERTIES CUDA_SEPARABLE_COMPILATION ON)
      if (MSVC)
        target_compile_options(${target} PRIVATE "$<$<COMPILE_LANGUAGE:CUDA>:SHELL:-Xcompiler /wd4505>")
      endif()
      # skip diagnosis error caused by cuda header files
      target_compile_options(${target} PRIVATE "$<$<COMPILE_LANGUAGE:CUDA>:--diag-suppress=221>")
    endif()

    if (UNIX)
      target_compile_options(${target} PRIVATE "$<$<COMPILE_LANGUAGE:CUDA>:SHELL:-Xcompiler -Wno-reorder>"
                  "$<$<NOT:$<COMPILE_LANGUAGE:CUDA>>:-Wno-reorder>")
      target_compile_options(${target} PRIVATE "$<$<COMPILE_LANGUAGE:CUDA>:SHELL:-Xcompiler -Wno-error=sign-compare>"
                  "$<$<NOT:$<COMPILE_LANGUAGE:CUDA>>:-Wno-error=sign-compare>")
    else()
      #mutex.cuh(91): warning C4834: discarding return value of function with 'nodiscard' attribute
      target_compile_options(${target} PRIVATE "$<$<COMPILE_LANGUAGE:CUDA>:SHELL:-Xcompiler /wd4834>")
      target_compile_options(${target} PRIVATE "$<$<COMPILE_LANGUAGE:CUDA>:SHELL:-Xcompiler /wd4127>")
      if (MSVC)
        # the VS warnings for 'Conditional Expression is Constant' are spurious as they don't handle multiple conditions
        # e.g. `if (std::is_same_v<T, float> && not_a_const)` will generate the warning even though constexpr cannot
        # be used due to `&& not_a_const`. This affects too many places for it to be reasonable to disable at a finer
        # granularity.
        target_compile_options(${target} PRIVATE "$<$<COMPILE_LANGUAGE:CXX>:/wd4127>")
      endif()
    endif()

    if(MSVC)
      target_compile_options(${target} PRIVATE "$<$<COMPILE_LANGUAGE:CUDA>:SHELL:-Xcompiler /Zc:__cplusplus>")
    endif()

    onnxruntime_add_include_to_target(${target} onnxruntime_common onnxruntime_framework onnx onnx_proto ${PROTOBUF_LIB} flatbuffers::flatbuffers)
    if (onnxruntime_ENABLE_TRAINING_OPS)
      onnxruntime_add_include_to_target(${target} onnxruntime_training)
      if (onnxruntime_ENABLE_TRAINING)
        target_link_libraries(${target} PRIVATE onnxruntime_training)
      endif()
      if (onnxruntime_ENABLE_TRAINING_TORCH_INTEROP OR onnxruntime_ENABLE_TRITON)
        onnxruntime_add_include_to_target(${target} Python::Module)
      endif()
    endif()

    add_dependencies(${target} onnxruntime_providers_shared ${onnxruntime_EXTERNAL_DEPENDENCIES})
    if(onnxruntime_CUDA_MINIMAL)
      target_compile_definitions(${target} PRIVATE USE_CUDA_MINIMAL)
      target_link_libraries(${target} PRIVATE ${ABSEIL_LIBS} ${ONNXRUNTIME_PROVIDERS_SHARED} Boost::mp11 safeint_interface CUDA::cudart)
    else()
      include(cudnn_frontend) # also defines CUDNN::*
      if (onnxruntime_USE_CUDA_NHWC_OPS)
        if(CUDNN_MAJOR_VERSION GREATER 8)
          add_compile_definitions(ENABLE_CUDA_NHWC_OPS)
        else()
          message( WARNING "To compile with NHWC ops enabled please compile against cuDNN 9 or newer." )
        endif()
      endif()
      target_link_libraries(${target} PRIVATE CUDA::cublasLt CUDA::cublas CUDNN::cudnn_all cudnn_frontend CUDA::curand CUDA::cufft CUDA::cudart
              ${ABSEIL_LIBS} ${ONNXRUNTIME_PROVIDERS_SHARED} Boost::mp11 safeint_interface)
    endif()

    include(cutlass)
    target_include_directories(${target} PRIVATE ${cutlass_SOURCE_DIR}/include ${cutlass_SOURCE_DIR}/examples ${cutlass_SOURCE_DIR}/tools/util/include)
    target_link_libraries(${target} PRIVATE Eigen3::Eigen)
    target_include_directories(${target} PRIVATE ${ONNXRUNTIME_ROOT} ${CMAKE_CURRENT_BINARY_DIR} PUBLIC ${CUDAToolkit_INCLUDE_DIRS})
    # ${CMAKE_CURRENT_BINARY_DIR} is so that #include "onnxruntime_config.h" inside tensor_shape.h is found
    set_target_properties(${target} PROPERTIES LINKER_LANGUAGE CUDA)
    set_target_properties(${target} PROPERTIES FOLDER "ONNXRuntime")

    if("90" IN_LIST CMAKE_CUDA_ARCHITECTURES_ORIG)
      target_compile_options(${target} PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:-Xptxas=-w>)
      target_compile_definitions(${target} PRIVATE COMPILE_HOPPER_TMA_GEMMS)
      if (MSVC)
        target_compile_options(${target} PRIVATE "$<$<COMPILE_LANGUAGE:CUDA>:SHELL:-Xcompiler /bigobj>")
        target_compile_options(${target} PRIVATE "$<$<COMPILE_LANGUAGE:CUDA>:--diag-suppress=177>")
        target_compile_options(${target} PRIVATE "$<$<COMPILE_LANGUAGE:CUDA>:SHELL:-Xcompiler /wd4172>")
      endif()
    endif()

    if (onnxruntime_ENABLE_CUDA_PROFILING) # configure cupti for cuda profiling
      target_link_libraries(${target} PRIVATE CUDA::cupti)
    endif()

    if (onnxruntime_ENABLE_NVTX_PROFILE)
      target_link_libraries(${target} PRIVATE CUDA::nvtx3)
    endif()

    if (onnxruntime_ENABLE_TRAINING_OPS)
      target_include_directories(${target} PRIVATE ${ORTTRAINING_ROOT} ${MPI_CXX_INCLUDE_DIRS})
    endif()

    if (onnxruntime_USE_NCCL)
      target_include_directories(${target} PRIVATE ${NCCL_INCLUDE_DIRS})
      target_link_libraries(${target} PRIVATE ${NCCL_LIBRARIES})
    endif()

    if (WIN32)
      # *.cu cannot use PCH
      if (NOT onnxruntime_BUILD_CACHE)
        target_precompile_headers(${target} PUBLIC
          "${ONNXRUNTIME_ROOT}/core/providers/cuda/cuda_pch.h"
          "${ONNXRUNTIME_ROOT}/core/providers/cuda/cuda_pch.cc"
        )
      endif()

      # minimize the Windows includes.
      # this avoids an issue with CUDA 11.6 where 'small' is defined in the windows and cuda headers.
      target_compile_definitions(${target} PRIVATE "WIN32_LEAN_AND_MEAN")

      # disable a warning from the CUDA headers about unreferenced local functions
      #target_compile_options(${target} PRIVATE /wd4505)
      set(onnxruntime_providers_cuda_static_library_flags
          -IGNORE:4221 # LNK4221: This object file does not define any previously undefined public symbols, so it will not be used by any link operation that consumes this library
      )
      set_target_properties(${target} PROPERTIES
          STATIC_LIBRARY_FLAGS "${onnxruntime_providers_cuda_static_library_flags}")
    endif()

    if(APPLE)
      set_property(TARGET ${target} APPEND_STRING PROPERTY LINK_FLAGS "-Xlinker -exported_symbols_list ${ONNXRUNTIME_ROOT}/core/providers/cuda/exported_symbols.lst")
    elseif(UNIX)
      set_property(TARGET ${target} APPEND_STRING PROPERTY LINK_FLAGS "-Xlinker --version-script=${ONNXRUNTIME_ROOT}/core/providers/cuda/version_script.lds -Xlinker --gc-sections")
    elseif(WIN32)
      set_property(TARGET ${target} APPEND_STRING PROPERTY LINK_FLAGS "-DEF:${ONNXRUNTIME_ROOT}/core/providers/cuda/symbols.def")
    else()
      message(FATAL_ERROR "${target} unknown platform, need to specify shared library exports for it")
    endif()

    if (onnxruntime_ENABLE_ATEN)
      target_compile_definitions(${target} PRIVATE ENABLE_ATEN)
    endif()
  endfunction()
  if(onnxruntime_ENABLE_CUDA_EP_INTERNAL_TESTS)
    config_cuda_provider_shared_module(onnxruntime_providers_cuda_obj)
  endif()
  config_cuda_provider_shared_module(onnxruntime_providers_cuda)
  # Cannot use glob because the file cuda_provider_options.h should not be exposed out.
  set(ONNXRUNTIME_CUDA_PROVIDER_PUBLIC_HEADERS
        "${REPO_ROOT}/include/onnxruntime/core/providers/cuda/cuda_context.h"
        "${REPO_ROOT}/include/onnxruntime/core/providers/cuda/cuda_resource.h"
      )
  set_target_properties(onnxruntime_providers_cuda PROPERTIES
    PUBLIC_HEADER "${ONNXRUNTIME_CUDA_PROVIDER_PUBLIC_HEADERS}")
  install(TARGETS onnxruntime_providers_cuda
          PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/onnxruntime/core/providers/cuda
          ARCHIVE  DESTINATION ${CMAKE_INSTALL_LIBDIR}
          LIBRARY  DESTINATION ${CMAKE_INSTALL_LIBDIR}
          RUNTIME  DESTINATION ${CMAKE_INSTALL_BINDIR})
