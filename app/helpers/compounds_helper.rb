module CompoundsHelper

	def smiles_column(record)
    if !record.smiles.blank?
      image_tag "http://cactus.nci.nih.gov/chemical/structure/#{URI.escape(record.smiles)}/image", :alt => record.smiles
      #display_smiles(record.smiles)
    else
      '-'
    end
	end

  def chemid_column(record)
    if !record.cas.blank?
      cas = record.cas.gsub(/-/,'').rjust(9,"0")
      link_to "ChemIDPlus", "http://chem.sis.nlm.nih.gov/chemidplus/direct.jsp?result=advanced&regno=#{cas}", :target => '_blank'
    else
      '-'
    end
  end

  def pubchem_column(record)
    if !record.smiles.blank?
      inchi = @translator.translate record.smiles
      pubChemUrl = 'http://www.ncbi.nlm.nih.gov/sites/entrez?cmd=PureSearch&db=pccompound&term=' + inchi
      link_to "PubChem", h(pubChemUrl), :target => '_blank'
    else
      '-'
    end
  end

end
