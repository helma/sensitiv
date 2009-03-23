# Methods added to this helper will be available to all templates in the application.

module ApplicationHelper

	def display_smiles(smiles)
    '<img src="' + url_for(:controller => "compounds", :action => "display_smiles", :smiles => smiles)+ '" alt="' + smiles+'"></img>'
	end

  def display_smiles_with_fragments(smiles, activating_fragments,deactivating_fragments,activating_p,deactivating_p,unknown_fragments)
    session[:smiles] = smiles
    session[:activating_fragments] = activating_fragments
    session[:deactivating_fragments] = deactivating_fragments
    session[:unknown_fragments] = unknown_fragments
    session[:activating_p] = activating_p
    session[:deactivating_p] = deactivating_p

    '<img src="' + url_for(:controller => "compounds", :action => "display_smiles_with_fragments", :smiles => smiles) + '" alt="' + smiles +'"></img>'
  end

  def audited_column(record)
    if record.audited
      #image_tag "check_mark.png", :alt => "yes", :size => "8x8"
      "yes"
    else
      #link_to("<b>--</b>", :action => :audit, :id => record.id)
      link_to("no", :action => :audit, :id => record.id)
    end
  end
    
end
