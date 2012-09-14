#require 'rubygems'
#require 'capybara'
#require 'capybara/dsl'
#require 'capybara/rspec'
#require 'capybara-webkit'
#require 'launchy'


#require 'capybara_helper'


def screenshot
  require 'capybara/util/save_and_open_page'
  now = Time.now
  p = "/#{now.strftime('%Y-%m-%d-%H-%M-%S')}-#{rand}"
  Capybara.save_page body, "#{p}.html"
  path = Rails.root.join("#{Capybara.save_and_open_page_path}" "#{p}.png").to_s
  page.driver.render path
  Launchy.open path
end

def verify_alert_message(msg, &block)
  page.evaluate_script %Q|  window.alert = function(msg) {
                              window.alert_message = msg;
                              return true;
                            }; |
  yield
  page.evaluate_script("window.alert_message").should eq(msg)
ensure
  page.evaluate_script("window.alert_message = null)")
end

def js_confirm(accept=true)
  page.evaluate_script "window.original_confirm = window.confirm"
  page.evaluate_script "window.confirm = function(msg) { return #{!!accept}; }"
  yield
ensure
  page.evaluate_script "window.confirm = window.original_confirm"
end

def wait_until_ajax_done(wait_time=Capybara.default_wait_time)
  wait_until wait_time do
    page.evaluate_script('$.active') == 0
  end
end


RSpec.configure do |config|
  config.before(:each) do
  Capybara.default_wait_time = 10
  Capybara.default_driver = :webkit
  Capybara.javascript_driver = :webkit
  Capybara.run_server = false
  Capybara.app_host = ENV["TEST_SERVER"] || 'http://localhost:3000'
  puts ' using remote server : '+ Capybara.app_host.to_s
  end
end



def should_have_no_errors
  page.should_not have_content "something went wrong"
  page.should_not have_css ".alert-error"
end

def find_answer concept
  puts 'find_answer : ' + concept.to_s
  msg = "cannot fill in, no text field, text area or password field with data-short_name= '#{concept}' found"
  page.find(:css,("[data-short-name='#{concept}']") , :message => msg)
end

def fill_answer concept,value
  if (value.nil? || value.to_s.blank?)
    puts ' skip filling concept ' + concept
    return false
  end
  puts ' fill_answer ' + concept + ' : ' + value.to_s
  node = find_answer(concept)
  name = node[:name]

  if node["disabled"] == true
    puts 'disabled :' + node[:disabled]+' visible? ' + node.visible?.to_s + ' : ' + node["data-short-name"]
    wait_until { node.visible? }
  end

  if name.include? "date_value"
    #date field
    date = Date.parse(value)
    puts 'set date : year : '  + date.year.to_s + ' month : '  + date.month.to_s + ' day : ' + date.day.to_s
    node.set(date.day.to_s)
    find(:css,("[name='#{name.sub("3i","2i")}']")).set(date.month.to_s)
    find(:css,("[name='#{name.sub("3i","1i")}']")).set(date.year.to_s)
  end
  #puts 'disabled ' + node[:disabled] +' : '+  ' : ' + node["data-short-name"]

  node.set(value)
  node.trigger("change")
end

def fill_answers options
  options.each_key do  |key|
    fill_answer key,options[key]
  end
end

def populate_patient_assessments options
  options.each do |option|
    populate_patient_assessment option
  end
end

def populate_patient_assessment options
  visit '/'
  puts ' options[:answers] '  + options[:answers].to_s
  click_link "Pre-op assessment"
  should_have_no_errors
  page.should have_content "Please answer these questions"
  fill_answers options[:answers]
  populate_with_random_answers
  click_button "Submit"
  page.should have_content "Assessment was successfully created"
end

def login prof
  visit '/'
  puts prof.to_s
  click_link "Login"
  fill_in "user_email", {with: prof['email']}
  fill_in "user_password", {with: prof['password']}
  click_button "Sign in"
  should_have_no_errors
end

def create_patient options
  login options[:professionals][0]
  click_link 'Patients'
  should_have_no_errors
  patients = options[:patients]
  patients.each do |pat|
    puts 'create patients ' + pat.to_s
    click_link 'New Patient'
    fill_answers  pat[:answers]
    populate_with_random_answers
    click_button 'Create Patient'
    page.should have_content "Patient was successfully created"
    click_link 'Back'
  end
end

def populate_with_random_answers
  selects = page.all(:xpath,'//select')
  selects.each do |node|
    if (node.value.blank? && node.visible?)
      puts 'populating ' + node[:name]
      select_random_option(node[:id])
      puts 'node[value] ' + node[:value]
    end
  end
end

def select_random_option(id)
  puts 'select_random_option ' + id
  second_options_xpath = "//*[@id='#{id}']/option"
  options = all(:xpath, second_options_xpath).map{|node| node.text}
  # we not choosing first option as it is blank
  index = 1 + rand(options.size-1)
  puts 'selecting  '  + options[index]
  select(options[index], :from => id)
end
