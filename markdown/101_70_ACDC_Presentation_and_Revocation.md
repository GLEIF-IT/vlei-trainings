# ACDC Presentation and Revocation with KLI: Using the IPEX Protocol

<div class="alert alert-primary">
<b>🎯 OBJECTIVE</b><hr>
Demonstrate how a Holder presents a previously issued ACDC or Verifiable Credential (VC) to a Verifier using the Issuance and Presentation Exchange (IPEX) protocol.<br/>
<br/>
Understand how IPEX allows credential holders (issuees) to sign that they agree with the terms of a credential.<br/>
<br/>
Conduct a credential revocation and present a revoked credential as an issuer so the holder may learn that a credential they hold has been revoked. Learn that observer infrastructure may be used for pull-style monitoring of credential revocation state.
</div>

## Credential Presentation Overview

In the previous notebook, you saw how an Issuer creates and sends an ACDC to a Holder. Now, we'll focus on the next steps in the typical verifiable credential lifecycle: presentation and admittance.

After creating the credential the Issuer must present it to the Holder. In IPEX this presentation is called an IPEX Grant message. After receiving the IPEX Grant message the Holder can then accept the credential by performing an IPEX Admit message. In the prior training this Grant and Admit process were explained.

In this training, following the reception of a credential, the Holder will present it to another party (the Verifier) to prove certain claims or gain access to something. You will again use the IPEX protocol for this exchange, but this time initiated by the Holder. Finally, you will see how the original Issuer can revoke the credential.

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

!kli incept --name {issuer_keystore_name} --passcode {issuer_keystore_passcode} --alias {issuer_aid}\
    --file ./config/aid_inception_config.json

# Issuer registry inception
issuer_registry_name="issuer_registry"

!kli vc registry incept --name {issuer_keystore_name} \
    --passcode {issuer_keystore_passcode} \
    --registry-name {issuer_registry_name} \
    --alias {issuer_aid}

# Issuer and Holder oobi

holder_oobi_gen = f"kli oobi generate --name {holder_keystore_name} --alias {holder_aid}\
  --passcode {holder_keystore_passcode} --role witness"
holder_oobi = exec(holder_oobi_gen)

issuer_oobi_gen = f"kli oobi generate --name {issuer_keystore_name} --alias {issuer_aid}\
  --passcode {issuer_keystore_passcode} --role witness"
issuer_oobi = exec(issuer_oobi_gen)

!kli oobi resolve --name {holder_keystore_name} --passcode {holder_keystore_passcode}\
  --oobi-alias {issuer_aid} --oobi {issuer_oobi}

!kli oobi resolve --name {issuer_keystore_name} --passcode {issuer_keystore_passcode}\
  --oobi-alias {holder_aid} --oobi {holder_oobi}

# Issuer and Holder resolve schema oobis
schema_oobi_alias = "schema_oobi"
schema_said = get_schema_said("config/schemas/event_pass_schema.json")
schema_oobi = f"http://vlei-server:7723/oobi/{schema_said}"

!kli oobi resolve --name {holder_keystore_name} --passcode {holder_keystore_passcode}\
    --oobi-alias {schema_oobi_alias} --oobi {schema_oobi}

!kli oobi resolve --name {issuer_keystore_name} --passcode {issuer_keystore_passcode}\
    --oobi-alias {schema_oobi_alias} --oobi {schema_oobi}

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
get_credential_said = f"kli vc list --name {issuer_keystore_name}\
  --passcode {issuer_keystore_passcode} --alias {issuer_aid}\
  --issued --said --schema {schema_said}"
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

