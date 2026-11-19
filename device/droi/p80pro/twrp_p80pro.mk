DEVICE_PATH := device/droi/p80pro

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/embedded.mk)
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

# The prebuilt kernel is installed by the build system's kernel tasks, which
# this TWRP manifest does not always include; copy it to PRODUCT_OUT/kernel
# ourselves so the bootimage rule always finds it.
PRODUCT_COPY_FILES += $(DEVICE_PATH)/prebuilt/kernel:kernel