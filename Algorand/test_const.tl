#pragma version 8


bytes a = "0000000000000001"
bytes b = itob(2)

bytes cc = a b+ b

int c = btoi(cc)

exit(1)

# tealish compile $TEALISH_DIR/test_const.tl
# goal app create --creator $CREATOR --approval-prog $TEAL_DIR/test_const.teal --clear-prog $TEAL_DIR/$CLEAR_FILE_NAME.teal --global-byteslices 0 --global-ints 0 --local-byteslices 0 --local-ints 0
# goal app update --from=$CREATOR --app-id 202970299 --approval-prog $TEAL_DIR/test_const.teal --clear-prog $TEAL_DIR/$CLEAR_FILE_NAME.teal
# goal app call --from $A --app-id 202970299 --out $TXNS_DIR/test_const.txn
# goal clerk dryrun -t $TXNS_DIR/test_const.txn --dryrun-dump -o $TXNS_DIR/dryrun.json
# tealdbg debug $TEAL_DIR/test_const.teal -d $TXNS_DIR/dryrun.json --group-index 0 --mode application
