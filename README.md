# Ermete OS 🛡️

Ermete è un sistema operativo desktop immutabile, zero-trust e focalizzato sulle performance. È costruito come un'immagine container OCI stratificata basata su **Fedora Atomic (bootc)**. 

Nasce per essere un *daily driver* inespugnabile: unisce un kernel custom ad alte prestazioni (CachyOS), osservabilità di sicurezza a livello kernel (eBPF via Cilium Tetragon), hardening di rete rigoroso (nftables) e un ambiente desktop minimale Wayland-only (KDE Plasma).

## 🏗️ Architettura & Design

* **Immutabilità a Cipolla (Layered OCI):** Il filesystem di root (`/usr`, `/bin`, `/sbin`) è in rigoroso **read-only**. Ogni aggiornamento è transazionale e atomico.
* **Sicurezza Offensiva & eBPF:** Il kernel è monitorato in tempo reale da Tetragon, eseguito all'interno di una sandbox Systemd de-privilegiata.
* **Rete Blindata:** Policy di default DROP. Sono consentiti esclusivamente loopback, DHCP, mDNS, traffico stabilito/correlato, SSH e ICMP essenziali. Conntrack ottimizzato via O(1) vmap.
* **Performance:** ZRAM ottimizzata per swap in memoria con compressione ZSTD. Kernel CachyOS e TCP BBR per il congestion control.

## 🚀 Installazione (Rebase Atomico)

Ermete non si installa tramite ISO. Se hai già una distribuzione OSTree compatibile (es. Fedora Kinoite o Silverblue), puoi "agganciare" il tuo sistema all'immagine OCI generata da questo repository. L'operazione non toccherà la tua `/var/home`.

1. Apri il terminale sul tuo sistema Fedora Atomic attuale.
2. Esegui il pull e lo switch all'immagine Ermete:
   ```bash
   sudo bootc switch ghcr.io/patapem/ermete:latest
   ```
3. Attendi il completamento del rendering dell'albero OSTree.
4. Riavvia il sistema:
   ```bash
   systemctl reboot
   ```

## 🛠️ Day-2 Operations: Come sopravvivere senza `dnf`

Il comando `dnf` **non è disponibile** sul sistema base, e `/usr` non è scrivibile. Tentare di installare pacchetti in modo tradizionale fallirà intenzionalmente. Per mantenere pulito l'host, utilizza gli strumenti integrati ("Escape Hatches"):

### 1. Applicazioni GUI (Flatpak)
Tutto il software desktop (browser, suite office, player multimediali) deve essere eseguito in sandbox via Flatpak.
```bash
# Esempio: Installare Firefox
flatpak install flathub org.mozilla.firefox
```

### 2. Strumenti CLI e Sviluppo (Distrobox)
Per ambienti di sviluppo, toolchain, compilatori e pacchetti RPM standard, crea un container mutabile integrato con l'host:
```bash
# Crea un ambiente di sviluppo basato su Fedora
distrobox create --name dev-env --image registry.fedoraproject.org/fedora-toolbox:41

# Entra nell'ambiente (qui hai i permessi di root e dnf a disposizione)
distrobox enter dev-env
```

## 🚑 Disaster Recovery (Rollback)

Se un aggiornamento notturno (pullato dal registry) rende il sistema instabile, puoi tornare istantaneamente allo stato precedente senza perdere i dati utente.

* **Dal Bootloader (GRUB/systemd-boot):** Seleziona semplicemente la voce di menu precedente all'avvio.
* **Da Terminale:**
  ```bash
  sudo rpm-ostree rollback
  systemctl reboot
  ```

## 🕵️‍♂️ Osservabilità eBPF & Rete

Ermete include strumenti nativi per l'analisi e il monitoraggio approfondito:

* **Lettura Log Tetragon:**
  ```bash
  sudo tail -f /var/log/tetragon/tetragon.log
  ```
* **Analisi Overhead eBPF (bpftop):**
  ```bash
  sudo bpftop
  ```
* **Verifica Tabella di Rete:**
  ```bash
  sudo nft list ruleset
  ```

---
*Progettato come Fortino Crittografico. Usato come Daily Driver.*
