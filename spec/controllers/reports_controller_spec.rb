require 'rails_helper'
require 'support/system_setup'
require 'support/users_and_groups_setup'

RSpec.describe ReportsController, :type => :controller do

  include_context 'system_setup'
  include_context 'users_and_groups_setup'

  context 'Not logged in: ' do

    describe "GET 'index'" do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'export_users'" do
      it 'should redirect to sign_in' do
        get :export_users
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'export_users_monthly'" do
      it 'should redirect to sign_in' do
        get :export_users_monthly
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'export_enrollments'" do
      it 'should redirect to sign_in' do
        get :export_enrollments
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'export_users_with_enrollments'" do
      it 'should redirect to sign_in' do
        get :export_users_with_enrollments
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'export_courses'" do
      it 'should redirect to sign_in' do
        get :export_courses
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'export_visits'" do
      it 'should redirect to sign_in' do
        get :export_visits
        expect_bounce_as_not_signed_in
      end
    end


  end


end