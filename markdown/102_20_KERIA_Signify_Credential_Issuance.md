# Signify-ts: ACDC Credential Issuance with IPEX

<div class="alert alert-primary">
<b>🎯 OBJECTIVE</b><hr>
Demonstrate the process of issuing an ACDC (Authentic Chained Data Container) from an Issuer to a Holder using the Issuance and Presentation Exchange (IPEX) protocol with the Signify-ts library.
</div>

<div class="alert alert-info">
<b>ℹ️ NOTE</b><hr>
This section utilizes utility functions (from <code>./scripts_ts/utils.ts</code>) to quickly establish the necessary preconditions for credential issuance. The detailed steps for client initialization, AID creation, end role assignment, and OOBI resolution were covered in the "KERIA-Signify Connecting Controllers" notebook. Here, we provide a high-level recap of what these utility functions accomplish.
</div>

## Prerequisites: Client and AID Setup

The setup process, streamlined by the utility functions, performs the following key actions:

* **Signify Library Initialization**: Ensures the underlying cryptographic components of Signify-ts are ready.
* **Client Initialization & Connection**: Three `SignifyClient` instances are created—one each for an Issuer, a Holder, and a Verifier. Each client is bootstrapped and connected to its KERIA agent.
* **AID Creation**: Each client (Issuer, Holder, Verifier) creates a primary AID using default arguments.
* **End Role Assignment**: An `agent` end role is assigned to each client's KERIA Agent AID.
* **OOBI Generation and Resolution (Client-to-Client)**:
    * OOBIs are generated for the Issuer, Holder, and Verifier AIDs, specifically for the `'agent'` role.
    * Communication channels are established by resolving these OOBIs:
        * Issuer's client resolves the Holder's OOBI.
        * Holder's client resolves the Issuer's OOBI.
        * Verifier's client resolves the Holder's OOBI.
        * Holder's client resolves the Verifier's OOBI.
* **Schema OOBI Resolution**: The Issuer, Holder, and Verifier clients all resolve the OOBI for the "EventPass" schema (SAID: `EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK`). This schema is hosted on the schema server (vLEI-Server in this context). Resolving the schema OOBI ensures all parties have the correct and verifiable schema definition necessary to understand and validate the credential.

The code block below executes this setup.


```typescript
import { randomPasscode, Serder} from 'npm:signify-ts';
import { initializeSignify, 
         initializeAndConnectClient,
         createNewAID,
         addEndRoleForAID,
         generateOOBI,
         resolveOOBI,
         createTimestamp,
         DEFAULT_IDENTIFIER_ARGS,
         DEFAULT_TIMEOUT_MS,
         DEFAULT_DELAY_MS,
         DEFAULT_RETRIES,
         ROLE_AGENT,
         IPEX_GRANT_ROUTE,
         IPEX_ADMIT_ROUTE,
         IPEX_APPLY_ROUTE,
         IPEX_OFFER_ROUTE,
         SCHEMA_SERVER_HOST
       } from './scripts_ts/utils.ts';

// Clients setup
// Initialize Issuer, Holder and Verifier CLients, Create AIDs for each one, assign 'agent' role to the AIDs
// generate and resolve OOBIs 

// Issuer Client
const issuerBran = randomPasscode()
const issuerAidAlias = 'issuerAid'
const { client: issuerClient } = await initializeAndConnectClient(issuerBran)
const { aid: issuerAid} = await createNewAID(issuerClient, issuerAidAlias, DEFAULT_IDENTIFIER_ARGS);
await addEndRoleForAID(issuerClient, issuerAidAlias, ROLE_AGENT);
const issuerOOBI = await generateOOBI(issuerClient, issuerAidAlias, ROLE_AGENT);

// Holder Client
const holderBran = randomPasscode()
const holderAidAlias = 'holderAid'
const { client: holderClient } = await initializeAndConnectClient(holderBran)
const { aid: holderAid} = await createNewAID(holderClient, holderAidAlias, DEFAULT_IDENTIFIER_ARGS);
await addEndRoleForAID(holderClient, holderAidAlias, ROLE_AGENT);
const holderOOBI = await generateOOBI(holderClient, holderAidAlias, ROLE_AGENT);

// Verifier Client
const verifierBran = randomPasscode()
const verifierAidAlias = 'verifierAid'
const { client: verifierClient } = await initializeAndConnectClient(verifierBran)
const { aid: verifierAid} = await createNewAID(verifierClient, verifierAidAlias, DEFAULT_IDENTIFIER_ARGS);
await addEndRoleForAID(verifierClient, verifierAidAlias, ROLE_AGENT);
const verifierOOBI = await generateOOBI(verifierClient, verifierAidAlias, ROLE_AGENT);

// Clients OOBI Resolution
// Resolve OOBIs to establish connections Issuer-Holder, Holder-Verifier
const issuerContactAlias = 'issuerContact';
const holderContactAlias = 'holderContact';
const verifierContactAlias = 'verifierContact';

await resolveOOBI(issuerClient, holderOOBI, holderContactAlias);
await resolveOOBI(holderClient, issuerOOBI, issuerContactAlias);
await resolveOOBI(verifierClient, holderOOBI, holderContactAlias);
await resolveOOBI(holderClient, verifierOOBI, verifierContactAlias);

// Schemas OOBI Resolution
// Resolve the Schemas from the Schema Server (VLEI-Server)
const schemaContactAlias = 'schemaContact';
const schemaSaid = 'EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK';
const schemaOOBI = `http://vlei-server:7723/oobi/${schemaSaid}`;

await resolveOOBI(issuerClient, schemaOOBI, schemaContactAlias);
await resolveOOBI(holderClient, schemaOOBI, schemaContactAlias);
await resolveOOBI(verifierClient, schemaOOBI, schemaContactAlias);

