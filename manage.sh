# https://developer.algorand.org/docs/run-a-node/setup/install/#sync-node-network-using-fast-catchup
# chrome://inspect/#devices

# set env vars for terminal
export ALGORAND_DATA="$HOME/algorand/testnetdata"
export WALLET=Fair
export TEALISH_DIR=./tealish
export TEAL_DIR=./tealish/build
export TXNS_DIR=./txns
export APPROVAL_FILE_NAME=state_approval_program
export CLEAR_FILE_NAME=state_clear_program
export CREATOR=5B3SUGACYLICWU3DHXYCS45NDNEFZCZM4MCKCKQA3DLGKZEOFQR74HLGEU
export APP_ID=

# start goal, create wallet and account
goal node start
goal node status
goal node end
goal wallet new $WALLET
goal account new -w $WALLET
goal clerk send -a 1000000 -f $CREATOR -t $A -w $WALLET

# create teal
tealish compile $TEALISH_DIR/$APPROVAL_FILE_NAME.tl
tealish compile $TEALISH_DIR/$CLEAR_FILE_NAME.tl

# create app
goal app create --creator $CREATOR --approval-prog $TEAL_DIR/$APPROVAL_FILE_NAME.teal --clear-prog $TEAL_DIR/$CLEAR_FILE_NAME.teal --global-byteslices 0 --global-ints 0 --local-byteslices 0 --local-ints 0
goal app info --app-id $APP_ID
goal app update --app-id=$APP_ID --from=$CREATOR --approval-prog $TEAL_DIR/$APPROVAL_FILE_NAME.teal --clear-prog $TEAL_DIR/$CLEAR_FILE_NAME.teal

# API
#####

# create bid/trade [bidder]
goal asset send --from $BIDDER --to $SELLER_FAIRMARKET_ACCOUNT --amount $AMOUNT --assetid $ASSET_ID --note "1\n" --out $TXNS_DIR/asset_send.txn
goal app call --from $BIDDER --app-id $FX_APP --foreign-app $LP_APP --foreign-asset $ASSET_ID --app-account $LP_ACCOUNT --note "2\n" --out $TXNS_DIR/FX.txn
goal app call --from $BIDDER --app-id $SELLER_FAIRMARKET_APP --app-arg "create_bid" --app-arg $PARENT_BID --app-arg $BIDDER_FAIRMARKET_APP --note "3\n" --out $TXNS_DIR/app_call.txn
goal app call --from $BIDDER --app-id $SELLER_FAIRMARKET_APP --app-arg "add_data" --note "4\n" --out $TXNS_DIR/note_extra_1.txn
cat $TXNS_DIR/asset_send.txn $TXNS_DIR/FX.txn $TXNS_DIR/app_call.txn $TXNS_DIR/note_extra_1.txn > $TXNS_DIR/combined.txn
goal clerk group --infile $TXNS_DIR/combined.txn --outfile $TXNS_DIR/create_bid.txn
goal clerk sign --infile $TXNS_DIR/create_bid.txn --outfile $TXNS_DIR/create_bid.stxn
goal clerk dryrun -t $TXNS_DIR/create_bid.stxn --dryrun-dump -o $TXNS_DIR/dryrun.json
tealdbg debug $TEAL_DIR/$APPROVAL_FILE_NAME.teal -d $TXNS_DIR/dryrun.json --group-index 2 --mode application
goal clerk rawsend --filename $TXNS_DIR/create_bid.stxn

# cancel bid [bidder]
goal app call --from $BIDDER --app-id $SELLER_FAIRMARKET_APP --app-arg "cancel_bid" --app-arg $TX_ID --out $TXNS_DIR/cancel_bid.txn
goal clerk dryrun -t $TXNS_DIR/cancel_bid.stxn --dryrun-dump -o $TXNS_DIR/dryrun.json
tealdbg debug $TEAL_DIR/$APPROVAL_FILE_NAME.teal -d $TXNS_DIR/dryrun.json --group-index 0 --mode application
goal clerk rawsend --filename $TXNS_DIR/cancel_bid.stxn

# add reputation [bidder]
export REPUTATION=1
export REPUTATION=-1
goal app call --from $BIDDER --app-id $SELLER_FAIRMARKET_APP --app-arg "add_reputation" --app-arg $REPUTATION --out $TXNS_DIR/add_reputation.txn
goal clerk dryrun -t $TXNS_DIR/add_reputation.stxn --dryrun-dump -o $TXNS_DIR/dryrun.json
tealdbg debug $TEAL_DIR/$APPROVAL_FILE_NAME.teal -d $TXNS_DIR/dryrun.json --group-index 0 --mode application
goal clerk rawsend --filename $TXNS_DIR/add_reputation.stxn

# withdraw [seller]
goal asset send --from $SELLER_FAIRMARKET_ACCOUNT --to $SELLER --amount $AMOUNT --assetid $ASSET_ID --out $TXNS_DIR/withdraw_send.txn
goal app call --from $SELLER --app-id $SELLER_FAIRMARKET_APP --app-arg "withdraw" --out $TXNS_DIR/withdraw_call.txn
cat $TXNS_DIR/withdraw_send.txn $TXNS_DIR/withdraw_call.txn > $TXNS_DIR/combined.txn
goal clerk group --infile $TXNS_DIR/combined.txn --outfile $TXNS_DIR/withdraw.txn
goal clerk sign --infile $TXNS_DIR/withdraw.txn --outfile $TXNS_DIR/withdraw.stxn
goal clerk dryrun -t $TXNS_DIR/withdraw.stxn --dryrun-dump -o $TXNS_DIR/dryrun.json
tealdbg debug $TEAL_DIR/$APPROVAL_FILE_NAME.teal -d $TXNS_DIR/dryrun.json --group-index 1 --mode application
goal clerk rawsend --filename $TXNS_DIR/withdraw.stxn
