class CreateAuditLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :audit_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action
      t.string :resource
      t.string :ip_address
      t.boolean :success
      t.text :metadata

      t.timestamps
    end
  end
end
