# Foundations: KERI, ACDC, and the vLEI Ecosystem

<div class="alert alert-prymary">
  <b>🎯 OBJECTIVE</b><hr>
Provide a high-level overview of the three foundational concepts we'll be covering during this training: 
<li>The KERI protocol for secure identifiers
<li>The ACDC protocol for verifiable credentials
<li>The GLEIF vLEI ecosystem, which applies these technologies to organizational identity.
<br><br>
Consider this a starting point; we'll dive into the details, practical examples, and specific commands in the notebooks that follow.
</div>

## The KERI Protocol

**KERI** stands for **Key Event Receipt Infrastructure**, invented by [Dr. Samuel Smith](https://keri.one/131-2/). It's a decentralized key management infrastructure (DKMI) that aims to provide a secure and decentralized identity layer for the internet, focusing on establishing trust through cryptographic proof rather than relying solely on centralized authorities. It is a "never trust, always verify" security model with no share secrets, meaning no shared passwords, keys, or other types of cryptographic secrets. This means that KERI is a signed-everything model, meaning every communication between components is signed so that trust in each transmission can be verified by verifying its signature or by verifying the anchoring of data to a key event log (KEL).

Core Ideas:

* **Self Addressing Identifiers (SAIDs):** [Self addressing identifiers](https://trustoverip.github.io/tswg-keri-specification/#term:said) are a special type of content-addressable identifier where the identifier is based on and embedded within the data it refers to, making it self referential. The embedding happens after computing the digest in a two step digest and embedding process. See the [spec reference](https://trustoverip.github.io/tswg-said-specification/draft-ssmith-said.html).
* **Autonomic Identifiers (AIDs):** KERI's foundation is built on [self-certifying identifiers](https://trustoverip.github.io/tswg-keri-specification/#self-certifying-identifier-scid) called AIDs. These identifiers are generated from and cryptographically bound to key pairs controlled by an entity, eliminating the need for a central registration authority for the identifier itself. An AID is a SAID derived from the first event (inception event) in a key event log (KEL).
* **Key Event Logs (KELs):** Each AID has an associated KEL, which is a secure, append-only log of signed "key events" (like identifier creation, key rotation, etc.). This log provides a verifiable key history, or provenance, of the control over the AID. Anyone can verify the current authoritative keys for an AID by processing its KEL.
* **End-Verifiability:** KERI emphasizes that identifier control and key events can be verified by anyone, anywhere, using only the KEL, without trusting intermediaries.
* **Witnesses:** For high availability and resilience, the person controlling of keys for an AID (controller) can designate witnesses who receive, verify, and store key events. This both allows the controller to set security thresholds for event signing and also makes the KEL accessible when the controller is offline.
* **And more:** KERI has many other advanced features, but we'll focus on the fundamentals in this introduction.

## The ACDC Protocol

**ACDC** stands for **Authentic Chained Data Container**. It is KERI's native format for Verifiable Credentials (VCs), designed to work within KERI-based ecosystems.

**Core Ideas:**

* **Verifiable Credentials:** ACDCs are digital containers for claims or attributes (like a name, role, or authorization) that are issued by one identifier (AID) to another.
* **Built on KERI:** ACDCs leverage AIDs for identifying issuers and issues. The validity and status (issued, revoked) of an ACDC are anchored to the issuer's Key Event Log (KEL) through a secondary log called a Transaction Event Log (TEL).
* **Schemas & SAIDs:** Each ACDC conforms to a specific Schema, which defines its structure and data types. Both the schema and the ACDC instance itself are identified using SAIDs (Self-Addressing Identifiers), making them tamper-evident.
* **Chaining (Edges):** ACDCs can be cryptographically linked together using "edges," forming verifiable chains or graphs of evidence (e.g., an approval credential linking back to the request credential).
* **Rules:** ACDCs can optionally include embedded machine-readable rules or legal prose (like Ricardian Contracts).
* **IPEX (Issuance and Presentation Exchange):** a [credential exchange protocol](https://trustoverip.github.io/tswg-acdc-specification/#issuance-and-presentation-exchange-ipex) defining a mechanism and workflow for how ACDCs are issued between parties and how they are presented for verification in a securely attributable way. This protocol also defines a workflow for [graduated disclosure](https://trustoverip.github.io/tswg-acdc-specification/#graduated-disclosure), a variant of selective disclosure that allows for progressive, selective unblinding of claims or attributes after an agreement has been negotiated between the discloser (holder) and the receiver (disclosee) of an ACDC.

## The GLEIF vLEI Ecosystem

The **verifiable Legal Entity Identifier (vLEI)** is a system pioneered by the Global Legal Entity Identifier Foundation (GLEIF) to create a secure, digitized version of the traditional LEI used for organizational identity. It aims to enable automated authentication and verification of organizations globally.

**Core Ideas:**

* **Digital Counterpart to LEI:** The vLEI acts as a digitally verifiable representation of an organization's LEI code, enabling automated, machine-readable verification.
* **Built on KERI/ACDC:** The vLEI infrastructure is built using the KERI protocol and represents vLEI credentials as ACDCs. This leverages KERI's security and ACDC's verifiable credential format.
* **Trust Chain / Ecosystem:** The vLEI system establishes a chain of trust:
    * **GLEIF (Root of Trust):** GLEIF operates as the root of the ecosystem; its AID and KEL serve as the ultimate anchor for verifying the authority of QVIs. The root of trust uses **identifier delegation** to establish an authorization chain from the Root of Trust to the QVI through delegation chained KELs.
    * **Qualified vLEI Issuers (QVIs):** GLEIF uses its KERI identity to issue QVI credentials to a trusted network of QVIs. This means that both identifier delegation and credential issuance are used to delegate authority from GLEIF to QVIs for the purpose of allowing QVIs to issue vLEI credentials.
    * **Organizations:** QVIs are qualified to issue vLEI credentials, which represent the organization's identity, to legal entities.
    * **Organizational Role:** An organization holding a vLEI can then issue specific **vLEI Role Credentials** to individuals representing the organization in official or functional capacities (e.g., CEO, authorized signatory, supplier). These role credentials cryptographically bind the person's identity in that role to the organization's vLEI.
        * **Official Organizational Role (OOR) Credential:** A person representing a legal entity may be issued an OOR credential that indicates their official role in an organization. The rules for OOR credential issuance must follow the ISO 5009 Official Organization Role standard for official role names.
        * **Engagement Context Role (ECR) Credential:** An ECR credential indicates a person performs a given role for a company-defined context. It is a more permissive credential type where the name of the role is legal-entity specific.
* **QVI Workflow:** The workflow centrally involves the QVIs. GLEIF qualifies these issuers. A QVI interacts with an organization to verify its identity information (linked to its traditional LEI) and then uses its verifiable delegated authority from GLEIF to issue the organization its primary vLEI credential. This QVI issuance step is crucial for establishing the organization's verifiable digital identity within the ecosystem.

The vLEI ecosystem uses KERI and ACDC to extend the existing LEI system into the digital realm, creating a globally verifiable system for organizational identity that incorporates the roles individuals hold within an organization organizations, all anchored back to GLEIF as the root of trust.

<div class="alert alert-prymary">
  <b>📝 SUMMARY</b><hr>
KERI provides the secure identifier layer, ACDC provides the credential format on top of KERI, and vLEI is a specific application of both for organizational identity.
</div>






[<- Prev (Welcome)](101_05_Welcome_to_vLEI_Training_-_101.ipynb) | [Next (KERI Command Line Interface - KLI) ->](101_10_KERI_Command_Line_Interface.ipynb)
