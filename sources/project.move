module MyModule::Local_Deals_Platform {

    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a local deal.
    struct Deal has store, key {
        price: u64,         // Price per unit in AptosCoin
        stock: u64,         // Units available
        sold: u64,          // Units sold
    }

    /// Create a new deal (merchant's function).
    public fun create_deal(merchant: &signer, price: u64, stock: u64) {
        let deal = Deal {
            price,
            stock,
            sold: 0,
        };
        move_to(merchant, deal);
    }

    /// Purchase a deal (customer's function).
    public fun purchase_deal(
        customer: &signer,
        merchant_addr: address,
        quantity: u64
    ) acquires Deal {
        let deal = borrow_global_mut<Deal>(merchant_addr);

        // Ensure enough stock
        assert!(deal.stock >= quantity, 1);

        let total_cost = deal.price * quantity;

        // Transfer payment
        let payment = coin::withdraw<AptosCoin>(customer, total_cost);
        coin::deposit<AptosCoin>(merchant_addr, payment);

        // Update deal data
        deal.stock = deal.stock - quantity;
        deal.sold = deal.sold + quantity;
    }
}