console.log("Client setup and OOBI resolutions complete.");
```

    Using Passcode (bran): CnWecw3c9lNoJGRW9wKsM


    Client boot process initiated with KERIA agent.


      Client AID Prefix:  EHtLfQtuv6rZFw-zyREaFC4bUTtjrLBIY1ncEgO-1awU


      Agent AID Prefix:   EIgRWGIJ1BzDDGdN_Q9CiB5eCk-hE2ZyW6aUZIznpvDW


    Initiating AID inception for alias: issuerAid


    Successfully created AID with prefix: EG1-XGIRXIc-EwmQI_VeGkWgtD9CfPVl4ofEBf6BA4Ak


    Assigning 'agent' role to KERIA Agent EIgRWGIJ1BzDDGdN_Q9CiB5eCk-hE2ZyW6aUZIznpvDW for AID alias issuerAid


    Successfully assigned 'agent' role for AID alias issuerAid.


    Generating OOBI for AID alias issuerAid with role agent


    Generated OOBI URL: http://keria:3902/oobi/EG1-XGIRXIc-EwmQI_VeGkWgtD9CfPVl4ofEBf6BA4Ak/agent/EIgRWGIJ1BzDDGdN_Q9CiB5eCk-hE2ZyW6aUZIznpvDW


    Using Passcode (bran): BZCm0D0prnW1nFoXo_n_a


    Client boot process initiated with KERIA agent.


      Client AID Prefix:  EDnlKtF7-GEb5aEWeo4FN8WxsI4Xn5f42A_nMlRKAnNw


      Agent AID Prefix:   EOjIY4Slxw38XvwNGFcYg9hmgaj0fmPzyEQc6hfZEM3B


    Initiating AID inception for alias: holderAid


    Successfully created AID with prefix: EDuMtFBduortAQvD2Ywsp_6sPHrlDQyKPshlsRTWV2xv


    Assigning 'agent' role to KERIA Agent EOjIY4Slxw38XvwNGFcYg9hmgaj0fmPzyEQc6hfZEM3B for AID alias holderAid


    Successfully assigned 'agent' role for AID alias holderAid.


    Generating OOBI for AID alias holderAid with role agent


    Generated OOBI URL: http://keria:3902/oobi/EDuMtFBduortAQvD2Ywsp_6sPHrlDQyKPshlsRTWV2xv/agent/EOjIY4Slxw38XvwNGFcYg9hmgaj0fmPzyEQc6hfZEM3B


    Using Passcode (bran): Di823IcRXD3pydDWPuXOp


    Client boot process initiated with KERIA agent.


      Client AID Prefix:  EKG9RhwweaFwMz5WNkC-zvUhi9G8cY5tfsTqr9-HT8ep


      Agent AID Prefix:   EHdg5Z7VGCtIFcbVkYnDsL4_8ygWJJ_TX0KP_bydfsQY


    Initiating AID inception for alias: verifierAid


    Successfully created AID with prefix: EBKTy4GFE2Ggv4gbVW8I9XHu_iTjvMdJ1omLphdsO5lQ


    Assigning 'agent' role to KERIA Agent EHdg5Z7VGCtIFcbVkYnDsL4_8ygWJJ_TX0KP_bydfsQY for AID alias verifierAid


    Successfully assigned 'agent' role for AID alias verifierAid.


    Generating OOBI for AID alias verifierAid with role agent


    Generated OOBI URL: http://keria:3902/oobi/EBKTy4GFE2Ggv4gbVW8I9XHu_iTjvMdJ1omLphdsO5lQ/agent/EHdg5Z7VGCtIFcbVkYnDsL4_8ygWJJ_TX0KP_bydfsQY


    Resolving OOBI URL: http://keria:3902/oobi/EDuMtFBduortAQvD2Ywsp_6sPHrlDQyKPshlsRTWV2xv/agent/EOjIY4Slxw38XvwNGFcYg9hmgaj0fmPzyEQc6hfZEM3B with alias holderContact


    Successfully resolved OOBI URL. Response: OK


    Contact "holderContact" (ID: undefined) added/updated.


    Resolving OOBI URL: http://keria:3902/oobi/EG1-XGIRXIc-EwmQI_VeGkWgtD9CfPVl4ofEBf6BA4Ak/agent/EIgRWGIJ1BzDDGdN_Q9CiB5eCk-hE2ZyW6aUZIznpvDW with alias issuerContact


    Successfully resolved OOBI URL. Response: OK


    Contact "issuerContact" (ID: undefined) added/updated.


    Resolving OOBI URL: http://keria:3902/oobi/EDuMtFBduortAQvD2Ywsp_6sPHrlDQyKPshlsRTWV2xv/agent/EOjIY4Slxw38XvwNGFcYg9hmgaj0fmPzyEQc6hfZEM3B with alias holderContact


    Successfully resolved OOBI URL. Response: OK


    Contact "holderContact" (ID: undefined) added/updated.


    Resolving OOBI URL: http://keria:3902/oobi/EBKTy4GFE2Ggv4gbVW8I9XHu_iTjvMdJ1omLphdsO5lQ/agent/EHdg5Z7VGCtIFcbVkYnDsL4_8ygWJJ_TX0KP_bydfsQY with alias verifierContact


    Successfully resolved OOBI URL. Response: OK


    Contact "verifierContact" (ID: undefined) added/updated.


    Resolving OOBI URL: http://vlei-server:7723/oobi/EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK with alias schemaContact


    Successfully resolved OOBI URL. Response: OK


    Contact "schemaContact" (ID: undefined) added/updated.


    Resolving OOBI URL: http://vlei-server:7723/oobi/EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK with alias schemaContact


    Successfully resolved OOBI URL. Response: OK


    Contact "schemaContact" (ID: undefined) added/updated.


    Resolving OOBI URL: http://vlei-server:7723/oobi/EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK with alias schemaContact


    Successfully resolved OOBI URL. Response: OK


    Contact "schemaContact" (ID: undefined) added/updated.


    Client setup and OOBI resolutions complete.


## Credential Issuance Workflow Steps

With the clients set up and connected, you can proceed with the credential issuance workflow. This involves the Issuer creating a credential and transferring it to the Holder using the IPEX protocol. Below are the code snippets you need to follow to do the issuance.

### Step 1: Create Issuer's Credential Registry

Before an Issuer can issue credentials, it needs a Credential Registry. In KERI, a Credential Registry is implemented using a **Transaction Event Log (TEL)**. This TEL is a secure, hash-linked log, managed by the Issuer's AID, specifically for tracking the lifecycle of credentials it issues—such as their issuance and revocation status. The registry itself is identified by a SAID derived from its inception event (`vcp` event type for registry inception). The TEL's history is anchored to the Issuer's Key Event Log, ensuring that all changes to the registry's state are cryptographically secured by the Issuer's controlling keys. This anchoring is achieved by including a digest of the TEL event in a KEL event.

Use the code below to let the Issuer client create this registry. A human-readable name (`issuerRegistryName`) is used to reference it within the client.


```typescript
//Create Issuer credential Registry
const issuerRegistryName = 'issuerRegistry' // Human readable identifier for the Registry

