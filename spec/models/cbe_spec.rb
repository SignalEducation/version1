require 'rails_helper'

RSpec.describe Cbe, type: :model do

  context 'When creating an empty CBE' do
    it 'Should return nil values for name, title, description, and exam_body_id to be nil ' do
      cbe = Cbe.new
      expect(cbe.name).to eq nil
      expect(cbe.title).to eq nil
      expect(cbe.description).to eq nil
      expect(cbe.exam_body_id).to eq nil
    end
  end

  context 'When creating a CBE with values set' do
    it 'Should create a new CBE record with those values saved' do
      cbe = Cbe.create(name: 'BCCA EXAM', title: 'exam 1', description: 'test desc', exam_body_id: 1)
      expect(cbe.errors.blank?).to eq true
    end
  end

  context 'When creating a CBE with no alues set' do
    it 'Should return errors' do
      cbe = Cbe.create
      expect(cbe.errors.blank?).to eq false
    end
  end

  context 'When creating a CBE with default settings' do
    it 'Should create a new CBE record default settings' do
      cbe = Cbe.create(name: 'BCCA EXAM', title: 'exam 1', description: 'test desc', exam_body_id: 1)
      expect(cbe.hard_time_limit).to eq(nil)
      expect(cbe.exam_time).to eq nil
      expect(cbe.length_of_pauses).to eq nil
      expect(cbe.number_of_pauses_allowed).to eq nil

      cbe.initialize_settings
      expect(cbe.hard_time_limit).to eq(240)
      expect(cbe.exam_time).to eq 120
      expect(cbe.length_of_pauses).to eq 15
      expect(cbe.number_of_pauses_allowed).to eq 32

      expect(cbe.errors.blank?).to eq true
    end
  end

  context 'When creating a section & adding it attaching to a CBE' do
    it 'The section should have a name and be attached to the currenct CBE ' do
      cbe = Cbe.create(name: 'BCCA EXAM', title: 'exam 1', description: 'test desc', exam_body_id: 1)
      cbe_section = CbeSection.create(name: 'Intro')
      cbe << cbe_section
    end
  end


end
