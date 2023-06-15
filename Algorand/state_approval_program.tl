#pragma version 8

# A creates bid for B with currency and data attached
# A can cancel and get currency back before
# B trades to receive currency and send receipt to A
# receipt contains data

# central smart contract

# api
# create bid [A]
# cancel bid [A]
# trade [B]
# update params

# create bid
# if 0<min, do not allow 0 lurker
# add box

# cancel bid
# remove bid
# send currency back

# trade
# not with lurker
# remove bid

# structures
############

# size=4*8+2*32=96
# box with user name contains own params (updatable)
# see get_params for default
struct Params:
    chrony_importance: int
    highroller_importance: int
    subjective_importance: int
    # min in ALGO
    min: int
    description: bytes[32]
    encryption_public_key: bytes[32]
end

# size=3*32+9*8=168
struct BidWithoutData:
    time: int
    # a = A, b = B
    a: bytes[32]
    b: bytes[32]
    currency_id: int
    currency_amount: int
    fx_n: int
    fx_d: int
    bid_chrony_importance: int
    bid_highroller_importance: int
    bid_subjective_importance: int
    bid_min: int
    bid_encryption_public_key: bytes[32]
end
const int BIDWITHOUTDATASIZE = 168

 # TESTNET
const int FX_APP = 178969021
 # MAINNET
# const int FX_APP = 1118290368

 # TESTNET
const int PROJECT_COIN = 240148078
 # MAINNET
# const int PROJECT_COIN = 

# FEE_N/FEE_D = FEE is the fraction of the currency_amount kept in the contract
# currently set to 1/10
# does not compile as const
bytes fee_n = itob(1)
bytes fee_d = itob(10)

# manage code
############

if Txn.ApplicationID == 0:
    # Handle Create App
    exit(1)
end

switch Txn.OnCompletion:
    NoOp: main
    OptIn: opt_in
    CloseOut: close_out
    UpdateApplication: update_app
    DeleteApplication: delete_app
end

block opt_in:
    # Disallow Opt In
    exit(0)
end

block close_out:
    # Disallow Closing Out
    exit(0)
end

block update_app:
    # Handle Update App
    # Only allow the Creator to update the app
    assert(Txn.Sender == Global.CreatorAddress)
     # (for now)
    exit(1)
end

block delete_app:
    # Disallow Delete App
    exit(0)
end

# API
############

block main:

    # safety
    int e = Global.GroupSize
    for i in 0:e:
        assert(Gtxn[i].RekeyTo == Global.ZeroAddress)
        assert(Gtxn[i].AssetCloseTo == Global.ZeroAddress)
        assert(Gtxn[i].CloseRemainderTo == Global.ZeroAddress)
    end

    # main switch
    switch Txn.ApplicationArgs[0]:
        "create_bid": create_bid
        "cancel_bid": cancel_bid
        "trade": trade
        "update_params": update_params
    end
end

block create_bid:

    # indices
    int fx_call_ix = 0
    int algo_send_ix = 1
    int app_call_ix = 2
    int asset_send_ix = 3
    int notify_ix = 4

    check_create_bid(fx_call_ix, algo_send_ix, app_call_ix, asset_send_ix, notify_ix)
    
    opt_in(Gtxn[asset_send_ix].XferAsset)

    # box_content
    # time
    bytes time_bytes = itob(Global.LatestTimestamp)
    bytes bid = time_bytes

    # a = A, b = B
    bytes a = Txn.Sender
    bid = concat(bid, a)
    bytes b = Txn.ApplicationArgs[1]
    bid = concat(bid, b)
    
    # currency_id
    bytes currency_id_bytes = itob(Gtxn[asset_send_ix].XferAsset)
    bid = concat(bid, currency_id_bytes)
    # currency_amount
    bytes currency_amount_bytes = itob(Gtxn[asset_send_ix].AssetAmount)
    bid = concat(bid, currency_amount_bytes)
    
    # fx
    bytes fx = Gtxn[fx_call_ix].LastLog
    bid = concat(bid, fx)

    # params
    Params p = get_params(b)
    bytes chrony_importance_bytes = itob(p.chrony_importance)
    bid = concat(bid, chrony_importance_bytes)
    bytes highroller_importance_bytes = itob(p.highroller_importance)
    bid = concat(bid, highroller_importance_bytes)
    bytes subjective_importance_bytes = itob(p.subjective_importance)
    bid = concat(bid, subjective_importance_bytes)
    bytes min_bytes = itob(p.min)
    bid = concat(bid, min_bytes)

    # encryption
    bid = concat(bid, p.encryption_public_key)

    # data
    # first 32 bytes of Gtxn[asset_send_ix].Note is B
    # +1 for .
    # next 32 bytes of Gtxn[asset_send_ix].Note is BID_ID
    # +1 for .
    bytes data = extract(66, 0, Gtxn[asset_send_ix].Note)
    bid = concat(bid, data)

    # calc bid_id
    # BID_ID = hash($A$B$CURRENCY_ID$CURRENCY_AMOUNT$DATA)
    bytes bid_id_prehash
    bid_id_prehash = concat(Txn.Sender, b)
    bid_id_prehash = concat(bid_id_prehash, currency_id_bytes)
    bid_id_prehash = concat(bid_id_prehash, currency_amount_bytes)
    bid_id_prehash = concat(bid_id_prehash, data)
    bytes bid_id = sha512_256(bid_id_prehash)

    # log(Txn.Sender)
    # log(b)
    # log(currency_id_bytes)
    # log(currency_amount_bytes)
    # log(data)
    # log(itob(len(data)))
    # log(bid_id_prehash)
    # log(itob(len(bid_id_prehash)))
    # log(bid_id)
    # log(itob(len(bid_id)))

    # create box
    int box_existed = box_create(bid_id, len(bid))
    assert(box_existed == 1)
    box_replace(bid_id, 0, bid)

    reward(a)

    exit(1)
