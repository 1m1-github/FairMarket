#pragma version 8

# A creates bid for B with currency and data attached
# A can cancel and get currency back before
# B trades to receive currency and send receipt to A
# receipt contains data

# global
# version:int
# min_precision_n: int
# min_precision_d: int

# central smart contract
# default params
# box with user name contains own params (updatable)
# box with hash(ABNoteCurrency) is bid

# size=4*8+2*32=96
struct Params:
    chrony_importance: int
    highroller_importance: int
    subjective_importance: int
    # min in ALGO
    min: int
    description: bytes[32]
    encryption: bytes[32]
end

# size=2*32+5*8+1=105
struct BidWithoutNote:
    # a = A, b = B
    a: bytes[32]
    b: bytes[32]
    currency_id: int
    currency_amount: int
    fx_n: int
    fx_d: int
    type: byte[1]
    time: int
end
const int BIDWITHOUTNOTESIZE = 97

const int FX_APP = 178969021

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

if Txn.ApplicationID == 0:
    # Handle Create App

    # version
    app_global_put("v", 1)

    # min_precision_n
    app_global_put("mn", 1)

    # min_precision_d
    app_global_put("md", 10)

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

block main:

    # safety
    int e = Global.GroupSize
    for i in 0:e:
        assert(Gtxn[i].RekeyTo == Global.ZeroAddress)
    end

    # main switch
    switch Txn.ApplicationArgs[0]:
        "create_bid": create_bid
        "cancel_bid": cancel_bid
        "trade": trade
        "update_params": update_params
        "add_data": add_data
    end
end

block create_bid:
    # indices
    int fx_call_ix = 0
    int algo_send_ix = 1
    int app_call_ix = 2
    int asset_send_ix = 3

    # check_create_bid(asset_send_ix, fx_call_ix, app_call_ix, algo_send_ix)
    
    opt_in(Gtxn[asset_send_ix].XferAsset)

    # box_content
    # A, b = B
    bytes b = Txn.ApplicationArgs[1]
    bytes bid = concat(Txn.Sender, b)
    # currency_id
    bytes currency_id_bytes = itob(Gtxn[asset_send_ix].XferAsset)
    bid = concat(bid, currency_id_bytes)
    # currency_amount
    bytes currency_amount_bytes = itob(Gtxn[asset_send_ix].AssetAmount)
    bid = concat(bid, currency_amount_bytes)
    # fx
    bytes fx = Gtxn[fx_call_ix].LastLog
    bid = concat(bid, fx)
    # type
    bytes type = calc_type(b, Gtxn[asset_send_ix].AssetAmount, fx)
    bid = concat(bid, type)

    # time
    bytes time_bytes = itob(Global.LatestTimestamp)
    bid = concat(bid, time_bytes)

    # note
    int s = Txn.GroupIndex + 1
    int e = Global.GroupSize
    # first 58 bytes of Txn.Note is B as string
    bytes note = extract(59, 0, Txn.Note)
    for i in s:e:
        if Gtxn[i].TypeEnum == Appl:
            if Gtxn[i].ApplicationArgs[0] == "add_data":
                note = concat(note, Gtxn[i].Note)
            end
        end
    end
    bid = concat(bid, note)

    # calc bid_id
    # BID_ID = hash($A$B$CURRENCY_ID$CURRENCY_AMOUNT$NOTE)
    bytes bid_id_prehash
    bid_id_prehash = concat(Txn.Sender, b)
    bid_id_prehash = concat(bid_id_prehash, currency_id_bytes)
    bid_id_prehash = concat(bid_id_prehash, currency_amount_bytes)
    bid_id_prehash = concat(bid_id_prehash, note)
    bytes bid_id = sha512_256(bid_id_prehash)

    # log(Txn.Sender)
    # log(b)
    # log(currency_id_bytes)
    # log(currency_amount_bytes)
    # log(note)
    # log(bid_id_prehash)
    # log(bid_id)

    # create box
    int box_existed = box_create(bid_id, len(bid))
    assert(box_existed == 1)
    box_replace(bid_id, 0, bid)

    exit(1)
end

block cancel_bid:
    bytes bid_id = Txn.ApplicationArgs[1]
    BidWithoutNote bid = get_bid(bid_id)

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

    _ = box_del(bid_id)

    exit(1)
end

