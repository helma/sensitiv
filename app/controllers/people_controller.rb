class PeopleController < ApplicationController
	active_scaffold :person do |conf|
		conf.label = 'Investigators'
    conf.actions.exclude :show
		#onf.columns.exclude :bio_source_provider
    #conf.columns[:roles].clear_link
    #onf.columns[:roles].form_ui = :select
    #conf.subform.columns.add :roles

    conf.update.link.page = true
    conf.create.link.page = true
	end

end
