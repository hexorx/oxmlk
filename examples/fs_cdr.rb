#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + '/../spec/spec_helper')
require 'sqlite3'
require 'activerecord'

DB_PATH = File.join(File.dirname(__FILE__), 'active_record.sqlite3')
ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => DB_PATH
)

class Cdr < ActiveRecord::Base
  include OxMlk
  
  ox_tag :cdr
  
  ox_elem :hangup_cause, :in => 'variables'
  ox_elem :start_stamp, :in => 'variables'
  ox_elem :answer_stamp, :in => 'variables'
  ox_elem :end_stamp, :in => 'variables'
  ox_elem :caller_id, :in => 'variables'
  ox_elem :duration, :in => 'variables'
  ox_elem :billsec, :in => 'variables'
end

# do a quick pseudo migration.  This should only get executed on the first run
unless Cdr.table_exists?
  ActiveRecord::Base.connection.create_table(:cdrs) do |t|
    t.string :hangup_cause
    t.string :start_stamp
    t.string :answer_stamp
    t.string :end_stamp
    t.string :caller_id
    t.string :duration
    t.string :billsec
    t.timestamps
  end
end

new_cdr = Cdr.from_xml(xml_for(:fs_cdr))

new_cdr.save
cdr = Cdr.find new_cdr.id

puts cdr.hangup_cause, 
  cdr.start_stamp, 
  cdr.answer_stamp, 
  cdr.end_stamp, 
  cdr.caller_id, 
  cdr.duration, 
  cdr.billsec, 
  '', 
  cdr.to_xml
