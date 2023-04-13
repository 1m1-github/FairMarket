goal app create --creator $SELLER --approval-prog $TEAL_DIR/fx_test.teal --clear-prog $TEAL_DIR/$CLEAR_FILE_NAME.teal --global-byteslices 1 --global-ints 0 --local-byteslices 0 --local-ints 0
export FX_TEST_APP=188596565

tealish compile $TEALISH_DIR/fx_test.tl
goal app update --from=$SELLER --app-id=$FX_TEST_APP --approval-prog $TEAL_DIR/fx_test.teal --clear-prog $TEAL_DIR/$CLEAR_FILE_NAME.teal
goal app call --from $SELLER --app-id $FX_TEST_APP
goal app read --app-id $FX_TEST_APP --global

goal app call --from $SELLER --app-id $FX_TEST_APP --out $TXNS_DIR/fx_test.stxn
goal clerk dryrun -t $TXNS_DIR/fx_test.stxn --dryrun-dump -o $TXNS_DIR/dryrun.json
tealdbg debug $TEAL_DIR/fx_test.teal -d $TXNS_DIR/dryrun.json --group-index 0 --mode application