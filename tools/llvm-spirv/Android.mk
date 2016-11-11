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
LLVM_SPIRV_ROOT_PATH := $(LOCAL_PATH)
LLVM_ROOT := external/llvm

LIBSPIRV_ROOT_PATH := $(LOCAL_PATH)/../../lib/SPIRV

LLVM_SPIRV_SOURCES := \
  llvm-spirv.cpp

#=====================================================================
# Host Executable llvm-spirv
#=====================================================================

# Don't build for unbundled branches
ifeq (,$(TARGET_BUILD_APPS))

include $(CLEAR_VARS)
include $(CLEAR_TBLGEN_VARS)
LLVM_ROOT_PATH := external/llvm

LOCAL_SRC_FILES := \
  $(LLVM_SPIRV_SOURCES)

LOCAL_C_INCLUDES := \
  $(LIBSPIRV_ROOT_PATH) \
  $(LIBSPIRV_ROOT_PATH)/Mangler \
  $(LIBSPIRV_ROOT_PATH)/libSPIRV \
  $(LLVM_ROOT)/include \
  $(LLVM_ROOT)/host/include

LOCAL_MODULE := llvm-spirv
LOCAL_MODULE_CLASS := EXECUTABLES

# TODO: handle windows and darwin

LOCAL_MODULE_HOST_OS := linux
LOCAL_IS_HOST_MODULE := true

LOCAL_LDLIBS_linux := -lrt -ldl -ltinfo -lpthread

LOCAL_SHARED_LIBRARIES_linux += libLLVM libSPIRV

LOCAL_CFLAGS += $(TOOL_CFLAGS) \
  -D_SPIRV_LLVM_API \
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
include $(BUILD_HOST_EXECUTABLE)

endif # Don't build in unbundled branches

#=====================================================================
# Device Executable llvm-spirv
#=====================================================================
ifneq (true,$(DISABLE_LLVM_DEVICE_BUILDS)))

include $(CLEAR_VARS)
include $(CLEAR_TBLGEN_VARS)
LLVM_ROOT_PATH := external/llvm

LOCAL_SRC_FILES := \
  $(LLVM_SPIRV_SOURCES)

LOCAL_C_INCLUDES := \
  $(LIBSPIRV_ROOT_PATH) \
  $(LIBSPIRV_ROOT_PATH)/Mangler \
  $(LIBSPIRV_ROOT_PATH)/libSPIRV

LOCAL_MODULE := llvm-spirv
LOCAL_MODULE_CLASS := EXECUTABLES

LOCAL_SHARED_LIBRARIES += libSPIRV libLLVM

LOCAL_CFLAGS += $(TOOL_CFLAGS) \
  -D_SPIRV_LLVM_API \
  -DNDEBUG=1 \
  -Wno-error=pessimizing-move \
  -Wno-error=unused-variable \
  -Wno-error=unused-private-field \
  -Wno-error=unused-function \
  -Wno-error=dangling-else \
  -Wno-error=ignored-qualifiers

include $(LLVM_GEN_INTRINSICS_MK)
include $(LLVM_GEN_ATTRIBUTES_MK)
include $(LLVM_DEVICE_BUILD_MK)
include $(BUILD_EXECUTABLE)

endif # Don't build in unbundled branches

#=====================================================================
# Include Subdirectories
#=====================================================================
include $(call all-makefiles-under,$(LOCAL_PATH))
