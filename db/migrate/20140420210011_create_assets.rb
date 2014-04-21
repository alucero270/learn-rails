class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.references :idea
      t.has_attached_file :file
    end
  end
end
