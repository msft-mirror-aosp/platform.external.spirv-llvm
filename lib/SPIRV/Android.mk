#
# Copyright (C) 2016 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

LOCAL_PATH := $(call my-dir)
LIBSPIRV_ROOT_PATH := $(LOCAL_PATH)
LLVM_ROOT := external/llvm

FORCE_BUILD_LLVM_DISABLE_NDEBUG ?= false
# Legality check: FORCE_BUILD_LLVM_DISABLE_NDEBUG should consist of
# one word -- either "true" or "false".
ifneq "$(words $(FORCE_BUILD_LLVM_DISABLE_NDEBUG))$(words $(filter-out true \
 false,$(FORCE_BUILD_LLVM_DISABLE_NDEBUG)))" "10"
  $(error FORCE_BUILD_LLVM_DISABLE_NDEBUG may only be true, false, or unset)
endif

FORCE_BUILD_LLVM_DEBUG ?= false
# Legality check: FORCE_BUILD_LLVM_DEBUG should consist of
# one word -- either "true" or "false".
ifneq "$(words $(FORCE_BUILD_LLVM_DEBUG))$(words $(filter-out true \
 false,$(FORCE_BUILD_LLVM_DEBUG)))" "10"
  $(error FORCE_BUILD_LLVM_DEBUG may only be true, false, or unset)
endif

SPIRV_SOURCES:= \
  libSPIRV/SPIRVBasicBlock.cpp \
  libSPIRV/SPIRVDebug.cpp \
  libSPIRV/SPIRVDecorate.cpp \
  libSPIRV/SPIRVEntry.cpp \
  libSPIRV/SPIRVFunction.cpp \
  libSPIRV/SPIRVInstruction.cpp \
  libSPIRV/SPIRVModule.cpp \
  libSPIRV/SPIRVStream.cpp \
  libSPIRV/SPIRVType.cpp \
  libSPIRV/SPIRVValue.cpp \
  Mangler/FunctionDescriptor.cpp \
  Mangler/Mangler.cpp \
  Mangler/ManglingUtils.cpp \
  Mangler/ParameterType.cpp \
  OCL20To12.cpp \
  OCL20ToSPIRV.cpp \
  OCL21ToSPIRV.cpp \
  OCLTypeToSPIRV.cpp \
  OCLUtil.cpp \
  SPIRVLowerBool.cpp \
  SPIRVLowerConstExpr.cpp \
  SPIRVLowerOCLBlocks.cpp \
  SPIRVReader.cpp \
  SPIRVRegularizeLLVM.cpp \
  SPIRVToOCL20.cpp \
  SPIRVUtil.cpp \
  SPIRVWriter.cpp \
  SPIRVWriterPass.cpp \
  TransOCLMD.cpp

#=====================================================================
# Host Shared Library libSPIRV
#=====================================================================

# Don't build for unbundled branches
ifeq (,$(TARGET_BUILD_APPS))

include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
  $(SPIRV_SOURCES)

LOCAL_C_INCLUDES := \
  $(LIBSPIRV_ROOT_PATH)/Mangler \
  $(LIBSPIRV_ROOT_PATH)/libSPIRV \
  $(LLVM_ROOT)/include \
  $(LLVM_ROOT)/host/include

LOCAL_MODULE := libSPIRV

# TODO: test windows build

LOCAL_MODULE_HOST_OS := linux
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_IS_HOST_MODULE := true
LOCAL_MULTILIB := first

LOCAL_LDLIBS_linux := -lrt -ldl -ltinfo -lpthread

LOCAL_SHARED_LIBRARIES_linux += libLLVM

LOCAL_CFLAGS += $(TOOL_CFLAGS) \
  -D_SPIRV_LLVM_API \
  -D__STDC_LIMIT_MACROS \
  -Wno-error=pessimizing-move \
  -Wno-error=unused-variable \
  -Wno-error=unused-private-field \
  -Wno-error=unused-function \
  -Wno-error=dangling-else \
  -Wno-error=ignored-qualifiers

include $(LLVM_ROOT)/llvm.mk
include $(LLVM_GEN_INTRINSICS_MK)
include $(LLVM_GEN_ATTRIBUTES_MK)
include $(LLVM_HOST_BUILD_MK)
include $(BUILD_HOST_SHARED_LIBRARY)

endif # Don't build in unbundled branches

#=====================================================================
# Device Shared Library libSPIRV
#=====================================================================
ifneq (true,$(DISABLE_LLVM_DEVICE_BUILDS))

include $(CLEAR_VARS)

LOCAL_MODULE := libSPIRV
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := SHARED_LIBRARIES

LOCAL_SHARED_LIBRARIES := libLLVM

LOCAL_SRC_FILES := \
  $(SPIRV_SOURCES)

LOCAL_C_INCLUDES := \
  $(LIBSPIRV_ROOT_PATH)/Mangler \
  $(LIBSPIRV_ROOT_PATH)/libSPIRV

LOCAL_CFLAGS += $(TOOL_CFLAGS) \
  -D_SPIRV_LLVM_API \
  -Wno-error=pessimizing-move \
  -Wno-error=unused-variable \
  -Wno-error=unused-private-field \
  -Wno-error=unused-function \
  -Wno-error=dangling-else \
  -Wno-error=ignored-qualifiers \
  -Wno-error=non-virtual-dtor

include $(LLVM_GEN_INTRINSICS_MK)
include $(LLVM_GEN_ATTRIBUTES_MK)
include $(LLVM_DEVICE_BUILD_MK)
include $(BUILD_SHARED_LIBRARY)
endif

#=====================================================================
# Include Subdirectories
#=====================================================================
include $(call all-makefiles-under,$(LOCAL_PATH))

