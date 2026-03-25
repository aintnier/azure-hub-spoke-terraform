# Layer 3 — Hub-and-Spoke via Azure Virtual WAN (vWAN)

> **Status:** 🔲 Not started

## Session Log

_Document each deploy/test/destroy session below. Include timestamps, commands, screenshots, and observations._

---

### Session N — YYYY-MM-DD

**Deployed at:** HH:MM UTC  
**Destroyed at:** HH:MM UTC  
**Estimated cost:** €X.XX

#### 1. Deploy

```bash
cd layer3-vwan
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

#### 2. Connectivity Tests

| Test | Command | Expected | Actual | Result |
|------|---------|----------|--------|--------|
| Ping Spoke1 → Spoke2 | `ping <spoke2_vm_ip>` | Reply via Secured Hub | | ⬜ |
| Routing Intent active | Check vWAN Hub routing | Private traffic via FW | | ⬜ |

#### 3. vWAN Verification

- Verify vWAN Hub provisioning state
- Verify VNet Connections to spokes
- Verify Routing Intent configuration
- Verify Azure Firewall Manager integration

#### 4. Screenshots

_Add screenshots here._

#### 5. Destroy

```bash
terraform destroy -auto-approve
```

#### 6. Observations & Lessons Learned

- _Document insights here._