// Initiate registry creation
const createRegistryResult = await issuerClient
    .registries()
    .create({ name: issuerAidAlias, registryName: issuerRegistryName });

// Get the operation details
const createRegistryOperation = await createRegistryResult.op();

// Wait for the operation to complete
const createRegistryResponse = await issuerClient
    .operations()
    .wait(createRegistryOperation, AbortSignal.timeout(DEFAULT_TIMEOUT_MS));

// Clean up the operation from the agent's list
await issuerClient.operations().delete(createRegistryOperation.name);

console.log(`Registry '${issuerRegistryName}' created for Issuer AID ${issuerAid.i}.`);
console.log("Registry creation response:", JSON.stringify(createRegistryResponse.response, null, 2));

// Listing Registries to confirm creation and retrieve its SAID (regk)
const issuerRegistries = await issuerClient.registries().list(issuerAidAlias);
const issuerRegistry = issuerRegistries[0]
console.log(`Registry: Name='${issuerRegistry.name}', SAID (regk)='${issuerRegistry.regk}'`);
```

    Registry 'issuerRegistry' created for Issuer AID EG1-XGIRXIc-EwmQI_VeGkWgtD9CfPVl4ofEBf6BA4Ak.


    Registry creation response: {
      "anchor": {
        "i": "EFRsZKzhX16pRpGJR2PrY1Q3JQWU0JsA3_Sstc9cu-CK",
        "s": "0",
        "d": "EFRsZKzhX16pRpGJR2PrY1Q3JQWU0JsA3_Sstc9cu-CK"
      }
    }


    Registry: Name='issuerRegistry', SAID (regk)='EFRsZKzhX16pRpGJR2PrY1Q3JQWU0JsA3_Sstc9cu-CK'


### Step 2: Retrieve Schema Definition

The Issuer needs the definition of the schema against which they intend to issue a credential. Since the schema OOBI was resolved during the setup phase, the schema definition can now be retrieved from the KERIA agent's cache using its SAID. You will reuse the `EventPass` schema (SAID: `EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK`) from previous KLI examples.


```typescript
// Retrieve Schemas
const issuerSchema = await issuerClient.schemas().get(schemaSaid);
console.log(issuerSchema)
```

    {
      [32m"$id"[39m: [32m"EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK"[39m,
      [32m"$schema"[39m: [32m"http://json-schema.org/draft-07/schema#"[39m,
      title: [32m"EventPass"[39m,
      description: [32m"Event Pass Schema"[39m,
      type: [32m"object"[39m,
      credentialType: [32m"EventPassCred"[39m,
      version: [32m"1.0.0"[39m,
      properties: {
        v: { description: [32m"Credential Version String"[39m, type: [32m"string"[39m },
        d: { description: [32m"Credential SAID"[39m, type: [32m"string"[39m },
        u: { description: [32m"One time use nonce"[39m, type: [32m"string"[39m },
        i: { description: [32m"Issuer AID"[39m, type: [32m"string"[39m },
        ri: { description: [32m"Registry SAID"[39m, type: [32m"string"[39m },
        s: { description: [32m"Schema SAID"[39m, type: [32m"string"[39m },
        a: {
          oneOf: [
            { description: [32m"Attributes block SAID"[39m, type: [32m"string"[39m },
            {
              [32m"$id"[39m: [32m"ELppbffpWEM-uufl6qpVTcN6LoZS2A69UN4Ddrtr_JqE"[39m,
              description: [32m"Attributes block"[39m,
              type: [32m"object"[39m,
              properties: [36m[Object][39m,
              additionalProperties: [33mfalse[39m,
              required: [36m[Array][39m
            }
          ]
        }
      },
      additionalProperties: [33mfalse[39m,
      required: [ [32m"v"[39m, [32m"d"[39m, [32m"i"[39m, [32m"ri"[39m, [32m"s"[39m, [32m"a"[39m ]
    }


### Step 3: Issue the ACDC

Now the Issuer creates the actual ACDC. This involves:

1. Defining the `credentialClaims` – the specific attribute values for this instance of the `EventPass` credential.
2. Calling `issuerClient.credentials().issue()`. This method takes the Issuer's AID alias and an object specifying:
    - `ri`: The SAID of the Credential Registry (`issuerRegistry.regk`) where this credential's issuance will be recorded.
    - `s`: The SAID of the schema (`schemaSaid`) this credential adheres to.
    - `a`: An attributes block containing:
      - `i`: The AID of the Issuee (the Holder, holderAid.i).
      - The actual `credentialClaims`.

This `issue` command creates the ACDC locally within the Issuer's client and records an issuance event (e.g., `iss`) in the specified registry's TEL. The SAID of the newly created credential is then extracted from the response.

Use the code below to perform these actions.


```typescript
// Issue Credential

const credentialClaims = {
    "eventName":"GLEIF Summit",
    "accessLevel":"staff",
    "validDate":"2026-10-01"
}

const issueResult = await issuerClient
    .credentials()
    .issue(
        issuerAidAlias,
        {
            ri: issuerRegistry.regk, //Registry Identifier (not the alias)
            s: schemaSaid,           // Schema identifier
            a: {                     // Attributes block
                i: holderAid.i,      // Isuue or credential subject 
                ...credentialClaims  // The actual claims data                 
            }
        });

// Issuance is an asynchronous operation.
const issueOperation = await issueResult.op; //In this case is .op instead of .op() (Inconsistency in the sdk)

// Wait for the issuance operation to complete.
const issueResponse = await issuerClient
    .operations()
    .wait(issueOperation, AbortSignal.timeout(DEFAULT_TIMEOUT_MS));

// Clean up the operation.
await issuerClient.operations().delete(issueOperation.name);

// Extract the SAID of the newly created credential from the response.
// This SAID uniquely identifies this specific ACDC instance.
const credentialSaid = issueResponse.response.ced.d

