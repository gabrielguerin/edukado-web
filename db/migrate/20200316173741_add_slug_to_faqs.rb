class AddSlugToFaqs < ActiveRecord::Migration[6.0]
  def change
    add_column :faqs, :slug, :string
    add_index :faqs, :slug, unique: true
  end
end
