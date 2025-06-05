# Signify-ts: ACDC Presentation and Revocation with IPEX

<div class="alert alert-primary">
<b>🎯 OBJECTIVE</b><hr>
Demonstrate the process of presenting an ACDC (Authentic Chained Data Container) from a Holder to a Verifier using the IPEX protocol with the Signify-ts library and the process of credential revocation.
</div>

<div class="alert alert-info">
<b>ℹ️ NOTE</b><hr>
This section utilizes utility functions (from <code>./scripts_ts/utils.ts</code>) to quickly establish the necessary preconditions for credential presentation. 
</div>

## Prerequisites: Client and Credential Setup 

The client setup process from the previous notebook is reused here.


```typescript
import { randomPasscode, Serder} from 'npm:signify-ts';
import { initializeSignify, 
         initializeAndConnectClient,
         createNewAID,
         addEndRoleForAID,
         generateOOBI,
         resolveOOBI,
         createTimestamp,
         createCredentialRegistry,
         getSchema,
         issueCredential,
         ipexGrantCredential,
         getCredentialState,
         waitForAndGetNotification,
         ipexAdmitGrant,
         markNotificationRead,
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

    Using Passcode (bran): BR4e1_QtyyMU_1kCks4x2


    Client boot process initiated with KERIA agent.


      Client AID Prefix:  EDoXhKDYMx8FgYQcfCkQ5fF2XhdEqyAT8Xf8cK-0zXRj


      Agent AID Prefix:   EJ84vgAC5Wa_KMgW-j8K3ZQSq7o7Rs6sbZAaZBBmKQQI


    Initiating AID inception for alias: issuerAid


    Successfully created AID with prefix: EKZnlxpHNfSj2TExcUEzMl7o_WclylGrlJFe0H0GgZLQ


    Assigning 'agent' role to KERIA Agent EJ84vgAC5Wa_KMgW-j8K3ZQSq7o7Rs6sbZAaZBBmKQQI for AID alias issuerAid


    Successfully assigned 'agent' role for AID alias issuerAid.


    Generating OOBI for AID alias issuerAid with role agent


    Generated OOBI URL: http://keria:3902/oobi/EKZnlxpHNfSj2TExcUEzMl7o_WclylGrlJFe0H0GgZLQ/agent/EJ84vgAC5Wa_KMgW-j8K3ZQSq7o7Rs6sbZAaZBBmKQQI


    Using Passcode (bran): DqfMfizOlKV8lZHMJLoIb


    Client boot process initiated with KERIA agent.


      Client AID Prefix:  EHGV4cz06eaWxgfn94ulnsgjqei7RYelkuhFqE_-9c27


      Agent AID Prefix:   EH5M0lB6M3cBIoTGMUk_-XLZNDRz3RZ-qFDPtkPCOGLY


    Initiating AID inception for alias: holderAid


    Successfully created AID with prefix: EOIHsOWni4ynixK49dVEHUWcjAT3bdgEHHfK7a7oUk0w


    Assigning 'agent' role to KERIA Agent EH5M0lB6M3cBIoTGMUk_-XLZNDRz3RZ-qFDPtkPCOGLY for AID alias holderAid


    Successfully assigned 'agent' role for AID alias holderAid.


    Generating OOBI for AID alias holderAid with role agent


    Generated OOBI URL: http://keria:3902/oobi/EOIHsOWni4ynixK49dVEHUWcjAT3bdgEHHfK7a7oUk0w/agent/EH5M0lB6M3cBIoTGMUk_-XLZNDRz3RZ-qFDPtkPCOGLY


    Using Passcode (bran): BJiE_RsDOWqHkxo392kz4


    Client boot process initiated with KERIA agent.


      Client AID Prefix:  EDfK5w-_colBVmeh2cVxdCE2gFBWxTtK5PazNU7Qu8fz


      Agent AID Prefix:   EKaDOli79V-kfh7mEUXTBR08A4sUI0za_eLFfPPqTcnf


    Initiating AID inception for alias: verifierAid


    Successfully created AID with prefix: EFw1FlBWMRfymeGH_MeyXRWIdCiMwvCIra8nwOpK4i50


    Assigning 'agent' role to KERIA Agent EKaDOli79V-kfh7mEUXTBR08A4sUI0za_eLFfPPqTcnf for AID alias verifierAid


    Successfully assigned 'agent' role for AID alias verifierAid.


    Generating OOBI for AID alias verifierAid with role agent


    Generated OOBI URL: http://keria:3902/oobi/EFw1FlBWMRfymeGH_MeyXRWIdCiMwvCIra8nwOpK4i50/agent/EKaDOli79V-kfh7mEUXTBR08A4sUI0za_eLFfPPqTcnf


    Resolving OOBI URL: http://keria:3902/oobi/EOIHsOWni4ynixK49dVEHUWcjAT3bdgEHHfK7a7oUk0w/agent/EH5M0lB6M3cBIoTGMUk_-XLZNDRz3RZ-qFDPtkPCOGLY with alias holderContact


    Successfully resolved OOBI URL. Response: OK


    Contact "holderContact" (ID: undefined) added/updated.


    Resolving OOBI URL: http://keria:3902/oobi/EKZnlxpHNfSj2TExcUEzMl7o_WclylGrlJFe0H0GgZLQ/agent/EJ84vgAC5Wa_KMgW-j8K3ZQSq7o7Rs6sbZAaZBBmKQQI with alias issuerContact


    Successfully resolved OOBI URL. Response: OK


    Contact "issuerContact" (ID: undefined) added/updated.


    Resolving OOBI URL: http://keria:3902/oobi/EOIHsOWni4ynixK49dVEHUWcjAT3bdgEHHfK7a7oUk0w/agent/EH5M0lB6M3cBIoTGMUk_-XLZNDRz3RZ-qFDPtkPCOGLY with alias holderContact


    Successfully resolved OOBI URL. Response: OK


    Contact "holderContact" (ID: undefined) added/updated.


    Resolving OOBI URL: http://keria:3902/oobi/EFw1FlBWMRfymeGH_MeyXRWIdCiMwvCIra8nwOpK4i50/agent/EKaDOli79V-kfh7mEUXTBR08A4sUI0za_eLFfPPqTcnf with alias verifierContact


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


As you will be conducting a credential presentation in this notebook, let's generate one for use in the presentation workflow. 


```typescript
// Create Issuer Credential Registry
const issuerRegistryName = 'issuerRegistry'
const { registrySaid: registrySaid } = await createCredentialRegistry(issuerClient, issuerAidAlias, issuerRegistryName)