// Display the issued credential from the Issuer's perspective.
const issuerCredential = await issuerClient.credentials().get(credentialSaid);
console.log(issuerCredential)
```

    {
      sad: {
        v: [32m"ACDC10JSON0001c4_"[39m,
        d: [32m"ECrfo90QVwsAjSg4D5VpaNDW0ggOndsFHjKyymjhJ6ZO"[39m,
        i: [32m"EG1-XGIRXIc-EwmQI_VeGkWgtD9CfPVl4ofEBf6BA4Ak"[39m,
        ri: [32m"EFRsZKzhX16pRpGJR2PrY1Q3JQWU0JsA3_Sstc9cu-CK"[39m,
        s: [32m"EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK"[39m,
        a: {
          d: [32m"EGmYpfqwx-IAXb5TinMWNLpVJ6YGRimlIasburVbiSHw"[39m,
          i: [32m"EDuMtFBduortAQvD2Ywsp_6sPHrlDQyKPshlsRTWV2xv"[39m,
          eventName: [32m"GLEIF Summit"[39m,
          accessLevel: [32m"staff"[39m,
          validDate: [32m"2026-10-01"[39m,
          dt: [32m"2025-06-05T22:24:03.630000+00:00"[39m
        }
      },
      atc: [32m"-IABECrfo90QVwsAjSg4D5VpaNDW0ggOndsFHjKyymjhJ6ZO0AAAAAAAAAAAAAAAAAAAAAAAECrfo90QVwsAjSg4D5VpaNDW0ggOndsFHjKyymjhJ6ZO"[39m,
      iss: {
        v: [32m"KERI10JSON0000ed_"[39m,
        t: [32m"iss"[39m,
        d: [32m"EBtTQSVGcMG6y77Jn53woLxsxdhAodol2i20HfDgnONX"[39m,
        i: [32m"ECrfo90QVwsAjSg4D5VpaNDW0ggOndsFHjKyymjhJ6ZO"[39m,
        s: [32m"0"[39m,
        ri: [32m"EFRsZKzhX16pRpGJR2PrY1Q3JQWU0JsA3_Sstc9cu-CK"[39m,
        dt: [32m"2025-06-05T22:24:03.630000+00:00"[39m
      },
      issatc: [32m"-VAS-GAB0AAAAAAAAAAAAAAAAAAAAAACEAYL-QBEI1F3pcUQwgN_gslBHsn1AvJyPKPVzKJFxpvg"[39m,
      pre: [32m"EG1-XGIRXIc-EwmQI_VeGkWgtD9CfPVl4ofEBf6BA4Ak"[39m,
      schema: {
        [32m"$id"[39m: [32m"EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK"[39m,
        [32m"$schema"[39m: [32m"http://json-schema.org/draft-07/schema#"[39m,
        title: [32m"EventPass"[39m,
        description: [32m"Event Pass Schema"[39m,
        type: [32m"object"[39m,
        credentialType: [32m"EventPassCred"[39m,
        version: [32m"1.0.0"[39m,
        properties: {
          v: { description: [32m"Credential Version String"[39m, type: [32m"string"[39m },
          d: { description: [32m"Credential SAID"[39m, type: [32m"string"[39m },
          u: { description: [32m"One time use nonce"[39m, type: [32m"string"[39m },
          i: { description: [32m"Issuer AID"[39m, type: [32m"string"[39m },
          ri: { description: [32m"Registry SAID"[39m, type: [32m"string"[39m },
          s: { description: [32m"Schema SAID"[39m, type: [32m"string"[39m },
          a: { oneOf: [ [36m[Object][39m, [36m[Object][39m ] }
        },
        additionalProperties: [33mfalse[39m,
        required: [ [32m"v"[39m, [32m"d"[39m, [32m"i"[39m, [32m"ri"[39m, [32m"s"[39m, [32m"a"[39m ]
      },
      chains: [],
      status: {
        vn: [ [33m1[39m, [33m0[39m ],
        i: [32m"ECrfo90QVwsAjSg4D5VpaNDW0ggOndsFHjKyymjhJ6ZO"[39m,
        s: [32m"0"[39m,
        d: [32m"EBtTQSVGcMG6y77Jn53woLxsxdhAodol2i20HfDgnONX"[39m,
        ri: [32m"EFRsZKzhX16pRpGJR2PrY1Q3JQWU0JsA3_Sstc9cu-CK"[39m,
        ra: {},
        a: { s: [33m2[39m, d: [32m"EAYL-QBEI1F3pcUQwgN_gslBHsn1AvJyPKPVzKJFxpvg"[39m },
        dt: [32m"2025-06-05T22:24:03.630000+00:00"[39m,
        et: [32m"iss"[39m
      },
      anchor: {
        pre: [32m"ECrfo90QVwsAjSg4D5VpaNDW0ggOndsFHjKyymjhJ6ZO"[39m,
        sn: [33m0[39m,
        d: [32m"EBtTQSVGcMG6y77Jn53woLxsxdhAodol2i20HfDgnONX"[39m
      },
      anc: {
        v: [32m"KERI10JSON00013a_"[39m,
        t: [32m"ixn"[39m,
        d: [32m"EAYL-QBEI1F3pcUQwgN_gslBHsn1AvJyPKPVzKJFxpvg"[39m,
        i: [32m"EG1-XGIRXIc-EwmQI_VeGkWgtD9CfPVl4ofEBf6BA4Ak"[39m,
        s: [32m"2"[39m,
        p: [32m"EH-GVRRyM4-emR_ZRmiOFczW8lWWZWcgU6HMUZyfcJZ1"[39m,
        a: [
          {
            i: [32m"ECrfo90QVwsAjSg4D5VpaNDW0ggOndsFHjKyymjhJ6ZO"[39m,
            s: [32m"0"[39m,
            d: [32m"EBtTQSVGcMG6y77Jn53woLxsxdhAodol2i20HfDgnONX"[39m
          }
        ]
      },
      ancatc: [
        [32m"-VBq-AABAACZ8USvkHvarIHTgFMXEtLI-qzyDPITmfpktSxN9hTVml2x9ftL3noXqinOYIdwB0ZnRYNE9szrnhb3hS7A5E4N-BADAABKJS0x50cZVhqdM8iiL8jkscMmye8v9V52E7Qx30pxhxO6-36_Yza-u0I0A94GZQZYyhraLL8x8mGVtVg42CQOABAiFxcOvmzjaYSMIX47FtXv1jVXHbTORw9trvdq-l7p0EQWR936L3SiMGCQxxgQISPtfgxha9fFh_2nXgx3U1EKACCck4cdWQJ4qEhU9QiJ6--PK2oeHMoYGo6bpIbPO6TZkXfqaV1E_oa-_gvgDOmf_IWf86jM-bx6e1-jVEXh7EkK-EAB0AAAAAAAAAAAAAAAAAAAAAAA1AAG2025-06-05T22c24c03d728977p00c00"[39m
      ]
    }


### Step 4: Issuer Grants Credential via IPEX

The credential has been created but currently resides with the Issuer. To transfer it to the Holder, the Issuer initiates an IPEX (Issuance and Presentation Exchange) grant. This process uses KERI `exn` (exchange) messages. The grant message effectively offers the credential to the Holder. 

The `issuerClient.ipex().grant()` method prepares the grant message, including the ACDC itself (`acdc`), the issuance event from the registry (`iss`), and the anchoring event from the Issuer's KEL (`anc`) along with its signatures (`ancAttachment`).
Then, `issuerClient.ipex().submitGrant()` sends this packaged grant message to the Holder's KERIA agent.

Use the code below to perform the ipex grant.


```typescript
// Ipex Grant

