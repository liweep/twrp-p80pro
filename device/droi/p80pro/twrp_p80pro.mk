DEVICE_PATH := device/droi/p80pro

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
$(call inherit-product, vendor/twrp/config/common.mk)
$(call inherit-product, $(DEVICE_PATH)/device.mk)

PRODUCT_DEVICE := p80pro
PRODUCT_NAME := twrp_p80pro
PRODUCT_BRAND := 5G
PRODUCT_MODEL := P80Pro+
PRODUCT_MANUFACTURER := 5G
PRODUCT_RELEASE_NAME := p80pro

PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_SHIPPING_API_LEVEL := 30

# vendor/twrp/build/tasks/kernel.mk copies TARGET_PREBUILT_KERNEL to
# $(PRODUCT_OUT)/kernel itself (NEEDS_KERNEL_COPY), so no PRODUCT_COPY_FILES
# rule for "kernel" here - that would override the same target.