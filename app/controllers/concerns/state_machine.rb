module StateMachine
  extend ActiveSupport::Concern
  
  def state
    @object = resource_class.find(params[:id])
    if @object.is_a?(Order)
      @order = @object
    else
      @order = @object.order
    end
    @transition = params[:transition].to_sym unless params[:transition].nil?
    @machine = params[:state_machine]
    transition_state if (@machine && @transition)
    respond_to do |format|
      format.js
      format.html do 
        if @successful_transition
          redirect_to edit_order_path(@order), notice: "Successfully transitioned #{@machine.humanize}"
        else
          redirect_to edit_order_path(@order), error: "Failed to transition #{@machine.humanize}"
        end
      end
    end
  end

  private
  
  def transition_state
    if @object.send("#{@machine}_events").include? @transition
      old_state = @object.send(@machine)
      PublicActivity.enabled = false
      @object.send("fire_#{@machine}_event",  @transition)
      @successful_transition = true if @object.valid?
      if @successful_transition
        PublicActivity.enabled = true
        transition_params = {
          old_state: old_state,
          new_state: @object.send(@machine),
          machine: params[:state_machine],
          transition: params[:transition],
          details: params[:details]
        }
        @object.create_activity(
              action:     :transition,
              parameters: transition_params,
              owner:      current_user
        )
      end
      @object.reload
    else
      @object.errors.add(:base, "Invalid transition '#{@transition.to_s.humanize}' for
                        '#{@machine.to_s.humanize}' from state '#{@object.send(@machine).humanize}'")
    end
  end
end
