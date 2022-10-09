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

rm -rf $CHAIN_DIR/$CHAINID_1 &> /dev/null
if ! mkdir -p $CHAIN_DIR/$CHAINID_1 2>/dev/null; then
    echo "Failed to create chain folder. Aborting..."
    exit 1
fi

seid init test --home $CHAIN_DIR/$CHAINID_1 --chain-id=$CHAINID_1

echo $VAL_MNEMONIC_1  |  seid keys add val1 --home $CHAIN_DIR/$CHAINID_1 --recover --keyring-backend=test
echo $DEMO_MNEMONIC_1 | seid keys add demowallet1 --home $CHAIN_DIR/$CHAINID_1 --recover --keyring-backend=test
echo $DEMO_MNEMONIC_2 | seid keys add demowallet2 --home $CHAIN_DIR/$CHAINID_1 --recover --keyring-backend=test
echo $DEMO_MNEMONIC_3 | seid keys add demowallet3 --home $CHAIN_DIR/$CHAINID_1 --recover --keyring-baƒckend=test

#~/go/bin/seid keys add $keyname
#seid add-genesis-account $(~/go/bin/seid keys show $keyname -a) 100000000000000000000usei,100000000000000000000uusdc,100000000000000000000uatom
seid add-genesis-account $(seid keys show val1 --keyring-backend test -a --home $CHAIN_DIR/$CHAINID_1) 100000000000000000000usei,100000000000000000000uusdc,100000000000000000000uatom --home $CHAIN_DIR/$CHAINID_1
seid add-genesis-account $(seid --home $CHAIN_DIR/$CHAINID_1 keys show demowallet1 --keyring-backend test -a) 100000000000000000000usei,100000000000000000000uusdc,100000000000000000000uatom  --home $CHAIN_DIR/$CHAINID_1
seid add-genesis-account $(seid --home $CHAIN_DIR/$CHAINID_1 keys show demowallet2 --keyring-backend test -a) 100000000000000000000usei,100000000000000000000uusdc,100000000000000000000uatom  --home $CHAIN_DIR/$CHAINID_1
seid add-genesis-account $(seid --home $CHAIN_DIR/$CHAINID_1 keys show demowallet3 --keyring-backend test -a) 100000000000000000000usei,100000000000000000000uusdc,100000000000000000000uatom  --home $CHAIN_DIR/$CHAINID_1


seid gentx val1 70000000000000000000usei --chain-id $CHAINID_1 --keyring-backend test --home $CHAIN_DIR/$CHAINID_1
seid collect-gentxs --home $CHAIN_DIR/$CHAINID_1
cat $SEID_HOME/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="usei"' >                          $SEID_HOME/config/tmp_genesis.json && mv $SEID_HOME/config/tmp_genesis.json $SEID_HOME/config/genesis.json
cat $SEID_HOME/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="usei"' >         $SEID_HOME/config/tmp_genesis.json && mv $SEID_HOME/config/tmp_genesis.json $SEID_HOME/config/genesis.json
cat $SEID_HOME/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="usei"' >                             $SEID_HOME/config/tmp_genesis.json && mv $SEID_HOME/config/tmp_genesis.json $SEID_HOME/config/genesis.json
cat $SEID_HOME/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="usei"' >                          $SEID_HOME/config/tmp_genesis.json && mv $SEID_HOME/config/tmp_genesis.json $SEID_HOME/config/genesis.json
cat $SEID_HOME/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["max_deposit_period"]="300s"' >              $SEID_HOME/config/tmp_genesis.json && mv $SEID_HOME/config/tmp_genesis.json $SEID_HOME/config/genesis.json
cat $SEID_HOME/config/genesis.json | jq '.app_state["gov"]["voting_params"]["voting_period"]="10s"' >                      $SEID_HOME/config/tmp_genesis.json && mv $SEID_HOME/config/tmp_genesis.json $SEID_HOME/config/genesis.json
cat $SEID_HOME/config/genesis.json | jq '.consensus_params["block"]["time_iota_ms"]="50"' >                               $SEID_HOME/config/tmp_genesis.json && mv $SEID_HOME/config/tmp_genesis.json $SEID_HOME/config/genesis.json
cat $SEID_HOME/config/genesis.json | jq '.app_state["distribution"]["params"]["community_tax"]="0.000000000000000000"' >  $SEID_HOME/config/tmp_genesis.json && mv $SEID_HOME/config/tmp_genesis.json $SEID_HOME/config/genesis.json

CONFIG_PATH=$CHAIN_DIR/$CHAINID_1/config/config.toml

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  sed -i 's/timeout_prevote =.*/timeout_prevote = "2000ms"/g' $CONFIG_PATH
  sed -i 's/timeout_precommit =.*/timeout_precommit = "2000ms"/g' $CONFIG_PATH
  sed -i 's/timeout_commit =.*/timeout_commit = "2000ms"/g' $CONFIG_PATH
  sed -i 's/skip_timeout_commit =.*/skip_timeout_commit = false/g' $CONFIG_PATH
elif [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' 's/timeout_prevote =.*/timeout_prevote = "2000ms"/g' $CONFIG_PATH
  sed -i '' 's/timeout_precommit =.*/timeout_precommit = "2000ms"/g' $CONFIG_PATH
  sed -i '' 's/timeout_commit =.*/timeout_commit = "2000ms"/g' $CONFIG_PATH
  sed -i '' 's/skip_timeout_commit =.*/skip_timeout_commit = false/g' $CONFIG_PATH
else
  printf "Platform not supported, please ensure that the following values are set in your config.toml:\n"
  printf "###         Consensus Configuration Options         ###\n"
  printf "\t timeout_prevote = \"2000ms\"\n"
  printf "\t timeout_precommit = \"2000ms\"\n"
  printf "\t timeout_commit = \"2000ms\"\n"
  printf "\t skip_timeout_commit = false\n"
  exit 1
fi

# start the chain with log tracing
seid start --log_level debug --log_format json --home $CHAIN_DIR/$CHAINID_1 --pruning=nothing --trace