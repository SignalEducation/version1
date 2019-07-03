require 'rails_helper'

# These need to be passed into the create method
# :name, :scenario_label, :scenario_description, :cbe,

RSpec.describe CbeSection, type: :model do
  context 'When creating an empty CBE Section' do
    it 'Should return an error as it needs to be attached to a CBE' do
      cbe = Cbe.create(name: 'BCCA EXAM', title: 'exam 1', description: 'test desc', exam_body_id: 1)
      cbe_section = CbeSection.create(name: 'Intro',
                                      scenario_label: 'S Label',
                                      scenario_description: 'S Desc',
                                      cbe: cbe)

      expect(cbe_section.name).not_to eq nil
      expect(cbe_section.scenario_label).not_to eq nil
      expect(cbe_section.scenario_description).not_to eq nil
      expect(cbe_section.cbe).not_to eq nil
    end
  end
end
