require 'spec_helper'
puts "#{$:}"
puts "PATH=#{ENV['PATH']}"

describe Idea do

  let(:user) { create(:user) }
  before { @idea = user.ideas.build(content: "Lorem ipsum") }

  subject { @idea }

  it { should respond_to(:content) }
  it { should respond_to(:user) }
  it { should respond_to(:represented_by) }
  it { should respond_to(:representing) }
  
  describe "validation" do
    context "when user_id is not present" do
      before { @idea.user_id = nil }
      it { should_not be_valid }
    end
    
    context "with blank content" do
      before { @idea.content = " " }
      it { should_not be_valid }
    end
  
    context "with content that is too long" do
      before { @idea.content = "a" * 1401 }
      it { should_not be_valid }
    end
  end
  
  describe "representing" do
    before do
      @idea = create(:idea)
      @idea2 = create(:idea,represented_by:@idea)
      @idea3 = create(:idea,represented_by:@idea)
    end
    
    context "representing" do
      subject { @idea.representing }
      it { is_expected.to match_array([@idea2,@idea3]) }
    end
    
    context "rendersenting_and_self" do
      subject { @idea.representing_and_self }
      it { is_expected.to match_array([@idea,@idea2,@idea3]) }
    end
  end

  describe "similar" do
    before do
      @idea1 = create(:idea,content:'red green blue')
      @idea2 = create(:idea,content:'black white')
      @idea3 = create(:idea,content:'black green')
    end
    it "should not include itself" do
      expect(@idea1.similiar).not_to include(@idea1)
    end
    it "should include similiar" do
      expect(@idea1.similiar).to eq([@idea3])
    end
  end

  describe "create_with_merge" do
    before do
      @merge_to = create(:idea,title:'merge_to_title',content:'merge_to_body',user:create(:user),assets:create_list(:asset,3))
      @merged = create(:idea,title:'merged_title',content:'merged_body',user:create(:user),assets:create_list(:asset,2))
    end
    subject { Idea.create_with_merge!(@merge_to,@merged) }
    it "should merge two ideas" do
      expect(subject.title).to eq(@merge_to.title)
      expect(subject.content).to include(@merge_to.content,@merged.content,@merged.title)
      expect(subject.assets.count).to eq(@merge_to.assets.count+@merged.assets.count)
    end
  end

  describe "hashtags" do
    context "when saving with hashtag in context" do
      before do
        @idea.content ="#foo #bar #baz"
        @idea.save
      end
      it { expect(@idea.tags.pluck(:name)).to eq(["foo","bar","baz"])}
    end
  end

  describe "editable_by" do
    let(:users_idea) { create(:idea, user_id: user.id) }
    let(:other_user) { create(:user) }
    let(:other_users_idea) { create(:idea, user_id: other_user.id) }
    let(:representing_idea) {
      result = create(:idea,content:"merged idea")
      create(:idea,represented_by:result,user_id:user.id,content:"original idea")
      result
    }
    let(:subject) {
      Idea.where(id:[users_idea.id,other_users_idea.id,representing_idea.id]+
        representing_idea.representing.pluck(:id))
    }
    it "should show editable if ether directly editable" do
      expect(subject.editable_by(user)).to include(users_idea)
      expect(subject.editable_by(user)).not_to include(other_users_idea)
      expect(subject.editable_by(user)).to include(representing_idea)
    end
  end

  describe "order_by_likes_and_followed" do
    let(:o) { [0,2,3,1,4] }
    let(:order_without_follow) { [3,0,2,1,4] }
    let(:ideas) { create_list(:idea,5) }
    let(:user) { create(:user) }
    subject do
      # one like from followed is better than 2 like from other
      create_list(:like, 3, idea:ideas[o[0]], value: +1)
      ideas[o[0]].update(user: create(:user))
      user.follow!(ideas[o[0]].user)
      create_list(:like, 2, idea:ideas[o[1]], value: +1)
      ideas[o[1]].update(user: create(:user))
      user.follow!(ideas[o[1]].user)
      create_list(:like, 5, idea:ideas[o[2]], value: +1)
      create_list(:like, 2, idea:ideas[o[3]], value: +1)
      create_list(:like, 1, idea:ideas[o[4]], value: +1)
      Idea.where(id:ideas.map(&:id))
    end
    it "should order by likes but prefer friends" do
      expect(subject.order_by_likes.map{|i|i.likes.sum(:value)}).to eq([5, 3, 2, 2, 1])
      expect(subject.order_by_likes.to_a).to eq((0...5).map{|i|ideas[order_without_follow[i]]})
      expect(subject.order_by_likes_and_followed(user).to_a).to eq((0...5).map{|i|ideas[o[i]]})
    end
  end

  describe "order_by_like" do
    let(:o) { [0,2,3,1,4] }
    let(:ideas) { create_list(:idea, 5) }
    subject do
      create_list(:like, 2, idea:ideas[o[0]], value: +1)
      create_list(:like, 2, idea:ideas[o[1]], value: +1)
      create(:like, idea:ideas[o[1]], value: -1)
      create_list(:like, 2, idea:ideas[o[3]], value: +1)
      create_list(:like, 3, idea:ideas[o[3]], value: -1)
      create_list(:like, 2, idea:ideas[o[4]], value: -1)
      Idea.where(id:ideas.map(&:id))
    end

    it "should order by likes" do
      expect(subject.order_by_likes.map{|i|i.likes.sum(:value)}).to eq([2,1,0,-1,-2])
      expect(subject.order_by_likes.to_a).to eq((0...5).map{|i|ideas[o[i]]})
    end
  end
end
