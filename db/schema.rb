# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090518110009) do

  create_table "bio_samples", :force => true do |t|
    t.string  "name"
    t.integer "developmental_stage_id"
    t.integer "cell_line_id"
    t.integer "cell_type_id"
    t.integer "organism_id"
    t.integer "organism_part_id"
    t.integer "sex_id"
    t.integer "experiment_id"
    t.integer "growth_condition_id"
    t.integer "individual_id"
  end

  create_table "bio_samples_protocols", :id => false, :force => true do |t|
    t.integer "bio_sample_id"
    t.integer "protocol_id"
  end

  create_table "bool_values", :force => true do |t|
    t.boolean "value"
  end

  create_table "cell_lines", :force => true do |t|
    t.string "name"
  end

  create_table "cell_types", :force => true do |t|
    t.string "name"
  end

  create_table "compounds", :force => true do |t|
    t.string  "name"
    t.string  "cas"
    t.string  "smiles"
    t.string  "comment"
    t.string  "inchi"
    t.integer "cid"
    t.boolean "training_compound", :default => false
  end

  create_table "compounds_experiments", :id => false, :force => true do |t|
    t.integer "experiment_id"
    t.integer "compound_id"
  end

  create_table "concentrations", :force => true do |t|
    t.float   "value"
    t.integer "unit_id"
  end

  create_table "developmental_stages", :force => true do |t|
    t.string "name"
  end

  create_table "dose_response_curves", :force => true do |t|
    t.integer  "compound_id"
    t.integer  "result_id"
    t.integer  "cell_line_id"
    t.integer  "concentration_unit_id"
    t.integer  "duration_id"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dose_response_curves_dose_response_sheets", :id => false, :force => true do |t|
    t.integer "dose_response_curve_id"
    t.integer "dose_response_sheet_id"
  end

  create_table "dose_response_sheets", :force => true do |t|
    t.integer  "cell_line"
    t.integer  "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "durations", :force => true do |t|
    t.float   "value"
    t.integer "unit_id"
  end

  create_table "experiments", :force => true do |t|
    t.string  "name"
    t.string  "title"
    t.date    "date"
    t.string  "description"
    t.boolean "audited",        :default => false
    t.integer "workpackage_id"
  end

  create_table "experiments_people", :id => false, :force => true do |t|
    t.integer "experiment_id"
    t.integer "person_id"
  end

  create_table "experiments_protocols", :id => false, :force => true do |t|
    t.integer "experiment_id"
    t.integer "protocol_id"
  end

  create_table "file_documents", :force => true do |t|
    t.string "file"
  end

  create_table "float_values", :force => true do |t|
    t.float "value"
  end

  create_table "growth_conditions", :force => true do |t|
    t.string "description"
  end

  create_table "human_interactions", :force => true do |t|
    t.string "unique_id_a"
    t.string "unique_id_b"
    t.string "aliases_a"
    t.string "aliases_b"
    t.string "interaction_detection_methods"
    t.string "pubmed_ids"
    t.string "ncbi_taxonomy_id_a"
    t.string "NCBI_taxonomy_id_b"
    t.string "interactor_types"
    t.string "source_database"
    t.string "interaction_id"
    t.string "count"
    t.string "interaction_labels"
    t.string "different_techniques"
    t.string "different_pubmed_articles"
    t.string "different_sources"
    t.string "weight"
  end

  add_index "human_interactions", ["unique_id_b"], :name => "index_human_interactions_on_unique_id_b"
  add_index "human_interactions", ["unique_id_a"], :name => "index_human_interactions_on_unique_id_a"

  create_table "individuals", :force => true do |t|
    t.string "name"
  end

  create_table "organisations", :force => true do |t|
    t.string "name"
    t.string "address"
  end

  create_table "organism_parts", :force => true do |t|
    t.string "name"
  end

  create_table "organisms", :force => true do |t|
    t.string "genus"
    t.string "species"
    t.string "name"
  end

  create_table "outcomes", :force => true do |t|
    t.integer "property_id"
    t.integer "value_id"
    t.integer "unit_id"
    t.integer "treatment_id"
    t.integer "experiment_id"
    t.string  "type"
    t.string  "value_type"
  end

  create_table "outcomes_protocols", :id => false, :force => true do |t|
    t.integer "outcome_id"
    t.integer "protocol_id"
  end

  create_table "people", :force => true do |t|
    t.string "last_name"
    t.string "first_name"
    t.string "mid_initials"
    t.string "email"
    t.string "phone"
    t.string "organisation_id"
  end

  create_table "plugin_schema_info", :id => false, :force => true do |t|
    t.string  "plugin_name"
    t.integer "version"
  end

  create_table "potencies", :force => true do |t|
    t.string "name"
  end

  create_table "properties", :force => true do |t|
    t.string "name"
  end

  create_table "protocols", :force => true do |t|
    t.string  "description"
    t.integer "workpackage_id"
    t.boolean "audited",        :default => false
    t.string  "name"
    t.string  "text"
    t.string  "uri"
    t.string  "file"
  end

  create_table "protocols_treatments", :id => false, :force => true do |t|
    t.integer "treatment_id"
    t.integer "protocol_id"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"
  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"

  create_table "sexes", :force => true do |t|
    t.string "name"
  end

  create_table "solvents", :force => true do |t|
    t.integer "compound_id"
    t.integer "concentration_id"
  end

  create_table "strain_or_lines", :force => true do |t|
    t.string "name"
  end

  create_table "string_values", :force => true do |t|
    t.string "value"
  end

  create_table "survey_analysis_purposes", :force => true do |t|
    t.boolean "biomarker_identification"
    t.boolean "pathway_identification"
    t.boolean "evaluation_of_experimental_conditions"
    t.boolean "assay_comparison"
    t.string  "other"
    t.string  "comment"
    t.integer "workpackage_id"
  end

  create_table "survey_database_purposes", :force => true do |t|
    t.boolean "data_backup"
    t.boolean "data_dissemination"
    t.boolean "data_analysis"
    t.string  "other"
    t.string  "comment"
    t.integer "workpackage_id"
  end

  create_table "survey_experiments", :force => true do |t|
    t.string  "description"
    t.string  "purpose"
    t.string  "cell_line"
    t.string  "measurements"
    t.string  "remarks"
    t.boolean "standardised_sop"
    t.boolean "treatment"
    t.boolean "time_course"
    t.boolean "dose_response"
    t.boolean "finished"
    t.integer "workpackage_id"
  end

  create_table "treatments", :force => true do |t|
    t.integer "compound_id"
    t.integer "bio_sample_id"
    t.integer "experiment_id"
    t.integer "solvent_id"
    t.integer "concentration_id"
    t.integer "duration_id"
  end

  create_table "units", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string "name"
    t.string "hashed_password"
  end

  create_table "users_workpackages", :id => false, :force => true do |t|
    t.integer "workpackage_id"
    t.integer "user_id"
  end

  create_table "workpackages", :force => true do |t|
    t.integer "nr"
  end

end
