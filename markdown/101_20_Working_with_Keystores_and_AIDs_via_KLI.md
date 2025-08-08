# KLI Operations: Managing Keystores and Identifiers

<div class="alert alert-primary">
  <b>🎯 OBJECTIVE</b><hr>
    Demonstrate how to create a KERI keystore and then manage identifiers within it using the <code>kli init</code>, <code>kli incept</code>, and <code>kli list</code> commands.
</div>

## Initializing Keystores

Before you can create identifiers or perform many other actions with KLI, you need a keystore. The keystore is an encrypted data store that holds the keys for your identifiers. To initialize a keystore, you give it a name, protect it with a passcode, and provide a salt for generating the keys.

The command to do this is `kli init`. Here's an example:


<div class="alert alert-info">
  <b>💡 TIP</b><hr>
    <li>If you run <code>clear_keri()</code>, the keystore directories are deleted.</li>  
    <li>This function is provided as a utility to clean your data and re-run the notebooks.</li>
    <li>It will be called at the beginning of each notebook.</li>
</div>


```python
# Imports and Utility functions
from scripts.utils import clear_keri
clear_keri()
```

    Proceeding with deletion of '/usr/local/var/keri/' without confirmation.
    ⚠️ Path not found: /usr/local/var/keri/. Nothing to remove.



```python
# Choose a name for your keystore
keystore_name="my-first-key-store"
# Use a strong, randomly generated passcode (using a predefined one here, but can be created with 'kli passcode generate')
keystore_passcode="xSLg286d4iWiRg2mzGYca"
# Use a random salt (using a predefined one here, but can be created with 'kli salt')
keystore_salt="0ABeuT2dErMrqFE5Dmrnc2Bq"

!kli init --name {keystore_name} \
    --passcode {keystore_passcode} \
    --salt {keystore_salt}
```

    KERI Keystore created at: /usr/local/var/keri/ks/my-first-key-store
    KERI Database created at: /usr/local/var/keri/db/my-first-key-store
    KERI Credential Store created at: /usr/local/var/keri/reg/my-first-key-store
    	aeid: BD-1udeJaXFzKbSUFb6nhmndaLlMj-pdlNvNoN562h3z


The command sets up the necessary file structures for your keystore, so once executed, it's ready for you to create and manage Identifiers within it.

![](images/empty-keystore.png)

<div class="alert alert-info">
  <b>ℹ️ NOTE</b><hr>
