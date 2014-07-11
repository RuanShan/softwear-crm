require_dependency "api/application_controller"

module Api
  class ImprintablesController < ApplicationController
    def index
      @imprintables = Imprintable.where(standard_offering: true)
      respond_to do |format|
        format.json { render json: @imprintables }
      end
    end

    def show
      @imprintable = Imprintable.find(params[:id])
      respond_to do |format|
        format.json { render json: @imprintable, include: [:colors, :sizes, :style, :brand, :imprintable_variants] }
      end
    end
  end
end
