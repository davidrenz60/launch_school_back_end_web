require "sinatra"
require "sinatra/reloader" if development?
require 'tilt/erubis'

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").each_with_index.map do |line, idx|
      "<p id=paragraph#{idx}>#{line}</p>"
    end.join
  end

  def highlight(text, term)
    text.gsub(term, "<strong>#{term}</strong>")
  end
end

not_found do
  redirect "/"
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  chapter_number = @contents[number + 1]
  @title = "Chapter #{number}: #{chapter_number}"
  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

get "/search" do
  if params[:query]
    @results = @contents.each_with_object([]).with_index do |(chapter, array), idx|
      text = File.read("data/chp#{idx + 1}.txt")
      paragraph = text.split("\n\n")
      paragraph.each_with_index do |para, para_index|
        array << [chapter, idx, para, para_index] if para.include?(params[:query])
      end
    end
  end
    

  erb :search
end

