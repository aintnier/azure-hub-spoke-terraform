# Architettura Hub & Spoke: Teoria e Pratica (Layer 1)

> Questo documento didattico espone i principi architetturali alla base del **Layer 1 (Manual Peering)**. Analizzeremo il comportamento dei network components implementati tramite Terraform e validati empiricamente su Azure.

---

## 1. Il Paradigma Hub and Spoke

Nel Cloud Computing moderno, isolare singole macchine o singoli applicativi su Virtual Network separate crea un problema di scalabilità. Il paradigma **Hub-and-Spoke** risolve questo problema decentralizzando il *Compute* e centralizzando la *Security*.

Al centro della stella risiede l'**Hub** (`vnet-hub-dev`), il cuore nevralgico della topologia. 
I satelliti sono gli **Spoke** (`vnet-spoke1-dev`, `vnet-spoke2-dev`), progettati per ospitare macchine virtuali e database (i carichi di lavoro) pur rimanendo sprovvisti di connettività diretta al mondo esterno.

### Il Ponticello: VNet Peering
Due Virtual Network distinte su Azure **non comunicano di default**. Per superare questo limite progettuale senza passare per VPN o nodi pubblici, si instaura un **VNet Peering** manuale. 
- La connessione non è transitiva: se `Spoke 1` e `Spoke 2` fanno peering con l'`Hub`, *non* comunicano tra loro, a meno che non ci sia un "direttore d'orchestra" in mezzo.

---

## 2. Il Direttore d'Orchestra: L'Azure Firewall

Per abilitare il traffico controllato tra le reti satelliti, entra in gioco un **Network Virtual Appliance (NVA)**, in questo caso l'Azure Firewall.

### L'inganno del Routing (UDR)
Come convincere una macchina su `Spoke 1` a deviare i suoi pacchetti verso l'`Hub`? La risposta è nel custom routing implementato tramite la `Route Table` (`rt-spoke1-dev`).
- Si definisce una regola universale (`0.0.0.0/0`) associata alla Subnet.
- Si setta l'indirizzo privato del Firewall (`10.0.0.4`) come destinatario di questo hop.
- **Risultato:** Dal ping verso il server accanto, al curl verso un server Esterno, l'intero payload viene sequestrato a basso livello e iniettato dritto nel Firewall.

### Zero-Trust
L'Azure Firewall segue il paradigma **Deny by Default**. Il pacchetto arrivato dall'hop di routing viene disarticolato:
Se è un transito tra `Spoke-to-Spoke` e le Policy consentono `ICMP`, il traffico attraversa il firewall arrivando al secondo Peering. Altrimenti, finisce tracciato nei **Log Analytics** e cestinato all'istante (Packet Drop).

---

## 3. L'Egress "SNATTato" Limitato

La prova empirica dell'esperimento numero 4 è quella dal valore inestimabile. Qualsiasi connessione diretta ad originare su Internet fallirà se il protocollo è ICMP (il classico `ping`), mentre prospererà se è protocollo TCP/UDP (come l'`HTTP` richiesto per scaricare gli aggiornamenti).

Perché? Il livello **Standard** dell'Azure Firewall esegue automaticamente una procedura definita **SNAT** (Source Network Address Translation):
1. La VM `Spoke 1` spara verso `google.com` (Layer 4 TCP 443).
2. La VNet prende il pacchetto e lo invia sull'`IP 10.0.0.4`.
3. Il Firewall legge la destinazione (Internet). Applica l'Allow Rule definita per l'HTTPS.
4. **Il miracolo:** Il Firewall spoglia il pacchetto dell'indirizzo privato della VM, indossa l'indirizzo del suo IP Pubblico (`pip-fw-hub-dev`), ed elude l'osservabilità portando a termine la transazione. Tutte le risposte compiono il percorso simmetrico. Questa traslazione non viene eseguita attivamente per ICMP da parte di Azure, bloccando così i ping.

---

## 4. Azure Bastion: RDP/SSH Clientless

Tuttavia l'amministratore (noi) doveva accedere alla VM di Test usando `SSH / Port 22` pur non potendo associare un indirizzo pubblico alla Subnet (che violerebbe la security dell'architettura).

L'**Azure Bastion** risolve radicalmente il dilemma:
Funge da WebRTC Proxy-Gateway situato nella VNet dell'Hub. Una volta validati dallo strato control-plane del portale HTTPS, crea un bridge diretto `Bastion <> VM` per iniettare l'I/O dal cloud fino al nostro Browser Web, il tutto in estrema sicurezza ed eludendo l'uso di chiavi private vulnerabili intermedie.

---

## 5. Automazione e Infrastructure as Code (Terraform)

Creare, manutenere o modificare un'architettura complessa come questa cliccando manualmente sul portale Azure (*"ClickOps"*) viene ormai considerato un "totale caos" nel panorama IT moderno: è un processo lento, prono ad errori umani e privo di uno storico tracciato delle modifiche. 
È qui che entra in gioco **Terraform**: uno strumento open-source creato da HashiCorp che introduce la vera essenza dell'**Infrastructure as Code (IaC)**.
Trattiamo le reti, i firewall e i server letteralmente come file di testo versionati su Git, potendo "clonare" l'intera architettura in pochi secondi e garantendone l'immutabilità.

