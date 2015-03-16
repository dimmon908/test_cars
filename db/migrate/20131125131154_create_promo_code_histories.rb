class CreatePromoCodeHistories < ActiveRecord::Migration
  def change
    create_table :promo_code_histories do |t|
      t.references :user
      t.references :promo_code
      t.references :request

      t.timestamps
    end
    add_index :promo_code_histories, :user_id
    add_index :promo_code_histories, :promo_code_id
    add_index :promo_code_histories, :request_id
  end
end