const [grant, gsigs, gend] = await issuerClient.ipex().grant({
    senderName: issuerAidAlias,
    acdc: new Serder(issuerCredential.sad), // The ACDC (Verifiable Credential) itself
    iss: new Serder(issuerCredential.iss),  // The issuance event from the credential registry (TEL event)
    anc: new Serder(issuerCredential.anc),  // The KEL event anchoring the TEL issuance event
    ancAttachment: issuerCredential.ancatc, // Signatures for the KEL anchoring event
    recipient: holderAid.i,                 // AID of the Holder
    datetime: createTimestamp(),            // Timestamp for the grant message
});

// Issuer submits the prepared grant message to the Holder.
// This sends an 'exn' message to the Holder's KERIA agent.
const submitGrantOperation = await issuerClient
    .ipex()
    .submitGrant(
        issuerAidAlias,  // Issuer's AID alias
        grant,           // The grant message payload
        gsigs,           // Signatures for the grant message
        gend,            // Endorsements for the grant message
        [holderAid.i]    // List of recipient AIDs
    );

// Wait for the submission operation to complete.
const submitGrantResponse = await issuerClient
    .operations()
    .wait(submitGrantOperation, AbortSignal.timeout(DEFAULT_TIMEOUT_MS));

// Clean up the operation.
await issuerClient.operations().delete(submitGrantOperation.name);
```

**Holder Checks Credential Status (Optional)**

The Holder can proactively check the status of a credential in the Issuer's registry if they know the registry's SAID (`issuerRegistry.regk`) and the credential's SAID (`issuerCredential.sad.d`). This query demonstrates how a party can verify the status directly from the TEL.


```typescript
// The flow transitions from the Issuer to the Holder.
// A delay and retry mechanism is added to allow time for KERIA agents and witnesses
// to propagate the credential issuance information.

let credentialState;

// Retry loop to fetch credential state from the Holder's perspective.
for (let attempt = 1; attempt <= DEFAULT_RETRIES ; attempt++) {
    try{
        // Holder's client queries the state of the credential in the Issuer's registry.
        credentialState = await holderClient.credentials().state(issuerRegistry.regk, issuerCredential.sad.d)
        break;
    }
    catch (error){    
         console.log(`[Retry] failed to get credential state on attempt #${attempt} of ${DEFAULT_RETRIES}`);
         if (attempt === DEFAULT_RETRIES) {
             console.error(`[Retry] Max retries (${DEFAULT_RETRIES}) reached for getting credential state.`);
             throw error; 
         }
         console.log(`[Retry] Waiting ${DEFAULT_DELAY_MS}ms before next attempt...`);
         await new Promise(resolve => setTimeout(resolve, DEFAULT_DELAY_MS));
    }
}

console.log(credentialState) // Displays the status (e.g., issued, revoked)
```

    [Retry] failed to get credential state on attempt #1 of 5


    [Retry] Waiting 5000ms before next attempt...


    {
      vn: [ [33m1[39m, [33m0[39m ],
      i: [32m"ECrfo90QVwsAjSg4D5VpaNDW0ggOndsFHjKyymjhJ6ZO"[39m,
      s: [32m"0"[39m,
      d: [32m"EBtTQSVGcMG6y77Jn53woLxsxdhAodol2i20HfDgnONX"[39m,
      ri: [32m"EFRsZKzhX16pRpGJR2PrY1Q3JQWU0JsA3_Sstc9cu-CK"[39m,
      ra: {},
      a: { s: [33m2[39m, d: [32m"EAYL-QBEI1F3pcUQwgN_gslBHsn1AvJyPKPVzKJFxpvg"[39m },
      dt: [32m"2025-06-05T22:24:03.630000+00:00"[39m,
      et: [32m"iss"[39m
    }


### Step 5: Holder Receives IPEX Grant Notification

The Holder's KERIA agent will receive the grant `exn` message sent by the Issuer. The Holder's client can list its notifications to find this incoming grant. The notification will contain the SAID of the `exn` message (`grantNotification.a.d`), which can then be used to retrieve the full details of the grant exchange from the Holder's client.




```typescript
// Holder waits for Grant notification

let notifications;

// Retry loop to fetch notifications.
for (let attempt = 1; attempt <= DEFAULT_RETRIES ; attempt++) {
    try{
        // List notifications, filtering for unread IPEX_GRANT_ROUTE messages.
        let allNotifications = await holderClient.notifications().list( );
        notifications = allNotifications.notes.filter(
            (n) => n.a.r === IPEX_GRANT_ROUTE && n.r === false // n.r is 'read' status
        )        
        if(notifications.length === 0){ 
            throw new Error("Grant notification not found"); // Throw error to trigger retry
        }
        break;     
    }
    catch (error){    
         console.log(`[Retry] Grant notification not found on attempt #${attempt} of ${DEFAULT_RETRIES}`);
         if (attempt === DEFAULT_RETRIES) {
             console.error(`[Retry] Max retries (${DEFAULT_RETRIES}) reached for grant notification.`);
             throw error; 
         }
         console.log(`[Retry] Waiting ${DEFAULT_DELAY_MS}ms before next attempt...`);
         await new Promise(resolve => setTimeout(resolve, DEFAULT_DELAY_MS));
    }
}

