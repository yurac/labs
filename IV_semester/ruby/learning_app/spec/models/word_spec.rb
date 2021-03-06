require File.dirname(__FILE__) + '/../spec_helper'

describe Word do
  fixtures :users
  fixtures :words
  fixtures :guesses

  before do
    @guess = Guess.new
  end

  describe Word, " validations/associations" do
    it { should validate_presence_of :value }
    it { should validate_presence_of :translation }
    it { should belong_to :user }
    it { should have_many :guesses }
    it { should have_many :tags }
    it { should have_and_belong_to_many :exams }
  end

  describe Word, " guessing" do
    it "should return true if guess was correct when guessing by value" do
      words(:spouse).guess(guesses(:correct_by_value)).should == true
    end

    it "should return true if guess was correct when guessing by translation " do
      words(:spouse).guess(guesses(:correct_by_translation)).should == true
    end

    it "should return false if guess was incorrect when guessing by value" do
      words(:spouse).guess(guesses(:incorrect_by_value)).should == false
    end

    it "should return false if guess was incorrect when guessing by translation" do
      words(:spouse).guess(guesses(:incorrect_by_translation)).should == false
    end

    it "should be guessed with specified accuracy"
  end

  describe Word, " counting guessing statistics" do
    it "should know how many times it was guessed" do
      2.times { words(:spouse).guess(guesses(:correct_by_value)) }
      2.times { words(:spouse).guess(guesses(:incorrect_by_value)) }

      words(:spouse).times_guessed.should == 4
    end

    it "should know how many times it was answered" do
      2.times { words(:spouse).guess(guesses(:correct_by_value)) }
      2.times { words(:spouse).guess(guesses(:incorrect_by_translation)) }

      words(:spouse).times_answered.should == 2
    end

    it "should be guessed and answerred equally" do
      2.times { words(:spouse).guess(guesses(:correct_by_translation)) }
      words(:spouse).times_guessed.should == words(:spouse).times_answered
    end
  end

  # testing webservice
  describe Word, " getting synonyms" do
    before do
      words(:test).synonym_finder = mock()
    end

    it "should get a specified number of synonyms in array" do
      words(:test).synonym_finder.expects(:related).with(words(:test).value, 2, :type => :synonym).returns([{"wordstrings"=>["judgment", "distinction"], "relType"=>"synonym"}])

      synonyms = words(:test).synonyms(2)
      synonyms.size.should == 2
    end

    it "s value should not be among returned synonyms" do
      words(:test).synonym_finder.expects(:related).with(words(:test).value, 2, :type => :synonym).returns([{"wordstrings"=>["judgment", "distinction"], "relType"=>"synonym"}])

      synonyms = words(:test).synonyms(2)
      synonyms.include?(words(:test).value).should == false 
    end

    it "should return 4 synonyms if count is not specified" do
      words(:test).synonym_finder.expects(:related).with(words(:test).value, 4, :type => :synonym).returns([{"wordstrings"=>["judgment", "distinction", "standard", "touchstone"], "relType"=>"synonym"}])

      words(:test).synonyms.size.should == 4
    end

    it "should get an array of similar translations" do
      words(:test).stubs(:synonyms).returns(["judgment", "distinction", "standard"])

      words(:test).synonym_finder.expects(:define).with("judgment", :count => 1).returns([{"headword"=>"judgment", "sequence"=>"0", "citations"=>[{"cite"=>"I oughte deme, of skilful <ex>jugement</ex>,\nThat in the salte sea my wife is deed.", "source"=>"Chaucer."}], "exampleUses"=>[{"text"=>"by careful <ex>judgment</ex> he avoided the peril; by a series of wrong <ex>judgments</ex> he forfeited confidence."}], "partOfSpeech"=>"noun", "text"=>"The act of judging; the operation of the mind, involving comparison and discrimination, by which a knowledge of the values and relations of things, whether of moral qualities, intellectual concepts, logical propositions, or material facts, is obtained", "id"=>720904, "seqString"=>"1."}]
)
      words(:test).synonym_finder.expects(:define).with("distinction", :count => 1).returns([{"headword"=>"distinction", "sequence"=>"0", "citations"=>[{"cite"=>"The <ex>distinction</ex> of tragedy into acts was not known.", "source"=>"Dryden."}], "partOfSpeech"=>"noun", "text"=>"A marking off by visible signs; separation into parts; division.", "id"=>675821, "seqString"=>"1.", "labels"=>[{"text"=>"obsolete", "type"=>"mark"}]}])

      words(:test).synonym_finder.expects(:define).with("standard", :count => 1).returns([{"headword"=>"standard", "sequence"=>"0", "citations"=>[{"cite"=>"His armies, in the following day,\nOn those fair plains their <ex>standards</ex> proud display.", "source"=>"Fairfax."}], "partOfSpeech"=>"noun", "text"=>"A flag; colors; a banner; especially, a national or other ensign.", "id"=>795578, "seqString"=>"1."}]
)

      words(:test).similar_definitions(3).size.should == 3
    end

    it "should return empty array if there was no synonyms" do
      words(:test).synonym_finder.expects(:related).with("123123_should_have_no_synonyms2k3j1l", 4, :type => :synonym).returns([])

      words(:test).stubs(:value => "123123_should_have_no_synonyms2k3j1l") 
      words(:test).synonyms.should be_empty
    end
  end
end
