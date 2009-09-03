#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + '/../spec/spec_helper')

## This example is pretty ugly. It should be pretty when moved to the phrk gem.

class Say
  include OxMlk
  
  ox_elem :phrase, :from => :content
  
  def description
    "Say '#{phrase}'"
  end
end

class Play
  include OxMlk
  
  ox_elem :file, :from => :content
  
  def description
    "Play #{file}"
  end
end

class Gather
  include OxMlk
  
  ox_attr :action
  ox_attr :method
  ox_attr :timeout, :as => Integer
  ox_attr :finish_on_key, :from => 'finishOnKey'
  ox_attr :num_digits, :from => 'numDigits', :as => Integer
  
  ox_elem :verbs, :as => [Say,Play]
  
  def description
    "Gather #{num_digits} keypresses ending on key 'finish_on_key}' or timing out at #{timeout} seconds, then send #{method} to #{action}:\n\t#{verbs.map(&:description).join("\n\t")}"
  end
end

class Record
  include OxMlk
  
  ox_attr :action
  ox_attr :method
  ox_attr :max_length, :from => 'maxLength', :as => Integer
  ox_attr :finish_on_key, :from => 'finishOnKey'
  
  def description
    "Record for #{max_length} seconds max ending on keys '#{finish_on_key}' then send #{method} to #{action}"
  end
end

class Redirect
  include OxMlk
  
  ox_elem :destination, :from => :content
  
  def description
    "Redirect to #{destination}"
  end
end

class Pause
  include OxMlk
  
  ox_attr :length
  
  def description
    "Pause for #{length} seconds"
  end
end

class Hangup
  include OxMlk
  
  def description
    'Hangup'
  end
end

class Number
  include OxMlk
  
  ox_attr :send_digits, :from => 'sendDigits'
  ox_elem :number, :from => :content
  
  def description
    "Call #{number} and send digits '#{send_digits}'"
  end
end

class Dial
  include OxMlk
  
  ox_attr :callerid
  ox_elem :numbers, :as => [Number]
  
  def description
    "Dial numbers with caller id #{callerid}:\n\t#{numbers.map(&:description).join("\n\t")}"
  end
end

class Tag
  include OxMlk
  
  ox_elem :tag, :from => :content
  
  def description
    "Add tag '#{tag}'"
  end
end

class Tags
  include OxMlk
  
  ox_attr :mode
  ox_attr :include
  ox_attr :exclude
  
  def description
    "Tagged with (#{include}) but not (#{exclude}) using match mode(#{mode})"
  end
end

class Schedule
  include OxMlk
  
  ox_attr :mode 
  ox_attr :tz_offset
  ox_attr :time
  ox_attr :year
  ox_attr :month
  ox_attr :day_of_week
  ox_attr :day_of_month
  
  def description
    "Schedule: mode(#{mode}) tz_offset(#{tz_offset}) time(#{time}) year(#{year}) month(#{month}) day_of_week(#{day_of_week} day_of_month(#{day_of_month}))"
  end
end

VERBS = [Say,Play,Gather,Record,Redirect,Pause,Hangup,Dial,Tag]

class Rule
  include OxMlk
  
  ox_attr :name
  ox_attr :mode
  ox_elem :conditions, :as => [Schedule,Tags], :in => 'Conditions'
  ox_elem :match_verbs, :as => VERBS, :in => 'Match'
  ox_elem :no_match_verbs, :as => VERBS, :in => 'NoMatch'
  
  def description
    "Rule #{name} - match mode(#{mode})\n\tConditions:\n\t#{conditions.map(&:description).join("\n\t")}\n\n\tOn Match:\n\t#{match_verbs.map(&:description).join("\n\t")}\n\n\tNo Match:\n\t#{no_match_verbs.map(&:description).join("\n\t")}"
  end
end

class Response
  include OxMlk
  
  ox_elem :verbs, :as => VERBS + [Rule]
end

class String
  def description
    self
  end
end

response = Response.from_xml(xml_for(:phrk))

puts *response.verbs.map{|x| [x,'']}.flatten.map(&:description)