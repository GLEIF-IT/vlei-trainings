# KLI Operations: Connecting Controllers

<div class="alert alert-primary">
  <b>🎯 OBJECTIVE</b><hr>
Explain how to establish a secure, mutually authenticated connection between two KERI controllers using Out-of-Band Introductions (OOBIs) and challenge/response protocol to enhance trust.
</div>

## Initial Controller Setup

So far, we have only done basic operations with AIDs in an isolated way. That has limited use in practical applications; after all, establishing identity verification only becomes meaningful when interacting with others. In KERI, this interaction starts with controllers needing to discover and securely connect with each other.

In our context, this means we need to establish connections between controllers. We've already seen a similar process when pairing transferable AIDs with witnesses. Now, let's explore how two controllers (a and b) can connect using Out-of-Band Introductions (OOBIs) and enhance trust with **challenge/response**.

### Keystore Initialization
For the example, you need to use two different keystores called `keystore-a` and `keystore-b`, both initialized using the `keystore_init_config.json` configuration. This means they will both load the same initial set of three witness contacts, providing endpoints where each controller's KEL (and thus key state) can be published and retrieved.



```python
# Imports and Utility functions
from scripts.utils import clear_keri
clear_keri()

keystore_a_name="keystore_a"
keystore_a_passcode="xSLg286d4iWiRg2mzGYca"
salt_a="0ABeuT2dErMrqFE5Dmrnc2Bq"

!kli init --name {keystore_a_name} --passcode {keystore_a_passcode} --salt {salt_a} \
    --config-dir ./config \
    --config-file keystore_init_config.json

```

    Proceeding with deletion of '/usr/local/var/keri/' without confirmation.
    ✅ Successfully removed: /usr/local/var/keri/


    KERI Keystore created at: /usr/local/var/keri/ks/keystore_a
    KERI Database created at: /usr/local/var/keri/db/keystore_a
    KERI Credential Store created at: /usr/local/var/keri/reg/keystore_a
    	aeid: BD-1udeJaXFzKbSUFb6nhmndaLlMj-pdlNvNoN562h3z
    
    Loading 3 OOBIs...


    http://witness-demo:5642/oobi/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha/controller?name=Wan&tag=witness succeeded
    http://witness-demo:5643/oobi/BLskRTInXnMxWaGqcpSyMgo0nYbalW99cGZESrz3zapM/controller?name=Wes&tag=witness succeeded
    http://witness-demo:5644/oobi/BIKKuvBwpmDVA4Ds-EpL5bt9OqPzWPja2LigFYZN2YfX/controller?name=Wil&tag=witness succeeded



```python
keystore_b_name="keystore_b"

keystore_b_passcode="LLF1NYii5L7jTMvw4gDar"

salt_b="0ADzG7sbUyw-MYIoUyQe5wxB"

!kli init --name {keystore_b_name} --passcode {keystore_b_passcode} --salt {salt_b} \
    --config-dir ./config \
    --config-file keystore_init_config.json
```

    KERI Keystore created at: /usr/local/var/keri/ks/keystore_b
    KERI Database created at: /usr/local/var/keri/db/keystore_b
    KERI Credential Store created at: /usr/local/var/keri/reg/keystore_b
    	aeid: BPJYwdaLcdcbB6pTpRal-IhbV_Vb8bD6vq_qiMFojHNG
    
    Loading 3 OOBIs...


    http://witness-demo:5642/oobi/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha/controller?name=Wan&tag=witness succeeded
    http://witness-demo:5643/oobi/BLskRTInXnMxWaGqcpSyMgo0nYbalW99cGZESrz3zapM/controller?name=Wes&tag=witness succeeded
    http://witness-demo:5644/oobi/BIKKuvBwpmDVA4Ds-EpL5bt9OqPzWPja2LigFYZN2YfX/controller?name=Wil&tag=witness succeeded


### Identifier Inception
Now, you need AIDs to represent the controllers. Create one transferable AID in each keystore, aliased `aid_a` and `aid_b` respectively. Use the aid_inception_config.json file, which specifies the initial set of witnesses for both AIDs. (While they share witnesses here, controllers could use different witness sets).


```python
aid_a = "aid_a"

!kli incept --name {keystore_a_name} \
    --passcode {keystore_a_passcode} \
    --alias {aid_a} \
    --file ./config/aid_inception_config.json

```

    Waiting for witness receipts...


    Prefix  EML-Hx1ivj6CSkPTM80xCqFmabG9l9ZrVxPe9omW2cWl
    	Public key 1:  DDiMxDbmRMjC0mDSkzlwEbYveGozxRXXIsFUo3ixQaU4
    



```python
aid_b = "aid_b"

!kli incept --name {keystore_b_name} \
    --passcode {keystore_b_passcode} \
    --alias {aid_b} \
    --file ./config/aid_inception_config.json
```

    Waiting for witness receipts...


    Prefix  EAJR7SlFds3hQpH8kj8HySFRdhW6DcC7m9KdELNJIUma
    	Public key 1:  DHEa1ktRvZUjdRitkgJ5u3tNjitiw9Ba0cgz-fMhTS4c
    


