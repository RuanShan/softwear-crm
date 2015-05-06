class RefactorLineItemGroupsIntoJobs < ActiveRecord::Migration
  def change
    rename_column :jobs, :order_id, :jobbable_id
    add_column :jobs, :jobbable_type, :string

    connection = ActiveRecord::Base.connection
    line_item_groups = connection.exec_query('select name, description, quote_id, created_at, updated_at, id from line_item_groups')
    line_item_groups.each do |line_item_group|
      job = Job.new(
          name: line_item_group['name'],
          description: line_item_group['description'],
          jobbable_id: line_item_group['quote_id'],
          created_at: line_item_group['created_at'],
          updated_at: line_item_group['updated_at']
      )
      job.save(validate: false)

      line_items = LineItem.where(line_itemable_type: 'LineItemGroup', line_itemable_id: line_item_group['id'])
      line_items.each do |li|
        li.update_columns(line_itemable_type: 'Job', line_itemable_id: job.id)
      end
    end
  end
end
