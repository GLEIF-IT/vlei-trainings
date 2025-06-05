# ACDC Presentation and Revocation with KLI: Using the IPEX Protocol

<div class="alert alert-primary">
<b>🎯 OBJECTIVE</b><hr>
Demonstrate how a Holder presents a previously issued ACDC or Verifiable Credential (VC) to a Verifier using the Issuance and Presentation Exchange (IPEX) protocol. And also covers the process of credential revocation by the Issuer.
</div>

## Credential Presentation Overview

In the previous notebook, you saw how an Issuer creates and sends an ACDC to a Holder. Now, we'll focus on the next step in the typical verifiable credential lifecycle: presentation. The Holder, possessing the credential, needs to present it to another party (the Verifier) to prove certain claims or gain access to something. You will again use the IPEX protocol for this exchange, but this time initiated by the Holder. Finally, you will see how the original Issuer can revoke the credential.

### Recap: Issuing the Prerequisite Credential

To present a credential, you first need one! The following code block is a condensed recap of the ACDC Issuance workflow covered in the previous notebook. It quickly sets up an Issuer and a Holder, creates a Credential Registry, defines and resolves a schema, issues an `EventPass` credential from the Issuer to the Holder using IPEX, and ensures the Holder admits it.

<div class="alert alert-info">
<b>ℹ️ NOTE:</b><hr> 
For a detailed explanation of these issuance steps, please refer to the previous notebook.
</div>


