
# Aztec Sequencer Node Setup Guide (Root User Only)

This guide will walk you through setting up an **Aztec Sequencer Node** on the testnet network and obtaining the "Apprentice" role on Discord. The process is fully automated using a script and **must be executed as the root user**.

## System Requirements

| **Requirement**         | **Details**         |
|-------------------------|---------------------|
| **RAM**                 | Minimum 16 GB       |
| **CPU**                 | 8 Cores             |
| **Operating System**    | Ubuntu 22.04 or higher |
| **Storage**             | 1TB SSD             |

### Recommended Servers:

- **For Long-Term Running:**  
  NETCUP or Contabo 8 Core VPS

- **For Earning the Role:**  
  NETCUP or Contabo 6 Core VPS

---

## Pre-Setup Requirements

1. **Create a New MetaMask Wallet.**
2. **Get Sepolia Test ETH**: [Alchemy Faucet](https://www.alchemy.com/faucets)
3. **Obtain Sepolia RPC URL**: [Alchemy Dashboard](https://dashboard.alchemy.com)
4. **Obtain Beacon (Consensus) RPC URL**: [Chainstack Global Nodes](https://chainstack.com/global-nodes)

---

## 1- ENV Setup (Under Root Folder Only)

Log into your VPS as the `root` user and run the following command:

```bash
curl -sSL -o /root/aztec.env https://raw.githubusercontent.com/Farukest/Aztec-Node-Setup/main/aztec.env
```
It will download aztec.env file under root.. 
The script will need for aztec.env file under root folder with the following information need to be filled:

- **Sepolia RPC URL**
- **Beacon (Consensus) URL**
- **Private Key**
- **Wallet Address**

To ensure the node run properly, fill a `aztec.env` file like below examples:

```bash
RPC=Alchemy RPC URL (e.g., https://eth-sepolia.g.alchemy.com/v2/6VOM....)
BEACON=Chainstack Beacon URL (e.g., https://ethereum-sepolia.core.chainstack.com/beacon/7ace2d4...)
PRVKEY=Your wallet private key 0x80..
PUBKEY=Your wallet public key 0xa5..
```

---

## 2- Node Run Script (Under Root Folder Only)

```bash
[ -f "/root/script.sh" ] && rm /root/script.sh && apt update -y && apt install curl wget screen jq -y && curl -sSL -o /root/script.sh https://raw.githubusercontent.com/Farukest/Aztec-Node-Setup/main/aztec_node_run.sh && chmod +x /root/script.sh && /root/script.sh
```

Once the setup is complete, check with `screen -r aztec` 
Note : The node will run in a screen session named **aztec**.


## 3- Screen Usage

To exit the screen session:

- Press **CTRL + A**, then **D**

To reconnect to the screen session:

- Run `screen -r aztec`

---

## 4- Earning Discord "Apprentice" Role

After your node has been running for 5 minutes, follow these steps:

### A- Get Block Number

Run the following command to get the block number:

```bash
curl -s -X POST -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","method":"node_getL2Tips","params":[],"id":67}' http://localhost:8080 | jq -r ".result.proven.number"
```

This command will provide you with a block number. Take note of it.

### B- Get Proof

Replace the "BLOCK" part in the following command with the block number you received:

```bash
curl -s -X POST -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","method":"node_getArchiveSiblingPath","params":["BLOCK","BLOCK"],"id":67}' http://localhost:8080 | jq -r ".result"
```

The output will be a long string, which is your proof. Copy all of it.

### C- Get Discord Role

- Join the Discord server: [Aztec Discord](https://discord.gg/aztec)
- Go to the **#operators > start-here** channel
- Run the command:
  ```
  /operator start
  ```
- Provide the following details:
  - Your Wallet Address
  - Block Number
  - Proof (the long string you copied)

Once the role is verified, you will be granted the **Apprentice** role on Discord.

---

## 5- Validator Registration (Optional)

Once your node is fully synced, you can register as a validator by running the following command:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Farukest/Aztec-Node-Setup/main/validator_kayıt.sh)"
```

If the script works, you’ll be registered as a validator. If you see the following message, the daily limit may have been reached:

⚠ **The daily limit may have been reached. Please try again tomorrow.**

---

## Troubleshooting

If you face any issues during the setup, please check the logs inside the **aztec** screen session, or feel free to ask for support in the [Aztec Discord](https://discord.gg/aztec).
