# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe MandrillWorker do
  let(:user) { build(:user) }
  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
    allow_any_instance_of(MandrillClient).to receive(:send).and_return(:ok)
    allow(User).to receive(:find).and_return(user)
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { MandrillWorker }

  it 'Mandrill job is processed in high queue.' do
    expect { subject.perform_async(user.id, 'method_name', %w[arg1 arg2]) }.to change(subject.jobs, :size).by(1)
  end
end
