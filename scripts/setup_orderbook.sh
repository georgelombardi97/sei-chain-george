#!/bin/bash

CHAIN_DIR=./data
CHAINID_1=sei-chain
VAL_MNEMONIC_1="clock post desk civil pottery foster expand merit dash seminar song memory figure uniform spice circle try happy obvious trash crime hybrid hood cushion"
VAL_MNEMONIC_2="angry twist harsh drastic left brass behave host shove marriage fall update business leg direct reward object ugly security warm tuna model broccoli choice"
DEMO_MNEMONIC_1="banner spread envelope side kite person disagree path silver will brother under couch edit food venture squirrel civil budget number acquire point work mass"
DEMO_MNEMONIC_2="veteran try aware erosion drink dance decade comic dawn museum release episode original list ability owner size tuition surface ceiling depth seminar capable only"
DEMO_MNEMONIC_3="obscure canal because tomorrow tribe sibling describe satoshi kiwi upgrade bless empty math trend erosion oblige donate label birth chronic hazard ensure wreck shine"
RLY_MNEMONIC_1="alley afraid soup fall idea toss can goose become valve initial strong forward bright dish figure check leopard decide warfare hub unusual join cart"
RLY_MNEMONIC_2="record gift you once hip style during joke field prize dust unique length more pencil transfer quit train device arrive energy sort steak upset"

SEID_HOME=$CHAIN_DIR/$CHAINID_1
export SEID_HOME=$SEID_HOME

WALLET_ADDR_1=$(seid --home $CHAIN_DIR/$CHAINID_1 keys show demowallet1 --keyring-backend test -a)
WALLET_ADDR_2=$(seid --home $CHAIN_DIR/$CHAINID_1 keys show demowallet2 --keyring-backend test -a)
WALLET_ADDR_3=$(seid --home $CHAIN_DIR/$CHAINID_1 keys show demowallet3 --keyring-backend test -a)

# store code
STORE_RES=$(seid tx wasm store ./scripts/spot_lite.wasm --from=demowallet1 --chain-id=$CHAINID_1 --gas auto --gas-adjustment 1.3 --broadcast-mode=block --keyring-backend test --home $SEID_HOME -y --output json)
CODE_ID=$(echo $STORE_RES | jq -r '.logs[0].events[-1].attributes[0].value')
echo "CODE_ID:" $CODE_ID

# instantiate the contract
INSTANTIATE_RES=$(seid tx wasm instantiate $CODE_ID "{}" --label "tmp1" --no-admin \
  --from demowallet1  --keyring-backend test --home $CHAIN_DIR/$CHAINID_1 \
   --gas auto --gas-adjustment 1.3 -b block -y --chain-id $CHAINID_1 --output json)
CONTRACT_ADDR=$(echo $INSTANTIATE_RES | jq -r '.logs[0].events[0].attributes[0].value')
echo "CONTRACT_ADDR:" $CONTRACT_ADDR

# seid tx dex register-contract [contract address] [code id] [need hook] [need order matching] [dependency1,dependency2,...] [flags]
REGISTER_RES=$(seid tx dex register-contract $CONTRACT_ADDR $CODE_ID false true -y --from=demowallet1 \
              --gas auto --gas-adjustment 1.3 -b block --chain-id=$CHAINID_1 --broadcast-mode=block \
              --keyring-backend test --home $CHAIN_DIR/$CHAINID_1 --output json)
#echo "REGISTER_RES:" $REGISTER_RES

PROPOSAL=$(cat scripts/register_pair_proposal.json | sed -e "s/\"contract_addr\": \"aaa\"/\"contract_addr\": \"$CONTRACT_ADDR\"/g")
echo $PROPOSAL | jq | cat > scripts/tmp_proposal.json
#echo "PROPOSAL:" $PROPOSAL
REGISTER_PAIRS=$(seid tx dex register-pairs-proposal scripts/tmp_proposal.json -y --from=demowallet1 \
                 --gas auto --gas-adjustment 1.3 -b block --chain-id=$CHAINID_1 --gas=10000000 --broadcast-mode=block \
                 --keyring-backend test --home $CHAIN_DIR/$CHAINID_1 --output json)


