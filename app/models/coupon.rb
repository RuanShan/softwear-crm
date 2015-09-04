class Coupon < ActiveRecord::Base
  CALCULATORS = {
    percent_off_order: "reduces a % off the subtotal of the whole order",
    flat_rate:         "decucts a flat amount from the total of the whole order",
    percent_off_job:   "reduces a % off the total of a specified job within an order",
    free_shipping:     "deducts the shipping price from the order"
  }

  before_create :assign_code

  def assign_code
    self.code = SecureRandom.hex while Coupon.where(code: code).exists?
  end

  def apply(order, job = nil)
    calc_method = method(calculator)

    case calc_method.arity
    when 1 then calc_method.call(order)
    when 2 then calc_method.call(order, job)

    else raise "Calculator method #{calculator} must take 1 or 2 arguments. "\
               "Got #{calc_method.arity}."
    end
  end

  # === Calculators ===
  def percent_off_order(order)
    modify_method(order, :subtotal) do |subtotal|
      subtotal - subtotal * value/100
    end
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
