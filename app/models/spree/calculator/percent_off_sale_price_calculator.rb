module Spree
  class Calculator::PercentOffSalePriceCalculator < Spree::Calculator

    after_initialize :init

    # TODO: validate that the sale price is between 0 and 1
    def self.description
      'Calculates the sale price for a Variant by taking off a percentage of the original price'
    end

    def compute(sale_price)
      computed_price = (1.0 - sale_price.value.to_f) * sale_price.variant.price_in(sale_price.price.currency).original_price.to_f
      if preferences[:round_to_nearest_multiple_of] && preferences[:round_to_nearest_multiple_of].integer?
        (computed_price / preferences[:round_to_nearest_multiple_of]).round * preferences[:round_to_nearest_multiple_of]
      elsif preferences[:round_number]
        computed_price.round.to_f
      else
        computed_price
      end
    end

    private

      def init
        # No rounding by default
        self.preferences[:round_number] ||= false
      end

  end
end