#echo "REGISTER_PAIRS:" $REGISTER_PAIRS
PROPOSAL_ID=$(echo $REGISTER_PAIRS | jq -r '.logs[0].events[-2].attributes[0].value')
echo "PROPOSAL_ID:" $PROPOSAL_ID

DEPOSIT_RES=$(seid tx gov deposit $PROPOSAL_ID 10000000usei -y --from=demowallet1 \
    --gas auto --gas-adjustment 1.3 -b block --chain-id=$CHAINID_1 --broadcast-mode=block \
    --keyring-backend test --home $CHAIN_DIR/$CHAINID_1 --output json)

VOTE_RES=$(seid tx gov vote $PROPOSAL_ID yes -y --from=val1 \
           --gas auto --gas-adjustment 1.3 -b block --chain-id=$CHAINID_1 \
           --keyring-backend test --home $CHAIN_DIR/$CHAINID_1 --output json)

#echo "VOTE_RES:" $VOTE_RES
#exit
printf "\n\nWaiting for the proposal to pass"
sleep 10

#"PositionDirection?Price?Quantitiy?PriceDenom?AssetDenom?OrderType?Data"
ORDER_RES=$(seid tx dex place-orders $CONTRACT_ADDR 'LONG?1.01?50?uusdc?uatom?LIMIT?{"leverage":"1","position_effect":"Open"}' \
    --amount=10000000000uusdc -y --from=demowallet1 --gas auto --gas-adjustment 1.3 -b block --chain-id=$CHAINID_1 \
    --keyring-backend test --home $CHAIN_DIR/$CHAINID_1 --output json)
#echo "ORDER_RES:"$ORDER_RES
ORDER_RES=$(seid tx dex place-orders $CONTRACT_ADDR 'LONG?1.0?50?uusdc?uatom?LIMIT?{"leverage":"1","position_effect":"Open"}' \
    --amount=10000000000uusdc -y --from=demowallet1 --gas auto --gas-adjustment 1.3 -b block --chain-id=$CHAINID_1 \
    --keyring-backend test --home $CHAIN_DIR/$CHAINID_1 --output json)
ORDER_RES=$(seid tx dex place-orders $CONTRACT_ADDR 'SHORT?1.2?80?uusdc?uatom?LIMIT?{"leverage":"1","position_effect":"Open"}' \
    --amount=10000000000uatom -y --from=demowallet1 --gas auto --gas-adjustment 1.3 -b block --chain-id=$CHAINID_1 \
    --keyring-backend test --home $CHAIN_DIR/$CHAINID_1 --output json)
ORDER_RES=$(seid tx dex place-orders $CONTRACT_ADDR 'SHORT?1.3?90?uusdc?uatom?LIMIT?{"leverage":"1","position_effect":"Open"}' \
    --amount=10000000000uatom -y --from=demowallet1 --gas auto --gas-adjustment 1.3 -b block --chain-id=$CHAINID_1 \
    --keyring-backend test --home $CHAIN_DIR/$CHAINID_1 --output json)
#echo "ORDER_RES:"$ORDER_RES
sleep 2
echo "Open Orders:"
seid q dex get-orders $CONTRACT_ADDR  $WALLET_ADDR_1

echo ""
echo "Trading..."
TRADE_RES=$(seid tx dex place-orders $CONTRACT_ADDR 'LONG?1.2?50?uusdc?uatom?LIMIT?{"leverage":"1","gg":"55","position_effect":"Open"}' \
    --amount=10000000000uusdc -y --from=demowallet2 --gas auto --gas-adjustment 1.3 -b block --chain-id=$CHAINID_1 \
    --keyring-backend test --home $CHAIN_DIR/$CHAINID_1 --output json)

#echo "TRADE_RES:"
#echo $TRADE_RES | jq ".height"
TRADE_HEIGHT=$(echo $TRADE_RES | jq -r ".height")
echo "TRADE_HEIGHT:" $TRADE_HEIGHT

MATCH_RESULT=$(seid q dex get-match-result $CONTRACT_ADDR $TRADE_HEIGHT)
echo "\n\nMATCH_RESULT:"
echo $MATCH_RESULT