const grantNotification = notifications[0]  // Assuming only one grant notification for simplicity

console.log(grantNotification) // Displays the notification details

// Retrieve the full IPEX grant exchange details using the SAID from the notification.
// The 'exn' field in the exchange will contain the actual credential data.
const grantExchange = await holderClient.exchanges().get(grantNotification.a.d);

console.log(grantExchange) // Displays the content of the grant message
```

    {
      i: [32m"0AD38NYp2ZoLdoVQRJsZ8LaY"[39m,
      dt: [32m"2025-06-05T22:24:04.982407+00:00"[39m,
      r: [33mfalse[39m,
      a: {
        r: [32m"/exn/ipex/grant"[39m,
        d: [32m"EKf5N_ScQr_jTmL5VFUZU2s8lIuBODb6n9OZ59FyN4Vl"[39m,
        m: [32m""[39m
      }
    }


    {
      exn: {
        v: [32m"KERI10JSON00057f_"[39m,
        t: [32m"exn"[39m,
        d: [32m"EKf5N_ScQr_jTmL5VFUZU2s8lIuBODb6n9OZ59FyN4Vl"[39m,
        i: [32m"EG1-XGIRXIc-EwmQI_VeGkWgtD9CfPVl4ofEBf6BA4Ak"[39m,
        rp: [32m"EDuMtFBduortAQvD2Ywsp_6sPHrlDQyKPshlsRTWV2xv"[39m,
        p: [32m""[39m,
        dt: [32m"2025-06-05T22:24:04.612000+00:00"[39m,
        r: [32m"/ipex/grant"[39m,
        q: {},
        a: { i: [32m"EDuMtFBduortAQvD2Ywsp_6sPHrlDQyKPshlsRTWV2xv"[39m, m: [32m""[39m },
        e: {
          acdc: {
            v: [32m"ACDC10JSON0001c4_"[39m,
            d: [32m"ECrfo90QVwsAjSg4D5VpaNDW0ggOndsFHjKyymjhJ6ZO"[39m,
            i: [32m"EG1-XGIRXIc-EwmQI_VeGkWgtD9CfPVl4ofEBf6BA4Ak"[39m,
            ri: [32m"EFRsZKzhX16pRpGJR2PrY1Q3JQWU0JsA3_Sstc9cu-CK"[39m,
            s: [32m"EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK"[39m,
            a: {
              d: [32m"EGmYpfqwx-IAXb5TinMWNLpVJ6YGRimlIasburVbiSHw"[39m,
              i: [32m"EDuMtFBduortAQvD2Ywsp_6sPHrlDQyKPshlsRTWV2xv"[39m,
              eventName: [32m"GLEIF Summit"[39m,
              accessLevel: [32m"staff"[39m,
              validDate: [32m"2026-10-01"[39m,
              dt: [32m"2025-06-05T22:24:03.630000+00:00"[39m
            }
          },
          iss: {
            v: [32m"KERI10JSON0000ed_"[39m,
            t: [32m"iss"[39m,
            d: [32m"EBtTQSVGcMG6y77Jn53woLxsxdhAodol2i20HfDgnONX"[39m,
            i: [32m"ECrfo90QVwsAjSg4D5VpaNDW0ggOndsFHjKyymjhJ6ZO"[39m,
            s: [32m"0"[39m,
            ri: [32m"EFRsZKzhX16pRpGJR2PrY1Q3JQWU0JsA3_Sstc9cu-CK"[39m,
            dt: [32m"2025-06-05T22:24:03.630000+00:00"[39m
          },
          anc: {
            v: [32m"KERI10JSON00013a_"[39m,
            t: [32m"ixn"[39m,
            d: [32m"EAYL-QBEI1F3pcUQwgN_gslBHsn1AvJyPKPVzKJFxpvg"[39m,
            i: [32m"EG1-XGIRXIc-EwmQI_VeGkWgtD9CfPVl4ofEBf6BA4Ak"[39m,
            s: [32m"2"[39m,
            p: [32m"EH-GVRRyM4-emR_ZRmiOFczW8lWWZWcgU6HMUZyfcJZ1"[39m,
            a: [ [36m[Object][39m ]
          },
          d: [32m"EPJBZrkPLMTw2huqFoSl39Bds4rWbj4N6r4vuGsgiuVc"[39m
        }
      },
      pathed: {
        acdc: [32m"-IABECrfo90QVwsAjSg4D5VpaNDW0ggOndsFHjKyymjhJ6ZO0AAAAAAAAAAAAAAAAAAAAAAAEBtTQSVGcMG6y77Jn53woLxsxdhAodol2i20HfDgnONX"[39m,
        iss: [32m"-VAS-GAB0AAAAAAAAAAAAAAAAAAAAAAAEAYL-QBEI1F3pcUQwgN_gslBHsn1AvJyPKPVzKJFxpvg"[39m,
        anc: [32m"-VBq-AABAACZ8USvkHvarIHTgFMXEtLI-qzyDPITmfpktSxN9hTVml2x9ftL3noXqinOYIdwB0ZnRYNE9szrnhb3hS7A5E4N-BADAABKJS0x50cZVhqdM8iiL8jkscMmye8v9V52E7Qx30pxhxO6-36_Yza-u0I0A94GZQZYyhraLL8x8mGVtVg42CQOABAiFxcOvmzjaYSMIX47FtXv1jVXHbTORw9trvdq-l7p0EQWR936L3SiMGCQxxgQISPtfgxha9fFh_2nXgx3U1EKACCck4cdWQJ4qEhU9QiJ6--PK2oeHMoYGo6bpIbPO6TZkXfqaV1E_oa-_gvgDOmf_IWf86jM-bx6e1-jVEXh7EkK-EAB0AAAAAAAAAAAAAAAAAAAAAAA1AAG2025-06-05T22c24c03d728977p00c00"[39m
      }
    }


### Step 6: Holder Admits Credential

Upon receiving and reviewing the grant, the Holder decides to accept (`admit`) the credential. This involves:
- Preparing an `admit` `exn` message using `holderClient.ipex().admit()`.
- Submitting this `admit` message back to the Issuer using `holderClient.ipex().submitAdmit()`.
- Marking the original grant notification as read.
- The Holder's client then processes the admitted credential, verifying its signatures, schema, and status against the Issuer's KEL and TEL, and stores it locally.


```typescript
// Holder admits (accepts) the IPEX grant.

