class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.string :user_name
      t.string :password
      t.string :current_service_hash

      t.timestamps
    end
  end
end
