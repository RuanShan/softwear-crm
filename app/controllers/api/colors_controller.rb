module Api
  class ColorsController < ApiController
    def index
      super { @colors = Color.where(retail: true) }
    end
  end
end