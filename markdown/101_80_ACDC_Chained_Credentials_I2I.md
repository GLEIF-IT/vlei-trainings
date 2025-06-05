# ACDC Issuance with KLI: Issuer-To-Issuee

<div class="alert alert-primary">
<b>🎯 OBJECTIVE</b><hr>
Demonstrate how to issue chained Authentic Chained Data Containers (ACDCs) using an Issuer-To-Issuee (<code>I2I</code>) edge relationship with the KERI Command Line Interface (KLI). It also illustrates how to embed a simple rule within an ACDC. We will implement the "Endorsement for Building Access" scenario.
</div>

## Scenario Recap: Endorsement for Building Access

This notebook focuses on the practical KLI commands for implementing an `I2I` chained credential scenario. For a detailed theoretical explanation of ACDC Edges, Edge Operators, and Rules, please refer to the "Advanced ACDC Features: Edges, Edge Operators, and Rules" notebook. To summarize: 

- **ACME Corp** issues a "Role Credential" to an Employee.
- The **Employee**, by virtue of their "Role Credential", issues an "Access Credential" to a **Sub-contractor**.
- The **Access Credential** contains an `I2I` edge linking back to the Employee's "Role Credential", signifying that the Employee's authority to grant access is derived from their managerial role.
- The **Access Credential** will also include a simple textual rule regarding its usage policy.


## Initial Setup: Keystores, AIDs, Registries, and OOBIs
As usual, it is necessary to set up our participants:

- Acme Corporation (`acme_aid`): The initial authority in this scenario, responsible for issuing the Role Credential.
- Employee (`employee_aid`): This participant will first receive the Role Credential from Acme and subsequently issue the Access Credential.
- Sub-contractor (`subcontractor_aid`): The recipient of the Access Credential.

For each participant:
- Initialize their respective keystores.
- Incept their Autonomic Identifiers (AIDs). These AIDs will be configured as transferable and will utilize the default witness setup from `keystore_init_config.json`.
- Establish OOBI connections. This involves generating OOBIs for each AID and resolving them to ensure all necessary participants (Acme-Employee, Employee-Sub-contractor) can securely discover each other.

For ACME and the Employee:
- Incept a credential registry


