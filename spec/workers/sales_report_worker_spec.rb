# frozen_string_literal: true

require 'rails_helper'
require 'mandrill_client'
require 'sidekiq/testing'

RSpec.describe SalesReportWorker do
  before do
    allow_any_instance_of(MandrillClient).to receive(:send_report_email).and_return(true)
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { SalesReportWorker }

  it 'Sales Report job is processed in importers queue.' do
    expect { subject.perform_async('daily', nil, nil) }.to change(subject.jobs, :size).by(1)
  end
end