// Define credential Claims
const credentialClaims = {
    "eventName":"GLEIF Summit",
    "accessLevel":"staff",
    "validDate":"2026-10-01"
}

// Issuer - Issue Credential
const { credentialSaid: credentialSaid} = await issueCredential(
    issuerClient, 
    issuerAidAlias, 
    registrySaid, 
    schemaSaid,
    holderAid.i,
    credentialClaims
)

// Issuer - get credential (with all its data)
const credential = await issuerClient.credentials().get(credentialSaid);

// Issuer - Ipex grant
const grantResponse = await ipexGrantCredential(
    issuerClient,
    issuerAidAlias, 
    holderAid.i,
    credential,
    ipexAdmitGrant
)

// Holder - Wait for grant notification
const grantNotifications = await waitForAndGetNotification(holderClient, IPEX_GRANT_ROUTE)
const grantNotification = grantNotifications[0]

// Holder - Admit Grant
const admitResponse = await ipexAdmitGrant(
    holderClient,
    holderAidAlias,
    issuerAid.i,
    grantNotification.a.d
)

// Holder - Mark notification
await markNotificationRead(holderClient, grantNotification.i)

// Issuer - Wait for admit notification
const admitNotifications = await waitForAndGetNotification(issuerClient, IPEX_ADMIT_ROUTE)
const admitNotification = admitNotifications[0]

