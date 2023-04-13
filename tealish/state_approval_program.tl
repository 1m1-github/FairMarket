#pragma version 8

# b 5
# i
# 32+24+8+16+x+8+16
# 256
# global params
# owner [32 bytes]
# chrony/highroller/subjective importance [3xint: 3*=24 bytes] [owner can change]
# min [int: 8 bytes] [owner can change]
# min precision [2xint: 2*8=16 bytes] [owner can change]
# reputation +/- [2xint: 2*8=16 bytes]
# version [int: 8 bytes]
# description [bytes] [owner can change]
# encryption public key [256 bytes = 3 vars]

# size=32+9*8=104
struct Params:
    owner: bytes[32]
    chrony_importance: int
    highroller_importance: int
    subjective_importance: int
    min: int
    # min_precision_n = numerator
    min_precision_n: int
    # min_precision_d = denominator
    min_precision_d: int
    # reputation_p = positive
    reputation_p: int
    # reputation_n = negative
    reputation_n: int
    version: int
end

# size=2*32+5*8+1=105
struct BidWithoutNote:
    parent: bytes[32]
    owner: bytes[32]
    fairmarket: int
    currency_id: int
    currency_quantity: int
    fx_n: int
    fx_d: int
    type: byte[1]
end

const int FX_APP = 178969021

# bid list = list of txids [boxes]

# reputation list of bidd   ers [boxes]

# api
# create bid [bidder]
# cancel bid [bidder]
# trade [seller] = create bid [bidder]
# add reputation [bidder]
# withdraw [seller]

# create bid
# if 0<min, do not allow 0 lurker
# add box

# cancel bid
# input txid, bidder == txn.Sender
# remove box

# trade
# not with lurker
# add bidder to reputation list
# remove bid
# send fee to treasury in exchange for project coins for bidder and seller

# withdraw
# if amount < locked via bids



if Txn.ApplicationID == 0:
    # Handle Create App

    for i in 0:8:
        assert(len(Txn.ApplicationArgs[i]) == 8)
    end
    bytes a = Txn.Sender
    a = concat(a, Txn.ApplicationArgs[0])
    a = concat(a, Txn.ApplicationArgs[1])
    a = concat(a, Txn.ApplicationArgs[2])
    a = concat(a, Txn.ApplicationArgs[3])
    a = concat(a, Txn.ApplicationArgs[4])
    a = concat(a, Txn.ApplicationArgs[5])
    a = concat(a, Txn.ApplicationArgs[6])
    a = concat(a, Txn.ApplicationArgs[7])
    a = concat(a, Txn.ApplicationArgs[8])
    app_global_put("a", a)

    app_global_put("d", Txn.ApplicationArgs[9])

    app_global_put("e1", Txn.ApplicationArgs[10])
    app_global_put("e2", Txn.ApplicationArgs[11])
    app_global_put("e3", Txn.ApplicationArgs[12])

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
    # Handle Delete App
    # Only allow the Creator to delete the app
    assert(Txn.Sender == Global.CreatorAddress)
     # (for now)
    exit(1)
end

block main:

    int e = Global.GroupSize-1
    for i in 0:e:
        assert(Gtxn[i].RekeyTo == Global.ZeroAddress)
    end

    switch Txn.ApplicationArgs[0]:
        "update_params": update_params
        "create_bid": create_bid
        "cancel_bid": cancel_bid
        "add_reputation": add_reputation
        "withdraw": withdraw
        "add_data": add_data
    end
end

block update_params:
    exit(1)
end

block create_bid:
    # indices
    int fx_call_ix = 0
    int algo_send_ix = 1
    int app_call_ix = 2
    int asset_send_ix = 3
    # int e = Global.GroupSize-1

    check_create_bid(asset_send_ix, fx_call_ix, app_call_ix, algo_send_ix)
    
    opt_in(Gtxn[asset_send_ix].XferAsset)

    # box_content
    # parent
    assert(len(Txn.ApplicationArgs[1]) == 32)
    bytes box_content = Txn.ApplicationArgs[1]
    # owner
    box_content = concat(box_content, Txn.Sender)
    # fairmarket
    assert(len(Txn.ApplicationArgs[2]) == 8)
    box_content = concat(box_content, Txn.ApplicationArgs[2])
    # currency_id
    box_content = concat(box_content, itob(Gtxn[asset_send_ix].XferAsset))
    # currency_quantity
    box_content = concat(box_content, itob(Gtxn[asset_send_ix].AssetAmount))
    bytes fx = Gtxn[fx_call_ix].LastLog
    box_content = concat(box_content, fx)
    bytes type = calc_type(Gtxn[asset_send_ix].AssetAmount, fx)
    box_content = concat(box_content, type)
    BidWithoutNote bidWithoutNote = box_content

    int e = Global.GroupSize-1
    for i in 0:e:
        box_content = concat(box_content, Gtxn[i].Note)
    end

    bytes box_name = Txn.ApplicationArgs[3]
    assert(len(box_name) == 32)
    int box_existed = box_create(box_name, len(box_content))
    assert(box_existed == 1)
    box_replace(box_name, 0, box_content)

    exit(1)
