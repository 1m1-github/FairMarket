# https://developer.algorand.org/docs/run-a-node/setup/install/#sync-node-network-using-fast-catchup
# chrome://inspect/#devices

# start goal, create wallet and account
goal node start
goal node stop
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
goal app info --app-id $FAIRMARKET_APP
goal app update --from=$CREATOR --app-id=$FAIRMARKET_APP --approval-prog $TEAL_DIR/$APPROVAL_FILE_NAME.teal --clear-prog $TEAL_DIR/$CLEAR_FILE_NAME.teal  --signer $SIGNER

# API
#####

# create bid [A]
goal app call --from $A --app-id $FX_APP --foreign-app $FX_LP_APP --foreign-asset $CURRENCY_ID --app-account $FX_LP_ACCOUNT --out $TXNS_DIR/FX.txn --fee 0
goal clerk send --from $A --to $FAIRMARKET_ACCOUNT --amount 283300 --out $TXNS_DIR/algo_send.txn --fee 0
goal app call --from $A --app-id $FAIRMARKET_APP --foreign-asset $CURRENCY_ID --app-arg "str:create_bid" --app-arg "addr:$B" --app-arg "b64:$BID_ID_B64" --box "addr:$B" --box "b64:$BID_ID_B64" --app-account $B --out $TXNS_DIR/app_call.txn --fee 6000
goal asset send --from $A --to $FAIRMARKET_ACCOUNT --amount $CURRENCY_AMOUNT --assetid $CURRENCY_ID --noteb64 $CREATE_NOTE_B64 --out $TXNS_DIR/asset_send.txn --fee 0
cat $TXNS_DIR/FX.txn $TXNS_DIR/algo_send.txn $TXNS_DIR/app_call.txn $TXNS_DIR/asset_send.txn > $TXNS_DIR/combined.txn
goal clerk group --infile $TXNS_DIR/combined.txn --outfile $TXNS_DIR/create_bid.txn
goal clerk sign --infile $TXNS_DIR/create_bid.txn --outfile $TXNS_DIR/create_bid.stxn
goal clerk rawsend --filename $TXNS_DIR/create_bid.stxn

# cancel bid [bidder]
goal app call --from $A --app-id $FAIRMARKET_APP --app-arg "str:cancel_bid" --app-arg "b64:$BID_ID_B64" --box "b64:$BID_ID_B64" --foreign-asset $CURRENCY_ID --fee 3000

# trade [seller]
goal asset optin --account $B --assetid $CURRENCY_ID --fee 0 --out $TXNS_DIR/trade_optin.txn
goal app call --from $B --app-id $FAIRMARKET_APP --app-account $A --foreign-asset $CURRENCY_ID --app-arg "str:trade" --app-arg "b64:$BID_ID" --box "b64:$BID_ID" --note "str:$DATA_ANSWER" --fee 4000 --out $TXNS_DIR/trade_app_call.txn
cat $TXNS_DIR/trade_optin.txn $TXNS_DIR/trade_app_call.txn > $TXNS_DIR/combined.txn
goal clerk group --infile $TXNS_DIR/combined.txn --outfile $TXNS_DIR/trade.txn
goal clerk sign --infile $TXNS_DIR/trade.txn --outfile $TXNS_DIR/trade.stxn
goal clerk rawsend --filename $TXNS_DIR/trade.stxn

# update params
# first time needs gas for new box
goal clerk send --from $A --to $FAIRMARKET_ACCOUNT --amount 53700 --out $TXNS_DIR/update_params_algo_send.txn --fee 0
goal app call --from $A --app-id $FAIRMARKET_APP --app-arg "str:update_params" --app-arg $CHRONY_IMPORTANCE --app-arg $HIGHROLLER_IMPORTANCE --app-arg $SUBJECTIVE_IMPORTANCE --app-arg $MIN --app-arg $DESCRIPTION --app-arg $ENCRYPTION_PUBLIC_KEY --box "addr:$A" --out $TXNS_DIR/update_params_app_call.txn --fee 2000
cat $TXNS_DIR/update_params_algo_send.txn $TXNS_DIR/update_params_app_call.txn > $TXNS_DIR/combined.txn
goal clerk group --infile $TXNS_DIR/combined.txn --outfile $TXNS_DIR/update_params.txn
goal clerk sign --infile $TXNS_DIR/update_params.txn --outfile $TXNS_DIR/update_params.stxn
goal clerk rawsend --filename $TXNS_DIR/update_params.stxn
# after first time no new box
goal app call --from $A --app-id $FAIRMARKET_APP --app-arg "str:update_params" --app-arg $CHRONY_IMPORTANCE --app-arg $HIGHROLLER_IMPORTANCE --app-arg $SUBJECTIVE_IMPORTANCE --app-arg $MIN --app-arg $DESCRIPTION --app-arg $ENCRYPTION_PUBLIC_KEY --box "addr:$A" --out $TXNS_DIR/update_params_app_call.stxn

#debug
goal clerk dryrun -t $TXNS_DIR/update_params.stxn --dryrun-dump -o $TXNS_DIR/dryrun.json
tealdbg debug $TEAL_DIR/$APPROVAL_FILE_NAME.teal -d $TXNS_DIR/dryrun.json --group-index 0 --mode application
goal app read --app-id $FAIRMARKET_APP --global
goal account info --address $FAIRMARKET_ACCOUNT --onlyShowAssetIds
goal account info --address $A --onlyShowAssetIds
goal account dump --address $A
goal account balance --address $A
goal asset info --assetid $CURRENCY_ID
goal app box list --app-id $FAIRMARKET_APP
goal app box info --app-id $FAIRMARKET_APP --name $BID_ID
goal account info --address $FAIRMARKET_ACCOUNT