// Issuer - Mark notification
await markNotificationRead(issuerClient, admitNotification.i)
```

    Creating credential registry "issuerRegistry" for AID alias "issuerAid"...


    Successfully created credential registry: EFJbqLviCwkUsY47HckIOzgGlS2NyfmRvkgh7izdmJgL


    Issuing credential from AID "issuerAid" to AID "EOIHsOWni4ynixK49dVEHUWcjAT3bdgEHHfK7a7oUk0w"...


    {
      name: [32m"credential.ECj8x588-SJoBX4ERaClMNuZ3R-5CIEdny31cvT_RhbG"[39m,
      metadata: {
        ced: {
          v: [32m"ACDC10JSON0001c4_"[39m,
          d: [32m"ECj8x588-SJoBX4ERaClMNuZ3R-5CIEdny31cvT_RhbG"[39m,
          i: [32m"EKZnlxpHNfSj2TExcUEzMl7o_WclylGrlJFe0H0GgZLQ"[39m,
          ri: [32m"EFJbqLviCwkUsY47HckIOzgGlS2NyfmRvkgh7izdmJgL"[39m,
          s: [32m"EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK"[39m,
          a: {
            d: [32m"ECh1d1TVl3Iq1fBuAhOqVWX0Hl5oQ0gdKm6P2d7sSLpb"[39m,
            i: [32m"EOIHsOWni4ynixK49dVEHUWcjAT3bdgEHHfK7a7oUk0w"[39m,
            eventName: [32m"GLEIF Summit"[39m,
            accessLevel: [32m"staff"[39m,
            validDate: [32m"2026-10-01"[39m,
            dt: [32m"2025-06-05T22:24:22.037000+00:00"[39m
          }
        },
        depends: {
          name: [32m"witness.EEom_mYN-O-1GxBU7mpkzOoeTBrnRib6yUap9g_oMhpx"[39m,
          metadata: { pre: [32m"EKZnlxpHNfSj2TExcUEzMl7o_WclylGrlJFe0H0GgZLQ"[39m, sn: [33m2[39m },
          done: [33mfalse[39m,
          error: [1mnull[22m,
          response: [1mnull[22m
        }
      },
      done: [33mtrue[39m,
      error: [1mnull[22m,
      response: {
        ced: {
          v: [32m"ACDC10JSON0001c4_"[39m,
          d: [32m"ECj8x588-SJoBX4ERaClMNuZ3R-5CIEdny31cvT_RhbG"[39m,
          i: [32m"EKZnlxpHNfSj2TExcUEzMl7o_WclylGrlJFe0H0GgZLQ"[39m,
          ri: [32m"EFJbqLviCwkUsY47HckIOzgGlS2NyfmRvkgh7izdmJgL"[39m,
          s: [32m"EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK"[39m,
          a: {
            d: [32m"ECh1d1TVl3Iq1fBuAhOqVWX0Hl5oQ0gdKm6P2d7sSLpb"[39m,
            i: [32m"EOIHsOWni4ynixK49dVEHUWcjAT3bdgEHHfK7a7oUk0w"[39m,
            eventName: [32m"GLEIF Summit"[39m,
            accessLevel: [32m"staff"[39m,
            validDate: [32m"2026-10-01"[39m,
            dt: [32m"2025-06-05T22:24:22.037000+00:00"[39m
          }
        }
      }
    }


    Successfully issued credential with SAID: ECj8x588-SJoBX4ERaClMNuZ3R-5CIEdny31cvT_RhbG


    AID "issuerAid" granting credential to AID "EOIHsOWni4ynixK49dVEHUWcjAT3bdgEHHfK7a7oUk0w" via IPEX...


    Successfully submitted IPEX grant from "issuerAid" to "EOIHsOWni4ynixK49dVEHUWcjAT3bdgEHHfK7a7oUk0w".


    Waiting for notification with route "/exn/ipex/grant"...


    [Retry] Grant notification not found on attempt #1 of 5


    [Retry] Waiting 5000ms before next attempt...


    AID "holderAid" admitting IPEX grant "ENrmdJqaRfBLtHwtBqFkMpRNEMYJeHp4zlD9zwjMUnXz" from AID "EKZnlxpHNfSj2TExcUEzMl7o_WclylGrlJFe0H0GgZLQ"...


    Successfully submitted IPEX admit for grant "ENrmdJqaRfBLtHwtBqFkMpRNEMYJeHp4zlD9zwjMUnXz".


    Marking notification "0ABdVL5Nq7r40qs76dyICBUp" as read...


    Notification "0ABdVL5Nq7r40qs76dyICBUp" marked as read.


    Waiting for notification with route "/exn/ipex/admit"...


    Marking notification "0AANw8Y-gVIez9-JxfQTL0xA" as read...


    Notification "0AANw8Y-gVIez9-JxfQTL0xA" marked as read.


## Credential Presentation Workflow (IPEX)

Now that the Holder possesses the credential, they can present it to a Verifier. This workflow also uses IPEX, but typically starts with the Verifier requesting a presentation.

Below are presented the code snipets you need to follow to do the presentation.

### Step 1: Verifier Requests Presentation (Apply)

The Verifier initiates the presentation process by sending an IPEX apply message. This `apply` message is an `exn` message specifying the criteria for the credential they are requesting. This includes the `schemaSaid` and can include specific attributes the credential must have.


```typescript
// Verifier Ipex Apply (Presentation request)

// Prepare the IPEX apply message.
const [apply, sigsApply, _endApply] = await verifierClient.ipex().apply({ //_endApply is not used
    senderName: verifierAidAlias,     // Alias of the Verifier's AID
    schemaSaid: schemaSaid,           // SAID of the schema for the requested credential
    attributes: { eventName:'GLEIF Summit' }, // Specific attributes the credential should have
    recipient: holderAid.i,           // AID of the Holder being asked for the presentation
    datetime: createTimestamp(),      // Timestamp for the apply message
});

// Verifier submits the prepared apply message to the Holder.
const applyOperation = await verifierClient
    .ipex()
    .submitApply(verifierAidAlias, apply, sigsApply, [holderAid.i]);

// Wait for the submission operation to complete.
const applyResponse = await verifierClient
    .operations()
    .wait(applyOperation, AbortSignal.timeout(DEFAULT_TIMEOUT_MS));

// Clean up the operation.
await verifierClient.operations().delete(applyOperation.name);
```

### Step 2: Holder Receives Apply Request

Holder Apply Notification and Exchange
The Holder receives a notification for the Verifier's `apply` request. They retrieve the details of this request from the exchange message. After processing, the Holder marks the notification as read.


```typescript
// Holder receives the IPEX apply notification from the Verifier.

let holderApplyNotifications;

