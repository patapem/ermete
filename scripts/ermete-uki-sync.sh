#!/bin/bash
# Ermete OS: UKI Synchronization Engine per systemd-boot
# CHANGELOG: Scrittura dello script per l'estrazione UKI dall'albero OSTree all'ESP, con garbage collection e atomicità.

set -euo pipefail
ESP_PATH="/boot/efi"
EFI_LINUX_DIR="${ESP_PATH}/EFI/Linux"

mkdir -p "${EFI_LINUX_DIR}"

ACTIVE_DEPLOY=$(readlink -f /ostree/deploy/ermeteos/deploy/current || echo "")
if [ -z "${ACTIVE_DEPLOY}" ]; then
    echo "CRITICAL: Impossibile determinare il deployment OSTree attivo." >&2
    exit 1
fi

DEPLOY_HASH=$(basename "${ACTIVE_DEPLOY}" | cut -d '.' -f1)
KERNEL_VERSION=$(ls -1 "${ACTIVE_DEPLOY}/usr/lib/modules/" | head -n 1)
UKI_SRC="${ACTIVE_DEPLOY}/usr/lib/modules/${KERNEL_VERSION}/vmlinuz-ermete.efi"
UKI_DEST="${EFI_LINUX_DIR}/ermete-${DEPLOY_HASH}.efi"

if [ ! -f "${UKI_DEST}" ]; then
    echo "INFO: Nuovo deployment rilevato (${DEPLOY_HASH}). Sincronizzazione UKI in corso..."
    cp --preserve=all "${UKI_SRC}" "${UKI_DEST}.tmp"
    sync -f "${UKI_DEST}.tmp"
    mv "${UKI_DEST}.tmp" "${UKI_DEST}"
    
    if command -v bootctl >/dev/null 2>&1; then
        bootctl --esp-path="${ESP_PATH}" update
    fi
else
    echo "INFO: UKI per il deployment ${DEPLOY_HASH} già presente nell'ESP."
fi

for efi_file in "${EFI_LINUX_DIR}"/ermete-*.efi; do
    hash_in_file=$(basename "${efi_file}" | sed -E 's/ermete-(.*)\.efi/\1/')
    if [ ! -d "/sysroot/ostree/deploy/ermeteos/deploy/${hash_in_file}.0" ] && \
       [ ! -d "/sysroot/ostree/deploy/ermeteos/deploy/${hash_in_file}.1" ]; then
        echo "INFO: Rimuovo UKI orfano: ${efi_file}"
        rm -f "${efi_file}"
    fi
done

echo "SUCCESS: Sincronizzazione UKI terminata."
exit 0
