class Coupon < ActiveRecord::Base
  CALCULATORS = {
    percent_off_order: "Reduces a % off the subtotal of the whole order",
    flat_rate:         "Decucts a flat amount from the total of the whole order",
    percent_off_job:   "Reduces a % off the total of a specified job within an order",
    free_shipping:     "Deducts the shipping price from the order"
  }
    .with_indifferent_access

  validates :name, :code, uniqueness: true, presence: true
  validates :calculator, inclusion: { in: CALCULATORS.keys, message: 'is not a defined calculator method' }

  after_initialize :assign_code

  def assign_code
    self.code = SecureRandom.hex if code.blank?
  end

  def requires_job?
    method(calculator).arity == 2
  end

  def calculate(order, job = nil)
    calc_method = method(calculator)

    case calc_method.arity
    when 1 then calc_method.call(order)
    when 2 then calc_method.call(order, job)

    else raise "Calculator method #{calculator} must take only 1 or 2 arguments. "\
               "Got #{calc_method.arity}."
    end
  end

  def format_value(view)
    case calculator

    when /percent_off/   then "#{value}%"
    when /flat_rate/     then view.number_to_currency(value)
    when /free_shipping/ then "No Shipping"

    else value
    end
  end

  def time(attribute)
    t = send(attribute)
    if t
      t.strftime('%m/%d/%Y')
    else
      case attribute.to_sym
      when :valid_from  then 'the beginning of time'
      when :valid_until then 'the end of time'
      else '???'
      end
    end
  end

  # === Calculators ===
  def percent_off_order(order)
    order.subtotal * value/100
  end

  def flat_rate(order)
    value
  end

  def percent_off_job(order, job)
    job.total_price * value/100
  end

  def free_shipping(order)
    order.shipping_price
  end

  protected

  def modify_method(order, method_name, &block)
    stack = order.instance_variable_get("@#{method_name}_mods")
    if stack.nil?
      stack = order.instance_variable_set("@#{method_name}_mods", [])

      order.define_singleton_method method_name do |*args|
        result = super(*args)

        instance_variable_get("@#{method_name}_mods").each do |modifier|
          result = modifier.call(result, *args)
        end

        result
      end
    end

    stack << block
  end
end
