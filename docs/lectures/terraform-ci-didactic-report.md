# Terraform CI/CD: Report Didattico ed Analisi concettuale

Questo documento funge da ponte tra i concetti teorici esposti nei principali tutorial di Terraform (Infrastructure as Code, Declarative Syntax, State Management) e l'applicazione pratica nella nostra pipeline `ci.yml`.

## 1. Il Paradigma di Terraform: "What" vs "How"
Come spiegato in diversi tutorial (es. "How I Would Learn Terraform" e "Terraform in 15 mins"), Terraform non è uno script imperativo (come uno script Bash Python che esegue comandi sequenziali). È un linguaggio **dichiarativo**. 
Tu descrivi *solo lo stato finale* che desideri (es. "Voglio un Azure Firewall e 2 Macchine Virtuali"). Terraform si occupa di capire *come* arrivarci (quali API chiamare, in che ordine, ecc). 

**Come si adatta alla nostra CI (`ci.yml`):**
La nostra pipeline CI non crea le risorse ad ogni esecuzione. Essendo dichiarativa, la CI serve solo a **validare** se "il modo in cui abbiamo descritto il mondo" è sintatticamente corretto e coerente col provider.

## 2. Il Ciclo di Vita di Terraform (Core Workflow)
I video evidenziano sempre le 3 fasi fondamentali: `Init`, `Plan`, `Apply`. Nella nostra pipeline CI (`ci.yml`) usiamo parte di questo ciclo di vita per fare controlli automatizzati di qualità prima del rilascio (Shift-Left validation).

### A. Initialization (`terraform init -backend=false`)
- **Teoria**: Terraform non conosce nativamente Azure o AWS. È "nudo". Il comando `init` legge i file `.tf` per scaricare i "Provider plugins" necessari (nel nostro caso l'eseguibile `azurerm` che sa parlare con Azure). Inoltre inizializza la gestione dello "*State*".
- **Pratica nella nostra CI**: Nella CI eseguiamo `init -backend=false`. Questo è un trucco da professionisti: essendo un test "a vuoto", diciamo a Terraform di scaricare solo il provider AzureRM locale per testare il codice, senza provare a scaricare il file di stato dallo Storage Account (risparmiando tempo, autenticazioni e risorse).

### B. Mantenimento e Qualità del Codice (`terraform fmt` e `validate`)
- **Teoria**: Nei progetti aziendali lavorano molte persone. Terraform offre tool nativi per standardizzare il codice. `fmt` (Format) riallinea spazi, tabs e indentazioni. `validate` controlla che non ci siano errori di sintassi (es. una variabile richiamata che non esiste o un blocco non chiuso).
- **Pratica nella nostra CI**: Lo step `terraform fmt -check -recursive` controlla la formattazione. Se fallisce, Github Actions blocca la Pull Request. Questo assicura che il codice main sia sempre pulito. Il `terraform validate` chiude il cerchio garantendo che la sintassi HCL sia formalmente corretta.

### C. La Pianificazione (`terraform plan`)
- **Teoria**: È forse il comando più potente. Legge il "Desire State" (il tuo codice `.tf`), legge l'"Actual State" (dal cloud o dal file tfstate), calcola la differenza (*diff*), e annuncia cosa *creerà, modificherà o distruggerà*.
- **Pratica nella nostra CI**: Nel nostro file `ci.yml`, il `plan` è condizionato (`if: github.event_name == 'pull_request'`). Viene lanciato solo quando un collega chiede di unire del nuovo codice nel `main`. Questo genererà un report nei log mostrando l'impatto distruttivo/costruttivo, prima ancora di arrivare in produzione!

## 3. Perché la Matrix Strategy?
Nel nostro `ci.yml` abbiamo tre cartelle: `layer1-manual-peering`, `layer2-avnm`, `layer3-vwan`.
Invece di copiare e incollare il codice 3 volte, GitHub Actions usa il pattern:
```yaml
strategy:
  matrix:
    layer: [layer1-manual-peering, layer2-avnm, layer3-vwan]
```
Questo crea **3 runner Ubuntu temporanei paralleli**, ognuno entra in una delle 3 cartelle e fa `fmt`, `init`, `validate` in totale isolamento. Questo è un modo elegante per gestire l'architettura a micro-state (ogni layer è indipendente) senza raddoppiare i tempi della CI.

## 4. OIDC e Zero-Trust Security
I video spesso saltano questo punto perché mostrano come testare in locale (passando le chiavi segrete via terminale). Nella nostra CI, usiamo:
```yaml
uses: azure/login@v2
```
Insieme alle variabili `ARM_USE_OIDC: true`. Questo permette a GitHub di dialogare con Entra ID senza usare password statiche a rischio di compromissione, ma con dei token crittografici a durata di 1 ora generati sul momento!

## Conclusione
La pipeline CI che abbiamo non fa deploy (quello lo fa la CD `deploy-layer1.yml`). La sua unica funzione è costruire una "rete di sicurezza", testando il codice in modo isolato tramite `fmt`, `init` (spogliato dal backend) e `validate`, garantendo che solo codice verificato grammaticalmente veda mai i server Azure.