get_ipex_said=f"kli ipex list --name {holder_keystore_name} --passcode {holder_keystore_passcode}\
  --alias {holder_aid} --poll --said"
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
    	aeid: BBBVRy6lcdnYQ9FnsGN6Q-Y6ldO6TbixkpjROvHynFrE
    
    Loading 3 OOBIs...


    http://witness-demo:5642/oobi/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha/controller?name=Wan&tag=witness succeeded
    http://witness-demo:5643/oobi/BLskRTInXnMxWaGqcpSyMgo0nYbalW99cGZESrz3zapM/controller?name=Wes&tag=witness succeeded
    http://witness-demo:5644/oobi/BIKKuvBwpmDVA4Ds-EpL5bt9OqPzWPja2LigFYZN2YfX/controller?name=Wil&tag=witness succeeded


    Waiting for witness receipts...


    Prefix  EF48bMpmEntCs7Dsa4ThI9ncQNpVk0RJcKxIhIOSEaUc
    	Public key 1:  DCaCpFrgPhN2hauZ9JhrCC2KfnTXIAJtYzeLcy0sAfMG
    


    KERI Keystore created at: /usr/local/var/keri/ks/issuer_presentation_ks
    KERI Database created at: /usr/local/var/keri/db/issuer_presentation_ks
    KERI Credential Store created at: /usr/local/var/keri/reg/issuer_presentation_ks
    	aeid: BC_295BahyVc3cLyo4UpJZxB-8IPsgWhHnj1Bx_MxzCZ
    
    Loading 3 OOBIs...


    http://witness-demo:5642/oobi/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha/controller?name=Wan&tag=witness succeeded
    http://witness-demo:5643/oobi/BLskRTInXnMxWaGqcpSyMgo0nYbalW99cGZESrz3zapM/controller?name=Wes&tag=witness succeeded
    http://witness-demo:5644/oobi/BIKKuvBwpmDVA4Ds-EpL5bt9OqPzWPja2LigFYZN2YfX/controller?name=Wil&tag=witness succeeded


    Waiting for witness receipts...


    Prefix  EDrgzJ9CTI__UOzLxSQEjRcVn-WdCg0vr7H08rS8LDpF
    	Public key 1:  DNb4Svy4wFKFENR7UfwyzNTiKplUvq08tZpURpiMJ_YO
    


    Waiting for TEL event witness receipts


    Sending TEL events to witnesses


    Registry:  issuer_registry(EOCl9YIwNcqXsGNs7k3hr61wmOukF_1GLf11l3SzvGUV) 
    	created for Identifier Prefix:  EDrgzJ9CTI__UOzLxSQEjRcVn-WdCg0vr7H08rS8LDpF


    http://witness-demo:5642/oobi/EDrgzJ9CTI__UOzLxSQEjRcVn-WdCg0vr7H08rS8LDpF/witness resolved


    http://witness-demo:5642/oobi/EF48bMpmEntCs7Dsa4ThI9ncQNpVk0RJcKxIhIOSEaUc/witness resolved


    http://vlei-server:7723/oobi/EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK resolved


    http://vlei-server:7723/oobi/EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK resolved


    Waiting for TEL event witness receipts


    Sending TEL events to witnesses


    EKdFpsYHnxZiUiXefCuqKB0puQmfbRPUCJniDQ0uj9Gd has been created.


    Sending message EHPK4Gm3V9D_EzzfXmG1watsWPOQlob0q2krPqYB5mA8 to EF48bMpmEntCs7Dsa4ThI9ncQNpVk0RJcKxIhIOSEaUc


    ... grant message sent


    Sending admit message to EDrgzJ9CTI__UOzLxSQEjRcVn-WdCg0vr7H08rS8LDpF


    ... admit message sent


    
      You can continue ✅  
    
    


## The IPEX Presentation Flow

Now that the Holder (`holder_aid`) possesses the `EventPass` credential, you must present it to a Verifier (`verifier_aid`) to prove they have access.

First, confirm the Holder has the credential:


