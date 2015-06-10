module PublicActivity
  module Renderable
    alias_method :super_render, :render
    def render(context, params={})
      begin
        super_render(context, params.dup)
      rescue ActionView::MissingTemplate => e
        # If there was no view for the particular model, we look
        # for default instead.
        key_for_default = self.key.split('.')
        key_for_default[-2] = 'default'
        path = key_for_default.join '/'
        super_render(context, params.merge(partial: path)) rescue raise e
      end
    end
  end
end
