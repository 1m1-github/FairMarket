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

# box is a bid: (each box element is prefixed with its length)
# txid [bytes] [key]
# parent bid [bytes]
# bidder address [bytes]
# fairmarket address [bytes]
# currency (id, quantity)
# fx (bytes xor 2 ints)
# type (chrony/highroller/subjective/lurker)
# data (bytes)

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

    assert(Txn.RekeyTo == Global.ZeroAddress)

    switch Txn.ApplicationArgs[0]:
        "update_params": update_params
        "create_bid": create_bid
        "cancel_bid": cancel_bid
        "add_reputation": add_reputation
        "withdraw": withdraw
        "add_data": add_data
    end

    # block add:
    #     # Add 2 integers
    #     int x = btoi(Txn.ApplicationArgs[1])
    #     int y = btoi(Txn.ApplicationArgs[2])
    #     int result = x + y
    #     abi_return(abi_encode_uint64(result))
    #     exit(1)
    # end

    # block mulw:
    #     # Multiply 2 integers, returing a uint128
    #     bytes x = Txn.ApplicationArgs[1]
    #     bytes y = Txn.ApplicationArgs[2]
    #     bytes result = x b* y
    #     abi_return(abi_encode_uint128(result))
    #     exit(1)
    # end


    # block hello:
    #     # Return a greeting
    #     bytes name = abi_decode_string(Txn.ApplicationArgs[1])
    #     bytes result = concat("Hello ", name)
    #     abi_return(abi_encode_string(result))
    #     exit(1)
    # end

    # block send:
    #     # Send some Algo to the given address
    #     bytes address = Txn.ApplicationArgs[1]
    #     inner_txn:
    #         TypeEnum: Pay
    #         Receiver: address
    #         Amount: 10000000
    #         Fee: 0
    #     end
    #     exit(1)
    # end

    # block store_data:
    #     # Store some fixed size data in a box with the specified key
    #     bytes key = Txn.ApplicationArgs[1]
    #     bytes data = Txn.ApplicationArgs[2]
    #     box_put(key, data)
    #     exit(1)
    # end

    # block store_tuple:
    #     # Store some structured data in a box with the specified key
    #     bytes key = Txn.ApplicationArgs[1]
    #     # Item data = Txn.ApplicationArgs[2]
    #     # make some assertion about the data for the fun of it
    #     # assert(data.owner == Txn.Sender)
    #     # box_put(key, data)
    #     exit(1)
    # end

    # block balance:
    #     # Return balance of the specified account
    #     int result = balance(Txn.Accounts[btoi(Txn.ApplicationArgs[1])])
    #     abi_return(abi_encode_uint64(result))
    #     exit(1)
    # end
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
    int e = Global.GroupSize-1

    # check
    const int FX_APP = 178969021
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
    for i in 4:e:
        assert(Gtxn[i].TypeEnum == Appl)
    end

    # opt-in
    int asset_id = Gtxn[asset_send_ix].XferAsset
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

    # box_content
    bytes box_content = ""
    # bytes parent_bid = Txn.ApplicationArgs[1]
    box_content = concat(box_content, Txn.ApplicationArgs[1])
    box_content = concat(box_content, ".")
    # bytes bidder = Txn.Sender
    box_content = concat(box_content, Txn.Sender)
    box_content = concat(box_content, ".")
    # bytes bidder_fairmarket_address = Txn.ApplicationArgs[2]
    box_content = concat(box_content, Txn.ApplicationArgs[2])
    box_content = concat(box_content, ".")
    # bytes currency_id = itob(Gtxn[asset_send_ix].XferAsset)
    box_content = concat(box_content, itob(Gtxn[asset_send_ix].XferAsset))
    box_content = concat(box_content, ".")
    # bytes currency_quantity = itob(Gtxn[asset_send_ix].AssetAmount)
    box_content = concat(box_content, itob(Gtxn[asset_send_ix].AssetAmount))
    box_content = concat(box_content, ".")
    bytes fx = Gtxn[fx_call_ix].LastLog
    box_content = concat(box_content, fx)
    box_content = concat(box_content, ".")

    bytes type = calc_type(Gtxn[asset_send_ix].AssetAmount, fx)
    box_content = concat(box_content, type)
    box_content = concat(box_content, ".")

    # int e = Global.GroupSize-1
    for i in 0:e:
        box_content = concat(box_content, Gtxn[i].Note)
    end

    int box_existed = box_create(Txn.ApplicationArgs[3], len(box_content))
    assert(box_existed == 1)
    box_replace(Txn.ApplicationArgs[3], 0, box_content)

    exit(1)