```python
!kli vc list  --name {holder_keystore_name} \
    --passcode {holder_keystore_passcode} \
    --verbose
```

    Current received credentials for holder_aid (EF48bMpmEntCs7Dsa4ThI9ncQNpVk0RJcKxIhIOSEaUc):
    
    Credential #1: EKdFpsYHnxZiUiXefCuqKB0puQmfbRPUCJniDQ0uj9Gd
        Type: EventPass
        Status: Issued ✔
        Issued by EDrgzJ9CTI__UOzLxSQEjRcVn-WdCg0vr7H08rS8LDpF
        Issued on 2025-07-18T00:18:06.956874+00:00
        Full Credential:
    	{
    	  "v": "ACDC10JSON0001c4_",
    	  "d": "EKdFpsYHnxZiUiXefCuqKB0puQmfbRPUCJniDQ0uj9Gd",
    	  "i": "EDrgzJ9CTI__UOzLxSQEjRcVn-WdCg0vr7H08rS8LDpF",
    	  "ri": "EOCl9YIwNcqXsGNs7k3hr61wmOukF_1GLf11l3SzvGUV",
    	  "s": "EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK",
    	  "a": {
    	    "d": "EHEZ2ahUpRq8J5qrakEk_a4GrcDyR-aGhBzLv5lTGsJ2",
    	    "i": "EF48bMpmEntCs7Dsa4ThI9ncQNpVk0RJcKxIhIOSEaUc",
    	    "dt": "2025-07-18T00:18:06.956874+00:00",
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
    	aeid: BKdWWKjMtQzNcZNNiWd5bvTB31jSwkqQSDjXWiT21jF-
    
    Loading 3 OOBIs...


    http://witness-demo:5642/oobi/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha/controller?name=Wan&tag=witness succeeded
    http://witness-demo:5643/oobi/BLskRTInXnMxWaGqcpSyMgo0nYbalW99cGZESrz3zapM/controller?name=Wes&tag=witness succeeded
    http://witness-demo:5644/oobi/BIKKuvBwpmDVA4Ds-EpL5bt9OqPzWPja2LigFYZN2YfX/controller?name=Wil&tag=witness succeeded


    Waiting for witness receipts...


    Prefix  EIZQZVLQVwebl4ME2viQKn-J0zZpK80_fVXYoiZ7rvak
    	Public key 1:  DL9Bc9Ruvc2D5uZPOmXSNIWuK-PSMtwOCc7m4Bwqf1DW
    


### Establishing Holder-Verifier Connection (OOBI)

Similar to the Issuer/Holder exchange, the Holder and Verifier must exchange and resolve OOBIs to establish a secure communication channel and verify each other's key states (KELs).


```python
holder_oobi_gen = f"kli oobi generate --name {holder_keystore_name} --alias {holder_aid}\
    --passcode {holder_keystore_passcode} --role witness"
holder_oobi = exec(holder_oobi_gen)

verifier_oobi_gen = f"kli oobi generate --name {verifier_keystore_name} --alias {verifier_aid}\
    --passcode {verifier_keystore_passcode} --role witness"
verifier_oobi = exec(verifier_oobi_gen)

!kli oobi resolve --name {holder_keystore_name} --passcode {holder_keystore_passcode}\
    --oobi-alias {verifier_aid} --oobi {verifier_oobi}

!kli oobi resolve --name {verifier_keystore_name} --passcode {verifier_keystore_passcode}\
    --oobi-alias {holder_aid} --oobi {holder_oobi}
```

    http://witness-demo:5642/oobi/EIZQZVLQVwebl4ME2viQKn-J0zZpK80_fVXYoiZ7rvak/witness resolved


    http://witness-demo:5642/oobi/EF48bMpmEntCs7Dsa4ThI9ncQNpVk0RJcKxIhIOSEaUc/witness resolved


### Verifier Resolves Schema OOBI

The Verifier also needs to resolve the OOBI for the ACDC's schema (`event_pass_schema`). This allows the Verifier to retrieve the schema definition and validate that the presented credential conforms to the expected structure and data types. Without the schema, the Verifier wouldn't know how to interpret or validate the credential's content.


```python
!kli oobi resolve --name {verifier_keystore_name} --passcode {verifier_keystore_passcode}\
    --oobi-alias {schema_oobi_alias} --oobi {schema_oobi}
```

    http://vlei-server:7723/oobi/EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK resolved


### Step 1: Holder Presents Credential (Grant)

Now, the Holder initiates the IPEX exchange to present the credential to the Verifier. The Holder acts as the "Discloser" in this context. The command used is `kli ipex grant`, just like in issuance, but the IPEX roles here are different so the Holder is the discloser and the Verifier is the disclosee.

- `--name`, `--passcode`, `--alias`: Identify the Holder's keystore and AID.
- `--said`: The SAID of the credential being presented.
- `--recipient`: The AID of the Verifier who should receive the presentation.
- `--time`: A timestamp for the grant message.

This sends an IPEX Grant message, effectively offering the credential presentation to the Verifier.

<div class="alert alert-info">
<b>ℹ️ NOTE: on <code>--time</code></b><hr> 
Including the time <code>--time</code> argument is only necessary when performing multisignature operations. It is shown below for illustrative purposes only. 
    
This argument is necessary for multisignature operations because each participating controller must produce the exact same event, in this case an IPEX Grant message, as all the other members of a multisig group. Since a timestamp is one of the attributes in an IPEX Grant message then in order to produce the exact same event, and thereby the same event digest, the same value for a timestamp must be used by each controller when constructing the event. At the command line this is provided with the `--time` argument to the `kli ipex grant` command.

You will notice the output value of the `kli time` command is used in various places in these Jupyter notebooks. The necessity of the `--time` command is the same for each context; it is only applicable to multi-signature operations.
</div>


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

    Sending message EBamgKsfJURegxwVHiXgTzZwYGv_QPaIS-aq-erRkyCo to EIZQZVLQVwebl4ME2viQKn-J0zZpK80_fVXYoiZ7rvak


    ... grant message sent


Receiving the Grant message triggers the Verifier's KERI controller to perform several checks automatically:

- Schema Validation: Checks whether the credential structure and data types match the resolved schema.
- Issuer Authentication: Verifies the credential signature against the Issuer's KEL (previously retrieved via OOBI) and, importantly, checks the credential's status (e.g., not revoked) against the Issuer's registry (TEL).

If all checks pass, the Verifier may admit the ACDC, store the validated credential information, and send an IPEX Admit message back to the Holder.

### Step 2: Verifier Receives Presentation

The Verifier needs to check its KERI mailbox(es) for the incoming grant message containing the credential presentation.

Use `kli ipex list --poll` to check the mailbox(es) and extract the SAID of the IPEX Grant message.


```python
get_ipex_said=f"kli ipex list --name {verifier_keystore_name} --passcode {verifier_keystore_passcode}\
    --alias {verifier_aid} --poll --said"
ipex_said=exec(get_ipex_said)

print(ipex_said)

pr_continue()
```

    EBamgKsfJURegxwVHiXgTzZwYGv_QPaIS-aq-erRkyCo
    
      You can continue ✅  
    
    


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
    
    GRANT - SAID: EBamgKsfJURegxwVHiXgTzZwYGv_QPaIS-aq-erRkyCo
    Credential EKdFpsYHnxZiUiXefCuqKB0puQmfbRPUCJniDQ0uj9Gd:
        Type: EventPass
        Status: Issued ✔
        Issued by EDrgzJ9CTI__UOzLxSQEjRcVn-WdCg0vr7H08rS8LDpF
        Issued on 2025-07-18T00:18:06.956874+00:00
        Already responded? No ✘
        Full Credential:
    	{
    	  "v": "ACDC10JSON0001c4_",
    	  "d": "EKdFpsYHnxZiUiXefCuqKB0puQmfbRPUCJniDQ0uj9Gd",
    	  "i": "EDrgzJ9CTI__UOzLxSQEjRcVn-WdCg0vr7H08rS8LDpF",
    	  "ri": "EOCl9YIwNcqXsGNs7k3hr61wmOukF_1GLf11l3SzvGUV",
    	  "s": "EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK",
    	  "a": {
    	    "d": "EHEZ2ahUpRq8J5qrakEk_a4GrcDyR-aGhBzLv5lTGsJ2",
    	    "i": "EF48bMpmEntCs7Dsa4ThI9ncQNpVk0RJcKxIhIOSEaUc",
    	    "dt": "2025-07-18T00:18:06.956874+00:00",
    	    "eventName": "GLEIF Summit",
    	    "accessLevel": "staff",
    	    "validDate": "2026-10-01"
    	  }
    	}
    


The status of the credential is shown by `Already responded? No ✘` meaning that an IPEX Admit from the Verifier to the Holder has not yet been sent.

### Step 3: Verifier Admits and Validates Presentation (Agreeing to Terms)

An admit is not strictly necessary between the verifier and the holder, though sending an admit is one way the Verifier signals to the holder that the verifier agrees to the terms of the credential presentation. The terms in the credential are specified in the rules section.

The Verifier uses the `kli ipex admit` command to accept the presentation.



```python
time = exec("kli time")

!kli ipex admit \
    --name {verifier_keystore_name} \
    --passcode {verifier_keystore_passcode} \
    --alias {verifier_aid} \
    --said {ipex_said} \
    --time {time}
```

    Sending admit message to EF48bMpmEntCs7Dsa4ThI9ncQNpVk0RJcKxIhIOSEaUc


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
    
    GRANT - SAID: EBamgKsfJURegxwVHiXgTzZwYGv_QPaIS-aq-erRkyCo
    Credential EKdFpsYHnxZiUiXefCuqKB0puQmfbRPUCJniDQ0uj9Gd:
        Type: EventPass
        Status: Issued ✔
        Issued by EDrgzJ9CTI__UOzLxSQEjRcVn-WdCg0vr7H08rS8LDpF
        Issued on 2025-07-18T00:18:06.956874+00:00
        Already responded? Yes ✔
        Response: Admit (EO7n6MMvrm9wGo-1gSYK0olfrqwUVAHjDYk5Y23T446E)
        Full Credential:
    	{
    	  "v": "ACDC10JSON0001c4_",
    	  "d": "EKdFpsYHnxZiUiXefCuqKB0puQmfbRPUCJniDQ0uj9Gd",
    	  "i": "EDrgzJ9CTI__UOzLxSQEjRcVn-WdCg0vr7H08rS8LDpF",
    	  "ri": "EOCl9YIwNcqXsGNs7k3hr61wmOukF_1GLf11l3SzvGUV",
    	  "s": "EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK",
    	  "a": {
    	    "d": "EHEZ2ahUpRq8J5qrakEk_a4GrcDyR-aGhBzLv5lTGsJ2",
    	    "i": "EF48bMpmEntCs7Dsa4ThI9ncQNpVk0RJcKxIhIOSEaUc",
    	    "dt": "2025-07-18T00:18:06.956874+00:00",
    	    "eventName": "GLEIF Summit",
    	    "accessLevel": "staff",
    	    "validDate": "2026-10-01"
    	  }
    	}
    


## Credential Revocation by Issuer

Credentials may need to be invalidated before their natural expiry (if any). This process is called revocation. In KERI/ACDC, revocation is performed by the original Issuer of the credential. The Issuer records a revocation event in the credential registry's Transaction Event Log (TEL), and that event is anchored to the Issuer's main KEL.

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
    --issued
```

    Current issued credentials for issuer_aid (EDrgzJ9CTI__UOzLxSQEjRcVn-WdCg0vr7H08rS8LDpF):
    
    Credential #1: EKdFpsYHnxZiUiXefCuqKB0puQmfbRPUCJniDQ0uj9Gd
        Type: EventPass
        Status: Revoked ✘
        Issued by EDrgzJ9CTI__UOzLxSQEjRcVn-WdCg0vr7H08rS8LDpF
        Issued on 2025-07-18T00:18:34.227259+00:00


### Sharing the revoked credential status with the Holder.
Revoking a credential is an important event that should be shared with verifiers. One way to share a revocation with a verifier is to share the revocation of a credential with the Holder. After the Holder receives that revoked credential status then it can re-present the revoked credential to a verifier so that the verifier may know the credential is revoked.

To accomplish this sharing of revocation state the issuer may perform another IPEX Grant of the credential following revocation. Then the Holder must again perform an IPEX Admit in order to learn of this revocation state.

<div class="alert alert-info">
<b>ℹ️ NOTE: Observers for Learning of Revocation State</b><hr> 
Use of an Observer node to learn of an ACDC credential state is another way for a verifier to learn of the revocation state of a credential. While standalone observers are under development, a witness of a controller may be used to query for credential state using the following request format:
<br/><br/>
<b>`HTTP GET`</b> to a witness host on the `/query` endpoint with URL parameters like so:

- `/query?typ=tel&amp;reg=EHrbPfpRLU9wpFXTzGY-LIo2FjMiljjEnt238eWHb7yZ&amp;vcid=EO5y0jMXS5XKTYBKjCUPmNKPr1FWcWhtKwB2Go2ozvr0`

A full query to a witness would look like so:
- `https://wit1.testnet.gleif.org:5641/query?typ=tel&reg=EHrbPfpRLU9wpFXTzGY-LIo2FjMiljjEnt238eWHb7yZ&vcid=EO5y0jMXS5XKTYBKjCUPmNKPr1FWcWhtKwB2Go2ozvr0`
</div>

### Presenting a revoked credential

Now the holder can present the revoked credential to the verifier and the verifier can understand that the credential is revoke.

#### Step 1: Issuer Sends revocation status with IPEX

An issuer may directly inform a holder using another IPEX Grant about the revocation status of any credential issued from itself. 

<div class="alert alert-info">
<b>ℹ️ NOTE: Observers for querying credential status</b><hr> 
Waiting for an issuer to send credential revocation status is not the only way a holder can learn about whether or not a credential has been revoked. 
    
<b>Observers</b> are another way a verifier or a holder can learn of the credential status, issued or revoked, from an issuer. Currently, as of June 16, 2025, observers are in an early phase in their development and are deployed as a feature on an issuer's witness. Eventually observers will be standalone components.
</div>


```python
# Issuer grants the now revoked credential
time = exec("kli time")

!kli ipex grant \
    --name {issuer_keystore_name} --passcode {issuer_keystore_passcode} \
    --alias {issuer_aid} \
    --said {credential_said} \
    --recipient {holder_aid} \
    --time {time}
```

    Sending message EFO_4ByP6ShVL8Ug3KpZ6QRfeajBIn4ovZQ8inVP81Cf to EF48bMpmEntCs7Dsa4ThI9ncQNpVk0RJcKxIhIOSEaUc


    ... grant message sent


#### Step 2: Holder Admits IPEX Grant of revoked credential

Now the holder admits the IPEX Grant from the issuer of the recently revoked credential.



```python
# Holder polls and admits the revoked credential
# The pipe to "tail -n 1" makes sure to get the last IPEX Grant which will be the grant sharing the revoked credential
get_ipex_said=f"kli ipex list --name {holder_keystore_name} --passcode {holder_keystore_passcode}\
  --alias {holder_aid} --poll --said | tail -n 1 | tr -d '' "
ipex_said=exec(get_ipex_said)

print(f"Found grant {ipex_said} for revocation")

time = exec("kli time")

!kli ipex admit \
    --name {holder_keystore_name} \
    --passcode {holder_keystore_passcode} \
    --alias {holder_aid} \
    --said {ipex_said} \
    --time {time}

pr_continue()
```

    Found grant EFO_4ByP6ShVL8Ug3KpZ6QRfeajBIn4ovZQ8inVP81Cf for revocation


    Sending admit message to EDrgzJ9CTI__UOzLxSQEjRcVn-WdCg0vr7H08rS8LDpF


    ... admit message sent


    
      You can continue ✅  
    
    


The holder now sees the credential status as "Revoked" in their credential list shown by `kli vc list.`


```python
!kli vc list --name {holder_keystore_name} --passcode {holder_keystore_passcode} \
    --alias {holder_aid}
```

    Current received credentials for holder_aid (EF48bMpmEntCs7Dsa4ThI9ncQNpVk0RJcKxIhIOSEaUc):
    
    Credential #1: EKdFpsYHnxZiUiXefCuqKB0puQmfbRPUCJniDQ0uj9Gd
        Type: EventPass
        Status: Revoked ✘
        Issued by EDrgzJ9CTI__UOzLxSQEjRcVn-WdCg0vr7H08rS8LDpF
        Issued on 2025-07-18T00:18:34.227259+00:00


Now that this credential is revoked it can similarly be presented to the verifier from either the issuer or the holder so that the verifier can learn of the revocation state of the credential. This would be a push-style workflow.

Arguably a pull-style approach is better for verifiers where they query the issuer, or some other infrastructure, to learn of the revocation state of credentials, similar to checking certificate revocation lists ([CRLs](https://en.wikipedia.org/wiki/Certificate_revocation_list)) in the x509 TLS certificate model. Using **observer** infrastructure is the best way to accomplish pull-style querying for credential state. 

As of the writing of this training the only functional observer implementation is combined with witnesses as describe above in the note to the [Sharing the revoked credential status with the Holder](#Sharing-the-revoked-credential-status-with-the-Holder.) section.

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
    <li>The Issuer then presented via IPEX Grant the revoked credential to the Holder.</li>    
    <li>The Holder then received the revoked credential via IPEX Admit.</li>
</ul>
</li>
</ol>
Observers were mentioned as pull-style infrastructure for verifiers, or anyone else, to learn of credential revocation state.
<br/><br/>
This completes the basic lifecycle demonstration: issuance (previous notebook), presentation, and revocation, all handled securely using KERI identities and the IPEX protocol.
</div>