### 5.1 La Logica "Dichiarativa" e l'Idempotenza
Terraform utilizza un linguaggio chiamato **HCL (HashiCorp Configuration Language)**, che ha una natura strettamente **Dichiarativa**. 
- Invece di dirgli *"Come"* fare le cose (come in uno script bash classico: *"Crea la risorsa X e poi vai alla riga Y"*), ti limiti a dichiarare lo stato finale desiderato (il *"Cosa"*).
- Nel nostro `networking.tf`, scrivendo il blocco `resource "azurerm_virtual_network" "hub"`, noi dichiariamo *che quella rete deve esistere*. Terraform calcolerà da solo le chiamate API ad Azure necessarie per arrivarci.
- **Idempotenza:** Questo principio cardine spiegato nei tutorial ci insegna che puoi lanciare lo stesso codice decine di volte: se la VNet esiste già ed è identica al codice, Terraform non la toccherà. Se invece qualcuno l'ha modificata a mano per errore dal Portale, Terraform correggerà "l'infrazione" riportandola esattamente allo stato del codice originale.

### 5.2 I Concetti Fondamentali e il Grafo delle Dipendenze

La teoria di Terraform si articola su componenti chiave che abbiamo sfruttato in modo massiccio in questo Layer 1:

1. **Il Provider (`providers.tf`)**
   I provider sono i traduttori che permettono al *Core* di Terraform di dialogare con i vendor Cloud (Azure, AWS, Google) e convertirne la logica in chiamate REST. Noi abbiamo agganciato `hashicorp/azurerm` specificando versioni "pinnate" per evitare "Breaking Changes" nel tempo.

2. **La Sorgente della Verità e l'Analisi del Delta (`terraform.tfstate`)**
   Questo è il componente più critico in assoluto: la "memoria" dell'intera operazione. Nel blocco `backend "azurerm"`, carichiamo lo State File temporaneo su uno Storage Account remoto protetto (`tsterraformstate26032026`). 
   Ogni volta che si esegue Terraform, viene compiuta un'**Analisi del Delta** a tre vie:
   - Il tuo **Codice HCL** (Quello che vuoi)
   - L'ultimo **File di Stato** (Quello che Terraform si ricorda)
   - L'**Infrastruttura Reale** su Azure (Quello che fisicamente esiste)
   Sulla base di questo triplice confronto, Terraform decide chirurgicamente le modifiche da attuare.

3. **Il Grafo Invisibile delle Dipendenze (`networking.tf`, `routing.tf`)**
   Quando creiamo un *Virtual Network Peering*, quel blocco "esige" di conoscere l'ID di due Virtual Network. Terraform estrapola un **Grafo delle Dipendenze** automatico: leggendo il codice HCL, comprende che i Peering non possono in alcun modo precedere la creazione delle Reti di base, e ordina l'invio delle API ad Azure di conseguenza. Usando moduli esterni, si possono addirittura plasmare risorse giganti trattandole come "Mattoncini LEGO".

4. **Variables e Outputs (`variables.tf`, `outputs.tf`)**
   Le variabili astraggono i parametri hardcoded sfruttando la forte tipizzazione (`type = string o map`) e le `description` (Best Practice obbligatoria per documentare l'IaC per il team). Gli Output consentono a fine ciclo di estrarre al volo risultati processati, come l'esatto IP che Azure ha assegnato alla nostra VM.

### 5.3 Il Ciclo di Vita (Pipeline di Automazione CI/CD)
Un'implementazione professionale impone di non lanciare mai i comandi dal portatile di uno sviluppatore, demandando il lavoro ai server sicuri. I nostri workflow `.github/workflows` codificano in sequenza esatta i comandi di vita di Terraform:

1. **`terraform init` (Inizializzazione):** Prepara il cloud runner, scarica i plugin necessari e si collega in modalità "Zero Trust" senza password (esclusivamente con federazione OIDC) allo Stato remoto Azure.
2. **`terraform plan` (La Rete di Sicurezza):** È un *dry-run* simulato essenziale. Mette in scena le API di Azure e mostra all'umano: "Plan: 18 added, 0 changed, 0 destroyed". Ferma uno sviluppatore dall'applicare un typo fatale che raderebbe al suolo la produzione.
3. **`terraform apply -auto-approve` (Esecuzione Finale):** Approvato il piano costruttivo, questa istruzione martella letteralmente le richieste sul Cloud trasformando i file testuali dell'IDE di Visual Studio Code in Server e Routing fisici.

---
**Lesson Learned finale:** L'IaC tramite Terraform impone rigidità formale ma regala un'infrastruttura auto-documentata, immutabile e gestibile per enormi team DevOps. Questo report teorico dimostra come ogni blocco di testo nel nostro repository plasmi deterministicamente la fisica delle comunicazioni. **Layer 1 Completato.**
