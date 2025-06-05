# Advanced ACDC Features: Edges, Edge Operators, and Rules

<div class="alert alert-primary">
  <b>🎯 OBJECTIVE</b><hr>
    Introduce the concept of Edges in ACDCs, explain the Edge operators (I2I, NI2I, DI2I) that define relationships between chained ACDCs, illustrate their use with conceptual scenarios, and briefly introduce Rules as another component for embedding conditions within the ACDC.
</div>

## Understanding Edges and Rules
 
Authentic Chained Data Containers (ACDCs) are not always standalone credentials. One of their features is the ability to be cryptographically linked to other ACDCs, forming verifiable chains of information. These links are defined in the `e` (edges) section of an ACDC's payload.

Edges allow an ACDC to point to another ACDC, establishing a verifiable relationship between them. This relationship is further defined by **Edge Operators**, which dictate the rules for how the issuer and issuee of the connected ACDCs relate to each other.

Understanding these operators is crucial for designing ACDC ecosystems that model real-world authority, delegation, and contextual relationships. In this notebook, we will focus on three unary edge operators:

* **I2I (Issuer-To-Issuee)**
* **NI2I (Not-Issuer-To-Issuee)**
* **DI2I (Delegated-Issuer-To-Issuee)**

We will explore what each operator signifies and provide scenarios to illustrate their practical application.

Beyond these structural links, ACDCs also feature a dedicated `r` (rules) section. This section allows for the embedding of machine-readable logic, conditions, or even legal prose directly within the credential. While edges define how ACDCs are connected, rules can define additional constraints or behaviors associated with the ACDC itself or its relationships.

Edge operators provide the logic for validating the link between two ACDCs. They answer questions like: "Does the issuer of this ACDC need to be the subject of the ACDC it's pointing to?" or "Can the issuer be someone delegated by the subject of the linked ACDC?"

## I2I Operator: Issuer-To-Issuee

The core idea behind an I2I edge is to represent a direct chain of authority. The issuer of the current ACDC (the "near" ACDC containing the edge) is asserting its claims based on its status as the issuee of the ACDC it's pointing to (the "far" ACDC).

I2I signifies: "My authority to issue this current ACDC comes from the fact that I am the subject of the ACDC I am pointing to."

### I2I Scenario Examples

1.  **Endorsement for Building Access:**
    * **Scenario:** A company (ACME) issues a "Manager role" ACDC to an Employee. The Employee (now acting as an issuer by virtue of their managerial role) then issues an "Access" ACDC for a specific building to a sub-contractor they hired. The "Access" ACDC would have an I2I edge pointing back to the employee's "Manager role" ACDC.
    * **Chain:** ACME (Issuer) -> "Manager role" ACDC (Issuee: Employee) -> Employee (Issuer, leveraging their "Manager" status) -> "Access" ACDC (Issuee: Sub-contractor).
    * **Significance:** The I2I edge ensures the Manager issuing access is verifiably the same individual to whom ACME conferred managerial status.

2.  **Membership Level Endorsement for Event Access:**
    * **Scenario:** An Organization issues a "Gold Member" ACDC to an individual. This individual (Gold Member) then wants to bring a guest to an exclusive event. The organization's policies (which are embedded in the `r` section of the "Gold Member" ACDC) allow Gold Members to issue "Guest Pass" ACDCs. The "Guest Pass" issued by the Gold Member would have an I2I edge pointing to their "Gold Member" ACDC.
    * **Chain:** Organization (Issuer) -> "Gold Member" ACDC (Issuee: Individual) -> Individual (Issuer, using their Gold Member privilege) -> "Guest Pass" ACDC (Issuee: The Guest).
    * **Significance:** The validity of the guest pass relies on the issuer being a verified Gold Member, as established by the I2I link, and governed by additional rules specified in the r section (e.g., limit on number of guest passes).

### Use Cases for I2I

