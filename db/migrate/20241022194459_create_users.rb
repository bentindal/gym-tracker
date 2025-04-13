# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users, if_not_exists: true do |t|
      t.string :email, default: '', null: false
      t.string :encrypted_password, default: '', null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.string :first_name
      t.string :last_name
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip
      t.boolean :isPublic, default: true
      t.integer :streakcount, default: 0
      t.integer :highest_streak, default: 0

      t.index :email, unique: true, name: 'index_users_on_email'
      t.index :reset_password_token, unique: true, name: 'index_users_on_reset_password_token'

      t.timestamps
    end
  end
end
