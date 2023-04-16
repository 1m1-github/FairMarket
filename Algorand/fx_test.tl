#pragma version 8
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

    int fx_n = 3
    int fx_d = 2
    int asset_amount = 0
    int min = 0
    int min_precision_n = 1
    int min_precision_d = 10

    int m = 10000

    int currency_quantity_after_fx = (m * (asset_amount * fx_n)) / fx_d
    int chrony_upper_bound = min * (m + ((m * min_precision_n) / min_precision_d))
    int chrony_lower_bound = min * (m - ((m * min_precision_n) / min_precision_d))

    if currency_quantity_after_fx == 0:
        if chrony_lower_bound == 0:
            app_global_put("x", "L")
        else:
            app_global_put("x", "BADL")
        end
    elif currency_quantity_after_fx < chrony_lower_bound:
        app_global_put("x", "L")
    elif chrony_upper_bound < currency_quantity_after_fx:
        app_global_put("x", "H")
    else:
        app_global_put("x", "C")
    end

    exit(1)
end