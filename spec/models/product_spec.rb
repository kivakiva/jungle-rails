require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'Validations' do
    # validation tests/examples here
    before '' do
      @category = Category.new
      @product = Product.new(
        name: 'name',
        price: 999,
        quantity: 1,
        category: @category
      )
    end
      it 'initializes' do
      end
      it 'requires a name to save' do
      end
      it 'requires a price to save' do
      end
      it 'requires a quantity to save' do
      end
      it 'requires a category to save' do
      end
  end
end

