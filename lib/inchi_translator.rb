require 'rubygems'
gem 'rjb'
gem 'rino'
require 'rjb'
require 'rino'
Rjb::load(classpath = './lib/java/:lib/java/cdk-1.0.1.jar')

StringWriter = Rjb::import 'java.io.StringWriter'

SmilesParser = Rjb::import 'org.openscience.cdk.smiles.SmilesParser'
MDLWriter = Rjb::import 'org.openscience.cdk.io.MDLWriter'

# Converts a SMILES string into an InChI identifier using
# the CDK Library (Java) and the Rino Library (Ruby/C).
class InchiTranslator

  def initialize
    @smiles_parser = SmilesParser.new
    @mdl_writer = MDLWriter.new
    @mol2inchi = Rino::MolfileReader.new
    #@mol2inchi.options << '-t'
  end

  # Returns an InChI identifier from the specified SMILES string.
  # Uses the CDK classes SmilesParser and MDLWriter to generate
  # a molfile from a SMILES string. Then this molfile is
  # parsed by Rino::MolfileReader.
  def translate(smiles)
    mol = @smiles_parser.parseSmiles(smiles)

    sw = StringWriter.new

    @mdl_writer.setWriter(sw)
    @mdl_writer.write(mol)

    @mol2inchi.read(sw.toString)
  end
end
