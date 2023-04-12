#pragma version 8

# global params
# owner [bytes]
# chrony/highroller/subjective importance [3xint] [owner can change]
# min [int] [owner can change]
# min precision [2xint] [owner can change]
# description [bytes] [owner can change]
# encryption public key [256 bytes = 3 vars]
# version [int]
# reputation +/- [2xint]

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

# reputation list of bidders [boxes]

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
        "create_bid": create_bid
        "cancel_bid": cancel_bid
        "add_reputation": add_reputation
        "withdraw": withdraw
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

block create_bid:
    
    # check
    const int FX_APP = 178969021
    assert(Gtxn[0].Type == Axfer)
    assert(Gtxn[0].AssetReceiver == Global.CurrentApplicationAddress)
    assert(Gtxn[1].Type == Appl)
    assert(Gtxn[1].Sender == Gtxn[0].Sender)
    assert(Gtxn[1].Receiver == FX_APP)
    assert(Gtxn[0].XferAsset == Gtxna[1].Assets[0])
    assert(Global.GroupID == 2)
    assert(Txn.Sender == Gtxn[0].Sender)



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