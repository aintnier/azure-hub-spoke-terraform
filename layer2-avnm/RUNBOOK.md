# Layer 2 — Hub-and-Spoke via Azure Virtual Network Manager (AVNM)

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
cd layer2-avnm
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

#### 2. Connectivity Tests

| Test | Command | Expected | Actual | Result |
|------|---------|----------|--------|--------|
| Ping Spoke1 → Spoke2 | `ping <spoke2_vm_ip>` | Reply via Firewall | | ⬜ |
| AVNM auto-membership | Check Network Group | Spokes auto-added by tag | | ⬜ |

#### 3. AVNM Verification

- Verify Network Group membership (dynamic tag-based)
- Verify Connectivity Configuration deployment status
- Verify effective peering created by AVNM

#### 4. Screenshots

_Add screenshots here._

#### 5. Destroy

```bash
terraform destroy -auto-approve
```

#### 6. Observations & Lessons Learned

- _Document insights here._