// Prepare the IPEX admit message.
const [admit, sigs, aend] = await holderClient.ipex().admit({
    senderName: holderAidAlias,       // Alias of the Holder's AID
    message: '',                      // Optional message to include in the admit
    grantSaid: grantNotification.a.d!,// SAID of the grant 'exn' message being admitted
    recipient: issuerAid.i,           // AID of the Issuer
    datetime: createTimestamp(),      // Timestamp for the admit message
});

// Holder submits the prepared admit message to the Issuer.
const admitOperation = await holderClient
    .ipex()
    .submitAdmit(holderAidAlias, admit, sigs, aend, [issuerAid.i]);

// Wait for the submission operation to complete.
const admitResponse = await holderClient
    .operations()
    .wait(admitOperation, AbortSignal.timeout(DEFAULT_TIMEOUT_MS));

// Clean up the operation.
await holderClient.operations().delete(admitOperation.name);

// Holder marks the grant notification as read.
await holderClient.notifications().mark(grantNotification.i);
console.log("Holder's notifications after marking grant as read:");
console.log(await holderClient.notifications().list());

// Holder can now get the credential from their local store.
// This implies the client has processed, verified, and stored it upon admission.
const holderReceivedCredential = await holderClient.credentials().get(issuerCredential.sad.d);
console.log("Credential as stored by Holder:");
console.log(holderReceivedCredential);

```

    Holder's notifications after marking grant as read:


    {
      start: [33m0[39m,
      end: [33m0[39m,
      total: [33m1[39m,
      notes: [
        {
          i: [32m"0AD38NYp2ZoLdoVQRJsZ8LaY"[39m,
          dt: [32m"2025-06-05T22:24:04.982407+00:00"[39m,
          r: [33mtrue[39m,
          a: {
            r: [32m"/exn/ipex/grant"[39m,
            d: [32m"EKf5N_ScQr_jTmL5VFUZU2s8lIuBODb6n9OZ59FyN4Vl"[39m,
            m: [32m""[39m
          }
        }
      ]
    }


    Credential as stored by Holder:


    {
      sad: {
        v: [32m"ACDC10JSON0001c4_"[39m,
        d: [32m"ECrfo90QVwsAjSg4D5VpaNDW0ggOndsFHjKyymjhJ6ZO"[39m,
        i: [32m"EG1-XGIRXIc-EwmQI_VeGkWgtD9CfPVl4ofEBf6BA4Ak"[39m,
        ri: [32m"EFRsZKzhX16pRpGJR2PrY1Q3JQWU0JsA3_Sstc9cu-CK"[39m,
        s: [32m"EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK"[39m,
        a: {
          d: [32m"EGmYpfqwx-IAXb5TinMWNLpVJ6YGRimlIasburVbiSHw"[39m,
          i: [32m"EDuMtFBduortAQvD2Ywsp_6sPHrlDQyKPshlsRTWV2xv"[39m,
          eventName: [32m"GLEIF Summit"[39m,
          accessLevel: [32m"staff"[39m,
          validDate: [32m"2026-10-01"[39m,
          dt: [32m"2025-06-05T22:24:03.630000+00:00"[39m
        }
      },
      atc: [32m"-IABECrfo90QVwsAjSg4D5VpaNDW0ggOndsFHjKyymjhJ6ZO0AAAAAAAAAAAAAAAAAAAAAAAECrfo90QVwsAjSg4D5VpaNDW0ggOndsFHjKyymjhJ6ZO"[39m,
      iss: {
        v: [32m"KERI10JSON0000ed_"[39m,
        t: [32m"iss"[39m,
        d: [32m"EBtTQSVGcMG6y77Jn53woLxsxdhAodol2i20HfDgnONX"[39m,
        i: [32m"ECrfo90QVwsAjSg4D5VpaNDW0ggOndsFHjKyymjhJ6ZO"[39m,
        s: [32m"0"[39m,
        ri: [32m"EFRsZKzhX16pRpGJR2PrY1Q3JQWU0JsA3_Sstc9cu-CK"[39m,
        dt: [32m"2025-06-05T22:24:03.630000+00:00"[39m
      },
      issatc: [32m"-VAS-GAB0AAAAAAAAAAAAAAAAAAAAAACEAYL-QBEI1F3pcUQwgN_gslBHsn1AvJyPKPVzKJFxpvg"[39m,
      pre: [32m"EG1-XGIRXIc-EwmQI_VeGkWgtD9CfPVl4ofEBf6BA4Ak"[39m,
      schema: {
        [32m"$id"[39m: [32m"EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK"[39m,
        [32m"$schema"[39m: [32m"http://json-schema.org/draft-07/schema#"[39m,
        title: [32m"EventPass"[39m,
        description: [32m"Event Pass Schema"[39m,
        type: [32m"object"[39m,
        credentialType: [32m"EventPassCred"[39m,
        version: [32m"1.0.0"[39m,
        properties: {
          v: { description: [32m"Credential Version String"[39m, type: [32m"string"[39m },
          d: { description: [32m"Credential SAID"[39m, type: [32m"string"[39m },
          u: { description: [32m"One time use nonce"[39m, type: [32m"string"[39m },
          i: { description: [32m"Issuer AID"[39m, type: [32m"string"[39m },
          ri: { description: [32m"Registry SAID"[39m, type: [32m"string"[39m },
          s: { description: [32m"Schema SAID"[39m, type: [32m"string"[39m },
          a: { oneOf: [ [36m[Object][39m, [36m[Object][39m ] }
        },
        additionalProperties: [33mfalse[39m,
        required: [ [32m"v"[39m, [32m"d"[39m, [32m"i"[39m, [32m"ri"[39m, [32m"s"[39m, [32m"a"[39m ]
      },
      chains: [],
      status: {
        vn: [ [33m1[39m, [33m0[39m ],
        i: [32m"ECrfo90QVwsAjSg4D5VpaNDW0ggOndsFHjKyymjhJ6ZO"[39m,
        s: [32m"0"[39m,
        d: [32m"EBtTQSVGcMG6y77Jn53woLxsxdhAodol2i20HfDgnONX"[39m,
        ri: [32m"EFRsZKzhX16pRpGJR2PrY1Q3JQWU0JsA3_Sstc9cu-CK"[39m,
        ra: {},
        a: { s: [33m2[39m, d: [32m"EAYL-QBEI1F3pcUQwgN_gslBHsn1AvJyPKPVzKJFxpvg"[39m },
        dt: [32m"2025-06-05T22:24:03.630000+00:00"[39m,
        et: [32m"iss"[39m
      },
      anchor: {
        pre: [32m"ECrfo90QVwsAjSg4D5VpaNDW0ggOndsFHjKyymjhJ6ZO"[39m,
        sn: [33m0[39m,
        d: [32m"EBtTQSVGcMG6y77Jn53woLxsxdhAodol2i20HfDgnONX"[39m
      },
      anc: {
        v: [32m"KERI10JSON00013a_"[39m,
        t: [32m"ixn"[39m,
        d: [32m"EAYL-QBEI1F3pcUQwgN_gslBHsn1AvJyPKPVzKJFxpvg"[39m,
        i: [32m"EG1-XGIRXIc-EwmQI_VeGkWgtD9CfPVl4ofEBf6BA4Ak"[39m,
        s: [32m"2"[39m,
        p: [32m"EH-GVRRyM4-emR_ZRmiOFczW8lWWZWcgU6HMUZyfcJZ1"[39m,
        a: [
          {
            i: [32m"ECrfo90QVwsAjSg4D5VpaNDW0ggOndsFHjKyymjhJ6ZO"[39m,
            s: [32m"0"[39m,
            d: [32m"EBtTQSVGcMG6y77Jn53woLxsxdhAodol2i20HfDgnONX"[39m
          }
        ]
      },
      ancatc: [
        [32m"-VBq-AABAACZ8USvkHvarIHTgFMXEtLI-qzyDPITmfpktSxN9hTVml2x9ftL3noXqinOYIdwB0ZnRYNE9szrnhb3hS7A5E4N-BADAABKJS0x50cZVhqdM8iiL8jkscMmye8v9V52E7Qx30pxhxO6-36_Yza-u0I0A94GZQZYyhraLL8x8mGVtVg42CQOABAiFxcOvmzjaYSMIX47FtXv1jVXHbTORw9trvdq-l7p0EQWR936L3SiMGCQxxgQISPtfgxha9fFh_2nXgx3U1EKACCck4cdWQJ4qEhU9QiJ6--PK2oeHMoYGo6bpIbPO6TZkXfqaV1E_oa-_gvgDOmf_IWf86jM-bx6e1-jVEXh7EkK-EAB0AAAAAAAAAAAAAAAAAAAAAAA1AAG2025-06-05T22c24c05d134389p00c00"[39m
      ]
    }


### Step 8: Issuer Receives Admit Notification

The Issuer, in turn, will receive a notification that the Holder has admitted the credential. The Issuer's client lists its notifications, finds the `admit` message, and marks it as read. This completes the issuance loop.


```typescript
// Issuer retrieves the Admit notification from the Holder.

