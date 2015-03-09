class AddForeignKeyToTasks < ActiveRecord::Migration
  def change
    add_foreign_key :tasks, :employees
  end
end
