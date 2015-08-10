class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.string :description
      t.string :time_to_complete
      t.belongs_to :user 
      t.timestamps null: false
    end
  end
end
