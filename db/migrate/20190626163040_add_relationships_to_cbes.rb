class AddRelationshipsToCbes < ActiveRecord::Migration[5.2]
  def change
    add_reference :cbe_sections, :cbe_section, foreign_key: true
    add_reference :cbe_introduction_pages, :cbe_introduction_page, foreign_key: true
    add_reference :cbe_agreements, :cbe_agreement, foreign_key: true
  end
end