1.  **Delegation of Authority:** When an entity that was the subject (issuee) of a credential (e.g., "Manager Role") now needs to issue a subsequent credential by leveraging that conferred authority (e.g., "Project Approval" issued by the manager). 
2.  **Endorsement:** If one credential's authority directly enables the issuance of another by the same entity acting in a new capacity.
3.  **Hierarchical Relationships:** When representing a clear hierarchy where an entity's position (as an issuee of a credential defining that position) allows them to issue credentials further down the chain.
4.  **Sequential Processes:** In workflows where an entity receives a credential (making them an issuee) and then, as a next step in the process, issues another credential related to that item.
5.  **Default Expectation for Targeted ACDCs:** If the far node (the ACDC being pointed to) is a "Targeted ACDC" (i.e., has an issuee), the I2I operator is the default assumption unless otherwise specified. This implies a natural flow where the issuee of one ACDC becomes the issuer of the next related ACDC.

## NI2I Operator: Not-Issuer-To-Issuee

The purpose of the NI2I edge is to reference, associate, or link to another ACDC for context, support, or related information, where there isn't a direct delegation of authority or a requirement for the issuer of the current ACDC to be the subject of the referenced ACDC.

NI2I means that this ACDC I am pointing to provides relevant context, support, or related information for my current ACDC, but my authority to issue this current ACDC does not stem from my being the subject of that linked ACDC.

### NI2I Scenario Examples

1.  **Linking to an External Training Course Completion Certificate:**
    * **Scenario:** A Company issues an "Employee Skill Certified" ACDC to an employee after they complete an internal assessment. The employee also completed an external, third-party training course relevant to this skill. The "Employee Skill Certified" ACDC could have an NI2I edge pointing to the "Course Completion" ACDC issued by the external Training Provider.
    * **Relationship:** Company (Issuer) -> "Employee Skill Certified" ACDC (Issuee: Employee) --NI2I Edge--> "Course Completion" ACDC (Issued by: Training Provider, Issuee: Employee).
    * **Significance:** The company acknowledges the external training as supporting evidence. The r (rules) section of the "Employee Skill Certified" ACDC could specify how this external certification contributes to the overall skill validation (e.g., "External certification X fulfills requirement Y").

2.  **Proof of Insurance for a Rental Agreement:**
    * **Scenario:** A Car Rental Agency issues a "Rental Agreement" ACDC to a Customer. The customer is required to have valid car insurance. The "Rental Agreement" ACDC could have an NI2I edge pointing to the Customer's "Proof of Insurance" ACDC, which was issued by an Insurance Company.
    * **Relationship:** Rental Agency (Issuer) -> "Rental Agreement" ACDC (Issuee: Customer) --NI2I Edge--> "Proof of Insurance" ACDC (Issued by: Insurance Company, Issuee: Customer).
    * **Significance:** The rental agreement relies on the existence of an insurance policy. The `r` section of the "Rental Agreement" ACDC would likely contain critical rules defining the terms of the rental, insurance coverage requirements (e.g., minimum liability), and consequences of non-compliance, which are legally binding.

### Use Cases for NI2I

1.  **Referencing External Information:** When an ACDC needs to point to an ACDC that was issued by a third party and not specifically to the issuer of the current ACDC. The r (rules) section of the referencing ACDC might contain specific clauses on how that external information applies.
2.  **Providing Supporting Evidence from Third Parties:** Linking to credentials issued by other, independent parties that support a claim in the current ACDC.
3.  **Associating Related but Independent Credentials:** When linking credentials that are related but don't follow a direct chain of delegated authority from the same entity.
4.  **Linking to Untargeted ACDCs:** If the ACDC being pointed to is an "Untargeted ACDC" (i.e., does not have a specific issuee, representing a thing, a concept, or a general statement), then NI2I is appropriate. The issuer of the current ACDC isn't the "issuee" of a general concept.
5.  **Relaxing the I2I Constraint:** When you explicitly want to state that the issuer of the current ACDC is not necessarily the issuee of the linked ACDC, even if the linked ACDC is targeted.