// Retry loop for the Holder to receive the apply notification.
for (let attempt = 1; attempt <= DEFAULT_RETRIES ; attempt++) {
    try{
        // List notifications, filtering for unread IPEX_APPLY_ROUTE messages.
        let allNotifications = await holderClient.notifications().list()
        holderApplyNotifications = allNotifications.notes.filter(
            (n) => n.a.r === IPEX_APPLY_ROUTE && n.r === false
        )        
        if(holderApplyNotifications.length === 0){ 
            throw new Error("Apply notification not found"); // Throw error to trigger retry
        }
        break; // Exit loop if notification found
    }
    catch (error){    
         console.log(`[Retry] Apply notification not found for Holder on attempt #${attempt} of ${DEFAULT_RETRIES}`);
         if (attempt === DEFAULT_RETRIES) {
             console.error(`[Retry] Max retries (${DEFAULT_RETRIES}) reached for Holder's apply notification.`);
             throw error; 
         }
         console.log(`[Retry] Waiting ${DEFAULT_DELAY_MS}ms before next attempt...`);
         await new Promise(resolve => setTimeout(resolve, DEFAULT_DELAY_MS));
    }
}

const applyNotificationForHolder = holderApplyNotifications[0] // Assuming one notification

console.log("Holder received Apply Notification:");
console.log(applyNotificationForHolder);

// Retrieve the full IPEX apply exchange details.
const applyExchange = await holderClient.exchanges().get(applyNotificationForHolder.a.d);
console.log("Details of Apply Exchange received by Holder:");
console.log(applyExchange);

// Extract the SAID of the apply 'exn' message for use in the offer.
const applyExchangeSaid = applyExchange.exn.d;

// Holder marks the apply notification as read.
await holderClient.notifications().mark(applyNotificationForHolder.i);
console.log("Holder's notifications after marking apply as read:");
console.log(await holderClient.notifications().list());


```

    [Retry] Apply notification not found for Holder on attempt #1 of 5


    [Retry] Waiting 5000ms before next attempt...


    Holder received Apply Notification:


    {
      i: [32m"0ACaSasCPJjBM2kMrYHNRZt8"[39m,
      dt: [32m"2025-06-05T22:24:29.325673+00:00"[39m,
      r: [33mfalse[39m,
      a: {
        r: [32m"/exn/ipex/apply"[39m,
        d: [32m"EI7QfrawKAnpcpEIwUlAm-mRrhmNAvPF4PByspDWIooS"[39m,
        m: [32m""[39m
      }
    }


    Details of Apply Exchange received by Holder:


    {
      exn: {
        v: [32m"KERI10JSON0001a0_"[39m,
        t: [32m"exn"[39m,
        d: [32m"EI7QfrawKAnpcpEIwUlAm-mRrhmNAvPF4PByspDWIooS"[39m,
        i: [32m"EFw1FlBWMRfymeGH_MeyXRWIdCiMwvCIra8nwOpK4i50"[39m,
        rp: [32m"EOIHsOWni4ynixK49dVEHUWcjAT3bdgEHHfK7a7oUk0w"[39m,
        p: [32m""[39m,
        dt: [32m"2025-06-05T22:24:28.968000+00:00"[39m,
        r: [32m"/ipex/apply"[39m,
        q: {},
        a: {
          i: [32m"EOIHsOWni4ynixK49dVEHUWcjAT3bdgEHHfK7a7oUk0w"[39m,
          m: [32m""[39m,
          s: [32m"EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK"[39m,
          a: { eventName: [32m"GLEIF Summit"[39m }
        },
        e: {}
      },
      pathed: {}
    }


    Holder's notifications after marking apply as read:


    {
      start: [33m0[39m,
      end: [33m1[39m,
      total: [33m2[39m,
      notes: [
        {
          i: [32m"0ABdVL5Nq7r40qs76dyICBUp"[39m,
          dt: [32m"2025-06-05T22:24:23.357776+00:00"[39m,
          r: [33mtrue[39m,
          a: {
            r: [32m"/exn/ipex/grant"[39m,
            d: [32m"ENrmdJqaRfBLtHwtBqFkMpRNEMYJeHp4zlD9zwjMUnXz"[39m,
            m: [32m""[39m
          }
        },
        {
          i: [32m"0ACaSasCPJjBM2kMrYHNRZt8"[39m,
          dt: [32m"2025-06-05T22:24:29.325673+00:00"[39m,
          r: [33mtrue[39m,
          a: {
            r: [32m"/exn/ipex/apply"[39m,
            d: [32m"EI7QfrawKAnpcpEIwUlAm-mRrhmNAvPF4PByspDWIooS"[39m,
            m: [32m""[39m
          }
        }
      ]
    }


### Step 3: Holder Finds Matching Credential

The Holder now needs to find a credential in their possession that satisfies the Verifier's `apply` request (matches the schema SAID and any specified attributes). The code below constructs a filter based on the `applyExchange` data and uses it to search the Holder's credentials.


```typescript
// The apply operation from the Verifier asks for a specific credential 
// (matching schema and attribute values).
// This code snippet creates a credential filter based on the criteria
// from the applyExchange message received by the Holder.

