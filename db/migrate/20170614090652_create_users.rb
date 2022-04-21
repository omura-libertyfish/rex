class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :image
      t.integer :best_gold_score, default: 0
      t.integer :best_silver_score, default: 0
      t.integer :continuous_times, default: 0
      t.string :provider
      t.text :uid
      t.string :oauth_token

      t.timestamps null: false
    end
  end
end