end

block cancel_bid:

    bytes box_name = Txn.ApplicationArgs[1]
    int box_exists
    bytes box_contents
    box_exists, box_contents = box_get(box_name)
    assert(box_exists == 1)

    int e
    # parent_bid
    _, e = get_next_token(box_contents, 0)
    # app_global_put("e1", itob(e))
    # log("parent_bid")
    # log(itob(e))

    # bidder
    bytes bidder
    bidder, e = get_next_token(box_contents, e+1)
    # app_global_put("d", bidder)
    # app_global_put("e2", itob(e))
    # log("bidder")
    # log(bidder)
    # log("e")
    # log(itob(e))
    # log("Txn.Sender")
    # log(Txn.Sender)
    # if Txn.Sender == bidder:
    #     log("Txn.Sender == bidder")
    # else:
    #     log("Txn.Sender != bidder")
    # end

    assert(Txn.Sender == bidder)

    # bidder_fairmarket_address
    _, e = get_next_token(box_contents, e+1)

    # currency_id
    bytes currency_id_bytes
    currency_id_bytes, e = get_next_token(box_contents, e+1)
    int currency_id = btoi(currency_id_bytes)
    log("currency_id_bytes")
    log(currency_id_bytes)
    # exit(1)

    # currency_quantity
    bytes currency_quantity_bytes
    currency_quantity_bytes, e = get_next_token(box_contents, e+1)
    int currency_quantity = btoi(currency_quantity_bytes)
    log("currency_quantity_bytes")
    log(currency_quantity_bytes)
    # exit(1)

    # check
    # assert(Txn.Sender == bidder)

    inner_txn:
        TypeEnum: Axfer
        Sender: Global.CurrentApplicationAddress
        AssetReceiver: bidder
        AssetAmount: currency_quantity
        XferAsset: currency_id
        Fee: 0
    end

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

func get_next_token(content: bytes, s: int) bytes, int:
    log("get_next_token")
    int e = len(content) - 1
    # log("s")
    # log(itob(s))
    # log("e")
    # log(itob(e))
    for i in s:e:
        bytes c = substring3(content, i, i+1)
        # log("i")
        # log(itob(i))
        # log("c")
        # log(c)
        if c == ".":
            # log("good")
            # log(itob(i))
            return substring3(content, s, i), i
        end
    end
    # log("no good")
    return substring3(content, s, e), e
end

# func abi_return_int(result):
#     # log(concat("\x15\x1f\x7c\x75", result))
#     # log(result)
#     int r = result
#     teal:
#         store 0
#     end
#     log(itob(result0))
#     return
# end

func abi_return(result: bytes):
    # log(concat("\x15\x1f\x7c\x75", result))
    log(result)
    return
end

# func abi_decode_string(value: bytes) bytes:
#     # return the content portion of the string, skipping the first 2 bytes which encode the length
#     return extract(2, 0, value)
# end

# func abi_encode_string(value: bytes) bytes:
#     # return the bytestring with a uint16 prefix denoting the length
#     return concat(extract(6, 2, itob(len(value))), value)
# end

func abi_encode_uint64(value: int) bytes:
    return itob(value)
end

# func abi_encode_uint32(value: int) bytes:
#     # return the last 4 bytes
#     return extract(4, 4, itob(value))
# end

# func abi_encode_uint16(value: int) bytes:
#     # return the last 2 bytes
#     return extract(6, 2, itob(value))
# end

# func abi_encode_uint8(value: int) bytes:
#     # return the last 1 byte
#     return extract(7, 1, itob(value))
# end

# func abi_encode_uint128(value: bytes) bytes:
#     # return 16 bytes with zero padding
#     return bzero(16) b| value
# end

# TODO assert input sizes, choose m appropriately
func calc_type(asset_amount: int, fx: bytes) bytes:

    if fx == "SUBJECTIVE":
        return "S"
    end

    int m = 10000

    int fx_n = extract_uint64(fx, 0)
    int fx_d = extract_uint64(fx, 8)

    bytes aa = app_global_get("a")
    int min = btoi(substring(56, 64, aa))
    int min_precision_n = btoi(substring(64, 72, aa))
    int min_precision_d = btoi(substring(72, 80, aa))
    
    int currency_quantity_after_fx = (m * (asset_amount * fx_n)) / fx_d
    int chrony_upper_bound = min * (m + ((m * min_precision_n) / min_precision_d))
    int chrony_lower_bound = min * (m - ((m * min_precision_n) / min_precision_d))

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