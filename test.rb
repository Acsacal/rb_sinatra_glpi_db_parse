require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'dm-core'
require 'dm-validations'

set :bind, '0.0.0.0'

#DataMapper::Logger.new(STDOUT, :debug)

#DataMapper.setup(:default, 'mysql://glpi:gfhjkm@localhost/glpi')
DataMapper.setup(:default, 'mysql://glpi0804:mJq8C7M8WJTZCmCT@195.230.103.3/glpi0804')

class GlpiComputers
	include DataMapper::Resource

	property :id,						Serial
	property :name,						String
	property :contact,					String
	property :date_mod,					DateTime
	property :locations_id,				Serial
	property :computertypes_id,			Serial
	property :users_id,					Serial	
	property :groups_id,				Serial
	property :states_id,				Serial

	belongs_to :GlpiLocations, :parent_key => [ :id ], :child_key => [ :locations_id ]
	belongs_to :GlpiGroups, :parent_key => [ :id ], :child_key => [ :groups_id ]
	belongs_to :GlpiUsers, :parent_key => [ :id ], :child_key => [ :users_id ]
	belongs_to :GlpiComputersDeviceharddrives, :parent_key => [ :computers_id ], :child_key => [ :id ]
	belongs_to :GlpiComputersDevicememories, :parent_key => [ :computers_id ], :child_key => [ :id ]
	belongs_to :GlpiComputersDevicemotherboards, :parent_key => [ :computers_id ], :child_key => [ :id ]
	belongs_to :GlpiComputersDeviceprocessors, :parent_key => [ :computers_id ], :child_key => [ :id ]
	belongs_to :GlpiComputersItems, :parent_key => [ :computers_id ], :child_key => [ :id ]
end

class GlpiLocations
	include DataMapper::Resource

	property :id,						Serial
	property :completename,				String

	has n, :GlpiComputers, :parent_key => [ :id ], :child_key => [ :locations_id ]
end

class GlpiGroups
	include DataMapper::Resource

	property :id,						Serial
	property :name,						String

	has n, :GlpiComputers, :parent_key => [ :id ], :child_key => [ :groups_id ]
end

class GlpiUsers
	include DataMapper::Resource

	property :id,						Serial
	property :realname,					String

	has n, :GlpiComputers, :parent_key => [ :id ], :child_key => [ :users_id ]
end

class GlpiComputersDeviceharddrives
	include DataMapper::Resource

	property :id,						Serial
	property :computers_id,				Serial
	property :deviceharddrives_id,		Serial
	property :specificity,				Integer

	has n, :GlpiComputers, :parent_key => [ :computers_id  ], :child_key => [ :id ]
end

class GlpiComputersDevicememories
	include DataMapper::Resource

	property :id,						Serial
	property :computers_id,				Serial
	property :specificity,				Integer

	has n, :GlpiComputers, :parent_key => [ :computers_id  ], :child_key => [ :id ]
end

class GlpiComputersDevicemotherboards
	include DataMapper::Resource

	property :id,						Serial
	property :computers_id,				Serial
	property :devicemotherboards_id,	Serial

	has 1, :GlpiComputers, :parent_key => [ :computers_id  ], :child_key => [ :id ]
	has 1, :GlpiDevicemotherboards, :parent_key => [ :devicemotherboards_id ], :child_key => [ :id ]
	
end

class GlpiDevicemotherboards
	include DataMapper::Resource

	property :id,						Serial
	property :designation,				String

	belongs_to :GlpiComputersDevicemotherboards, :parent_key => [ :devicemotherboards_id ], :child_key => [ :id ]
end

class GlpiComputersDeviceprocessors
	include DataMapper::Resource

	property :id,						Serial
	property :computers_id,				Serial
	property :deviceprocessors_id,		Serial

	has 1, :GlpiComputers, :parent_key => [ :computers_id  ], :child_key => [ :id ]
	has 1, :GlpiDeviceprocessors, :parent_key => [ :deviceprocessors_id ], :child_key => [ :id ]
end

class GlpiDeviceprocessors
	include DataMapper::Resource

	property :id,						Serial
	property :designation,				String

	belongs_to :GlpiComputersDeviceprocessors, :parent_key => [ :deviceprocessors_id ], :child_key => [ :id ]
end

class GlpiComputersItems
	include DataMapper::Resource

	property :id,						Serial
	property :items_id,					Serial
	property :computers_id,				Serial
	property :itemtype,					String

	has 1, :GlpiComputers, :parent_key => [ :computers_id  ], :child_key => [ :id ]
	belongs_to :GlpiMonitors,  :parent_key => [ :items_id ], :child_key => [ :id ]
end

class GlpiMonitors
	include DataMapper::Resource

	property :id,						Serial
	property :users_id,					Serial
	property :locations_id,				Serial
	property :name,						String

	has n, :GlpiComputersItems, :parent_key => [ :items_id ], :child_key => [ :id ]
end

DataMapper.setup(:external, "sqlite3://#{Dir.pwd}/db/price.sqlite3")

class Price
   	include DataMapper::Resource

   	def self.default_repository_name
   		:external
   	end

   	property :id,					Serial
   	property :name, 				String, :required => true
   	property :price, 				Integer, :required => true
end

Price.auto_upgrade!

get '/' do
	@glpi_comp = GlpiComputers.all(:computertypes_id => 2, :states_id => 1, :order => [ :date_mod.desc ], :contact.not => ['conference', 'For home use', 'room2', 'room8', 'ConfRoom4'])
	erb :index
end

get '/new' do
	@glpi_comp = GlpiComputers.all(:computertypes_id => 2, :states_id => 1, :order => [ :date_mod.desc ], :contact.not => ['conference', 'For home use', 'room2', 'room8', 'ConfRoom4'])
	erb :new
end

post '/new' do
	@glpi_comp = GlpiComputers.all(:contact.like => "%#{params[:user_name].to_s}%", :computertypes_id => 2, :states_id => 1, :order => [ :date_mod.desc ], :contact.not => ['conference', 'For home use', 'room2', 'room8', 'ConfRoom4'])
	erb :new
end

get '/db_price' do
	@item_price_print = Price.all(:order => [ :name.asc ])
	erb :db_price
end

post '/db_update' do
	@item = Price.create(:name => params[:name], :price => params[:price].to_i)
  	redirect '/db_price'
end

get '/db_update/:id/delete' do
	Price.get(params[:id].to_i).destroy
	redirect '/db_price'
end