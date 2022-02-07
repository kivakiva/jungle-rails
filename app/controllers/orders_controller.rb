class OrdersController < ApplicationController

  def show
    @order = Order.find(params[:id])
    @line_items = LineItem.where(order_id: params[:id])

    
    line_item_id = {}
    
    @line_items.each do |item|
      line_item_id[item.id] = item.quantity
    end
    puts "line items"
    puts @line_items.inspect
    puts "line item 6 human feet shoes"
    puts @line_items[6]

    # @enhanced_order ||= Product.find(id: line_item_id).map {|product| { product:product, quantity: @line_items[product.id.to_s] } }
    @enhanced_order ||= Product.find(line_item_id.keys).map {|product| { product:product, quantity: line_item_id[product.id] } }

  end

  def create
    charge = perform_stripe_charge
    order  = create_order(charge)

    if order.valid?
      empty_cart!
      redirect_to order, notice: 'Your Order has been placed.'
    else
      redirect_to cart_path, flash: { error: order.errors.full_messages.first }
    end

  rescue Stripe::CardError => e
    redirect_to cart_path, flash: { error: e.message }
  end

  private

  def empty_cart!
    # empty hash means no products in cart :)
    update_cart({})
  end

  def perform_stripe_charge
    Stripe::Charge.create(
      source:      params[:stripeToken],
      amount:      cart_subtotal_cents,
      description: "Khurram Virani's Jungle Order",
      currency:    'cad'
    )
  end

  def create_order(stripe_charge)
    order = Order.new(
      email: params[:stripeEmail],
      total_cents: cart_subtotal_cents,
      stripe_charge_id: stripe_charge.id, # returned by stripe
    )

    enhanced_cart.each do |entry|
      product = entry[:product]
      quantity = entry[:quantity]
      order.line_items.new(
        product: product,
        quantity: quantity,
        item_price: product.price,
        total_price: product.price * quantity
      )
    end
    order.save!
    order
  end

end
