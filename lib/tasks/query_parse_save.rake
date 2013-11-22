task :parse_and_save_genre_data => :environment do
  infobox = Infobox.all
  infobox.each do |infobox|
    page = infobox.page_id  # set page variable to help parse JSON hash in next line
    string = JSON.parse(infobox.infobox)["query"]["pages"]["#{page}"]["revisions"].first["*"] #parse JSON hash
    string2 = /\bgenre\b\s*=(?:\[\[)?(.+?)(?:(\]\]))?(?=\s\|)/.match(string) #search for genre string

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
       string5 = string4.scan(/\w+[\']?[\-]?\s*[\\]?\w+[\']?[\-]?\s?\w+[\']?[\-]?/) #regex used to insolate each genre name.
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
    string2 = /\bformat\b\s*=(?:\[\[)?(.+?)(?:(\]\]))?(?=\s\|)/.match(string) #search for format string

    # this code checks in format string is nil, in which case end variables must first get set to nil.
    if string2.nil?
      @format1 = nil
      @format2 = nil
      @format3 = nil
      @format4 = nil
      @format5 = nil
    else
      # the first 3 lines here help further parse the code and isolate each format. Each show can have multiple formats.
      string3 = string2.to_s.gsub(/<\/?[^>]*>/, "") #takes out html tags from code.
      string4 = string3.gsub("format","").gsub("Unbulleted list","").gsub("Plainlist","") #takes out format and a few other words.
      string5 = string4.scan(/\w+[\']?[\-]?\s*[\\]?\w+[\']?[\-]?\s?\w+[\']?[\-]?/) #regex used to insolate each format name.
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




task :dog => [:hello, :parse_and_save_genre_data] do
  puts "You are stinky"
end