let issuerAdmitNotifications;

// Retry loop for the Issuer to receive the admit notification.
for (let attempt = 1; attempt <= DEFAULT_RETRIES ; attempt++) {
    try{
        // List notifications, filtering for unread IPEX_ADMIT_ROUTE messages.
        let allNotifications = await issuerClient.notifications().list();
        issuerAdmitNotifications = allNotifications.notes.filter(
            (n) => n.a.r === IPEX_ADMIT_ROUTE && n.r === false
        )        
        if(issuerAdmitNotifications.length === 0){ 
            throw new Error("Admit notification not found"); // Throw error to trigger retry
        }
        break; // Exit loop if notification found
    }
    catch (error){    
         console.log(`[Retry] Admit notification not found for Issuer on attempt #${attempt} of ${DEFAULT_RETRIES}`);
         if (attempt === DEFAULT_RETRIES) {
             console.error(`[Retry] Max retries (${DEFAULT_RETRIES}) reached for Issuer's admit notification.`);
             throw error; 
         }
         console.log(`[Retry] Waiting ${DEFAULT_DELAY_MS}ms before next attempt...`);
         await new Promise(resolve => setTimeout(resolve, DEFAULT_DELAY_MS));
    }
}

const admitNotificationForIssuer = issuerAdmitNotifications[0] // Assuming one notification

// Issuer marks the admit notification as read.
await issuerClient.notifications().mark(admitNotificationForIssuer.i);
console.log("Issuer's notifications after marking admit as read:");
console.log(await issuerClient.notifications().list());
```

    Issuer's notifications after marking admit as read:


    {
      start: [33m0[39m,
      end: [33m0[39m,
      total: [33m1[39m,
      notes: [
        {
          i: [32m"0ADxARNRS2N6NX1PO5E0HHxW"[39m,
          dt: [32m"2025-06-05T22:24:10.586504+00:00"[39m,
          r: [33mtrue[39m,
          a: {
            r: [32m"/exn/ipex/admit"[39m,
            d: [32m"ELmtSs4LaAUF5F42Si28U3_tAyPKduD2HR_yIZtZQzTM"[39m,
            m: [32m""[39m
          }
        }
      ]
    }


**Cleanup (Optional)**

Once the IPEX flow for issuance is complete and notifications have been processed, both parties can optionally delete these notifications from their local client stores.


```typescript
// Issuer Remove Admit Notification from their list
await issuerClient.notifications().delete(admitNotificationForIssuer.i);
console.log("Issuer's notifications after deleting admit notification:");
console.log(await issuerClient.notifications().list());

// Holder Remove Grant Notification from their list
await holderClient.notifications().delete(grantNotification.i);
console.log("Holder's notifications after deleting grant notification:");
console.log(await holderClient.notifications().list());
```

    Issuer's notifications after deleting admit notification:


    { start: [33m0[39m, end: [33m0[39m, total: [33m0[39m, notes: [] }


    Holder's notifications after deleting grant notification:


    { start: [33m0[39m, end: [33m0[39m, total: [33m0[39m, notes: [] }

