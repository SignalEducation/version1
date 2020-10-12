# frozen_string_literal: true

require 'rails_helper'
require 'mandrill_client'
require 'sidekiq/testing'

RSpec.describe OrdersReportWorker do
  let(:email)         { SALES_REPORT_EMAIL }
  let(:period)        { 'monthly' }
  let(:date_interval) {  Time.zone.yesterday.all_month }

  before do
    allow_any_instance_of(MandrillClient).to receive(:send_report_email).and_return(true)
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { OrdersReportWorker }

  it 'Orders Report job is processed in importers queue.' do
    expect { subject.perform_async(period, date_interval, email) }.to change(subject.jobs, :size).by(1)
  end
end
