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

class System < ActiveRecord::Base
  include Glue::Candlepin::Consumer
  include Glue::Pulp::Consumer
  include Glue
  include Authorization

  belongs_to :organization, :inverse_of => :systems
  validates :organization, :presence => true
  validates :name, :presence => true, :no_trailing_space => true
  validates :description, :katello_description_format => true
  before_create  :fill_defaults

  scoped_search :on => :name, :complete_value => true
  scoped_search :on => :description, :complete_value => true
  scoped_search :on => :location, :complete_value => true
  scoped_search :on => :uuid, :complete_value => true

  def consumed_pool_ids
    self.pools.collect {|t| t['id']}
  end

  def consumed_pool_ids=attributes
    attribs_to_unsub = consumed_pool_ids - attributes
   
    attribs_to_unsub.each do |id|
      self.unsubscribe id
    end
    
    attribs_to_sub = attributes - consumed_pool_ids
    attribs_to_sub.each do |id|
      self.subscribe id
    end
  end

  # returns list of virtual permission tags for the current user
  def self.list_tags
    select('id,name').all.collect { |m| VirtualTag.new(m.id, m.name) }
  end

  private
    def fill_defaults
      self.description = "Initial Registration Params" unless self.description
      self.location = "None" unless self.location
    end
end