let filter: { [x: string]: any } = { '-s': applyExchange.exn.a.s }; // Filter by schema SAID
// Add attribute filters from the apply request
for (const key in applyExchange.exn.a.a) { // 'a.a' contains the requested attributes
    filter[`-a-${key}`] = applyExchange.exn.a.a[key];
}

console.log("Constructed filter for matching credentials:");
console.log(filter);

// Holder lists credentials matching the filter.
const matchingCredentials = await holderClient.credentials().list({ filter });

console.log("Matching credentials found by Holder:");
console.log(matchingCredentials); // Should list the EventPass credential issued earlier
```

    Constructed filter for matching credentials:


    {
      [32m"-s"[39m: [32m"EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK"[39m,
      [32m"-a-eventName"[39m: [32m"GLEIF Summit"[39m
    }


    Matching credentials found by Holder:


    [
      {
        sad: {
          v: [32m"ACDC10JSON0001c4_"[39m,
          d: [32m"ECj8x588-SJoBX4ERaClMNuZ3R-5CIEdny31cvT_RhbG"[39m,
          i: [32m"EKZnlxpHNfSj2TExcUEzMl7o_WclylGrlJFe0H0GgZLQ"[39m,
          ri: [32m"EFJbqLviCwkUsY47HckIOzgGlS2NyfmRvkgh7izdmJgL"[39m,
          s: [32m"EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK"[39m,
          a: {
            d: [32m"ECh1d1TVl3Iq1fBuAhOqVWX0Hl5oQ0gdKm6P2d7sSLpb"[39m,
            i: [32m"EOIHsOWni4ynixK49dVEHUWcjAT3bdgEHHfK7a7oUk0w"[39m,
            eventName: [32m"GLEIF Summit"[39m,
            accessLevel: [32m"staff"[39m,
            validDate: [32m"2026-10-01"[39m,
            dt: [32m"2025-06-05T22:24:22.037000+00:00"[39m
          }
        },
        atc: [32m"-IABECj8x588-SJoBX4ERaClMNuZ3R-5CIEdny31cvT_RhbG0AAAAAAAAAAAAAAAAAAAAAAAECj8x588-SJoBX4ERaClMNuZ3R-5CIEdny31cvT_RhbG"[39m,
        iss: {
          v: [32m"KERI10JSON0000ed_"[39m,
          t: [32m"iss"[39m,
          d: [32m"EMhosAmvYQNz5YipeQdo72_2S1HSky9gZr1eYREH9RKl"[39m,
          i: [32m"ECj8x588-SJoBX4ERaClMNuZ3R-5CIEdny31cvT_RhbG"[39m,
          s: [32m"0"[39m,
          ri: [32m"EFJbqLviCwkUsY47HckIOzgGlS2NyfmRvkgh7izdmJgL"[39m,
          dt: [32m"2025-06-05T22:24:22.037000+00:00"[39m
        },
        issatc: [32m"-VAS-GAB0AAAAAAAAAAAAAAAAAAAAAACEEom_mYN-O-1GxBU7mpkzOoeTBrnRib6yUap9g_oMhpx"[39m,
        pre: [32m"EKZnlxpHNfSj2TExcUEzMl7o_WclylGrlJFe0H0GgZLQ"[39m,
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
            a: { oneOf: [36m[Array][39m }
          },
          additionalProperties: [33mfalse[39m,
          required: [ [32m"v"[39m, [32m"d"[39m, [32m"i"[39m, [32m"ri"[39m, [32m"s"[39m, [32m"a"[39m ]
        },
        chains: [],
        status: {
          vn: [ [33m1[39m, [33m0[39m ],
          i: [32m"ECj8x588-SJoBX4ERaClMNuZ3R-5CIEdny31cvT_RhbG"[39m,
          s: [32m"0"[39m,
          d: [32m"EMhosAmvYQNz5YipeQdo72_2S1HSky9gZr1eYREH9RKl"[39m,
          ri: [32m"EFJbqLviCwkUsY47HckIOzgGlS2NyfmRvkgh7izdmJgL"[39m,
          ra: {},
          a: { s: [33m2[39m, d: [32m"EEom_mYN-O-1GxBU7mpkzOoeTBrnRib6yUap9g_oMhpx"[39m },
          dt: [32m"2025-06-05T22:24:22.037000+00:00"[39m,
          et: [32m"iss"[39m
        },
        anchor: {
          pre: [32m"ECj8x588-SJoBX4ERaClMNuZ3R-5CIEdny31cvT_RhbG"[39m,
          sn: [33m0[39m,
          d: [32m"EMhosAmvYQNz5YipeQdo72_2S1HSky9gZr1eYREH9RKl"[39m
        },
        anc: {
          v: [32m"KERI10JSON00013a_"[39m,
          t: [32m"ixn"[39m,
          d: [32m"EEom_mYN-O-1GxBU7mpkzOoeTBrnRib6yUap9g_oMhpx"[39m,
          i: [32m"EKZnlxpHNfSj2TExcUEzMl7o_WclylGrlJFe0H0GgZLQ"[39m,
          s: [32m"2"[39m,
          p: [32m"EEX6S8D4WrWbsmu5QQ050StWfCWcnrs4NGJ1Hv3-_SM4"[39m,
          a: [
            {
              i: [32m"ECj8x588-SJoBX4ERaClMNuZ3R-5CIEdny31cvT_RhbG"[39m,
              s: [32m"0"[39m,
              d: [32m"EMhosAmvYQNz5YipeQdo72_2S1HSky9gZr1eYREH9RKl"[39m
            }
          ]
        },
        ancatc: [
          [32m"-VBq-AABAACprPzsJfLy9DnPelX5tHVJYJaGqhAfwDvtFImVHfgyQ5bDSMa8SCcs2WT609oY46DcUPJTU7BNGUfuwmh2jw4A-BADAABMPpdLw4P4jLKOueGk4hsxFGTRNSEPyE3Cs9qdTozcUVQ0mrPqLqosDlPTix0D1xXII5OMJ89s9xweEqKPrGoJABAWTYD__oaQhFY2AFVe-L6nhERgQsn-Yo7YHTc__eRJWEd12LsKqQDesYZxZNEMP_GOnIBVqheAm1pF6e21uYEHACAl1_k6TV4i4dEjZxFxOJXDtv1NNVhVUeKHM6qBKJ3uhBPMBsIuL6pjqkELWPaCkaUw0rNe1vmKu6xB1aODaZ4A-EAB0AAAAAAAAAAAAAAAAAAAAAAA1AAG2025-06-05T22c24c23d509457p00c00"[39m
        ]
      }
    ]


### Step 4: Holder Offers Credential

Assuming a matching credential is found, the Holder prepares an IPEX offer message. This `offer` includes the ACDC they are presenting. This is sent back to the Verifier.


```typescript
// Holder prepares and submits an IPEX offer message with the matching credential.

