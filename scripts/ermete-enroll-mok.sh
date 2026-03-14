#!/bin/bash
# Ermete OS: Script di Provisioning MOK Day-1
# CHANGELOG: Implementazione logica validazione UEFI e injection MOK.

set -euo pipefail
MOK_CERT_PATH="/etc/pki/ermeteos/ErmeteOS-MOK.der"

if [ ! -f "${MOK_CERT_PATH}" ]; then
    echo "CRITICAL: Certificato DER non trovato nel filesystem immutabile in ${MOK_CERT_PATH}" >&2
    exit 1
fi # [cite: 134, 135]

SB_STATE=$(mokutil --sb-state)
if [[ "${SB_STATE}" == *"disabled"* ]]; then
    echo "WARNING: Secure Boot è attualmente disabilitato nel firmware."
    echo "L'arruolamento non garantirà validazione fino all'abilitazione in UEFI."
fi # [cite: 136, 137, 138]

if mokutil --test-key "${MOK_CERT_PATH}" | grep -q "is already enrolled"; then
    echo "INFO: La MOK Root CA di Ermete OS è già arruolata. Nessuna azione richiesta."
    exit 0
fi # [cite: 138, 139, 140]

echo "======================================================================"
echo " Inizializzazione della richiesta di Arruolamento MOK"
echo " Verrà richiesta una password temporanea (One-Time)."
echo " Al riavvio, MOKManager richiederà l'immissione per confermare l'enrollment."
echo "======================================================================" # [cite: 140, 141, 142, 143]

mokutil --import "${MOK_CERT_PATH}"
echo "Richiesta acquisita. Riavviare il sistema per completare la Chain of Trust." # [cite: 143, 144]
