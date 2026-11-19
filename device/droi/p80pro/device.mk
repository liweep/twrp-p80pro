DEVICE_PATH := device/droi/p80pro

# Everything under recovery/root is copied into the recovery ramdisk by the
# build system automatically (recovery_root_private), so do not add it via
# PRODUCT_COPY_FILES as well - that defines the same rule twice.