end

block cancel_bid:

    check_cancel_bid()

    bytes bid_id = Txn.ApplicationArgs[1]
    BidWithoutData bid = get_bid(bid_id)

    # only A can cancel
    assert(Txn.Sender == bid.a)

    inner_txn:
        TypeEnum: Axfer
        AssetReceiver: bid.a
        AssetAmount: bid.currency_amount
        XferAsset: bid.currency_id
        Fee: 0
    end

    # # # opt-out if no balance? TODO (e.g. return subj currency reserve)
    # # int currency_balance
    # # currency_balance, _ = asset_holding_get(AssetBalance, 0, bid.currency_id)
    # # if currency_balance == 0:
    # #     inner_txn:
    # #         TypeEnum: Axfer
    # #         Sender: Global.CurrentApplicationAddress
    # #         AssetReceiver: bid.owner
    # #         AssetAmount: bid.currency_quantity
    # #         XferAsset: bid.currency_id
    # #         Fee: 0
    # #     end
    # # end

    # box
    _ = box_del(bid_id)

    # cancel reduces min_balance
    # send unused gas to Sender
    int clear_gas_amount = clear_gas()
    if 1000 < clear_gas_amount:
        inner_txn:
            TypeEnum: Pay
            Receiver: Txn.Sender
            Amount: clear_gas_amount
            Fee: 0
        end
    end

    exit(1)
end

block trade:
    check_trade()

    bytes bid_id = Txn.ApplicationArgs[1]
    BidWithoutData bid = get_bid(bid_id)

    # only B can trade
    assert(Txn.Sender == bid.b)

    # send currency to owner
    bytes currency_amount_bytes = itob(bid.currency_amount)
    bytes fee_bytes = (currency_amount_bytes b* fee_n) b/ fee_d
    bytes currency_amount_for_b_bytes = currency_amount_bytes b- fee_bytes
    int currency_amount_for_b = btoi(currency_amount_for_b_bytes)
    inner_txn:
        TypeEnum: Axfer
        AssetReceiver: bid.b
        AssetAmount: currency_amount_for_b
        XferAsset: bid.currency_id
        Note: bid.a
        Fee: 0
    end

    # box
    _ = box_del(bid_id)

    # trade reduces min_balance
    # send reply and unused gas to A
    int clear_gas_amount = clear_gas()
    inner_txn:
        TypeEnum: Pay
        Receiver: bid.a
        Amount: clear_gas_amount
        Fee: 0
    end

    reward(bid.b)

    exit(1)
end

block update_params:

    check_update_params()

    bytes params_id = Txn.Sender

    # extract params
    bytes chrony_importance_bytes = Txn.ApplicationArgs[1]
    bytes highroller_importance_bytes = Txn.ApplicationArgs[2]
    bytes params = concat(chrony_importance_bytes, highroller_importance_bytes)
    bytes subjective_importance_bytes = Txn.ApplicationArgs[3]
    params = concat(params, subjective_importance_bytes)
    bytes min_bytes = Txn.ApplicationArgs[4]
    params = concat(params, min_bytes)
    bytes description = Txn.ApplicationArgs[5]
    params = concat(params, description)
    bytes encryption_public_key = Txn.ApplicationArgs[6]
    params = concat(params, encryption_public_key)

    # safety
    assert(len(chrony_importance_bytes) == 8)
    assert(len(highroller_importance_bytes) == 8)
    assert(len(subjective_importance_bytes) == 8)
    assert(len(min_bytes) == 8)
    assert(len(description) == 32)
    assert(len(encryption_public_key) == 32)

    # box
    _ = box_create(params_id, len(params))
    box_replace(params_id, 0, params)

    exit(1)
end

