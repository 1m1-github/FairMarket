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
export BIDDER=HQMMGGF3KJRPTEZV6GKGT6PNQJBZWUBIQMHG4XBVGBIV2E2V4LWOFHVEAA
export SELLER=5B3SUGACYLICWU3DHXYCS45NDNEFZCZM4MCKCKQA3DLGKZEOFQR74HLGEU
export FX_APP=178969021

# start goal, create wallet and account
goal node start
goal node status
goal node end
goal wallet new $WALLET
goal account new -w $WALLET
goal clerk send --amount 1000000 --from $SELLER --to $BIDDER
goal asset optin --account $BIDDER --assetid $ASSET_ID

# create teal
tealish compile $TEALISH_DIR/$APPROVAL_FILE_NAME.tl
tealish compile $TEALISH_DIR/$CLEAR_FILE_NAME.tl

# create app
export CHRONY_IMPORTANCE="int:1"
export HIGHROLLER_IMPORTANCE="int:1"
export SUBJECTIVE_IMPORTANCE="int:1"
export MIN="int:1"
export MIN_PRECISION_N="int:1"
export MIN_PRECISION_D="int:10"
export VERSION="int:1"
export REPUTATION_P="int:0"
export REPUTATION_N="int:0"
export DESCRIPTION="str:DESCRIPTION"
export ENCRYPTION_1="str:abcd"
export ENCRYPTION_2="str:abcd"
export ENCRYPTION_3="str:abcd"
goal app create --creator $SELLER --approval-prog $TEAL_DIR/$APPROVAL_FILE_NAME.teal --clear-prog $TEAL_DIR/$CLEAR_FILE_NAME.teal --global-byteslices 5 --global-ints 0 --local-byteslices 0 --local-ints 0 --app-arg $CHRONY_IMPORTANCE --app-arg $HIGHROLLER_IMPORTANCE --app-arg $SUBJECTIVE_IMPORTANCE --app-arg $MIN --app-arg $MIN_PRECISION_N --app-arg $MIN_PRECISION_D --app-arg $REPUTATION_P --app-arg $REPUTATION_N --app-arg $VERSION --app-arg $DESCRIPTION --app-arg $ENCRYPTION_1 --app-arg $ENCRYPTION_2 --app-arg $ENCRYPTION_3
export SELLER_FAIRMARKET_APP=187929070
goal app info --app-id $SELLER_FAIRMARKET_APP
export SELLER_FAIRMARKET_ACCOUNT=JBWD32XGDJOD4F2I6PGE3ATSMR5UNF4RC4U6P6BUI4FP74GNLJTZROBW5I
goal app update --from=$SELLER --app-id=$SELLER_FAIRMARKET_APP --approval-prog $TEAL_DIR/$APPROVAL_FILE_NAME.teal --clear-prog $TEAL_DIR/$CLEAR_FILE_NAME.teal

# API
#####

# update_params [seller]


# create bid/trade [bidder]
export AMOUNT=1
export ASSET_ID=10458941
export LP_APP=148607000
export LP_ACCOUNT=UDFWT5DW3X5RZQYXKQEMZ6MRWAEYHWYP7YUAPZKPW6WJK3JH3OZPL7PO2Y
export PARENT_BID="str:27ae41e4649b934ca495991b7852b855"
export BIDDER_FAIRMARKET_APP="int:0"
export BID_ID="str:7c34bfe6e537accbe6d4827144546f3c"
export NOTE="hellohellohellohellohello"
export BLOCK=29115361
# BID_ID = hash($BIDDER$NOTE$BLOCK)
tealish compile $TEALISH_DIR/$APPROVAL_FILE_NAME.tl
goal app update --from=$SELLER --app-id=$SELLER_FAIRMARKET_APP --approval-prog $TEAL_DIR/$APPROVAL_FILE_NAME.teal --clear-prog $TEAL_DIR/$CLEAR_FILE_NAME.teal
goal app call --from $BIDDER --app-id $FX_APP --foreign-app $LP_APP --foreign-asset $ASSET_ID --app-account $LP_ACCOUNT --note $NOTE --out $TXNS_DIR/FX.txn
goal clerk send --from $BIDDER --to $SELLER_FAIRMARKET_ACCOUNT --amount 239700 --note $NOTE --out $TXNS_DIR/algo_send.txn
goal app call --from $BIDDER --app-id $SELLER_FAIRMARKET_APP --foreign-asset $ASSET_ID --app-arg "str:create_bid" --app-arg $PARENT_BID --app-arg $BIDDER_FAIRMARKET_APP --app-arg $BID_ID --box $BID_ID --note $NOTE --fee 1000 --out $TXNS_DIR/app_call.txn
goal asset send --from $BIDDER --to $SELLER_FAIRMARKET_ACCOUNT --amount $AMOUNT --assetid $ASSET_ID --note $NOTE --out $TXNS_DIR/asset_send.txn
goal app call --from $BIDDER --app-id $SELLER_FAIRMARKET_APP --app-arg "str:add_data" --note $NOTE --out $TXNS_DIR/note_extra_1.txn
cat $TXNS_DIR/FX.txn $TXNS_DIR/algo_send.txn $TXNS_DIR/app_call.txn $TXNS_DIR/asset_send.txn $TXNS_DIR/note_extra_1.txn > $TXNS_DIR/combined.txn
goal clerk group --infile $TXNS_DIR/combined.txn --outfile $TXNS_DIR/create_bid.txn
goal clerk sign --infile $TXNS_DIR/create_bid.txn --outfile $TXNS_DIR/create_bid.stxn
goal clerk rawsend --filename $TXNS_DIR/create_bid.stxn
goal clerk dryrun -t $TXNS_DIR/create_bid.stxn --dryrun-dump -o $TXNS_DIR/dryrun.json
tealdbg debug $TEAL_DIR/$APPROVAL_FILE_NAME.teal -d $TXNS_DIR/dryrun.json --group-index 2 --mode application

