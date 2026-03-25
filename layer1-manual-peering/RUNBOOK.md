# Layer 1 — Hub-and-Spoke via Manual VNet Peering

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
cd layer1-manual-peering
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

<details>
<summary>terraform apply output</summary>

```
# Paste terraform apply output here
```

</details>

#### 2. Connectivity Tests

| Test | Command | Expected | Actual | Result |
|------|---------|----------|--------|--------|
| Ping Spoke1 → Spoke2 | `ping <spoke2_vm_ip>` | Reply via Firewall | | ⬜ |
| Ping Spoke2 → Spoke1 | `ping <spoke1_vm_ip>` | Reply via Firewall | | ⬜ |
| SSH Spoke1 → Spoke2 | `ssh azureadmin@<spoke2_vm_ip>` | Session opened | | ⬜ |
| Ping Spoke1 → Internet | `ping 8.8.8.8` | Blocked by Firewall | | ⬜ |

#### 3. Firewall Log Verification

```kql
// Paste KQL query used to verify Firewall logs in Log Analytics
AzureDiagnostics
| where Category == "AzureFirewallNetworkRule"
| project TimeGenerated, msg_s
| order by TimeGenerated desc
| take 20
```

<details>
<summary>Query results</summary>

```
# Paste query results or screenshot here
```

</details>

#### 4. Routing Verification

```bash
# Verify effective routes on Spoke1 VM NIC
az network nic show-effective-route-table \
  --resource-group rg-layer1-manual-peering-dev \
  --name nic-vm-spoke1-dev \
  --output table
```

#### 5. Screenshots

_Add screenshots of Azure Portal, connectivity tests, firewall logs here._

#### 6. Destroy

```bash
terraform destroy -auto-approve
```

#### 7. Observations & Lessons Learned

- _Document any issues encountered, workarounds, or insights._