```python
from scripts.utils import exec
from scripts.saidify import process_schema_file, get_schema_said
from scripts.utils import pr_title, pr_message, pr_continue, clear_keri

clear_keri()

# Holder keystore init and AID inception

holder_keystore_name = "holder_presentation_ks"
holder_keystore_passcode = exec("kli passcode generate")
holder_keystore_salt = exec("kli salt")
holder_aid = "holder_aid"

!kli init --name {holder_keystore_name} --passcode {holder_keystore_passcode} --salt {holder_keystore_salt}\
    --config-dir ./config \
    --config-file keystore_init_config.json

!kli incept --name {holder_keystore_name} --alias {holder_aid} --passcode {holder_keystore_passcode} \
    --file ./config/aid_inception_config.json

# Issuer keystore init and AID inception
issuer_keystore_name = "issuer_presentation_ks"
issuer_keystore_passcode = exec("kli passcode generate")
issuer_keystore_salt = exec("kli salt")
issuer_aid = "issuer_aid"

!kli init --name {issuer_keystore_name} --passcode {issuer_keystore_passcode} --salt {issuer_keystore_salt}\
    --config-dir ./config \
    --config-file keystore_init_config.json

!kli incept --name {issuer_keystore_name} --passcode {issuer_keystore_passcode} --alias {issuer_aid}  \
    --file ./config/aid_inception_config.json

# Issuer registry inception
issuer_registry_name="issuer_registry"

!kli vc registry incept --name {issuer_keystore_name} \
    --passcode {issuer_keystore_passcode} \
    --registry-name {issuer_registry_name} \
    --alias {issuer_aid}

# Issuer and Holder oobi

holder_oobi_gen = f"kli oobi generate --name {holder_keystore_name} --alias {holder_aid} --passcode {holder_keystore_passcode} --role witness"
holder_oobi = exec(holder_oobi_gen)

issuer_oobi_gen = f"kli oobi generate --name {issuer_keystore_name} --alias {issuer_aid} --passcode {issuer_keystore_passcode} --role witness"
issuer_oobi = exec(issuer_oobi_gen)

!kli oobi resolve --name {holder_keystore_name} --passcode {holder_keystore_passcode} --oobi-alias {issuer_aid} \
    --oobi {issuer_oobi}

!kli oobi resolve --name {issuer_keystore_name} --passcode {issuer_keystore_passcode} --oobi-alias {holder_aid}\
    --oobi {holder_oobi}

# Issuer and Holder resolve schema oobis
schema_oobi_alias = "schema_oobi"
schema_said = get_schema_said("config/schemas/event_pass_schema.json")
schema_oobi = f"http://vlei-server:7723/oobi/{schema_said}"

!kli oobi resolve --name {holder_keystore_name} --passcode {holder_keystore_passcode} --oobi-alias {schema_oobi_alias} \
    --oobi {schema_oobi}

!kli oobi resolve --name {issuer_keystore_name} --passcode {issuer_keystore_passcode} --oobi-alias {schema_oobi_alias}\
    --oobi {schema_oobi}

# Issuer create VC
time = exec("kli time")

!kli vc create --name {issuer_keystore_name} --passcode {issuer_keystore_passcode} \
    --alias {issuer_aid} \
    --registry-name {issuer_registry_name} \
    --schema {schema_said} \
    --recipient {holder_aid} \
    --data "@./config/credential_data/event_pass_cred_data.json" \
    --time {time}

# Get credential said
get_credential_said = f"kli vc list --name {issuer_keystore_name} --passcode {issuer_keystore_passcode} --alias {issuer_aid} --issued --said --schema {schema_said}"
credential_said=exec(get_credential_said)

#Issuer grant credential
time = exec("kli time")

!kli ipex grant \
    --name {issuer_keystore_name} --passcode {issuer_keystore_passcode} \
    --alias {issuer_aid} \
    --said {credential_said} \
    --recipient {holder_aid} \
    --time {time}

# Holder poll and admit credential

get_ipex_said=f"kli ipex list --name {holder_keystore_name} --passcode {holder_keystore_passcode} --alias {holder_aid} --poll --said"
ipex_said=exec(get_ipex_said)

time = exec("kli time")

!kli ipex admit \
    --name {holder_keystore_name} \
    --passcode {holder_keystore_passcode} \
    --alias {holder_aid} \
    --said {ipex_said} \
    --time {time}

pr_continue()
```

    Proceeding with deletion of '/usr/local/var/keri/' without confirmation.
    ✅ Successfully removed: /usr/local/var/keri/


    KERI Keystore created at: /usr/local/var/keri/ks/holder_presentation_ks
    KERI Database created at: /usr/local/var/keri/db/holder_presentation_ks
    KERI Credential Store created at: /usr/local/var/keri/reg/holder_presentation_ks
    	aeid: BHQHgkOvgReP8UnWK6ALrbIs6XB-7erlXU1HrUOf9p3I
    
    Loading 3 OOBIs...


    http://witness-demo:5642/oobi/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha/controller?name=Wan&tag=witness succeeded
    http://witness-demo:5643/oobi/BLskRTInXnMxWaGqcpSyMgo0nYbalW99cGZESrz3zapM/controller?name=Wes&tag=witness succeeded
    http://witness-demo:5644/oobi/BIKKuvBwpmDVA4Ds-EpL5bt9OqPzWPja2LigFYZN2YfX/controller?name=Wil&tag=witness succeeded


    Waiting for witness receipts...


    Prefix  EKTsH9f4rhij7VT6dmiUOJzPL7KGJeIbTOnnSzAsrEFU
    	Public key 1:  DFKc79G0e4ku9qjNf2419HrnmBQ-pf1Z-602oAjhvQJR
    


    KERI Keystore created at: /usr/local/var/keri/ks/issuer_presentation_ks
    KERI Database created at: /usr/local/var/keri/db/issuer_presentation_ks
    KERI Credential Store created at: /usr/local/var/keri/reg/issuer_presentation_ks
    	aeid: BNWqcUUCns-8s_jXmzg_MPMzq0SFuTHfiY8OJlhTeEa2
    
    Loading 3 OOBIs...


    http://witness-demo:5642/oobi/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha/controller?name=Wan&tag=witness succeeded
    http://witness-demo:5643/oobi/BLskRTInXnMxWaGqcpSyMgo0nYbalW99cGZESrz3zapM/controller?name=Wes&tag=witness succeeded
    http://witness-demo:5644/oobi/BIKKuvBwpmDVA4Ds-EpL5bt9OqPzWPja2LigFYZN2YfX/controller?name=Wil&tag=witness succeeded


    Waiting for witness receipts...


    Prefix  EGS90tmpUs2itV1eevY7v5twNQIDB-66hSwX3GKjlruO
    	Public key 1:  DKHZJRB83VPD9SEkpCO56JCoaFg7g4UvvygoH76D4YXW
    


    Waiting for TEL event witness receipts


    Sending TEL events to witnesses


    Registry:  issuer_registry(ENileSLbbV2XRl5-yDhaAYbKNCbzUh0wTafSJ9ZBVmhD) 
    	created for Identifier Prefix:  EGS90tmpUs2itV1eevY7v5twNQIDB-66hSwX3GKjlruO


    http://witness-demo:5642/oobi/EGS90tmpUs2itV1eevY7v5twNQIDB-66hSwX3GKjlruO/witness resolved


    http://witness-demo:5642/oobi/EKTsH9f4rhij7VT6dmiUOJzPL7KGJeIbTOnnSzAsrEFU/witness resolved


    http://vlei-server:7723/oobi/EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK resolved


    http://vlei-server:7723/oobi/EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK resolved


    Waiting for TEL event witness receipts


    Sending TEL events to witnesses


    EHMbH_hoEzN3RXkHhx7SPA5y7y6-Y8MuXLgLLqUkU3UL has been created.


    Sending message EBRQJP2VemYRMIV3fHHpV154A0v7p_GIyu43w52Dpacf to EKTsH9f4rhij7VT6dmiUOJzPL7KGJeIbTOnnSzAsrEFU


    ... grant message sent


    Sending admit message to EGS90tmpUs2itV1eevY7v5twNQIDB-66hSwX3GKjlruO


    ... admit message sent


    
    [1m[42m[90m  You can continue ✅  [0m
    
    


## The IPEX Presentation Flow

Now that the Holder (`holder_aid`) possesses the `EventPass` credential, you must present it to a Verifier (`verifier_aid`) to prove they have access.

First, confirm the Holder has the credential:


```python
!kli vc list  --name {holder_keystore_name} \
    --passcode {holder_keystore_passcode} \
    --verbose
```

    Current received credentials for holder_aid (EKTsH9f4rhij7VT6dmiUOJzPL7KGJeIbTOnnSzAsrEFU):
    
    Credential #1: EHMbH_hoEzN3RXkHhx7SPA5y7y6-Y8MuXLgLLqUkU3UL
        Type: EventPass
        Status: Issued [92m✔[0m
        Issued by EGS90tmpUs2itV1eevY7v5twNQIDB-66hSwX3GKjlruO
        Issued on 2025-06-05T22:21:57.656852+00:00
        Full Credential:
    	{
    	  "v": "ACDC10JSON0001c4_",
    	  "d": "EHMbH_hoEzN3RXkHhx7SPA5y7y6-Y8MuXLgLLqUkU3UL",
    	  "i": "EGS90tmpUs2itV1eevY7v5twNQIDB-66hSwX3GKjlruO",
    	  "ri": "ENileSLbbV2XRl5-yDhaAYbKNCbzUh0wTafSJ9ZBVmhD",
    	  "s": "EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK",
    	  "a": {
    	    "d": "EIarjpmZWm9ko98rBbrGQ_ISxEzcP8nMZWD7ZhBnBoze",
    	    "i": "EKTsH9f4rhij7VT6dmiUOJzPL7KGJeIbTOnnSzAsrEFU",
    	    "dt": "2025-06-05T22:21:57.656852+00:00",
    	    "eventName": "GLEIF Summit",
    	    "accessLevel": "staff",
    	    "validDate": "2026-10-01"
    	  }
    	}


### Verifier AID Setup

Just like the Issuer and Holder, the Verifier needs its own AID to participate in the protocol securely. Initialize its keystore and incept its AID.


```python
verifier_keystore_name="verifier_ks"

verifier_keystore_passcode = exec("kli passcode generate")

verifier_keystore_salt = exec("kli salt")
# Alias for our non-transferable AID
verifier_aid = "verifier_aid"

# Initialize the keystore
!kli init --name {verifier_keystore_name} --passcode {verifier_keystore_passcode} --salt {verifier_keystore_salt}\
    --config-dir ./config \
    --config-file keystore_init_config.json

!kli incept --name {verifier_keystore_name} --alias {verifier_aid} --passcode {verifier_keystore_passcode} \
    --file ./config/aid_inception_config.json
```

    KERI Keystore created at: /usr/local/var/keri/ks/verifier_ks
    KERI Database created at: /usr/local/var/keri/db/verifier_ks
    KERI Credential Store created at: /usr/local/var/keri/reg/verifier_ks
    	aeid: BBdwEg_yiSSYCkulDzvWVC7Yt8pxyo0-1QXO1wK9y3XO
    
    Loading 3 OOBIs...


    http://witness-demo:5642/oobi/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha/controller?name=Wan&tag=witness succeeded
    http://witness-demo:5643/oobi/BLskRTInXnMxWaGqcpSyMgo0nYbalW99cGZESrz3zapM/controller?name=Wes&tag=witness succeeded
    http://witness-demo:5644/oobi/BIKKuvBwpmDVA4Ds-EpL5bt9OqPzWPja2LigFYZN2YfX/controller?name=Wil&tag=witness succeeded


    Waiting for witness receipts...


    Prefix  EJLZ-W2MArXetfQ0oBuzhcl8Depk37LbUV4UuRNraSaU
    	Public key 1:  DOQIffAkPjF9r6Ka99SfGUuVe2b8NDJ3avjNg3WJ88DT
    


### Establishing Holder-Verifier Connection (OOBI)

Similar to the Issuer/Holder exchange, the Holder and Verifier must exchange and resolve OOBIs to establish a secure communication channel and verify each other's key states (KELs).


```python
holder_oobi_gen = f"kli oobi generate --name {holder_keystore_name} --alias {holder_aid} --passcode {holder_keystore_passcode} --role witness"
holder_oobi = exec(holder_oobi_gen)

verifier_oobi_gen = f"kli oobi generate --name {verifier_keystore_name} --alias {verifier_aid} --passcode {verifier_keystore_passcode} --role witness"
verifier_oobi = exec(verifier_oobi_gen)

!kli oobi resolve --name {holder_keystore_name} --passcode {holder_keystore_passcode} --oobi-alias {verifier_aid} \
    --oobi {verifier_oobi}

!kli oobi resolve --name {verifier_keystore_name} --passcode {verifier_keystore_passcode} --oobi-alias {holder_aid}\
    --oobi {holder_oobi}


```

    http://witness-demo:5642/oobi/EJLZ-W2MArXetfQ0oBuzhcl8Depk37LbUV4UuRNraSaU/witness resolved


    http://witness-demo:5642/oobi/EKTsH9f4rhij7VT6dmiUOJzPL7KGJeIbTOnnSzAsrEFU/witness resolved


### Verifier Resolves Schema OOBI

The Verifier also needs to resolve the OOBI for the ACDC's schema (`event_pass_schema`). This allows the Verifier to retrieve the schema definition and validate that the presented credential conforms to the expected structure and data types. Without the schema, the Verifier wouldn't know how to interpret or validate the credential's content.


```python
!kli oobi resolve --name {verifier_keystore_name} --passcode {verifier_keystore_passcode} --oobi-alias {schema_oobi_alias}\
    --oobi {schema_oobi}
```

    http://vlei-server:7723/oobi/EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK resolved


### Step 1: Holder Presents Credential (Grant)

Now, the Holder initiates the IPEX exchange to present the credential to the Verifier. The Holder acts as the "Discloser" in this context. The command used is `kli ipex grant`, just like in issuance, but the roles are reversed in intent.

- `--name`, `--passcode`, `--alias`: Identify the Holder's keystore and AID.
- `--said`: The SAID of the credential being presented.
- `--recipient`: The AID of the Verifier who should receive the presentation.
- `--time`: A timestamp for the grant message.

This sends an IPEX grant message, effectively offering the credential presentation to the Verifier.


```python
time = exec("kli time")

!kli ipex grant \
    --name {holder_keystore_name} \
    --passcode {holder_keystore_passcode} \
    --alias {holder_aid} \
    --said {credential_said} \
    --recipient {verifier_aid} \
    --time {time}
```

    Sending message EG1Bmw-Rvih_y-pr5H_6PrqInThLwWTZJsmbZFF7Uzuk to EJLZ-W2MArXetfQ0oBuzhcl8Depk37LbUV4UuRNraSaU


    ... grant message sent


### Step 2: Verifier Receives Presentation

The Verifier needs to check its KERI mailbox for the incoming grant message containing the credential presentation.Use `kli ipex list --poll` and extract the SAID of the message.


```python
get_ipex_said=f"kli ipex list --name {verifier_keystore_name} --passcode {verifier_keystore_passcode} --alias {verifier_aid} --poll --said"
ipex_said=exec(get_ipex_said)

print(ipex_said)
```

    EG1Bmw-Rvih_y-pr5H_6PrqInThLwWTZJsmbZFF7Uzuk


**Verifier displays credential (Optional)**

Before formally admitting the credential, the Verifier can inspect the received presentation using `kli ipex list --verbose`. This shows the credential details and the status of the IPEX exchange.


```python
!kli ipex list \
    --name {verifier_keystore_name} \
    --passcode {verifier_keystore_passcode} \
    --alias {verifier_aid} \
    --verbose
```

    
    Received IPEX Messages:
    
    GRANT - SAID: EG1Bmw-Rvih_y-pr5H_6PrqInThLwWTZJsmbZFF7Uzuk
    Credential EHMbH_hoEzN3RXkHhx7SPA5y7y6-Y8MuXLgLLqUkU3UL:
        Type: EventPass
        Status: Issued [92m✔[0m
        Issued by EGS90tmpUs2itV1eevY7v5twNQIDB-66hSwX3GKjlruO
        Issued on 2025-06-05T22:21:57.656852+00:00
        Already responded? No [91m✘[0m
        Full Credential:
    	{
    	  "v": "ACDC10JSON0001c4_",
    	  "d": "EHMbH_hoEzN3RXkHhx7SPA5y7y6-Y8MuXLgLLqUkU3UL",
    	  "i": "EGS90tmpUs2itV1eevY7v5twNQIDB-66hSwX3GKjlruO",
    	  "ri": "ENileSLbbV2XRl5-yDhaAYbKNCbzUh0wTafSJ9ZBVmhD",
    	  "s": "EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK",
    	  "a": {
    	    "d": "EIarjpmZWm9ko98rBbrGQ_ISxEzcP8nMZWD7ZhBnBoze",
    	    "i": "EKTsH9f4rhij7VT6dmiUOJzPL7KGJeIbTOnnSzAsrEFU",
    	    "dt": "2025-06-05T22:21:57.656852+00:00",
    	    "eventName": "GLEIF Summit",
    	    "accessLevel": "staff",
    	    "validDate": "2026-10-01"
    	  }
    	}
    


### Step 3: Verifier Admits and Validates Presentation

The Verifier uses the `kli ipex admit` command to accept the presentation. This triggers the Verifier's KERI controller to perform several checks automatically:

- Schema Validation: Checks whether the credential structure and data types match the resolved schema.
- Issuer Authentication: Verifies the credential signature against the Issuer's KEL (previously retrieved via OOBI) and, importantly, checks the credential's status (e.g., not revoked) against the Issuer's registry (TEL).

If all checks pass, the Verifier sends an admit message back to the Holder and stores the validated credential information.


```python
time = exec("kli time")

!kli ipex admit \
    --name {verifier_keystore_name} \
    --passcode {verifier_keystore_passcode} \
    --alias {verifier_aid} \
    --said {ipex_said} \
    --time {time}
```

    Sending admit message to EKTsH9f4rhij7VT6dmiUOJzPL7KGJeIbTOnnSzAsrEFU


    ... admit message sent


**Verifier Confirms Admission**

Finally, the Verifier can check the status of the received IPEX message again. The Already responded? field should now show Yes ✔ and indicate the response was Admit, confirming the successful presentation and validation.


```python
!kli ipex list \
    --name {verifier_keystore_name} \
    --passcode {verifier_keystore_passcode} \
    --alias {verifier_aid} \
    --verbose
```

    
    Received IPEX Messages:
    
    GRANT - SAID: EG1Bmw-Rvih_y-pr5H_6PrqInThLwWTZJsmbZFF7Uzuk
    Credential EHMbH_hoEzN3RXkHhx7SPA5y7y6-Y8MuXLgLLqUkU3UL:
        Type: EventPass
        Status: Issued [92m✔[0m
        Issued by EGS90tmpUs2itV1eevY7v5twNQIDB-66hSwX3GKjlruO
        Issued on 2025-06-05T22:21:57.656852+00:00
        Already responded? Yes [92m✔[0m
        Response: [92mAdmit[0m (EMcJw7qIEc2YVySRfN6z_SemI21KCvThiiFbN0T0XAFE)
        Full Credential:
    	{
    	  "v": "ACDC10JSON0001c4_",
    	  "d": "EHMbH_hoEzN3RXkHhx7SPA5y7y6-Y8MuXLgLLqUkU3UL",
    	  "i": "EGS90tmpUs2itV1eevY7v5twNQIDB-66hSwX3GKjlruO",
    	  "ri": "ENileSLbbV2XRl5-yDhaAYbKNCbzUh0wTafSJ9ZBVmhD",
    	  "s": "EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK",
    	  "a": {
    	    "d": "EIarjpmZWm9ko98rBbrGQ_ISxEzcP8nMZWD7ZhBnBoze",
    	    "i": "EKTsH9f4rhij7VT6dmiUOJzPL7KGJeIbTOnnSzAsrEFU",
    	    "dt": "2025-06-05T22:21:57.656852+00:00",
    	    "eventName": "GLEIF Summit",
    	    "accessLevel": "staff",
    	    "validDate": "2026-10-01"
    	  }
    	}
    


## Credential Revocation by Issuer

Credentials may need to be invalidated before their natural expiry (if any). This process is called revocation. In KERI/ACDC, revocation is performed by the original Issuer of the credential. The Issuer records a revocation event in the credential registry's Transaction Event Log (TEL), which is anchored to the Issuer's main KEL.

The `kli vc revoke` command is used by the Issuer:

- `--name`, `--passcode`, `--alias`: Identify the Issuer's keystore and AID.
- `--registry-name`: Specifies the registry where the credential's status is managed.
- `--said`: The SAID of the specific credential instance to be revoked.
- `--time`: Timestamp for the revocation event.


```python
!kli vc revoke --name {issuer_keystore_name} --passcode {issuer_keystore_passcode} \
    --alias {issuer_aid} \
    --registry-name {issuer_registry_name} \
    --said {credential_said} \
    --time {time}
```

    Waiting for TEL event witness receipts


    Sending TEL events to witnesses


Now, if the Issuer lists their issued credentials again, the status will reflect the revocation:


```python
!kli vc list --name {issuer_keystore_name} --passcode {issuer_keystore_passcode} \
    --alias {issuer_aid} \
    -i
```

    Current issued credentials for issuer_aid (EGS90tmpUs2itV1eevY7v5twNQIDB-66hSwX3GKjlruO):
    
    Credential #1: EHMbH_hoEzN3RXkHhx7SPA5y7y6-Y8MuXLgLLqUkU3UL
        Type: EventPass
        Status: Revoked [91m✘[0m
        Issued by EGS90tmpUs2itV1eevY7v5twNQIDB-66hSwX3GKjlruO
        Issued on 2025-06-05T22:22:28.440209+00:00


<div class="alert alert-primary">
<b>📝 SUMMARY</b><hr>
This notebook demonstrated the ACDC presentation and revocation flows:
<ol>
<li><b>Prerequisites:</b> We started with a Holder possessing an issued credential from an Issuer (established via the recap section).</li>
<li><b>Verifier Setup:</b> A Verifier established its KERI identity (AID).</li>
<li><b>Connectivity:</b> The Holder and Verifier exchanged and resolved OOBIs. The Verifier also resolved the credential's schema OOBI to enable validation.</li>
<li><b>Presentation (IPEX):</b>
<ul>
<li>Holder initiated the presentation using kli ipex grant, sending the credential to the Verifier.</li>
<li>Verifier polled its mailbox (kli ipex list --poll) to receive the presentation.</li>
<li>Verifier accepted and validated the presentation using kli ipex admit. Validation included schema checks, issuer authentication (KEL), and registry status checks (TEL).</li>
</ul>
</li>
<li><b>Revocation:</b>
<ul>
<li>The original Issuer revoked the credential using kli vc revoke, updating the status in the credential registry's TEL.</li>
</ul>
</li>
</ol>
This completes the basic lifecycle demonstration: issuance (previous notebook), presentation, and revocation, all handled securely using KERI identities and the IPEX protocol.
</div>
