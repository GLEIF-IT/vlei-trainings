# Understanding the KERI Command Line Interface (KLI)

<div class="alert alert-primary">
  <b>🎯 OBJECTIVE</b><hr>
Introduce the KERI Command Line Interface (KLI) and demonstrate some of its basic utility commands.
</div>

## Using KLI in Notebooks

Throughout these notebooks, you will interact with the KERI protocol using the **KLI**. The KLI is the standard text-based tool for managing identifiers and infrastructure directly from your computer's terminal. 

Since you are working within Jupyter notebooks, the KLI commands are written with an exclamation mark prefix (`!`). This tells the notebook environment to run the command in the underlying system shell, rather than as Python code. So, you'll frequently see commands structured like this:

`!kli <command> [options]`  

**What can you do with KLI?**

The KLI provides a wide range of functionalities. Key capabilities include:
- **Identifier management**: Management and creation of keystores and identifiers
- **Utility functions**: Functions to facilitate KERI-related operations for debugging and troubleshooting.
- **Credential management**: Creation of credentials
- **Comunication operations**: Establishing connections between AIDs
- **IPEX actions**: To issue and present credentials
- **Run witness**: Start a witness process in order to receipt key events
- **Others**: The KLI provides commands for most of the features available in the KERI and ACDC protocol implementations.



<div class="alert alert-info">
  <b>ℹ️ NOTE</b><hr>
    There are UI based methods to manage Identifiers, known as wallets, but for the purpose of this training, the KLI offers a good compromise between ease of use and visibility of technical details. 
</div>

## Overview of Basic Utilities

Let's explore some helpful commands available in the **KERI Command Line Interface (KLI)**.

This isn't a complete list of every command, but it covers some essential utilities that you'll find useful as you work with KERI.

**KERI library version**


```python
!kli version
```

    Library version: 1.2.8


**Generate a salt**: Create a new random salt (or seed) in the fully-qualified [CESR](https://trustoverip.github.io/tswg-cesr-specification/) format. A salt is a random value used as an input when generating cryptographic key pairs to help ensure their uniqueness and security.

What it means to be fully qualified is that the bytes in the cryptographic salt are ordered according to the CESR protocol. This ordering will be explained in a later training when CESR is introduced and explained. For now just think of CESR as a custom file format for KERI and ACDC data.


```python
# This will output a qualified base64 string representing the salt
!kli salt
```

    0ADnHkHNLRtIG5xtdwFlXv68


**Generate a passcode**: The passcode is used to encrypt your keystore, providing an additional layer of protection.


```python
# This will output a random string suitable for use as an encryption passcode
!kli passcode generate
```

    As1NOxmtbfW3aOTJ1vihB


**Print a timestamp**: Timestamps are typically used in operations involving multiple signers with what are called multi-signature (or "multisig") groups.


```python
!kli time
```

    2025-06-05T22:19:24.327823+00:00


**Display help menu**


```python
!kli -h
```

    usage: kli [-h] command ...
    
    options:
      -h, --help       show this help message and exit
    
    subcommands:
    
      command
        aid            Print the AID for a given alias
        challenge
        clean          Cleans and migrates a database and keystore
        contacts
        decrypt        Decrypt arbitrary data for AIDs with Ed25519 p ...
        delegate
        did
        ends
        escrow
        event          Print an event from an AID, or specific values ...
        export         Export key events in CESR stream format
        incept         Initialize a prefix
        init           Create a database and keystore
        interact       Create and publish an interaction event
        introduce      Send an rpy /introduce message to recipient wi ...
        ipex
        kevers         Poll events at controller for prefix
        list           List existing identifiers
        local
        location
        mailbox
        migrate
        multisig
        nonce          Print a new random nonce
        notifications
        oobi
        passcode
        query          Request KEL from Witness
        rename         Change the alias for a local identifier
        rollback       Revert an unpublished interaction event at the ...
        rotate         Rotate keys
        saidify        Saidify a JSON file.
        salt           Print a new random passcode
        sign           Sign an arbitrary string
        ssh
        status         View status of a local AID
        time           Print a new time
        vc
        verify         Verify signature(s) on arbitrary data
        version        Print version of KLI
        watcher
        witness


Additional commands will be introduced as they are used in upcoming trainings.

[<- Prev (Intro)](101_07_Introduction_to-KERI_ACDC_and_vLEI.ipynb) | [Next (Controllers and Identifiers) ->](101_15_Controllers_and_Identifiers.ipynb)
