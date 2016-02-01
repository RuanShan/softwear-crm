class FbaSpreadsheetUploadsController < InheritedResources::Base
  def show
    super do |format|
      format.html
      format.js
    end
  end

  def upload
    if params[:fba_spreadsheet_upload][:spreadsheet].blank?
      flash[:error] = "Looks like you forgot to hit 'Browse'!"
      redirect_to new_fba_spreadsheet_upload_path and return
    end

    super do |success, failure|
      success.html do
        flash[:success] = flash[:notice] = nil
        redirect_to fba_spreadsheet_upload_path(@fba_spreadsheet_upload)
      end
      failure.html
    end
  end

  private

  def permitted_params
    params.permit(
      fba_spreadsheet_upload: [
        :errors, :spreadsheet
      ]
    )
  end
end
