Spree::Variant.class_eval do
  has_many :sale_prices, through: :prices

  delegate_belongs_to :default_price, :sale_price, :original_price, :on_sale?, :discount_percent

  def put_on_sale(value, params = {})
    currencies = params.fetch(:currencies, [])
    if params[:currency].present?
      currencies << params[:currency] unless currencies.include? params[:currency]
    end
    run_on_prices(currencies) { |p| p.put_on_sale value, params }
  end
  alias_method :create_sale, :put_on_sale

  # TODO: make update_sale method

  def active_sale_in(currency)
    price_in(currency).active_sale
  end
  alias_method :current_sale_in, :active_sale_in

  def next_active_sale_in(currency)
    price_in(currency).next_active_sale
  end
  alias_method :next_current_sale_in, :next_active_sale_in

  def sale_price_in(currency)
    Spree::Price.new variant_id: id, currency: currency, amount: price_in(currency).sale_price
  end

  def discount_percent_in(currency)
    price_in(currency).discount_percent
  end

  def on_sale_in?(currency)
    price_in(currency).on_sale?
  end

  def original_price_in(currency)
    Spree::Price.new variant_id: id, currency: currency, amount: price_in(currency).original_price
  end

  def enable_sale(currencies = nil)
    run_on_prices(currencies, &:enable_sale)
  end

  def disable_sale(currencies = nil)
    run_on_prices(currencies, &:disable_sale)
  end

  def start_sale(end_time = nil, currencies = nil)
    run_on_prices(currencies) { |p| p.start_sale end_time }
  end

  def stop_sale(currencies = nil)
    run_on_prices(currencies, &:stop_sale)
  end

  private

  # runs on all prices or on the ones with the currencies you've specified
  def run_on_prices(currencies = nil)
    if currencies.present? && currencies.any?
      prices_with_currencies = prices.select { |p| currencies.include?(p.currency) }
      prices_with_currencies.each { |p| yield p }
    else
      prices.each { |p| yield p }
    end
  end
end
