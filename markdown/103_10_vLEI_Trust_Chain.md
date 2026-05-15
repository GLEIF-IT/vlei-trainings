# vLEI Trust Chain

<div class="alert alert-primary">
<b>🎯 OBJECTIVE</b><hr>
To provide a practical, hands-on demonstration of the vLEI trust chain using SignifyTS. 
</div>

## The simplified vLEI Trust Chain 

To clearly explain the fundamentals of vLEI credentials and schemas, this notebook presents a simplified model of the credential issuance hierarchy. We will trace the flow of authority and the process of creating chained credentials using official vLEI schema definitions. For the sake of clarity, we have excluded the more advanced topics of multisignatures and delegated identifier structures, which are key components of the complete vLEI production trust chain. A practical, in-depth example of these advanced features can be found in the **[qvi-software repository](https://github.com/GLEIF-IT/qvi-software/tree/main/qvi-workflow)**.

The outcome of this training is to produce a verification chain similar to the one shown below except that all identifiers are single signature identifiers instead of multi-signature identifiers.

![vLEI Verification Chain](./images/vlei-verification-chain.png)

## Setup Phase

The first step is to create the four distinct identity clients that represent the actors in our scenario: GLEIF, a Qualified vLEI Issuer (QVI), a Legal Entity (LE), and a Role holder. We will establish secure connections between all relevant parties using OOBIs and create the necessary credential registries for the issuers.


```typescript
import { randomPasscode, Saider} from 'npm:signify-ts@0.3.0-rc1';
import { 
  initializeSignify, initializeAndConnectClient, createNewAID, addEndRoleForAID,
  generateOOBI, resolveOOBI, createCredentialRegistry, issueCredential,
  ipexGrantCredential, getCredentialState, waitForAndGetNotification,
  ipexAdmitGrant, markNotificationRead,
  DEFAULT_IDENTIFIER_ARGS, ROLE_AGENT, IPEX_GRANT_ROUTE, IPEX_ADMIT_ROUTE, SCHEMA_SERVER_HOST,
  prTitle, prMessage, prContinue, prAlert, isServiceHealthy, sleep
} from './scripts_ts/utils.ts';

initializeSignify()

// Create clients, AIDs and OOBIs.
prTitle("Creating clients setup")

// Fixed Bran to keep a consistent root of trust (DO NOT MODIFY or else validation with the Sally verifier will break)
const gleifBran = "Dm8Tmz05CF6_JLX9sVlFe" 
const gleifAlias = 'gleif'
const { client: gleifClient } = await initializeAndConnectClient(gleifBran)
let gleifPrefix

// GLEIF GEDA (GLEIF External Delegated AID) setup
// uses try/catch to permit reusing existing GEDA upon re-run of this test file.
try{
    const gleifAid = await gleifClient.identifiers().get(gleifAlias);
    gleifPrefix = gleifAid.prefix
} catch {
    prMessage("Creating GLEIF AID")
    const { aid: newAid} = await createNewAID(gleifClient, gleifAlias, DEFAULT_IDENTIFIER_ARGS);
    await addEndRoleForAID(gleifClient, gleifAlias, ROLE_AGENT); 
    gleifPrefix = newAid.i
}
const gleifOOBI = await generateOOBI(gleifClient, gleifAlias, ROLE_AGENT);

prMessage(`GLEIF Prefix: ${gleifPrefix}`)

// QVI
const qviBran = randomPasscode()
const qviAlias = 'qvi'
const { client: qviClient } = await initializeAndConnectClient(qviBran)
const { aid: qviAid} = await createNewAID(qviClient, qviAlias, DEFAULT_IDENTIFIER_ARGS);
await addEndRoleForAID(qviClient, qviAlias, ROLE_AGENT);
const qviOOBI = await generateOOBI(qviClient, qviAlias, ROLE_AGENT);
const qviPrefix = qviAid.i
prMessage(`QVI Prefix: ${qviPrefix}`)

// LE
const leBran = randomPasscode()
const leAlias = 'le'
const { client: leClient } = await initializeAndConnectClient(leBran)
const { aid: leAid} = await createNewAID(leClient, leAlias, DEFAULT_IDENTIFIER_ARGS);
await addEndRoleForAID(leClient, leAlias, ROLE_AGENT);
const leOOBI = await generateOOBI(leClient, leAlias, ROLE_AGENT);
const lePrefix = leAid.i
prMessage(`LE Prefix: ${lePrefix}`)

// Role Holder
const roleBran = randomPasscode()
const roleAlias = 'role'
const { client: roleClient } = await initializeAndConnectClient(roleBran)
const { aid: roleAid} = await createNewAID(roleClient, roleAlias, DEFAULT_IDENTIFIER_ARGS);
await addEndRoleForAID(roleClient, roleAlias, ROLE_AGENT);
const roleOOBI = await generateOOBI(roleClient, roleAlias, ROLE_AGENT);
const rolePrefix = roleAid.i
prMessage(`ROLE Prefix: ${rolePrefix}`)

// Client OOBI resolution (Create contacts)
prTitle("Resolving OOBIs")

await Promise.all([
    resolveOOBI(gleifClient, qviOOBI, qviAlias),
    resolveOOBI(qviClient, gleifOOBI, gleifAlias),
    resolveOOBI(qviClient, leOOBI, leAlias),
    resolveOOBI(qviClient, roleOOBI, roleAlias),
    resolveOOBI(leClient, gleifOOBI, gleifAlias),
    resolveOOBI(leClient, qviOOBI, qviAlias),
    resolveOOBI(leClient, roleOOBI, roleAlias),
    resolveOOBI(roleClient, gleifOOBI, gleifAlias),
    resolveOOBI(roleClient, leOOBI, leAlias),
    resolveOOBI(roleClient, qviOOBI, qviAlias)
]);

// Create Credential Registries
prTitle("Creating Credential Registries")

// GLEIF GEDA Registry
// uses try/catch to permit reusing existing GEDA upon re-run of this test file.
let gleifRegistrySaid
try{
    const registries = await gleifClient.registries().list(gleifAlias);
    gleifRegistrySaid = registries[0].regk
} catch {
    prMessage("Creating GLEIF Registry")
    const { registrySaid: newRegistrySaid } = await createCredentialRegistry(gleifClient, gleifAlias, 'gleifRegistry')
    gleifRegistrySaid = newRegistrySaid
}
// QVI and LE registry
const { registrySaid: qviRegistrySaid } = await createCredentialRegistry(qviClient, qviAlias, 'qviRegistry')
const { registrySaid: leRegistrySaid } = await createCredentialRegistry(leClient, leAlias, 'leRegistry')

prContinue()
```

    
      Creating clients setup  
    
    Using Passcode (bran): Dm8Tmz05CF6_JLX9sVlFe
    Signify-ts library initialized.
    Client boot process initiated with KERIA agent.
      Client AID Prefix:  EAahBlwoMzpTutCwwyc8QitdbzrbLXhKLuydIbVOGjCM
      Agent AID Prefix:   EKtDG7pLmYMforv2XuNouqMWIslaw3n79QZq8q7RBI2d
    Generating OOBI for AID alias gleif with role agent
    Generated OOBI URL: http://keria:3902/oobi/EECGZ7vbYzOM1FWicPFIot-4AiteMX6Xr5htEVAA5Iq2/agent/EKtDG7pLmYMforv2XuNouqMWIslaw3n79QZq8q7RBI2d
    
    GLEIF Prefix: EECGZ7vbYzOM1FWicPFIot-4AiteMX6Xr5htEVAA5Iq2
    
    Using Passcode (bran): AaGt5rjZRDve7qEBKef6s
    Client boot process initiated with KERIA agent.
      Client AID Prefix:  EH2GiFoVXWi4D0ktUE6NwpCNQZj6PpgQmbCGZ2OOd03f
      Agent AID Prefix:   EMlCbBalJtkWpjzbHdvy238bud0S03AEnwb6aUbunUYZ
    Initiating AID inception for alias: qvi
    Successfully created AID with prefix: ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB
    Assigning 'agent' role to KERIA Agent EMlCbBalJtkWpjzbHdvy238bud0S03AEnwb6aUbunUYZ for AID alias qvi
    Successfully assigned 'agent' role for AID alias qvi.
    Generating OOBI for AID alias qvi with role agent
    Generated OOBI URL: http://keria:3902/oobi/ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB/agent/EMlCbBalJtkWpjzbHdvy238bud0S03AEnwb6aUbunUYZ
    
    QVI Prefix: ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB
    
    Using Passcode (bran): D3JcdQhJMIUQJx1_iBSXr
    Client boot process initiated with KERIA agent.
      Client AID Prefix:  EE2eDDu0qaAxZvHkmKcYyFzS-RK_fPtfKI07AxvzebEu
      Agent AID Prefix:   EMRKCrs8TUM_6fo143ofNksU7m8zdeBVuDVhOUMx9yx3
    Initiating AID inception for alias: le
    Successfully created AID with prefix: ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ
    Assigning 'agent' role to KERIA Agent EMRKCrs8TUM_6fo143ofNksU7m8zdeBVuDVhOUMx9yx3 for AID alias le
    Successfully assigned 'agent' role for AID alias le.
    Generating OOBI for AID alias le with role agent
    Generated OOBI URL: http://keria:3902/oobi/ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ/agent/EMRKCrs8TUM_6fo143ofNksU7m8zdeBVuDVhOUMx9yx3
    
    LE Prefix: ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ
    
    Using Passcode (bran): CimFJ8s6BsfubR513PBv0
    Client boot process initiated with KERIA agent.
      Client AID Prefix:  ELIptEqv5mFrsJU-hqbhoUCgyzhChxt732EVF2GZanWC
      Agent AID Prefix:   EKS9HxyPWFbx9pvrhHq5xLBR8CfkCwD5KrkUoGwWWoRp
    Initiating AID inception for alias: role
    Successfully created AID with prefix: EHdZZzxpaPDxHkPNeAwxYje5ngW0GPzSQCqnutfO5Bbu
    Assigning 'agent' role to KERIA Agent EKS9HxyPWFbx9pvrhHq5xLBR8CfkCwD5KrkUoGwWWoRp for AID alias role
    Successfully assigned 'agent' role for AID alias role.
    Generating OOBI for AID alias role with role agent
    Generated OOBI URL: http://keria:3902/oobi/EHdZZzxpaPDxHkPNeAwxYje5ngW0GPzSQCqnutfO5Bbu/agent/EKS9HxyPWFbx9pvrhHq5xLBR8CfkCwD5KrkUoGwWWoRp
    
    ROLE Prefix: EHdZZzxpaPDxHkPNeAwxYje5ngW0GPzSQCqnutfO5Bbu
    
    
      Resolving OOBIs  
    
    Resolving OOBI URL: http://keria:3902/oobi/ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB/agent/EMlCbBalJtkWpjzbHdvy238bud0S03AEnwb6aUbunUYZ with alias qvi
    Resolving OOBI URL: http://keria:3902/oobi/EECGZ7vbYzOM1FWicPFIot-4AiteMX6Xr5htEVAA5Iq2/agent/EKtDG7pLmYMforv2XuNouqMWIslaw3n79QZq8q7RBI2d with alias gleif
    Resolving OOBI URL: http://keria:3902/oobi/ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ/agent/EMRKCrs8TUM_6fo143ofNksU7m8zdeBVuDVhOUMx9yx3 with alias le
    Resolving OOBI URL: http://keria:3902/oobi/EHdZZzxpaPDxHkPNeAwxYje5ngW0GPzSQCqnutfO5Bbu/agent/EKS9HxyPWFbx9pvrhHq5xLBR8CfkCwD5KrkUoGwWWoRp with alias role
    Resolving OOBI URL: http://keria:3902/oobi/EECGZ7vbYzOM1FWicPFIot-4AiteMX6Xr5htEVAA5Iq2/agent/EKtDG7pLmYMforv2XuNouqMWIslaw3n79QZq8q7RBI2d with alias gleif
    Resolving OOBI URL: http://keria:3902/oobi/ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB/agent/EMlCbBalJtkWpjzbHdvy238bud0S03AEnwb6aUbunUYZ with alias qvi
    Resolving OOBI URL: http://keria:3902/oobi/EHdZZzxpaPDxHkPNeAwxYje5ngW0GPzSQCqnutfO5Bbu/agent/EKS9HxyPWFbx9pvrhHq5xLBR8CfkCwD5KrkUoGwWWoRp with alias role
    Resolving OOBI URL: http://keria:3902/oobi/EECGZ7vbYzOM1FWicPFIot-4AiteMX6Xr5htEVAA5Iq2/agent/EKtDG7pLmYMforv2XuNouqMWIslaw3n79QZq8q7RBI2d with alias gleif
    Resolving OOBI URL: http://keria:3902/oobi/ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ/agent/EMRKCrs8TUM_6fo143ofNksU7m8zdeBVuDVhOUMx9yx3 with alias le
    Resolving OOBI URL: http://keria:3902/oobi/ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB/agent/EMlCbBalJtkWpjzbHdvy238bud0S03AEnwb6aUbunUYZ with alias qvi
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Contact "qvi" added/updated.
    Contact "le" added/updated.
    Contact "qvi" added/updated.
    Contact "gleif" added/updated.
    Contact "role" added/updated.
    Contact "le" added/updated.
    Contact "gleif" added/updated.
    Contact "role" added/updated.
    Contact "qvi" added/updated.
    Contact "gleif" added/updated.
    
      Creating Credential Registries  
    
    Creating credential registry "qviRegistry" for AID alias "qvi"...
    Successfully created credential registry: ED7V4aCJrFccq8vtvExmQW12pIe25ZT381275ZgWLxwl
    Creating credential registry "leRegistry" for AID alias "le"...
    Successfully created credential registry: EIWmQXgTeIg3XK_ixkyZST4_h7L6AdEjtXe9iMrFU31r
    
      You can continue ✅  
    
    


## Schema Resolution

For any party to issue or verify a credential, they must first have a copy of its corresponding schema. The schemas define the structure, attributes, and rules for each type of vLEI credential. In this ecosystem, schemas are identified by a SAID and are hosted on a schema server. All participants will resolve the OOBIs for the schemas they need to interact with.

The schemas used in this demonstration are:

- **QVI Credential**: Issued by GLEIF to a QVI, authorizing it to issue vLEI credentials.
- **vLEI Credential**: Issued by a QVI to a Legal Entity, representing its digital identity.
- **OOR Auth Credential**: An authorization issued by a Legal Entity to a QVI, permitting the QVI to issue a specific OOR credential on its behalf.
- **OOR Credential**: Issued to an individual in an official capacity (e.g., CEO), based on an OOR authorization.
- **ECR Auth Credential**: An authorization issued by a Legal Entity, permitting another party (like a QVI) to issue an ECR credential on its behalf.
- **ECR Credential**: Issued to an individual for a specific business role or context (e.g., Project Manager), based on an ECR authorization or issued directly by the LE.

<div class="alert alert-info">
<b>ℹ️ NOTE</b><hr>
For this demonstration, the vLEI schemas are pre-loaded into our local schema server, and their SAIDs are known beforehand.
</div>


```typescript
// Schemas

// vLEI Schema SAIDs. These are well known schemas. Already preloaded
const QVI_SCHEMA_SAID = 'EBfdlu8R27Fbx-ehrqwImnK-8Cm79sqbAQ4MmvEAYqao';
const LE_SCHEMA_SAID = 'ENPXp1vQzRF6JwIuS-mp2U8Uf1MoADoP_GqQ62VsDZWY';
const ECR_AUTH_SCHEMA_SAID = 'EH6ekLjSr8V32WyFbGe1zXjTzFs9PkTYmupJ9H65O14g';
const ECR_SCHEMA_SAID = 'EEy9PkikFcANV1l7EHukCeXqrzT1hNZjGlUk7wuMO5jw';
const OOR_AUTH_SCHEMA_SAID = 'EKA57bKBKxr_kN7iN5i7lMUxpMG-s19dRcmov1iDxz-E';
const OOR_SCHEMA_SAID = 'EBNaNu-M9P5cgrnfl2Fvymy4E_jvxxyjb70PRtiANlJy';

const QVI_SCHEMA_URL = `${SCHEMA_SERVER_HOST}/oobi/${QVI_SCHEMA_SAID}`;
const LE_SCHEMA_URL = `${SCHEMA_SERVER_HOST}/oobi/${LE_SCHEMA_SAID}`;
const ECR_AUTH_SCHEMA_URL = `${SCHEMA_SERVER_HOST}/oobi/${ECR_AUTH_SCHEMA_SAID}`;
const ECR_SCHEMA_URL = `${SCHEMA_SERVER_HOST}/oobi/${ECR_SCHEMA_SAID}`;
const OOR_AUTH_SCHEMA_URL = `${SCHEMA_SERVER_HOST}/oobi/${OOR_AUTH_SCHEMA_SAID}`;
const OOR_SCHEMA_URL = `${SCHEMA_SERVER_HOST}/oobi/${OOR_SCHEMA_SAID}`;

prTitle("Schema OOBIs")
prMessage(`QVI_SCHEMA_URL:\n  - ${QVI_SCHEMA_URL}`)
prMessage(`LE_SCHEMA_URL:\n  - ${LE_SCHEMA_URL}`)
prMessage(`ECR_AUTH_SCHEMA_URL:\n  - ${ECR_AUTH_SCHEMA_URL}`)
prMessage(`ECR_SCHEMA_URL:\n  - ${ECR_SCHEMA_URL}`)
prMessage(`OOR_AUTH_SCHEMA_URL:\n  - ${OOR_AUTH_SCHEMA_URL}`)
prMessage(`OOR_SCHEMA_URL:\n  - ${OOR_SCHEMA_URL}`)

prContinue()
```

    
      Schema OOBIs  
    
    
    QVI_SCHEMA_URL:
      - http://vlei-server:7723/oobi/EBfdlu8R27Fbx-ehrqwImnK-8Cm79sqbAQ4MmvEAYqao
    
    
    LE_SCHEMA_URL:
      - http://vlei-server:7723/oobi/ENPXp1vQzRF6JwIuS-mp2U8Uf1MoADoP_GqQ62VsDZWY
    
    
    ECR_AUTH_SCHEMA_URL:
      - http://vlei-server:7723/oobi/EH6ekLjSr8V32WyFbGe1zXjTzFs9PkTYmupJ9H65O14g
    
    
    ECR_SCHEMA_URL:
      - http://vlei-server:7723/oobi/EEy9PkikFcANV1l7EHukCeXqrzT1hNZjGlUk7wuMO5jw
    
    
    OOR_AUTH_SCHEMA_URL:
      - http://vlei-server:7723/oobi/EKA57bKBKxr_kN7iN5i7lMUxpMG-s19dRcmov1iDxz-E
    
    
    OOR_SCHEMA_URL:
      - http://vlei-server:7723/oobi/EBNaNu-M9P5cgrnfl2Fvymy4E_jvxxyjb70PRtiANlJy
    
    
      You can continue ✅  
    
    


All clients now resolve all the necessary schemas in order to have knowledge of the schemas they use.


```typescript
prTitle("Resolving Schemas")
await Promise.all([
    resolveOOBI(gleifClient, QVI_SCHEMA_URL),
    
    resolveOOBI(qviClient, QVI_SCHEMA_URL),
    resolveOOBI(qviClient, LE_SCHEMA_URL),
    resolveOOBI(qviClient, ECR_AUTH_SCHEMA_URL),
    resolveOOBI(qviClient, ECR_SCHEMA_URL),
    resolveOOBI(qviClient, OOR_AUTH_SCHEMA_URL),
    resolveOOBI(qviClient, OOR_SCHEMA_URL),
    
    resolveOOBI(leClient, QVI_SCHEMA_URL),
    resolveOOBI(leClient, LE_SCHEMA_URL),
    resolveOOBI(leClient, ECR_AUTH_SCHEMA_URL),
    resolveOOBI(leClient, ECR_SCHEMA_URL),
    resolveOOBI(leClient, OOR_AUTH_SCHEMA_URL),
    resolveOOBI(leClient, OOR_SCHEMA_URL),
    
    resolveOOBI(roleClient, QVI_SCHEMA_URL),
    resolveOOBI(roleClient, LE_SCHEMA_URL),
    resolveOOBI(roleClient, ECR_AUTH_SCHEMA_URL),
    resolveOOBI(roleClient, ECR_SCHEMA_URL),
    resolveOOBI(roleClient, OOR_AUTH_SCHEMA_URL),
    resolveOOBI(roleClient, OOR_SCHEMA_URL),
]);

prContinue()
```

    
      Resolving Schemas  
    
    Resolving OOBI URL: http://vlei-server:7723/oobi/EBfdlu8R27Fbx-ehrqwImnK-8Cm79sqbAQ4MmvEAYqao with alias undefined
    Resolving OOBI URL: http://vlei-server:7723/oobi/EBfdlu8R27Fbx-ehrqwImnK-8Cm79sqbAQ4MmvEAYqao with alias undefined
    Resolving OOBI URL: http://vlei-server:7723/oobi/ENPXp1vQzRF6JwIuS-mp2U8Uf1MoADoP_GqQ62VsDZWY with alias undefined
    Resolving OOBI URL: http://vlei-server:7723/oobi/EH6ekLjSr8V32WyFbGe1zXjTzFs9PkTYmupJ9H65O14g with alias undefined
    Resolving OOBI URL: http://vlei-server:7723/oobi/EEy9PkikFcANV1l7EHukCeXqrzT1hNZjGlUk7wuMO5jw with alias undefined
    Resolving OOBI URL: http://vlei-server:7723/oobi/EKA57bKBKxr_kN7iN5i7lMUxpMG-s19dRcmov1iDxz-E with alias undefined
    Resolving OOBI URL: http://vlei-server:7723/oobi/EBNaNu-M9P5cgrnfl2Fvymy4E_jvxxyjb70PRtiANlJy with alias undefined
    Resolving OOBI URL: http://vlei-server:7723/oobi/EBfdlu8R27Fbx-ehrqwImnK-8Cm79sqbAQ4MmvEAYqao with alias undefined
    Resolving OOBI URL: http://vlei-server:7723/oobi/ENPXp1vQzRF6JwIuS-mp2U8Uf1MoADoP_GqQ62VsDZWY with alias undefined
    Resolving OOBI URL: http://vlei-server:7723/oobi/EH6ekLjSr8V32WyFbGe1zXjTzFs9PkTYmupJ9H65O14g with alias undefined
    Resolving OOBI URL: http://vlei-server:7723/oobi/EEy9PkikFcANV1l7EHukCeXqrzT1hNZjGlUk7wuMO5jw with alias undefined
    Resolving OOBI URL: http://vlei-server:7723/oobi/EKA57bKBKxr_kN7iN5i7lMUxpMG-s19dRcmov1iDxz-E with alias undefined
    Resolving OOBI URL: http://vlei-server:7723/oobi/EBNaNu-M9P5cgrnfl2Fvymy4E_jvxxyjb70PRtiANlJy with alias undefined
    Resolving OOBI URL: http://vlei-server:7723/oobi/EBfdlu8R27Fbx-ehrqwImnK-8Cm79sqbAQ4MmvEAYqao with alias undefined
    Resolving OOBI URL: http://vlei-server:7723/oobi/ENPXp1vQzRF6JwIuS-mp2U8Uf1MoADoP_GqQ62VsDZWY with alias undefined
    Resolving OOBI URL: http://vlei-server:7723/oobi/EH6ekLjSr8V32WyFbGe1zXjTzFs9PkTYmupJ9H65O14g with alias undefined
    Resolving OOBI URL: http://vlei-server:7723/oobi/EEy9PkikFcANV1l7EHukCeXqrzT1hNZjGlUk7wuMO5jw with alias undefined
    Resolving OOBI URL: http://vlei-server:7723/oobi/EKA57bKBKxr_kN7iN5i7lMUxpMG-s19dRcmov1iDxz-E with alias undefined
    Resolving OOBI URL: http://vlei-server:7723/oobi/EBNaNu-M9P5cgrnfl2Fvymy4E_jvxxyjb70PRtiANlJy with alias undefined
    Successfully resolved OOBI URL. Response: OK
    Contact "undefined" added/updated.
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Successfully resolved OOBI URL. Response: OK
    Contact "undefined" added/updated.
    Contact "undefined" added/updated.
    Contact "undefined" added/updated.
    Contact "undefined" added/updated.
    Contact "undefined" added/updated.
    Contact "undefined" added/updated.
    Contact "undefined" added/updated.
    Contact "undefined" added/updated.
    Contact "undefined" added/updated.
    Contact "undefined" added/updated.
    Contact "undefined" added/updated.
    Contact "undefined" added/updated.
    Contact "undefined" added/updated.
    Contact "undefined" added/updated.
    Contact "undefined" added/updated.
    Contact "undefined" added/updated.
    Contact "undefined" added/updated.
    Contact "undefined" added/updated.
    
      You can continue ✅  
    
    


## Credential Issuance Chain
The core of this demonstration is to build the vLEI trust chain credential by credential. The test follows the official vLEI ecosystem hierarchy, showing how authority is passed down from GLEIF to a QVI, then to a Legal Entity, and finally to an individual Role Holder.

The issuance flow is as follows:

- **QVI Credential**: GLEIF issues a "Qualified vLEI Issuer" credential to the QVI.
- **LE Credential**: The QVI issues a "Legal Entity" credential to the LE.
- **OOR Auth Credential**: The LE issues an "Official Organizational Role" authorization to the QVI.
- **OOR Credential**: The QVI, using the authorization from the previous step, issues the final OOR credential to the Role holder.
- **ECR Auth Credential**: The LE issues an "Engagement Context Role" authorization credential to the QVI.
- **ECR Credential (Path 1)**: The LE directly issues an ECR credential to the Role holder.
- **ECR Credential (Path 2)**: The QVI issues another ECR credential to the same Role holder, this time using the ECR authorization credential.

The key to this chain of trust lies within the `e` (edges) block of each ACDC. This block contains cryptographic pointers to the credential that authorizes the issuance of the current one. We will examine these edge blocks at each step to see how the chain is formed.

### Step 1: QVI Credential - GLEIF issues a Qualified vLEI Issuer credential to the QVI

The chain of trust begins with GLEIF, the root of the ecosystem, issuing a credential to a QVI. This credential attests that the QVI is qualified and authorized to issue vLEI credentials to other legal entities. As the first link in our chain, this credential does not have an edge block pointing to a prior authority.




```typescript
// QVI LEI (Arbitrary value)
const qviData = {
    LEI: '254900OPPU84GM83MG36',
};

// GLEIF - Issue credential
prTitle("Issuing Credential")
const { credentialSaid: credentialSaid} = await issueCredential(
    gleifClient, gleifAlias, gleifRegistrySaid, 
    QVI_SCHEMA_SAID, 
    qviPrefix, 
    qviData
)

// GLEIF - get credential
const qviCredential = await gleifClient.credentials().get(credentialSaid);

// GLEIF - Ipex grant
prTitle("Granting Credential")
const grantResponse = await ipexGrantCredential(
    gleifClient, gleifAlias, 
    qviPrefix, 
    qviCredential
)

// QVI - Wait for grant notification
const grantNotifications = await waitForAndGetNotification(qviClient, IPEX_GRANT_ROUTE)
const grantNotification = grantNotifications[0]

// QVI - Admit Grant
prTitle("Admitting Grant")
const admitResponse = await ipexAdmitGrant(
    qviClient, qviAlias,
    gleifPrefix, 
    grantNotification.a.d
)

// QVI - Mark notification
await markNotificationRead(qviClient, grantNotification.i)

// GLEIF - Wait for admit notification
const admitNotifications = await waitForAndGetNotification(gleifClient, IPEX_ADMIT_ROUTE)
const admitNotification = admitNotifications[0]

// GLEIF - Mark notification
await markNotificationRead(gleifClient, admitNotification.i)

prContinue()
```

    
      Issuing Credential  
    
    Issuing credential from AID "gleif" to AID "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB"...
    {
      name: "credential.EC6fjMGfTBcj3qlj4MkqgZrpz1W-7tXonEhK6WAIX7jJ",
      metadata: {
        ced: {
          v: "ACDC10JSON000197_",
          d: "EC6fjMGfTBcj3qlj4MkqgZrpz1W-7tXonEhK6WAIX7jJ",
          i: "EECGZ7vbYzOM1FWicPFIot-4AiteMX6Xr5htEVAA5Iq2",
          ri: "EO6JNHwIxVoTPrp8NRGjLaftgeCHMrMAnUU1viAuK-ao",
          s: "EBfdlu8R27Fbx-ehrqwImnK-8Cm79sqbAQ4MmvEAYqao",
          a: {
            d: "EHCnsk0W_pXvmscUuqT2HBcL_Rrf6DXvysZCucdxHu7l",
            i: "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB",
            LEI: "254900OPPU84GM83MG36",
            dt: "2025-09-12T04:32:10.380000+00:00"
          }
        },
        depends: {
          name: "witness.EHDzSCDcguepq3FImANHtYY7HqUbwjcP1oFRSASVUF1s",
          metadata: { pre: "EECGZ7vbYzOM1FWicPFIot-4AiteMX6Xr5htEVAA5Iq2", sn: 4 },
          done: false,
          error: null,
          response: null
        }
      },
      done: true,
      error: null,
      response: {
        ced: {
          v: "ACDC10JSON000197_",
          d: "EC6fjMGfTBcj3qlj4MkqgZrpz1W-7tXonEhK6WAIX7jJ",
          i: "EECGZ7vbYzOM1FWicPFIot-4AiteMX6Xr5htEVAA5Iq2",
          ri: "EO6JNHwIxVoTPrp8NRGjLaftgeCHMrMAnUU1viAuK-ao",
          s: "EBfdlu8R27Fbx-ehrqwImnK-8Cm79sqbAQ4MmvEAYqao",
          a: {
            d: "EHCnsk0W_pXvmscUuqT2HBcL_Rrf6DXvysZCucdxHu7l",
            i: "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB",
            LEI: "254900OPPU84GM83MG36",
            dt: "2025-09-12T04:32:10.380000+00:00"
          }
        }
      }
    }
    Successfully issued credential with SAID: EC6fjMGfTBcj3qlj4MkqgZrpz1W-7tXonEhK6WAIX7jJ
    
      Granting Credential  
    
    AID "gleif" granting credential to AID "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB" via IPEX...
    Successfully submitted IPEX grant from "gleif" to "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB".
    Waiting for notification with route "/exn/ipex/grant"...
    [Retry] Grant notification not found on attempt #1 of 5
    [Retry] Waiting 5000ms before next attempt...
    
      Admitting Grant  
    
    AID "qvi" admitting IPEX grant "ECtHXWPGioUGvZ8MNtzVFat_ryOQx62tsG3ya5gZqZGq" from AID "EECGZ7vbYzOM1FWicPFIot-4AiteMX6Xr5htEVAA5Iq2"...
    Successfully submitted IPEX admit for grant "ECtHXWPGioUGvZ8MNtzVFat_ryOQx62tsG3ya5gZqZGq".
    Marking notification "0AAkw4s9oss0I0tyD_pHQ4XB" as read...
    Notification "0AAkw4s9oss0I0tyD_pHQ4XB" marked as read.
    Waiting for notification with route "/exn/ipex/admit"...
    Marking notification "0AAwyvF4dim2WDtHeRavwVzi" as read...
    Notification "0AAwyvF4dim2WDtHeRavwVzi" marked as read.
    
      You can continue ✅  
    
    


### Step 2: LE Credential - QVI issues a Legal Entity credential to the LE

Now that the QVI is authorized, it can issue a vLEI credential to a Legal Entity. To maintain the chain of trust, this new LE Credential must be cryptographically linked back to the QVI's authorizing credential.

This link is created in the `leEdge` object.

- `n: qviCredential.sad.d`: The `n` field (node) is populated with the SAID of the QVI's own credential, issued in Step 1. This is the direct cryptographic pointer.
- `s: qviCredential.sad.s`: The `s` field specifies the required schema SAID of the credential being pointed to, ensuring the link is to the correct type of credential.

The `Saider.saidify()` function is a utility that makes this edge block itself verifiable. It calculates a cryptographic digest (SAID) of the edge's content and embeds that digest back into the block under the `d` field.


```typescript
// Credential Data
const leData = {
    LEI: '875500ELOZEL05BVXV37',
};

const leEdge = Saider.saidify({
    d: '',
    qvi: {
        n: qviCredential.sad.d,
        s: qviCredential.sad.s,
    },
})[1];

const leRules = Saider.saidify({
    d: '',
    usageDisclaimer: {
        l: 'Usage of a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, does not assert that the Legal Entity is trustworthy, honest, reputable in its business dealings, safe to do business with, or compliant with any laws or that an implied or expressly intended purpose will be fulfilled.',
    },
    issuanceDisclaimer: {
        l: 'All information in a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, is accurate as of the date the validation process was complete. The vLEI Credential has been issued to the legal entity or person named in the vLEI Credential as the subject; and the qualified vLEI Issuer exercised reasonable care to perform the validation process set forth in the vLEI Ecosystem Governance Framework.',
    },
})[1];

// qvi - Issue credential
prTitle("Issuing Credential")
const { credentialSaid: credentialSaid} = await issueCredential(
    qviClient, qviAlias, qviRegistrySaid, 
    LE_SCHEMA_SAID, 
    lePrefix,
    leData, leEdge, leRules
)

// qvi - get credential (with all its data)
prTitle("Granting Credential")
const leCredential = await qviClient.credentials().get(credentialSaid);

// qvi - Ipex grant
const grantResponse = await ipexGrantCredential(
    qviClient, qviAlias, 
    lePrefix, 
    leCredential
)

// LE - Wait for grant notification
const grantNotifications = await waitForAndGetNotification(leClient, IPEX_GRANT_ROUTE)
const grantNotification = grantNotifications[0]

// LE - Admit Grant
prTitle("Admitting Grant")
const admitResponse = await ipexAdmitGrant(
    leClient, leAlias,
    qviPrefix, 
    grantNotification.a.d
)

// LE - Mark notification
await markNotificationRead(leClient, grantNotification.i)

// QVI - Wait for admit notification
const admitNotifications = await waitForAndGetNotification(qviClient, IPEX_ADMIT_ROUTE)
const admitNotification = admitNotifications[0]

// QVI - Mark notification
await markNotificationRead(qviClient, admitNotification.i)

prContinue()
```

    
      Issuing Credential  
    
    Issuing credential from AID "qvi" to AID "ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ"...
    {
      name: "credential.EEbwZ1kvlmJmjS-w7wqMXUnHGH_jf7aGszTSyYrZsOYW",
      metadata: {
        ced: {
          v: "ACDC10JSON0005c8_",
          d: "EEbwZ1kvlmJmjS-w7wqMXUnHGH_jf7aGszTSyYrZsOYW",
          i: "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB",
          ri: "ED7V4aCJrFccq8vtvExmQW12pIe25ZT381275ZgWLxwl",
          s: "ENPXp1vQzRF6JwIuS-mp2U8Uf1MoADoP_GqQ62VsDZWY",
          a: {
            d: "EJbsRgbWE3bIalbOp7rp1pvAeC5VTgP0zUBfCcrCSsEB",
            i: "ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ",
            LEI: "875500ELOZEL05BVXV37",
            dt: "2025-09-12T04:32:18.699000+00:00"
          },
          e: {
            d: "ENwYh-0Hwkz7rqeTb2M_pLUS4IKcycGYjsuIbzbMk-cq",
            qvi: {
              n: "EC6fjMGfTBcj3qlj4MkqgZrpz1W-7tXonEhK6WAIX7jJ",
              s: "EBfdlu8R27Fbx-ehrqwImnK-8Cm79sqbAQ4MmvEAYqao"
            }
          },
          r: {
            d: "EGZ97EjPSINR-O-KHDN_uw4fdrTxeuRXrqT5ZHHQJujQ",
            usageDisclaimer: {
              l: "Usage of a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, does not assert that the Legal Entity is trustworthy, honest, reputable in its business dealings, safe to do business with, or compliant with any laws or that an implied or expressly intended purpose will be fulfilled."
            },
            issuanceDisclaimer: {
              l: "All information in a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, is accurate as of the date the validation process was complete. The vLEI Credential has been issued to the legal entity or person named in the vLEI Credential as the subject; and the qualified vLEI Issuer exercised reasonable care to perform the validation process set forth in the vLEI Ecosystem Governance Framework."
            }
          }
        },
        depends: {
          name: "witness.EIgEL2I5DagKseoLud6SezCvNwB5aM0Ak96qvVj34ZlZ",
          metadata: { pre: "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB", sn: 2 },
          done: false,
          error: null,
          response: null
        }
      },
      done: true,
      error: null,
      response: {
        ced: {
          v: "ACDC10JSON0005c8_",
          d: "EEbwZ1kvlmJmjS-w7wqMXUnHGH_jf7aGszTSyYrZsOYW",
          i: "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB",
          ri: "ED7V4aCJrFccq8vtvExmQW12pIe25ZT381275ZgWLxwl",
          s: "ENPXp1vQzRF6JwIuS-mp2U8Uf1MoADoP_GqQ62VsDZWY",
          a: {
            d: "EJbsRgbWE3bIalbOp7rp1pvAeC5VTgP0zUBfCcrCSsEB",
            i: "ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ",
            LEI: "875500ELOZEL05BVXV37",
            dt: "2025-09-12T04:32:18.699000+00:00"
          },
          e: {
            d: "ENwYh-0Hwkz7rqeTb2M_pLUS4IKcycGYjsuIbzbMk-cq",
            qvi: {
              n: "EC6fjMGfTBcj3qlj4MkqgZrpz1W-7tXonEhK6WAIX7jJ",
              s: "EBfdlu8R27Fbx-ehrqwImnK-8Cm79sqbAQ4MmvEAYqao"
            }
          },
          r: {
            d: "EGZ97EjPSINR-O-KHDN_uw4fdrTxeuRXrqT5ZHHQJujQ",
            usageDisclaimer: {
              l: "Usage of a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, does not assert that the Legal Entity is trustworthy, honest, reputable in its business dealings, safe to do business with, or compliant with any laws or that an implied or expressly intended purpose will be fulfilled."
            },
            issuanceDisclaimer: {
              l: "All information in a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, is accurate as of the date the validation process was complete. The vLEI Credential has been issued to the legal entity or person named in the vLEI Credential as the subject; and the qualified vLEI Issuer exercised reasonable care to perform the validation process set forth in the vLEI Ecosystem Governance Framework."
            }
          }
        }
      }
    }
    Successfully issued credential with SAID: EEbwZ1kvlmJmjS-w7wqMXUnHGH_jf7aGszTSyYrZsOYW
    
      Granting Credential  
    
    AID "qvi" granting credential to AID "ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ" via IPEX...
    Successfully submitted IPEX grant from "qvi" to "ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ".
    Waiting for notification with route "/exn/ipex/grant"...
    [Retry] Grant notification not found on attempt #1 of 5
    [Retry] Waiting 5000ms before next attempt...
    
      Admitting Grant  
    
    AID "le" admitting IPEX grant "EP6Ss-ASNLSL10HjRStHPHiafzLSZ21UUOfmm-mOXa5a" from AID "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB"...
    Successfully submitted IPEX admit for grant "EP6Ss-ASNLSL10HjRStHPHiafzLSZ21UUOfmm-mOXa5a".
    Marking notification "0ADwUPzGisTInu8vqRY98E9f" as read...
    Notification "0ADwUPzGisTInu8vqRY98E9f" marked as read.
    Waiting for notification with route "/exn/ipex/admit"...
    Marking notification "0ACV-rTeh8sD7KE_jOsQTw6c" as read...
    Notification "0ACV-rTeh8sD7KE_jOsQTw6c" marked as read.
    
      You can continue ✅  
    
    


### Step 3: OOR AUTH Credential - LE issues an Official Organizational Role authorization to QVI

Before a QVI can issue a credential for an official role (like CEO or Director) on behalf of a Legal Entity, it must first receive explicit authorization. This step shows the LE issuing an "OOR Authorization" credential to the QVI.

The edge block here links back to the `leCredential` from **Step 2**, proving that the entity granting this authorization is a valid Legal Entity within the vLEI ecosystem.


```typescript
// Credential Data
const oorAuthData = {
    AID: '',
    LEI: leData.LEI,
    personLegalName: 'Jane Doe',
    officialRole: 'CEO',
};

const oorAuthEdge = Saider.saidify({
    d: '',
    le: {
        n: leCredential.sad.d,
        s: leCredential.sad.s,
    },
})[1];

// LE - Issue credential
prTitle("Issuing Credential")

const { credentialSaid: credentialSaid} = await issueCredential(
    leClient, leAlias, leRegistrySaid, 
    OOR_AUTH_SCHEMA_SAID,
    qviPrefix,
    oorAuthData, oorAuthEdge, leRules // Reuses LE rules
)

// LE - get credential
const oorAuthCredential = await leClient.credentials().get(credentialSaid);

// LE - Ipex grant
prTitle("Granting Credential")

const grantResponse = await ipexGrantCredential(
    leClient, leAlias, 
    qviPrefix,
    oorAuthCredential
)

// QVI - Wait for grant notification
const grantNotifications = await waitForAndGetNotification(qviClient, IPEX_GRANT_ROUTE)
const grantNotification = grantNotifications[0]

// QVI - Admit Grant
prTitle("Admitting Grant")
const admitResponse = await ipexAdmitGrant(
    qviClient, qviAlias,
    lePrefix,
    grantNotification.a.d
)

// QVI - Mark notification
await markNotificationRead(qviClient, grantNotification.i)

// LE - Wait for admit notification
const admitNotifications = await waitForAndGetNotification(leClient, IPEX_ADMIT_ROUTE)
const admitNotification = admitNotifications[0]

// LE - Mark notification
await markNotificationRead(leClient, admitNotification.i)

prContinue()
```

    
      Issuing Credential  
    
    Issuing credential from AID "le" to AID "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB"...
    {
      name: "credential.ENuAxM6nDPLgaFARHz-w2V34Nv0lpup1iLZ3bFw1WfNS",
      metadata: {
        ced: {
          v: "ACDC10JSON000602_",
          d: "ENuAxM6nDPLgaFARHz-w2V34Nv0lpup1iLZ3bFw1WfNS",
          i: "ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ",
          ri: "EIWmQXgTeIg3XK_ixkyZST4_h7L6AdEjtXe9iMrFU31r",
          s: "EKA57bKBKxr_kN7iN5i7lMUxpMG-s19dRcmov1iDxz-E",
          a: {
            d: "ENaSGdLArVp0eburis-MqghDW_Xe7OqzaB2Q6vFnoitS",
            i: "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB",
            AID: "",
            LEI: "875500ELOZEL05BVXV37",
            personLegalName: "Jane Doe",
            officialRole: "CEO",
            dt: "2025-09-12T04:32:27.259000+00:00"
          },
          e: {
            d: "EHW84Tb8rCQN71yG5TDxcmdH5mUuMnXEklYUw_5m-Rnp",
            le: {
              n: "EEbwZ1kvlmJmjS-w7wqMXUnHGH_jf7aGszTSyYrZsOYW",
              s: "ENPXp1vQzRF6JwIuS-mp2U8Uf1MoADoP_GqQ62VsDZWY"
            }
          },
          r: {
            d: "EGZ97EjPSINR-O-KHDN_uw4fdrTxeuRXrqT5ZHHQJujQ",
            usageDisclaimer: {
              l: "Usage of a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, does not assert that the Legal Entity is trustworthy, honest, reputable in its business dealings, safe to do business with, or compliant with any laws or that an implied or expressly intended purpose will be fulfilled."
            },
            issuanceDisclaimer: {
              l: "All information in a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, is accurate as of the date the validation process was complete. The vLEI Credential has been issued to the legal entity or person named in the vLEI Credential as the subject; and the qualified vLEI Issuer exercised reasonable care to perform the validation process set forth in the vLEI Ecosystem Governance Framework."
            }
          }
        },
        depends: {
          name: "witness.EA-FGXuvvlfmQnNTU42NPwIA07FTqkTNEBLsGNRY0tHu",
          metadata: { pre: "ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ", sn: 2 },
          done: false,
          error: null,
          response: null
        }
      },
      done: true,
      error: null,
      response: {
        ced: {
          v: "ACDC10JSON000602_",
          d: "ENuAxM6nDPLgaFARHz-w2V34Nv0lpup1iLZ3bFw1WfNS",
          i: "ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ",
          ri: "EIWmQXgTeIg3XK_ixkyZST4_h7L6AdEjtXe9iMrFU31r",
          s: "EKA57bKBKxr_kN7iN5i7lMUxpMG-s19dRcmov1iDxz-E",
          a: {
            d: "ENaSGdLArVp0eburis-MqghDW_Xe7OqzaB2Q6vFnoitS",
            i: "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB",
            AID: "",
            LEI: "875500ELOZEL05BVXV37",
            personLegalName: "Jane Doe",
            officialRole: "CEO",
            dt: "2025-09-12T04:32:27.259000+00:00"
          },
          e: {
            d: "EHW84Tb8rCQN71yG5TDxcmdH5mUuMnXEklYUw_5m-Rnp",
            le: {
              n: "EEbwZ1kvlmJmjS-w7wqMXUnHGH_jf7aGszTSyYrZsOYW",
              s: "ENPXp1vQzRF6JwIuS-mp2U8Uf1MoADoP_GqQ62VsDZWY"
            }
          },
          r: {
            d: "EGZ97EjPSINR-O-KHDN_uw4fdrTxeuRXrqT5ZHHQJujQ",
            usageDisclaimer: {
              l: "Usage of a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, does not assert that the Legal Entity is trustworthy, honest, reputable in its business dealings, safe to do business with, or compliant with any laws or that an implied or expressly intended purpose will be fulfilled."
            },
            issuanceDisclaimer: {
              l: "All information in a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, is accurate as of the date the validation process was complete. The vLEI Credential has been issued to the legal entity or person named in the vLEI Credential as the subject; and the qualified vLEI Issuer exercised reasonable care to perform the validation process set forth in the vLEI Ecosystem Governance Framework."
            }
          }
        }
      }
    }
    Successfully issued credential with SAID: ENuAxM6nDPLgaFARHz-w2V34Nv0lpup1iLZ3bFw1WfNS
    
      Granting Credential  
    
    AID "le" granting credential to AID "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB" via IPEX...
    Successfully submitted IPEX grant from "le" to "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB".
    Waiting for notification with route "/exn/ipex/grant"...
    [Retry] Grant notification not found on attempt #1 of 5
    [Retry] Waiting 5000ms before next attempt...
    
      Admitting Grant  
    
    AID "qvi" admitting IPEX grant "EEIUgj1kjZpvSNASpgCtA2vapw3mHQXTiyQVCGlQ2lid" from AID "ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ"...
    Successfully submitted IPEX admit for grant "EEIUgj1kjZpvSNASpgCtA2vapw3mHQXTiyQVCGlQ2lid".
    Marking notification "0ADTy070IYJAgVnsOLYRfIwC" as read...
    Notification "0ADTy070IYJAgVnsOLYRfIwC" marked as read.
    Waiting for notification with route "/exn/ipex/admit"...
    Marking notification "0ADbUrKLtAZbvC4IbzFwecbL" as read...
    Notification "0ADbUrKLtAZbvC4IbzFwecbL" marked as read.
    
      You can continue ✅  
    
    


### Step 4: OOR Credential - QVI issues the final OOR credential to the Role holder

Now, with the specific OOR authorization from the LE, the QVI can issue the final OOR credential to the individual Role Holder.

This is a critical link in the chain. The edge block in this new credential points to the `oorAuthCredential` from **Step 3**.

- `o: 'I2I'`: It uses the `I2I` (Issuer-to-Issuee) operator. This enforces a strict rule during verification, the issuer of this OOR credential (the QVI) must be the same entity as the issuee of the authorization credential it's pointing to. This cryptographically proves that the QVI had the correct, specific authorization from the LE to issue this very role credential.


```typescript
// Credential Data
const oorData = {
    LEI: oorAuthData.LEI,
    personLegalName: oorAuthData.personLegalName,
    officialRole: oorAuthData.officialRole,
};

const oorEdge = Saider.saidify({
    d: '',
    auth: {
        n: oorAuthCredential.sad.d,
        s: oorAuthCredential.sad.s,
        o: 'I2I',
    },
})[1];

// QVI - Issue credential
prTitle("Issuing Credential")
const { credentialSaid: credentialSaid} = await issueCredential(
    qviClient, qviAlias, qviRegistrySaid, 
    OOR_SCHEMA_SAID,
    rolePrefix,
    oorData, oorEdge, leRules // Reuses LE rules
)

// QVI - get credential (with all its data)
prTitle("Granting Credential")
const oorCredential = await qviClient.credentials().get(credentialSaid);

// QVI - Ipex grant
const grantResponse = await ipexGrantCredential(
    qviClient, qviAlias, 
    rolePrefix,
    oorCredential
)

// ROLE - Wait for grant notification
const grantNotifications = await waitForAndGetNotification(roleClient, IPEX_GRANT_ROUTE)
const grantNotification = grantNotifications[0]

// ROLE - Admit Grant
prTitle("Admitting Grant")
const admitResponse = await ipexAdmitGrant(
    roleClient, roleAlias,
    qviPrefix,
    grantNotification.a.d
)

// LE - Mark notification
await markNotificationRead(roleClient, grantNotification.i)

// QVI - Wait for admit notification
const admitNotifications = await waitForAndGetNotification(qviClient, IPEX_ADMIT_ROUTE)
const admitNotification = admitNotifications[0]

// QVI - Mark notification
await markNotificationRead(qviClient, admitNotification.i)

prContinue()
```

    
      Issuing Credential  
    
    Issuing credential from AID "qvi" to AID "EHdZZzxpaPDxHkPNeAwxYje5ngW0GPzSQCqnutfO5Bbu"...
    {
      name: "credential.EB86XZdf_4OzaXJsXI6d1tMofyi8lWH8GGjRd85ZUjYT",
      metadata: {
        ced: {
          v: "ACDC10JSON000605_",
          d: "EB86XZdf_4OzaXJsXI6d1tMofyi8lWH8GGjRd85ZUjYT",
          i: "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB",
          ri: "ED7V4aCJrFccq8vtvExmQW12pIe25ZT381275ZgWLxwl",
          s: "EBNaNu-M9P5cgrnfl2Fvymy4E_jvxxyjb70PRtiANlJy",
          a: {
            d: "EKSNM5FjW06oqlwQ0zb10jsxYLGM0DcIGc5Czpx1JtVx",
            i: "EHdZZzxpaPDxHkPNeAwxYje5ngW0GPzSQCqnutfO5Bbu",
            LEI: "875500ELOZEL05BVXV37",
            personLegalName: "Jane Doe",
            officialRole: "CEO",
            dt: "2025-09-12T04:32:35.666000+00:00"
          },
          e: {
            d: "EGCl9jnBuHKKwqNPCyqGXRmEXn78vyJFBuEplqRfQFGP",
            auth: {
              n: "ENuAxM6nDPLgaFARHz-w2V34Nv0lpup1iLZ3bFw1WfNS",
              s: "EKA57bKBKxr_kN7iN5i7lMUxpMG-s19dRcmov1iDxz-E",
              o: "I2I"
            }
          },
          r: {
            d: "EGZ97EjPSINR-O-KHDN_uw4fdrTxeuRXrqT5ZHHQJujQ",
            usageDisclaimer: {
              l: "Usage of a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, does not assert that the Legal Entity is trustworthy, honest, reputable in its business dealings, safe to do business with, or compliant with any laws or that an implied or expressly intended purpose will be fulfilled."
            },
            issuanceDisclaimer: {
              l: "All information in a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, is accurate as of the date the validation process was complete. The vLEI Credential has been issued to the legal entity or person named in the vLEI Credential as the subject; and the qualified vLEI Issuer exercised reasonable care to perform the validation process set forth in the vLEI Ecosystem Governance Framework."
            }
          }
        },
        depends: {
          name: "witness.EFLHKvKxWlZzaYg0GFscNgGe1Od1X0KBm0fTXweBwUY6",
          metadata: { pre: "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB", sn: 3 },
          done: false,
          error: null,
          response: null
        }
      },
      done: true,
      error: null,
      response: {
        ced: {
          v: "ACDC10JSON000605_",
          d: "EB86XZdf_4OzaXJsXI6d1tMofyi8lWH8GGjRd85ZUjYT",
          i: "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB",
          ri: "ED7V4aCJrFccq8vtvExmQW12pIe25ZT381275ZgWLxwl",
          s: "EBNaNu-M9P5cgrnfl2Fvymy4E_jvxxyjb70PRtiANlJy",
          a: {
            d: "EKSNM5FjW06oqlwQ0zb10jsxYLGM0DcIGc5Czpx1JtVx",
            i: "EHdZZzxpaPDxHkPNeAwxYje5ngW0GPzSQCqnutfO5Bbu",
            LEI: "875500ELOZEL05BVXV37",
            personLegalName: "Jane Doe",
            officialRole: "CEO",
            dt: "2025-09-12T04:32:35.666000+00:00"
          },
          e: {
            d: "EGCl9jnBuHKKwqNPCyqGXRmEXn78vyJFBuEplqRfQFGP",
            auth: {
              n: "ENuAxM6nDPLgaFARHz-w2V34Nv0lpup1iLZ3bFw1WfNS",
              s: "EKA57bKBKxr_kN7iN5i7lMUxpMG-s19dRcmov1iDxz-E",
              o: "I2I"
            }
          },
          r: {
            d: "EGZ97EjPSINR-O-KHDN_uw4fdrTxeuRXrqT5ZHHQJujQ",
            usageDisclaimer: {
              l: "Usage of a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, does not assert that the Legal Entity is trustworthy, honest, reputable in its business dealings, safe to do business with, or compliant with any laws or that an implied or expressly intended purpose will be fulfilled."
            },
            issuanceDisclaimer: {
              l: "All information in a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, is accurate as of the date the validation process was complete. The vLEI Credential has been issued to the legal entity or person named in the vLEI Credential as the subject; and the qualified vLEI Issuer exercised reasonable care to perform the validation process set forth in the vLEI Ecosystem Governance Framework."
            }
          }
        }
      }
    }
    Successfully issued credential with SAID: EB86XZdf_4OzaXJsXI6d1tMofyi8lWH8GGjRd85ZUjYT
    
      Granting Credential  
    
    AID "qvi" granting credential to AID "EHdZZzxpaPDxHkPNeAwxYje5ngW0GPzSQCqnutfO5Bbu" via IPEX...
    Successfully submitted IPEX grant from "qvi" to "EHdZZzxpaPDxHkPNeAwxYje5ngW0GPzSQCqnutfO5Bbu".
    Waiting for notification with route "/exn/ipex/grant"...
    [Retry] Grant notification not found on attempt #1 of 5
    [Retry] Waiting 5000ms before next attempt...
    
      Admitting Grant  
    
    AID "role" admitting IPEX grant "EAmtvBCyl9PdgjX9YP2QGVojc-oVGf0Q9wcHi5NFHf9_" from AID "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB"...
    Successfully submitted IPEX admit for grant "EAmtvBCyl9PdgjX9YP2QGVojc-oVGf0Q9wcHi5NFHf9_".
    Marking notification "0ADxagJEkAiMLsSMTbVJMfMq" as read...
    Notification "0ADxagJEkAiMLsSMTbVJMfMq" marked as read.
    Waiting for notification with route "/exn/ipex/admit"...
    Marking notification "0ABkU4MU5PHrNUzJ1bTo-Ckq" as read...
    Notification "0ABkU4MU5PHrNUzJ1bTo-Ckq" marked as read.
    
      You can continue ✅  
    
    


### Step 5: ECR AUTH Credential - LE issues an ECR authorization credential to the QVI

This flow mirrors the OOR authorization. The LE issues an Engagement Context Role (ECR) authorization to the QVI. This allows the QVI to issue credentials for non-official but contextually important roles (e.g., "Project Lead," "Authorized Signatory for Invoices"). The `ecrAuthEdge` again links to the LE's root credential to prove the source of the authorization.



```typescript
// Credential Data
const ecrAuthData = {
    AID: '',
    LEI: leData.LEI,
    personLegalName: 'John Doe',
    engagementContextRole: 'Managing Director',
};

const ecrAuthEdge = Saider.saidify({
    d: '',
    le: {
        n: leCredential.sad.d,
        s: leCredential.sad.s,
    },
})[1];

const ecrAuthRules = Saider.saidify({
    d: '',
    usageDisclaimer: {
        l: 'Usage of a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, does not assert that the Legal Entity is trustworthy, honest, reputable in its business dealings, safe to do business with, or compliant with any laws or that an implied or expressly intended purpose will be fulfilled.',
    },
    issuanceDisclaimer: {
        l: 'All information in a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, is accurate as of the date the validation process was complete. The vLEI Credential has been issued to the legal entity or person named in the vLEI Credential as the subject; and the qualified vLEI Issuer exercised reasonable care to perform the validation process set forth in the vLEI Ecosystem Governance Framework.',
    },
    privacyDisclaimer: {
        l: 'Privacy Considerations are applicable to QVI ECR AUTH vLEI Credentials.  It is the sole responsibility of QVIs as Issuees of QVI ECR AUTH vLEI Credentials to present these Credentials in a privacy-preserving manner using the mechanisms provided in the Issuance and Presentation Exchange (IPEX) protocol specification and the Authentic Chained Data Container (ACDC) specification.  https://github.com/WebOfTrust/IETF-IPEX and https://github.com/trustoverip/kswg-acdc-specification.',
    },
})[1];

// LE - Issue credential
prTitle("Issuing Credential")

const { credentialSaid: credentialSaid} = await issueCredential(
    leClient, leAlias, leRegistrySaid, 
    ECR_AUTH_SCHEMA_SAID,
    qviPrefix,
    ecrAuthData, ecrAuthEdge, ecrAuthRules
)

// LE - get credential
const ecrAuthCredential = await leClient.credentials().get(credentialSaid);

// LE - Ipex grant
prTitle("Granting Credential")

const grantResponse = await ipexGrantCredential(
    leClient, leAlias, 
    qviPrefix,
    ecrAuthCredential
)

// QVI - Wait for grant notification
const grantNotifications = await waitForAndGetNotification(qviClient, IPEX_GRANT_ROUTE)
const grantNotification = grantNotifications[0]

// QVI - Admit Grant
prTitle("Admitting Grant")
const admitResponse = await ipexAdmitGrant(
    qviClient, qviAlias,
    lePrefix,
    grantNotification.a.d
)

// QVI - Mark notification
await markNotificationRead(qviClient, grantNotification.i)

// LE - Wait for admit notification
const admitNotifications = await waitForAndGetNotification(leClient, IPEX_ADMIT_ROUTE)
const admitNotification = admitNotifications[0]

// LE - Mark notification
await markNotificationRead(leClient, admitNotification.i)

prContinue()
```

    
      Issuing Credential  
    
    Issuing credential from AID "le" to AID "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB"...
    {
      name: "credential.EMjzuB4T9TsuTEpi-J2ECky2hD1Ah6Z1xG-hCCIqJL2B",
      metadata: {
        ced: {
          v: "ACDC10JSON000816_",
          d: "EMjzuB4T9TsuTEpi-J2ECky2hD1Ah6Z1xG-hCCIqJL2B",
          i: "ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ",
          ri: "EIWmQXgTeIg3XK_ixkyZST4_h7L6AdEjtXe9iMrFU31r",
          s: "EH6ekLjSr8V32WyFbGe1zXjTzFs9PkTYmupJ9H65O14g",
          a: {
            d: "EPY2Sc55vchUVMHQGVcs08BiQtxn_-mqQmp6esG_UHGO",
            i: "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB",
            AID: "",
            LEI: "875500ELOZEL05BVXV37",
            personLegalName: "John Doe",
            engagementContextRole: "Managing Director",
            dt: "2025-09-12T04:32:43.977000+00:00"
          },
          e: {
            d: "EHW84Tb8rCQN71yG5TDxcmdH5mUuMnXEklYUw_5m-Rnp",
            le: {
              n: "EEbwZ1kvlmJmjS-w7wqMXUnHGH_jf7aGszTSyYrZsOYW",
              s: "ENPXp1vQzRF6JwIuS-mp2U8Uf1MoADoP_GqQ62VsDZWY"
            }
          },
          r: {
            d: "EKHMDCNFlMBaMdDOq5Pf_vGMxkTqrDMrTx_28cZZJCcW",
            usageDisclaimer: {
              l: "Usage of a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, does not assert that the Legal Entity is trustworthy, honest, reputable in its business dealings, safe to do business with, or compliant with any laws or that an implied or expressly intended purpose will be fulfilled."
            },
            issuanceDisclaimer: {
              l: "All information in a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, is accurate as of the date the validation process was complete. The vLEI Credential has been issued to the legal entity or person named in the vLEI Credential as the subject; and the qualified vLEI Issuer exercised reasonable care to perform the validation process set forth in the vLEI Ecosystem Governance Framework."
            },
            privacyDisclaimer: {
              l: "Privacy Considerations are applicable to QVI ECR AUTH vLEI Credentials.  It is the sole responsibility of QVIs as Issuees of QVI ECR AUTH vLEI Credentials to present these Credentials in a privacy-preserving manner using the mechanisms provided in the Issuance and Presentation Exchange (IPEX) protocol specification and the Authentic Chained Data Container (ACDC) specification.  https://github.com/WebOfTrust/IETF-IPEX and https://github.com/trustoverip/kswg-acdc-specification."
            }
          }
        },
        depends: {
          name: "witness.EMcPHib0rTkeFYkMHWbRmI0eRE4oYLjsdKHlEL0CeDmO",
          metadata: { pre: "ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ", sn: 3 },
          done: false,
          error: null,
          response: null
        }
      },
      done: true,
      error: null,
      response: {
        ced: {
          v: "ACDC10JSON000816_",
          d: "EMjzuB4T9TsuTEpi-J2ECky2hD1Ah6Z1xG-hCCIqJL2B",
          i: "ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ",
          ri: "EIWmQXgTeIg3XK_ixkyZST4_h7L6AdEjtXe9iMrFU31r",
          s: "EH6ekLjSr8V32WyFbGe1zXjTzFs9PkTYmupJ9H65O14g",
          a: {
            d: "EPY2Sc55vchUVMHQGVcs08BiQtxn_-mqQmp6esG_UHGO",
            i: "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB",
            AID: "",
            LEI: "875500ELOZEL05BVXV37",
            personLegalName: "John Doe",
            engagementContextRole: "Managing Director",
            dt: "2025-09-12T04:32:43.977000+00:00"
          },
          e: {
            d: "EHW84Tb8rCQN71yG5TDxcmdH5mUuMnXEklYUw_5m-Rnp",
            le: {
              n: "EEbwZ1kvlmJmjS-w7wqMXUnHGH_jf7aGszTSyYrZsOYW",
              s: "ENPXp1vQzRF6JwIuS-mp2U8Uf1MoADoP_GqQ62VsDZWY"
            }
          },
          r: {
            d: "EKHMDCNFlMBaMdDOq5Pf_vGMxkTqrDMrTx_28cZZJCcW",
            usageDisclaimer: {
              l: "Usage of a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, does not assert that the Legal Entity is trustworthy, honest, reputable in its business dealings, safe to do business with, or compliant with any laws or that an implied or expressly intended purpose will be fulfilled."
            },
            issuanceDisclaimer: {
              l: "All information in a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, is accurate as of the date the validation process was complete. The vLEI Credential has been issued to the legal entity or person named in the vLEI Credential as the subject; and the qualified vLEI Issuer exercised reasonable care to perform the validation process set forth in the vLEI Ecosystem Governance Framework."
            },
            privacyDisclaimer: {
              l: "Privacy Considerations are applicable to QVI ECR AUTH vLEI Credentials.  It is the sole responsibility of QVIs as Issuees of QVI ECR AUTH vLEI Credentials to present these Credentials in a privacy-preserving manner using the mechanisms provided in the Issuance and Presentation Exchange (IPEX) protocol specification and the Authentic Chained Data Container (ACDC) specification.  https://github.com/WebOfTrust/IETF-IPEX and https://github.com/trustoverip/kswg-acdc-specification."
            }
          }
        }
      }
    }
    Successfully issued credential with SAID: EMjzuB4T9TsuTEpi-J2ECky2hD1Ah6Z1xG-hCCIqJL2B
    
      Granting Credential  
    
    AID "le" granting credential to AID "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB" via IPEX...
    Successfully submitted IPEX grant from "le" to "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB".
    Waiting for notification with route "/exn/ipex/grant"...
    [Retry] Grant notification not found on attempt #1 of 5
    [Retry] Waiting 5000ms before next attempt...
    
      Admitting Grant  
    
    AID "qvi" admitting IPEX grant "EE-5sBlA155Mfffn-Z0SnlVy5bH6xR-3d0_hKQcReHBE" from AID "ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ"...
    Successfully submitted IPEX admit for grant "EE-5sBlA155Mfffn-Z0SnlVy5bH6xR-3d0_hKQcReHBE".
    Marking notification "0ACDrr8ijyEbegd63Vkg9hOM" as read...
    Notification "0ACDrr8ijyEbegd63Vkg9hOM" marked as read.
    Waiting for notification with route "/exn/ipex/admit"...
    Marking notification "0ACtUyJQ5CtqU0AT0QUFGuN_" as read...
    Notification "0ACtUyJQ5CtqU0AT0QUFGuN_" marked as read.
    
      You can continue ✅  
    
    


### Step 6 (Path 1): ECR Credential - LE directly issues an Engagement Context Role credential to the Role holder

The vLEI framework is flexible. For ECR credentials, the Legal Entity can bypass a QVI and issue them directly. This path demonstrates that flow. The `ecrEdge` links directly to the LE's own vLEI credential, signifying its direct authority to define and issue this role.


```typescript
// Credential Data
const ecrData = {
    LEI: leData.LEI,
    personLegalName: 'John Doe',
    engagementContextRole: 'Managing Director',
};

const ecrEdge = Saider.saidify({
    d: '',
    le: {
        n: leCredential.sad.d,
        s: leCredential.sad.s,
    },
})[1];

const ecrRules = Saider.saidify({
    d: '',
    usageDisclaimer: {
        l: 'Usage of a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, does not assert that the Legal Entity is trustworthy, honest, reputable in its business dealings, safe to do business with, or compliant with any laws or that an implied or expressly intended purpose will be fulfilled.',
    },
    issuanceDisclaimer: {
        l: 'All information in a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, is accurate as of the date the validation process was complete. The vLEI Credential has been issued to the legal entity or person named in the vLEI Credential as the subject; and the qualified vLEI Issuer exercised reasonable care to perform the validation process set forth in the vLEI Ecosystem Governance Framework.',
    },
    privacyDisclaimer: {
        l: 'It is the sole responsibility of Holders as Issuees of an ECR vLEI Credential to present that Credential in a privacy-preserving manner using the mechanisms provided in the Issuance and Presentation Exchange (IPEX) protocol specification and the Authentic Chained Data Container (ACDC) specification. https://github.com/WebOfTrust/IETF-IPEX and https://github.com/trustoverip/kswg-acdc-specification.',
    },
})[1];

// lE - Issue credential
prTitle("Issuing Credential")

const { credentialSaid: credentialSaid} = await issueCredential(
    leClient, leAlias, leRegistrySaid, 
    ECR_SCHEMA_SAID,
    rolePrefix,
    ecrData, ecrEdge, ecrRules,
	true
)

// lE - get credential
const ecrCredential = await leClient.credentials().get(credentialSaid);

// lE - Ipex grant
prTitle("Granting Credential")

const grantResponse = await ipexGrantCredential(
    leClient, leAlias, 
    rolePrefix,
    ecrCredential
)

// role - Wait for grant notification
const grantNotifications = await waitForAndGetNotification(roleClient, IPEX_GRANT_ROUTE)
const grantNotification = grantNotifications[0]

// role - Admit Grant
prTitle("Admitting Grant")

const admitResponse = await ipexAdmitGrant(
    roleClient, roleAlias,
    lePrefix,
    grantNotification.a.d
)

// role - Mark notification
await markNotificationRead(roleClient, grantNotification.i)

// le - Wait for admit notification
const admitNotifications = await waitForAndGetNotification(leClient, IPEX_ADMIT_ROUTE)
const admitNotification = admitNotifications[0]

// le - Mark notification
await markNotificationRead(leClient, admitNotification.i)

prContinue()
```

    
      Issuing Credential  
    
    Issuing credential from AID "le" to AID "EHdZZzxpaPDxHkPNeAwxYje5ngW0GPzSQCqnutfO5Bbu"...
    {
      name: "credential.EHIjHiMWsCdoEIw1pUH842Cs6z2mBWnbBINmyZbh1nVN",
      metadata: {
        ced: {
          v: "ACDC10JSON0007dc_",
          d: "EHIjHiMWsCdoEIw1pUH842Cs6z2mBWnbBINmyZbh1nVN",
          u: "0AAVPaoUap9sZUbR9TN1Ex4g",
          i: "ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ",
          ri: "EIWmQXgTeIg3XK_ixkyZST4_h7L6AdEjtXe9iMrFU31r",
          s: "EEy9PkikFcANV1l7EHukCeXqrzT1hNZjGlUk7wuMO5jw",
          a: {
            d: "EIesID91PCs6euUWp5C_IhjVuLXi_Vks21BVkXJOGR4w",
            i: "EHdZZzxpaPDxHkPNeAwxYje5ngW0GPzSQCqnutfO5Bbu",
            LEI: "875500ELOZEL05BVXV37",
            personLegalName: "John Doe",
            engagementContextRole: "Managing Director",
            dt: "2025-09-12T04:32:52.443000+00:00"
          },
          e: {
            d: "EHW84Tb8rCQN71yG5TDxcmdH5mUuMnXEklYUw_5m-Rnp",
            le: {
              n: "EEbwZ1kvlmJmjS-w7wqMXUnHGH_jf7aGszTSyYrZsOYW",
              s: "ENPXp1vQzRF6JwIuS-mp2U8Uf1MoADoP_GqQ62VsDZWY"
            }
          },
          r: {
            d: "EIfq_m1DI2IQ1MgHhUl9sq3IQ_PJP9WQ1LhbMscngDCB",
            usageDisclaimer: {
              l: "Usage of a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, does not assert that the Legal Entity is trustworthy, honest, reputable in its business dealings, safe to do business with, or compliant with any laws or that an implied or expressly intended purpose will be fulfilled."
            },
            issuanceDisclaimer: {
              l: "All information in a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, is accurate as of the date the validation process was complete. The vLEI Credential has been issued to the legal entity or person named in the vLEI Credential as the subject; and the qualified vLEI Issuer exercised reasonable care to perform the validation process set forth in the vLEI Ecosystem Governance Framework."
            },
            privacyDisclaimer: {
              l: "It is the sole responsibility of Holders as Issuees of an ECR vLEI Credential to present that Credential in a privacy-preserving manner using the mechanisms provided in the Issuance and Presentation Exchange (IPEX) protocol specification and the Authentic Chained Data Container (ACDC) specification. https://github.com/WebOfTrust/IETF-IPEX and https://github.com/trustoverip/kswg-acdc-specification."
            }
          }
        },
        depends: {
          name: "witness.EITWWclApC3ObeMYJxltB7EMAdf0mjqfYk3SaRlt80ID",
          metadata: { pre: "ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ", sn: 4 },
          done: false,
          error: null,
          response: null
        }
      },
      done: true,
      error: null,
      response: {
        ced: {
          v: "ACDC10JSON0007dc_",
          d: "EHIjHiMWsCdoEIw1pUH842Cs6z2mBWnbBINmyZbh1nVN",
          u: "0AAVPaoUap9sZUbR9TN1Ex4g",
          i: "ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ",
          ri: "EIWmQXgTeIg3XK_ixkyZST4_h7L6AdEjtXe9iMrFU31r",
          s: "EEy9PkikFcANV1l7EHukCeXqrzT1hNZjGlUk7wuMO5jw",
          a: {
            d: "EIesID91PCs6euUWp5C_IhjVuLXi_Vks21BVkXJOGR4w",
            i: "EHdZZzxpaPDxHkPNeAwxYje5ngW0GPzSQCqnutfO5Bbu",
            LEI: "875500ELOZEL05BVXV37",
            personLegalName: "John Doe",
            engagementContextRole: "Managing Director",
            dt: "2025-09-12T04:32:52.443000+00:00"
          },
          e: {
            d: "EHW84Tb8rCQN71yG5TDxcmdH5mUuMnXEklYUw_5m-Rnp",
            le: {
              n: "EEbwZ1kvlmJmjS-w7wqMXUnHGH_jf7aGszTSyYrZsOYW",
              s: "ENPXp1vQzRF6JwIuS-mp2U8Uf1MoADoP_GqQ62VsDZWY"
            }
          },
          r: {
            d: "EIfq_m1DI2IQ1MgHhUl9sq3IQ_PJP9WQ1LhbMscngDCB",
            usageDisclaimer: {
              l: "Usage of a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, does not assert that the Legal Entity is trustworthy, honest, reputable in its business dealings, safe to do business with, or compliant with any laws or that an implied or expressly intended purpose will be fulfilled."
            },
            issuanceDisclaimer: {
              l: "All information in a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, is accurate as of the date the validation process was complete. The vLEI Credential has been issued to the legal entity or person named in the vLEI Credential as the subject; and the qualified vLEI Issuer exercised reasonable care to perform the validation process set forth in the vLEI Ecosystem Governance Framework."
            },
            privacyDisclaimer: {
              l: "It is the sole responsibility of Holders as Issuees of an ECR vLEI Credential to present that Credential in a privacy-preserving manner using the mechanisms provided in the Issuance and Presentation Exchange (IPEX) protocol specification and the Authentic Chained Data Container (ACDC) specification. https://github.com/WebOfTrust/IETF-IPEX and https://github.com/trustoverip/kswg-acdc-specification."
            }
          }
        }
      }
    }
    Successfully issued credential with SAID: EHIjHiMWsCdoEIw1pUH842Cs6z2mBWnbBINmyZbh1nVN
    
      Granting Credential  
    
    AID "le" granting credential to AID "EHdZZzxpaPDxHkPNeAwxYje5ngW0GPzSQCqnutfO5Bbu" via IPEX...
    Successfully submitted IPEX grant from "le" to "EHdZZzxpaPDxHkPNeAwxYje5ngW0GPzSQCqnutfO5Bbu".
    Waiting for notification with route "/exn/ipex/grant"...
    [Retry] Grant notification not found on attempt #1 of 5
    [Retry] Waiting 5000ms before next attempt...
    
      Admitting Grant  
    
    AID "role" admitting IPEX grant "EH5il6RJMXJg09SxVSNHyjYIM2tTxfUiJAZJtAaapXdD" from AID "ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ"...
    Successfully submitted IPEX admit for grant "EH5il6RJMXJg09SxVSNHyjYIM2tTxfUiJAZJtAaapXdD".
    Marking notification "0ADZtE7A9V0HxMaty3dv7_jh" as read...
    Notification "0ADZtE7A9V0HxMaty3dv7_jh" marked as read.
    Waiting for notification with route "/exn/ipex/admit"...
    Marking notification "0AC7ovRgvjbZtI-vGNKwt7tB" as read...
    Notification "0AC7ovRgvjbZtI-vGNKwt7tB" marked as read.
    
      You can continue ✅  
    
    


### Step 6 (Path 2): ECR Credential - QVI issues another ECR credential using the AUTH credential

This is an alternate path for ECR issuance. Here, the QVI uses the `ECR AUTH` credential it received from the LE in **Step 5** to issue an ECR credential. Just like the OOR flow, the edge block uses the `I2I` operator, proving the QVI is acting on a specific, verifiable authorization from the Legal Entity.


```typescript
// Credential Data
const ecrEdgeByQvi = Saider.saidify({
    d: '',
    auth: {
        n: ecrAuthCredential.sad.d,
        s: ecrAuthCredential.sad.s,
        o: 'I2I',
    },
})[1];

// QVI - Issue credential
prTitle("Issuing Credential")
const { credentialSaid: credentialSaid} = await issueCredential(
    qviClient,  qviAlias, qviRegistrySaid, 
    ECR_SCHEMA_SAID,
    rolePrefix,
    ecrData, ecrEdgeByQvi, ecrRules,
    true
)

// QVI - get credential (with all its data)
prTitle("Granting Credential")
const ecrByQviCredential = await qviClient.credentials().get(credentialSaid);

// QVI - Ipex grant
const grantResponse = await ipexGrantCredential(
    qviClient, qviAlias, 
    rolePrefix,
    ecrByQviCredential
)

// ROLE - Wait for grant notification
const grantNotifications = await waitForAndGetNotification(roleClient, IPEX_GRANT_ROUTE)
const grantNotification = grantNotifications[0]

// ROLE - Admit Grant
prTitle("Admitting Grant")
const admitResponse = await ipexAdmitGrant(
    roleClient, roleAlias,
    qviPrefix,
    grantNotification.a.d
)

// LE - Mark notification
await markNotificationRead(roleClient, grantNotification.i)

// QVI - Wait for admit notification
const admitNotifications = await waitForAndGetNotification(qviClient, IPEX_ADMIT_ROUTE)
const admitNotification = admitNotifications[0]

// QVI - Mark notification
await markNotificationRead(qviClient, admitNotification.i)

prContinue()
```

    
      Issuing Credential  
    
    Issuing credential from AID "qvi" to AID "EHdZZzxpaPDxHkPNeAwxYje5ngW0GPzSQCqnutfO5Bbu"...
    {
      name: "credential.EL9IVpoNSEOU_dWJAV-haVJL69RyIrNp73O-VnelD1X_",
      metadata: {
        ced: {
          v: "ACDC10JSON0007e8_",
          d: "EL9IVpoNSEOU_dWJAV-haVJL69RyIrNp73O-VnelD1X_",
          u: "0AAC2HWaBkQ5Q3hzLYhAAQuu",
          i: "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB",
          ri: "ED7V4aCJrFccq8vtvExmQW12pIe25ZT381275ZgWLxwl",
          s: "EEy9PkikFcANV1l7EHukCeXqrzT1hNZjGlUk7wuMO5jw",
          a: {
            d: "EIUYcnPicYW_EQI1mfn5YxamY6uOBCxC9AVuQSUQGiHk",
            i: "EHdZZzxpaPDxHkPNeAwxYje5ngW0GPzSQCqnutfO5Bbu",
            LEI: "875500ELOZEL05BVXV37",
            personLegalName: "John Doe",
            engagementContextRole: "Managing Director",
            dt: "2025-09-12T04:33:00.901000+00:00"
          },
          e: {
            d: "EIsG1uLLjuv-3PNH8ephy0myrnVFtbXIUdC1Cs-nEq6y",
            auth: {
              n: "EMjzuB4T9TsuTEpi-J2ECky2hD1Ah6Z1xG-hCCIqJL2B",
              s: "EH6ekLjSr8V32WyFbGe1zXjTzFs9PkTYmupJ9H65O14g",
              o: "I2I"
            }
          },
          r: {
            d: "EIfq_m1DI2IQ1MgHhUl9sq3IQ_PJP9WQ1LhbMscngDCB",
            usageDisclaimer: {
              l: "Usage of a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, does not assert that the Legal Entity is trustworthy, honest, reputable in its business dealings, safe to do business with, or compliant with any laws or that an implied or expressly intended purpose will be fulfilled."
            },
            issuanceDisclaimer: {
              l: "All information in a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, is accurate as of the date the validation process was complete. The vLEI Credential has been issued to the legal entity or person named in the vLEI Credential as the subject; and the qualified vLEI Issuer exercised reasonable care to perform the validation process set forth in the vLEI Ecosystem Governance Framework."
            },
            privacyDisclaimer: {
              l: "It is the sole responsibility of Holders as Issuees of an ECR vLEI Credential to present that Credential in a privacy-preserving manner using the mechanisms provided in the Issuance and Presentation Exchange (IPEX) protocol specification and the Authentic Chained Data Container (ACDC) specification. https://github.com/WebOfTrust/IETF-IPEX and https://github.com/trustoverip/kswg-acdc-specification."
            }
          }
        },
        depends: {
          name: "witness.EO4Fpx7u92KiGCZkcUCny4nVroekOJxVDwCav1oo_EW5",
          metadata: { pre: "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB", sn: 4 },
          done: false,
          error: null,
          response: null
        }
      },
      done: true,
      error: null,
      response: {
        ced: {
          v: "ACDC10JSON0007e8_",
          d: "EL9IVpoNSEOU_dWJAV-haVJL69RyIrNp73O-VnelD1X_",
          u: "0AAC2HWaBkQ5Q3hzLYhAAQuu",
          i: "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB",
          ri: "ED7V4aCJrFccq8vtvExmQW12pIe25ZT381275ZgWLxwl",
          s: "EEy9PkikFcANV1l7EHukCeXqrzT1hNZjGlUk7wuMO5jw",
          a: {
            d: "EIUYcnPicYW_EQI1mfn5YxamY6uOBCxC9AVuQSUQGiHk",
            i: "EHdZZzxpaPDxHkPNeAwxYje5ngW0GPzSQCqnutfO5Bbu",
            LEI: "875500ELOZEL05BVXV37",
            personLegalName: "John Doe",
            engagementContextRole: "Managing Director",
            dt: "2025-09-12T04:33:00.901000+00:00"
          },
          e: {
            d: "EIsG1uLLjuv-3PNH8ephy0myrnVFtbXIUdC1Cs-nEq6y",
            auth: {
              n: "EMjzuB4T9TsuTEpi-J2ECky2hD1Ah6Z1xG-hCCIqJL2B",
              s: "EH6ekLjSr8V32WyFbGe1zXjTzFs9PkTYmupJ9H65O14g",
              o: "I2I"
            }
          },
          r: {
            d: "EIfq_m1DI2IQ1MgHhUl9sq3IQ_PJP9WQ1LhbMscngDCB",
            usageDisclaimer: {
              l: "Usage of a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, does not assert that the Legal Entity is trustworthy, honest, reputable in its business dealings, safe to do business with, or compliant with any laws or that an implied or expressly intended purpose will be fulfilled."
            },
            issuanceDisclaimer: {
              l: "All information in a valid, unexpired, and non-revoked vLEI Credential, as defined in the associated Ecosystem Governance Framework, is accurate as of the date the validation process was complete. The vLEI Credential has been issued to the legal entity or person named in the vLEI Credential as the subject; and the qualified vLEI Issuer exercised reasonable care to perform the validation process set forth in the vLEI Ecosystem Governance Framework."
            },
            privacyDisclaimer: {
              l: "It is the sole responsibility of Holders as Issuees of an ECR vLEI Credential to present that Credential in a privacy-preserving manner using the mechanisms provided in the Issuance and Presentation Exchange (IPEX) protocol specification and the Authentic Chained Data Container (ACDC) specification. https://github.com/WebOfTrust/IETF-IPEX and https://github.com/trustoverip/kswg-acdc-specification."
            }
          }
        }
      }
    }
    Successfully issued credential with SAID: EL9IVpoNSEOU_dWJAV-haVJL69RyIrNp73O-VnelD1X_
    
      Granting Credential  
    
    AID "qvi" granting credential to AID "EHdZZzxpaPDxHkPNeAwxYje5ngW0GPzSQCqnutfO5Bbu" via IPEX...
    Successfully submitted IPEX grant from "qvi" to "EHdZZzxpaPDxHkPNeAwxYje5ngW0GPzSQCqnutfO5Bbu".
    Waiting for notification with route "/exn/ipex/grant"...
    [Retry] Grant notification not found on attempt #1 of 5
    [Retry] Waiting 5000ms before next attempt...
    
      Admitting Grant  
    
    AID "role" admitting IPEX grant "EIL5P-3nLK8NTXH3CurFttmC5F4Ay5r77KOKSkgG2W4C" from AID "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB"...
    Successfully submitted IPEX admit for grant "EIL5P-3nLK8NTXH3CurFttmC5F4Ay5r77KOKSkgG2W4C".
    Marking notification "0ACHUs5HNpKKTvg5tcvIl8O3" as read...
    Notification "0ACHUs5HNpKKTvg5tcvIl8O3" marked as read.
    Waiting for notification with route "/exn/ipex/admit"...
    Marking notification "0AAEkrU39oyti4pd-cWylNYS" as read...
    Notification "0AAEkrU39oyti4pd-cWylNYS" marked as read.
    
      You can continue ✅  
    
    


## The vLEI Reporting Agent

Once credentials like the ones created in this chain are issued and held by their respective entities, a common next step is to present them for verification or auditing. The vLEI Audit Reporting Agent, known as Sally, is a component designed for this purpose.

Sally acts as a direct-mode validator. It receives presentations of vLEI credentials (like the QVI, vLEI and OOR credentials), cryptographically verifies their structure and integrity, and then performs a POST request to a pre-configured webhook URL. This allows external systems to receive trusted, real-time notifications about credential presentations and revocations within the vLEI ecosystem.

For more details about Sally go to its Github **[repository](https://github.com/GLEIF-IT/sally)**.

To continue with the example you need to start the sally service following the instructions below (⚠️ The command is programatically generated) in the root directory of these training materials so the correct docker compose file is found.


```typescript
// Ask user to start the sally service setting the proper root of trust for this run
prAlert(`Please run this command on you local machine in the vlei-trainings directory before continuing, and wait for the container to start:`)

prMessage(`GEDA_PRE=${gleifPrefix} docker compose up --build direct-sally -d`)

const isReady = confirm("Is the service running and ready to accept connections?");
if (isReady) {
    prContinue()
} else {
    throw new Error("❌ Script aborted by user. Please start the service and run the script again.");
}

```

    
    Please run this command on you local machine in the vlei-trainings directory before continuing, and wait for the container to start:
    
    
    GEDA_PRE=EECGZ7vbYzOM1FWicPFIot-4AiteMX6Xr5htEVAA5Iq2 docker compose up --build direct-sally -d
    


    Is the service running and ready to accept connections? [y/N]  y


    
      You can continue ✅  
    
    


<div class="alert alert-info">
    <b>ℹ️ NOTE</b><hr>
    When the sally service is started, the Root of Trust prefix is passed via the <code>GEDA_PRE</code> variable.  
</div>

### The Presentation Workflow

The following code block performs the entire presentation flow in four main steps.

1. **Establishing Contact with Sally:** Before the Legal Entity client (`leClient`) can present its credentials, it must first know how to communicate with Sally. The first action in the code is `resolveOOBI(leClient, sallyOOBI, sallyAlias)`, which resolves Sally's OOBI to establish this connection.
2. **Running the Local Sally Service:** The code will then prompt you to start the local Sally service using a `docker compose` command. This command is critical for the demonstration:
    - It starts a container running the Sally agent.
    - It also starts a simple hook service that acts as the webhook endpoint, listening for and storing the reports that Sally will post.
    - The `GEDA_PRE=${gleifPrefix}` variable passed to the command provides Sally with the Root of Trust AID for this specific notebook run. Sally requires this information to validate the entire credential chain, from the LE credential presented to it all the way back to its root anchor at GLEIF.
3. **Presenting the Credential:** The `presentToSally()` function uses `ipexGrantCredential` to send the `leCredential` to Sally's AID. This action is the `signify-ts` equivalent of using `kli ipex grant` for credential presentation and initiates the verification process within Sally.
4. **Verifying the Audit Report:** Finally, the `pollForCredential()` function simulates a webhook listener. Instead of running a full server, it simply polls the hook service where Sally sends its report. Upon receiving a successful `200 OK` response, it fetches and displays the JSON report, confirming that Sally received the presentation, successfully verified the trust chain, and dispatched its audit report.


```typescript
// Present to sally

const sallyOOBI = "http://direct-sally:9823/oobi"
const sallyPrefix = "ECLwKe5b33BaV20x7HZWYi_KUXgY91S41fRL2uCaf4WQ"
const sallyAlias = "sally"

// Ipex presentation of LE credential
async function presentToSally(){
    prTitle("Presenting vLEI Credential to sally")
    const grantResponse = await ipexGrantCredential(
        leClient,  leAlias, 
        sallyPrefix,
        leCredential
    )
}

// Poll webhook for LE credential data
const webhookUrl = `${"http://hook:9923"}/?holder=${lePrefix}`;

async function pollForCredential() {

    const TIMEOUT_SECONDS = 25;
    let present_result = 0;
    const start = Date.now();

    while (present_result !== 200) {

        if ((Date.now() - start) / 1000 > TIMEOUT_SECONDS) {
            prMessage(`TIMEOUT - Sally did not receive the Credential`);
            break; // Exit the loop
        }
        // Run curl to get just the HTTP status code
        try {
            const command = new Deno.Command("curl", {
                args: ["-s", "-o", "/dev/null", "-w", "%{http_code}", webhookUrl],
            });
            const { stdout } = await command.output();
            const httpCodeStr = new TextDecoder().decode(stdout);
            present_result = parseInt(httpCodeStr, 10) || 0; // Default to 0 if parsing fails
            prMessage(`Received ${present_result} from Sally`);
        } catch (error) {
            prMessage(`[QVI] Polling command failed: ${error.message}`);
            present_result = 0; // Reset on failure to avoid exiting loop
        }
        if (present_result !== 200) {
            await sleep(1000); 
        }
    }
    if (present_result === 200) {
        prTitle("Fetching Credential Info...");
        const command = new Deno.Command("curl", {
            args: ["-s", webhookUrl]
        });
        const { stdout } = await command.output();
        const responseBody = new TextDecoder().decode(stdout);
        try {
            const jsonObject = JSON.parse(responseBody);
            const formattedJson = JSON.stringify(jsonObject, null, 2);
            prMessage(formattedJson);
        } catch (error) {
            prMessage("Response was not valid JSON. Printing raw body:");
            prMessage(responseBody);
        }
    }
}

while(! await isServiceHealthy("http://direct-sally:9823/health")){
    prMessage(`Please run this command on you local machine before continuing, and wait for the container to start:`)
    prMessage(`GEDA_PRE=${gleifPrefix} docker compose up --build direct-sally -d`)
    await sleep(5000);
}

await resolveOOBI(leClient, sallyOOBI, sallyAlias)
await resolveOOBI(qviClient, sallyOOBI, sallyAlias)
await presentToSally()
await pollForCredential()

prContinue()
```

    Checking health at: http://direct-sally:9823/health
    Received status: 200. Service is healthy.
    Resolving OOBI URL: http://direct-sally:9823/oobi with alias sally
    Successfully resolved OOBI URL. Response: OK
    Contact "sally" added/updated.
    Resolving OOBI URL: http://direct-sally:9823/oobi with alias sally
    Successfully resolved OOBI URL. Response: OK
    Contact "sally" added/updated.
    
      Presenting vLEI Credential to sally  
    
    AID "le" granting credential to AID "ECLwKe5b33BaV20x7HZWYi_KUXgY91S41fRL2uCaf4WQ" via IPEX...
    Successfully submitted IPEX grant from "le" to "ECLwKe5b33BaV20x7HZWYi_KUXgY91S41fRL2uCaf4WQ".
    
    Received 404 from Sally
    
    
    Received 404 from Sally
    
    
    Received 404 from Sally
    
    
    Received 404 from Sally
    
    
    Received 404 from Sally
    
    
    Received 404 from Sally
    
    
    Received 200 from Sally
    
    
      Fetching Credential Info...  
    
    
    {
      "credential": "EEbwZ1kvlmJmjS-w7wqMXUnHGH_jf7aGszTSyYrZsOYW",
      "type": "LE",
      "issuer": "ENI8jRbuVRvHf9XsW5wudw_NBJkl5XTz11Qo7v-qwtIB",
      "holder": "ELkTLFJYB0yoO-R2slbPlm3l6vEyxMCzCs6ovP7ii_vQ",
      "LEI": "875500ELOZEL05BVXV37",
      "personLegalName": "",
      "officialRole": ""
    }
    
    
      You can continue ✅  
    
    


<div class="alert alert-prymary">
<b>📝 SUMMARY</b><hr>
This notebook provided a practical walkthrough of a simplified vLEI trust chain using Signify-ts, demonstrating:
<ul>
<li><b>Hierarchical Trust:</b> Each credential in the chain cryptographically references its authorizing credential, creating a verifiable link back to the Root of Trust (GLEIF).</li>
<li><b>Multiple Issuance Paths:</b> The vLEI ecosystem supports different issuance models, including direct issuance by a Legal Entity (for ECRs) and authorized issuance by a QVI on behalf of an LE (for OORs and ECRs).</li>
<li><b>IPEX Protocol:</b> The Issuance and Presentation Exchange protocol facilitates the secure delivery of credentials between parties using a grant/admit message flow.</li>
<li><b>Schema Compliance:</b> Every credential adheres to a specific, SAID-identified vLEI schema, ensuring interoperability and consistent data structures.</li>
<li><b>Credential Chaining:</b> The 'edges' section of an ACDC is used to reference the SAID of a source credential, explicitly defining the chain of authority.</li>
<li><b>Audit Agent Interaction:</b> A credential holder can present their ACDC to an external agent like Sally for verification and auditing. Sally validates the entire trust chain and notifies an external service via a webhook.</li>
</ul>
This represents a functional, albeit simplified, model of how the vLEI ecosystem issues verifiable credentials for legal entities and their roles while maintaining a robust and verifiable chain of trust.
</div>

[<- Prev (vLEI Ecosystem)](103_05_vLEI_Ecosystem.ipynb) | [Next (Integrating Chainlink CCID with vLEI) ->](220_10_Integrating_Chainlink_CCID_with_vLEI.ipynb)
