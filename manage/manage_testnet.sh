# https://developer.algorand.org/docs/run-a-node/setup/install/#sync-node-network-using-fast-catchup
# chrome://inspect/#devices

# set env vars for terminal
export ALGORAND_DATA="$HOME/algorand/testnetdata"
export TEALISH_DIR=./Algorand
export TEAL_DIR=./Algorand/build
export TXNS_DIR=./txns
export APPROVAL_FILE_NAME=state_approval_program_testnet
export CLEAR_FILE_NAME=state_clear_program
export CREATOR=HQMMGGF3KJRPTEZV6GKGT6PNQJBZWUBIQMHG4XBVGBIV2E2V4LWOFHVEAA
export A=HQMMGGF3KJRPTEZV6GKGT6PNQJBZWUBIQMHG4XBVGBIV2E2V4LWOFHVEAA
export B=5B3SUGACYLICWU3DHXYCS45NDNEFZCZM4MCKCKQA3DLGKZEOFQR74HLGEU
export FX_APP=178969021

# start goal, create wallet and account
goal node start
goal node status
goal node end
goal wallet new $WALLET
goal account new -w $WALLET
goal clerk send --amount 1000000 --from $B --to $A
goal asset optin --account $A --assetid $ASSET_ID

# create teal
tealish compile $TEALISH_DIR/$APPROVAL_FILE_NAME.tl
tealish compile $TEALISH_DIR/$CLEAR_FILE_NAME.tl

# create app
goal app create --creator $CREATOR --approval-prog $TEAL_DIR/$APPROVAL_FILE_NAME.teal --clear-prog $TEAL_DIR/$CLEAR_FILE_NAME.teal --global-byteslices 0 --global-ints 0 --local-byteslices 0 --local-ints 0 --signer $SIGNER
export FAIRMARKET_APP=202947056
goal app info --app-id $FAIRMARKET_APP
export FAIRMARKET_ACCOUNT=7XDQJVL4XBHQSKF5FVUDMJ4U3W4UCQ5DO7JWAOCPRFZN2AEEQIXV27YE5I

# update app
tealish compile $TEALISH_DIR/$APPROVAL_FILE_NAME.tl
goal app update --from=$CREATOR --app-id=$FAIRMARKET_APP --approval-prog $TEAL_DIR/$APPROVAL_FILE_NAME.teal --clear-prog $TEAL_DIR/$CLEAR_FILE_NAME.teal

# API
#####

# create bid [A]
export CURRENCY_CREATOR=VETIGP3I6RCUVLVYNDW5UA2OJMXB5WP6L6HJ3RWO2R37GP4AVETICXC55I
export CURRENCY_ID=10458941
export CURRENCY_AMOUNT=2
export FX_LP_APP=148607000
export FX_LP_ACCOUNT=UDFWT5DW3X5RZQYXKQEMZ6MRWAEYHWYP7YUAPZKPW6WJK3JH3OZPL7PO2Y
export DATA="hello world"
# BID_ID = hash($A$B$CURRENCY_ID$CURRENCY_AMOUNT$DATA)
export BID_ID="b64:KIUIRV7FzMsZqfZ2eqQxoXqCUr6miZEtmm0jXrha+W8="
goal app call --from $A --app-id $FX_APP --foreign-app $FX_LP_APP --foreign-asset $CURRENCY_ID --app-account $FX_LP_ACCOUNT --out $TXNS_DIR/FX.txn --fee 0
goal clerk send --from $A --to $FAIRMARKET_ACCOUNT --amount 86900 --out $TXNS_DIR/algo_send.txn --fee 0
goal app call --from $A --app-id $FAIRMARKET_APP --foreign-asset $CURRENCY_ID --app-arg "str:create_bid" --app-arg "addr:$B" --app-arg $BID_ID --box $BID_ID --box "addr:$B" --note $B.$DATA --out $TXNS_DIR/app_call.txn --fee 5000
goal asset send --from $A --to $FAIRMARKET_ACCOUNT --amount $CURRENCY_AMOUNT --assetid $CURRENCY_ID --out $TXNS_DIR/asset_send.txn --fee 0
cat $TXNS_DIR/FX.txn $TXNS_DIR/algo_send.txn $TXNS_DIR/app_call.txn $TXNS_DIR/asset_send.txn > $TXNS_DIR/combined.txn
goal clerk group --infile $TXNS_DIR/combined.txn --outfile $TXNS_DIR/create_bid.txn
goal clerk sign --infile $TXNS_DIR/create_bid.txn --outfile $TXNS_DIR/create_bid.stxn
goal clerk rawsend --filename $TXNS_DIR/create_bid.stxn

goal clerk dryrun -t $TXNS_DIR/create_bid.stxn --dryrun-dump --dryrun-accounts $CURRENCY_CREATOR -o $TXNS_DIR/dryrun.json
tealdbg debug $TEAL_DIR/$APPROVAL_FILE_NAME.teal -d $TXNS_DIR/dryrun.json --group-index 2 --mode application

# costs
# opt-in: 0.001 + 0.1
# box: reserve

# cancel bid [bidder]
goal app call --from $A --app-id $FAIRMARKET_APP --app-arg "str:cancel_bid" --app-arg $BID_ID --box $BID_ID --foreign-asset $CURRENCY_ID --fee 3000