end

block cancel_bid:
    bytes box_name = Txn.ApplicationArgs[1]
    int box_exists
    bytes box_contents
    box_exists, box_contents = box_get(box_name)
    assert(box_exists == 1)

    BidWithoutNote bid = substring(0, 105, box_contents)

    assert(Txn.Sender == bid.owner)

    inner_txn:
        TypeEnum: Axfer
        Sender: Global.CurrentApplicationAddress
        AssetReceiver: bid.owner
        AssetAmount: bid.currency_quantity
        XferAsset: bid.currency_id
        Fee: 0
    end

    # # opt-out if no balance? TODO (e.g. return subj currency reserve)
    # int currency_balance
    # currency_balance, _ = asset_holding_get(AssetBalance, 0, bid.currency_id)
    # if currency_balance == 0:
    #     inner_txn:
    #         TypeEnum: Axfer
    #         Sender: Global.CurrentApplicationAddress
    #         AssetReceiver: bid.owner
    #         AssetAmount: bid.currency_quantity
    #         XferAsset: bid.currency_id
    #         Fee: 0
    #     end
    # end

    _ = box_del(box_name)

    exit(1)
end

block add_reputation:
    exit(1)
end

block withdraw:
    exit(1)
end
block add_data:
    exit(1)
end

func abi_return(result: bytes):
    # log(concat("\x15\x1f\x7c\x75", result))
    log(result)
    return
end

func abi_encode_uint64(value: int) bytes:
    return itob(value)
end

# TODO assert input sizes, choose m appropriately
func calc_type(asset_amount: int, fx: bytes) bytes:

    if fx == "SUBJECTIVE":
        return "S"
    end

    int m = 10000

    int fx_n = extract_uint64(fx, 0)
    int fx_d = extract_uint64(fx, 8)

    Params p = app_global_get("a")
    
    int currency_quantity_after_fx = (m * (asset_amount * fx_n)) / fx_d
    int chrony_upper_bound = p.min * (m + ((m * p.min_precision_n) / p.min_precision_d))
    int chrony_lower_bound = p.min * (m - ((m * p.min_precision_n) / p.min_precision_d))

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
            Sender: Global.CurrentApplicationAddress
            AssetReceiver: Global.CurrentApplicationAddress
            AssetAmount: 0
            XferAsset: asset_id
            Fee: 0
        end
    end
    return
end

func check_create_bid(asset_send_ix: int, fx_call_ix: int, app_call_ix: int, algo_send_ix: int):
    assert(Gtxn[asset_send_ix].TypeEnum == Axfer)
    assert(Gtxn[asset_send_ix].AssetReceiver == Global.CurrentApplicationAddress)
    assert(Gtxn[fx_call_ix].TypeEnum == Appl)
    assert(Gtxn[fx_call_ix].Sender == Gtxn[asset_send_ix].Sender)
    assert(Gtxn[fx_call_ix].ApplicationID == FX_APP)
    assert(Gtxn[asset_send_ix].XferAsset == Gtxn[fx_call_ix].Assets[0])
    assert(Txn.GroupIndex == app_call_ix)
    assert(Txn.Sender == Gtxn[asset_send_ix].Sender)
    assert(Gtxn[algo_send_ix].TypeEnum == Pay)
    assert(Gtxn[algo_send_ix].Sender == Gtxn[asset_send_ix].Sender)
    assert(Gtxn[algo_send_ix].Receiver == Global.CurrentApplicationAddress)
    int e = Global.GroupSize - 1
    for i in 4:e:
        assert(Gtxn[i].TypeEnum == Appl)
    end
    return
end