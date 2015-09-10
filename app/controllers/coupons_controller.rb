class CouponsController < InheritedResources::Base
  before_action :set_current_action
  before_action :format_dates, only: [:create, :update]

  def show
    super do |format|
      format.html { redirect_to edit_coupon_path params[:id] }
    end
  end

  def update
    super do |success, failure|
      success.html { redirect_to coupons_path }
      failure.html { render action: :edit }
    end
  end

  def validate
    @coupon = Coupon.find_by(code: params[:code])
    respond_to(&:js)
  end

  protected

  def set_current_action
    @current_action = 'coupons'
  end

  private

  def permitted_params
    params.permit(coupon: [:name, :code, :calculator, :value, :valid_until, :valid_from])
  end

  def format_dates
    return if params[:coupon].nil?

    unless params[:coupon][:valid_from].nil?
      valid_from = params[:coupon][:valid_from]
      params[:coupon][:valid_from] = format_time(valid_from)
    end

    unless params[:coupon][:valid_until].nil?
      valid_until = params[:coupon][:valid_until]
      params[:coupon][:valid_until] = format_time(valid_until)
    end
  end
end