## OOBI Exchange for Discovery

With your AIDs established, you need a way for them to find each other. This is where Out-of-Band Introductions (OOBIs) come in. You have used OOBIs before; to recapitulate, an OOBI is a specialized URL associated with an AID and how to reach one of its endpoints (like a witness). 


### Generating OOBI URLs

Use the `kli oobi generate` command to create OOBIs for your AIDs. Specify which AID (`--alias`) within which keystore (`--name`) should generate the OOBI, and importantly, the role associated with the endpoint included in the OOBI URL. Here, `--role witness` means the OOBI URL will point to one of the AID's designated witnesses, providing an indirect way to fetch the AID's KEL.


```python
!kli oobi generate --name {keystore_a_name} \
    --passcode {keystore_a_passcode} \
    --alias {aid_a} \
    --role witness
```

    http://witness-demo:5642/oobi/EML-Hx1ivj6CSkPTM80xCqFmabG9l9ZrVxPe9omW2cWl/witness
    http://witness-demo:5643/oobi/EML-Hx1ivj6CSkPTM80xCqFmabG9l9ZrVxPe9omW2cWl/witness



```python
!kli oobi generate --name {keystore_b_name} \
    --passcode {keystore_b_passcode} \
    --alias {aid_b} \
    --role witness
```

    http://witness-demo:5642/oobi/EAJR7SlFds3hQpH8kj8HySFRdhW6DcC7m9KdELNJIUma/witness
    http://witness-demo:5643/oobi/EAJR7SlFds3hQpH8kj8HySFRdhW6DcC7m9KdELNJIUma/witness


Note that the command returns multiple OOBIs, one for each witness endpoint configured for the AID. Any of these can be used to initiate contact. For simplicity, we'll capture the first OOBI URL generated for each AID into the variables `oobi_a` and `oobi_b`.


```python
# Imports and Utility functions
from scripts.utils import exec

command_a = f"kli oobi generate --name {keystore_a_name} --alias {aid_a} --passcode {keystore_a_passcode} --role witness"
oobi_a = exec(command_a)

command_b = f"kli oobi generate --name {keystore_b_name} --alias {aid_b} --passcode {keystore_b_passcode} --role witness"
oobi_b = exec(command_b)
```

### Resolving OOBI URLs 

Now that `aid_a` and `aid_b` each have an OOBI, they need to resolve them. The `kli oobi resolve` command handles this.

When `keystore_a` resolves `oobi_b`, its uses the URL to contact the specified witness. The witness provides the KEL for `aid_b`. `keystore_a` then verifies the entire KEL cryptographically, ensuring its integrity and confirming the public keys associated with `aid_b`. A human-readable alias `--oobi-alias` is assigned for easy reference later. The same process happens when `keystore_b` resolves `oobi_a`.



```python
!kli oobi resolve --name {keystore_a_name} \
    --passcode {keystore_a_passcode} \
    --oobi-alias {aid_b} \
    --oobi {oobi_b}
```

    http://witness-demo:5642/oobi/EAJR7SlFds3hQpH8kj8HySFRdhW6DcC7m9KdELNJIUma/witness resolved



```python
!kli oobi resolve --name {keystore_b_name} \
    --passcode {keystore_b_passcode} \
    --oobi-alias {aid_a} \
    --oobi {oobi_a}
```

    http://witness-demo:5642/oobi/EML-Hx1ivj6CSkPTM80xCqFmabG9l9ZrVxPe9omW2cWl/witness resolved


### Listing contacts 

After successful resolution, the other AID appears in the keystore's contact list. You can verify this using `kli contacts list`. You'll see the newly resolved AID alongside the witnesses loaded during the keystore initialization. This confirms that the keystore now knows the other AID's identifier prefix and has verified its KEL.


```python
!kli contacts list --name {keystore_a_name} \
    --passcode {keystore_a_passcode}
```

    {
      "id": "BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha",
      "alias": "Wan",
      "oobi": "http://witness-demo:5642/oobi/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha/controller?name=Wan&tag=witness",
      "challenges": [],
      "wellKnowns": []
    }
    {
      "id": "BIKKuvBwpmDVA4Ds-EpL5bt9OqPzWPja2LigFYZN2YfX",
      "alias": "Wil",
      "oobi": "http://witness-demo:5644/oobi/BIKKuvBwpmDVA4Ds-EpL5bt9OqPzWPja2LigFYZN2YfX/controller?name=Wil&tag=witness",
      "challenges": [],
      "wellKnowns": []
    }
    {
      "id": "BLskRTInXnMxWaGqcpSyMgo0nYbalW99cGZESrz3zapM",
      "alias": "Wes",
      "oobi": "http://witness-demo:5643/oobi/BLskRTInXnMxWaGqcpSyMgo0nYbalW99cGZESrz3zapM/controller?name=Wes&tag=witness",
      "challenges": [],
      "wellKnowns": []
    }
    {
      "id": "EAJR7SlFds3hQpH8kj8HySFRdhW6DcC7m9KdELNJIUma",
      "alias": "aid_b",
      "oobi": "http://witness-demo:5642/oobi/EAJR7SlFds3hQpH8kj8HySFRdhW6DcC7m9KdELNJIUma/witness",
      "challenges": [],
      "wellKnowns": []
    }