// Prepare the IPEX offer message.
const [offer, sigsOffer, endOffer] = await holderClient.ipex().offer({
    senderName: holderAidAlias,                   // Alias of the Holder's AID
    recipient: verifierAid.i,                     // AID of the Verifier
    acdc: new Serder(matchingCredentials[0].sad), // The ACDC being offered (first matching credential)
    applySaid: applyExchangeSaid,                 // SAID of the Verifier's apply 'exn' message this offer is responding to
    datetime: createTimestamp(),                  // Timestamp for the offer message
});

// Holder submits the prepared offer message to the Verifier.
const offerOperation = await holderClient
    .ipex()
    .submitOffer(holderAidAlias, offer, sigsOffer, endOffer, [
        verifierAid.i, // Recipient AID
    ]);

// Wait for the submission operation to complete.
const offerResponse = await holderClient
    .operations()
    .wait(offerOperation, AbortSignal.timeout(DEFAULT_TIMEOUT_MS));

// Clean up the operation.
await holderClient.operations().delete(offerOperation.name);
console.log("Holder submitted IPEX Offer to Verifier.");


```

    Holder submitted IPEX Offer to Verifier.


### Step 5: Verifier Receives Offer

The Verifier receives a notification for the Holder's `offer`. The Verifier retrieves the exchange details and marks the notification.


```typescript
// Verifier receives the IPEX offer notification from the Holder.

let verifierOfferNotifications;

// Retry loop for the Verifier to receive the offer notification.
for (let attempt = 1; attempt <= DEFAULT_RETRIES ; attempt++) {
    try{
        // List notifications, filtering for unread IPEX_OFFER_ROUTE messages.
        verifierOfferNotifications = await verifierClient.notifications().list(
            (n) => n.a.r === IPEX_OFFER_ROUTE && n.r === false
        );
        if(verifierOfferNotifications.notes.length === 0){ 
            throw new Error("Offer notification not found"); // Throw error to trigger retry
        }
        break; // Exit loop if notification found
    }
    catch (error){    
         console.log(`[Retry] Offer notification not found for Verifier on attempt #${attempt} of ${DEFAULT_RETRIES}`);
         if (attempt === DEFAULT_RETRIES) {
             console.error(`[Retry] Max retries (${DEFAULT_RETRIES}) reached for Verifier's offer notification.`);
             throw error; 
         }
         console.log(`[Retry] Waiting ${DEFAULT_DELAY_MS}ms before next attempt...`);
         await new Promise(resolve => setTimeout(resolve, DEFAULT_DELAY_MS));
    }
}

const offerNotificationForVerifier = verifierOfferNotifications.notes[0]; // Assuming one notification

console.log("Verifier received Offer Notification:");
console.log(offerNotificationForVerifier);

// Retrieve the full IPEX offer exchange details.
const offerExchange = await verifierClient.exchanges().get(offerNotificationForVerifier.a.d);
console.log("Details of Offer Exchange received by Verifier:");
console.log(offerExchange); // This will contain the ACDC presented by the Holder

// Extract the SAID of the offer 'exn' message for use in the agree.
let offerExchangeSaid = offerExchange.exn.d;

