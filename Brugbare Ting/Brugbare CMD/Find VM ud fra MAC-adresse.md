---
tags: [brugbare-ting, cli, kvm, libvirt, virsh, linux]
aliases: ["Search VM (Mac-ADDR)", "virsh domiflist", "Find VM fra MAC"]
---

# Find VM ud fra MAC-adresse (libvirt / virsh)

> [!abstract] Hvad & hvorfor
> Lister alle libvirt‑VM'er (også slukkede) sammen med deres netværksinterfaces og
> MAC‑adresser. Brug det når du har en MAC fra fx en DHCP‑lease eller ARP‑tabel og skal finde
> ud af hvilken VM den hører til.

```bash
# gennemløb alle VM'er (--all = også slukkede) og vis hver VM's interfaces + MAC
for each in $(sudo virsh list --all --name | tr "\n" " "); do
  echo ":: VM $each"
  sudo virsh domiflist "$each"
done
```

> [!tip] Kortere alternativer
> ```bash
> # alle interfaces for én kendt VM
> sudo virsh domiflist <vm-navn>
> # find VM-navnet direkte hvis du kender MAC'en
> sudo virsh list --all --name | while read v; do sudo virsh domiflist "$v" | grep -q "<MAC>" && echo "$v"; done
> ```
