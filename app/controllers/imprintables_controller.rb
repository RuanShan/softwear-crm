class ImprintablesController < ApplicationController
  def index
    @imprintables = Imprintable.all
  end

  def show
  end

  def new
    @imprintable = Imprintable.new
  end

  def create
    @imprintable = Imprintable.new(imprintable_params)

    respond_to do |format|
      if @imprintable.save
        format.html {
          flash[:notice] = 'Imprintable was successfully created.'
          redirect_to action: 'index'
        }
        format.json { render action: 'index', status: :created,
          location: @product }
      else
        format.html { render action: 'new' }
        format.json { render json: @imprintable.errors,
          status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @imprintable.update(imprintable_params)
        format.html {
          flash[:notice] = 'Product was successfully updated.'
          redirect_to @imprintable
        }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @imprintable.errors,
                             status: :unprocessable_entity }
      end
    end
  end

  def destroy
  end


private
  def imprintable_params
    params.require(:imprintable).permit(:name, :catalog_number, :description)
  end
end
