class AddSubjectToPosts < ActiveRecord::Migration[6.0]
  def change
    add_reference :posts, :subject, null: false, foreign_key: true
  end
end
