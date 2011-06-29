#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'spec_helper'

describe PromotionsController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include ProductHelperMethods

  before (:each) do
    login_user
    set_default_locale
  end

  describe "Getting the promotions page " do

    before (:each) do
      @org = new_test_org
      controller.stub(:current_organization).and_return(@org)
      @env = @org.locker
    end

    it "should be successful with locker and no next environment" do
      get 'show', :org_id=>@org.cp_key, :env_id=>@env.name
      response.should be_success
      assigns(:changeset).should == @env.working_changesets.first
      assigns(:environment).should  == @env
      assigns(:next_environment).should == nil
    end

    it "should be successful on the locker and a next environment" do
      @env2 = KPEnvironment.new(:organization=>@org, :locker=>false, :name=>"otherenv", :prior=>@org.locker)
      @env2.save!
      get 'show', :org_id=>@org.cp_key, :env_id=>@env.name
      response.should be_success
      assigns(:changeset).should == @env.working_changesets.first
      assigns(:next_environment).should == @env2
      assigns(:environment).should  == @env
    end

    it "should be successful on the next environment with no changeset" do
      @env2 = KPEnvironment.new(:organization=>@org, :locker=>false, :name=>"otherenv", :prior=>@org.locker)
      @env2.save!
      get 'show', :org_id=>@org.cp_key, :env_id=>@env2.name
      response.should be_success
      assigns(:environment).should == @env2
      assigns(:next_environment).should == nil
      assigns(:changeset).should == @env2.working_changesets.first
    end

  end





end
