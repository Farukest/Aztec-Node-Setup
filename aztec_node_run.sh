#!/bin/bash

ORANGE='\033[0;33m'
GREEN='\033[1;32m'
CYAN='\033[0;36m'
RESET='\033[0m'

clear
echo -e "${CYAN}"
echo "███    ██ ██ ███████  █████  ███    ███ ███    ███"
echo "████   ██ ██    ████ ██   ██ ████  ████ ████  ████"
echo "██ ██  ██ ██   ███   ███████ ██ ████ ██ ██ ████ ██"
echo "██  ██ ██ ██  ███    ██   ██ ██  ██  ██ ██  ██  ██"
echo "██   ████ ██ ███████ ██   ██ ██      ██ ██      ██"
echo -e "${RESET}"
echo -e "${GREEN}Starting script: Created by Faruk-( NIZAMULMULK ).${RESET}"

sleep 2

echo -e "${CYAN}Installing required dependencies...${RESET}"
sudo apt update && sudo apt install curl wget screen jq -y

echo -e "${CYAN}Checking Docker installation...${RESET}"
if ! command -v docker &> /dev/null; then
  echo -e "${ORANGE}Docker not found, installing...${RESET}"
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  rm get-docker.sh
fi

echo -e "${GREEN}Docker installation complete.${RESET}"


echo -e "${CYAN}Checking for existing Aztec Docker image...${RESET}"

# Docker image check
if docker images | grep -q "aztecprotocol/aztec"; then
  echo -e "${ORANGE}Aztec Docker image found. Removing...${RESET}"
  docker rmi -f aztecprotocol/aztec:latest || true
fi


echo -e "${CYAN}Installing Aztec CLI...${RESET}"
curl -fsSL https://install.aztec.network | bash
export PATH="$HOME/.aztec/bin:$PATH"

echo -e "${CYAN}Switching to testnet...${RESET}"
aztec-up alpha-testnet

echo -e "${CYAN}Detecting public IP address...${RESET}"
IP=$(curl -s https://api.ipify.org)
echo -e "${GREEN}Detected IP: $IP${RESET}"

# Load .env variables
echo -e "${CYAN}Reading parameters from aztec.env...${RESET}"
if [ -f /root/aztec.env ]; then
  while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" =~ ^# ]] && continue
    value=$(echo "$value" | tr -d '[:space:]\r\n')
    export "$key=$value"
  done < /root/aztec.env
else
  echo -e "${ORANGE}Error: /root/aztec.env file not found!${RESET}"
  exit 1
fi

# Check if required variables are defined
if [ -z "$RPC" ] || [ -z "$BEACON" ] || [ -z "$PRVKEY" ] || [ -z "$PUBKEY" ]; then
  echo -e "${ORANGE}Error: RPC, BEACON, PRVKEY, or PUBKEY is missing in aztec.env!${RESET}"
  exit 1
fi

# Remove 0x prefix from PRVKEY if present
PRVKEY=$(echo "$PRVKEY" | sed 's/^0x//')

echo -e "${CYAN}Starting Aztec node...${RESET}"

cat > $HOME/start_aztec_node.sh <<EOF
#!/bin/bash
export PATH=\$PATH:\$HOME/.aztec/bin
aztec start --node --archiver --sequencer \\
  --network alpha-testnet \\
  --l1-rpc-urls $RPC \\
  --l1-consensus-host-urls $BEACON \\
  --sequencer.validatorPrivateKey $PRVKEY \\
  --sequencer.coinbase $PUBKEY \\
  --p2p.p2pIp $IP \\
  --p2p.maxTxPoolSize 1000000000
EOF

chmod +x $HOME/start_aztec_node.sh
screen -dmS aztec $HOME/start_aztec_node.sh

echo -e "${GREEN}Node started successfully. Use 'screen -r aztec' to view the screen session.${RESET}"
