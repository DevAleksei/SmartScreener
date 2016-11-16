class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.string :url
      t.text :response
      t.date :when

      t.timestamps null: false
    end
  end
end
