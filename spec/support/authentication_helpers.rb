module AuthenticationHelpers
	def login_through_form_as(user, password=nil, &block)
		visit '/users/sign_in'
		fill_in 'Email', with: (user.is_a?(String) ? user : user.email)
		r = Class.new do
			def initialize(context); @context = context; end
			def with(password, &block)
				@context.fill_in 'Password', with: password
				@context.click_button 'Login'
				@context.wait_for_ajax
				yield if block_given?
				@context.find(".modal-dialog button.close").click
				@context.wait_for_ajax
			end
		end.new(self)
		if password then r.with(password, &block)
		else return r end
	end
end