```python
# Imports and Utility functions
from scripts.utils import exec, clear_keri, pr_title, pr_message, pr_continue
from scripts.saidify import get_schema_said
import json, os

clear_keri()

# ACME Keystore and AID
acme_keystore_name = "acme_ks"
acme_salt = exec("kli salt")
acme_aid_alias = "acme"
acme_registry_name = "acme_mgr_registry"

# Employee Keystore and AID
employee_keystore_name = "employee_ks"
employee_salt = exec("kli salt")
employee_aid_alias = "employee"
employee_registry_name = "employee_access_registry"

# Sub-contractor Keystore and AID
subcontractor_keystore_name = "subcontractor_ks"
subcontractor_salt = exec("kli salt")
subcontractor_aid_alias = "subcontractor"

pr_title("Initializing keystores")

!kli init --name {acme_keystore_name} \
    --nopasscode \
    --salt {acme_salt} \
    --config-dir ./config \
    --config-file keystore_init_config.json

!kli init --name {employee_keystore_name} \
    --nopasscode \
    --salt {employee_salt} \
    --config-dir ./config \
    --config-file keystore_init_config.json

!kli init --name {subcontractor_keystore_name} \
    --nopasscode \
    --salt {subcontractor_salt} \
    --config-dir ./config \
    --config-file keystore_init_config.json

pr_title("Initializing AIDs")

!kli incept --name {acme_keystore_name} \
    --alias {acme_aid_alias} \
    --file ./config/aid_inception_config.json # Uses witnesses and transferable settings

!kli incept --name {employee_keystore_name} \
    --alias {employee_aid_alias} \
    --file ./config/aid_inception_config.json

!kli incept --name {subcontractor_keystore_name} \
    --alias {subcontractor_aid_alias} \
    --file ./config/aid_inception_config.json

pr_title("Initializing Credential Registries")

!kli vc registry incept --name {acme_keystore_name} \
    --alias {acme_aid_alias} \
    --registry-name {acme_registry_name}

!kli vc registry incept --name {employee_keystore_name} \
    --alias {employee_aid_alias} \
    --registry-name {employee_registry_name}


acme_aid_prefix = exec(f"kli aid --name {acme_keystore_name} --alias {acme_aid_alias}")
employee_aid_prefix = exec(f"kli aid --name {employee_keystore_name}  --alias {employee_aid_alias}")
subcontractor_aid_prefix = exec(f"kli aid --name {subcontractor_keystore_name}  --alias {subcontractor_aid_alias}")

pr_message(f"ACME AID: {acme_aid_prefix}")
pr_message(f"Employee AID: {employee_aid_prefix}")
pr_message(f"Sub-contractor AID: {subcontractor_aid_prefix}")

pr_title("Generating and resolving OOBIs")

# ACME and Employee OOBI Exchange
acme_oobi = exec(f"kli oobi generate --name {acme_keystore_name} --alias {acme_aid_alias} --role witness")
employee_oobi = exec(f"kli oobi generate --name {employee_keystore_name} --alias {employee_aid_alias} --role witness")

!kli oobi resolve --name {acme_keystore_name} \
    --oobi-alias {employee_aid_alias} \
    --oobi {employee_oobi}

!kli oobi resolve --name {employee_keystore_name} \
    --oobi-alias {acme_aid_alias} \
    --oobi {acme_oobi}

# Employee and Sub-contractor OOBI Exchange
subcontractor_oobi = exec(f"kli oobi generate --name {subcontractor_keystore_name}  --alias {subcontractor_aid_alias} --role witness")

!kli oobi resolve --name {employee_keystore_name} \
    --oobi-alias {subcontractor_aid_alias} \
    --oobi {subcontractor_oobi}

!kli oobi resolve --name {subcontractor_keystore_name} \
    --oobi-alias {employee_aid_alias} \
    --oobi {employee_oobi}

pr_message("OOBI connections established.")

pr_continue()
```

    Proceeding with deletion of '/usr/local/var/keri/' without confirmation.
    ✅ Successfully removed: /usr/local/var/keri/


    
    [1m[4m[44m[90m  Initializing keystores  [0m
    


    KERI Keystore created at: /usr/local/var/keri/ks/acme_ks
    KERI Database created at: /usr/local/var/keri/db/acme_ks
    KERI Credential Store created at: /usr/local/var/keri/reg/acme_ks
    
    Loading 3 OOBIs...


    http://witness-demo:5642/oobi/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha/controller?name=Wan&tag=witness succeeded
    http://witness-demo:5643/oobi/BLskRTInXnMxWaGqcpSyMgo0nYbalW99cGZESrz3zapM/controller?name=Wes&tag=witness succeeded
    http://witness-demo:5644/oobi/BIKKuvBwpmDVA4Ds-EpL5bt9OqPzWPja2LigFYZN2YfX/controller?name=Wil&tag=witness succeeded


    KERI Keystore created at: /usr/local/var/keri/ks/employee_ks
    KERI Database created at: /usr/local/var/keri/db/employee_ks
    KERI Credential Store created at: /usr/local/var/keri/reg/employee_ks
    
    Loading 3 OOBIs...


    http://witness-demo:5642/oobi/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha/controller?name=Wan&tag=witness succeeded
    http://witness-demo:5643/oobi/BLskRTInXnMxWaGqcpSyMgo0nYbalW99cGZESrz3zapM/controller?name=Wes&tag=witness succeeded
    http://witness-demo:5644/oobi/BIKKuvBwpmDVA4Ds-EpL5bt9OqPzWPja2LigFYZN2YfX/controller?name=Wil&tag=witness succeeded


    KERI Keystore created at: /usr/local/var/keri/ks/subcontractor_ks
    KERI Database created at: /usr/local/var/keri/db/subcontractor_ks
    KERI Credential Store created at: /usr/local/var/keri/reg/subcontractor_ks
    
    Loading 3 OOBIs...


    http://witness-demo:5642/oobi/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha/controller?name=Wan&tag=witness succeeded
    http://witness-demo:5643/oobi/BLskRTInXnMxWaGqcpSyMgo0nYbalW99cGZESrz3zapM/controller?name=Wes&tag=witness succeeded
    http://witness-demo:5644/oobi/BIKKuvBwpmDVA4Ds-EpL5bt9OqPzWPja2LigFYZN2YfX/controller?name=Wil&tag=witness succeeded


    
    [1m[4m[44m[90m  Initializing AIDs  [0m
    


    Waiting for witness receipts...


    Prefix  EGlbqwf3Ga4BvF6VXKlf40PHPKDE9O9Sh2DLYLrq_G8H
    	Public key 1:  DMAGtf7bbvSjdrfQ2FFbCCKtB6wR7s--B-w7l-RMtMaG
    


    Waiting for witness receipts...


    Prefix  EKZJBOcl723F-JnNz8uZNlqhANgto4_0UxLWMSoFO9ly
    	Public key 1:  DEjaa5ldc04HQNiiWuh2uj2Q5c1EHIq9zMkGocHvoYOG
    


    Waiting for witness receipts...


    Prefix  EGdluYSncX2IGrXQltbI20VZzX-4ZHim-otOImaP1Sk_
    	Public key 1:  DGEpYCWM5l-WrmgtdCc_cghizJpHSCCO7rmGsYq-_EA4
    


    
    [1m[4m[44m[90m  Initializing Credential Registries  [0m
    


    Waiting for TEL event witness receipts


    Sending TEL events to witnesses


    Registry:  acme_mgr_registry(EPCdfo7GCMux8P8lrHAjbz-mtNzOj5I9IRX2CIj44K0W) 
    	created for Identifier Prefix:  EGlbqwf3Ga4BvF6VXKlf40PHPKDE9O9Sh2DLYLrq_G8H


    Waiting for TEL event witness receipts


    Sending TEL events to witnesses


    Registry:  employee_access_registry(ECoFStsBpu1oDnXxFsZEcQgTb9o851V7gy7-VEeTMr5_) 
    	created for Identifier Prefix:  EKZJBOcl723F-JnNz8uZNlqhANgto4_0UxLWMSoFO9ly


    
    [1m[94mACME AID: EGlbqwf3Ga4BvF6VXKlf40PHPKDE9O9Sh2DLYLrq_G8H[0m
    
    
    [1m[94mEmployee AID: EKZJBOcl723F-JnNz8uZNlqhANgto4_0UxLWMSoFO9ly[0m
    
    
    [1m[94mSub-contractor AID: EGdluYSncX2IGrXQltbI20VZzX-4ZHim-otOImaP1Sk_[0m
    
    
    [1m[4m[44m[90m  Generating and resolving OOBIs  [0m
    


    http://witness-demo:5642/oobi/EKZJBOcl723F-JnNz8uZNlqhANgto4_0UxLWMSoFO9ly/witness resolved


    http://witness-demo:5642/oobi/EGlbqwf3Ga4BvF6VXKlf40PHPKDE9O9Sh2DLYLrq_G8H/witness resolved


    http://witness-demo:5642/oobi/EGdluYSncX2IGrXQltbI20VZzX-4ZHim-otOImaP1Sk_/witness resolved


    http://witness-demo:5642/oobi/EKZJBOcl723F-JnNz8uZNlqhANgto4_0UxLWMSoFO9ly/witness resolved


    
    [1m[94mOOBI connections established.[0m
    
    
    [1m[42m[90m  You can continue ✅  [0m
    
    


## Schema Definitions

We need two ACDC schemas:
- Role Schema (`role_schema.json`): For the credential ACME issues to the Employee.
- Access Schema (`access_schema.json`): For the credential the Employee issues to the Sub-contractor. This schema will include definitions for an `e` (edges) section to specify the I2I link and an `r` (rules) section.

<div class="alert alert-info">
<b>ℹ️ NOTE</b><hr>
For this notebook,the schemas have been SAIDified and made available on a schema server. The SAIDification process was covered in the "SAIDifying ACDC Schemas" notebook.

### Role Schema

This schema defines the structure of the "Role Credential." It has a structure that is rather similar to the other schemas presented so far during the training:

- Filename: `role_schema.json` (content shown SAIDified)


```python
role_schema_path = "config/schemas/role_schema.json" 
pr_title(f"Schema: {role_schema_path}")

role_schema_said = get_schema_said(role_schema_path)
pr_message(f"Schema SAID: {role_schema_said}")

pr_message(f"Retieving Schema from Server:")
!curl -s http://vlei-server:7723/oobi/{role_schema_said} | jq

pr_continue()
```

    
    [1m[4m[44m[90m  Schema: config/schemas/role_schema.json  [0m
    
    
    [1m[94mSchema SAID: ENWatfUaeryBqvGnG7VdILVcqk84_eoxmiaJYguJXaRw[0m
    
    
    [1m[94mRetieving Schema from Server:[0m
    
    [1;39m{
      [0m[34;1m"$id"[0m[1;39m: [0m[0;32m"ENWatfUaeryBqvGnG7VdILVcqk84_eoxmiaJYguJXaRw"[0m[1;39m,
      [0m[34;1m"$schema"[0m[1;39m: [0m[0;32m"http://json-schema.org/draft-07/schema#"[0m[1;39m,
      [0m[34;1m"title"[0m[1;39m: [0m[0;32m"RoleCredential"[0m[1;39m,
      [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Credential signifying a role within an organization."[0m[1;39m,
      [0m[34;1m"type"[0m[1;39m: [0m[0;32m"object"[0m[1;39m,
      [0m[34;1m"credentialType"[0m[1;39m: [0m[0;32m"RoleCredential"[0m[1;39m,
      [0m[34;1m"version"[0m[1;39m: [0m[0;32m"1.0.0"[0m[1;39m,
      [0m[34;1m"properties"[0m[1;39m: [0m[1;39m{
        [0m[34;1m"v"[0m[1;39m: [0m[1;39m{
          [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Credential Version String"[0m[1;39m,
          [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
        [1;39m}[0m[1;39m,
        [0m[34;1m"d"[0m[1;39m: [0m[1;39m{
          [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Credential SAID"[0m[1;39m,
          [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
        [1;39m}[0m[1;39m,
        [0m[34;1m"u"[0m[1;39m: [0m[1;39m{
          [0m[34;1m"description"[0m[1;39m: [0m[0;32m"One time use nonce"[0m[1;39m,
          [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
        [1;39m}[0m[1;39m,
        [0m[34;1m"i"[0m[1;39m: [0m[1;39m{
          [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Issuer AID"[0m[1;39m,
          [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
        [1;39m}[0m[1;39m,
        [0m[34;1m"ri"[0m[1;39m: [0m[1;39m{
          [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Registry SAID"[0m[1;39m,
          [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
        [1;39m}[0m[1;39m,
        [0m[34;1m"s"[0m[1;39m: [0m[1;39m{
          [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Schema SAID"[0m[1;39m,
          [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
        [1;39m}[0m[1;39m,
        [0m[34;1m"a"[0m[1;39m: [0m[1;39m{
          [0m[34;1m"oneOf"[0m[1;39m: [0m[1;39m[
            [1;39m{
              [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Attributes block SAID"[0m[1;39m,
              [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
            [1;39m}[0m[1;39m,
            [1;39m{
              [0m[34;1m"$id"[0m[1;39m: [0m[0;32m"EFmgKWjhXaH2MYUmlNy5-t8Y6SHZ0InHriOkyAnI4777"[0m[1;39m,
              [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Attributes block"[0m[1;39m,
              [0m[34;1m"type"[0m[1;39m: [0m[0;32m"object"[0m[1;39m,
              [0m[34;1m"properties"[0m[1;39m: [0m[1;39m{
                [0m[34;1m"d"[0m[1;39m: [0m[1;39m{
                  [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Attributes data SAID"[0m[1;39m,
                  [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
                [1;39m}[0m[1;39m,
                [0m[34;1m"i"[0m[1;39m: [0m[1;39m{
                  [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Issuee AID (Employee's AID)"[0m[1;39m,
                  [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
                [1;39m}[0m[1;39m,
                [0m[34;1m"dt"[0m[1;39m: [0m[1;39m{
                  [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Issuance date time"[0m[1;39m,
                  [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m,
                  [0m[34;1m"format"[0m[1;39m: [0m[0;32m"date-time"[0m[1;39m
                [1;39m}[0m[1;39m,
                [0m[34;1m"roleTitle"[0m[1;39m: [0m[1;39m{
                  [0m[34;1m"description"[0m[1;39m: [0m[0;32m"The title of the role."[0m[1;39m,
                  [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
                [1;39m}[0m[1;39m,
                [0m[34;1m"department"[0m[1;39m: [0m[1;39m{
                  [0m[34;1m"description"[0m[1;39m: [0m[0;32m"The department the employee belongs to."[0m[1;39m,
                  [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
                [1;39m}[0m[1;39m
              [1;39m}[0m[1;39m,
              [0m[34;1m"additionalProperties"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
              [0m[34;1m"required"[0m[1;39m: [0m[1;39m[
                [0;32m"d"[0m[1;39m,
                [0;32m"i"[0m[1;39m,
                [0;32m"dt"[0m[1;39m,
                [0;32m"roleTitle"[0m[1;39m,
                [0;32m"department"[0m[1;39m
              [1;39m][0m[1;39m
            [1;39m}[0m[1;39m
          [1;39m][0m[1;39m
        [1;39m}[0m[1;39m
      [1;39m}[0m[1;39m,
      [0m[34;1m"additionalProperties"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
      [0m[34;1m"required"[0m[1;39m: [0m[1;39m[
        [0;32m"v"[0m[1;39m,
        [0;32m"d"[0m[1;39m,
        [0;32m"i"[0m[1;39m,
        [0;32m"ri"[0m[1;39m,
        [0;32m"s"[0m[1;39m,
        [0;32m"a"[0m[1;39m
      [1;39m][0m[1;39m
    [1;39m}[0m


    
    [1m[42m[90m  You can continue ✅  [0m
    
    


### Access Schema
This schema defines the "Access Credential". It includes an `e` (edges) section for the `I2I` link to the Role Credential and an `r` (rules) section for a usage policy.

Filename: `access_schema.json` (content shown SAIDified)



```python
access_schema_path = "config/schemas/access_schema.json" 
pr_title(f"Schema: {access_schema_path}")

access_schema_said = get_schema_said(access_schema_path)
pr_message(f"Schema SAID: {access_schema_said}")

pr_message(f"Retieving Schema from Server:")
!curl -s http://vlei-server:7723/oobi/{access_schema_said} | jq

pr_continue()
```

    
    [1m[4m[44m[90m  Schema: config/schemas/access_schema.json  [0m
    
    
    [1m[94mSchema SAID: EF2zX3g5YDyHMSjgsK4OayZMFmLRMxcAJfW363JhBOfD[0m
    
    
    [1m[94mRetieving Schema from Server:[0m
    
    [1;39m{
      [0m[34;1m"$id"[0m[1;39m: [0m[0;32m"EF2zX3g5YDyHMSjgsK4OayZMFmLRMxcAJfW363JhBOfD"[0m[1;39m,
      [0m[34;1m"$schema"[0m[1;39m: [0m[0;32m"http://json-schema.org/draft-07/schema#"[0m[1;39m,
      [0m[34;1m"title"[0m[1;39m: [0m[0;32m"AccessCredential"[0m[1;39m,
      [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Credential granting access to a specific building or area, endorsed by a manager."[0m[1;39m,
      [0m[34;1m"type"[0m[1;39m: [0m[0;32m"object"[0m[1;39m,
      [0m[34;1m"credentialType"[0m[1;39m: [0m[0;32m"AccessCredential"[0m[1;39m,
      [0m[34;1m"version"[0m[1;39m: [0m[0;32m"1.0.0"[0m[1;39m,
      [0m[34;1m"properties"[0m[1;39m: [0m[1;39m{
        [0m[34;1m"v"[0m[1;39m: [0m[1;39m{
          [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Credential Version String"[0m[1;39m,
          [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
        [1;39m}[0m[1;39m,
        [0m[34;1m"d"[0m[1;39m: [0m[1;39m{
          [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Credential SAID"[0m[1;39m,
          [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
        [1;39m}[0m[1;39m,
        [0m[34;1m"u"[0m[1;39m: [0m[1;39m{
          [0m[34;1m"description"[0m[1;39m: [0m[0;32m"One time use nonce"[0m[1;39m,
          [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
        [1;39m}[0m[1;39m,
        [0m[34;1m"i"[0m[1;39m: [0m[1;39m{
          [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Issuer AID (Employee's AID)"[0m[1;39m,
          [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
        [1;39m}[0m[1;39m,
        [0m[34;1m"ri"[0m[1;39m: [0m[1;39m{
          [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Registry SAID"[0m[1;39m,
          [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
        [1;39m}[0m[1;39m,
        [0m[34;1m"s"[0m[1;39m: [0m[1;39m{
          [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Schema SAID"[0m[1;39m,
          [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
        [1;39m}[0m[1;39m,
        [0m[34;1m"a"[0m[1;39m: [0m[1;39m{
          [0m[34;1m"oneOf"[0m[1;39m: [0m[1;39m[
            [1;39m{
              [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Attributes block SAID"[0m[1;39m,
              [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
            [1;39m}[0m[1;39m,
            [1;39m{
              [0m[34;1m"$id"[0m[1;39m: [0m[0;32m"EOxa7LAD2BoA9tk9n0CW4zH7nF91DP1g_Pjz1wC_FuNw"[0m[1;39m,
              [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Attributes block"[0m[1;39m,
              [0m[34;1m"type"[0m[1;39m: [0m[0;32m"object"[0m[1;39m,
              [0m[34;1m"properties"[0m[1;39m: [0m[1;39m{
                [0m[34;1m"d"[0m[1;39m: [0m[1;39m{
                  [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Attributes data SAID"[0m[1;39m,
                  [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
                [1;39m}[0m[1;39m,
                [0m[34;1m"i"[0m[1;39m: [0m[1;39m{
                  [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Issuee AID (Sub-contractor's AID)"[0m[1;39m,
                  [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
                [1;39m}[0m[1;39m,
                [0m[34;1m"dt"[0m[1;39m: [0m[1;39m{
                  [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Issuance date time"[0m[1;39m,
                  [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m,
                  [0m[34;1m"format"[0m[1;39m: [0m[0;32m"date-time"[0m[1;39m
                [1;39m}[0m[1;39m,
                [0m[34;1m"buildingId"[0m[1;39m: [0m[1;39m{
                  [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Identifier for the building access is granted to."[0m[1;39m,
                  [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
                [1;39m}[0m[1;39m,
                [0m[34;1m"accessLevel"[0m[1;39m: [0m[1;39m{
                  [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Level of access granted."[0m[1;39m,
                  [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
                [1;39m}[0m[1;39m
              [1;39m}[0m[1;39m,
              [0m[34;1m"additionalProperties"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
              [0m[34;1m"required"[0m[1;39m: [0m[1;39m[
                [0;32m"d"[0m[1;39m,
                [0;32m"i"[0m[1;39m,
                [0;32m"dt"[0m[1;39m,
                [0;32m"buildingId"[0m[1;39m,
                [0;32m"accessLevel"[0m[1;39m
              [1;39m][0m[1;39m
            [1;39m}[0m[1;39m
          [1;39m][0m[1;39m
        [1;39m}[0m[1;39m,
        [0m[34;1m"e"[0m[1;39m: [0m[1;39m{
          [0m[34;1m"oneOf"[0m[1;39m: [0m[1;39m[
            [1;39m{
              [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Edges block SAID"[0m[1;39m,
              [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
            [1;39m}[0m[1;39m,
            [1;39m{
              [0m[34;1m"$id"[0m[1;39m: [0m[0;32m"EI8RvTM23u-pQDK-KpDUBWOKbiOW8fpnzktVVBCLy55N"[0m[1;39m,
              [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Edges block"[0m[1;39m,
              [0m[34;1m"type"[0m[1;39m: [0m[0;32m"object"[0m[1;39m,
              [0m[34;1m"properties"[0m[1;39m: [0m[1;39m{
                [0m[34;1m"d"[0m[1;39m: [0m[1;39m{
                  [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Edges block SAID"[0m[1;39m,
                  [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
                [1;39m}[0m[1;39m,
                [0m[34;1m"manager_endorsement"[0m[1;39m: [0m[1;39m{
                  [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Link to the Manager Credential that endorses this access"[0m[1;39m,
                  [0m[34;1m"type"[0m[1;39m: [0m[0;32m"object"[0m[1;39m,
                  [0m[34;1m"properties"[0m[1;39m: [0m[1;39m{
                    [0m[34;1m"n"[0m[1;39m: [0m[1;39m{
                      [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Issuer credential SAID"[0m[1;39m,
                      [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
                    [1;39m}[0m[1;39m,
                    [0m[34;1m"s"[0m[1;39m: [0m[1;39m{
                      [0m[34;1m"description"[0m[1;39m: [0m[0;32m"SAID of required schema of the credential pointed to by this node"[0m[1;39m,
                      [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m,
                      [0m[34;1m"const"[0m[1;39m: [0m[0;32m"ENWatfUaeryBqvGnG7VdILVcqk84_eoxmiaJYguJXaRw"[0m[1;39m
                    [1;39m}[0m[1;39m,
                    [0m[34;1m"o"[0m[1;39m: [0m[1;39m{
                      [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Operator indicating this node is the issuer"[0m[1;39m,
                      [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m,
                      [0m[34;1m"const"[0m[1;39m: [0m[0;32m"I2I"[0m[1;39m
                    [1;39m}[0m[1;39m
                  [1;39m}[0m[1;39m,
                  [0m[34;1m"additionalProperties"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
                  [0m[34;1m"required"[0m[1;39m: [0m[1;39m[
                    [0;32m"n"[0m[1;39m,
                    [0;32m"s"[0m[1;39m,
                    [0;32m"o"[0m[1;39m
                  [1;39m][0m[1;39m
                [1;39m}[0m[1;39m
              [1;39m}[0m[1;39m,
              [0m[34;1m"additionalProperties"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
              [0m[34;1m"required"[0m[1;39m: [0m[1;39m[
                [0;32m"d"[0m[1;39m,
                [0;32m"manager_endorsement"[0m[1;39m
              [1;39m][0m[1;39m
            [1;39m}[0m[1;39m
          [1;39m][0m[1;39m
        [1;39m}[0m[1;39m,
        [0m[34;1m"r"[0m[1;39m: [0m[1;39m{
          [0m[34;1m"oneOf"[0m[1;39m: [0m[1;39m[
            [1;39m{
              [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Rules block SAID"[0m[1;39m,
              [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
            [1;39m}[0m[1;39m,
            [1;39m{
              [0m[34;1m"$id"[0m[1;39m: [0m[0;32m"EKDmqq14KgthMAV23sCbzgdFFjT-v9x01toUsyfyi2uU"[0m[1;39m,
              [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Rules governing the use of this access credential."[0m[1;39m,
              [0m[34;1m"type"[0m[1;39m: [0m[0;32m"object"[0m[1;39m,
              [0m[34;1m"properties"[0m[1;39m: [0m[1;39m{
                [0m[34;1m"d"[0m[1;39m: [0m[1;39m{
                  [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Rules block SAID"[0m[1;39m,
                  [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m
                [1;39m}[0m[1;39m,
                [0m[34;1m"usageDisclaimer"[0m[1;39m: [0m[1;39m{
                  [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Usage Disclaimer"[0m[1;39m,
                  [0m[34;1m"type"[0m[1;39m: [0m[0;32m"object"[0m[1;39m,
                  [0m[34;1m"properties"[0m[1;39m: [0m[1;39m{
                    [0m[34;1m"l"[0m[1;39m: [0m[1;39m{
                      [0m[34;1m"description"[0m[1;39m: [0m[0;32m"Associated legal language"[0m[1;39m,
                      [0m[34;1m"type"[0m[1;39m: [0m[0;32m"string"[0m[1;39m,
                      [0m[34;1m"const"[0m[1;39m: [0m[0;32m"This mock credential grants no actual access. For illustrative use only."[0m[1;39m
                    [1;39m}[0m[1;39m
                  [1;39m}[0m[1;39m
                [1;39m}[0m[1;39m
              [1;39m}[0m[1;39m,
              [0m[34;1m"additionalProperties"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
              [0m[34;1m"required"[0m[1;39m: [0m[1;39m[
                [0;32m"d"[0m[1;39m,
                [0;32m"usageDisclaimer"[0m[1;39m
              [1;39m][0m[1;39m
            [1;39m}[0m[1;39m
          [1;39m][0m[1;39m
        [1;39m}[0m[1;39m
      [1;39m}[0m[1;39m,
      [0m[34;1m"additionalProperties"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
      [0m[34;1m"required"[0m[1;39m: [0m[1;39m[
        [0;32m"v"[0m[1;39m,
        [0;32m"d"[0m[1;39m,
        [0;32m"i"[0m[1;39m,
        [0;32m"ri"[0m[1;39m,
        [0;32m"s"[0m[1;39m,
        [0;32m"a"[0m[1;39m,
        [0;32m"e"[0m[1;39m,
        [0;32m"r"[0m[1;39m
      [1;39m][0m[1;39m
    [1;39m}[0m


    
    [1m[42m[90m  You can continue ✅  [0m
    
    


## Resolving Schema OOBIs
All parties need to resolve the OOBIs for these schemas from the schema server.


```python
pr_title("Resolving schema OOBIs")

role_schema_oobi = f"http://vlei-server:7723/oobi/{role_schema_said}"
access_schema_oobi = f"http://vlei-server:7723/oobi/{access_schema_said}"

# ACME Corp
!kli oobi resolve --name {acme_keystore_name} \
    --oobi-alias "role_schema" \
    --oobi {role_schema_oobi}

!kli oobi resolve --name {acme_keystore_name} \
    --oobi-alias "access_schema" \
    --oobi {access_schema_oobi}

# Employee
!kli oobi resolve --name {employee_keystore_name} \
    --oobi-alias "role_schema" --oobi {role_schema_oobi}

!kli oobi resolve --name {employee_keystore_name} \
    --oobi-alias "access_schema" \
    --oobi {access_schema_oobi}

# Sub-contractor
!kli oobi resolve --name {subcontractor_keystore_name} \
    --oobi-alias "role_schema" \
    --oobi {role_schema_oobi}

!kli oobi resolve --name {subcontractor_keystore_name} \
    --oobi-alias "access_schema" \
    --oobi {access_schema_oobi}

pr_message("Schema OOBIs resolved.")
pr_continue()
```

    
    [1m[4m[44m[90m  Resolving schema OOBIs  [0m
    


    http://vlei-server:7723/oobi/ENWatfUaeryBqvGnG7VdILVcqk84_eoxmiaJYguJXaRw resolved


    http://vlei-server:7723/oobi/EF2zX3g5YDyHMSjgsK4OayZMFmLRMxcAJfW363JhBOfD resolved


    http://vlei-server:7723/oobi/ENWatfUaeryBqvGnG7VdILVcqk84_eoxmiaJYguJXaRw resolved


    http://vlei-server:7723/oobi/EF2zX3g5YDyHMSjgsK4OayZMFmLRMxcAJfW363JhBOfD resolved


    http://vlei-server:7723/oobi/ENWatfUaeryBqvGnG7VdILVcqk84_eoxmiaJYguJXaRw resolved


    http://vlei-server:7723/oobi/EF2zX3g5YDyHMSjgsK4OayZMFmLRMxcAJfW363JhBOfD resolved


    
    [1m[94mSchema OOBIs resolved.[0m
    
    
    [1m[42m[90m  You can continue ✅  [0m
    
    


## Issuing credentials

Now that the setup is complete and the schemas are available, its necessary to create the credential chain. 


### Step 1: Role Credential Issuance

The Keystores, AIDs, and Credential Registry for ACME Corporation were created during the initial setup. The next step is to create the credential that grants the "Engineering Manager" role to the employee.

**ACME Creates Role Credential Data**

Create a JSON file `role_cred_data.json` with the attributes for this specific credential


```python
pr_title("Creating role credential data")

!echo '{ \
    "roleTitle": "Engineering Manager", \
    "department": "Technology Innovations" \
}' > config/credential_data/role_cred_data.json

!cat config/credential_data/role_cred_data.json | jq

pr_continue()
```

    
    [1m[4m[44m[90m  Creating role credential data  [0m
    


    [1;39m{
      [0m[34;1m"roleTitle"[0m[1;39m: [0m[0;32m"Engineering Manager"[0m[1;39m,
      [0m[34;1m"department"[0m[1;39m: [0m[0;32m"Technology Innovations"[0m[1;39m
    [1;39m}[0m


    
    [1m[42m[90m  You can continue ✅  [0m
    
    


**ACME Issues Role Credential to Employee**

Now that the credential data is in the file the next step is to create the credential with `!kli vc create`


```python
pr_title("Creating Role credential")

issue_time_acme = exec("kli time")
!kli vc create --name {acme_keystore_name} \
    --alias {acme_aid_alias} \
    --registry-name {acme_registry_name} \
    --schema {role_schema_said} \
    --recipient {employee_aid_prefix} \
    --data "@./config/credential_data/role_cred_data.json" \
    --time {issue_time_acme}

role_credential_said = exec(f"kli vc list --name {acme_keystore_name} --alias {acme_aid_alias} --issued --said --schema {role_schema_said}")
pr_message(f"Role Credential SAID: {role_credential_said}")

pr_continue()
```

    
    [1m[4m[44m[90m  Creating Role credential  [0m
    


    Waiting for TEL event witness receipts


    Sending TEL events to witnesses


    EEfT-xtk8IdQZsadomUzunO1U7zCUD0FTO1eEKfNTd4r has been created.


    
    [1m[94mRole Credential SAID: EEfT-xtk8IdQZsadomUzunO1U7zCUD0FTO1eEKfNTd4r[0m
    
    
    [1m[42m[90m  You can continue ✅  [0m
    
    


**IPEX Transfer: ACME Grants, Employee Admits Manager Credential**

Next, perform the IPEX transfer as done in previous ACDC issuance examples. Afterwards, the employee will have the role credential.


```python
pr_title("Transfering credential (ipex grant)")

time = exec("kli time")
!kli ipex grant --name {acme_keystore_name} \
    --alias {acme_aid_alias} \
    --said {role_credential_said} \
    --recipient {employee_aid_prefix} \
    --time {time}

pr_title("Admiting credential (ipex grant)")
# Employee polls for the grant and admits it
employee_grant_msg_said = exec(f"kli ipex list --name {employee_keystore_name} --alias {employee_aid_alias} --poll --said")
time = exec("kli time")
!kli ipex admit --name {employee_keystore_name} \
    --alias {employee_aid_alias} \
    --said {employee_grant_msg_said} \
    --time {time}

# Employee lists the received credential
pr_message("\nEmployee's received Manager Credential:")
!kli vc list --name {employee_keystore_name} \
    --alias {employee_aid_alias} \
    --verbose

pr_continue()
```

    
    [1m[4m[44m[90m  Transfering credential (ipex grant)  [0m
    


    Sending message EE1wNop_RImEpqJWcSbK_-CllXXC3QR1aq_OnP4925Th to EKZJBOcl723F-JnNz8uZNlqhANgto4_0UxLWMSoFO9ly


    ... grant message sent


    
    [1m[4m[44m[90m  Admiting credential (ipex grant)  [0m
    


    Sending admit message to EGlbqwf3Ga4BvF6VXKlf40PHPKDE9O9Sh2DLYLrq_G8H


    ... admit message sent


    
    [1m[94m
    Employee's received Manager Credential:[0m
    


    Current received credentials for employee (EKZJBOcl723F-JnNz8uZNlqhANgto4_0UxLWMSoFO9ly):
    
    Credential #1: EEfT-xtk8IdQZsadomUzunO1U7zCUD0FTO1eEKfNTd4r
        Type: RoleCredential
        Status: Issued [92m✔[0m
        Issued by EGlbqwf3Ga4BvF6VXKlf40PHPKDE9O9Sh2DLYLrq_G8H
        Issued on 2025-06-05T22:23:08.052322+00:00
        Full Credential:
    	{
    	  "v": "ACDC10JSON0001c2_",
    	  "d": "EEfT-xtk8IdQZsadomUzunO1U7zCUD0FTO1eEKfNTd4r",
    	  "i": "EGlbqwf3Ga4BvF6VXKlf40PHPKDE9O9Sh2DLYLrq_G8H",
    	  "ri": "EPCdfo7GCMux8P8lrHAjbz-mtNzOj5I9IRX2CIj44K0W",
    	  "s": "ENWatfUaeryBqvGnG7VdILVcqk84_eoxmiaJYguJXaRw",
    	  "a": {
    	    "d": "EPomGK9qOAiFFBCi8SZK7981gVA2zrBF_h3L0dFhP3lL",
    	    "i": "EKZJBOcl723F-JnNz8uZNlqhANgto4_0UxLWMSoFO9ly",
    	    "dt": "2025-06-05T22:23:08.052322+00:00",
    	    "roleTitle": "Engineering Manager",
    	    "department": "Technology Innovations"
    	  }
    	}


    
    [1m[42m[90m  You can continue ✅  [0m
    
    


### Step 2: Access Credential Data blocks

The Employee, now holding the "Role Credential", issues the "Access Credential" to the Sub-contractor. This new credential will link to the Manager Credential via an `I2I` edge and include a "Usage Disclaimer" rule. For this is necessary to create JSON files for the attributes (`access_cred_data.json`), the edge (`access_cred_edge.json`), and the rule (`access_cred_rule.json`). The attributes, edges, and rules blocks are displayed below.


#### Attributes Data

Generic mock data to represent an access claim.


```python
pr_message("Acces Credential Attributes")

access_cred_data_file_path = "config/credential_data/access_cred_data.json"

access_data = {
    "buildingId": "HQ-EastWing", 
    "accessLevel": "Level 2 - Common Areas & Labs" 
}

with open(access_cred_data_file_path, 'w') as f:
    json.dump(access_data, f, indent=4)

!cat {access_cred_data_file_path} | jq

```

    
    [1m[94mAcces Credential Attributes[0m
    
    [1;39m{
      [0m[34;1m"buildingId"[0m[1;39m: [0m[0;32m"HQ-EastWing"[0m[1;39m,
      [0m[34;1m"accessLevel"[0m[1;39m: [0m[0;32m"Level 2 - Common Areas & Labs"[0m[1;39m
    [1;39m}[0m


#### Edge Data and SAID Calculation

When creating the Edge Data, the `manager_endorsement` edge is defined to link to the SAID of the `role_credential_said` (the credential issued by ACME to the Employee). The schema SAID `s` for this edge points to `role_schema_said`, and the operator `o` is set to `I2I`.

To make this edge block verifiable, the `!kli saidify --file` command is used. When this command is executed, KERI processes the JSON content of the specified file and calculates a Self-Addressing Identifier (SAID) for its entire content. Crucially, the command then modifies the input file in place:
- It adds (or updates, if already present) a top-level field named `d` within the JSON structure of the file.
- The value of this `d` field is set to the newly calculated SAID.


```python
pr_message("Acces Credential Edges")

access_cred_edge_file_path = "config/credential_data/access_cred_edge.json"

access_edge = {
    "d": "",
    "manager_endorsement": {
        "n": role_credential_said,
        "s": role_schema_said,
        "o": "I2I"
    }
}

with open(access_cred_edge_file_path, 'w') as f:
    json.dump(access_edge, f, indent=4)

!kli saidify --file {access_cred_edge_file_path}

!cat {access_cred_edge_file_path} | jq

```

    
    [1m[94mAcces Credential Edges[0m
    


    [1;39m{
      [0m[34;1m"d"[0m[1;39m: [0m[0;32m"EDRQ1Kp1Bf2byY8r0ZU8AvSon-WdrO9-vOG7_3eIH0Or"[0m[1;39m,
      [0m[34;1m"manager_endorsement"[0m[1;39m: [0m[1;39m{
        [0m[34;1m"n"[0m[1;39m: [0m[0;32m"EEfT-xtk8IdQZsadomUzunO1U7zCUD0FTO1eEKfNTd4r"[0m[1;39m,
        [0m[34;1m"s"[0m[1;39m: [0m[0;32m"ENWatfUaeryBqvGnG7VdILVcqk84_eoxmiaJYguJXaRw"[0m[1;39m,
        [0m[34;1m"o"[0m[1;39m: [0m[0;32m"I2I"[0m[1;39m
      [1;39m}[0m[1;39m
    [1;39m}[0m


#### Rule Data

The rule section `usageDisclaimer` contains a simple legal disclaimer. Take notice that this data block is also SAIDified.


```python
pr_message("Acces Credential Rules")

access_cred_rule_file_path = "config/credential_data/access_cred_rule.json"

access_rule = {
  "d": "",
  "usageDisclaimer": {
    "l": "This mock credential grants no actual access. For illustrative use only."
  }
}

with open(access_cred_rule_file_path, 'w') as f:
    json.dump(access_rule, f, indent=4)

!kli saidify --file {access_cred_rule_file_path}

!cat {access_cred_rule_file_path} | jq

```

    
    [1m[94mAcces Credential Rules[0m
    


    [1;39m{
      [0m[34;1m"d"[0m[1;39m: [0m[0;32m"EGVMk928-Fz4DK2NSvZgtG0JJrMlrpxvuxBKPvFxfPSQ"[0m[1;39m,
      [0m[34;1m"usageDisclaimer"[0m[1;39m: [0m[1;39m{
        [0m[34;1m"l"[0m[1;39m: [0m[0;32m"This mock credential grants no actual access. For illustrative use only."[0m[1;39m
      [1;39m}[0m[1;39m
    [1;39m}[0m


### Step3: Employee Creates Access Credential for Sub-contractor

Now, the Employee uses `kli vc create` with the attributes, SAIDified edges, and SAIDified rules files to issue the Access Credential. Notice the additional parameters `--edges` and `rules` to supply the data blocks to the command.


```python
time = exec("kli time")
!kli vc create --name {employee_keystore_name} \
    --alias {employee_aid_alias} \
    --registry-name {employee_registry_name} \
    --schema {access_schema_said} \
    --recipient {subcontractor_aid_alias} \
    --data  "@./config/credential_data/access_cred_data.json" \
    --edges "@./config/credential_data/access_cred_edge.json" \
    --rules "@./config/credential_data/access_cred_rule.json" \
    --time {time}

access_credential_said = exec(f"kli vc list --name {employee_keystore_name} --alias {employee_aid_alias} --issued --said --schema {access_schema_said}")
pr_message(f"Access Credential SAID: {access_credential_said}")

pr_continue()

```

    Waiting for TEL event witness receipts


    Sending TEL events to witnesses


    EKUsRCZXkEXFy3mXESZAsJ8WOoP6eiOYgJU8GlCnBEV9 has been created.


    
    [1m[94mAccess Credential SAID: EKUsRCZXkEXFy3mXESZAsJ8WOoP6eiOYgJU8GlCnBEV9[0m
    
    
    [1m[42m[90m  You can continue ✅  [0m
    
    


### Step 4: Employee Grants, Sub-contractor Admits Access Credential


```python
pr_title("Transfering Access Credential from Employee to Sub-contractor")

time = exec("kli time")
!kli ipex grant --name {employee_keystore_name} \
    --alias {employee_aid_alias} \
    --said {access_credential_said} \
    --recipient {subcontractor_aid_prefix} \
    --time {time}

pr_title("Sub-contractor admitting Access Credential")
# Sub-contractor polls for the grant and admits it
subcontractor_grant_msg_said = exec(f"kli ipex list --name {subcontractor_keystore_name} --alias {subcontractor_aid_alias} --poll --said")
time = exec("kli time")
!kli ipex admit --name {subcontractor_keystore_name} \
    --alias {subcontractor_aid_alias} \
    --said {subcontractor_grant_msg_said} \
    --time {time}

# Sub-contractor lists the received credential
pr_message("\nSub-contractor's received Access Credential:")
!kli vc list --name {subcontractor_keystore_name} \
    --alias {subcontractor_aid_alias} \
    --verbose

pr_continue()
```

    
    [1m[4m[44m[90m  Transfering Access Credential from Employee to Sub-contractor  [0m
    


    Sending message EOQnVV8GLD6isYgqHjaA9ohuSUCDujgMgaPlvCxHIJb3 to EGdluYSncX2IGrXQltbI20VZzX-4ZHim-otOImaP1Sk_


    ... grant message sent


    
    [1m[4m[44m[90m  Sub-contractor admitting Access Credential  [0m
    


    Sending admit message to EKZJBOcl723F-JnNz8uZNlqhANgto4_0UxLWMSoFO9ly


    ... admit message sent


    
    [1m[94m
    Sub-contractor's received Access Credential:[0m
    


    Current received credentials for subcontractor (EGdluYSncX2IGrXQltbI20VZzX-4ZHim-otOImaP1Sk_):
    
    Credential #1: EKUsRCZXkEXFy3mXESZAsJ8WOoP6eiOYgJU8GlCnBEV9
        Type: AccessCredential
        Status: Issued [92m✔[0m
        Issued by EKZJBOcl723F-JnNz8uZNlqhANgto4_0UxLWMSoFO9ly
        Issued on 2025-06-05T22:23:24.095891+00:00
        Full Credential:
    	{
    	  "v": "ACDC10JSON000320_",
    	  "d": "EKUsRCZXkEXFy3mXESZAsJ8WOoP6eiOYgJU8GlCnBEV9",
    	  "i": "EKZJBOcl723F-JnNz8uZNlqhANgto4_0UxLWMSoFO9ly",
    	  "ri": "ECoFStsBpu1oDnXxFsZEcQgTb9o851V7gy7-VEeTMr5_",
    	  "s": "EF2zX3g5YDyHMSjgsK4OayZMFmLRMxcAJfW363JhBOfD",
    	  "a": {
    	    "d": "EFlWyQZhutX7a8p8xC-0QEmvWzSj7vOEpqgU1ePjVK5v",
    	    "i": "EGdluYSncX2IGrXQltbI20VZzX-4ZHim-otOImaP1Sk_",
    	    "dt": "2025-06-05T22:23:24.095891+00:00",
    	    "buildingId": "HQ-EastWing",
    	    "accessLevel": "Level 2 - Common Areas & Labs"
    	  },
    	  "e": {
    	    "d": "EDRQ1Kp1Bf2byY8r0ZU8AvSon-WdrO9-vOG7_3eIH0Or",
    	    "manager_endorsement": {
    	      "n": "EEfT-xtk8IdQZsadomUzunO1U7zCUD0FTO1eEKfNTd4r",
    	      "s": "ENWatfUaeryBqvGnG7VdILVcqk84_eoxmiaJYguJXaRw",
    	      "o": "I2I"
    	    }
    	  },
    	  "r": {
    	    "d": "EGVMk928-Fz4DK2NSvZgtG0JJrMlrpxvuxBKPvFxfPSQ",
    	    "usageDisclaimer": {
    	      "l": "This mock credential grants no actual access. For illustrative use only."
    	    }
    	  }
    	}


    
    [1m[42m[90m  You can continue ✅  [0m
    


    


The output for the Sub-contractor's received AccessCredential clearly shows:
- The attributes (`a` section) for building access.
- The edge (`e` section) with manager_endorsement linking to the RoleCredential's SAID (`n`) and using the `I2I` operator (`o`).
- The rule (`r` section) with the `usageDisclaimer`.

<div class="alert alert-primary">
<b>📝 SUMMARY</b><hr>
This notebook demonstrated the creation of a chained ACDC relationship using an Issuer-To-Issuee (I2I) edge and the inclusion of a rule:
<ol>
<li><b>Initial Setup:</b> Keystores, AIDs (ACME, Employee, Sub-contractor), and credential registries (for ACME and Employee) were initialized. OOBI connections were established between relevant parties.</li>
<li><b>Schema Preparation:</b> Two schemas, role_schema.json (for ACME to Employee) and access_schema.json (for Employee to Sub-contractor), were defined. The access_schema.json included definitions for an e (edges) section and an r (rules) section. Both schemas were assumed to be SAIDified and resolvable via a schema server.</li>
<li><b>Role Credential Issuance (ACME to Employee):</b>
<ul>
<li>ACME created data for the Role Credential.</li>
<li>ACME issued the Role Credential to the Employee's AID using <code>kli vc create</code>.</li>
<li>The Role Credential was transferred to the Employee via IPEX (<code>kli ipex grant</code> from ACME, <code>kli ipex admit</code> by Employee).</li>
</ul>
</li>
<li><b>Access Credential Issuance (Employee to Sub-contractor):</b>
<ul>
<li>The Employee created data for the Access Credential attributes.</li>
<li>A separate JSON file for the <b>edge</b> was created. This edge (<code>manager_endorsement</code>) pointed to the SAID of the Role Credential received by the Employee (<code>role_credential_said</code>), specified the Role Credential's schema SAID, and used the <code>"o": "I2I"</code> operator. This edge file was SAIDified using <code>kli saidify --file</code>, which populates its <code>d</code> field.</li>
<li>A separate JSON file for the <b>rule</b> (<code>usageDisclaimer</code>) was created and SAIDified using <code>kli saidify --file</code>.</li>
<li>The Employee issued the Access Credential to the Sub-contractor's AID using <code>kli vc create</code>, referencing the attributes data file, the SAIDified edge file (<code>--edges</code>), and the SAIDified rule file (<code>--rules</code>).</li>
<li>The Access Credential was transferred to the Sub-contractor via IPEX.</li>
</ul>
</li>
<li><b>Verification:</b> The Sub-contractor's received Access Credential clearly displayed the attributes, the I2I edge linking to the Employee's Role Credential, and the embedded rule.</li>
</ol>
This process illustrates how KERI and ACDC can model real-world endorsement scenarios where the authority to issue a credential is derived from another, verifiable credential held by the issuer, and how additional conditions can be embedded using rules.
</div>