// Verifier marks the offer notification as read.
await verifierClient.notifications().mark(offerNotificationForVerifier.i);
console.log("Verifier's notifications after marking offer as read:");
console.log(await verifierClient.notifications().list());
```

    [Retry] Offer notification not found for Verifier on attempt #1 of 5


    [Retry] Waiting 5000ms before next attempt...


    Verifier received Offer Notification:


    {
      i: [32m"0AB7TmJlEBzbwjGBR0nkMcpr"[39m,
      dt: [32m"2025-06-05T22:24:34.826610+00:00"[39m,
      r: [33mfalse[39m,
      a: {
        r: [32m"/exn/ipex/offer"[39m,
        d: [32m"EOnwYa1s4Ted8bvb7joWk5dgDardpbPSAa6npGI3483l"[39m,
        m: [32m""[39m
      }
    }


    Details of Offer Exchange received by Verifier:


    {
      exn: {
        v: [32m"KERI10JSON000376_"[39m,
        t: [32m"exn"[39m,
        d: [32m"EOnwYa1s4Ted8bvb7joWk5dgDardpbPSAa6npGI3483l"[39m,
        i: [32m"EOIHsOWni4ynixK49dVEHUWcjAT3bdgEHHfK7a7oUk0w"[39m,
        rp: [32m"EFw1FlBWMRfymeGH_MeyXRWIdCiMwvCIra8nwOpK4i50"[39m,
        p: [32m"EI7QfrawKAnpcpEIwUlAm-mRrhmNAvPF4PByspDWIooS"[39m,
        dt: [32m"2025-06-05T22:24:34.456000+00:00"[39m,
        r: [32m"/ipex/offer"[39m,
        q: {},
        a: { i: [32m"EFw1FlBWMRfymeGH_MeyXRWIdCiMwvCIra8nwOpK4i50"[39m, m: [32m""[39m },
        e: {
          acdc: {
            v: [32m"ACDC10JSON0001c4_"[39m,
            d: [32m"ECj8x588-SJoBX4ERaClMNuZ3R-5CIEdny31cvT_RhbG"[39m,
            i: [32m"EKZnlxpHNfSj2TExcUEzMl7o_WclylGrlJFe0H0GgZLQ"[39m,
            ri: [32m"EFJbqLviCwkUsY47HckIOzgGlS2NyfmRvkgh7izdmJgL"[39m,
            s: [32m"EGUPiCVO73M9worPwR3PfThAtC0AJnH5ZgwsXf6TzbVK"[39m,
            a: {
              d: [32m"ECh1d1TVl3Iq1fBuAhOqVWX0Hl5oQ0gdKm6P2d7sSLpb"[39m,
              i: [32m"EOIHsOWni4ynixK49dVEHUWcjAT3bdgEHHfK7a7oUk0w"[39m,
              eventName: [32m"GLEIF Summit"[39m,
              accessLevel: [32m"staff"[39m,
              validDate: [32m"2026-10-01"[39m,
              dt: [32m"2025-06-05T22:24:22.037000+00:00"[39m
            }
          },
          d: [32m"ECwYXdUacBz8Oev_WNat3x_6kay60pJYJgPcTEtViNo3"[39m
        }
      },
      pathed: {}
    }


    Verifier's notifications after marking offer as read:


    {
      start: [33m0[39m,
      end: [33m0[39m,
      total: [33m1[39m,
      notes: [
        {
          i: [32m"0AB7TmJlEBzbwjGBR0nkMcpr"[39m,
          dt: [32m"2025-06-05T22:24:34.826610+00:00"[39m,
          r: [33mtrue[39m,
          a: {
            r: [32m"/exn/ipex/offer"[39m,
            d: [32m"EOnwYa1s4Ted8bvb7joWk5dgDardpbPSAa6npGI3483l"[39m,
            m: [32m""[39m
          }
        }
      ]
    }


### Step 6: Verifier Agrees and Validates

Finally, the Verifier, after validating the offered credential (which signify-ts does implicitly upon processing the offer and preparing the agree), sends an IPEX agree message back to the Holder. This confirms successful receipt and validation of the presentation.


```typescript
// Verifier prepares and submits an IPEX agree message.

// Prepare the IPEX agree message.
const [agree, sigsAgree, _endAgree] = await verifierClient.ipex().agree({
    senderName: verifierAidAlias, // Alias of the Verifier's AID
    recipient: holderAid.i,       // AID of the Holder
    offerSaid: offerExchangeSaid, // SAID of the Holder's offer 'exn' message this agree is responding to
    datetime: createTimestamp(),  // Timestamp for the agree message
});

// Verifier submits the prepared agree message to the Holder.
const agreeOperation = await verifierClient
    .ipex()
    .submitAgree(verifierAidAlias, agree, sigsAgree, [holderAid.i]);

// Wait for the submission operation to complete.
const agreeResponse = await verifierClient
    .operations()
    .wait(agreeOperation, AbortSignal.timeout(DEFAULT_TIMEOUT_MS));