func reward(rewardee: bytes):
    int is_opted_in
    is_opted_in, _ = asset_holding_get(AssetBalance, rewardee, PROJECT_COIN)
    if is_opted_in == 1:
        inner_txn:
            TypeEnum: Axfer
            AssetReceiver: rewardee
            AssetAmount: 1
            XferAsset: PROJECT_COIN
            Fee: 0
        end
    end
    return
end

func clear_gas() int:
    int y
    int own_account_balance
    y, own_account_balance = acct_params_get(AcctBalance, Global.CurrentApplicationAddress)
    # log(itob(own_account_balance))
    int own_account_min_balance
    y, own_account_min_balance = acct_params_get(AcctMinBalance, Global.CurrentApplicationAddress)
    # log(itob(own_account_min_balance))

    return own_account_balance - own_account_min_balance
end

func get_bid(bid_id: bytes) bytes:
    int bid_exists
    bytes bid_contents
    bid_exists, bid_contents = box_get(bid_id)
    assert(bid_exists == 1)
    return extract3(bid_contents, 0, BIDWITHOUTDATASIZE)
end

func opt_in(asset_id: int):
    int is_opted_in
    is_opted_in, _ = asset_holding_get(AssetBalance, Global.CurrentApplicationAddress, asset_id)
    if is_opted_in == 0:
        inner_txn:
            TypeEnum: Axfer
            AssetReceiver: Global.CurrentApplicationAddress
            AssetAmount: 0
            XferAsset: asset_id
            Fee: 0
        end
    end
    return
end

func check_create_bid(fx_call_ix: int, algo_send_ix: int, app_call_ix: int, asset_send_ix: int, notify_ix: int):
    assert(Gtxn[fx_call_ix].TypeEnum == Appl)
    assert(Gtxn[algo_send_ix].TypeEnum == Pay)
    # assert(Gtxn[app_call_ix].TypeEnum == Appl) # NOT NEEDED, as we are in this Appl
    assert(Gtxn[asset_send_ix].TypeEnum == Axfer)
    assert(Gtxn[notify_ix].TypeEnum == Pay)

    assert(Gtxn[fx_call_ix].Sender == Gtxn[asset_send_ix].Sender)
    assert(Txn.Sender == Gtxn[asset_send_ix].Sender)
    assert(Gtxn[algo_send_ix].Sender == Gtxn[asset_send_ix].Sender)
    assert(Gtxn[notify_ix].Sender == Gtxn[asset_send_ix].Sender)

    assert(Gtxn[asset_send_ix].AssetReceiver == Global.CurrentApplicationAddress)
    assert(Gtxn[algo_send_ix].Receiver == Global.CurrentApplicationAddress)
    assert(Gtxn[notify_ix].Receiver == Txn.ApplicationArgs[1])
    
    assert(Gtxn[fx_call_ix].ApplicationID == FX_APP)
    assert(Gtxn[asset_send_ix].XferAsset == Gtxn[fx_call_ix].Assets[0])
    assert(Gtxn[notify_ix].Amount == 0)
    assert(Gtxn[notify_ix].Note == "you have mail ~ check your FairInbox.io")
    assert(Txn.GroupIndex == app_call_ix)

    # simpler for now
    assert(Global.GroupSize == 5)
    # int e = Global.GroupSize
    # for i in 4:e:
    #     assert(Gtxn[i].TypeEnum == Appl)
    # end
    
    return
end

func check_cancel_bid():
    assert(Global.GroupSize == 1)
    return
end

func check_trade():
    if Global.GroupSize == 1:
        return
    elif Global.GroupSize == 2:

        assert(Gtxn[0].TypeEnum == Axfer)
        assert(Gtxn[0].AssetAmount == 0)

        assert(Gtxn[0].AssetReceiver == Txn.Sender)
        assert(Txn.GroupIndex == 1)

        assert(Gtxn[0].XferAsset == Txn.Assets[0])

    else:
        exit(0)
    end

    return
end

func check_update_params():
    if Global.GroupSize == 1:
        return
    elif Global.GroupSize == 2:

        assert(Gtxn[0].TypeEnum == Pay)
        # assert(Gtxn[0].Amount == 53700)
        assert(Gtxn[0].Sender == Txn.Sender)
        assert(Gtxn[0].Receiver == Global.CurrentApplicationAddress)
        
        assert(Txn.GroupIndex == 1)

    else:
        exit(0)
    end
    
    return
end

func get_params(b: bytes) bytes:
    # from box if exists
    bytes p
    # int p_exists
    # p_exists, p = box_get(b)
    # if p_exists == 1:
    #     return p
    # end

    # default params

    # importances
    p = concat(itob(1), itob(1))
    p = concat(p, itob(1))
    # min
    p = concat(p, itob(0))
    # description
    p = concat(p, "00000000000000000000000000000000")
    # encryption_public_key
    p = concat(p, "00000000000000000000000000000000")
    
    return p
end