## Authenticating Control with Challenge-Response

Resolving an OOBI and verifying the KEL is a crucial first step. It confirms that the AID exists and that its key state history is cryptographically sound. However, it doesn't definitively prove that the entity you just connected with over the network is the legitimate controller you intend to interact with. You've verified the identifier, but not necessarily the authenticity of the current operator at the other end of the connection. Network connections can be vulnerable to Man-in-the-Middle (MITM) attacks or other deceptions.

This is where the challenge-response mechanism becomes essential. It provides a way to verify that the controller on the other side genuinely possesses the private keys corresponding to the public keys in the KEL you just verified. This adds a critical layer of authentication on top of the OOBI discovery process.

This is how it works:

One party (the challenger, say `aid_b`) generates a random challenge phrase.
The challenger sends this phrase to the other party (`aid_a`) through an Out-of-Band (OOB) channel. This means using a communication method different from the KERI network connection (e.g., a video call chat, phone call, secure email) to prevent an attacker on the  KERI network channel from intercepting or modifying the challenge. Using the same channel for both the challenge words and the response defeats the purpose of protecting against MITM attacks. 

The challenged party (`aid_a`) receives the phrase and uses their current private key to sign it.
`aid_a` sends the original phrase and the resulting signature back to `aid_b` over the KERI connection.
`aid_b` verifies two things: 
- that the returned phrase matches the one originally sent, and 
-  that the signature correctly verifies against the public key associated with `aid_a` in its verified KEL.

If the verification succeeds, `aid_b` now has strong assurance that they are communicating with the entity that truly controls aid_a's private keys. This process is typically done mutually, with `aid_a` also challenging `aid_b`.

You can generate the challenge phrases using `kli challenge generate`. The code below will store them in variables for later use in the commands.


```python
!kli challenge generate --out string

phrase_a = exec("kli challenge generate --out string")

phrase_b = exec("kli challenge generate --out string")
```

    distance luxury pottery shrimp gravity winner warrior empty chef coach husband cactus


Now, simulate the OOB exchange: `aid_b` sends `phrase_b` to `aid_a`, and `aid_a` sends `phrase_a` to `aid_b`. Each party then uses `kli challenge respond` to sign the phrase they received and `kli challenge verify` to check the response from the other party.



```python
print(phrase_a)

!kli challenge respond --name {keystore_b_name} \
    --passcode {keystore_b_passcode} \
    --alias {aid_b} \
    --words "{phrase_a}" \
    --recipient {aid_a}
```

    slide ostrich gas flat flash town dust treat memory funny recipe lake



```python
!kli challenge verify --name {keystore_a_name}  \
    --passcode {keystore_a_passcode} \
    --alias {aid_a} \
    --words "{phrase_a}" \
    --signer {aid_b}
```

    Checking mailboxes for any challenge responses.

    .
    
    Signer aid_b successfully responded to challenge words: '['slide', 'ostrich', 'gas', 'flat', 'flash', 'town', 'dust', 'treat', 'memory', 'funny', 'recipe', 'lake']'
    



```python
print(phrase_b)

!kli challenge respond --name {keystore_a_name} \
    --passcode {keystore_a_passcode} \
    --alias {aid_a} \
    --words "{phrase_b}" \
    --recipient {aid_b}
```

    page game hamster leopard seat lounge pudding young party wing mother dust



```python
!kli challenge verify --name {keystore_b_name} \
    --passcode {keystore_b_passcode} \
    --alias {aid_b} \
    --words "{phrase_b}" \
    --signer {aid_a}
```

    Checking mailboxes for any challenge responses.

    .
    
    Signer aid_a successfully responded to challenge words: '['page', 'game', 'hamster', 'leopard', 'seat', 'lounge', 'pudding', 'young', 'party', 'wing', 'mother', 'dust']'
    


Successful verification on both sides establishes mutual authenticated control, significantly increasing the trust level between the two controllers beyond the initial OOBI resolution. They now know they are interacting with the legitimate key holders for each respective AID.

<div class="alert alert-primary">
  <b>📝 SUMMARY</b><hr>
After initial discovery (often via OOBIs), KERI controllers can enhance trust by verifying active control of private keys using a challenge-response protocol. This involves each controller generating a unique challenge phrase (kli challenge generate). One controller (aid_a) then responds to the other's challenge (phrase_b) by signing it (kli challenge respond), and the second controller (aid_b) verifies this response (kli challenge verify). This process is repeated reciprocally. Successful verification by both parties confirms they are interacting with the legitimate key holders for each AID.
</div>
