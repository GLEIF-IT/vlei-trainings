# Introducing KERIA and Signify-ts: Architecture and Concepts

<div class="alert alert-primary">
  <b>🎯 OBJECTIVE</b><hr>
  Introduces the foundational concepts of KERIA and Signify-ts, focusing on:
    <ul>
        <li>The KERIA/Signify client-agent architecture.</li>
        <li>Key KERIA endpoint interfaces.</li>
        <li>The concept of End Roles.</li>
        <li>The relationship between Client AIDs and Agent AIDs.</li>
    </ul>
</div>

## Client-Agent Architecture

KERI is a protocol for secure, self-certifying identifiers. **KERIA** is an agent implementation of KERI, designed to run as a service (e.g., in the cloud or self-hosted) that manages AIDs on behalf of a controller. **Signify-ts** is a TypeScript library that acts as a client, enabling applications to interact with a KERIA agent.

The idea behind this client-agent architecture is to enable "signing at the edge". Your sensitive private keys, used for signing key events and other data, remain on the client-side (managed by Signify client library). The KERIA agent, running remotely, handles tasks like:
* Storing encrypted key material (salts, encrypted private keys)
* Managing Key Event Logs (KELs)
* Interacting with witnesses
* Exchanging messages with other KERI agents

The KERIA agent itself never has access to your unencrypted private keys. All critical signing operations happen on the client, and the signed events are then sent to the KERIA agent for processing and dissemination.

This architecture separates key management and signing authority (client-side) from the operational aspects of maintaining an AID's KEL and its availability (agent-side).

### KERIA Deployment and Configuration

In a typical deployment, KERIA starts up and often loads its configuration, including a list of default witnesses, from a JSON configuration file (e.g., **[keria configuration file](config/keria/keria-docker.json)**). This allows the agent to be pre-configured with a set of trusted witnesses that any AIDs it manages can use.

## Agent Service Endpoints

A KERIA service instance exposes distinct HTTP endpoints to handle different types of interactions:

1.  **Boot Interface** (`boot port`, e.g., 3903 by default):
    * **Purpose**: Used for the initial setup and provisioning of a KERIA agent worker for a Signify client. This is where the client and agent establish their initial secure relationship.
    * **Interaction**: The Signify client sends its client AID's inception event to this endpoint to request the creation of a delegated agent AID.
    * **Accessibility**: Often restricted to internal infrastructure or disabled if agents are pre-configured (static worker mode).

2.  **Admin Interface** (`admin port`, e.g., 3901 by default):
    * **Purpose**: This is the primary REST API for the Signify client to command and control its KERIA agent.
    * **Interaction**: Used for operations like creating new AIDs, rotating keys, issuing credentials, resolving OOBIs, etc. All requests to this interface must be authenticated (e.g., signed by the Client AID).
    * **Accessibility**: Typically exposed externally to allow the client to manage its AIDs.

3.  **KERI Protocol Interface** (`http port`, e.g., 3902 by default):
    * **Purpose**: Handles standard KERI protocol messages (e.g., KELs, receipts, challenges) exchanged with other KERI agents and witnesses in the wider KERI network.
    * **Interaction**: Facilitates multi-sig coordination, credential revocation, KEL exchange, etc., using CESR (Composable Event Streaming Representation) over HTTP.
    * **Accessibility**: Exposed externally to enable interaction with the global KERI ecosystem.

This separation of interfaces enhances security and deployment flexibility.

## Understanding End Roles

An **end role** in KERI is an authorization that one AID grants to another AID to act in a specific capacity on its behalf. Think of it as assigning a specific job to another identifier.

For instance, when a Signify client connects to a KERIA agent, the **Client AID** (controlled by the user/application) delegates authority to an **Agent AID** (managed by the KERIA service). The Client AID essentially authorizes its Agent AID to perform certain KERI operations in its name, like anchoring its KEL with witnesses or responding to discovery requests.

Declaring an end role typically involves creating a KERI event, often an interaction event (`ixn`) or an establishment event (`icp` or `rot`) with specific configuration (`c` field) or an `end` role event, that specifies:
* The AID granting the authorization (the delegator or authorizer).
* The AID receiving the authorization (the delegate or authorized party).
* The specific role being granted (e.g., `agent`, `witness`, `watcher`).

This signed authorization is recorded in the KEL of the authorizing AID, making the role assignment verifiable by anyone who can access and validate that KEL.

## Client and Agent AIDs Explained

When you use Signify-ts to connect to a KERIA agent, two primary AIDs are involved:

1.  **Client AID**:
    * This is an AID that *you* (or your application) control directly via the Signify-ts client.
    * You hold its private keys.
    * It's typically a transferable AID, allowing for key rotation.
    * It acts as the **delegator** to the Agent AID.

2.  **Agent AID**:
    * This AID is created and managed by the KERIA service *on your behalf*.
    * Its inception event specifies the Client AID as its delegator (`di` field in the inception event). This means the Agent AID's authority to act is derived from, and anchored to, your Client AID.
    * It's also typically a transferable AID.
    * The KERIA service uses this Agent AID to perform actions for your Client AID, such as interacting with witnesses or other agents, without needing direct access to your Client AID's private keys.

The Signify client generates the Client AID and sends its inception event to the KERIA agent's Boot Interface. The KERIA service then creates the delegated Agent AID and returns its inception event to the client. Finally, the Signify client approves this delegation by sending an interaction event back to the KERIA agent's Admin Interface.

This delegation model is fundamental to KERIA's security: your primary controlling keys (for the Client AID) remain "at the edge," while the KERIA agent operates with a delegated authority (via the Agent AID) that is always traceable back to your Client AID.

<div class="alert alert-primary">
  <b>📝 SUMMARY</b><hr>
  <p>
    The KERIA/Signify architecture enables "signing at the edge," where a Signify client (like Signify-ts) manages private keys and signing operations locally, while a remote KERIA agent handles KEL management, witness interactions, and KERI protocol communications. KERIA exposes three main HTTP endpoints:
    <ul>
        <li><b>Boot Interface:</b> For initial client-agent provisioning and creation of a delegated Agent AID.</li>
        <li><b>Admin Interface:</b> A REST API for the client to command and control its agent (e.g., create AIDs, rotate keys).</li>
        <li><b>KERI Protocol Interface:</b> For standard KERI message exchange with other agents and witnesses.</li>
    </ul>
    End roles in KERI define verifiable authorizations for one AID to act in a specific capacity for another (e.g., an Agent AID acting in the 'agent' role for a Client AID).
  </p>
  <p>
    The connection process involves a <b>Client AID</b> (controlled by the user via Signify) delegating authority to an <b>Agent AID</b> (managed by KERIA).
  </p>
</div>