# trade [seller]
export DATA="ty"
goal asset optin --account $B --assetid $CURRENCY_ID --out $TXNS_DIR/trade_optin.txn
goal app call --from $B --app-id $FAIRMARKET_APP --app-account $A --foreign-asset $CURRENCY_ID --app-arg "str:trade" --app-arg $BID_ID --box $BID_ID --note $DATA --fee 4000 --out $TXNS_DIR/trade_app_call.txn
cat $TXNS_DIR/trade_optin.txn $TXNS_DIR/trade_app_call.txn > $TXNS_DIR/combined.txn
goal clerk group --infile $TXNS_DIR/combined.txn --outfile $TXNS_DIR/trade.txn
goal clerk sign --infile $TXNS_DIR/trade.txn --outfile $TXNS_DIR/trade.stxn
goal clerk rawsend --filename $TXNS_DIR/trade.stxn
goal clerk dryrun -t $TXNS_DIR/trade.stxn --dryrun-dump -o $TXNS_DIR/dryrun.json
tealdbg debug $TEAL_DIR/$APPROVAL_FILE_NAME.teal -d $TXNS_DIR/dryrun.json --group-index 1 --mode application

# update params
export CHRONY_IMPORTANCE="int:3"
export HIGHROLLER_IMPORTANCE="int:2"
export SUBJECTIVE_IMPORTANCE="int:1"
export MIN="int:1"
export DESCRIPTION="str:DESCRIPTIONDESCRIPTIONDESCRIPTIO"
export ENCRYPTION_PUBLIC_KEY="b64:y2Trlfq3rEvjm42egC3dXgxx5riOZkh94GwPl4dmrFE="
# first time needs gas for new box
goal clerk send --from $A --to $FAIRMARKET_ACCOUNT --amount 53700 --out $TXNS_DIR/update_params_algo_send.txn --fee 0
goal app call --from $A --app-id $FAIRMARKET_APP --app-arg "str:update_params" --app-arg $CHRONY_IMPORTANCE --app-arg $HIGHROLLER_IMPORTANCE --app-arg $SUBJECTIVE_IMPORTANCE --app-arg $MIN --app-arg $DESCRIPTION --app-arg $ENCRYPTION_PUBLIC_KEY --box "addr:$A" --out $TXNS_DIR/update_params_app_call.txn --fee 2000
cat $TXNS_DIR/update_params_algo_send.txn $TXNS_DIR/update_params_app_call.txn > $TXNS_DIR/combined.txn
goal clerk group --infile $TXNS_DIR/combined.txn --outfile $TXNS_DIR/update_params.txn
goal clerk sign --infile $TXNS_DIR/update_params.txn --outfile $TXNS_DIR/update_params.stxn
goal clerk rawsend --filename $TXNS_DIR/update_params.stxn
# after first time no new box
goal app call --from $A --app-id $FAIRMARKET_APP --app-arg "str:update_params" --app-arg $CHRONY_IMPORTANCE --app-arg $HIGHROLLER_IMPORTANCE --app-arg $SUBJECTIVE_IMPORTANCE --app-arg $MIN --app-arg $DESCRIPTION --app-arg $ENCRYPTION_PUBLIC_KEY --box "addr:$A" --out $TXNS_DIR/update_params_app_call.stxn

# tealish compile $TEALISH_DIR/$APPROVAL_FILE_NAME.tl
# goal app update --from=$CREATOR --app-id=$FAIRMARKET_APP --approval-prog $TEAL_DIR/$APPROVAL_FILE_NAME.teal --clear-prog $TEAL_DIR/$CLEAR_FILE_NAME.teal
# goal app call --from $B --app-id $FAIRMARKET_APP --app-arg "str:update_params" --app-arg $CHRONY_IMPORTANCE --app-arg $HIGHROLLER_IMPORTANCE --app-arg $SUBJECTIVE_IMPORTANCE --app-arg $MIN --app-arg $DESCRIPTION --app-arg $ENCRYPTION_PUBLIC_KEY --out $TXNS_DIR/update_params.stxn
# goal clerk dryrun -t $TXNS_DIR/update_params.stxn --dryrun-dump -o $TXNS_DIR/dryrun.json
# tealdbg debug $TEAL_DIR/$APPROVAL_FILE_NAME.teal -d $TXNS_DIR/dryrun.json --group-index 0 --mode application
# goal clerk rawsend --filename $TXNS_DIR/update_params.stxn

#debug
goal app read --app-id $FAIRMARKET_APP --global
goal account info --address $FAIRMARKET_ACCOUNT --onlyShowAssetIds
goal account info --address $A --onlyShowAssetIds
goal account dump --address $A
goal account balance --address $A
goal asset info --assetid $CURRENCY_ID
goal app box list --app-id $FAIRMARKET_APP
goal app box info --app-id $FAIRMARKET_APP --name $BID_ID

goal account info --address $FAIRMARKET_ACCOUNT

# opt-out market from asa to test new asa
# goal asset send -a 0 -f $A -t $A -c $B --assetid=10458941
# goal asset send -a 0 -f $A -t $A --assetid=10458941
goal app call --from $A --app-id $FAIRMARKET_APP --foreign-asset $CURRENCY_ID --app-arg "str:opt_out_asa" --fee 2000