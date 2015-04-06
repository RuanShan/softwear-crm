module ImprintHelper
  def increment_new_imprint_counter
    # decrementing because we use negative numbers to determine
    # which imprints are new (id <=0) and which ones aren't (id >= 0)
    @new_imprint_counter ||= 0
    @new_imprint_counter -= 1
  end

  def imprint_select_field_name_for(imprint, field)
    if imprint.try(:id)
      "imprint[#{imprint.id}[#{field}]]"
    else
      "imprint[#{@new_imprint_counter}[#{field}]]"
    end
  end

  def update_name_number_table(job)
    %(
      $("#job-#{job.id}").find('.job-name-number-info')
        .html("#{j render('jobs/name_number_form', job: job) + render('jobs/name_number_table', job: job)}");
    )
      .html_safe
  end
end