## DI2I Operator: Delegated-Issuer-To-Issuee

The idea behind a DI2I edge is to represent a chain of authority where the issuer of the current ACDC is either the direct issuee of the referenced ACDC or a recognized delegate of that issuee. This allows for more flexible delegation chains than a strict I2I relationship.

DI2I signifies: My authority to issue this current ACDC comes from the fact that I am EITHER the subject of the ACDC I am pointing to OR I am a formally recognized delegate of that subject.

### DI2I Scenario Example

1.  **Supply Chain: Quality Control Release by Delegated Plant Manager:**
    * **Scenario:**
        * A Manufacturing Conglomerate issues a "Plant Operations Authority" ACDC to the General Manager (GM) of Plant A (Issuee: `GM_PlantA_AID`). This grants the GM overall responsibility for Plant A's output.
        * The GM of Plant A (AID: `GM_PlantA_AID`) delegates the authority for final quality control (QC) release of specific product lines (e.g., "Widget Model X") to the QC Shift Supervisor, Ms. Lee (AID: `QC_Lee_AID`), via KERI AID delegation.
        * Ms. Lee's team completes QC checks on a batch of Widget Model X, and she issues a "Batch Quality Approved" ACDC.
    * **Edge:** The "Batch Quality Approved" ACDC (issued by `QC_Lee_AID`) will have a DI2I edge pointing to the "Plant Operations Authority" ACDC (issuee: `GM_PlantA_AID`).
    * **Significance (Why DI2I?):** Ms. Lee's authority is a verifiable delegation from the GM. The `r` (rules) section of the "Batch Quality Approved" ACDC might further specify the exact QC standards that must be met for the approval to be valid, linking the delegated action to concrete operational requirements.

### Use Cases for DI2I

1.  **Delegation:** When authority is passed down through an intermediary. The entity issuing the current credential isn't the direct subject of the credential conferring original authority but is operating under a valid delegation from that subject.
2.  **Flexible Hierarchical Authority:** In complex organizations, the person signing off on something (issuing an ACDC) might not be the person who holds the primary credential for that domain but is acting on their behalf through a formal delegation chain verified via KERI's AID delegation mechanisms.
3.  **When the Issuer is Part of a Group Authorized by the Issuee:** The issuer is one of several individuals or entities who have been delegated authority by the issuee of the referenced ACDC.
4.  **Requires a Targeted Far Node:** Like I2I, the ACDC being pointed to (the "far node") by a DI2I edge MUST be a "Targeted ACDC" (i.e., it must have an issuee).
5.  **Expands on I2I:** It's a superset of I2I. If an I2I relationship is valid, a DI2I relationship would also be valid. However, DI2I also allows for valid issuers who are delegates of the far node's issuee.





<div class="alert alert-primary">
  <b>📝 SUMMARY</b><hr>
ACDC Edges (<code>e</code> section) link ACDCs, with Edge Operators defining relationship rules. The <code>r</code> (rules) section adds another layer for embedding machine-readable logic or legal prose.
<ul>
<li><b>I2I (Issuer-To-Issuee):</b> Use when the current ACDC's issuer's authority stems directly from being the subject (issuee) of the linked ACDC. Signifies direct authority. Example: A manager (issuee of "Manager" ACDC) issues project access.</li>
<li><b>NI2I (Not-Issuer-To-Issuee):</b> Use for referencing contextual or supporting ACDCs where the current issuer's authority doesn't derive from being the subject of the linked ACDC. Example: An "Employee Skill" ACDC linking to an external "Training Certificate" ACDC.</li>
<li><b>DI2I (Delegated-Issuer-To-Issuee):</b> Use when the current ACDC's issuer is either the subject of the linked ACDC or a formally recognized delegate of that subject. Allows for flexible, multi-step delegation. Example: A QC Supervisor (delegate of Plant GM) issues a "Batch Approved" ACDC pointing to the GM's "Plant Authority" ACDC.</li>
</ul>    
</div>
