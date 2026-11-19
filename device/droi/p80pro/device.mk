DEVICE_PATH := device/droi/p80pro

# Device-specific recovery init (USB configfs on MTK). Must land in the
# recovery root because this image is recovery-as-boot.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery/root/init.recovery.mt6768.rc:recovery/root/init.recovery.mt6768.rc

# Keep the stock first-stage fstab so the same boot image can still do a
# normal (force_normal_boot=1) boot into the system.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery/root/first_stage_ramdisk/fstab.mt6768:recovery/root/first_stage_ramdisk/fstab.mt6768 \
    $(DEVICE_PATH)/recovery/root/first_stage_ramdisk/avb/q-gsi.avbpubkey:recovery/root/first_stage_ramdisk/avb/q-gsi.avbpubkey \
    $(DEVICE_PATH)/recovery/root/first_stage_ramdisk/avb/r-gsi.avbpubkey:recovery/root/first_stage_ramdisk/avb/r-gsi.avbpubkey \
    $(DEVICE_PATH)/recovery/root/first_stage_ramdisk/avb/s-gsi.avbpubkey:recovery/root/first_stage_ramdisk/avb/s-gsi.avbpubkey