# cancel bid [bidder]
export BID_ID="str:a"

tealish compile $TEALISH_DIR/$APPROVAL_FILE_NAME.tl
goal app update --from=$SELLER --app-id=$SELLER_FAIRMARKET_APP --approval-prog $TEAL_DIR/$APPROVAL_FILE_NAME.teal --clear-prog $TEAL_DIR/$CLEAR_FILE_NAME.teal

goal app call --from $BIDDER --app-id $SELLER_FAIRMARKET_APP --app-arg "str:cancel_bid" --app-arg $BID_ID --box $BID_ID --foreign-asset $ASSET_ID --out $TXNS_DIR/cancel_bid.txn --fee 1000
goal app call --from $BIDDER --app-id $SELLER_FAIRMARKET_APP --app-arg "str:add_data" --out $TXNS_DIR/cancel_bid_add_budget_1.txn
goal app call --from $BIDDER --app-id $SELLER_FAIRMARKET_APP --app-arg "str:add_data" --out $TXNS_DIR/cancel_bid_add_budget_2.txn
cat $TXNS_DIR/cancel_bid.txn $TXNS_DIR/cancel_bid_add_budget_1.txn $TXNS_DIR/cancel_bid_add_budget_2.txn > $TXNS_DIR/combined.txn
goal clerk group --infile $TXNS_DIR/combined.txn --outfile $TXNS_DIR/cancel_bid.txn
goal clerk sign --infile $TXNS_DIR/cancel_bid.txn --outfile $TXNS_DIR/cancel_bid.stxn
goal clerk rawsend --filename $TXNS_DIR/cancel_bid.stxn

goal app read --app-id $SELLER_FAIRMARKET_APP --global

goal clerk dryrun -t $TXNS_DIR/cancel_bid.stxn --dryrun-dump -o $TXNS_DIR/dryrun.json
tealdbg debug $TEAL_DIR/$APPROVAL_FILE_NAME.teal -d $TXNS_DIR/dryrun.json --group-index 0 --mode application
goal clerk rawsend --filename $TXNS_DIR/cancel_bid.stxn

# add reputation [bidder]
export REPUTATION=1
export REPUTATION=-1
goal app call --from $BIDDER --app-id $SELLER_FAIRMARKET_APP --app-arg "str:add_reputation" --app-arg $REPUTATION --out $TXNS_DIR/add_reputation.txn
goal clerk dryrun -t $TXNS_DIR/add_reputation.stxn --dryrun-dump -o $TXNS_DIR/dryrun.json
tealdbg debug $TEAL_DIR/$APPROVAL_FILE_NAME.teal -d $TXNS_DIR/dryrun.json --group-index 0 --mode application
goal clerk rawsend --filename $TXNS_DIR/add_reputation.stxn

# withdraw [seller]
goal asset send --from $SELLER_FAIRMARKET_ACCOUNT --to $SELLER --amount $AMOUNT --assetid $ASSET_ID --out $TXNS_DIR/withdraw_send.txn
goal app call --from $SELLER --app-id $SELLER_FAIRMARKET_APP --app-arg "str:withdraw" --out $TXNS_DIR/withdraw_call.txn
cat $TXNS_DIR/withdraw_send.txn $TXNS_DIR/withdraw_call.txn > $TXNS_DIR/combined.txn
goal clerk group --infile $TXNS_DIR/combined.txn --outfile $TXNS_DIR/withdraw.txn
goal clerk sign --infile $TXNS_DIR/withdraw.txn --outfile $TXNS_DIR/withdraw.stxn
goal clerk dryrun -t $TXNS_DIR/withdraw.stxn --dryrun-dump -o $TXNS_DIR/dryrun.json
tealdbg debug $TEAL_DIR/$APPROVAL_FILE_NAME.teal -d $TXNS_DIR/dryrun.json --group-index 1 --mode application
goal clerk rawsend --filename $TXNS_DIR/withdraw.stxn

#debug
goal app read --app-id $SELLER_FAIRMARKET_APP --global
goal account info --address $SELLER_FAIRMARKET_ACCOUNT --onlyShowAssetIds
goal account info --address $BIDDER --onlyShowAssetIds
goal account dump --address $BIDDER
goal account balance --address $BIDDER
goal asset info --assetid $ASSET_ID
goal app box list --app-id $SELLER_FAIRMARKET_APP
goal app box info --app-id $SELLER_FAIRMARKET_APP --name "str:a"