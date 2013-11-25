task :parse_and_save_genre_data => :environment do
  infobox = Infobox.all
  infobox.each do |infobox|
    page = infobox.page_id  # set page variable to help parse JSON hash in next line
    string = JSON.parse(infobox.infobox)["query"]["pages"]["#{page}"]["revisions"].first["*"] #parse JSON hash
    string2 = /\bgenre\b\s*=(?:\[\[)?(.+?)(?:(\]\]))?(?=\s\|)/m.match(string) #search for genre string

     # this code checks in genre string is nil, in which case end variables must first get set to nil.
     if string2.nil? 
       @genre1 = nil
       @genre2 = nil
       @genre3 = nil
       @genre4 = nil
       @genre5 = nil
     else
       # the first 3 lines here help further parse the code and isolate each genre. Each show can have multiple genres.
       string3 = string2.to_s.gsub(/<\/?[^>]*>/, "") #takes out html tags from code.
       string4 = string3.gsub("genre","").gsub("Unbulleted list","").gsub("Plainlist","") #takes out genre and a few other words.
       string5 = string4.scan(/\w+[\']?[\-]?\s*[\\]?\w+[\']?[\-]?\s?\w+[\']?[\-]?/m) #regex used to insolate each genre name.
       @genre1 = string5[0]
       @genre2 = string5[1]
       @genre3 = string5[2]
       @genre4 = string5[3]
       @genre5 = string5[4]
     end

    #find the appropriate entry in the Show model and save the first aired date:
    show = Show.where(:wikipage_id => page).first
    show.genre_1 = @genre1
    show.genre_2 = @genre2
    show.genre_3 = @genre3
    show.genre_4 = @genre4
    show.genre_5 = @genre5
    show.save
  end
end


task :parse_and_save_format_data => :environment do
  infobox = Infobox.all
  infobox.each do |infobox|
    page = infobox.page_id  # set page variable to help parse JSON hash in next line
    string = JSON.parse(infobox.infobox)["query"]["pages"]["#{page}"]["revisions"].first["*"] #parse JSON hash
    string2 = /\bformat\b\s*=(?:\[\[)?(.+?)(?:(\]\]))?(?=\s\|)/m.match(string) #search for format string

    # this code checks in format string is nil, in which case end variables must first get set to nil.
    if string2.nil?
      @format1 = nil
      @format2 = nil
      @format3 = nil
      @format4 = nil
      @format5 = nil
    else
      # the first 3 lines here help further parse the code and isolate each format. Each show can have multiple formats.
      string3 = string2.to_s.gsub(/<\/?[^>]*>/m, "") #takes out html tags from code.
      string4 = string3.gsub("format","").gsub("Unbulleted list","").gsub("Plainlist","") #takes out format and a few other words.
      string5 = string4.scan(/\w+[\']?[\-]?\s*[\\]?\w+[\']?[\-]?\s?\w+[\']?[\-]?/m) #regex used to insolate each format name.
      @format1 = string5[0]
      @format2 = string5[1]
      @format3 = string5[2]
      @format4 = string5[3]
      @format5 = string5[4]
    end

    #find the appropriate entry in the Show model and save the first aired date:
    show = Show.where(:wikipage_id => page).first
    show.format_1 = @format1
    show.format_2 = @format2
    show.format_3 = @format3
    show.format_4 = @format4
    show.format_5 = @format5
    show.save
  end
end

task :parse_and_save_first_aired_data => :environment do
  infobox = Infobox.all
  infobox.each do |infobox|
    page = infobox.page_id  # set page variable to help parse JSON hash in next line
    string = JSON.parse(infobox.infobox)["query"]["pages"]["#{page}"]["revisions"].first["*"]
    string2 = /(first_aired\s*=\s*+)(.+?(?=\s\|))/m.match(string) #look for patterns in the data to start at first_aired and end after the date
    #take the date out of string above, substitute "/" for "|" because you cannot parse the date below without doing this
    string3 = /(\d+)\|?(\d+)\|?(\d+)/m.match(string2.to_s).to_s.gsub("|","/")

    #if statement to first look for dates in the "YYYY" format and add text of "/01/01" so they become Date.parse friendly
    if ( string3 =~ /^\d{4}\z/m )
      @string4 = string3.to_s.concat("/01/01")
    else
      @string4 = string3 #set variable to original parsed result if it is not in "YYYY" format
    end

    #This test was necessary to prevent the Date.parse function from throwing an error when...
    #...the @string4 variable was nil, then sets @first_aired_match to nil if @string4 is nil.
    begin
      @first_aired_match = Date.parse(@string4)
    rescue
      @first_aired_match = nil
    end

    #find the appropriate entry in the Show model and save the first aired date:
    show = Show.where(:wikipage_id => page).first
    show.first_aired = @first_aired_match
    show.save
  end
end


task :parse_and_save_last_aired_data => :environment do
  infobox = Infobox.all
  infobox.each do |infobox|
    page = infobox.page_id  # set page variable to help parse JSON hash in next line
    string = JSON.parse(infobox.infobox)["query"]["pages"]["#{page}"]["revisions"].first["*"]
    string2 = /(last_aired\s*=\s*+)(.+?(?=\s\|))/m.match(string) #look for patterns in the data to start at first_aired and end after the date
                            #take the date out of string above, substitute "/" for "|" because you cannot parse the date below without doing this
    string3 = /((\d+)\|?(\d+)\|?(\d+)|present)/m.match(string2.to_s).to_s.gsub("|","/")

    #if statement to first look for dates in the "YYYY" format and add text of "/01/01" so they become Date.parse friendly
    if ( string3 =~ /^\d{4}\z/m )
      @string4 = string3.to_s.concat("/01/01")
    elsif ( string3 =~ /present/m )
      @string4 = Date.today.to_s
    else
      @string4 = string3 #set variable to original parsed result if it is not in "YYYY" format
    end

    #This test was necessary to prevent the Date.parse function from throwing an error when...
    #...the @string4 variable was nil, then sets @first_aired_match to nil if @string4 is nil.
    begin
      @last_aired_match = Date.parse(@string4)
    rescue
      @last_aired_match = nil
    end

    #find the appropriate entry in the Show model and save the first aired date:
    show = Show.where(:wikipage_id => page).first
    show.last_aired = @last_aired_match
    show.save
  end
end


task :parse_and_save_episode_data => :environment do
  infobox = Infobox.all
  infobox.each do |infobox|
    page = infobox.page_id # set page variable to help parse JSON hash in next line
    string = JSON.parse(infobox.infobox)["query"]["pages"]["#{page}"]["revisions"].first["*"]
    episode_match = /(?:num_episodes\s*=\s*)([0-9,]+)/m.match(string) #look for patterns in the data to start at num_episodes and end at the last date digit of the number

    #run an if statement to weed out nil data, so I can call the match grouping in the else statement
    if episode_match.nil?
      @episode_value = nil
    else
      @episode_value = episode_match[1] #set season value to second group of the match data
    end

    #Call the show model object where the wikipedia ID matches the page number of the JSON we just parsed.
    show = Show.where(:wikipage_id => page).first
    show.number_of_episodes = @episode_value
    show.save
  end
end


task :parse_and_save_season_data => :environment do
  infobox = Infobox.all
  infobox.each do |infobox|
    page = infobox.page_id # set page variable to help parse JSON hash in next line
    string = JSON.parse(infobox.infobox)["query"]["pages"]["#{page}"]["revisions"].first["*"]
    season_match = /(?:num_seasons\s*=\s*)([0-9]+)/m.match(string) #look for patterns in the data to start at num_seasons and end at the last date digit of the number

    #run an if statement to weed out nil data, so I can call the match grouping in the else statement
    if season_match.nil?
      @season_value = nil
    else
      @season_value = season_match[1] #set season value to second group of the match data
    end

    #Call the show model object where the wikipedia ID matches the page number of the JSON we just parsed.
    show = Show.where(:wikipage_id => page).first
    show.number_of_seasons = @season_value
    show.save
  end
end


task :parse_and_save_country_data => :environment do
  infobox = Infobox.all
  infobox.each do |infobox|
    page = infobox.page_id # set page variable to help parse JSON hash in next line
    string = JSON.parse(infobox.infobox)["query"]["pages"]["#{page}"]["revisions"].first["*"] #look for patterns in the data to start at country and parse the different answers
    string2 = /(?:\bcountry\b\s*=s*)(?:\[\[)?(.+?)(?:\]\])?(?=\s\|)/m.match(string)

    if string2.nil?
      @country_1 = nil
      @country_2 = nil
      @country_3 = nil
    else
      string3 = string2.to_s.gsub(/<\/?[^>]*>/, "|") #remove HTML tags from code, replace with "|" so different country names remain separated
      #remove the word country and use gsub to replace or remove freqently recurring terms or abbreviations.
      string4 = string3.gsub("country","").gsub(/unbulleted list|plainlist/i,"").gsub(/USA|TVUS|United States of America/i,"United States").gsub(/Television (in|of) the/i,"").gsub(/flagcountry/i,"")
      #use regex to pick the country name from the cleaned text
      string5 = string4.scan(/\w+[\']?[\-]?\s*[\\]?\w+[\']?[\-]?\s?\w+[\']?[\-]?/m)
      @country_1 = string5[0]
      @country_2 = string5[1]
      @country_3 = string5[2]
    end

    #Call the show model object where the wikipedia ID matches the country names that were just parsed.
    show = Show.where(:wikipage_id => page).first
    show.country_1 = @country_1
    show.country_2 = @country_2
    show.country_3 = @country_3
    show.save
  end
end


task :parse_and_save_network_data => :environment do
  infobox = Infobox.all
  infobox.each do |infobox|
    page = infobox.page_id # set page variable to help parse JSON hash in next line
    string = JSON.parse(infobox.infobox)["query"]["pages"]["#{page}"]["revisions"].first["*"] #look for patterns in the data to start at country and parse the different answers
    #Wikipedia entries use either 'network' or 'channel' to describe what I want as network info, so i search for both:
    string2 = /(?:\bnetwork|channel\b\s*=s*)(?:\[\[)?(.+?)(?:\]\])?(?=\s\|)/m.match(string)

    if string2.nil?
      @network_1 = nil
      @network_2 = nil
    else
      string3 = string2.to_s.gsub(/<\/?[^>]*>/, ",") #remove HTML tags from code, replace with "|" so different network or channel names remain separated
      #remove the word network or channel and use gsub to replace or remove freqently recurring terms or abbreviations.
      string4 = string3.gsub(/network|channel/i,"").gsub(/unbulleted list|plainlist/i,"").gsub(/(tv channel)/i,"").gsub(/American Broadcasting Company/i,"ABC").gsub(/Fox Broadcasting Company/i,"FOX").gsub(/Columbia Broadcasting System/i,"CBS").gsub(/National Broadcasting Company/i,"NBC").gsub(/Public Broadcasting Service/i,"PBS").gsub(/[0-9]{4}/,"")
      #use regex to pick the network or channel name from the cleaned text
      string5 = string4.scan(/\w+[\']?[\-]?\s*[\\]?\w+[\']?[\-]?\s?\w+[\']?[\-]?/m)
      @network_1 = string5[0]
      @network_2 = string5[1]
    end

    #Call the show model object where the wikipedia ID matches the network names that were just parsed.
    show = Show.where(:wikipage_id => page).first
    show.network_1 = @network_1
    show.network_2 = @network_2
    show.save
  end
end

task :dog => [:hello, :parse_and_save_genre_data] do
  puts "You are stinky"
end