// Clean up the operation.
await verifierClient.operations().delete(agreeOperation.name);
console.log("Verifier submitted IPEX Agree to Holder, completing the presentation exchange.");

// At this point, the Verifier has successfully received and validated the credential.
// The Verifier's client would have stored the presented credential details if needed.
```

    Verifier submitted IPEX Agree to Holder, completing the presentation exchange.


## Credential Revocation by Issuer

Circumstances may require a credential to be invalidated before its intended expiry, or if it has no expiry. This process is known as revocation. Only the original Issuer of a credential can revoke it. Revocation involves the Issuer recording a revocation event in the specific credential's Transaction Event Log (TEL), which is part of the Issuer's Credential Registry. This event is, like all TEL events, anchored to the Issuer's KEL.

The Issuer uses the `issuerClient.credentials().revoke()` method, specifying the alias of their issuing AID and the SAID of the credential to be revoked. This action creates a new event in the TEL associated with the credential, marking its status as revoked.

First, check the credential status before revocation. The status object contains details about the latest event in the credential's TEL. The et field indicates the event type (e.g., iss for issuance).


```typescript

// Log the credential's status from the Issuer's perspective before revocation.
// The 'status' field shows the latest event in the credential's Transaction Event Log (TEL).
// 'et: "iss"' indicates it's currently in an issued state.
const statusBefore = (await issuerClient.credentials().get(credentialSaid)).status;
console.log("Credential status before revocation:", statusBefore);

// Issuer revokes the credential.
// This creates a revocation event in the credential's TEL within the Issuer's registry.
const revokeResult = await issuerClient.credentials().revoke(issuerAidAlias, credentialSaid); // Changed from revokeOperation to revokeResult to get .op
const revokeOperation = revokeResult.op; // Get the operation from the result

// Wait for the revocation operation to complete.
const revokeResponse = await issuerClient
    .operations()
    .wait(revokeOperation, AbortSignal.timeout(DEFAULT_TIMEOUT_MS)); // Used revokeOperation directly

// Log the credential status after revocation.
// Note the 'et: "rev"' indicating it's now revoked, and the sequence number 's' has incremented.
const statusAfter = (await issuerClient.credentials().get(credentialSaid)).status;
console.log("Credential status after revocation:", statusAfter);



```

    Credential status before revocation: {
      vn: [ [33m1[39m, [33m0[39m ],
      i: [32m"ECj8x588-SJoBX4ERaClMNuZ3R-5CIEdny31cvT_RhbG"[39m,
      s: [32m"0"[39m,
      d: [32m"EMhosAmvYQNz5YipeQdo72_2S1HSky9gZr1eYREH9RKl"[39m,
      ri: [32m"EFJbqLviCwkUsY47HckIOzgGlS2NyfmRvkgh7izdmJgL"[39m,
      ra: {},
      a: { s: [33m2[39m, d: [32m"EEom_mYN-O-1GxBU7mpkzOoeTBrnRib6yUap9g_oMhpx"[39m },
      dt: [32m"2025-06-05T22:24:22.037000+00:00"[39m,
      et: [32m"iss"[39m
    }


    Credential status after revocation: {
      vn: [ [33m1[39m, [33m0[39m ],
      i: [32m"ECj8x588-SJoBX4ERaClMNuZ3R-5CIEdny31cvT_RhbG"[39m,
      s: [32m"1"[39m,
      d: [32m"EPCsH_HWQqa42v37jYgAXrZqW9SLaJ3x3IqgJhbpCvpD"[39m,
      ri: [32m"EFJbqLviCwkUsY47HckIOzgGlS2NyfmRvkgh7izdmJgL"[39m,
      ra: {},
      a: { s: [33m3[39m, d: [32m"EFDf1wrZSXYesIbHzq3KbMpaMXi_Fmo-aUeBLm7jxfFM"[39m },
      dt: [32m"2025-06-05T22:24:40.327000+00:00"[39m,
      et: [32m"rev"[39m
    }


The output shows the change in the credential's status object:

- Before revocation, `et` (event type) was `iss`.
- After revocation, `et` is `rev`.
- The sequence number `s` of the TEL event also increments, reflecting the new event.
- The digest d of the event changes, as it's a new event.

This demonstrates that the Issuer has successfully updated the credential's status in their registry. Anyone (like a Verifier) who subsequently checks this registry for the credential's status will see that it has been revoked.

Once a Holder becomes aware that a credential they possess has been revoked (e.g., by checking its status in the Issuer's registry or being informed through other means), they should no longer rely on it. It's good practice for the Holder to delete the revoked credential from their local store to prevent accidental presentation.

The `holderClient.credentials().delete()` method removes the credential from the Holder's local client storage.


```typescript
// Holder deletes the (now revoked) credential from their local store.
await holderClient.credentials().delete(credentialSaid);

// Verify the credential is no longer in the Holder's list.
console.log("Holder's credential list after deleting the revoked credential:");
console.log(await holderClient.credentials().list()); // Should be an empty array or not contain the revoked credential

```

    Holder's credential list after deleting the revoked credential:


    []