<ul>
    <li>In the example, predefined <code>--passcode</code> and <code>--salt</code> values are used for convenience, but randomly generated values can be obtained using the <code>kli passcode generate</code> and <code>kli salt</code>
    <li>As mentioned earlier, the passcode is used for encryption of the keystore
    <li>The salt value is used as input (along with other context including the keystore's aeid) to deterministically generate all key-pairs belonging to an identifier. In these examples, you'll see many public keys and derivations of those (such as an AID's prefix), that are dependent on the salt value.
    <li>You can initialize multiple keystores as long as they have different names. 
</ul>
</div>

## Creating Identifiers (Inception)

Now that your keystore is set, you can create your first identifier (AID) within it using the `kli incept` command. You'll need to provide: 
- `--name` and `--passcode`: Think of it as the keystore access credentials `keystore_name` and `keystore_passcode`
- `--alias`: It will be difficult to recall an AID by its value. A human-readable `alias` is assigned using this parameter 
- `--icount` and `--isith`: the number of signing keys and the signing threshold, respectively. 
- Other parameters such as `--ncount`, `--nsith`, and `--toad` will be explained later. 

Executing `kli incept` will create the AID and output the prefix. This also means that the command will add the first event to the AID KEL, the inception event.

Proceed and create your first AID:
 


```python
# Choose a human-readable alias for your identifier within this keystore
aid_alias = "my-first-aid"

# Create (incept) the identifier
!kli incept --name {keystore_name} \
    --passcode {keystore_passcode} \
    --alias {aid_alias} \
    --icount 1 \
    --isith 1 \
    --ncount 0 \
    --nsith 0 \
    --toad 0
```

    Prefix  BHt9Kw8oUgfB2kiyoj65B2VE5fZLr87S5MJP3l4JeRwC
    	Public key 1:  BHt9Kw8oUgfB2kiyoj65B2VE5fZLr87S5MJP3l4JeRwC
    


![](images/incepted-keystore.png)

## Understanding Prefixes

The `kli incept` command generated an AID, which is represented by a unique string, e.g., `BHt9Kw8oUgfB2kiyoj65B2VE5fZLr87S5MJP3l4JeRwC`, known as the Prefix. While closely related, they represent different aspects of the identifier:

- AID: This is the formal concept of the self-governing identifier, representing the entity and its control. An entity may have multiple AIDs.
- Prefix: This is the practical, usable string representation of the AID. It's derived directly from the AID's initial cryptographic keys and is constructed by combining:
    - A Derivation Code: Indicates the cryptographic suite (key type, signature algorithm, hashing algorithm) used.
    - The Encoded Public Key: A string derived from the public portions of the initially generated key pairs associated with the AID.

**Prefix Self-Certification:**  
KERI AIDs are [self-certifying](https://trustoverip.github.io/tswg-keri-specification/#self-certifying-identifier-scid) in the sense that an AID does not rely on a trusted entity and instead relies only on its public keys to provide verifiability for signed statements made by the controller of an AID. This self-certifying quality holds throughout the AID's lifecycle, from inception to all future events, such as rotations.

This works because:
1. The identifier's prefix is derived from the set of public keys that are included in the inception event. The prefix is the self addressing identifier (SAID), a kind of digest, of the inception event. This provides a strong cryptographic binding between the AID prefix and the keys used to generate the inception event.
2. As validated rotation events occur, the AID's KEL is appended, which changes its effective Key-State. Key-State is a set of data that is time-dependent and includes the valid public signing keys and related data at a given point in time. The Key-State at a given point in time is derived from the KEL.
3. Given any signed statement made by the AID controller, the set of public keys and related data from the Key-State as of the time of that signed statement is sufficient to verify its authenticity.

Because of this relationship between keypairs, the inception event, and the key event log, anyone who has the prefix and the KEL can cryptographically verify signatures created by a given AID with the matching private keys (i.e., by the AID's controller) from any given point in the history of a KEL. This verifiability establishes authenticity for all actions taken by an AID without needing to check with outside authorities or registries, meaning they are self-certifying. 

### Security precaution for live transactions

**Keep in mind, as a security precaution**, signature verification with a prefix and a KEL is most securely done with the most recent keys that are currently authorized for the AID, as in the latest key-state (i.e., set of keys given the inception and all rotations). Key rotation changes the authorized keys, requiring reference to the AID's KEL for up-to-date verification. Historical signatures may still be verified, yet to ensure proper security during a live transaction the latest controlling keypairs (pubic portions) should always be used for signature verification. 

This means signatures from old keypairs, during a live transaction, should always be rejected when verifying signatures of an in-progress transaction. Such an approach is appropriate because there is no way to know if an attacker has compromised old keypairs and is using old keys to sign the new transaction events. To adopt the highest security posture then usage of the latest keypairs according to the KEL should **always** be required.

<div class="alert alert-prymary">
  <b>📝 SUMMARY</b><hr>
    <li>The AID is the secure, self-managed identifier</li>
    <li>The prefix is the actual text string you use to represent that AID, whose structure makes the AID's self-certifying property work</li>
    <li>The alias (<code>my-first-aid</code> in our example) is just a <b>local</b> nickname within your keystore to easily refer to the prefix</li>
    <li>The terms AID, identifier, prefix, and alias tend to be used interchangeably</li>
</div>

<div class="alert alert-info">
  <b>ℹ️ NOTE</b><hr>
    As you may have figured out, most of the <code>kli</code> commands require a keystore. Assume from now on that <code>--name</code> and <code>--passcode</code> refer to the keystore access.  
</div>

## Displaying Identifier Status
You can check the status of the identifier you just created using `kli status` and its `alias`. This command will show details about the AID's current state, including its Alias, prefix, sequence number, public keys, and additional information. More details on what all this data means will be explained later


```python
# Check the status of the AID using its alias
!kli status --name {keystore_name} \
    --passcode {keystore_passcode} \
    --alias {aid_alias}
```

    Alias: 	my-first-aid
    Identifier: BHt9Kw8oUgfB2kiyoj65B2VE5fZLr87S5MJP3l4JeRwC
    Seq No:	0
    
    Witnesses:
    Count:		0
    Receipts:	0
    Threshold:	0
    
    Public Keys:	
    	1. BHt9Kw8oUgfB2kiyoj65B2VE5fZLr87S5MJP3l4JeRwC
    


## Displaying Key Event Logs (KELs)
You can use `kli status` with the `--verbose` parameter to show the key event log.


```python
!kli status --name {keystore_name} \
    --passcode {keystore_passcode} \
    --alias {aid_alias} \
    --verbose
```

    Alias: 	my-first-aid
    Identifier: BHt9Kw8oUgfB2kiyoj65B2VE5fZLr87S5MJP3l4JeRwC
    Seq No:	0
    
    Witnesses:
    Count:		0
    Receipts:	0
    Threshold:	0
    
    Public Keys:	
    	1. BHt9Kw8oUgfB2kiyoj65B2VE5fZLr87S5MJP3l4JeRwC
    
    
    Witnesses:	
    
    {
     "v": "KERI10JSON0000fd_",
     "t": "icp",
     "d": "EG23dnLAUA4ywPcu2qbokplb2cb1XlIOw24iIKYtR3v4",
     "i": "BHt9Kw8oUgfB2kiyoj65B2VE5fZLr87S5MJP3l4JeRwC",
     "s": "0",
     "kt": "1",
     "k": [
      "BHt9Kw8oUgfB2kiyoj65B2VE5fZLr87S5MJP3l4JeRwC"
     ],
     "nt": "0",
     "n": [],
     "bt": "0",
     "b": [],
     "c": [],
     "a": []
    }
    


Here are some descriptions of the KEL fields (see the [spec](https://trustoverip.github.io/tswg-keri-specification/#keri-data-structures-and-labels)):
- `v`: Version String
- `t`: Message type (`icp` means inception)
- `i`: AID Prefix that created the event ("issuer" of the event)
- `s`: sequence number of the event, always zero for the inception event since it is the first event
- `kt`: Keys Signing Threshold (the `isith` value used in `kli inception`)
- `k`: List of public keys that are Signing Keys (You get as many keys as defined by the `icount` value used in `kli inception`)
- `nt`: Next Signing Threshold (rotation signing threshold), zero in this case. This will be explored in an upcoming lesson.
- `n`: List of public key **digests** that are rotation keys authorized to perform rotations. Since there are no rotation keys specified here then this identifier may never rotate and may be considered to have rotated to "null" on its first event, meaning it can only ever be used for signing.
- `bt`: Backer (witness) Threshold - the number of backer (witness) receipts the event must have in order to be considered accepted by the controller and valid.
- `b`: Backer (witness) list - the AID prefixes of the backers (witnesses) that are authorized by the controller to generate witness receipts for this event and any after it, until changed by a rotation event.
- `c`: configuration traits - not used here
- `a`: anchors (seals) - list of field maps used to anchor data in a key event

<div class="alert alert-info">
  <b>📚 REFERENCE</b><hr>
    To see the full details of the key event fields, refer to <a href="https://trustoverip.github.io/tswg-keri-specification/#keri-data-structures-and-labels" target="_blank">KERI Data Structures and Labels</a> 
</div>

## Listing Identifiers in a Keystore

You can also list all the identifiers managed within this keystore. To illustrate this, let's create an additional Identifier


```python
!kli incept --name {keystore_name} \
    --passcode {keystore_passcode} \
    --alias "my-second-aid" \
    --icount 1 \
    --isith 1 \
    --ncount 0 \
    --nsith 0 \
    --toad 0
```

    Prefix  BBuVNJvbJD2WNduQ0JUGRVGb6uKYrF5bO5T4gdGt_ezO
    	Public key 1:  BBuVNJvbJD2WNduQ0JUGRVGb6uKYrF5bO5T4gdGt_ezO
    


Now use `kli list` to list all the identifiers managed by the keystore


```python
# List all Identifiers in the keystore
!kli list --name {keystore_name} --passcode {keystore_passcode}
```

    my-second-aid (BBuVNJvbJD2WNduQ0JUGRVGb6uKYrF5bO5T4gdGt_ezO)
    my-first-aid (BHt9Kw8oUgfB2kiyoj65B2VE5fZLr87S5MJP3l4JeRwC)


![](images/two-aids.png)

<div class="alert alert-primary">
  <b>📝 SUMMARY</b><hr>
<p>The basics of managing KERI identifiers using the KLI:</p>
<ul>
    <li><strong>Keystore Creation:</strong> A keystore, essential for managing identifiers, is created using <code>kli init</code>, requiring a name, passcode, and salt</li>
    <li><strong>Identifier Inception:</strong> New identifiers (AIDs) are created within a named keystore using <code>kli incept</code>, which also starts their Key Event Log (KEL)</li>
    <li><strong>Key Event Log (KEL):</strong> The KEL tracks an AID's history with fields like version (<code>v</code>), event type (<code>t</code>), identifier prefix (<code>i</code>), signing threshold (<code>kt</code>), and keys (<code>k</code>)</li>
    <li><strong>Displaying identifiers:</strong><code>kli status</code> displays an AID information and the KEL </li>
    <li><strong>Listing Identifiers:</strong> The <code>kli list</code> command displays all identifiers managed within a specific keystore</li>
</ul>
</div>

[<- Prev (Controllers and Identifiers)](101_15_Controllers_and_Identifiers.ipynb) | [Next (Signatures) ->](101_25_Signatures.ipynb)
