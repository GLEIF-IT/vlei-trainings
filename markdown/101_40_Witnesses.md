# KLI Operations: Configuring AID Witnesses

<div class="alert alert-primary">
  <b>🎯 OBJECTIVE</b><hr>
Demonstrate how to configure witnesses and the Threshold of Accountable Duplicity (TOAD) in a configuration file and use it to create an AID 
</div>

## Verifying the Demo Witness Network

Now that you understand Witnesses and oobis, let's see some practical usage.

Within the deployment of these notebooks, we have included a demo witness network. It is composed of three witnesses: 
- http://witness-demo:5642/oobi/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
- http://witness-demo:5643/oobi/BLskRTInXnMxWaGqcpSyMgo0nYbalW99cGZESrz3zapM
- http://witness-demo:5644/oobi/BIKKuvBwpmDVA4Ds-EpL5bt9OqPzWPja2LigFYZN2YfX

(These witnesses are predefined (**[wan.json](config/witness-demo-docker/wan.json), [wes.json](config/witness-demo-docker/wes.json), [wil.json](config/witness-demo-docker/wil.json)**); that's why we know the prefixes beforehand) 

To verify the witness network is working, let's query the KEL of one of them using its oobi and `curl`. 


```python
!curl -s http://witness-demo:5642/oobi/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
```

    {"v":"KERI10JSON0000fd_","t":"icp","d":"EIkO4CUmYXukX4auGU9yaFoQaIicfVZkazQ0A3IO5biT","i":"BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha","s":"0","kt":"1","k":["BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha"],"nt":"0","n":[],"bt":"0","b":[],"c":[],"a":[]}-VAn-AABAAAMlb78gUo1_gPDwxbXyERk2sW8B0mtiNuACutAygnY78PHYUjbPj1fSY1jyid8fl4-TXgLXPnDmeoUs1UO-H0A-EAB0AAAAAAAAAAAAAAAAAAAAAAA1AAG2025-06-05T13c27c38d979711p00c00{"v":"KERI10JSON0000fd_","t":"rpy","d":"EHkrUtl8Nt7nZjJ8mApuG80us9E_td3oa4V-oW2clB2K","dt":"2024-12-31T14:06:30.123456+00:00","r":"/loc/scheme","a":{"eid":"BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha","scheme":"http","url":"http://witness-demo:5642/"}}-VAi-CABBBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha0BDkVOk5p25Rhim3LkhYXmDNNiUcZkgCp_BWvEB45q6f_pKJBYYlpUABpci5DMzBNXlz4RvK8ImKVc_cH-0D8Q8D{"v":"KERI10JSON0000fb_","t":"rpy","d":"EDSjg0HilC3L4I_eI53C3_6lW9I6pPbR4SWGgoOmDhMb","dt":"2024-12-31T14:06:30.123456+00:00","r":"/loc/scheme","a":{"eid":"BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha","scheme":"tcp","url":"tcp://witness-demo:5632/"}}-VAi-CABBBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha0BDLG3-HNp-kclaNamqIRI46rNcAhpIEQBDON2HO28r9zO-6S53_w7AA_Q4Weg4eAjvTGiXiNExhO86elrIEd74F{"v":"KERI10JSON000116_","t":"rpy","d":"EBBDzl8D5gFgFkVXaB-XNQlCem-4y5JywPcueWAMRfCp","dt":"2024-12-31T14:06:30.123456+00:00","r":"/end/role/add","a":{"cid":"BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha","role":"controller","eid":"BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha"}}-VAi-CABBBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha0BDt7alD1tA9x_9vVMKxY1Ne113qJ-xDdCyThnAh6_c13Rsrb9WW5HlKyQxyW5DVXWJjQ65yzME5kCLBiJWYBKEL

The command should have returned a KEL; you should be able to recognize part of it. It starts with `{"v": "KERI10JSON0000fd_", "t": "icp"...`. If so, the witness network is up and running. 

## Keystore Initialization with Witness Configuration

Let's continue with the example. As usual, we need to create a keystore, but this time we are going to do something different. We are going to use a configuration file to provide the OOBIS of the witnesses to the keystore.

The content of the configuration file can be seen here: **[Keystore configuration file](config/keri/cf/keystore_init_config.json)**


```python
# Imports and Utility functions
from scripts.utils import clear_keri
clear_keri()

keystore_name="tests-keystore"

keystore_passcode="xSLg286d4iWiRg2mzGYca"

salt="0ABeuT2dErMrqFE5Dmrnc2Bq"

!kli init --name {keystore_name} --passcode {keystore_passcode} --salt {salt} \
    --config-dir ./config \
    --config-file keystore_init_config.json

```

    Proceeding with deletion of '/usr/local/var/keri/' without confirmation.
    ✅ Successfully removed: /usr/local/var/keri/


    KERI Keystore created at: /usr/local/var/keri/ks/tests-keystore
    KERI Database created at: /usr/local/var/keri/db/tests-keystore
    KERI Credential Store created at: /usr/local/var/keri/reg/tests-keystore
    	aeid: BD-1udeJaXFzKbSUFb6nhmndaLlMj-pdlNvNoN562h3z
    
    Loading 3 OOBIs...


    http://witness-demo:5642/oobi/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha/controller?name=Wan&tag=witness succeeded
    http://witness-demo:5643/oobi/BLskRTInXnMxWaGqcpSyMgo0nYbalW99cGZESrz3zapM/controller?name=Wes&tag=witness succeeded
    http://witness-demo:5644/oobi/BIKKuvBwpmDVA4Ds-EpL5bt9OqPzWPja2LigFYZN2YfX/controller?name=Wil&tag=witness succeeded


## Listing keystore contacts
As you can see, the initialization has loaded the oobis. You can also check the loaded witness information by calling the `kli contact list` command  


```python
!kli contacts list --name {keystore_name} --passcode {keystore_passcode}
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


## Incepting an AID with Witness Configuration

Next, you can incept a new AID. Use a configuration file again.

The content of the configuration file (**[aid configuration file](config/aid_inception_config.json)**) can be seen here: 

```json
{
    "transferable": true,
    "wits": ["BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha","BLskRTInXnMxWaGqcpSyMgo0nYbalW99cGZESrz3zapM"],
    "toad": 1,
    "icount": 1,
    "ncount": 1,
    "isith": "1",
    "nsith": "1"
}
```

Notable highlights in this configuration are the inclusion of the witnesses' prefixes and the `toad` set to 1

Here is the `incept` command:


```python
aid_alias_transferable = "aid-transferable"

!kli incept --name {keystore_name} --alias {aid_alias_transferable} --passcode {keystore_passcode} \
    --file ./config/aid_inception_config.json
```

    Waiting for witness receipts...


    Prefix  EJq-DYl9EQVlY1lShETUWLQuDEcVdRkWXfkkGBNDugjZ
    	Public key 1:  DOdymqdtGJzeoRRSL9C8Suni6ebPaSqQfuEUM_JFkPQx
    


Check the status of the AID using `kli status`


```python
!kli status --name {keystore_name} --alias {aid_alias_transferable} --passcode {keystore_passcode} --verbose
```

    Alias: 	aid-transferable
    Identifier: EJq-DYl9EQVlY1lShETUWLQuDEcVdRkWXfkkGBNDugjZ
    Seq No:	0
    
    Witnesses:
    Count:		2
    Receipts:	2
    Threshold:	1
    
    Public Keys:	
    	1. DOdymqdtGJzeoRRSL9C8Suni6ebPaSqQfuEUM_JFkPQx
    
    
    Witnesses:	
    	1. BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
    	2. BLskRTInXnMxWaGqcpSyMgo0nYbalW99cGZESrz3zapM
    
    {
     "v": "KERI10JSON000188_",
     "t": "icp",
     "d": "EJq-DYl9EQVlY1lShETUWLQuDEcVdRkWXfkkGBNDugjZ",
     "i": "EJq-DYl9EQVlY1lShETUWLQuDEcVdRkWXfkkGBNDugjZ",
     "s": "0",
     "kt": "1",
     "k": [
      "DOdymqdtGJzeoRRSL9C8Suni6ebPaSqQfuEUM_JFkPQx"
     ],
     "nt": "1",
     "n": [
      "EO95Pwm8WYG_dIS2-H6LGoXmzOEEnbRljeIjy-Hd7aVx"
     ],
     "bt": "1",
     "b": [
      "BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha",
      "BLskRTInXnMxWaGqcpSyMgo0nYbalW99cGZESrz3zapM"
     ],
     "c": [],
     "a": []
    }
    


In this status, you will find a few new things:
- The witnesses section has a count of 2 and mentions two receipts and a threshold of 1
- The KEL has the `b` field populated with the witnesses' prefixes
- The `bt` threshold is set to 1 (toad)

<div class="alert alert-primary">
  <b>📝 SUMMARY</b><hr>
Witnesses are specified during AID inception using a configuration file that lists their prefixes (wits) and sets the Threshold of Accountable Duplicity (toad). The kli incept command utilizes this file to create the AID, embedding the witness information into the inception event. Checking the AID status with kli status <code>--verbose</code> reveals the witness prefixes in the <code>b</code> field, the TOAD in the <code>bt</code> field, and any received witness receipts.
</div>
