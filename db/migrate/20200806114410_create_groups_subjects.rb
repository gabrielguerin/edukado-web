class CreateGroupsSubjects < ActiveRecord::Migration[6.0]
  def change
    create_table :groups_subjects do |t|
      t.references :group, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true

      t.timestamps
    end
  end
end
