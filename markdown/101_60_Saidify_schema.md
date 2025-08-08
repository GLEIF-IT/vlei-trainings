# SAIDifying ACDC Schemas

<div class="alert alert-primary">
  <b>🎯 OBJECTIVE</b><hr>
    Explain the purpose and benefits of using Self-Addressing Identifiers (SAIDs) for ACDC schemas and demonstrate the practical, recursive process of calculating and embedding these SAIDs into an ACDC schema file ("SAIDifying").
</div>

## Role of Schema SAIDs

A key feature of KERI and ACDCs is the use of SAIDs (Self-Addressing Identifiers) for schemas. The SAID in a schema's `$id` field is a digest of the canonical form of that schema block.

Why it matters:
- **Lookup:** SAIDs provide a universal, unique identifier to retrieve a specific, verified version of a schema.
- **Immutability:** Once a schema version is SAIDified and published, it's cryptographically locked. New versions require a new SAID.
- **Integrity:** If anyone modifies the schema file after its SAID has been calculated and embedded, the SAID will no longer match the content, making tampering evident.
      
Calculating and embedding these SAIDs requires a specific process, often called **"SAIDifying"**. This involves calculating the SAIDs for the innermost blocks (like attributes, edges, rules) first, embedding them, and then calculating the SAID for the next level up, until the top-level schema SAID is computed.

## The SAIDification Process

We have provided a sample schema and a utility function to help you SAIDfy the schema. Here are the steps.

### Step 1: Write Schema JSON

First, you will create a JSON file with the basic structure as seen in the previous notebook. Since we provide the schema, you don't need to worry about it. But review the file **[sample_credential_schema.json](config/schemas/sample_schema.bak.json)**, since it is the schema you will use, initially unprocessed. Notice the `$id` fields are initially empty strings `""`. 

### Step 2: Process and Embed SAIDs

Now, you need to process the schema to embed the Self-Addressing Identifiers (SAIDs). For this, we use the provided **[Python script](scripts/saidify.py)** available in the scripts folder. It calculates the required digests from the content and adds the SAIDs to the file. 


```python
from scripts.saidify import process_schema_file

# Run the saidify script
process_schema_file("./config/schemas/sample_schema.bak.json", "./config/schemas/sample_schema.json", True)

# Displays all "$id" values from any JSON objects found recursively in the schema file
print("\ncalculated saids ($id):")
!jq '.. | objects | .["$id"]? // empty' ./config/schemas/sample_schema.json

```

    Successfully wrote processed data to ./config/schemas/sample_schema.json
    
    calculated saids ($id):
    "EJgBEKtba5ewUgG3k268YadY2eGBRrsVF6fF6tLyoRni"
    "ED614TseulOlXWhFNsOcKIKt9Na0gCByugqyKVsva-gl"


After running this command, if you inspect output **[sample_credential_schema.json](config/schemas/sample_schema.json)**, you will see that the previously empty `"id": ""` fields (both the top-level one and the one inside the a block) have been populated with SAID strings (long Base64-like identifiers).

You now have a cryptographically verifiable schema identified by its top-level SAID!

<div class="alert alert-info">
  <b>💡 TIP</b><hr>
    The KERI command-line tool (`kli`) provides the <code>kli saidify</code> command. When used like <code>kli saidify --file &lt;filename&gt; --label '&lt;label&gt;'</code>, it calculates a SAID for the specified file content and can embed it into the field matching the label (e.g., <code>"$id"</code> at the top level).
    <br><br>
    However, automatically processing nested structures and dependencies within complex ACDC schemas typically requires helper tools or custom scripts to ensure all inner SAIDs are calculated and embedded correctly before the final outer SAID is generated.
</div>

## Making Schemas Discoverable
For an issuer to issue an ACDC using this schema, and for a recipient/verifier to validate it, they need access to this exact, SAIDified schema definition.

How do they get it? The SAID acts as a universal lookup key. Common ways to make schemas available include:

- Simple Web Server: Host the SAIDified JSON file on a basic web server. Controllers can be configured (often via OOBIs, covered later) to fetch the schema from that URL using its SAID.   
- Content-Addressable Network: Store the schema on a network like IPFS, where the SAID naturally aligns with the content digest used for retrieval.
- Direct Exchange: For specific interactions, the schema could potentially be exchanged directly between parties (though less common for widely used schemas).
The key point is that the schema, identified by its SAID, must be retrievable by parties needing to issue or verify credentials based on it.

In the next notebook, we'll use our SAIDified schema to set up a Credential Registry and issue our first actual ACDC.

<div class="alert alert-primary">
  <b>📝 SUMMARY</b><hr>
    KERI uses Self-Addressing Identifiers (SAIDs) as unique, verifiable identifiers for ACDC schemas, embedded in the <code>&#36;id</code> field. A schema's SAID is a cryptographic digest of its content, guaranteeing integrity (tamper-evidence) and immutability (specific to that version). This process, called "SAIDifying," involves calculating and embedding SAIDs recursively from inner blocks outwards. Practically, tools or scripts (like the example <code>process_schema_file</code> or <code>kli saidify</code>) are used to populate the initially empty <code>&#36;id</code> fields in the schema JSON. Once SAIDified, the schema must be accessible (e.g., hosted on a server) so others can retrieve and verify it using its SAID.
</div>


```python

```