block trade:
    bytes bid_id = Txn.ApplicationArgs[1]
    BidWithoutNote bid = get_bid(bid_id)

    # only B can trade
    assert(Txn.Sender == bid.b)

    # send currency to owner
    int currency_amount_for_b = bid.currency_amount
    inner_txn:
        TypeEnum: Axfer
        AssetReceiver: bid.b
        AssetAmount: currency_amount_for_b
        XferAsset: bid.currency_id
        Fee: 0
    end

    # note
    int s = Txn.GroupIndex + 1
    int e = Global.GroupSize
    bytes note = Txn.Note
    for i in s:e:
        if Gtxn[i].ApplicationArgs[0] == "add_data":
            note = concat(note, Gtxn[i].Note)
        end
    end

    # TODO need multiple if note large
    inner_txn:
        TypeEnum: Pay
        Receiver: bid.a
        Amount: 0
        Note: note
        Fee: 0
    end

    _ = box_del(bid_id)

    exit(1)
end

block update_params:

    bytes params_id = Txn.Sender

    bytes chrony_importance_bytes = Txn.ApplicationArgs[1]
    bytes highroller_importance_bytes = Txn.ApplicationArgs[2]
    bytes params = concat(chrony_importance_bytes, highroller_importance_bytes)
    bytes subjective_importance_bytes = Txn.ApplicationArgs[3]
    params = concat(params, subjective_importance_bytes)
    bytes min_bytes = Txn.ApplicationArgs[4]
    params = concat(params, min_bytes)
    bytes description = Txn.ApplicationArgs[5]
    params = concat(params, description)
    bytes encryption = Txn.ApplicationArgs[6]
    params = concat(params, encryption)

    assert(len(chrony_importance_bytes) == 8)
    assert(len(highroller_importance_bytes) == 8)
    assert(len(subjective_importance_bytes) == 8)
    assert(len(min_bytes) == 8)
    assert(len(description) == 32)
    assert(len(encryption) == 32)

    _ = box_create(params_id, len(params))
    box_replace(params_id, 0, params)

    exit(1)
end

block add_data:
    exit(1)
end

func get_bid(bid_id: bytes) bytes:
    int bid_exists
    bytes bid_contents
    bid_exists, bid_contents = box_get(bid_id)
    assert(bid_exists == 1)
    return extract3(bid_contents, 0, BIDWITHOUTNOTESIZE)
end

# TODO assert input sizes, choose m appropriately
func calc_type(b: bytes, asset_amount: int, fx: bytes) bytes:
    int fx_d = extract_uint64(fx, 8)
    if fx_d == 0:
        return "S"
    end
    int fx_n = extract_uint64(fx, 0)

    int m = 10000

    Params p = get_params(b)

    int min_precision_n = app_global_get("mn")
    int min_precision_d = app_global_get("md")
    
    int currency_quantity_after_fx = (m * (asset_amount * fx_n)) / fx_d
    int chrony_upper_bound = p.min * (m + ((m * min_precision_n) / min_precision_d))
    int chrony_lower_bound = p.min * (m - ((m * min_precision_n) / min_precision_d))

    if currency_quantity_after_fx == 0:
        if chrony_lower_bound == 0:
            return "L"
        else:
            # 0 lurker with 0<min is a spammer
            exit(0)
        end
    elif currency_quantity_after_fx < chrony_lower_bound:
        return "L"
    elif chrony_upper_bound < currency_quantity_after_fx:
        return "H"
    else:
        return "C"
    end

    # should never reach here
    exit(0)
    return "X"
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

# func check_create_bid(asset_send_ix: int, fx_call_ix: int, app_call_ix: int, algo_send_ix: int):
#     assert(Gtxn[asset_send_ix].TypeEnum == Axfer)
#     assert(Gtxn[asset_send_ix].AssetReceiver == Global.CurrentApplicationAddress)
#     assert(Gtxn[fx_call_ix].TypeEnum == Appl)
#     assert(Gtxn[fx_call_ix].Sender == Gtxn[asset_send_ix].Sender)
#     assert(Gtxn[fx_call_ix].ApplicationID == FX_APP)
#     assert(Gtxn[asset_send_ix].XferAsset == Gtxn[fx_call_ix].Assets[0])
#     assert(Txn.GroupIndex == app_call_ix)
#     assert(Txn.Sender == Gtxn[asset_send_ix].Sender)
#     assert(Gtxn[algo_send_ix].TypeEnum == Pay)
#     assert(Gtxn[algo_send_ix].Sender == Gtxn[asset_send_ix].Sender)
#     assert(Gtxn[algo_send_ix].Receiver == Global.CurrentApplicationAddress)
#     int e = Global.GroupSize
#     for i in 4:e:
#         assert(Gtxn[i].TypeEnum == Appl)
#     end
#     return
# end

func get_params(b: bytes) bytes:
    bytes p
    int p_exists
    p_exists, p = box_get(b)
    if p_exists == 1:
        return p
    end

    # default params

    # importances
    p = concat(itob(1), itob(1))
    p = concat(p, itob(1))
    # min
    p = concat(p, itob(1))
    # description
    p = concat(p, "00000000000000000000000000000000")
    # encryption
    p = concat(p, "00000000000000000000000000000000")
    
    return p
end